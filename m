From: akpm@linux-foundation.org
Subject: [patch 14/17] drivers/net/at1700.c: replace init_module&cleanup_module with module_init&module_exit
Date: Tue, 04 Mar 2008 15:19:31 -0800
Message-ID: <200803042319.m24NJV8o002727@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46670 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935069AbYCDXTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replaced init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/at1700.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN drivers/net/at1700.c~drivers-net-at1700c-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/at1700.c
--- a/drivers/net/at1700.c~drivers-net-at1700c-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/at1700.c
@@ -881,7 +881,7 @@ MODULE_PARM_DESC(io, "AT1700/FMV18X I/O 
 MODULE_PARM_DESC(irq, "AT1700/FMV18X IRQ number");
 MODULE_PARM_DESC(net_debug, "AT1700/FMV18X debug level (0-6)");
 
-int __init init_module(void)
+static int __init at1700_module_init(void)
 {
 	if (io == 0)
 		printk("at1700: You should not use auto-probing with insmod!\n");
@@ -891,13 +891,14 @@ int __init init_module(void)
 	return 0;
 }
 
-void __exit
-cleanup_module(void)
+static void __exit at1700_module_exit(void)
 {
 	unregister_netdev(dev_at1700);
 	cleanup_card(dev_at1700);
 	free_netdev(dev_at1700);
 }
+module_init(at1700_module_init);
+module_exit(at1700_module_exit);
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
 
_
