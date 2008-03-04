From: akpm@linux-foundation.org
Subject: [patch 10/17] drivers/net/appletalk/cops.c: replace init_module&cleanup_module with module_init&module_exit
Date: Tue, 04 Mar 2008 15:19:28 -0800
Message-ID: <200803042319.m24NJST6002713@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37082 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934790AbYCDXTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replaced init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/appletalk/cops.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/appletalk/cops.c~drivers-net-appletalk-copsc-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/appletalk/cops.c
--- a/drivers/net/appletalk/cops.c~drivers-net-appletalk-copsc-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/appletalk/cops.c
@@ -1010,7 +1010,7 @@ module_param(io, int, 0);
 module_param(irq, int, 0);
 module_param(board_type, int, 0);
 
-int __init init_module(void)
+static int __init cops_module_init(void)
 {
 	if (io == 0)
 		printk(KERN_WARNING "%s: You shouldn't autoprobe with insmod\n",
@@ -1021,12 +1021,14 @@ int __init init_module(void)
         return 0;
 }
 
-void __exit cleanup_module(void)
+static void __exit cops_module_exit(void)
 {
 	unregister_netdev(cops_dev);
 	cleanup_card(cops_dev);
 	free_netdev(cops_dev);
 }
+module_init(cops_module_init);
+module_exit(cops_module_exit);
 #endif /* MODULE */
 
 /*
_
