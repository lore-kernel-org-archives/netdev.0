From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] CAN: Add Flexcan CAN controller driver
Date: Sun, 25 Jul 2010 14:01:06 +0200
Message-ID: <4C4C2782.9030204@pengutronix.de>
References: <1279816844-12138-1-git-send-email-mkl@pengutronix.de> <4C4C1EDE.7020400@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig711A71A42F017026F86619B0"
Cc: wg@grandegger.com, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, davem@davemloft.net
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49920 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162Ab0GYMBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 08:01:08 -0400
In-Reply-To: <4C4C1EDE.7020400@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig711A71A42F017026F86619B0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Oliver Hartkopp wrote:
> first of all thanks for your contribution of the flexcan driver!

You're welcome!

> But i have a question regarding the Kconfig change that has been finall=
y
> committed to net-next-2.6.

> It looks like the pulled code has some extra HAVE_CAN_FLEXCAN config op=
tion -
> which may be something of your debugging environment - which was not pa=
rt of
> the original posted patch, where CAN_FLEXCAN depended on (ARCH_MX25 || =
ARCH_MX35).

Indeed this was not in the patch that Wolfgang Acked.

However, after Wolfgang's Ack I discussed the arm patches with the imx
people. I switched to dynamically registered devies, which is a more
modern way of registering them. And this led to the
"IMX_HAVE_PLATFORM_FLEXCAN" symbol (see below) and then we thought a
platform independent "HAVE_CAN_FLEXCAN" is even better.

So this was intentional (and in the latest patch I posed with the final
pull request.)

> Please see the two posted sections below ...

> The depency of (ARCH_MX25 || ARCH_MX35) makes more sense to me ;-)

The idea behind the "HAVE_CAN_FLEXCAN" is that all architectures select
this symbol if they have a flexcan core (which is supported by this
driver). On the imx platform we make this even in finer granularity.

BTW: If we on ARM finally have OF tree support we can change this easily
without needing to go over the net-next-2.6 tree.

Have a look at the corresponding ARM commits:
http://git.pengutronix.de/?p=3Dimx/linux-2.6.git;a=3Dcommit;h=3Dd7aec06a0=
decceabde9d9be6957229485568964b
http://git.pengutronix.de/?p=3Dimx/linux-2.6.git;a=3Dcommit;h=3Db5a326c8c=
0a01692e710fc6086ddf84128b7a7d3

Here in detail+
http://git.pengutronix.de/?p=3Dimx/linux-2.6.git;a=3Dblob;f=3Darch/arm/pl=
at-mxc/devices/Kconfig;h=3D9ab784b776f9192a33feaff37ff21be99b0a3691;hb=3D=
d7aec06a0decceabde9d9be6957229485568964b
We define a symbol without a prompt "IMX_HAVE_PLATFORM_FLEXCAN" for the
imx arm platform. This symbol selects "HAVE_CAN_FLEXCAN".

http://git.pengutronix.de/?p=3Dimx/linux-2.6.git;a=3Dblob;f=3Darch/arm/pl=
at-mxc/devices/platform-flexcan.c;h=3D5e97a01f14f3eb106750f00d8a0fffb66f2=
c9563;hb=3Dd7aec06a0decceabde9d9be6957229485568964b
A selected "IMX_HAVE_PLATFORM_FLEXCAN" symbol activates some glue code
that's used to create the individual flexcan devices.

It's up to the individual board code to select the
"IMX_HAVE_PLATFORM_FLEXCAN" symbol. This patch adds the flexcan support
on the pcm043:
http://git.pengutronix.de/?p=3Dimx/linux-2.6.git;a=3Dblobdiff;f=3Darch/ar=
m/mach-mx3/Kconfig;h=3D03563eb997c0f761ea7d7e14d155facfce880e03;hp=3De063=
657e1bf4c3f3d56a67e70bc3f17b333cfb55;hb=3Db5a326c8c0a01692e710fc6086ddf84=
128b7a7d3;hpb=3Dd7aec06a0decceabde9d9be6957229485568964b

I hope that answers you question,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig711A71A42F017026F86619B0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkxMJ4IACgkQjTAFq1RaXHPXWACeNd0jQ6u+y0VVrgPkWeCeJ6wh
XM4An0SDVgI5nrixI2JF9ZMumi/69Ad7
=DIiF
-----END PGP SIGNATURE-----

--------------enig711A71A42F017026F86619B0--
