From: "Christoph J. Thompson" <cjsthompson@gmail.com>
Subject: [PATCH 4/4] iproute2 - Fix up and simplify variables pointing to
 install directories. Define where is the are located the iproute2 config
 files. Get rid of trailing slashes for paths in several file.
Date: Thu, 1 Mar 2012 17:46:26 +0100
Message-ID: <20120301164622.GA24306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:42653 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756400Ab2CAQqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 11:46:17 -0500
Received: by wejx9 with SMTP id x9so483915wej.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 08:46:16 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	modified:   Makefile
	modified:   ip/iplink.c
	modified:   tc/Makefile
	modified:   tc/tc_util.c

Signed-off-by: Christoph J. Thompson <cjsthompson@gmail.com>
---
 Makefile     |   11 +++++++----
 ip/iplink.c  |    2 +-
 tc/Makefile  |    2 +-
 tc/tc_util.c |    2 +-
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/Makefile b/Makefile
index fb5f5d3..2d0192e 100644
--- a/Makefile
+++ b/Makefile
@@ -1,10 +1,11 @@
-DESTDIR=/usr/
 ROOTDIR=$(DESTDIR)
-LIBDIR=/usr/lib/
+PREFIX=/usr
+LIBDIR=$(PREFIX)/lib
 SBINDIR=/sbin
 CONFDIR=/etc/iproute2
-DOCDIR=/share/doc/iproute2
-MANDIR=/share/man
+DATADIR=$(PREFIX)/share
+DOCDIR=$(DATADIR)/doc/iproute2
+MANDIR=$(DATADIR)/man
 ARPDDIR=/var/lib/arpd
 
 # Path to db_185.h include
@@ -17,6 +18,8 @@ ifneq ($(SHARED_LIBS),y)
 DEFINES+= -DNO_SHARED_LIBS
 endif
 
+DEFINES+=-DCONFDIR=\"$(CONFDIR)\"
+
 #options if you have a bind>=4.9.4 libresolv (or, maybe, glibc)
 LDLIBS=-lresolv
 ADDLIB=
diff --git a/ip/iplink.c b/ip/iplink.c
index 6b051b6..72a9866 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -34,7 +34,7 @@
 
 #define IPLINK_IOCTL_COMPAT	1
 #ifndef LIBDIR
-#define LIBDIR "/usr/lib/"
+#define LIBDIR "/usr/lib"
 #endif
 
 static void usage(void) __attribute__((noreturn));
diff --git a/tc/Makefile b/tc/Makefile
index f523adc..be8cd5a 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -91,7 +91,7 @@ YACC := bison
 LEX := flex
 CFLAGS += -DYY_NO_INPUT
 
-MODDESTDIR := $(DESTDIR)$(patsubst /usr%,%,$(LIBDIR))/tc
+MODDESTDIR := $(DESTDIR)$(LIBDIR)/tc
 
 %.so: %.c
 	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic $< -o $@
diff --git a/tc/tc_util.c b/tc/tc_util.c
index 5829d61..bd7f9e0 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -25,7 +25,7 @@
 #include "tc_util.h"
 
 #ifndef LIBDIR
-#define LIBDIR "/usr/lib/"
+#define LIBDIR "/usr/lib"
 #endif
 
 const char *get_tc_lib(void)
-- 
1.7.4.4


-- 
Jabber: heimdal@jabber.org
