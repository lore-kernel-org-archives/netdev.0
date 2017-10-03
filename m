From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH RESEND net 5/9] net/macmace: Fix and cleanup log messages
Date: Mon,  2 Oct 2017 21:07:18 -0400 (EDT)
Message-ID: <d0ae010da06182c5b952ba4433803f873048d0d1.1506992619.git.fthain@telegraphics.com.au>
References: <cover.1506992619.git.fthain@telegraphics.com.au>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1506992619.git.fthain@telegraphics.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Log the MAC address after the interface gets a meaningful name.
Drop redundant debug messages for FIFO events recorded in the
interface statistics (consistent with mace.c).

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>
---
 drivers/net/ethernet/apple/macmace.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index f17a160dbff2..3ff53c3ef732 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -247,13 +247,12 @@ static int mace_probe(struct platform_device *pdev)
 	dev->netdev_ops		= &mace_netdev_ops;
 	dev->watchdog_timeo	= TX_TIMEOUT;
 
-	printk(KERN_INFO "%s: 68K MACE, hardware address %pM\n",
-	       dev->name, dev->dev_addr);
-
 	err = register_netdev(dev);
 	if (!err)
 		return 0;
 
+	netdev_info(dev, "MAC %pM\n", dev->dev_addr);
+
 	free_netdev(dev);
 	return err;
 }
@@ -589,7 +588,6 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 			else if (fs & (UFLO|LCOL|RTRY)) {
 				++dev->stats.tx_aborted_errors;
 				if (mb->xmtfs & UFLO) {
-					printk(KERN_ERR "%s: DMA underrun.\n", dev->name);
 					dev->stats.tx_fifo_errors++;
 					mace_txdma_reset(dev);
 				}
@@ -644,10 +642,8 @@ static void mace_dma_rx_frame(struct net_device *dev, struct mace_frame *mf)
 
 	if (frame_status & (RS_OFLO | RS_CLSN | RS_FRAMERR | RS_FCSERR)) {
 		dev->stats.rx_errors++;
-		if (frame_status & RS_OFLO) {
-			printk(KERN_DEBUG "%s: fifo overflow.\n", dev->name);
+		if (frame_status & RS_OFLO)
 			dev->stats.rx_fifo_errors++;
-		}
 		if (frame_status & RS_CLSN)
 			dev->stats.collisions++;
 		if (frame_status & RS_FRAMERR)
-- 
2.13.5
