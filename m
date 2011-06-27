From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/8] dscc4: Update to current logging forms
Date: Sun, 26 Jun 2011 22:01:32 -0700
Message-ID: <98fab15052d0e037e5a5c813cf2d6bc5d49564a8.1309150684.git.joe@perches.com>
References: <cover.1309150683.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309150683.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pr_fmt, pr_<level> and netdev_<level> as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/dscc4.c |   80 ++++++++++++++++++++++------------------------
 1 files changed, 38 insertions(+), 42 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 3590d58..058e169 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -80,6 +80,8 @@
  * - misc crapectomy.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/types.h>
@@ -553,7 +555,7 @@ static int dscc4_wait_ack_cec(struct dscc4_dev_priv *dpriv,
 		schedule_timeout_uninterruptible(10);
 		rmb();
 	} while (++i > 0);
-	printk(KERN_ERR "%s: %s timeout\n", dev->name, msg);
+	netdev_err(dev, "%s timeout\n", msg);
 done:
 	return (i >= 0) ? i : -EAGAIN;
 }
@@ -569,18 +571,18 @@ static int dscc4_do_action(struct net_device *dev, char *msg)
 		u32 state = readl(ioaddr);
 
 		if (state & ArAck) {
-			printk(KERN_DEBUG "%s: %s ack\n", dev->name, msg);
+			netdev_dbg(dev, "%s ack\n", msg);
 			writel(ArAck, ioaddr);
 			goto done;
 		} else if (state & Arf) {
-			printk(KERN_ERR "%s: %s failed\n", dev->name, msg);
+			netdev_err(dev, "%s failed\n", msg);
 			writel(Arf, ioaddr);
 			i = -1;
 			goto done;
 	}
 		rmb();
 	} while (++i > 0);
-	printk(KERN_ERR "%s: %s timeout\n", dev->name, msg);
+	netdev_err(dev, "%s timeout\n", msg);
 done:
 	return i;
 }
@@ -636,7 +638,7 @@ static void dscc4_tx_reset(struct dscc4_dev_priv *dpriv, struct net_device *dev)
 
 	writel(MTFi|Rdt, dpriv->base_addr + dpriv->dev_id*0x0c + CH0CFG);
 	if (dscc4_do_action(dev, "Rdt") < 0)
-		printk(KERN_ERR "%s: Tx reset failed\n", dev->name);
+		netdev_err(dev, "Tx reset failed\n");
 }
 #endif
 
