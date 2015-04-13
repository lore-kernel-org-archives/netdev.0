From: =?UTF-8?q?Pavel=20=C5=A0imerda?= <pavlix@pavlix.net>
Subject: [PATCH 2/7] turn Makefile more distribution friendly
Date: Mon, 13 Apr 2015 16:00:56 +0200
Message-ID: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, psimerda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:47550 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753708AbbDMOKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 10:10:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pavel =C5=A0imerda <psimerda@redhat.com>

Changes:

 * Accept directory settings from environment.
 * Remove redundant ROOTDIR variable.
 * Set KERNEL_INCLUDE default to '/usr/include'.
 * Use CFLAGS from environemnt.

Note: In the long term it might be better to improve the configure
script to generate those parts of the Makefile in a manner similar
to autoconf. It might be even practical to autotoolize the package.

Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>
---
 Makefile | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/Makefile b/Makefile
index 9dbb29f..18faee4 100644
--- a/Makefile
+++ b/Makefile
@@ -1,15 +1,15 @@
-ROOTDIR=3D$(DESTDIR)
-PREFIX=3D/usr
-LIBDIR=3D$(PREFIX)/lib
-SBINDIR=3D/sbin
-CONFDIR=3D/etc/iproute2
-DATADIR=3D$(PREFIX)/share
-DOCDIR=3D$(DATADIR)/doc/iproute2
-MANDIR=3D$(DATADIR)/man
-ARPDDIR=3D/var/lib/arpd
+PREFIX?=3D/usr
+LIBDIR?=3D$(PREFIX)/lib
+SBINDIR?=3D/sbin
+CONFDIR?=3D/etc/iproute2
+DATADIR?=3D$(PREFIX)/share
+DOCDIR?=3D$(DATADIR)/doc/iproute2
+MANDIR?=3D$(DATADIR)/man
+ARPDDIR?=3D/var/lib/arpd
+KERNEL_INCLUDE?=3D/usr/include
=20
 # Path to db_185.h include
-DBM_INCLUDE:=3D$(ROOTDIR)/usr/include
+DBM_INCLUDE:=3D$(DESTDIR)/usr/include
=20
 SHARED_LIBS =3D y
=20
@@ -33,7 +33,7 @@ CCOPTS =3D -O2
 WFLAGS :=3D -Wall -Wstrict-prototypes  -Wmissing-prototypes
 WFLAGS +=3D -Wmissing-declarations -Wold-style-definition -Wformat=3D2
=20
-CFLAGS =3D $(WFLAGS) $(CCOPTS) -I../include $(DEFINES)
+CFLAGS :=3D $(WFLAGS) $(CCOPTS) -I../include $(DEFINES) $(CFLAGS)
 YACCFLAGS =3D -d -t -v
=20
 SUBDIRS=3Dlib ip tc bridge misc netem genl man
--=20
2.3.5
