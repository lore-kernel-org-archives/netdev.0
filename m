From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] add a `make dist` helper
Date: Fri, 14 Dec 2012 01:34:02 -0500
Message-ID: <1355466842-20123-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:34913 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab2LNGdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 01:33:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes sure the tarball is always created in the same way.
Avoids accidental typos in path names for example.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 .gitignore |  1 +
 Makefile   | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/.gitignore b/.gitignore
index 3ba2632..e4490f4 100644
--- a/.gitignore
+++ b/.gitignore
@@ -1,3 +1,4 @@
+iproute2-*.tar*
 static-syms.h
 config.*
 Config
diff --git a/Makefile b/Makefile
index 46a5ad9..198abea 100644
--- a/Makefile
+++ b/Makefile
@@ -75,6 +75,16 @@ clobber:
 
 distclean: clobber
 
+GIT_ARCHIVE = git archive --prefix=iproute2-$(VER)/ v$(VER) | $(1) > iproute2-$(VER).tar.$(2)
+dist.gz:  ; $(call GIT_ARCHIVE,gzip,gz)
+dist.bz2: ; $(call GIT_ARCHIVE,bzip2,bz2)
+dist.xz:  ; $(call GIT_ARCHIVE,xz,xz)
+dist:
+ifeq ($(VER),)
+	@echo "Usage: make dist VER=3.7.0"; false
+endif
+	$(MAKE) dist.gz dist.bz2 dist.xz
+
 cscope:
 	cscope -b -q -R -Iinclude -sip -slib -smisc -snetem -stc
 
-- 
1.8.0
