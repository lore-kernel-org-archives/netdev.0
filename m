From: =?UTF-8?q?Diego=20Elio=20Petten=C3=B2?= <flameeyes@gmail.com>
Subject: [PATCH] Link directly to the archive files rather than using search paths.
Date: Fri, 10 Dec 2010 01:56:12 +0100
Message-ID: <1291942572-12653-1-git-send-email-flameeyes@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Kurtz <djkurtz@google.com>,
	Mike Frysinger <vapier@gentoo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48951 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab0LJA42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 19:56:28 -0500
Received: by wwa36 with SMTP id 36so3131602wwa.1
        for <netdev@vger.kernel.org>; Thu, 09 Dec 2010 16:56:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While the previous code was supposed to work nonetheless, it could be
messed up if further -L were used in LDFLAGS to list the path where gli=
bc's
libutil was to be found.

References: https://bugs.gentoo.org/347489

CC: Daniel Kurtz <djkurtz@google.com>
CC: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Diego Elio Petten=C3=B2 <flameeyes@gmail.com>
---
 Makefile |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/Makefile b/Makefile
index c03d74c..d1ace1f 100644
--- a/Makefile
+++ b/Makefile
@@ -33,11 +33,10 @@ CCOPTS =3D -D_GNU_SOURCE -O2 -Wstrict-prototypes -W=
all
 CFLAGS =3D $(CCOPTS) -I../include $(DEFINES)
 YACCFLAGS =3D -d -t -v
=20
-LDLIBS +=3D -L../lib -lnetlink -lutil
-
 SUBDIRS=3Dlib ip tc misc netem genl
=20
 LIBNETLINK=3D../lib/libnetlink.a ../lib/libutil.a
+LDLIBS +=3D $(LIBNETLINK)
=20
 all: Config
 	@set -e; \
--=20
1.7.3.3

