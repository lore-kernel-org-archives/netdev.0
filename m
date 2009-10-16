From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [BUILD-FAILURE] next-20091015 - vbus_enet driver breaks with
 allmodconfig
Date: Thu, 15 Oct 2009 20:29:09 -0400
Message-ID: <4AD7BE55.5050905@gmail.com>
References: <20091015152538.74a1cb15.sfr@canb.auug.org.au> <20091015104852.GA6740@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig38C353B18AFE9ABD0D88BB72"
Cc: ghaskins@novell.com, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, greg@kroah.com
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:54847 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758688AbZJPAaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 20:30:23 -0400
In-Reply-To: <20091015104852.GA6740@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig38C353B18AFE9ABD0D88BB72
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Kamalesh Babulal wrote:
> Hi Gregory,
>=20
> 	While building next-20091015 with allmodconfig on the powerpc
> vbus-enet driver breaks
>=20
> MODPOST 2492 modules
> ERROR: ".vbus_driver_register" [drivers/net/vbus-enet.ko] undefined!
> ERROR: ".vbus_driver_unregister" [drivers/net/vbus-enet.ko] undefined!
> ERROR: ".vbus_driver_ioq_alloc" [drivers/net/vbus-enet.ko] undefined!
>=20
> CONFIG_VBUS_ENET=3Dm
> CONFIG_VBUS_ENET_DEBUG=3Dy
> CONFIG_VBUS_PROXY=3Dn

Hi Kamalesh,

Please try the following patch:

commit 1de440616ac84679902d045b4476effcebfae400
Author: Gregory Haskins <ghaskins@novell.com>
Date:   Thu Oct 15 20:25:05 2009 -0400

    net: fix vbus-enet Kconfig dependencies

    We currently select VBUS_PROXY when vbus-enet is enabled, which is
    the wrong direction.  Not all platforms will define VBUS-PROXY, and
    venet depends on its inclusion.  Therefore, lets fix vbus-enet to
    properly depend on the presence of VBUS_PROXY to get this right.

    Signed-off-by: Gregory Haskins <ghaskins@novell.com>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 47dfa04..c9128ea 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3233,7 +3233,7 @@ config VIRTIO_NET
 config VBUS_ENET
        tristate "VBUS Ethernet Driver"
        default n
-       select VBUS_PROXY
+       depends on VBUS_PROXY
        help
           A virtualized 802.x network device based on the VBUS
           "virtual-ethernet" interface.  It can be used with any




--------------enig38C353B18AFE9ABD0D88BB72
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkrXvlUACgkQP5K2CMvXmqG/DgCaAgpjHZ8jzeARE8KA/yJ5Ycek
ab4An30M7wOxsz9GTpS3+9BMmphlu4G7
=QLOe
-----END PGP SIGNATURE-----

--------------enig38C353B18AFE9ABD0D88BB72--
