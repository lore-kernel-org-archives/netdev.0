From: akpm@linux-foundation.org
Subject: [patch 12/17] drivers/net/arcnet/capmode.c: replace init_module&cleanup_module with module_init&module_exit
Date: Tue, 04 Mar 2008 15:19:29 -0800
Message-ID: <200803042319.m24NJUqw002721@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36495 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935079AbYCDXTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replaced init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/arcnet/capmode.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/arcnet/capmode.c~drivers-net-arcnet-capmodec-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/arcnet/capmode.c
--- a/drivers/net/arcnet/capmode.c~drivers-net-arcnet-capmodec-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/arcnet/capmode.c
@@ -80,17 +80,19 @@ void arcnet_cap_init(void)
 
 #ifdef MODULE
 
-int __init init_module(void)
+static int __init capmode_module_init(void)
 {
 	printk(VERSION);
 	arcnet_cap_init();
 	return 0;
 }
 
-void cleanup_module(void)
+static void __exit capmode_module_exit(void)
 {
 	arcnet_unregister_proto(&capmode_proto);
 }
+module_init(capmode_module_init);
+module_exit(capmode_module_exit);
 
 MODULE_LICENSE("GPL");
 #endif				/* MODULE */
_
