From: akpm@osdl.org
Subject: [patch 03/41] 82596 section fixes
Date: Mon, 14 Aug 2006 22:59:57 -0700
Message-ID: <200608150559.k7F5xvqc012580@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15250 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965122AbWHOGAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:00:02 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

WARNING: drivers/net/82596.o - Section mismatch: reference to .init.text:i82596_probe from .text between 'init_module' (at offset 0x141) and 'i596_add_cmd'

Also nail a couple of crazy inlines.

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/82596.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff -puN drivers/net/82596.c~82596-section-fixes drivers/net/82596.c
--- a/drivers/net/82596.c~82596-section-fixes
+++ a/drivers/net/82596.c
@@ -899,7 +899,7 @@ memory_squeeze:
 }
 
 
-static inline void i596_cleanup_cmd(struct net_device *dev, struct i596_private *lp)
+static void i596_cleanup_cmd(struct net_device *dev, struct i596_private *lp)
 {
 	struct i596_cmd *ptr;
 
@@ -932,7 +932,8 @@ static inline void i596_cleanup_cmd(stru
 	lp->scb.cmd = I596_NULL;
 }
 
-static inline void i596_reset(struct net_device *dev, struct i596_private *lp, int ioaddr)
+static void i596_reset(struct net_device *dev, struct i596_private *lp,
+			int ioaddr)
 {
 	unsigned long flags;
 
@@ -1578,7 +1579,7 @@ static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "i82596 debug mask");
 
-int init_module(void)
+int __init init_module(void)
 {
 	if (debug >= 0)
 		i596_debug = debug;
@@ -1588,7 +1589,7 @@ int init_module(void)
 	return 0;
 }
 
-void cleanup_module(void)
+void __exit cleanup_module(void)
 {
 	unregister_netdev(dev_82596);
 #ifdef __mc68000__
_
