From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] netem: fix installs of dist files
Date: Wed,  9 Jun 2010 20:52:09 -0400
Message-ID: <1276131129-18079-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:55528 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755785Ab0FJAwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 20:52:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tc program searches LIBDIR by default for the .dist files, and that
defaults to /usr/lib.  But the netem subdir has /lib/ hardcoded which
means the default build+install results in the files not being found.

Further, these are plain text files which are read at runtime, so it
doesn't make sense to give them executable bits.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 netem/Makefile |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/netem/Makefile b/netem/Makefile
index b6ccfc6..e52e125 100644
--- a/netem/Makefile
+++ b/netem/Makefile
@@ -20,9 +20,9 @@ stats: stats.c
 	$(HOSTCC) $(CCOPTS) -I../include -o $@ $@.c -lm
 
 install: all
-	mkdir -p $(DESTDIR)/lib/tc
+	mkdir -p $(DESTDIR)$(LIBDIR)/tc
 	for i in $(DISTDATA); \
-	do install -m 755 $$i $(DESTDIR)/lib/tc; \
+	do install -m 644 $$i $(DESTDIR)$(LIBDIR)/tc; \
 	done
 
 clean:
-- 
1.7.1

