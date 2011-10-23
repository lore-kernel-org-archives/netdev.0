From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 1/5] m68k/net: Remove obsolete IRQ_FLG_* users
Date: Sun, 23 Oct 2011 23:18:02 +0200
Message-ID: <1319404686-10800-1-git-send-email-geert@linux-m68k.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The m68k core irq code stopped honoring these flags during the irq
restructuring in 2006.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
This is a split-up of "m68k/irq: Remove obsolete IRQ_FLG_* definitions and
users", to reduce conflicts and dependencies.

diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index c93679e..aae4cfc 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -142,8 +142,7 @@ static int macsonic_open(struct net_device* dev)
 {
 	int retval;
 
-	retval = request_irq(dev->irq, sonic_interrupt, IRQ_FLG_FAST,
-				"sonic", dev);
+	retval = request_irq(dev->irq, sonic_interrupt, 0, "sonic", dev);
 	if (retval) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
 				dev->name, dev->irq);
@@ -154,8 +153,8 @@ static int macsonic_open(struct net_device* dev)
 	 * rupt as well, which must prevent re-entrance of the sonic handler.
 	 */
 	if (dev->irq == IRQ_AUTO_3) {
-		retval = request_irq(IRQ_NUBUS_9, macsonic_interrupt,
-					IRQ_FLG_FAST, "sonic", dev);
+		retval = request_irq(IRQ_NUBUS_9, macsonic_interrupt, 0,
+				     "sonic", dev);
 		if (retval) {
 			printk(KERN_ERR "%s: unable to get IRQ %d.\n",
 					dev->name, IRQ_NUBUS_9);
