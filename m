From: akpm@linux-foundation.org
Subject: [patch 02/21] drivers/net/3c501.c: replace init_module&cleanup_module with module_init&module_exit
Date: Fri, 28 Mar 2008 14:41:16 -0700
Message-ID: <200803282141.m2SLfGGa011804@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49997 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751112AbYC1VlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:41:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replace init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c501.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/3c501.c~drivers-net-3c501c-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/3c501.c
--- a/drivers/net/3c501.c~drivers-net-3c501c-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/3c501.c
@@ -869,13 +869,14 @@ MODULE_PARM_DESC(irq, "EtherLink IRQ num
  * here also causes the module to be unloaded
  */
 
-int __init init_module(void)
+static int __init tc501_module_init(void)
 {
 	dev_3c501 = el1_probe(-1);
 	if (IS_ERR(dev_3c501))
 		return PTR_ERR(dev_3c501);
 	return 0;
 }
+module_init(tc501_module_init);
 
 /**
  * cleanup_module:
@@ -884,13 +885,14 @@ int __init init_module(void)
  * and then free up the resources we took when the card was found.
  */
 
-void __exit cleanup_module(void)
+static void __exit tc501_module_exit(void)
 {
 	struct net_device *dev = dev_3c501;
 	unregister_netdev(dev);
 	release_region(dev->base_addr, EL1_IO_EXTENT);
 	free_netdev(dev);
 }
+module_exit(tc501_module_exit);
 
 #endif /* MODULE */
 
_
