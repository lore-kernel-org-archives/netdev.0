From: akpm@linux-foundation.org
Subject: [patch 1/8] net: fix compilation NG when !CONFIG_MODULE
Date: Mon, 22 Sep 2008 14:50:35 -0700
Message-ID: <200809222150.m8MLoZdf031857@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	h-shimamoto@ct.jp.nec.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36871 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753387AbYIVVvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:51:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

  CC      net/core/dev.o
net/core/dev.c:1001: error: redefinition of 'dev_load'
include/linux/netdevice.h:1645: error: previous definition of 'dev_load' was here
make[2]: *** [net/core/dev.o] Error 1

dev_load() is not used when CONFIG_MODULE disabled.

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/core/dev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN net/core/dev.c~net-fix-compilation-ng-when-config_module net/core/dev.c
--- a/net/core/dev.c~net-fix-compilation-ng-when-config_module
+++ a/net/core/dev.c
@@ -997,7 +997,7 @@ EXPORT_SYMBOL(netdev_bonding_change);
  *	privileges this function loads the module. If module loading is not
  *	available in this kernel then it becomes a nop.
  */
-
+#ifdef CONFIG_MODULES
 void dev_load(struct net *net, const char *name)
 {
 	struct net_device *dev;
@@ -1009,6 +1009,7 @@ void dev_load(struct net *net, const cha
 	if (!dev && capable(CAP_SYS_MODULE))
 		request_module("%s", name);
 }
+#endif
 
 /**
  *	dev_open	- prepare an interface for use.
_
