From: akpm@linux-foundation.org
Subject: [patch 17/17] drivers/net/ac3200.c: replace init_module&cleanup_module with module_init&module_exit
Date: Tue, 04 Mar 2008 15:19:33 -0800
Message-ID: <200803042319.m24NJXAv002741@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48872 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935080AbYCDXTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replace init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ac3200.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -puN drivers/net/ac3200.c~drivers-net-ac3200c-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/ac3200.c
--- a/drivers/net/ac3200.c~drivers-net-ac3200c-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/ac3200.c
@@ -369,7 +369,7 @@ MODULE_PARM_DESC(mem, "Memory base addre
 MODULE_DESCRIPTION("Ansel AC3200 EISA ethernet driver");
 MODULE_LICENSE("GPL");
 
-int __init init_module(void)
+static int __init ac3200_module_init(void)
 {
 	struct net_device *dev;
 	int this_dev, found = 0;
@@ -404,8 +404,7 @@ static void cleanup_card(struct net_devi
 	iounmap(ei_status.mem);
 }
 
-void __exit
-cleanup_module(void)
+static void __exit ac3200_module_exit(void)
 {
 	int this_dev;
 
@@ -418,4 +417,6 @@ cleanup_module(void)
 		}
 	}
 }
+module_init(ac3200_module_init);
+module_exit(ac3200_module_exit);
 #endif /* MODULE */
_
