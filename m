From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: [PATCH] Accept -1 for IPV6_TCLASS
Date: Sun, 3 Sep 2006 10:28:30 +0300
Message-ID: <200609031028.31236@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 42.mail-out.ovh.net ([213.251.189.42]:48580 "EHLO
	42.mail-out.ovh.net") by vger.kernel.org with ESMTP
	id S1752124AbWICH2m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2006 03:28:42 -0400
To: yoshfuji@linux-ipv6.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hello,

This patch should add support for -1 as "default" IPv6 traffic class, a=
s=20
specified in IETF RFC3542 =C2=A76.5. Within the kernel, it seems tclass=
 < 0=20
is already handled, but setsockopt, getsockopt and recvmsg calls won't=20
accept it from userland.

Signed-off-by: Remi Denis-Courmont <rdenis@simphalempin.com>

diff -Nru linux-2.6.18-rc5-git6.orig/net/ipv6/datagram.c=20
linux-2.6.18-rc5-git6/net/ipv6/datagram.c
--- linux-2.6.18-rc5-git6.orig/net/ipv6/datagram.c	2006-03-20=20
07:53:29.000000000 +0200
+++ linux-2.6.18-rc5-git6/net/ipv6/datagram.c	2006-09-03=20
09:42:03.000000000 +0300
@@ -696,7 +696,7 @@
 			}
=20
 			tc =3D *(int *)CMSG_DATA(cmsg);
-			if (tc < 0 || tc > 0xff)
+			if (tc < -1 || tc > 0xff)
 				goto exit_f;
=20
 			err =3D 0;
diff -Nru linux-2.6.18-rc5-git6.orig/net/ipv6/ipv6_sockglue.c=20
linux-2.6.18-rc5-git6/net/ipv6/ipv6_sockglue.c
--- linux-2.6.18-rc5-git6.orig/net/ipv6/ipv6_sockglue.c	2006-09-03=20
09:47:10.000000000 +0300
+++ linux-2.6.18-rc5-git6/net/ipv6/ipv6_sockglue.c	2006-09-03=20
09:41:31.000000000 +0300
@@ -362,7 +362,7 @@
 		break;
=20
 	case IPV6_TCLASS:
-		if (val < 0 || val > 0xff)
+		if (val < -1 || val > 0xff)
 			goto e_inval;
 		np->tclass =3D val;
 		retv =3D 0;
@@ -947,6 +947,8 @@
=20
 	case IPV6_TCLASS:
 		val =3D np->tclass;
+		if (val < 0)
+			val =3D 0;
 		break;
=20
 	case IPV6_RECVTCLASS:


--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/

--=20
VGER BF report: U 0.93636
