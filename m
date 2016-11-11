From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: wl1251 & mac address & calibration data
Date: Fri, 11 Nov 2016 18:20:50 +0100
Message-ID: <201611111820.52072@pali>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2449889.yIGgG33EzT";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>, Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Sebastian Reichel <sre@kernel.org>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35505 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932864AbcKKRUz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 12:20:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2449889.yIGgG33EzT
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hi! I will open discussion about mac address and calibration data for=20
wl1251 wireless chip again...

Problem: Mac address & calibration data for wl1251 chip on Nokia N900=20
are stored on second nand partition (mtd1) in special proprietary format=20
which is used only for Nokia N900 (probably on N8x0 and N9 too).=20
Wireless driver wl1251.ko cannot work without mac address and=20
calibration data.

Absence of mac address cause that driver generates random mac address at=20
every kernel boot which has couple of problems (unstable identifier of=20
wireless device due to udev permanent storage rules; unpredictable=20
behaviour for dhcp mac address assignment, mac address filtering, ...).

Currently there is no way to set (permanent) mac address for network=20
interface from userspace. And it does not make sense to implement in=20
linux kernel large parser for proprietary format of second nand=20
partition where is mac address stored only for one device -- Nokia N900.

Driver wl1251.ko loads calibration data via request_firmware() for file=20
wl1251-nvs.bin. There are some "example" calibration file in linux-
firmware repository, but it is not suitable for normal usage as real=20
calibration data are per-device specific.

So questions are:

1) How to set mac address from userspace for that wl1251 interface? In=20
userspace I can write parser for that proprietary format of nand=20
partition and extract mac address from it

2) How to send calibration data to wl1251 driver? Those are again stored=20
in proprietary format and I can write userspace parser for it.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart2449889.yIGgG33EzT
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlgl/fQACgkQi/DJPQPkQ1KqxwCgtMjwxo2Mqu7qgaFjuXY4MGrD
d0UAoKpKMkZqfdEBDKJdqzzpYObpTEi9
=KhfV
-----END PGP SIGNATURE-----

--nextPart2449889.yIGgG33EzT--
