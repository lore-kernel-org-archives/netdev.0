From: Mike Frysinger <vapier@gentoo.org>
Subject: [patch/iputils] tweak makefile to be more flexible
Date: Wed, 20 Dec 2006 10:23:58 -0500
Message-ID: <200612201023.59455.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_PWViF4u5oM3Osnz"
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:37227 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965129AbWLTPXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 10:23:54 -0500
Received: from home.wh0rd.org (pool-141-154-225-206.bos.east.verizon.net [141.154.225.206])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id B77DE649DA
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 15:23:47 +0000 (UTC)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_PWViF4u5oM3Osnz
Content-Type: multipart/signed;
  boundary="nextPart4879543.jKogtMC1jc";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart4879543.jKogtMC1jc
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

this patch tweaks the makefile so that it respects user environment variabl=
es=20
such as CC/CFLAGS/etc... and cleans out some cruft that is no longer utiliz=
ed
=2Dmike

--nextPart4879543.jKogtMC1jc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBFiVWPK9sYciBdMQMRAvBxAJ40WiBfFAZUXWsSRdSobG8gJ6t1iQCgh60i
9OQsxID/VPCIeQJOx08pRg4=
=I+/n
-----END PGP SIGNATURE-----

--nextPart4879543.jKogtMC1jc--

--Boundary-00=_PWViF4u5oM3Osnz
Content-Type: text/x-diff;
  charset="us-ascii";
  name="iputils-makefile.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="iputils-makefile.patch"

Respect user environment variables.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>

diff --git a/Makefile b/Makefile
index 54c1de5..7a7b045 100644
--- a/Makefile
+++ b/Makefile
@@ -1,20 +1,18 @@
 # Path to parent kernel include files directory
 LIBC_INCLUDE=/usr/include
 
-DEFINES= 
-
 #options if you have a bind>=4.9.4 libresolv (or, maybe, glibc)
 LDLIBS=-lresolv
-ADDLIB=
 
 #options if you compile with libc5, and without a bind>=4.9.4 libresolv
 # NOT AVAILABLE. Please, use libresolv.
 
-CC=gcc
+CC ?= gcc
 # What a pity, all new gccs are buggy and -Werror does not work. Sigh.
 #CCOPT=-D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -g -Werror
-CCOPT=-D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -g
-CFLAGS=$(CCOPT) $(GLIBCFIX) $(DEFINES) 
+CFLAGS ?= -O2 -g
+CFLAGS += -Wstrict-prototypes -Wall
+CPPFLAGS += -D_GNU_SOURCE
 
 IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd
 IPV6_TARGETS=tracepath6 traceroute6 ping6
@@ -33,9 +31,8 @@ ping.o ping6.o ping_common.o: ping_common.h
 tftpd.o tftpsubs.o: tftp.h
 
 rdisc_srv: rdisc_srv.o
-
 rdisc_srv.o: rdisc.c
-	$(CC) $(CFLAGS) -DRDISC_SERVER -o rdisc_srv.o rdisc.c
+	$(CC) $(CFLAGS) $(CPPFLAGS) -DRDISC_SERVER -o rdisc_srv.o rdisc.c
 
 
 check-kernel:

--Boundary-00=_PWViF4u5oM3Osnz--
