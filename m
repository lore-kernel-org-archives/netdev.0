From: akpm@linux-foundation.org
Subject: [patch 03/21] drivers/net/3c505.c: replace init_module&cleanup_module with module_init&module_exit
Date: Fri, 28 Mar 2008 14:41:16 -0700
Message-ID: <200803282141.m2SLfGFc011807@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jkschind@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60104 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754890AbYC1VlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:41:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Schindler <jkschind@gmail.com>

Replace init_module and cleanup_module with static functions and
module_init/module_exit.

Signed-off-by: Jon Schindler <jkschind@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c505.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/3c505.c~drivers-net-3c505c-replace-init_modulecleanup_module-with-module_initmodule_exit drivers/net/3c505.c
--- a/drivers/net/3c505.c~drivers-net-3c505c-replace-init_modulecleanup_module-with-module_initmodule_exit
+++ a/drivers/net/3c505.c
@@ -1615,7 +1615,7 @@ MODULE_PARM_DESC(io, "EtherLink Plus I/O
 MODULE_PARM_DESC(irq, "EtherLink Plus IRQ number(s) (assigned)");
 MODULE_PARM_DESC(dma, "EtherLink Plus DMA channel(s)");
 
-int __init init_module(void)
+static int __init tc505_module_init(void)
 {
 	int this_dev, found = 0;
 
@@ -1651,8 +1651,9 @@ int __init init_module(void)
 		return -ENODEV;
 	return 0;
 }
+module_init(tc505_module_init);
 
-void __exit cleanup_module(void)
+static void __exit tc505_module_exit(void)
 {
 	int this_dev;
 
@@ -1665,6 +1666,7 @@ void __exit cleanup_module(void)
 		}
 	}
 }
+module_exit(tc505_module_exit);
 
 #endif				/* MODULE */
 MODULE_LICENSE("GPL");
_
