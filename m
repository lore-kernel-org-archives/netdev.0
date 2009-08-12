From: Phil Sutter <n0-1@freewrt.org>
Subject: [PATCH 1/2] korina: fix printk formatting, add final info line
Date: Thu, 13 Aug 2009 00:22:46 +0200
Message-ID: <20090812222249.39EAB4CEAA@orbit.nwl.cc>
References: <20090812221509.725F74CEAA@orbit.nwl.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, florian@openwrt.org,
	Roel Kluin <roel.kluin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:43185 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751896AbZHLWWs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 18:22:48 -0400
In-Reply-To: <20090812221509.725F74CEAA@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro DRV_NAME contains "korina", the field dev->name points to the
actual interface name. So messages were formerly prefixed with
'korinaeth2:' (on my system).

Signed-off-by: Phil Sutter <n0-1@freewrt.org>
---
 drivers/net/korina.c |   32 +++++++++++++++++---------------
 1 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index b4cf602..6df9d25 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -338,7 +338,7 @@ static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)
 		napi_schedule(&lp->napi);
 
 		if (dmas & DMA_STAT_ERR)
-			printk(KERN_ERR DRV_NAME "%s: DMA error\n", dev->name);
+			printk(KERN_ERR "%s: DMA error\n", dev->name);
 
 		retval = IRQ_HANDLED;
 	} else
@@ -555,7 +555,7 @@ static void korina_tx(struct net_device *dev)
 			dev->stats.tx_dropped++;
 
 			/* Should never happen */
-			printk(KERN_ERR DRV_NAME "%s: split tx ignored\n",
+			printk(KERN_ERR "%s: split tx ignored\n",
 							dev->name);
 		} else if (devcs & ETH_TX_TOK) {
 			dev->stats.tx_packets++;
@@ -641,7 +641,7 @@ korina_tx_dma_interrupt(int irq, void *dev_id)
 			dev->trans_start = jiffies;
 		}
 		if (dmas & DMA_STAT_ERR)
-			printk(KERN_ERR DRV_NAME "%s: DMA error\n", dev->name);
+			printk(KERN_ERR "%s: DMA error\n", dev->name);
 
 		retval = IRQ_HANDLED;
 	} else
@@ -917,8 +917,7 @@ static int korina_restart(struct net_device *dev)
 
 	ret = korina_init(dev);
 	if (ret < 0) {
-		printk(KERN_ERR DRV_NAME "%s: cannot restart device\n",
-								dev->name);
+		printk(KERN_ERR "%s: cannot restart device\n", dev->name);
 		return ret;
 	}
 	korina_multicast_list(dev);
@@ -1005,7 +1004,7 @@ static int korina_open(struct net_device *dev)
 	/* Initialize */
 	ret = korina_init(dev);
 	if (ret < 0) {
-		printk(KERN_ERR DRV_NAME "%s: cannot open device\n", dev->name);
+		printk(KERN_ERR "%s: cannot open device\n", dev->name);
 		goto out;
 	}
 
