From: yegorslists@googlemail.com
Subject: [PATCH] iproute2: cleanup dependencies
Date: Mon, 27 Feb 2012 15:21:15 +0100
Message-ID: <1330352475-31109-1-git-send-email-yegorslists@googlemail.com>
Cc: shemminger@vyatta.com, Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.visionsystems.de ([62.145.30.242]:60184 "EHLO
	mail.visionsystems.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209Ab2B0OVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 09:21:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yegor Yefremov <yegorslists@googlemail.com>

LIBNETLINK will be defined in the main Makefile, so
both ../lib/libnetlink.a ../lib/libutil.a will be
automatically appended during linking. Otherwise
../lib/libnetlink.a ../lib/libutil.a will appear
twice during linking.

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
---
 ip/Makefile   |    7 ++++---
 misc/Makefile |    2 +-
 tc/Makefile   |    2 +-
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/ip/Makefile b/ip/Makefile
index 3f8c25b..e029ea1 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -17,11 +17,12 @@ ALLOBJ=$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=ifcfg rtpr routel routef
 TARGETS=ip rtmon
 
-all: $(TARGETS) $(SCRIPTS) $(LIBS)
+all: $(TARGETS) $(SCRIPTS)
 
-ip: $(IPOBJ) $(LIBNETLINK) $(LIBUTIL)
+ip: $(IPOBJ) $(LIBNETLINK)
 
-rtmon: $(RTMONOBJ) $(LIBNETLINK)
+
+rtmon: $(RTMONOBJ)
 
 install: all
 	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
diff --git a/misc/Makefile b/misc/Makefile
index 8c25381..a59ff87 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -7,7 +7,7 @@ include ../Config
 
 all: $(TARGETS)
 
-ss: $(SSOBJ) $(LIBUTIL)
+ss: $(SSOBJ)
 
 nstat: nstat.c
 	$(CC) $(CFLAGS) $(LDFLAGS) -o nstat nstat.c -lm
diff --git a/tc/Makefile b/tc/Makefile
index 9cc1bf0..f523adc 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -99,7 +99,7 @@ MODDESTDIR := $(DESTDIR)$(patsubst /usr%,%,$(LIBDIR))/tc
 
 all: libtc.a tc $(TCSO)
 
-tc: $(TCOBJ) $(LIBNETLINK) $(LIBUTIL) $(TCLIB)
+tc: $(TCOBJ) $(TCLIB)
 
 libtc.a: $(TCLIB)
 	$(AR) rcs $@ $(TCLIB)
-- 
1.7.7
