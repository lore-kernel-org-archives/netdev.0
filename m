From: akpm@linux-foundation.org
Subject: [patch 08/21] drivers/net/82596.c: replace init_module&cleanup_module with module_init&module_exit
Date: Fri, 28 Mar 2008 14:41:19 -0700
Message-ID: <200803282141.m2SLfJnq011822@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51483 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756174AbYC1VlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:41:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replace init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/82596.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN drivers/net/82596.c~drivers-net-82596c-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/82596.c
--- a/drivers/net/82596.c~drivers-net-82596c-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/82596.c
@@ -1567,7 +1567,7 @@ static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "i82596 debug mask");
 
-int __init init_module(void)
+static int __init i82596_module_init(void)
 {
 	if (debug >= 0)
 		i596_debug = debug;
@@ -1576,8 +1576,9 @@ int __init init_module(void)
 		return PTR_ERR(dev_82596);
 	return 0;
 }
+module_init(i82596_module_init);
 
-void __exit cleanup_module(void)
+static void __exit i82596_module_exit(void)
 {
 	unregister_netdev(dev_82596);
 #ifdef __mc68000__
@@ -1595,7 +1596,7 @@ void __exit cleanup_module(void)
 #endif
 	free_netdev(dev_82596);
 }
-
+module_exit(i82596_module_exit);
 #endif				/* MODULE */
 
 /*
_