@@ -1015,14 +1014,14 @@ static int korina_open(struct net_device *dev)
 	ret = request_irq(lp->rx_irq, &korina_rx_dma_interrupt,
 			IRQF_DISABLED, "Korina ethernet Rx", dev);
 	if (ret < 0) {
-		printk(KERN_ERR DRV_NAME "%s: unable to get Rx DMA IRQ %d\n",
+		printk(KERN_ERR "%s: unable to get Rx DMA IRQ %d\n",
 		    dev->name, lp->rx_irq);
 		goto err_release;
 	}
 	ret = request_irq(lp->tx_irq, &korina_tx_dma_interrupt,
 			IRQF_DISABLED, "Korina ethernet Tx", dev);
 	if (ret < 0) {
-		printk(KERN_ERR DRV_NAME "%s: unable to get Tx DMA IRQ %d\n",
+		printk(KERN_ERR "%s: unable to get Tx DMA IRQ %d\n",
 		    dev->name, lp->tx_irq);
 		goto err_free_rx_irq;
 	}
@@ -1031,7 +1030,7 @@ static int korina_open(struct net_device *dev)
 	ret = request_irq(lp->ovr_irq, &korina_ovr_interrupt,
 			IRQF_DISABLED, "Ethernet Overflow", dev);
 	if (ret < 0) {
-		printk(KERN_ERR DRV_NAME"%s: unable to get OVR IRQ %d\n",
+		printk(KERN_ERR "%s: unable to get OVR IRQ %d\n",
 		    dev->name, lp->ovr_irq);
 		goto err_free_tx_irq;
 	}
@@ -1040,7 +1039,7 @@ static int korina_open(struct net_device *dev)
 	ret = request_irq(lp->und_irq, &korina_und_interrupt,
 			IRQF_DISABLED, "Ethernet Underflow", dev);
 	if (ret < 0) {
-		printk(KERN_ERR DRV_NAME "%s: unable to get UND IRQ %d\n",
+		printk(KERN_ERR "%s: unable to get UND IRQ %d\n",
 		    dev->name, lp->und_irq);
 		goto err_free_ovr_irq;
 	}
@@ -1137,7 +1136,7 @@ static int korina_probe(struct platform_device *pdev)
 	dev->base_addr = r->start;
 	lp->eth_regs = ioremap_nocache(r->start, r->end - r->start);
 	if (!lp->eth_regs) {
-		printk(KERN_ERR DRV_NAME "cannot remap registers\n");
+		printk(KERN_ERR DRV_NAME ": cannot remap registers\n");
 		rc = -ENXIO;
 		goto probe_err_out;
 	}
@@ -1145,7 +1144,7 @@ static int korina_probe(struct platform_device *pdev)
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_dma_rx");
 	lp->rx_dma_regs = ioremap_nocache(r->start, r->end - r->start);
 	if (!lp->rx_dma_regs) {
-		printk(KERN_ERR DRV_NAME "cannot remap Rx DMA registers\n");
+		printk(KERN_ERR DRV_NAME ": cannot remap Rx DMA registers\n");
 		rc = -ENXIO;
 		goto probe_err_dma_rx;
 	}
@@ -1153,14 +1152,14 @@ static int korina_probe(struct platform_device *pdev)
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_dma_tx");
 	lp->tx_dma_regs = ioremap_nocache(r->start, r->end - r->start);
 	if (!lp->tx_dma_regs) {
-		printk(KERN_ERR DRV_NAME "cannot remap Tx DMA registers\n");
+		printk(KERN_ERR DRV_NAME ": cannot remap Tx DMA registers\n");
 		rc = -ENXIO;
 		goto probe_err_dma_tx;
 	}
 
 	lp->td_ring = kmalloc(TD_RING_SIZE + RD_RING_SIZE, GFP_KERNEL);
 	if (!lp->td_ring) {
-		printk(KERN_ERR DRV_NAME "cannot allocate descriptors\n");
+		printk(KERN_ERR DRV_NAME ": cannot allocate descriptors\n");
 		rc = -ENXIO;
 		goto probe_err_td_ring;
 	}
@@ -1193,10 +1192,13 @@ static int korina_probe(struct platform_device *pdev)
 	rc = register_netdev(dev);
 	if (rc < 0) {
 		printk(KERN_ERR DRV_NAME
-			": cannot register net device %d\n", rc);
+			": cannot register net device: %d\n", rc);
 		goto probe_err_register;
 	}
 	setup_timer(&lp->media_check_timer, korina_poll_media, (unsigned long) dev);
+
+	printk(KERN_INFO "%s: " DRV_NAME "-" DRV_VERSION " " DRV_RELDATE "\n",
+			dev->name);
 out:
 	return rc;
 
-- 
1.6.0.6

