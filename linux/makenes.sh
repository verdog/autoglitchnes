#!/bin/bash
# generates a glitchy .nes ROM from the passed image 

if [ "$#" -ne 1 ]; then
    echo "usage: ./makenes.sh <image>"
    exit -1
fi

# check that makechr is in the directory in some way shape or form
if [ ! -f "makechr.py" ]; then
    echo "couldn't find makechr.py. please make sure it's in this directory. quitting."
    exit -2
fi

# makechr
python3 makechr.py $1 -o ${1%.*}\%s.dat

# check that makechr worked and put files where they were supposed to be
if [ ! -f ${1%.*}attribute.dat ] \
|| [ ! -f ${1%.*}palette.dat ] \
|| [ ! -f ${1%.*}nametable.dat ] \
|| [ ! -f ${1%.*}chr.dat ]; then
    echo "missing makechr output files. quitting."
    exit -3
fi

# glitch it
python3 ../glitch.py ${1%.*}

# do some truncating/combining
truncate -c -s 4K ${1%.*}chr.dat
cat ${1%.*}chr.dat ${1%.*}chr.dat ${1%.*}chr.dat ${1%.*}chr.dat \
    ${1%.*}chr.dat ${1%.*}chr.dat ${1%.*}chr.dat ${1%.*}chr.dat > ${1%.*}.chr
truncate -c -s 16 ${1%.*}palette.dat
mv ${1%.*}palette.dat ${1%.*}.pal
cat ${1%.*}nametable.dat ${1%.*}attribute.dat > ${1%.*}.dat

# compile asm6
gcc asm6.c -o asm6

# make the rom
./asm6 ${1%.*}.asm ${1%.*}.bin

# combine .bin and .chr
cat ${1%.*}.bin ${1%.*}.chr > ${1%.*}.nes
