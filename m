From: akpm@linux-foundation.org
Subject: [patch 04/21] drivers/net/3c507.c: replace init_module&cleanup_module with module_init&module_exit
Date: Fri, 28 Mar 2008 14:41:17 -0700
Message-ID: <200803282141.m2SLfHuA011810@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43702 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756697AbYC1Vlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:41:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replace init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c507.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff -puN drivers/net/3c507.c~drivers-net-3c507c-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/3c507.c
--- a/drivers/net/3c507.c~drivers-net-3c507c-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/3c507.c
@@ -918,16 +918,16 @@ module_param(irq, int, 0);
 MODULE_PARM_DESC(io, "EtherLink16 I/O base address");
 MODULE_PARM_DESC(irq, "(ignored)");
 
-int __init init_module(void)
+static int __init tc507_module_init(void)
 {
 	if (io == 0)
 		printk("3c507: You should not use auto-probing with insmod!\n");
 	dev_3c507 = el16_probe(-1);
 	return IS_ERR(dev_3c507) ? PTR_ERR(dev_3c507) : 0;
 }
+module_init(tc507_module_init);
 
-void __exit
-cleanup_module(void)
+static void __exit tc507_module_exit(void)
 {
 	struct net_device *dev = dev_3c507;
 	unregister_netdev(dev);
@@ -936,6 +936,8 @@ cleanup_module(void)
 	release_region(dev->base_addr, EL16_IO_EXTENT);
 	free_netdev(dev);
 }
+module_exit(tc507_module_exit);
+
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
 
_
