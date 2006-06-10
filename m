From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] hp ethernet: fix section mismatches
Date: Sat, 10 Jun 2006 13:32:12 -0700
Message-ID: <20060610133212.6d0e5ecb.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm <akpm@osdl.org>, jgarzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:34197 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751698AbWFJUdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2006 16:33:13 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Sat, 10 Jun 2006 13:33:10 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Priority: not critical; makes init code discardable.

Fix section mismatch warnings:
WARNING: drivers/net/hp-plus.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x387) and 'cleanup_card'
WARNING: drivers/net/hp.o - Section mismatch: reference to .init.data: from .text between 'hp_init_card' (at offset 0x310) and 'init_module'
WARNING: drivers/net/hp.o - Section mismatch: reference to .init.text: from .text between 'init_module' (at offset 0x367) and 'cleanup_card'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/net/hp-plus.c |    2 +-
 drivers/net/hp.c      |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

--- linux-2617-rc6.orig/drivers/net/hp-plus.c
+++ linux-2617-rc6/drivers/net/hp-plus.c
@@ -446,7 +446,7 @@ MODULE_LICENSE("GPL");
 
 /* This is set up so that only a single autoprobe takes place per call.
 ISA device autoprobes on a running machine are not recommended. */
-int
+int __init
 init_module(void)
 {
 	struct net_device *dev;
--- linux-2617-rc6.orig/drivers/net/hp.c
+++ linux-2617-rc6/drivers/net/hp.c
@@ -384,7 +384,7 @@ hp_block_output(struct net_device *dev, 
 }
 
 /* This function resets the ethercard if something screws up. */
-static void
+static void __init
 hp_init_card(struct net_device *dev)
 {
 	int irq = dev->irq;
@@ -409,7 +409,7 @@ MODULE_LICENSE("GPL");
 
 /* This is set up so that only a single autoprobe takes place per call.
 ISA device autoprobes on a running machine are not recommended. */
-int
+int __init
 init_module(void)
 {
 	struct net_device *dev;


---
