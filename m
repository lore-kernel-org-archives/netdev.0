From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 21 Sep 2012 11:30:09 +1000
Message-ID: <20120921113009.29a296b6405b96b4d3c05f84@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__21_Sep_2012_11_30_09_+1000_.0CtsRlNUgBO2s0W"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?B?IkJqw7hybiBNb3JrIg==?= <bjorn@mork.no>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__21_Sep_2012_11_30_09_+1000_.0CtsRlNUgBO2s0W
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in drivers/net=
/usb/qmi_wwan.c between commit 9db273f45686 ("net: qmi_wwan: adding Huawei =
E367, ZTE MF683 and Pantech P4200") from the net tree and commit bd877e4891=
26 ("net: qmi_wwan: use a single bind function for all device types") from =
the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/usb/qmi_wwan.c
index 3543c9e,e7b53f0..0000000
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@@ -366,21 -353,17 +353,21 @@@ static const struct usb_device_id produ
  	},
 =20
  	/* 2. Combined interface devices matching on class+protocol */
 +	{	/* Huawei E367 and possibly others in "Windows mode" */
 +		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPEC, =
1, 7),
 +		.driver_info        =3D (unsigned long)&qmi_wwan_info,
 +	},
  	{	/* Huawei E392, E398 and possibly others in "Windows mode" */
  		USB_VENDOR_AND_INTERFACE_INFO(HUAWEI_VENDOR_ID, USB_CLASS_VENDOR_SPEC, =
1, 17),
- 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
+ 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
  	},
 -	{	/* Pantech UML290 */
 -		USB_DEVICE_AND_INTERFACE_INFO(0x106c, 0x3718, USB_CLASS_VENDOR_SPEC, 0x=
f0, 0xff),
 +	{	/* Pantech UML290, P4200 and more */
 +		USB_VENDOR_AND_INTERFACE_INFO(0x106c, USB_CLASS_VENDOR_SPEC, 0xf0, 0xff=
),
- 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
+ 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
  	},
  	{	/* Pantech UML290 - newer firmware */
 -		USB_DEVICE_AND_INTERFACE_INFO(0x106c, 0x3718, USB_CLASS_VENDOR_SPEC, 0x=
f1, 0xff),
 +		USB_VENDOR_AND_INTERFACE_INFO(0x106c, USB_CLASS_VENDOR_SPEC, 0xf1, 0xff=
),
- 		.driver_info        =3D (unsigned long)&qmi_wwan_shared,
+ 		.driver_info        =3D (unsigned long)&qmi_wwan_info,
  	},
 =20
  	/* 3. Combined interface devices matching on interface number */

--Signature=_Fri__21_Sep_2012_11_30_09_+1000_.0CtsRlNUgBO2s0W
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQW8MhAAoJEECxmPOUX5FELVYQAJNJPOzFx6x8Jc7s+FNATqTT
OIS5lEnttw1te2ha2AHCbSBVVYJ5XtfXJW14/Kf1wa8Zla6Qqb0DaTSbHu7e/jNn
Y7dKtX4DR35t8ChH1z4hvD6/X/f5sqZ4HYyTkLU+lK/P4dCI+5w4qnzQ+IsPvzE7
OJ+ePZMrK6e1pR693Q/e3zXdXO8iP0GPMCy87kG9lfEYRgMvYWcEfuox4el2udCY
gfzClClSqhSmV+4Yrjr9JBDfRvpXfWWOHqqKMT/CbJDeALS1XRiCJr45wtFctGwO
4yeduwU3q7Udwvw/r1jfFJPZAp49WW7HBYakjVMkU1ms4S09gbjesGukWLcEQ34z
hK0p0+Zo9ndglfRO+oPLrK1oGLxvFMBDq2oll2J2RPrnRpPSq1D7K2zmpKqKkwZY
SSCCIKDWROwsGKwUe1PF7qQ2FZmXR2tk3kCi2hJDkwEbSDcbBBP3CNnkEfcgjHOo
R7BT6Fl6tYojBkILoG+YcFcvPlmCPoQptEykjNakNdOT+Erphhuib1TjPuXy769D
oujVPLsGwS7rp4swNcbfDbNKXvIZoNxBQSvkbXIEixenIIdeBeUPrzuKIGBV6Q9i
xFVekXswWwTg/fnAv0Hdu2AobOmG6pdZMdz5JL7n93PXF2LWYBfSuAu+inhZ/A0m
uRj5Vw2KlwtY4thRkxts
=Nhpt
-----END PGP SIGNATURE-----

--Signature=_Fri__21_Sep_2012_11_30_09_+1000_.0CtsRlNUgBO2s0W--
