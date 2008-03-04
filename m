From: akpm@linux-foundation.org
Subject: [patch 09/17] drivers/net/apne.c: replace init_module&cleanup_module with module_init&module_exit
Date: Tue, 04 Mar 2008 15:19:27 -0800
Message-ID: <200803042319.m24NJSEt002708@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51891 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934874AbYCDXTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replaced init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/apne.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN drivers/net/apne.c~drivers-net-apnec-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/apne.c
--- a/drivers/net/apne.c~drivers-net-apnec-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/apne.c
@@ -569,7 +569,7 @@ static irqreturn_t apne_interrupt(int ir
 #ifdef MODULE
 static struct net_device *apne_dev;
 
-int __init init_module(void)
+static int __init apne_module_init(void)
 {
 	apne_dev = apne_probe(-1);
 	if (IS_ERR(apne_dev))
@@ -577,7 +577,7 @@ int __init init_module(void)
 	return 0;
 }
 
-void __exit cleanup_module(void)
+static void __exit apne_module_exit(void)
 {
 	unregister_netdev(apne_dev);
 
@@ -591,7 +591,8 @@ void __exit cleanup_module(void)
 
 	free_netdev(apne_dev);
 }
-
+module_init(apne_module_init);
+module_exit(apne_module_exit);
 #endif
 
 static int init_pcmcia(void)
_
