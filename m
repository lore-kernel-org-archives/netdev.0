From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH] fix HIPQUAD macro in kernel.h
Date: Thu, 8 Aug 2002 13:31:12 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020808133112.E11828@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HQbpMUFNRY4iYVZ3"
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <owner-netdev@oss.sgi.com>
To: David Miller <davem@redhat.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


--HQbpMUFNRY4iYVZ3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

Below is a fix for the HIPQUAD macro in kernel.h.  The macro is currently
not endian-aware - it just assumes running on a little-endian machine.

If you don't like the #ifdefs in kernel.h, the macros could be moved into=
=20
include/linux/byteorder/.

Please apply, thanks

--- linux-2.4.19-rc5-plain/include/linux/kernel.h	Wed Aug  7 22:55:03 2002
+++ linux-2.4.19-rc5-endian/include/linux/kernel.h	Thu Aug  8 11:34:13 2002
@@ -12,6 +12,7 @@
 #include <linux/stddef.h>
 #include <linux/types.h>
 #include <linux/compiler.h>
+#include <asm/byteorder.h>
=20
 /* Optimization barrier */
 /* The "volatile" is due to gcc bugs */
@@ -128,11 +129,17 @@
 	((unsigned char *)&addr)[2], \
 	((unsigned char *)&addr)[3]
=20
+#if defined(__LITTLE_ENDIAN)
 #define HIPQUAD(addr) \
 	((unsigned char *)&addr)[3], \
 	((unsigned char *)&addr)[2], \
 	((unsigned char *)&addr)[1], \
 	((unsigned char *)&addr)[0]
+#elif defined(__BIG_ENDIAN)
+#define HIPQUAD	NIPQUAD
+#else
+#error "Please fix asm/byteorder.h"
+#endif /* __LITTLE_ENDIAN */
=20
 /*
  * min()/max() macros that also do

--=20
Live long and prosper
- Harald Welte / laforge@gnumonks.org               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
GCS/E/IT d- s-: a-- C+++ UL++++$ P+++ L++++$ E--- W- N++ o? K- w--- O- M+=
=20
V-- PS++ PE-- Y++ PGP++ t+ 5-- !X !R tv-- b+++ !DI !D G+ e* h--- r++ y+(*)

--HQbpMUFNRY4iYVZ3
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE9UlZ/XaXGVTD0i/8RArgWAJ9v+OI9pUwvTFy5Cojwkr1Ks3+qsQCffIuQ
6Xs89gLqtxxuRoMB4rJeSF0=
=PdjG
-----END PGP SIGNATURE-----

--HQbpMUFNRY4iYVZ3--
