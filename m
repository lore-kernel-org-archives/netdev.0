From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 17/71] myri*: Move the Myricom drivers
Date: Tue, 02 Aug 2011 23:02:39 -0700
Message-ID: <1312351360.2294.95.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-18-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAMaF-rOs_8=F1-nKMSR4kosNuoGUTE284MKtRvSQ-X2p5sb+rw@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-aJOb1WMzPMAPy+pMNs7s"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: Jon Mason <jon.mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19160 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754436Ab1HCGCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 02:02:41 -0400
In-Reply-To: <CAMaF-rOs_8=F1-nKMSR4kosNuoGUTE284MKtRvSQ-X2p5sb+rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-aJOb1WMzPMAPy+pMNs7s
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-08-01 at 10:09 -0700, Jon Mason wrote:
> On Sat, Jul 30, 2011 at 10:26 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > Move the Myricom drivers into drivers/net/ethernet/myricom/ and make
> > the necessary Kconfig and Makefile changes.
>=20
> Acked-by: Jon Mason <mason@myri.com>
>=20
> > CC: Andrew Gallatin <gallatin@myri.com>
> > CC: Brice Goglin <brice@myri.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>=20

Jon-

I made some minor changes to the Kconfig based on feedback from others
on other Kconfig's which made sense to apply to the other driver
Kconfig's.  Here is the Kconfig:

+config NET_VENDOR_MYRI
+       bool "Myricom devices"
+       depends on PCI && INET
+       ---help---
+         If you have a network (Ethernet) card belonging to this class,
say
+         Y and read the Ethernet-HOWTO, available from
+         <http://www.tldp.org/docs.html#howto>.
+
+         Note that the answer to this question doesn't directly affect
the
+         kernel: saying N will just cause the configurator to skip all
+         the questions about Myricom cards. If you say Y, you will be
asked for
+         your specific card in the following questions.
+
+if NET_VENDOR_MYRI
+
+config MYRI10GE
+       tristate "Myricom Myri-10G Ethernet support"
+       depends on PCI && INET
+       select FW_LOADER
+       select CRC32
+       select INET_LRO
+       ---help---
+         This driver supports Myricom Myri-10G Dual Protocol interface
in
+         Ethernet mode. If the eeprom on your board is not recent
enough,
+         you will need a newer firmware image.
+         You may get this image or more information, at:
+
+         <http://www.myri.com/scs/download-Myri10GE.html>
+
+         To compile this driver as a module, choose M here. The module
+         will be called myri10ge.
+
+config MYRI10GE_DCA
+       bool "Direct Cache Access (DCA) Support"
+       default y
+       depends on MYRI10GE && DCA && !(MYRI10GE=3Dy && DCA=3Dm)
+       ---help---
+         Say Y here if you want to use Direct Cache Access (DCA) in the
+         driver.  DCA is a method for warming the CPU cache before data
+         is used, with the intent of lessening the impact of cache
misses.
+
+endif # NET_VENDOR_MYRI

Let me know if these changes are ok and I can add your ACK.

--=-aJOb1WMzPMAPy+pMNs7s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOOOR/AAoJECTsCADr/EWUt40H/1fxAq7QveeiKDFT9jXGHs1j
hLu4QwQ5nuyG286xFzBzrbtyDEHd5RqXMvIKdT/z01CXXNbaXC4XLoXWn3pr9yuA
yE+GlB7tQ5r6ydKOMix2bzxTPjLhkZXSS1X+aBbYzzie6ZV3PKZQRV6If6MfTAT3
r3Y+PIAZFnnR3jCawtbMjZYD4HHBLmVXKr2HqdM20V20jZNZLqg9ZlmNZZcj1tCQ
fy0UXngRHD0xLCWhcyqoth2X1lc18I3la/wce+2ZOuSKOgRGNkXq+RpsqtovEk3d
OCHi/x/xRTYk9lDfpsYpf6738mf3n4y8OpPJ2AmT8rsxIGWLw8nmnvqeZNHwJi0=
=BQCi
-----END PGP SIGNATURE-----

--=-aJOb1WMzPMAPy+pMNs7s--

