From: akpm@linux-foundation.org
Subject: [patch 13/17] drivers/net/arcnet/com20020.c: replace init_module&cleanup_module with module_init&module_exit
Date: Tue, 04 Mar 2008 15:19:30 -0800
Message-ID: <200803042319.m24NJUfl002724@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:32907 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934961AbYCDXTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replaced init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/arcnet/com20020.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN drivers/net/arcnet/com20020.c~drivers-net-arcnet-com20020c-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/arcnet/com20020.c
--- a/drivers/net/arcnet/com20020.c~drivers-net-arcnet-com20020c-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/arcnet/com20020.c
@@ -348,14 +348,15 @@ MODULE_LICENSE("GPL");
 
 #ifdef MODULE
 
-int init_module(void)
+static int __init com20020_module_init(void)
 {
 	BUGLVL(D_NORMAL) printk(VERSION);
 	return 0;
 }
 
-void cleanup_module(void)
+static void __exit com20020_module_exit(void)
 {
 }
-
+module_init(com20020_module_init);
+module_exit(com20020_module_exit);
 #endif				/* MODULE */
_
