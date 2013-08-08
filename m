From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Thu, 08 Aug 2013 14:33:45 -0700
Message-ID: <1375997625.2087.14.camel@joe-AO722>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
	 <20130808210918.GE5502@mwanda>
	 <20130808.142054.1541424422807503741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, kumargauravgupta3@gmail.com,
	emilio@elopez.com.ar, mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130808.142054.1541424422807503741.davem@davemloft.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-08-08 at 14:20 -0700, David Miller wrote:
> From: Dan Carpenter <dan.carpenter@oracle.com>
> Date: Fri, 9 Aug 2013 00:09:18 +0300
> 
> > On Fri, Aug 09, 2013 at 12:50:49AM +0530, Kumar Gaurav wrote:
> >> Removed IRQF_DISABLED as it's no-op and should be removed
> >> 
> > 
> > What?  No, that doesn't sound right.
> 
> The IRQ layer completely ignores the flag for several releases
> now, it's a complete no-op as his commit message so adequately
> states.
> 
> So what's the problem again? :-)

Wouldn't it be better to do a sed 's/IRQF_DISABLED/0/' instead?
Maybe Kumar wants to/is doing that?

Here's what sed and a little emacs did to drivers/net/
(uncompiled/untested)

 drivers/net/ethernet/adi/bfin_mac.c          |  5 ++---
 drivers/net/ethernet/amd/sun3lance.c         |  2 +-
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 13 +++++--------
 drivers/net/ethernet/dec/tulip/de4x5.c       |  4 ++--
 drivers/net/ethernet/freescale/fec_main.c    |  2 +-
 drivers/net/ethernet/hp/hp100.c              |  4 ++--
 drivers/net/ethernet/ibm/ehea/ehea_main.c    |  8 +++-----
 drivers/net/ethernet/korina.c                |  8 ++++----
 drivers/net/ethernet/lantiq_etop.c           |  6 ++----
 drivers/net/ethernet/marvell/pxa168_eth.c    |  3 +--
 drivers/net/ethernet/micrel/ks8851_mll.c     |  2 +-
 drivers/net/ethernet/natsemi/jazzsonic.c     |  3 +--
 drivers/net/ethernet/natsemi/xtsonic.c       |  3 +--
 drivers/net/ethernet/pasemi/pasemi_mac.c     |  4 ++--
 drivers/net/ethernet/smsc/smc91x.h           |  2 +-
 drivers/net/ethernet/smsc/smsc9420.c         |  3 +--
 drivers/net/ethernet/toshiba/ps3_gelic_net.c |  2 +-
 drivers/net/hamradio/baycom_ser_fdx.c        |  2 +-
 drivers/net/hamradio/baycom_ser_hdx.c        |  2 +-
 drivers/net/hamradio/scc.c                   |  2 +-
 drivers/net/hamradio/yam.c                   |  2 +-
 drivers/net/irda/bfin_sir.c                  |  4 ++--
 drivers/net/irda/donauboe.c                  |  6 +++---
 drivers/net/irda/sh_irda.c                   |  2 +-
 drivers/net/irda/sh_sir.c                    |  2 +-
 drivers/net/wan/hostess_sv11.c               |  3 +--
 drivers/net/wan/sealevel.c                   |  3 +--
 drivers/net/wireless/p54/p54spi.c            |  3 +--
 28 files changed, 45 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index e904b38..4eaba0c 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -530,7 +530,7 @@ static int bfin_mac_ethtool_setwol(struct net_device *dev,
 	if (lp->wol && !lp->irq_wake_requested) {
 		/* register wake irq handler */
 		rc = request_irq(IRQ_MAC_WAKEDET, bfin_mac_wake_interrupt,
-				 IRQF_DISABLED, "EMAC_WAKE", dev);
+				 0, "EMAC_WAKE", dev);
 		if (rc)
 			return rc;
 		lp->irq_wake_requested = true;
@@ -1685,8 +1685,7 @@ static int bfin_mac_probe(struct platform_device *pdev)
 
 	/* now, enable interrupts */
 	/* register irq handler */
-	rc = request_irq(IRQ_MAC_RX, bfin_mac_interrupt,
-			IRQF_DISABLED, "EMAC_RX", ndev);
+	rc = request_irq(IRQ_MAC_RX, bfin_mac_interrupt, 0, "EMAC_RX", ndev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot request Blackfin MAC RX IRQ!\n");
 		rc = -EBUSY;
diff --git a/drivers/net/ethernet/amd/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
index d6b2029..3d8c6b2 100644
--- a/drivers/net/ethernet/amd/sun3lance.c
+++ b/drivers/net/ethernet/amd/sun3lance.c
@@ -358,7 +358,7 @@ static int __init lance_probe( struct net_device *dev)
 
 	REGA(CSR0) = CSR0_STOP;
 
-	if (request_irq(LANCE_IRQ, lance_interrupt, IRQF_DISABLED, "SUN3 Lance", dev) < 0) {
+	if (request_irq(LANCE_IRQ, lance_interrupt, 0, "SUN3 Lance", dev) < 0) {
 #ifdef CONFIG_SUN3
 		iounmap((void __iomem *)ioaddr);
 #endif
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index b1bcd4b..14ce6cd 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -926,13 +926,11 @@ static int bcm_enet_open(struct net_device *dev)
 	if (ret)
 		goto out_phy_disconnect;
 
-	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, IRQF_DISABLED,
-			  dev->name, dev);
+	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, 0, dev->name, dev);
 	if (ret)
 		goto out_freeirq;
 
-	ret = request_irq(priv->irq_tx, bcm_enet_isr_dma,
-			  IRQF_DISABLED, dev->name, dev);
+	ret = request_irq(priv->irq_tx, bcm_enet_isr_dma, 0, dev->name, dev);
 	if (ret)
 		goto out_freeirq_rx;
 
@@ -2157,14 +2155,13 @@ static int bcm_enetsw_open(struct net_device *dev)
 	enet_dmac_writel(priv, 0, ENETDMAC_IRMASK, priv->rx_chan);
 	enet_dmac_writel(priv, 0, ENETDMAC_IRMASK, priv->tx_chan);
 
-	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma,
-			  IRQF_DISABLED, dev->name, dev);
+	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, 0, dev->name, dev);
 	if (ret)
 		goto out_freeirq;
 
 	if (priv->irq_tx != -1) {
-		ret = request_irq(priv->irq_tx, bcm_enet_isr_dma,
-				  IRQF_DISABLED, dev->name, dev);
+		ret = request_irq(priv->irq_tx, bcm_enet_isr_dma, 0, dev->name,
+				  dev);
 		if (ret)
 			goto out_freeirq_rx;
 	}
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 4c83003..579df37 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1321,8 +1321,8 @@ de4x5_open(struct net_device *dev)
     if (request_irq(dev->irq, de4x5_interrupt, IRQF_SHARED,
 		                                     lp->adapter_name, dev)) {
 	printk("de4x5_open(): Requested IRQ%d is busy - attemping FAST/SHARE...", dev->irq);
-	if (request_irq(dev->irq, de4x5_interrupt, IRQF_DISABLED | IRQF_SHARED,
-			                             lp->adapter_name, dev)) {
+	if (request_irq(dev->irq, de4x5_interrupt, IRQF_SHARED,
+			lp->adapter_name, dev)) {
 	    printk("\n              Cannot get IRQ- reconfigure your hardware.\n");
 	    disable_ast(dev);
 	    de4x5_free_rx_buffs(dev);
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index fdf9307..7fef570 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2173,7 +2173,7 @@ fec_probe(struct platform_device *pdev)
 			goto failed_irq;
 		}
 		ret = devm_request_irq(&pdev->dev, irq, fec_enet_interrupt,
-				       IRQF_DISABLED, pdev->name, ndev);
+				       0, pdev->name, ndev);
 		if (ret)
 			goto failed_irq;
 	}
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index e3c7c69..ab1fc3c 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -1096,8 +1096,8 @@ static int hp100_open(struct net_device *dev)
 
 	/* New: if bus is PCI or EISA, interrupts might be shared interrupts */
 	if (request_irq(dev->irq, hp100_interrupt,
-			lp->bus == HP100_BUS_PCI || lp->bus ==
-			HP100_BUS_EISA ? IRQF_SHARED : IRQF_DISABLED,
+			lp->bus == HP100_BUS_PCI ||
+			lp->bus == HP100_BUS_EISA ? IRQF_SHARED : 0,
 			"hp100", dev)) {
 		printk("hp100: %s: unable to get IRQ %d\n", dev->name, dev->irq);
 		return -EAGAIN;
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 741f11e..50510e1 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1297,7 +1297,7 @@ static int ehea_reg_interrupts(struct net_device *dev)
 
 	ret = ibmebus_request_irq(port->qp_eq->attr.ist1,
 				  ehea_qp_aff_irq_handler,
-				  IRQF_DISABLED, port->int_aff_name, port);
+				  0, port->int_aff_name, port);
 	if (ret) {
 		netdev_err(dev, "failed registering irq for qp_aff_irq_handler:ist=%X\n",
 			   port->qp_eq->attr.ist1);
@@ -1315,8 +1315,7 @@ static int ehea_reg_interrupts(struct net_device *dev)
 			 "%s-queue%d", dev->name, i);
 		ret = ibmebus_request_irq(pr->eq->attr.ist1,
 					  ehea_recv_irq_handler,
-					  IRQF_DISABLED, pr->int_send_name,
-					  pr);
+					  0, pr->int_send_name, pr);
 		if (ret) {
 			netdev_err(dev, "failed registering irq for ehea_queue port_res_nr:%d, ist=%X\n",
 				   i, pr->eq->attr.ist1);
@@ -3332,8 +3331,7 @@ static int ehea_probe_adapter(struct platform_device *dev)
 	}
 
 	ret = ibmebus_request_irq(adapter->neq->attr.ist1,
-				  ehea_interrupt_neq, IRQF_DISABLED,
-				  "ehea_neq", adapter);
+				  ehea_interrupt_neq, 0, "ehea_neq", adapter);
 	if (ret) {
 		dev_err(&dev->dev, "requesting NEQ IRQ failed\n");
 		goto out_shutdown_ports;
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 270e65f..8c3c1da 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -996,14 +996,14 @@ static int korina_open(struct net_device *dev)
 	 * that handles the Done Finished
 	 * Ovr and Und Events */
 	ret = request_irq(lp->rx_irq, korina_rx_dma_interrupt,
-			IRQF_DISABLED, "Korina ethernet Rx", dev);
+			  0, "Korina ethernet Rx", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get Rx DMA IRQ %d\n",
 		    dev->name, lp->rx_irq);
 		goto err_release;
 	}
 	ret = request_irq(lp->tx_irq, korina_tx_dma_interrupt,
-			IRQF_DISABLED, "Korina ethernet Tx", dev);
+			  0, "Korina ethernet Tx", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get Tx DMA IRQ %d\n",
 		    dev->name, lp->tx_irq);
