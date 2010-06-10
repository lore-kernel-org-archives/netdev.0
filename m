From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] tc: revert "echo" in install target
Date: Wed,  9 Jun 2010 20:52:03 -0400
Message-ID: <1276131123-18040-1-git-send-email-vapier@gentoo.org>
Cc: Andreas Henriksson <andreas@fatal.se>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:55521 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753213Ab0FJAwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 20:52:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent commit "iproute2: add option to build m_xt as a tc module"
(ab814d635529787) looks like it wrongly included debug changes in the
install target.  So drop the `echo` so the tc binary actually gets
installed again.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tc/Makefile |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tc/Makefile b/tc/Makefile
index 01a16fc..3aa9f26 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -99,10 +99,10 @@ libtc.a: $(TCLIB)
 	$(AR) rcs $@ $(TCLIB)
 
 install: all
-	echo mkdir -p $(MODDESTDIR)
-	echo install -m 0755 tc $(DESTDIR)$(SBINDIR)
+	mkdir -p $(MODDESTDIR)
+	install -m 0755 tc $(DESTDIR)$(SBINDIR)
 	for i in $(TCSO); \
-	do echo install -m 755 $$i $(MODDESTDIR); \
+	do install -m 755 $$i $(MODDESTDIR); \
 	done
 	if [ ! -f $(MODDESTDIR)/m_ipt.so ]; then \
 	if [ -f $(MODDESTDIR)/m_xt.so ]; \
-- 
1.7.1

