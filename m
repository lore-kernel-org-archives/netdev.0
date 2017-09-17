From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [PATCH net-next v2 5/7] net: korina: whitespace cleanup
Date: Sun, 17 Sep 2017 20:25:02 +0300
Message-ID: <20170917172502.32531-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36444 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751686AbdIQRZD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2017 13:25:03 -0400
Received: by mail-lf0-f67.google.com with SMTP id l196so3439829lfl.3
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 10:25:02 -0700 (PDT)
Received: from ubrain.corp.ubnt.com ([2a02:16d8:105:4000:76d4:35ff:fe88:7631])
        by smtp.googlemail.com with ESMTPSA id r2sm1410517lja.32.2017.09.17.10.25.00
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 10:25:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 58 +++++++++++++++++++++++--------------------
 1 file changed, 31 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 5f36e1703378..c26f0d84ba6b 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -64,9 +64,9 @@
 #include <asm/mach-rc32434/eth.h>
 #include <asm/mach-rc32434/dma_v.h>
 
-#define DRV_NAME        "korina"
-#define DRV_VERSION     "0.10"
-#define DRV_RELDATE     "04Mar2008"
+#define DRV_NAME	"korina"
+#define DRV_VERSION	"0.10"
+#define DRV_RELDATE	"04Mar2008"
 
 #define STATION_ADDRESS_HIGH(dev) (((dev)->dev_addr[0] << 8) | \
 				   ((dev)->dev_addr[1]))
@@ -75,7 +75,7 @@
 				   ((dev)->dev_addr[4] << 8)  | \
 				   ((dev)->dev_addr[5]))
 
-#define MII_CLOCK 1250000 	/* no more than 2.5MHz */
+#define MII_CLOCK	1250000 /* no more than 2.5MHz */
 
 /* the following must be powers of two */
 #define KORINA_NUM_RDS	64  /* number of receive descriptors */
@@ -87,15 +87,19 @@
 #define KORINA_RBSIZE	1536 /* size of one resource buffer = Ether MTU */
 #define KORINA_RDS_MASK	(KORINA_NUM_RDS - 1)
 #define KORINA_TDS_MASK	(KORINA_NUM_TDS - 1)
-#define RD_RING_SIZE 	(KORINA_NUM_RDS * sizeof(struct dma_desc))
+#define RD_RING_SIZE	(KORINA_NUM_RDS * sizeof(struct dma_desc))
 #define TD_RING_SIZE	(KORINA_NUM_TDS * sizeof(struct dma_desc))
 
-#define TX_TIMEOUT 	(6000 * HZ / 1000)
+#define TX_TIMEOUT	(6000 * HZ / 1000)
 
-enum chain_status { desc_filled, desc_empty };
-#define IS_DMA_FINISHED(X)   (((X) & (DMA_DESC_FINI)) != 0)
-#define IS_DMA_DONE(X)   (((X) & (DMA_DESC_DONE)) != 0)
-#define RCVPKT_LENGTH(X)     (((X) & ETH_RX_LEN) >> ETH_RX_LEN_BIT)
+enum chain_status {
+	desc_filled,
+	desc_empty
+};
+
+#define IS_DMA_FINISHED(X)	(((X) & (DMA_DESC_FINI)) != 0)
+#define IS_DMA_DONE(X)		(((X) & (DMA_DESC_DONE)) != 0)
+#define RCVPKT_LENGTH(X)	(((X) & ETH_RX_LEN) >> ETH_RX_LEN_BIT)
 
 /* Information that need to be kept for each board. */
 struct korina_private {
@@ -123,7 +127,7 @@ struct korina_private {
 	int rx_irq;
 	int tx_irq;
 
-	spinlock_t lock;        /* NIC xmit lock */
+	spinlock_t lock;	/* NIC xmit lock */
 
 	int dma_halt_cnt;
 	int dma_run_cnt;
@@ -146,17 +150,17 @@ static inline void korina_start_dma(struct dma_reg *ch, u32 dma_addr)
 static inline void korina_abort_dma(struct net_device *dev,
 					struct dma_reg *ch)
 {
-       if (readl(&ch->dmac) & DMA_CHAN_RUN_BIT) {
-	       writel(0x10, &ch->dmac);
+	if (readl(&ch->dmac) & DMA_CHAN_RUN_BIT) {
+		writel(0x10, &ch->dmac);
 
-	       while (!(readl(&ch->dmas) & DMA_STAT_HALT))
-		       netif_trans_update(dev);
+		while (!(readl(&ch->dmas) & DMA_STAT_HALT))
+			netif_trans_update(dev);
 
-	       writel(0, &ch->dmas);
-       }
+		writel(0, &ch->dmas);
+	}
 
-       writel(0, &ch->dmadptr);
-       writel(0, &ch->dmandptr);
+	writel(0, &ch->dmadptr);
+	writel(0, &ch->dmandptr);
 }
 
 static inline void korina_chain_dma(struct dma_reg *ch, u32 dma_addr)
@@ -685,7 +689,7 @@ static int korina_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 /* ethtool helpers */
 static void netdev_get_drvinfo(struct net_device *dev,
-			struct ethtool_drvinfo *info)
+				struct ethtool_drvinfo *info)
 {
 	struct korina_private *lp = netdev_priv(dev);
 
@@ -728,10 +732,10 @@ static u32 netdev_get_link(struct net_device *dev)
 }
 
 static const struct ethtool_ops netdev_ethtool_ops = {
-	.get_drvinfo            = netdev_get_drvinfo,
-	.get_link               = netdev_get_link,
-	.get_link_ksettings     = netdev_get_link_ksettings,
-	.set_link_ksettings     = netdev_set_link_ksettings,
+	.get_drvinfo		= netdev_get_drvinfo,
+	.get_link		= netdev_get_link,
+	.get_link_ksettings	= netdev_get_link_ksettings,
+	.set_link_ksettings	= netdev_set_link_ksettings,
 };
 
 static int korina_alloc_ring(struct net_device *dev)
@@ -863,7 +867,7 @@ static int korina_init(struct net_device *dev)
 	/* Management Clock Prescaler Divisor
 	 * Clock independent setting */
 	writel(((idt_cpu_freq) / MII_CLOCK + 1) & ~1,
-		       &lp->eth_regs->ethmcp);
+			&lp->eth_regs->ethmcp);
 
 	/* don't transmit until fifo contains 48b */
 	writel(48, &lp->eth_regs->ethfifott);
@@ -946,14 +950,14 @@ static int korina_open(struct net_device *dev)
 			0, "Korina ethernet Rx", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get Rx DMA IRQ %d\n",
-		    dev->name, lp->rx_irq);
+			dev->name, lp->rx_irq);
 		goto err_release;
 	}
 	ret = request_irq(lp->tx_irq, korina_tx_dma_interrupt,
 			0, "Korina ethernet Tx", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get Tx DMA IRQ %d\n",
-		    dev->name, lp->tx_irq);
+			dev->name, lp->tx_irq);
 		goto err_free_rx_irq;
 	}
 
-- 
2.11.0