@@ -1012,7 +1012,7 @@ static int korina_open(struct net_device *dev)
 
 	/* Install handler for overrun error. */
 	ret = request_irq(lp->ovr_irq, korina_ovr_interrupt,
-			IRQF_DISABLED, "Ethernet Overflow", dev);
+			  0, "Ethernet Overflow", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get OVR IRQ %d\n",
 		    dev->name, lp->ovr_irq);
@@ -1021,7 +1021,7 @@ static int korina_open(struct net_device *dev)
 
 	/* Install handler for underflow error. */
 	ret = request_irq(lp->und_irq, korina_und_interrupt,
-			IRQF_DISABLED, "Ethernet Underflow", dev);
+			  0, "Ethernet Underflow", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get UND IRQ %d\n",
 		    dev->name, lp->und_irq);
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index bfdb0686..6a6c1f7 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -282,8 +282,7 @@ ltq_etop_hw_init(struct net_device *dev)
 
 		if (IS_TX(i)) {
 			ltq_dma_alloc_tx(&ch->dma);
-			request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
-				"etop_tx", priv);
+			request_irq(irq, ltq_etop_dma_irq, 0, "etop_tx", priv);
 		} else if (IS_RX(i)) {
 			ltq_dma_alloc_rx(&ch->dma);
 			for (ch->dma.desc = 0; ch->dma.desc < LTQ_DESC_NUM;
@@ -291,8 +290,7 @@ ltq_etop_hw_init(struct net_device *dev)
 				if (ltq_etop_alloc_skb(ch))
 					return -ENOMEM;
 			ch->dma.desc = 0;
-			request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
-				"etop_rx", priv);
+			request_irq(irq, ltq_etop_dma_irq, 0, "etop_rx", priv);
 		}
 		ch->dma.irq = irq;
 	}
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index db48147..51336f8 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1124,8 +1124,7 @@ static int pxa168_eth_open(struct net_device *dev)
 	struct pxa168_eth_private *pep = netdev_priv(dev);
 	int err;
 
