From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: [PATCHv2] Socket filter ancilliary data access for skb->dev->type
Date: Thu, 22 Apr 2010 14:32:22 +0100
Message-ID: <20100422133222.GU19334@cel.leo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="K0M4iRgkWWXhiQ9N"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:51448 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754771Ab0DVNcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 09:32:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--K0M4iRgkWWXhiQ9N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Add an SKF_AD_HATYPE field to the packet ancilliary data area, giving
access to skb->dev->type, as reported in the sll_hatype field.

When capturing packets on a PF_PACKET/SOCK_RAW socket bound to all
interfaces, there doesn't appear to be a way for the filter program to
actually find out the underlying hardware type the packet was captured
on. This patch adds such ability.

This patch also handles the case where skb->dev can be NULL, such as on
netlink sockets.

Signed-off-by: Paul Evans <leonerd@leonerd.org.uk>

---

diff -ur linux-2.6.33.2.orig/include/linux/filter.h linux-2.6.33.2/include/=
linux/filter.h
--- linux-2.6.33.2.orig/include/linux/filter.h	2010-04-02 00:02:33.00000000=
0 +0100
+++ linux-2.6.33.2/include/linux/filter.h	2010-04-20 22:40:25.000000000 +01=
00
@@ -123,7 +123,8 @@
 #define SKF_AD_NLATTR_NEST	16
 #define SKF_AD_MARK 	20
 #define SKF_AD_QUEUE	24
-#define SKF_AD_MAX	28
+#define SKF_AD_HATYPE	28
+#define SKF_AD_MAX	32
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
=20
diff -ur linux-2.6.33.2.orig/net/core/filter.c linux-2.6.33.2/net/core/filt=
er.c
--- linux-2.6.33.2.orig/net/core/filter.c	2010-04-02 00:02:33.000000000 +01=
00
+++ linux-2.6.33.2/net/core/filter.c	2010-04-22 14:19:24.000000000 +0100
@@ -301,6 +301,8 @@
 			A =3D skb->pkt_type;
 			continue;
 		case SKF_AD_IFINDEX:
+			if (!skb->dev)
+				return 0;
 			A =3D skb->dev->ifindex;
 			continue;
 		case SKF_AD_MARK:
@@ -309,6 +311,11 @@
 		case SKF_AD_QUEUE:
 			A =3D skb->queue_mapping;
 			continue;
+		case SKF_AD_HATYPE:
+			if (!skb->dev)
+				return 0;
+			A =3D skb->dev->type;
+			continue;
 		case SKF_AD_NLATTR: {
 			struct nlattr *nla;
=20

--K0M4iRgkWWXhiQ9N
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFL0E/lvLS2TC8cBo0RAgphAKDNPgBB0G9RAmHczzxY+pXNCIS52gCZAb7w
tM9oxWAqIbCFYoh0UQElfg8=
=ehFu
-----END PGP SIGNATURE-----

--K0M4iRgkWWXhiQ9N--
