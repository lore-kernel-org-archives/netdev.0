From: akpm@linux-foundation.org
Subject: [patch 07/21] drivers/net/3c527.c: replace init_module&cleanup_module with module_init&module_exit
Date: Fri, 28 Mar 2008 14:41:18 -0700
Message-ID: <200803282141.m2SLfJb9011819@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35885 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756094AbYC1Vlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replace init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c527.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff -puN drivers/net/3c527.c~drivers-net-3c527c-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/3c527.c
--- a/drivers/net/3c527.c~drivers-net-3c527c-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/3c527.c
@@ -1631,23 +1631,24 @@ static const struct ethtool_ops netdev_e
 static struct net_device *this_device;
 
 /**
- *	init_module		-	entry point
+ *	tc527_module_init	-	entry point
  *
  *	Probe and locate a 3c527 card. This really should probe and locate
  *	all the 3c527 cards in the machine not just one of them. Yes you can
  *	insmod multiple modules for now but it's a hack.
  */
 
-int __init init_module(void)
+static int __init tc527_module_init(void)
 {
 	this_device = mc32_probe(-1);
 	if (IS_ERR(this_device))
 		return PTR_ERR(this_device);
 	return 0;
 }
+module_init(tc527_module_init);
 
 /**
- *	cleanup_module	-	free resources for an unload
+ *	tc527_module_exit	-	free resources for an unload
  *
  *	Unloading time. We release the MCA bus resources and the interrupt
  *	at which point everything is ready to unload. The card must be stopped
@@ -1657,11 +1658,12 @@ int __init init_module(void)
  *	transmit operations are allowed to start scribbling into memory.
  */
 
-void __exit cleanup_module(void)
+static void __exit tc527_module_exit(void)
 {
 	unregister_netdev(this_device);
 	cleanup_card(this_device);
 	free_netdev(this_device);
 }
+module_exit(tc527_module_exit);
 
 #endif /* MODULE */
_