-	err = request_irq(dev->irq, pxa168_eth_int_handler,
-			  IRQF_DISABLED, dev->name, dev);
+	err = request_irq(dev->irq, pxa168_eth_int_handler, 0, dev->name, dev);
 	if (err) {
 		dev_err(&dev->dev, "can't assign irq\n");
 		return -EAGAIN;
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 9f3f5db..63c06d4 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -915,7 +915,7 @@ static int ks_net_open(struct net_device *netdev)
 	struct ks_net *ks = netdev_priv(netdev);
 	int err;
 
-#define	KS_INT_FLAGS	(IRQF_DISABLED|IRQF_TRIGGER_LOW)
+#define	KS_INT_FLAGS	(IRQF_TRIGGER_LOW)
 	/* lock the card, even if we may not actually do anything
 	 * else at the moment.
 	 */
diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
index c20766c..79257f7 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -83,8 +83,7 @@ static int jazzsonic_open(struct net_device* dev)
 {
 	int retval;
 
-	retval = request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED,
-				"sonic", dev);
+	retval = request_irq(dev->irq, sonic_interrupt, 0, "sonic", dev);
 	if (retval) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
 				dev->name, dev->irq);
diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index c2e0256..4da172a 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -95,8 +95,7 @@ static int xtsonic_open(struct net_device *dev)
 {
 	int retval;
 
-	retval = request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED,
-				"sonic", dev);
+	retval = request_irq(dev->irq, sonic_interrupt, 0, "sonic", dev);
 	if (retval) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
 		       dev->name, dev->irq);
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index f21ae7b..5e89438 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1220,7 +1220,7 @@ static int pasemi_mac_open(struct net_device *dev)
 	snprintf(mac->tx_irq_name, sizeof(mac->tx_irq_name), "%s tx",
 		 dev->name);
 
