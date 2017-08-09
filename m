From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master] bpf: unbreak libelf linkage for bpf obj loader
Date: Thu, 10 Aug 2017 00:15:41 +0200
Message-ID: <8ddcce8a9564e9c4a265db790002d6cd5ba8f353.1502316870.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59458 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752022AbdHIWPp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 18:15:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 69fed534a533 ("change how Config is used in Makefile's") moved
HAVE_MNL specific CFLAGS/LDLIBS for building with libmnl out of the
top level Makefile into sub-Makefiles. However, it also removed the
HAVE_ELF specific CFLAGS/LDLIBS entirely, which breaks the BPF object
loader for tc and ip with "No ELF library support compiled in." despite
having libelf detected in configure script. Fix it similarly as in
69fed534a533 for HAVE_ELF.

Fixes: 69fed534a533 ("change how Config is used in Makefile's")
Reported-by: Jeffrey Panneman <jeffrey.panneman@tno.nl>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ip/Makefile  | 4 ++++
 lib/Makefile | 4 ++++
 tc/Makefile  | 4 ++++
 3 files changed, 12 insertions(+)

diff --git a/ip/Makefile b/ip/Makefile
index 572604d..a754c04 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -19,6 +19,10 @@ ifeq ($(IP_CONFIG_SETNS),y)
 	CFLAGS += -DHAVE_SETNS
 endif
 
+ifeq ($(HAVE_ELF),y)
+	CFLAGS += -DHAVE_ELF
+	LDLIBS += -lelf
+endif
 ifeq ($(HAVE_MNL),y)
 	CFLAGS += -DHAVE_LIBMNL $(shell $(PKG_CONFIG) libmnl --cflags)
 	LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
diff --git a/lib/Makefile b/lib/Makefile
index 637fe48..b7b1d56 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -4,6 +4,10 @@ ifeq ($(IP_CONFIG_SETNS),y)
 	CFLAGS += -DHAVE_SETNS
 endif
 
+ifeq ($(HAVE_ELF),y)
+	CFLAGS += -DHAVE_ELF
+endif
+
 ifeq ($(HAVE_MNL),y)
 	CFLAGS += -DHAVE_LIBMNL $(shell $(PKG_CONFIG) libmnl --cflags)
 endif
diff --git a/tc/Makefile b/tc/Makefile
index c364a05..a9b4b8e 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -102,6 +102,10 @@ endif
 TCOBJ += $(TCMODULES)
 LDLIBS += -L. -lm
 
+ifeq ($(HAVE_ELF),y)
+	CFLAGS += -DHAVE_ELF
+	LDLIBS += -lelf
+endif
 ifeq ($(HAVE_MNL),y)
 	CFLAGS += -DHAVE_LIBMNL $(shell $(PKG_CONFIG) libmnl --cflags)
 	LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
-- 
1.9.3
