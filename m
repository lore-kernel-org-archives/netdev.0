From: Jan Engelhardt <jengelh@inai.de>
Subject: [PATCH] build: must honor pkg-config flags for libmnl
Date: Mon, 29 Jun 2015 10:01:55 +0200
Message-ID: <1435564915-21929-1-git-send-email-jengelh@inai.de>
Cc: netdev@vger.kernel.org
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares41.inai.de ([46.4.122.207]:55110 "EHLO ares41.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752944AbbF2IB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 04:01:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The build otherwise fails if libmnl does not directly live in a
standard search path.
---
 tipc/Makefile | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/tipc/Makefile b/tipc/Makefile
index 4bda8c5..d4637f8 100644
--- a/tipc/Makefile
+++ b/tipc/Makefile
@@ -5,8 +5,11 @@ TIPCOBJ=bearer.o \
     node.o socket.o \
     tipc.o
 
+include ../Config
+
 TARGETS=tipc
-LDLIBS += -lmnl
+CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
+LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
 
 all: $(TARGETS) $(LIBS)
 
-- 
2.4.3
