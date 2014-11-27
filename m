From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: wl1251: NVS firmware data
Date: Thu, 27 Nov 2014 15:06:20 +0100
Message-ID: <201411271506.20457@pali>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2511393.6NRFU7IPkM";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: "John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ming Lei <ming.lei@canonical.com>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2511393.6NRFU7IPkM
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hello,

wifi driver wl1251 needs NVS calibration data for working. These=20
data are loaded by driver via request_firmware from userspace=20
file: ti-connectivity/wl1251-nvs.bin. In linux-fimrware git tree=20
there is generic wl1251-nvs.bin file which is used by default.

Driver wl1251 is used on Nokia N900 cellphone for its wifi chip.=20
This cellphone has one special MTD partition (called CAL) where=20
are stored some configuration data in special binary (key-value)=20
format. And there is also stored correct calibration data for=20
specific device (each device has different data). It is preferred=20
to use those data instead generic one (provided by linux-firmware=20
git tree).

Now my question is: How to correctly load calibration data from=20
special Nokia N900 CAL partition into wl1251 kernel driver?

By default kernel reads ti-connectivity/wl1251-nvs.bin file from=20
VFS if exists without any userspace support. If it fails then it=20
fallback to loading via udev.

Reading correct data from CAL partition is not easy (structure is=20
difficult), but there is open source program which can parse CAL=20
partition and write NVS data to stdout. So adding this CAL parser=20
into kernel is not good idea (program is GPLv3+ code --=20
incompatible with kernel).

So how to solve this problem? How to load correct NVS data from=20
CAL partition into wl1251 driver?

It is possible to tell kernel to use some helper userspace=20
program for loading data and if it fails then fallback to direct=20
loading? E.g first try to use model specific data and if it fails=20
for some reasons then fallback to reading genetic data.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart2511393.6NRFU7IPkM
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlR3L9wACgkQi/DJPQPkQ1L/qQCgukIuGXsBlSf52W0+ktfjS83g
kTMAnj1l7WkgutGJdPl3Y7VFRpRDm74t
=DV3s
-----END PGP SIGNATURE-----

--nextPart2511393.6NRFU7IPkM--
