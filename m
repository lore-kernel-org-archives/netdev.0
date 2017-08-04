From: Marcus Meissner <meissner@suse.de>
Subject: [PATCH] iproute2/misc: do not mix CFLAGS with LDFLAGS
Date: Fri,  4 Aug 2017 11:54:02 +0200
Message-ID: <20170804095402.30943-1-meissner@suse.de>
Cc: Marcus Meissner <meissner@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45224 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751285AbdHDJyF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 05:54:05 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id E13E4ABB8
        for <netdev@vger.kernel.org>; Fri,  4 Aug 2017 09:54:03 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

during linking, do not use CFLAGS. This avoid clashes when doing PIE builds.
---
 misc/Makefile | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/misc/Makefile b/misc/Makefile
index 72807678..1d86c44d 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -23,17 +23,17 @@ all: $(TARGETS)
 ss: $(SSOBJ)
 	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
-nstat: nstat.c
-	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -o nstat nstat.c $(LIBNETLINK) -lm
+nstat: nstat.o
+	$(QUIET_CC)$(CC) $(LDFLAGS) -o nstat nstat.o $(LIBNETLINK) -lm
 
-ifstat: ifstat.c
-	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -o ifstat ifstat.c $(LIBNETLINK) -lm
+ifstat: ifstat.o
+	$(QUIET_CC)$(CC) $(LDFLAGS) -o ifstat ifstat.o $(LIBNETLINK) -lm
 
-rtacct: rtacct.c
-	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -o rtacct rtacct.c $(LIBNETLINK) -lm
+rtacct: rtacct.o
+	$(QUIET_CC)$(CC) $(LDFLAGS) -o rtacct rtacct.o $(LIBNETLINK) -lm
 
-arpd: arpd.c
-	$(QUIET_CC)$(CC) $(CFLAGS) -I$(DBM_INCLUDE) $(LDFLAGS) -o arpd arpd.c $(LIBNETLINK) -ldb -lpthread
+arpd: arpd.o
+	$(QUIET_CC)$(CC) $(LDFLAGS) -o arpd arpd.o $(LIBNETLINK) -ldb -lpthread
 
 ssfilter.c: ssfilter.y
 	$(QUIET_YACC)bison ssfilter.y -o ssfilter.c
-- 
2.12.3