@@ -722,22 +724,20 @@ static int __devinit dscc4_init_one(struct pci_dev *pdev,
 
 	rc = pci_request_region(pdev, 0, "registers");
 	if (rc < 0) {
-	        printk(KERN_ERR "%s: can't reserve MMIO region (regs)\n",
-			DRV_NAME);
+		pr_err("can't reserve MMIO region (regs)\n");
 	        goto err_disable_0;
 	}
 	rc = pci_request_region(pdev, 1, "LBI interface");
 	if (rc < 0) {
-	        printk(KERN_ERR "%s: can't reserve MMIO region (lbi)\n",
-			DRV_NAME);
+		pr_err("can't reserve MMIO region (lbi)\n");
 	        goto err_free_mmio_region_1;
 	}
 
 	ioaddr = pci_ioremap_bar(pdev, 0);
 	if (!ioaddr) {
-		printk(KERN_ERR "%s: cannot remap MMIO region %llx @ %llx\n",
-			DRV_NAME, (unsigned long long)pci_resource_len(pdev, 0),
-			(unsigned long long)pci_resource_start(pdev, 0));
+		pr_err("cannot remap MMIO region %llx @ %llx\n",
+		       (unsigned long long)pci_resource_len(pdev, 0),
+		       (unsigned long long)pci_resource_start(pdev, 0));
 		rc = -EIO;
 		goto err_free_mmio_regions_2;
 	}
@@ -757,7 +757,7 @@ static int __devinit dscc4_init_one(struct pci_dev *pdev,
 
 	rc = request_irq(pdev->irq, dscc4_irq, IRQF_SHARED, DRV_NAME, priv->root);
 	if (rc < 0) {
-		printk(KERN_WARNING "%s: IRQ %d busy\n", DRV_NAME, pdev->irq);
+		pr_warn("IRQ %d busy\n", pdev->irq);
 		goto err_release_4;
 	}
 
@@ -904,7 +904,7 @@ static int dscc4_found1(struct pci_dev *pdev, void __iomem *ioaddr)
 
 	root = kcalloc(dev_per_card, sizeof(*root), GFP_KERNEL);
 	if (!root) {
-		printk(KERN_ERR "%s: can't allocate data\n", DRV_NAME);
+		pr_err("can't allocate data\n");
 		goto err_out;
 	}
 
@@ -916,7 +916,7 @@ static int dscc4_found1(struct pci_dev *pdev, void __iomem *ioaddr)
 
 	ppriv = kzalloc(sizeof(*ppriv), GFP_KERNEL);
 	if (!ppriv) {
-		printk(KERN_ERR "%s: can't allocate private data\n", DRV_NAME);
+		pr_err("can't allocate private data\n");
 		goto err_free_dev;
 	}
 
@@ -952,7 +952,7 @@ static int dscc4_found1(struct pci_dev *pdev, void __iomem *ioaddr)
 
 		ret = register_hdlc_device(d);
 		if (ret < 0) {
-			printk(KERN_ERR "%s: unable to register\n", DRV_NAME);
+			pr_err("unable to register\n");
 			dscc4_release_ring(dpriv);
 			goto err_unregister;
 	        }
@@ -1005,7 +1005,7 @@ static int dscc4_loopback_check(struct dscc4_dev_priv *dpriv)
 	if (settings->loopback && (settings->clock_type != CLOCK_INT)) {
 		struct net_device *dev = dscc4_to_dev(dpriv);
 
-		printk(KERN_INFO "%s: loopback requires clock\n", dev->name);
+		netdev_info(dev, "loopback requires clock\n");
 		return -1;
 	}
 	return 0;
@@ -1078,7 +1078,7 @@ static int dscc4_open(struct net_device *dev)
 		scc_patchl(0, PowerUp, dpriv, dev, CCR0);
 		scc_patchl(0, 0x00050000, dpriv, dev, CCR2);
 		scc_writel(EventsMask, dpriv, dev, IMR);
-		printk(KERN_INFO "%s: up again.\n", dev->name);
+		netdev_info(dev, "up again\n");
 		goto done;
 	}
 
@@ -1095,11 +1095,11 @@ static int dscc4_open(struct net_device *dev)
 	 * situations.
 	 */
 	if (scc_readl_star(dpriv, dev) & SccBusy) {
-		printk(KERN_ERR "%s busy. Try later\n", dev->name);
+		netdev_err(dev, "busy - try later\n");
 		ret = -EAGAIN;
 		goto err_out;
 	} else
-		printk(KERN_INFO "%s: available. Good\n", dev->name);
+		netdev_info(dev, "available - good\n");
 
 	scc_writel(EventsMask, dpriv, dev, IMR);
 
@@ -1117,7 +1117,7 @@ static int dscc4_open(struct net_device *dev)
 	 * reset is needed. Suggestions anyone ?
 	 */
 	if ((ret = dscc4_xpr_ack(dpriv)) < 0) {
-		printk(KERN_ERR "%s: %s timeout\n", DRV_NAME, "XPR");
+		pr_err("XPR timeout\n");
 		goto err_disable_scc_events;
 	}
 	
@@ -1342,8 +1342,7 @@ static int dscc4_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			return -EPERM;
 
 		if (dpriv->flags & FakeReset) {
-			printk(KERN_INFO "%s: please reset the device"
-			       " before this command\n", dev->name);
+			netdev_info(dev, "please reset the device before this command\n");
 			return -EPERM;
 		}
 		if (copy_from_user(&dpriv->settings, line, size))
@@ -1506,8 +1505,7 @@ static irqreturn_t dscc4_irq(int irq, void *token)
 	writel(state, ioaddr + GSTAR);
 
 	if (state & Arf) {
-		printk(KERN_ERR "%s: failure (Arf). Harass the maintener\n",
-		       dev->name);
+		netdev_err(dev, "failure (Arf). Harass the maintainer\n");
 		goto out;
 	}
 	state &= ~ArAck;
@@ -1515,7 +1513,7 @@ static irqreturn_t dscc4_irq(int irq, void *token)
 		if (debug > 0)
 			printk(KERN_DEBUG "%s: CfgIV\n", DRV_NAME);
 		if (priv->iqcfg[priv->cfg_cur++%IRQ_RING_SIZE] & cpu_to_le32(Arf))
-			printk(KERN_ERR "%s: %s failed\n", dev->name, "CFG");
+			netdev_err(dev, "CFG failed\n");
 		if (!(state &= ~Cfg))
 			goto out;
 	}