-	ret = request_irq(mac->tx->chan.irq, pasemi_mac_tx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->tx->chan.irq, pasemi_mac_tx_intr, 0,
 			  mac->tx_irq_name, mac->tx);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
@@ -1231,7 +1231,7 @@ static int pasemi_mac_open(struct net_device *dev)
 	snprintf(mac->rx_irq_name, sizeof(mac->rx_irq_name), "%s rx",
 		 dev->name);
 
-	ret = request_irq(mac->rx->chan.irq, pasemi_mac_rx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->rx->chan.irq, pasemi_mac_rx_intr, 0,
 			  mac->rx_irq_name, mac->rx);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 370e13d..50ef30f 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -271,7 +271,7 @@ static inline void mcf_outsw(void *a, unsigned char *p, int l)
 #define SMC_insw(a, r, p, l)	mcf_insw(a + r, p, l)
 #define SMC_outsw(a, r, p, l)	mcf_outsw(a + r, p, l)
 
-#define SMC_IRQ_FLAGS		(IRQF_DISABLED)
+#define SMC_IRQ_FLAGS		(0)
 
 #else
 
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index ffa5c4a..5f9e79f 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1356,8 +1356,7 @@ static int smsc9420_open(struct net_device *dev)
 	smsc9420_reg_write(pd, INT_STAT, 0xFFFFFFFF);
 	smsc9420_pci_flush_write(pd);
 
