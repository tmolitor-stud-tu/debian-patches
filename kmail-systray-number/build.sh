#!/bin/bash
PACKET="kmail"
EXTRA_OPTIONS="--prefix=/usr --sysconfdir=/etc"
EMAIL="user@localhost"

echo "Cleaning up..."
rm -r *.deb 2>/dev/null
rm -r ${PACKET}* 2>/dev/null
echo "Installing build dependencies..."
su root -c "apt-get build-dep ${PACKET} $@"
echo "Downloading sources..."
apt-get source ${PACKET} $@
cd ${PACKET}-*

echo "Setting local version..."
EMAIL="$EMAIL" dch -l local 'local build'

echo "Patching via *.patch files..."
for file in ../*.patch; do
	echo "Applying patch $(basename "$file")..."
	patch -p1 -F 32 -N -r /dev/null < $file
done

echo "Please make your additional changes and press enter to build them..."
read -n 1 -s

DEB_BUILD_OPTIONS="parallel=32 $EXTRA_OPTIONS" fakeroot debian/rules binary

exit 0
