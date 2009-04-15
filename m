From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 03/12] fec: do not typedef struct types
Date: Wed, 15 Apr 2009 13:32:16 +0200
Message-ID: <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37909 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755588AbZDOLeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:34:25 -0400
In-Reply-To: <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |   37 ++++++++++++++++++++-----------------
 drivers/net/fec.h |    8 ++++----
 2 files changed, 24 insertions(+), 21 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 3fa3fe4..fea8e27 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -180,10 +180,14 @@ struct fec_enet_private {
 	/* CPM dual port RAM relative addresses.
 	*/
 	dma_addr_t	bd_dma;
-	cbd_t	*rx_bd_base;		/* Address of Rx and Tx buffers. */
-	cbd_t	*tx_bd_base;
-	cbd_t	*cur_rx, *cur_tx;		/* The next free ring entry */
-	cbd_t	*dirty_tx;	/* The ring entries to be free()ed. */
+	/* Address of Rx and Tx buffers. */
+	struct bufdesc	*rx_bd_base;
+	struct bufdesc	*tx_bd_base;
+	/* The next free ring entry */
+	struct bufdesc	*cur_rx, *cur_tx; 
+	/* The ring entries to be free()ed. */
+	struct bufdesc	*dirty_tx;
+
 	uint	tx_full;
 	/* hold while accessing the HW like ringbuffer for tx/rx but not MAC */
 	spinlock_t hw_lock;
@@ -289,7 +293,7 @@ static int
 fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
-	volatile cbd_t	*bdp;
+	struct bufdesc *bdp;
 	unsigned short	status;
 	unsigned long flags;
 
@@ -374,7 +378,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 	}
 
-	fep->cur_tx = (cbd_t *)bdp;
+	fep->cur_tx = bdp;
 
 	spin_unlock_irqrestore(&fep->hw_lock, flags);
 
@@ -391,7 +395,7 @@ fec_timeout(struct net_device *dev)
 #ifndef final_version
 	{
 	int	i;
-	cbd_t	*bdp;
+	struct bufdesc *bdp;
 
 	printk("Ring data dump: cur_tx %lx%s, dirty_tx %lx cur_rx: %lx\n",
 	       (unsigned long)fep->cur_tx, fep->tx_full ? " (full)" : "",
@@ -471,7 +475,7 @@ static void
 fec_enet_tx(struct net_device *dev)
 {
 	struct	fec_enet_private *fep;
-	volatile cbd_t	*bdp;
+	struct bufdesc *bdp;
 	unsigned short status;
 	struct	sk_buff	*skb;
 
@@ -534,7 +538,7 @@ fec_enet_tx(struct net_device *dev)
 				netif_wake_queue(dev);
 		}
 	}
-	fep->dirty_tx = (cbd_t *)bdp;
+	fep->dirty_tx = bdp;
 	spin_unlock_irq(&fep->hw_lock);
 }
 
@@ -548,7 +552,7 @@ static void
 fec_enet_rx(struct net_device *dev)
 {
 	struct	fec_enet_private *fep = netdev_priv(dev);
-	volatile cbd_t *bdp;
+	struct bufdesc *bdp;
 	unsigned short status;
 	struct	sk_buff	*skb;
 	ushort	pkt_len;
@@ -656,7 +660,7 @@ while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) {
 	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
 #endif
    } /* while (!((status = bdp->cbd_sc) & BD_ENET_RX_EMPTY)) */
-	fep->cur_rx = (cbd_t *)bdp;
+	fep->cur_rx = bdp;
 
 #if 0
 	/* Doing this here will allow us to process all frames in the
@@ -1654,8 +1658,7 @@ int __init fec_enet_init(struct net_device *dev, int index)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 	unsigned long	mem_addr;
-	volatile cbd_t	*bdp;
-	cbd_t		*cbd_base;
+	struct bufdesc *bdp, *cbd_base;
 	int 		i, j;
 
 	/* Allocate memory for buffer descriptors.
@@ -1696,7 +1699,7 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	}
 #endif
 
-	cbd_base = (cbd_t *)mem_addr;
+	cbd_base = (struct bufdesc *)mem_addr;
 
 	/* Set receive and transmit descriptor base.
 	*/
@@ -1761,7 +1764,7 @@ int __init fec_enet_init(struct net_device *dev, int index)
 	/* Set receive and transmit descriptor base.
 	*/
 	writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
-	writel((unsigned long)fep->bd_dma + sizeof(cbd_t) * RX_RING_SIZE,
+	writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc) * RX_RING_SIZE,
 			fep->hwp + FEC_X_DES_START);
 
 #ifdef HAVE_mii_link_interrupt
@@ -1825,7 +1828,7 @@ static void
 fec_restart(struct net_device *dev, int duplex)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
-	volatile cbd_t *bdp;
+	struct bufdesc *bdp;
 	int i;
 
 	/* Whack a reset.  We should wait for this. */
@@ -1847,7 +1850,7 @@ fec_restart(struct net_device *dev, int duplex)
 
 	/* Set receive and transmit descriptor base. */
 	writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
-	writel((unsigned long)fep->bd_dma + sizeof(cbd_t) * RX_RING_SIZE,
+	writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc) * RX_RING_SIZE,
 			fep->hwp + FEC_X_DES_START);
 
 	fep->dirty_tx = fep->cur_tx = fep->tx_bd_base;
diff --git a/drivers/net/fec.h b/drivers/net/fec.h
index bb4dabc..9ebebd6 100644
--- a/drivers/net/fec.h
+++ b/drivers/net/fec.h
@@ -46,17 +46,17 @@
  *	Define the buffer descriptor structure.
  */
 #ifdef CONFIG_ARCH_MXC
-typedef struct bufdesc {
+struct bufdesc {
 	unsigned short cbd_datlen;	/* Data length */
 	unsigned short cbd_sc;	/* Control and status info */
 	unsigned long cbd_bufaddr;	/* Buffer address */
-} cbd_t;
+};
 #else
-typedef struct bufdesc {
+struct bufdesc {
 	unsigned short	cbd_sc;			/* Control and status info */
 	unsigned short	cbd_datlen;		/* Data length */
 	unsigned long	cbd_bufaddr;		/* Buffer address */
-} cbd_t;
+};
 #endif
 
 /*
-- 
1.6.2.1

