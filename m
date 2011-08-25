From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next v2 04/10] headers, net: Use __kernel_sa_family_t in
 more definitions shared with userland
Date: Thu, 25 Aug 2011 05:43:55 +0100
Message-ID: <1314247451.27179.121.camel@deadeye>
References: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xqJ4fxiq0udY2oNQCCA+"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37143 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751846Ab1HYEoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 00:44:11 -0400
In-Reply-To: <1314247131.27179.116.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xqJ4fxiq0udY2oNQCCA+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Complete the work started with commit
6602a4baf4d1a73cc4685a39ef859e1c5ddf654c ('net: Make userland include
of netlink.h more sane').

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/atalk.h            |    3 ++-
 include/linux/ax25.h             |    2 +-
 include/linux/caif/caif_socket.h |    7 +------
 include/linux/can.h              |    2 +-
 include/linux/if_pppox.h         |    7 ++++---
 include/linux/in.h               |    2 +-
 include/linux/ipx.h              |    2 +-
 include/linux/irda.h             |    9 +++------
 include/linux/l2tp.h             |    7 ++++---
 include/linux/llc.h              |   10 +++++++---
 include/linux/netlink.h          |    2 +-
 include/linux/phonet.h           |    5 +++--
 include/linux/rose.h             |    5 +++--
 include/linux/un.h               |    4 +++-
 include/linux/x25.h              |    3 ++-
 15 files changed, 37 insertions(+), 33 deletions(-)

diff --git a/include/linux/atalk.h b/include/linux/atalk.h
index d34c187..f57c368 100644
--- a/include/linux/atalk.h
+++ b/include/linux/atalk.h
@@ -3,6 +3,7 @@
=20
 #include <linux/types.h>
 #include <asm/byteorder.h>
+#include <linux/socket.h>
=20
 /*
  * AppleTalk networking structures
@@ -28,7 +29,7 @@ struct atalk_addr {
 };
=20
 struct sockaddr_at {
-	sa_family_t	  sat_family;
+	__kernel_sa_family_t sat_family;
 	__u8		  sat_port;
 	struct atalk_addr sat_addr;
 	char		  sat_zero[8];
diff --git a/include/linux/ax25.h b/include/linux/ax25.h
index 56c11f0..74c89a4 100644
--- a/include/linux/ax25.h
+++ b/include/linux/ax25.h
@@ -47,7 +47,7 @@ typedef struct {
 } ax25_address;
=20
 struct sockaddr_ax25 {
-	sa_family_t	sax25_family;
+	__kernel_sa_family_t sax25_family;
 	ax25_address	sax25_call;
 	int		sax25_ndigis;
 	/* Digipeater ax25_address sets follow */
diff --git a/include/linux/caif/caif_socket.h b/include/linux/caif/caif_soc=
ket.h
index d9cb19b..3f3bac6 100644
--- a/include/linux/caif/caif_socket.h
+++ b/include/linux/caif/caif_socket.h
@@ -9,12 +9,7 @@
 #define _LINUX_CAIF_SOCKET_H
=20
 #include <linux/types.h>
-
-#ifdef __KERNEL__
 #include <linux/socket.h>
-#else
-#include <sys/socket.h>
-#endif
=20
 /**
  * enum caif_link_selector -    Physical Link Selection.
@@ -144,7 +139,7 @@ enum caif_debug_service {
  * CAIF Channel. It defines the service to connect to on the modem.
  */
 struct sockaddr_caif {
-	sa_family_t  family;
+	__kernel_sa_family_t  family;
 	union {
 		struct {
 			__u8  type;		/* type: enum caif_at_type */
diff --git a/include/linux/can.h b/include/linux/can.h
index d183333..bb047dc 100644
--- a/include/linux/can.h
+++ b/include/linux/can.h
@@ -78,7 +78,7 @@ struct can_frame {
  * @can_addr:    protocol specific address information
  */
 struct sockaddr_can {
-	sa_family_t can_family;
+	__kernel_sa_family_t can_family;
 	int         can_ifindex;
 	union {
 		/* transport protocol class address information (e.g. ISOTP) */
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index 60e5558..b5f927f 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -20,6 +20,7 @@
 #include <linux/types.h>
 #include <asm/byteorder.h>
=20
+#include <linux/socket.h>
 #include <linux/if_ether.h>
 #ifdef  __KERNEL__
 #include <linux/if.h>
@@ -63,7 +64,7 @@ struct pptp_addr {
 #define PX_MAX_PROTO   3
=20
 struct sockaddr_pppox {
-	sa_family_t     sa_family;            /* address family, AF_PPPOX */
+	__kernel_sa_family_t sa_family;       /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;          /* protocol identifier */
 	union {
 		struct pppoe_addr  pppoe;
@@ -77,7 +78,7 @@ struct sockaddr_pppox {
  * type instead.
  */
 struct sockaddr_pppol2tp {
-	sa_family_t     sa_family;      /* address family, AF_PPPOX */
+	__kernel_sa_family_t sa_family; /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;    /* protocol identifier */
 	struct pppol2tp_addr pppol2tp;
 } __attribute__((packed));
@@ -86,7 +87,7 @@ struct sockaddr_pppol2tp {
  * bits. So we need a different sockaddr structure.
  */
 struct sockaddr_pppol2tpv3 {
-	sa_family_t     sa_family;      /* address family, AF_PPPOX */
+	__kernel_sa_family_t sa_family; /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;    /* protocol identifier */
 	struct pppol2tpv3_addr pppol2tp;
 } __attribute__((packed));
diff --git a/include/linux/in.h b/include/linux/in.h
index beeb6de..01129c0 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -182,7 +182,7 @@ struct in_pktinfo {
 /* Structure describing an Internet (IP) socket address. */
 #define __SOCK_SIZE__	16		/* sizeof(struct sockaddr)	*/
 struct sockaddr_in {
-  sa_family_t		sin_family;	/* Address family		*/
+  __kernel_sa_family_t	sin_family;	/* Address family		*/
   __be16		sin_port;	/* Port number			*/
   struct in_addr	sin_addr;	/* Internet address		*/
=20
diff --git a/include/linux/ipx.h b/include/linux/ipx.h
index aabb1d2..3d48014 100644
--- a/include/linux/ipx.h
+++ b/include/linux/ipx.h
@@ -7,7 +7,7 @@
 #define IPX_MTU		576
=20
 struct sockaddr_ipx {
-	sa_family_t	sipx_family;
+	__kernel_sa_family_t sipx_family;
 	__be16		sipx_port;
 	__be32		sipx_network;
 	unsigned char 	sipx_node[IPX_NODE_LEN];
diff --git a/include/linux/irda.h b/include/linux/irda.h
index 00bdad0..a014c32 100644
--- a/include/linux/irda.h
+++ b/include/linux/irda.h
@@ -26,12 +26,9 @@
 #define KERNEL_IRDA_H
=20
 #include <linux/types.h>
+#include <linux/socket.h>
=20
-/* Please do *not* add any #include in this file, this file is
- * included as-is in user space.
- * Please fix the calling file to properly included needed files before
- * this one, or preferably to include <net/irda/irda.h> instead.
- * Jean II */
+/* Note that this file is shared with user space. */
=20
 /* Hint bit positions for first hint byte */
 #define HINT_PNP         0x01
@@ -125,7 +122,7 @@ enum {
 #define LSAP_ANY              0xff
=20
 struct sockaddr_irda {
-	sa_family_t sir_family;   /* AF_IRDA */
+	__kernel_sa_family_t sir_family; /* AF_IRDA */
 	__u8        sir_lsap_sel; /* LSAP selector */
 	__u32       sir_addr;     /* Device address */
 	char        sir_name[25]; /* Usually <service>:IrDA:TinyTP */
diff --git a/include/linux/l2tp.h b/include/linux/l2tp.h
index 4bdb31d..e77d7f9 100644
--- a/include/linux/l2tp.h
+++ b/include/linux/l2tp.h
@@ -8,8 +8,8 @@
 #define _LINUX_L2TP_H_
=20
 #include <linux/types.h>
-#ifdef __KERNEL__
 #include <linux/socket.h>
+#ifdef __KERNEL__
 #include <linux/in.h>
 #else
 #include <netinet/in.h>
@@ -26,14 +26,15 @@
 #define __SOCK_SIZE__	16		/* sizeof(struct sockaddr)	*/
 struct sockaddr_l2tpip {
 	/* The first fields must match struct sockaddr_in */
-	sa_family_t	l2tp_family;	/* AF_INET */
+	__kernel_sa_family_t l2tp_family; /* AF_INET */
 	__be16		l2tp_unused;	/* INET port number (unused) */
 	struct in_addr	l2tp_addr;	/* Internet address */
=20
 	__u32		l2tp_conn_id;	/* Connection ID of tunnel */
=20
 	/* Pad to size of `struct sockaddr'. */
-	unsigned char	__pad[sizeof(struct sockaddr) - sizeof(sa_family_t) -
+	unsigned char	__pad[sizeof(struct sockaddr) -
+			      sizeof(__kernel_sa_family_t) -
 			      sizeof(__be16) - sizeof(struct in_addr) -
 			      sizeof(__u32)];
 };
diff --git a/include/linux/llc.h b/include/linux/llc.h
index ad7074b..a2418ae 100644
--- a/include/linux/llc.h
+++ b/include/linux/llc.h
@@ -12,16 +12,20 @@
  *
  * See the GNU General Public License for more details.
  */
+
+#include <linux/socket.h>
+
 #define __LLC_SOCK_SIZE__ 16	/* sizeof(sockaddr_llc), word align. */
 struct sockaddr_llc {
-	sa_family_t     sllc_family;	/* AF_LLC */
-	sa_family_t	sllc_arphrd;	/* ARPHRD_ETHER */
+	__kernel_sa_family_t sllc_family; /* AF_LLC */
+	__kernel_sa_family_t sllc_arphrd; /* ARPHRD_ETHER */
 	unsigned char   sllc_test;
 	unsigned char   sllc_xid;
 	unsigned char	sllc_ua;	/* UA data, only for SOCK_STREAM. */
 	unsigned char   sllc_sap;
 	unsigned char   sllc_mac[IFHWADDRLEN];
-	unsigned char   __pad[__LLC_SOCK_SIZE__ - sizeof(sa_family_t) * 2 -
+	unsigned char   __pad[__LLC_SOCK_SIZE__ -
+			      sizeof(__kernel_sa_family_t) * 2 -
 			      sizeof(unsigned char) * 4 - IFHWADDRLEN];
 };
=20
diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 180540a..8180cd9 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -1,7 +1,7 @@
 #ifndef __LINUX_NETLINK_H
 #define __LINUX_NETLINK_H
=20
-#include <linux/socket.h> /* for sa_family_t */
+#include <linux/socket.h> /* for __kernel_sa_family_t */
 #include <linux/types.h>
=20
 #define NETLINK_ROUTE		0	/* Routing/device hook				*/
diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index 6fb1384..f53a416 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -24,6 +24,7 @@
 #define LINUX_PHONET_H
=20
 #include <linux/types.h>
+#include <linux/socket.h>
=20
 /* Automatic protocol selection */
 #define PN_PROTO_TRANSPORT	0
@@ -96,11 +97,11 @@ struct phonetmsg {
=20
 /* Phonet socket address structure */
 struct sockaddr_pn {
-	sa_family_t spn_family;
+	__kernel_sa_family_t spn_family;
 	__u8 spn_obj;
 	__u8 spn_dev;
 	__u8 spn_resource;
-	__u8 spn_zero[sizeof(struct sockaddr) - sizeof(sa_family_t) - 3];
+	__u8 spn_zero[sizeof(struct sockaddr) - sizeof(__kernel_sa_family_t) - 3]=
;
 } __attribute__((packed));
=20
 /* Well known address */
diff --git a/include/linux/rose.h b/include/linux/rose.h
index e8289cd..1fcfe95 100644
--- a/include/linux/rose.h
+++ b/include/linux/rose.h
@@ -7,6 +7,7 @@
 #ifndef	ROSE_KERNEL_H
 #define	ROSE_KERNEL_H
=20
+#include <linux/socket.h>
 #include <linux/ax25.h>
=20
 #define ROSE_MTU	251
@@ -46,7 +47,7 @@ typedef struct {
 } rose_address;
=20
 struct sockaddr_rose {
-	sa_family_t	srose_family;
+	__kernel_sa_family_t srose_family;
 	rose_address	srose_addr;
 	ax25_address	srose_call;
 	int		srose_ndigis;
@@ -54,7 +55,7 @@ struct sockaddr_rose {
 };
=20
 struct full_sockaddr_rose {
-	sa_family_t	srose_family;
+	__kernel_sa_family_t srose_family;
 	rose_address	srose_addr;
 	ax25_address	srose_call;
 	unsigned int	srose_ndigis;
diff --git a/include/linux/un.h b/include/linux/un.h
index 45561c5..3ed3e46 100644
--- a/include/linux/un.h
+++ b/include/linux/un.h
@@ -1,10 +1,12 @@
 #ifndef _LINUX_UN_H
 #define _LINUX_UN_H
=20
+#include <linux/socket.h>
+
 #define UNIX_PATH_MAX	108
=20
 struct sockaddr_un {
-	sa_family_t sun_family;	/* AF_UNIX */
+	__kernel_sa_family_t sun_family; /* AF_UNIX */
 	char sun_path[UNIX_PATH_MAX];	/* pathname */
 };
=20
diff --git a/include/linux/x25.h b/include/linux/x25.h
index 6450a7f..810cce6 100644
--- a/include/linux/x25.h
+++ b/include/linux/x25.h
@@ -12,6 +12,7 @@
 #define	X25_KERNEL_H
=20
 #include <linux/types.h>
+#include <linux/socket.h>
=20
 #define	SIOCX25GSUBSCRIP	(SIOCPROTOPRIVATE + 0)
 #define	SIOCX25SSUBSCRIP	(SIOCPROTOPRIVATE + 1)
@@ -57,7 +58,7 @@ struct x25_address {
  *	Linux X.25 Address structure, used for bind, and connect mostly.
  */
 struct sockaddr_x25 {
-	sa_family_t	   sx25_family;		/* Must be AF_X25 */
+	__kernel_sa_family_t sx25_family;	/* Must be AF_X25 */
 	struct x25_address sx25_addr;		/* X.121 Address */
 };
=20
--=20
1.7.5.4




--=-xqJ4fxiq0udY2oNQCCA+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlXTC+e/yOyVhhEJAQrP2Q//Y3TPJMqI5e/RUl1clV08eGiLXRT4jf+W
DXRLiKKUPIZHzEzMYer9kN1Zo9miHUforSszSALxSo99JeNqgi6UsGlv/rfSlzvS
qDKCVRwG8tDG+qWzTqgjuXQESXG0qiFMNIDBd0IlVACWzfBFiFePZuOpkhEgKqpW
vQKL/L6n5IIWWr3BQ053NM+ZWzCNd2uIt4tLtprzTzmr6l2AdSKi2SNbraWtL+7D
O0qUqY22WxKeY9QFOd9QfjDbtEnHCR0+GCqNzglW086kJphn8G/zwlt8uq1SsULZ
mI+bxZrC3S52hu9t9barUnoSHFcJJL7ddt4mJ4+5kw5cq7aws8TduA83e6eTa9d/
afovwntLrqlzyFkzGQqrwLza+cyt4JS2giTnipZfXh8dPHAPlYnktgSjI1GnqkSj
hEsZAwYKREJHbcg8MVkjn12ABseo3a7/kYvUbgacR2M+vlq6BIk5TreBqTjO6CzY
/KySrAfNf6Ss+JzWnmE4g7T7093hcnhr8vg0lWqIxZq0zp2vyz3J4ajV0lOn9SDN
wcCnL7rojmOiYLKw4B04btgdG8JdKpM/zcwepDdtYi6SLvpgkuaKr1dFP7WjSm9N
N0TY1IUTQgEWAODQR1Bbk9GEEzBPrROzoUttg9sXFWznn6X4noAMAWTJCE3aQAOU
O3qqHG8RVPc=
=DaDF
-----END PGP SIGNATURE-----

--=-xqJ4fxiq0udY2oNQCCA+--
