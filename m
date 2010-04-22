From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: [PATCH] Socket filter ancilliary data access for skb->dev->type
Date: Thu, 22 Apr 2010 13:12:53 +0100
Message-ID: <20100422121253.GR19334@cel.leo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rUztinBX/EQDJOOk"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:57739 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752272Ab0DVMMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 08:12:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--rUztinBX/EQDJOOk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Add an SKF_AD_HATYPE field to the packet ancilliary data area, giving
access to skb->dev->type, as reported in the sll_hatype field.

When capturing packets on a PF_PACKET/SOCK_RAW socket bound to all
interfaces, there doesn't appear to be a way for the filter program to
actually find out the underlying hardware type the packet was captured
on. This patch adds such ability.

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
+++ linux-2.6.33.2/net/core/filter.c	2010-04-20 22:41:01.000000000 +0100
@@ -309,6 +309,9 @@
 		case SKF_AD_QUEUE:
 			A =3D skb->queue_mapping;
 			continue;
+		case SKF_AD_HATYPE:
+			A =3D skb->dev->type;
+			continue;
 		case SKF_AD_NLATTR: {
 			struct nlattr *nla;

--rUztinBX/EQDJOOk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFL0D1FvLS2TC8cBo0RAi/UAJ9l+qUM9qMcckw4mP2yVKKeLbwoMgCfUVRP
F2zVVywKmqfYcoHB54TmwVI=
=RVmD
-----END PGP SIGNATURE-----

--rUztinBX/EQDJOOk--
