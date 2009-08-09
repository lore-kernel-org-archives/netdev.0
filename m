From: Phil Sutter <n0-1@freewrt.org>
Subject: [PATCH 1/3] korina: fix printk formatting, add final info line
Date: Sun,  9 Aug 2009 02:06:26 +0200
Message-ID: <20090809000635.636254CEAA@orbit.nwl.cc>
References: <20090808164512.02C174CEAA@orbit.nwl.cc>
 <1249776388-4626-1-git-send-email-n0-1@freewrt.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, florian@openwrt.org,
	Roel Kluin <roel.kluin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:48611 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753296AbZHIAGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Aug 2009 20:06:35 -0400
In-Reply-To: <1249776388-4626-1-git-send-email-n0-1@freewrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro DRV_NAME contains "korina", the field dev->name points to the
actual interface name. So messages were formerly prefixed with
'korinaeth2:' (on my system).

Signed-off-by: Phil Sutter <n0-1@freewrt.org>
---
 drivers/net/korina.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index a2701f5..c09e2ce 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -337,7 +337,7 @@ static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)
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
@@ -909,8 +909,7 @@ static int korina_restart(struct net_device *dev)
 
 	ret = korina_init(dev);
 	if (ret < 0) {
-		printk(KERN_ERR DRV_NAME "%s: cannot restart device\n",
-								dev->name);
+		printk(KERN_ERR "%s: cannot restart device\n", dev->name);
 		return ret;
 	}
 	korina_multicast_list(dev);
@@ -997,7 +996,7 @@ static int korina_open(struct net_device *dev)
 	/* Initialize */
 	ret = korina_init(dev);
 	if (ret < 0) {
-		printk(KERN_ERR DRV_NAME "%s: cannot open device\n", dev->name);
+		printk(KERN_ERR "%s: cannot open device\n", dev->name);
 		goto out;
 	}
 
@@ -1007,14 +1006,14 @@ static int korina_open(struct net_device *dev)
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
@@ -1023,7 +1022,7 @@ static int korina_open(struct net_device *dev)
 	ret = request_irq(lp->ovr_irq, &korina_ovr_interrupt,
 			IRQF_DISABLED, "Ethernet Overflow", dev);
 	if (ret < 0) {
-		printk(KERN_ERR DRV_NAME"%s: unable to get OVR IRQ %d\n",
+		printk(KERN_ERR "%s: unable to get OVR IRQ %d\n",
 		    dev->name, lp->ovr_irq);
 		goto err_free_tx_irq;
 	}
@@ -1032,7 +1031,7 @@ static int korina_open(struct net_device *dev)
 	ret = request_irq(lp->und_irq, &korina_und_interrupt,
 			IRQF_DISABLED, "Ethernet Underflow", dev);
 	if (ret < 0) {
-		printk(KERN_ERR DRV_NAME "%s: unable to get UND IRQ %d\n",
+		printk(KERN_ERR "%s: unable to get UND IRQ %d\n",
 		    dev->name, lp->und_irq);
 		goto err_free_ovr_irq;
 	}
@@ -1111,7 +1110,7 @@ static int korina_probe(struct platform_device *pdev)
 	dev->base_addr = r->start;
 	lp->eth_regs = ioremap_nocache(r->start, r->end - r->start);
 	if (!lp->eth_regs) {
-		printk(KERN_ERR DRV_NAME "cannot remap registers\n");
+		printk(KERN_ERR DRV_NAME ": cannot remap registers\n");
 		rc = -ENXIO;
 		goto probe_err_out;
 	}
@@ -1119,7 +1118,7 @@ static int korina_probe(struct platform_device *pdev)
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_dma_rx");
 	lp->rx_dma_regs = ioremap_nocache(r->start, r->end - r->start);
 	if (!lp->rx_dma_regs) {
-		printk(KERN_ERR DRV_NAME "cannot remap Rx DMA registers\n");
+		printk(KERN_ERR DRV_NAME ": cannot remap Rx DMA registers\n");
 		rc = -ENXIO;
 		goto probe_err_dma_rx;
 	}
@@ -1127,14 +1126,14 @@ static int korina_probe(struct platform_device *pdev)
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
@@ -1175,9 +1174,11 @@ static int korina_probe(struct platform_device *pdev)
 	rc = register_netdev(dev);
 	if (rc < 0) {
 		printk(KERN_ERR DRV_NAME
-			": cannot register net device %d\n", rc);
+			": cannot register net device: %d\n", rc);
 		goto probe_err_register;
 	}
+	printk(KERN_INFO "%s: " DRV_NAME "-" DRV_VERSION " " DRV_RELDATE "\n",
+			dev->name);
 out:
 	return rc;
 
-- 
1.6.0.6

