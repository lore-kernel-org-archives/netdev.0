From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 2/2] [iproute2] do not ignore errors in man subdirs
Date: Fri, 11 Jan 2013 11:56:29 -0500
Message-ID: <1357923389-20114-2-git-send-email-vapier@gentoo.org>
References: <1357923389-20114-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53903 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754375Ab3AKQxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 11:53:43 -0500
In-Reply-To: <1357923389-20114-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an error occurs in a man subdir, make sure we propagate it back up.

While we're here, merge the duplicate rules into one.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 man/Makefile | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/man/Makefile b/man/Makefile
index 9a60fa7..749faa1 100644
--- a/man/Makefile
+++ b/man/Makefile
@@ -4,17 +4,11 @@ INSTALLMAN=install -m 0644
 
 SUBDIRS = man3 man7 man8
 
-all:
-	@for subdir in $(SUBDIRS); do $(MAKE) -C $$subdir; done
+all clean install:
+	@for subdir in $(SUBDIRS); do $(MAKE) -C $$subdir $@ || exit $$?; done
 
 distclean: clean
 
-clean:
-	@for subdir in $(SUBDIRS); do $(MAKE) -C $$subdir clean; done
-
-install:
-	@for subdir in $(SUBDIRS); do $(MAKE) -C $$subdir install; done
-
 .PHONY: install clean distclean
 
 .EXPORT_ALL_VARIABLES:
-- 
1.8.0.2
