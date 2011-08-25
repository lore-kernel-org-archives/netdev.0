From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next v2 05/10] headers, net: Define struct
 __kernel_sockaddr, replacing struct sockaddr
Date: Thu, 25 Aug 2011 05:44:15 +0100
Message-ID: <1314247456.27179.122.camel@deadeye>
References: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PJ6TVQtS27iz4YtbLFvv"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37145 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751846Ab1HYEoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 00:44:16 -0400
In-Reply-To: <1314247131.27179.116.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PJ6TVQtS27iz4YtbLFvv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Commit 9c501935a3cdcf6b1d35aaee3aa11c7a7051a305 ('net: Support
inclusion of <linux/socket.h> before <sys/socket.h>') removed the
definition of struct sockaddr for userland.

But we still have several headers using struct sockaddr, and we
shouldn't make them include <sys/socket.h> as that risks recursive
inclusion in future.  Define and use an identical struct
__kernel_sockaddr instead.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/if.h     |   12 ++++++------
 include/linux/phonet.h |    3 ++-
 include/linux/socket.h |   17 +++++++++--------
 3 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/linux/if.h b/include/linux/if.h
index db20bd4..f9ce5fb 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -20,7 +20,7 @@
 #define _LINUX_IF_H
=20
 #include <linux/types.h>		/* for "__kernel_caddr_t" et al	*/
-#include <linux/socket.h>		/* for "struct sockaddr" et al	*/
+#include <linux/socket.h>		/* for "struct __kernel_sockaddr" et al	*/
 #include <linux/compiler.h>		/* for "__user" et al           */
=20
 #define	IFNAMSIZ	16
@@ -176,11 +176,11 @@ struct ifreq {
 	} ifr_ifrn;
 =09
 	union {
-		struct	sockaddr ifru_addr;
-		struct	sockaddr ifru_dstaddr;
-		struct	sockaddr ifru_broadaddr;
-		struct	sockaddr ifru_netmask;
-		struct  sockaddr ifru_hwaddr;
+		struct	__kernel_sockaddr ifru_addr;
+		struct	__kernel_sockaddr ifru_dstaddr;
+		struct	__kernel_sockaddr ifru_broadaddr;
+		struct	__kernel_sockaddr ifru_netmask;
+		struct  __kernel_sockaddr ifru_hwaddr;
 		short	ifru_flags;
 		int	ifru_ivalue;
 		int	ifru_mtu;
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index f53a416..9aba9ce 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -101,7 +101,8 @@ struct sockaddr_pn {
 	__u8 spn_obj;
 	__u8 spn_dev;
 	__u8 spn_resource;
-	__u8 spn_zero[sizeof(struct sockaddr) - sizeof(__kernel_sa_family_t) - 3]=
;
+	__u8 spn_zero[sizeof(struct __kernel_sockaddr) -
+		      sizeof(__kernel_sa_family_t) - 3];
 } __attribute__((packed));
=20
 /* Well known address */
diff --git a/include/linux/socket.h b/include/linux/socket.h
index d0e77f6..f13ad7b 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -10,6 +10,14 @@
=20
 typedef unsigned short __kernel_sa_family_t;
=20
+/*
+ *	1003.1g requires sa_family_t and that sa_data is char.
+ */
+struct __kernel_sockaddr {
+	__kernel_sa_family_t sa_family;	/* address family, AF_xxx	*/
+	char		sa_data[14];	/* 14 bytes of protocol address	*/
+};
+
 struct __kernel_sockaddr_storage {
 	__kernel_sa_family_t	ss_family;		/* address family */
 	/* Following field(s) are implementation specific */
@@ -39,15 +47,8 @@ extern void socket_seq_show(struct seq_file *seq);
=20
 typedef __kernel_sa_family_t	sa_family_t;
=20
-/*
- *	1003.1g requires sa_family_t and that sa_data is char.
- */
+#define sockaddr __kernel_sockaddr
 =20
-struct sockaddr {
-	sa_family_t	sa_family;	/* address family, AF_xxx	*/
-	char		sa_data[14];	/* 14 bytes of protocol address	*/
-};
-
 struct linger {
 	int		l_onoff;	/* Linger active		*/
 	int		l_linger;	/* How long to linger for	*/
--=20
1.7.5.4




--=-PJ6TVQtS27iz4YtbLFvv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlXTH+e/yOyVhhEJAQpPuw/+PI8PVwK4e9sKbPoMS9ifCLHdeWScI/lo
SeJO3ojRU9w6hAeJDYHeLfseP7viPwju0m/gfxUrHIdZWcfT2ia39FdkXtXaZxGS
qH6VGoxhgQ5qLd8eXY9w43cjbL7tyzaX+33a1zIlDMlrpjIfPvCRa+rUBRrbRr9W
XrlEi6cuYl4rlvxZVg0buEApZIIYkfkcKruOrVKV3WhTC8FK+9FcBEW/7eN2gqmC
asSuDdbIWPKfhdE8HnDT9fqVCOEgQbobyi73emYzYofr0woXFD8SbwQelLCqh5e7
9CGsfPM6opdQkyIsoxWevWuXuxf5EFibSUtFSyPJG5aNyCLJ/+1g4CpKWhTG8qdK
AQRYrIdNW5dRavw0oc1BMkUErkWZkUOeiAQM7Ne+F9/OUFNAYso83S5JDoykurgp
mElpYVoSo4lzqY4C96D69I8Wt6muyQnA+JWLE1V87UbGAJB04U0BhnUffGZkZjey
6stKiJap87ffYkL3S3AM6FHfX+tE861drHJY45xmasT2THhc2nQULbaJPXZDAgd/
/D/jr/72EOBihbbUG/XJ3y8hsEsaFUbgY73AH+XSh3sjaMgKWx85d5V8d/POb4UL
gEKgnqXYg8VIgFxSHbxF5pQSS55QGf/E2jj2BldEa3aPFAFuC0jBBI2KSUBC5vr6
/rwYD3eEnPE=
=uKYs
-----END PGP SIGNATURE-----

--=-PJ6TVQtS27iz4YtbLFvv--