@@ -1596,8 +1594,8 @@ try:
 				++dpriv->tx_dirty;
 			} else {
 				if (debug > 1)
-					printk(KERN_ERR "%s Tx: NULL skb %d\n",
-						dev->name, cur);
+					netdev_err(dev, "Tx: NULL skb %d\n",
+						   cur);
 			}
 			/*
 			 * If the driver ends sending crap on the wire, it
@@ -1616,7 +1614,7 @@ try:
 		 * Transmit Data Underrun
 		 */
 		if (state & Xdu) {
-			printk(KERN_ERR "%s: XDU. Ask maintainer\n", DRV_NAME);
+			netdev_err(dev, "Tx Data Underrun. Ask maintainer\n");
 			dpriv->flags = NeedIDT;
 			/* Tx reset */
 			writel(MTFi | Rdt,
@@ -1625,13 +1623,13 @@ try:
 			return;
 		}
 		if (state & Cts) {
-			printk(KERN_INFO "%s: CTS transition\n", dev->name);
+			netdev_info(dev, "CTS transition\n");
 			if (!(state &= ~Cts)) /* DEBUG */
 				goto try;
 		}
 		if (state & Xmr) {
 			/* Frame needs to be sent again - FIXME */
-			printk(KERN_ERR "%s: Xmr. Ask maintainer\n", DRV_NAME);
+			netdev_err(dev, "Tx ReTx. Ask maintainer\n");
 			if (!(state &= ~Xmr)) /* DEBUG */
 				goto try;
 		}
@@ -1649,7 +1647,7 @@ try:
 					break;
 			}
 			if (!i)
-				printk(KERN_INFO "%s busy in irq\n", dev->name);
+				netdev_info(dev, "busy in irq\n");
 
 			scc_addr = dpriv->base_addr + 0x0c*dpriv->dev_id;
 			/* Keep this order: IDT before IDR */
@@ -1686,7 +1684,7 @@ try:
 		}
 		if (state & Cd) {
 			if (debug > 0)
-				printk(KERN_INFO "%s: CD transition\n", dev->name);
+				netdev_info(dev, "CD transition\n");
 			if (!(state &= ~Cd)) /* DEBUG */
 				goto try;
 		}
@@ -1695,11 +1693,11 @@ try:
 #ifdef DSCC4_POLLING
 			while (!dscc4_tx_poll(dpriv, dev));
 #endif
-			printk(KERN_INFO "%s: Tx Hi\n", dev->name);
+			netdev_info(dev, "Tx Hi\n");
 			state &= ~Hi;
 		}
 		if (state & Err) {
-			printk(KERN_INFO "%s: Tx ERR\n", dev->name);
+			netdev_info(dev, "Tx ERR\n");
 			dev->stats.tx_errors++;
 			state &= ~Err;
 		}
@@ -1769,7 +1767,7 @@ try:
 			goto try;
 		}
 		if (state & Hi ) { /* HI bit */
-			printk(KERN_INFO "%s: Rx Hi\n", dev->name);
+			netdev_info(dev, "Rx Hi\n");
 			state &= ~Hi;
 			goto try;
 		}
@@ -1800,7 +1798,7 @@ try:
 				goto try;
 		}
 		if (state & Cts) {
-			printk(KERN_INFO "%s: CTS transition\n", dev->name);
+			netdev_info(dev, "CTS transition\n");
 			if (!(state &= ~Cts)) /* DEBUG */
 				goto try;
 		}
@@ -1859,14 +1857,12 @@ try:
 			       sizeof(struct RxFD), scc_addr + CH0BRDA);
 			writel(MTFi|Rdr|Idr, scc_addr + CH0CFG);
 			if (dscc4_do_action(dev, "RDR") < 0) {
-				printk(KERN_ERR "%s: RDO recovery failed(%s)\n",
-				       dev->name, "RDR");
+				netdev_err(dev, "RDO recovery failed(RDR)\n");
 				goto rdo_end;
 			}
 			writel(MTFi|Idr, scc_addr + CH0CFG);
 			if (dscc4_do_action(dev, "IDR") < 0) {
-				printk(KERN_ERR "%s: RDO recovery failed(%s)\n",
-				       dev->name, "IDR");
+				netdev_err(dev, "RDO recovery failed(IDR)\n");
 				goto rdo_end;
 			}
 		rdo_end:
@@ -1875,7 +1871,7 @@ try:
 			goto try;
 		}
 		if (state & Cd) {
-			printk(KERN_INFO "%s: CD transition\n", dev->name);
+			netdev_info(dev, "CD transition\n");
 			if (!(state &= ~Cd)) /* DEBUG */
 				goto try;
 		}
-- 
1.7.6.rc1
