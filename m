From: varkabhadram@gmail.com
Subject: [PATCH net-next] net: cpmac: fix in debug messages
Date: Thu, 10 Jul 2014 15:29:38 +0530
Message-ID: <1404986378-28555-1-git-send-email-varkabhadram@gmail.com>
Cc: mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:38443 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbaGJKBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 06:01:03 -0400
Received: by mail-pa0-f44.google.com with SMTP id rd3so10846042pab.17
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 03:01:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch fix the debug message format. This patch changes to the
commit f160a2d0b524eeebd97a68e2fbb59fad4cdd3fee: net: cpmac: dynamic debug fixes

When we use pr_debug()/netdev_dbg() new lines are inserting in b/w
the values. The format when i use the printk()

These formats used in skb dump and reg dump. This functions
called from the entire code. So this will be enabled all the lines.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/ti/cpmac.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index b68c5b5..3809f4e 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -228,22 +228,22 @@ static void cpmac_dump_regs(struct net_device *dev)
 	for (i = 0; i < CPMAC_REG_END; i += 4) {
 		if (i % 16 == 0) {
 			if (i)
-				pr_cont("\n");
-			netdev_dbg(dev, "reg[%p]:", priv->regs + i);
+				printk("\n");
+			printk("%s: reg[%p]:", dev->name, priv->regs + i);
 		}
-		pr_debug(" %08x", cpmac_read(priv->regs, i));
+		printk(" %08x", cpmac_read(priv->regs, i));
 	}
-	pr_debug("\n");
+	printk("\n");
 }
 
 static void cpmac_dump_desc(struct net_device *dev, struct cpmac_desc *desc)
 {
 	int i;
 
-	netdev_dbg(dev, "desc[%p]:", desc);
+	printk("%s: desc[%p]:", dev->name, desc);
 	for (i = 0; i < sizeof(*desc) / 4; i++)
-		pr_debug(" %08x", ((u32 *)desc)[i]);
-	pr_debug("\n");
+		printk(" %08x", ((u32 *)desc)[i]);
+	printk("\n");
 }
 
 static void cpmac_dump_all_desc(struct net_device *dev)
@@ -261,16 +261,16 @@ static void cpmac_dump_skb(struct net_device *dev, struct sk_buff *skb)
 {
 	int i;
 
-	netdev_dbg(dev, "skb 0x%p, len=%d\n", skb, skb->len);
+	printk("%s: skb 0x%p, len=%d\n", dev->name, skb, skb->len);
 	for (i = 0; i < skb->len; i++) {
 		if (i % 16 == 0) {
 			if (i)
-				pr_cont("\n");
-			netdev_dbg(dev, "data[%p]:", skb->data + i);
+				printk("\n");
+			printk("%s: data[%p]:", dev->name, skb->data + i);
 		}
-		pr_debug(" %02x", ((u8 *)skb->data)[i]);
+		printk(" %02x", ((u8 *)skb->data)[i]);
 	}
-	pr_debug("\n");
+	printk("\n");
 }
 
 static int cpmac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
-- 
1.7.9.5
