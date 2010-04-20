From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: Socket filter access to hatype
Date: Tue, 20 Apr 2010 23:00:29 +0100
Message-ID: <20100420220029.GN19334@cel.leo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xtx0sNU5lZ46KfgK"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:52206 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752500Ab0DTWIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 18:08:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--xtx0sNU5lZ46KfgK
Content-Type: multipart/mixed; boundary="iAzLNm1y1mIRgolD"
Content-Disposition: inline


--iAzLNm1y1mIRgolD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

When capturing packets on a PF_PACKET/SOCK_RAW socket bound to all
interfaces, there doesn't appear to be a way for the filter program to
actually find out the underlying hardware type the packet was captured
on, such as is reported by the sll_hatype field of the struct sockaddr_ll
when the packet is sent up to userland.

Unless I've managed to miss a trick somewhere, this would seem to put a
fairly fundamental blocker on actually being able to filter in such
packets. Granted there's the SKF_OFF_NET area to inspect at the e.g. IPv4
level, but this makes it impossible to do anything on e.g. the Ethernet
level.

See attached for a patch to add an SKF_AD_HATYPE field, up among the
other special access fields around SKF_AD_OFF.

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--iAzLNm1y1mIRgolD
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="linux-SKF_AD_HATYPE.patch"
Content-Transfer-Encoding: quoted-printable

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
=20

--iAzLNm1y1mIRgolD--

--xtx0sNU5lZ46KfgK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFLziP8vLS2TC8cBo0RAkpdAJ4v2AZDc1ycWlBr4fHltS//buCpuwCeODxU
BbMbv72UaQN6IugGIFf6Uz0=
=ojM7
-----END PGP SIGNATURE-----

--xtx0sNU5lZ46KfgK--
