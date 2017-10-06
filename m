From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH net v2 2/9] net/mac89x0: Remove dead or unreachable code
Date: Thu,  5 Oct 2017 21:11:05 -0400 (EDT)
Message-ID: <5344064de2d98cbcd38b60ad6c744a28faed00bd.1507211120.git.fthain@telegraphics.com.au>
References: <cover.1507211120.git.fthain@telegraphics.com.au>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1507211120.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
---
 drivers/net/ethernet/cirrus/mac89x0.c | 31 -------------------------------
 1 file changed, 31 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/mac89x0.c b/drivers/net/ethernet/cirrus/mac89x0.c
index f910f0f386d6..4fd72c1a69f5 100644
--- a/drivers/net/ethernet/cirrus/mac89x0.c
+++ b/drivers/net/ethernet/cirrus/mac89x0.c
@@ -119,10 +119,6 @@ struct net_local {
 };
 
 /* Index to functions, as function prototypes. */
-
-#if 0
-extern void reset_chip(struct net_device *dev);
-#endif
 static int net_open(struct net_device *dev);
 static int net_send_packet(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t net_interrupt(int irq, void *dev_id);
@@ -132,10 +128,6 @@ static int net_close(struct net_device *dev);
 static struct net_device_stats *net_get_stats(struct net_device *dev);
 static int set_mac_address(struct net_device *dev, void *addr);
 
-
-/* Example routines you must write ;->. */
-#define tx_done(dev) 1
-
 /* For reading/writing registers ISA-style */
 static inline int
 readreg_io(struct net_device *dev, int portno)
@@ -295,24 +287,6 @@ struct net_device * __init mac89x0_probe(int unit)
 	return ERR_PTR(err);
 }
 
-#if 0
-/* This is useful for something, but I don't know what yet. */
-void __init reset_chip(struct net_device *dev)
-{
-	int reset_start_time;
-
-	writereg(dev, PP_SelfCTL, readreg(dev, PP_SelfCTL) | POWER_ON_RESET);
-
-	/* wait 30 ms */
-	msleep_interruptible(30);
-
-	/* Wait until the chip is reset */
-	reset_start_time = jiffies;
-	while( (readreg(dev, PP_SelfST) & INIT_DONE) == 0 && jiffies - reset_start_time < 2)
-		;
-}
-#endif
-
 /* Open/initialize the board.  This is called (in the current kernel)
    sometime after booting when the 'ifconfig' program is run.
 
@@ -414,11 +388,6 @@ static irqreturn_t net_interrupt(int irq, void *dev_id)
 	struct net_local *lp;
 	int ioaddr, status;
 
-	if (dev == NULL) {
-		printk ("net_interrupt(): irq %d for unknown device.\n", irq);
-		return IRQ_NONE;
-	}
-
 	ioaddr = dev->base_addr;
 	lp = netdev_priv(dev);
 
-- 
2.13.5
