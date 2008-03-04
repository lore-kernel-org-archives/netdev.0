From: akpm@linux-foundation.org
Subject: [patch 16/17] drivers/net/8390.c: replace init_module&cleanup_module with module_init&module_exit
Date: Tue, 04 Mar 2008 15:19:32 -0800
Message-ID: <200803042319.m24NJXjS002733@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com, alan@lxorguk.ukuu.org.uk
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35458 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934933AbYCDXTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replace init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/8390.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/8390.c~drivers-net-8390c-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/8390.c
--- a/drivers/net/8390.c~drivers-net-8390c-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/8390.c
@@ -48,14 +48,16 @@ EXPORT_SYMBOL(__alloc_ei_netdev);
 
 #if defined(MODULE)
 
-int init_module(void)
+static int __init ns8390_module_init(void)
 {
 	return 0;
 }
 
-void cleanup_module(void)
+static void __exit ns8390_module_exit(void)
 {
 }
 
+module_init(ns8390_module_init);
+module_exit(ns8390_module_exit);
 #endif /* MODULE */
 MODULE_LICENSE("GPL");
_
