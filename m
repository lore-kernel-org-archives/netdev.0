From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251: NVS firmware data
Date: Thu, 27 Nov 2014 15:43:23 +0100
Message-ID: <201411271543.23527@pali>
References: <201411271506.20457@pali> <CACVXFVMr8jH1ZzyPNG91VDK8DuVjQsHn9ks62sSNjOfUnNsURQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8750784.QH8Oi3TROF";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Grazvydas Ignotas <notasas@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	Pavel Machek <pavel@ucw.cz>,
	Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
	Aaro Koskinen <aaro.koskinen@iki.fi>,
	Kalle Valo <kvalo@adurom.com>,
	Sebastian Reichel <sre@ring0.de>,
	David Gnedt <david.gnedt@davizone.at>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACVXFVMr8jH1ZzyPNG91VDK8DuVjQsHn9ks62sSNjOfUnNsURQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart8750784.QH8Oi3TROF
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Thursday 27 November 2014 15:21:44 Ming Lei wrote:
> On Thu, Nov 27, 2014 at 10:06 PM, Pali Roh=C3=A1r=20
<pali.rohar@gmail.com> wrote:
> > Hello,
> >=20
> > wifi driver wl1251 needs NVS calibration data for working.
> > These data are loaded by driver via request_firmware from
> > userspace file: ti-connectivity/wl1251-nvs.bin. In
> > linux-fimrware git tree there is generic wl1251-nvs.bin
> > file which is used by default.
> >=20
> > Driver wl1251 is used on Nokia N900 cellphone for its wifi
> > chip. This cellphone has one special MTD partition (called
> > CAL) where are stored some configuration data in special
> > binary (key-value) format. And there is also stored correct
> > calibration data for specific device (each device has
> > different data). It is preferred to use those data instead
> > generic one (provided by linux-firmware git tree).
> >=20
> > Now my question is: How to correctly load calibration data
> > from special Nokia N900 CAL partition into wl1251 kernel
> > driver?
>=20
> It is better to let user space script handle the request.
>=20

Yes, this makes sense. Implementing CAL parser in kernel wl1251=20
driver would be hard...

> > By default kernel reads ti-connectivity/wl1251-nvs.bin file
> > from VFS if exists without any userspace support. If it
> > fails then it fallback to loading via udev.
>=20
> You can remove or rename this file so that loading from user
> space can be triggered.
>=20

It is no so easy... In case when CAL does not contains NVS data=20
then we want to use this generic NVS file. And telling everybody=20
to rename this is file is not good solution...

> > Reading correct data from CAL partition is not easy
> > (structure is difficult), but there is open source program
> > which can parse CAL partition and write NVS data to stdout.
> > So adding this CAL parser into kernel is not good idea
> > (program is GPLv3+ code -- incompatible with kernel).
> >=20
> > So how to solve this problem? How to load correct NVS data
> > from CAL partition into wl1251 driver?
> >=20
> > It is possible to tell kernel to use some helper userspace
> > program for loading data and if it fails then fallback to
> > direct loading? E.g first try to use model specific data
> > and if it fails for some reasons then fallback to reading
> > genetic data.
>=20
> One solution is to introduce request_firmware_user() and let
> this API handle your case, but CONFIG_FW_LOADER_USER_HELPER
> has to be enabled.
>=20
> If request_firmware_user() fails, request_firmware_direct()
> can be tried further.
>=20
> Thanks,
> Ming Lei

Ok, new kernel function which will change order of loading=20
firmware should work.

Which userspace helper programs for (automatic) firmware loading=20
are used? Can be udev configured to use own program for loading=20
firmware instead that udev integrated which looking for firmware=20
only in /lib/firmware files?

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart8750784.QH8Oi3TROF
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlR3OIsACgkQi/DJPQPkQ1LipwCgi04jap1AjfxqRGw5XBZ6YyJT
6tsAn2XWVa8RSHLSILHuxeTU0zOe6H6q
=PUzE
-----END PGP SIGNATURE-----

--nextPart8750784.QH8Oi3TROF--
