From: akpm@linux-foundation.org
Subject: [patch 15/17] drivers/net/atarilance.c: replace init_module&cleanup_module with module_init&module_exit
Date: Tue, 04 Mar 2008 15:19:31 -0800
Message-ID: <200803042319.m24NJWEk002730@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53500 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935029AbYCDXTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replaced init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/atarilance.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN drivers/net/atarilance.c~drivers-net-atarilancec-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/atarilance.c
--- a/drivers/net/atarilance.c~drivers-net-atarilancec-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/atarilance.c
@@ -1156,7 +1156,7 @@ static int lance_set_mac_address( struct
 #ifdef MODULE
 static struct net_device *atarilance_dev;
 
-int __init init_module(void)
+static int __init atarilance_module_init(void)
 {
 	atarilance_dev = atarilance_probe(-1);
 	if (IS_ERR(atarilance_dev))
@@ -1164,13 +1164,14 @@ int __init init_module(void)
 	return 0;
 }
 
-void __exit cleanup_module(void)
+static void __exit atarilance_module_exit(void)
 {
 	unregister_netdev(atarilance_dev);
 	free_irq(atarilance_dev->irq, atarilance_dev);
 	free_netdev(atarilance_dev);
 }
-
+module_init(atarilance_module_init);
+module_exit(atarilance_module_exit);
 #endif /* MODULE */
 
 
_