-	result = request_irq(irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
-			     DRV_NAME, pd);
+	result = request_irq(irq, smsc9420_isr, IRQF_SHARED, DRV_NAME, pd);
 	if (result) {
 		smsc_warn(IFUP, "Unable to use IRQ = %d", irq);
 		result = -ENODEV;
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index ad32af6..c91590e 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1727,7 +1727,7 @@ static int ps3_gelic_driver_probe(struct ps3_system_bus_device *dev)
 		goto fail_alloc_irq;
 	}
 	result = request_irq(card->irq, gelic_card_interrupt,
-			     IRQF_DISABLED, netdev->name, card);
+			     0, netdev->name, card);
 
 	if (result) {
 		dev_info(ctodev(card), "%s:request_irq failed (%d)\n",
diff --git a/drivers/net/hamradio/baycom_ser_fdx.c b/drivers/net/hamradio/baycom_ser_fdx.c
index a974727..636b65c 100644
--- a/drivers/net/hamradio/baycom_ser_fdx.c
+++ b/drivers/net/hamradio/baycom_ser_fdx.c
@@ -445,7 +445,7 @@ static int ser12_open(struct net_device *dev)
 	outb(0, FCR(dev->base_addr));  /* disable FIFOs */
 	outb(0x0d, MCR(dev->base_addr));
 	outb(0, IER(dev->base_addr));
-	if (request_irq(dev->irq, ser12_interrupt, IRQF_DISABLED | IRQF_SHARED,
+	if (request_irq(dev->irq, ser12_interrupt, IRQF_SHARED,
 			"baycom_ser_fdx", dev)) {
 		release_region(dev->base_addr, SER12_EXTENT);
 		return -EBUSY;
diff --git a/drivers/net/hamradio/baycom_ser_hdx.c b/drivers/net/hamradio/baycom_ser_hdx.c
index e349d86..f9a8976 100644
--- a/drivers/net/hamradio/baycom_ser_hdx.c
+++ b/drivers/net/hamradio/baycom_ser_hdx.c
@@ -490,7 +490,7 @@ static int ser12_open(struct net_device *dev)
 	outb(0, FCR(dev->base_addr));  /* disable FIFOs */
 	outb(0x0d, MCR(dev->base_addr));
 	outb(0, IER(dev->base_addr));
-	if (request_irq(dev->irq, ser12_interrupt, IRQF_DISABLED | IRQF_SHARED,
+	if (request_irq(dev->irq, ser12_interrupt, IRQF_SHARED,
 			"baycom_ser12", dev)) {
 		release_region(dev->base_addr, SER12_EXTENT);       
 		return -EBUSY;
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index bc1d521..4bc6ee8 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1734,7 +1734,7 @@ static int scc_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			if (!Ivec[hwcfg.irq].used && hwcfg.irq)
 			{
 				if (request_irq(hwcfg.irq, scc_isr,
-						IRQF_DISABLED, "AX.25 SCC",
+						0, "AX.25 SCC",
 						(void *)(long) hwcfg.irq))
 					printk(KERN_WARNING "z8530drv: warning, cannot get IRQ %d\n", hwcfg.irq);
 				else
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 0721e72..ff31ff0 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -888,7 +888,7 @@ static int yam_open(struct net_device *dev)
 		goto out_release_base;
 	}
 	outb(0, IER(dev->base_addr));
-	if (request_irq(dev->irq, yam_interrupt, IRQF_DISABLED | IRQF_SHARED, dev->name, dev)) {
+	if (request_irq(dev->irq, yam_interrupt, IRQF_SHARED, dev->name, dev)) {
 		printk(KERN_ERR "%s: irq %d busy\n", dev->name, dev->irq);
 		ret = -EBUSY;
 		goto out_release_base;
diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index c74f384..303c4bd 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -411,12 +411,12 @@ static int bfin_sir_startup(struct bfin_sir_port *port, struct net_device *dev)
 
 #else
 
-	if (request_irq(port->irq, bfin_sir_rx_int, IRQF_DISABLED, "BFIN_SIR_RX", dev)) {
+	if (request_irq(port->irq, bfin_sir_rx_int, 0, "BFIN_SIR_RX", dev)) {
 		dev_warn(&dev->dev, "Unable to attach SIR RX interrupt\n");
 		return -EBUSY;
 	}
 
-	if (request_irq(port->irq+1, bfin_sir_tx_int, IRQF_DISABLED, "BFIN_SIR_TX", dev)) {
+	if (request_irq(port->irq+1, bfin_sir_tx_int, 0, "BFIN_SIR_TX", dev)) {
 		dev_warn(&dev->dev, "Unable to attach SIR TX interrupt\n");
 		free_irq(port->irq, dev);
 		return -EBUSY;
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index c6bfc4a..1bc033b 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1351,8 +1351,8 @@ toshoboe_net_open (struct net_device *dev)
   if (self->stopped)
     return 0;
 
-  rc = request_irq (self->io.irq, toshoboe_interrupt,
-                    IRQF_SHARED | IRQF_DISABLED, dev->name, self);
+  rc = request_irq(self->io.irq, toshoboe_interrupt, IRQF_SHARED,
+		   dev->name, self);
   if (rc)
   	return rc;
 
@@ -1559,7 +1559,7 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
   self->io.fir_base = self->base;
   self->io.fir_ext = OBOE_IO_EXTENT;
   self->io.irq = pci_dev->irq;
-  self->io.irqflags = IRQF_SHARED | IRQF_DISABLED;
+  self->io.irqflags = IRQF_SHARED;
 
   self->speed = self->io.speed = 9600;
   self->async = 0;
diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index 4455425..ff45cd0 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -804,7 +804,7 @@ static int sh_irda_probe(struct platform_device *pdev)
 		goto err_mem_4;
 
 	platform_set_drvdata(pdev, ndev);
-	err = request_irq(irq, sh_irda_irq, IRQF_DISABLED, "sh_irda", self);
+	err = request_irq(irq, sh_irda_irq, 0, "sh_irda", self);
 	if (err) {
 		dev_warn(&pdev->dev, "Unable to attach sh_irda interrupt\n");
 		goto err_mem_4;
diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 89682b4..8d9ae5a 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -761,7 +761,7 @@ static int sh_sir_probe(struct platform_device *pdev)
 		goto err_mem_4;
 
 	platform_set_drvdata(pdev, ndev);
-	err = request_irq(irq, sh_sir_irq, IRQF_DISABLED, "sh_sir", self);
+	err = request_irq(irq, sh_sir_irq, 0, "sh_sir", self);
 	if (err) {
 		dev_warn(&pdev->dev, "Unable to attach sh_sir interrupt\n");
 		goto err_mem_4;
diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index 3d80e42..fdf1aeb 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -220,8 +220,7 @@ static struct z8530_dev *sv11_init(int iobase, int irq)
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
 
-	if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
-			"Hostess SV11", sv) < 0) {
+	if (request_irq(irq, z8530_interrupt, 0, "Hostess SV11", sv) < 0) {
 		pr_warn("IRQ %d already in use\n", irq);
 		goto err_irq;
 	}
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 4f77484..be401d9 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -266,8 +266,7 @@ static __init struct slvl_board *slvl_init(int iobase, int irq,
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
 
-	if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
-			"SeaLevel", dev) < 0) {
+	if (request_irq(irq, z8530_interrupt, 0, "SeaLevel", dev) < 0) {
 		pr_warn("IRQ %d already in use\n", irq);
 		goto err_request_irq;
 	}
diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
index 7fc46f2..6c5e412 100644
--- a/drivers/net/wireless/p54/p54spi.c
+++ b/drivers/net/wireless/p54/p54spi.c
@@ -636,8 +636,7 @@ static int p54spi_probe(struct spi_device *spi)
 	gpio_direction_input(p54spi_gpio_irq);
 
 	ret = request_irq(gpio_to_irq(p54spi_gpio_irq),
-			  p54spi_interrupt, IRQF_DISABLED, "p54spi",
-			  priv->spi);
+			  p54spi_interrupt, 0, "p54spi", priv->spi);
 	if (ret < 0) {
 		dev_err(&priv->spi->dev, "request_irq() failed");
 		goto err_free_gpio_irq;


