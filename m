From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 3/3] net: Add missing dependencies on NETDEVICES
Date: Tue, 18 Jun 2013 03:37:05 +0100
Message-ID: <1371523025.3495.68.camel@deadeye.wl.decadent.org.uk>
References: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hQKys/aJhas2H7W14huN"
Cc: netdev <netdev@vger.kernel.org>, linux-cris-kernel@axis.com,
	Chad Williamson <chad@dahc.us>,
	Daniel Cotey <puff65537@bansheeslibrary.com>,
	devel@driverdev.osuosl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51507 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644Ab3FRChS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 22:37:18 -0400
In-Reply-To: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hQKys/aJhas2H7W14huN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

ETRAX_ETHERNET selects ETHERNET and MII, which depend on NETDEVICES.
I don't think anything should select NETDEVICES, so make it a
dependency.  It also doesn't need to select or depend on ETHERNET,
which has nothing to do with the Ethernet library functions.

BPCTL selects MII, which depends on NETDEVICES.  But everything in the
drivers/staging/silicom directory is related to net devices, so make
NET_VENDOR_SILICOM depend on NETDEVICES and remove the now-redundant
dependencies on NET.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
There are still a few staging dr

 arch/cris/arch-v10/drivers/Kconfig |    3 +--
 arch/cris/arch-v32/drivers/Kconfig |    3 +--
 drivers/staging/silicom/Kconfig    |    6 +++---
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/arch/cris/arch-v10/drivers/Kconfig b/arch/cris/arch-v10/driver=
s/Kconfig
index 8eab0c6..daf5f19 100644
--- a/arch/cris/arch-v10/drivers/Kconfig
+++ b/arch/cris/arch-v10/drivers/Kconfig
@@ -2,8 +2,7 @@ if ETRAX_ARCH_V10
=20
 config ETRAX_ETHERNET
 	bool "Ethernet support"
-	depends on ETRAX_ARCH_V10
-	select ETHERNET
+	depends on ETRAX_ARCH_V10 && NETDEVICES
 	select MII
 	help
 	  This option enables the ETRAX 100LX built-in 10/100Mbit Ethernet
diff --git a/arch/cris/arch-v32/drivers/Kconfig b/arch/cris/arch-v32/driver=
s/Kconfig
index 91c4e54..4f22350 100644
--- a/arch/cris/arch-v32/drivers/Kconfig
+++ b/arch/cris/arch-v32/drivers/Kconfig
@@ -2,8 +2,7 @@ if ETRAX_ARCH_V32
=20
 config ETRAX_ETHERNET
 	bool "Ethernet support"
-	depends on ETRAX_ARCH_V32
-	select ETHERNET
+	depends on ETRAX_ARCH_V32 && NETDEVICES
 	select MII
 	help
 	  This option enables the ETRAX FS built-in 10/100Mbit Ethernet
diff --git a/drivers/staging/silicom/Kconfig b/drivers/staging/silicom/Kcon=
fig
index fc082db..6651bd8 100644
--- a/drivers/staging/silicom/Kconfig
+++ b/drivers/staging/silicom/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_SILICOM
 	bool "Silicom devices"
 	default y
-	depends on PCI
+	depends on PCI && NETDEVICES
 	---help---
 	  If you have a network card (Ethernet) belonging to this class,
 	  say Y.
@@ -19,7 +19,7 @@ if NET_VENDOR_SILICOM
=20
 config SBYPASS
 	tristate "Silicom BypassCTL library support"
-	depends on PCI && NET
+	depends on PCI
 	depends on m
 	---help---
 	  If you have a network (Ethernet) controller of this type, say Y
@@ -29,7 +29,7 @@ config SBYPASS
=20
 config BPCTL
 	tristate "Silicom BypassCTL net support"
-	depends on PCI && NET
+	depends on PCI
 	depends on m
 	select SBYPASS
 	select MII


--=-hQKys/aJhas2H7W14huN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUb/H0ee/yOyVhhEJAQr6Mw/+K4zpTV4+2PGlqZtFjfJfchGKu7VVrL6n
cn5h/ldT9yHszsn2P+PiE/0eIQCopYoxOMRZUz/ztES047+wfOvpnF23Udsx79MC
W+KxL20xM6cpQQdSXsLvSn6eXx+SNWET2U3P5fFC2rO7yPBQvEN9YS4t3ANNUsRx
9ItELxj2/ji/Cphlp9FCBohLveLrUWc8pVKw6dxeNeA18OHCAcV9oOW83rOcNTWv
7nX9YeXG228iFlLLe4LzonREJ1+oSfgntfptARy9ZPbrPOB6xN+xyuLqak1YnEf6
+bQQEiEYUYm45nShYEM4CSKpx+3+VQAEgRby2htS7I7T3CroeowZ+Q/cuPPiUZJp
D0qZ2toJm6BuhH64qwbdZBIOAazai2zXhfg7Fp2jlFS0HvcVTLly9pp5ohqmYhI8
j9NUxLfvdp63yUHU2lqH/JsE7dWsT9R8OA0MeuM0Awh8kJTtDChQ+Ubt01aCfaMj
M2CTNQSdQKvBflSpyKF6czHnjm8ITHI8UOlI47e29ewyLf3n1ztmXU4INsdunwpw
FSmnhxquMyIyUXobOCqjMBw4HVVQ1ADUi0DF31Pm2Q+Yju4LKa6obW2XokH6RnH4
+AC9vrmwX8Oypdxju0bmxt5fBb9PiBTSJF5yAf1zsgCAH0+tzr+AF4VBl0ZELa0G
pHo8st5rPyw=
=aDnn
-----END PGP SIGNATURE-----

--=-hQKys/aJhas2H7W14huN--
