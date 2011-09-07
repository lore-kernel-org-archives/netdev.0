From: Yong Zhang <yong.zhang0@gmail.com>
Subject: [PATCH 45/62] net: irq: Remove IRQF_DISABLED
Date: Wed,  7 Sep 2011 16:10:42 +0800
Message-ID: <1315383059-3673-46-git-send-email-yong.zhang0@gmail.com>
References: <1315383059-3673-1-git-send-email-yong.zhang0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jaroslav Kysela <perex@perex.cz>, David Howells <dhowells@redhat.com>,
	Philip Rakity <prakity@marvell.com>, netdev@vger.kernel.org,
	Christian Lamparter <chunkeey@googlemail.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Klaus Kudielka <klaus.kudielka@ieee.org>,
	Thomas Sailer <t.sailer@alumni.ethz.ch>, Kevin Hilman <khilman@ti.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, Johan Hovold <jhovold@gmail.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>, mingo@elte.hu,
	Jean-Paul Roubelat <jpr@f6fbb.org>, Alexey Dobriyan <adobriyan@gmail.com>,
	Joerg Reuter <jreuter@yaina.de>, cbe-oss-dev@lists.ozlabs.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>,
	Samuel Ortiz <samuel@sortiz.org>, Mike Frysinger <vapier@gentoo.org>,
	Grant Grundler <grundler@parisc-linux.org>,
	Yong Zhang <yong.zhang0@gmail.com>, Tobias Klauser <tklauser@distanz.ch>,
	Luca
To: linux-kernel@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1315383059-3673-1-git-send-email-yong.zhang0@gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

This flag is a NOOP and can be removed now.

Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>
---
 drivers/net/bcm63xx_enet.c            |    4 ++--
 drivers/net/bfin_mac.c                |    4 ++--
 drivers/net/davinci_emac.c            |    2 +-
 drivers/net/ehea/ehea_main.c          |    6 +++---
 drivers/net/fec.c                     |    2 +-
 drivers/net/hamradio/baycom_ser_fdx.c |    2 +-
 drivers/net/hamradio/baycom_ser_hdx.c |    2 +-
 drivers/net/hamradio/scc.c            |    2 +-
 drivers/net/hamradio/yam.c            |    2 +-
 drivers/net/hp100.c                   |    2 +-
 drivers/net/irda/bfin_sir.c           |    4 ++--
 drivers/net/irda/donauboe.c           |    4 ++--
 drivers/net/irda/sh_irda.c            |    2 +-
 drivers/net/irda/sh_sir.c             |    2 +-
 drivers/net/jazzsonic.c               |    2 +-
 drivers/net/korina.c                  |    8 ++++----
 drivers/net/ks8851_mll.c              |    2 +-
 drivers/net/lantiq_etop.c             |    4 ++--
 drivers/net/pasemi_mac.c              |    4 ++--
 drivers/net/ps3_gelic_net.c           |    2 +-
 drivers/net/pxa168_eth.c              |    2 +-
 drivers/net/smc91x.h                  |    2 +-
 drivers/net/smsc9420.c                |    2 +-
 drivers/net/sun3lance.c               |    2 +-
 drivers/net/tulip/de4x5.c             |    2 +-
 drivers/net/wan/hostess_sv11.c        |    2 +-
 drivers/net/wan/sealevel.c            |    2 +-
 drivers/net/wireless/p54/p54spi.c     |    2 +-
 drivers/net/xtsonic.c                 |    2 +-
 include/net/irda/irda_device.h        |    2 +-
 30 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/bcm63xx_enet.c
index 1d9b985..24f57b5 100644
--- a/drivers/net/bcm63xx_enet.c
+++ b/drivers/net/bcm63xx_enet.c
@@ -840,13 +840,13 @@ static int bcm_enet_open(struct net_device *dev)
 	if (ret)
 		goto out_phy_disconnect;
 
-	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, IRQF_DISABLED,
+	ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, 0,
 			  dev->name, dev);
 	if (ret)
 		goto out_freeirq;
 
 	ret = request_irq(priv->irq_tx, bcm_enet_isr_dma,
-			  IRQF_DISABLED, dev->name, dev);
+			  0, dev->name, dev);
 	if (ret)
 		goto out_freeirq_rx;
 
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 6c019e1..765b7df 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -531,7 +531,7 @@ static int bfin_mac_ethtool_setwol(struct net_device *dev,
 	if (lp->wol && !lp->irq_wake_requested) {
 		/* register wake irq handler */
 		rc = request_irq(IRQ_MAC_WAKEDET, bfin_mac_wake_interrupt,
-				 IRQF_DISABLED, "EMAC_WAKE", dev);
+				 0, "EMAC_WAKE", dev);
 		if (rc)
 			return rc;
 		lp->irq_wake_requested = true;
@@ -1544,7 +1544,7 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	/* now, enable interrupts */
 	/* register irq handler */
 	rc = request_irq(IRQ_MAC_RX, bfin_mac_interrupt,
-			IRQF_DISABLED, "EMAC_RX", ndev);
+			0, "EMAC_RX", ndev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot request Blackfin MAC RX IRQ!\n");
 		rc = -EBUSY;
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 3f451e4..7373ab1 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1553,7 +1553,7 @@ static int emac_dev_open(struct net_device *ndev)
 
 	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
 		for (i = res->start; i <= res->end; i++) {
-			if (request_irq(i, emac_irq, IRQF_DISABLED,
+			if (request_irq(i, emac_irq, 0,
 					ndev->name, ndev))
 				goto rollback;
 		}
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index be2cb4a..053327e 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1340,7 +1340,7 @@ static int ehea_reg_interrupts(struct net_device *dev)
 
 	ret = ibmebus_request_irq(port->qp_eq->attr.ist1,
 				  ehea_qp_aff_irq_handler,
-				  IRQF_DISABLED, port->int_aff_name, port);
+				  0, port->int_aff_name, port);
 	if (ret) {
 		netdev_err(dev, "failed registering irq for qp_aff_irq_handler:ist=%X\n",
 			   port->qp_eq->attr.ist1);
@@ -1358,7 +1358,7 @@ static int ehea_reg_interrupts(struct net_device *dev)
 			 "%s-queue%d", dev->name, i);
 		ret = ibmebus_request_irq(pr->eq->attr.ist1,
 					  ehea_recv_irq_handler,
-					  IRQF_DISABLED, pr->int_send_name,
+					  0, pr->int_send_name,
 					  pr);
 		if (ret) {
 			netdev_err(dev, "failed registering irq for ehea_queue port_res_nr:%d, ist=%X\n",
@@ -3513,7 +3513,7 @@ static int __devinit ehea_probe_adapter(struct platform_device *dev,
 		     (unsigned long)adapter);
 
 	ret = ibmebus_request_irq(adapter->neq->attr.ist1,
-				  ehea_interrupt_neq, IRQF_DISABLED,
+				  ehea_interrupt_neq, 0,
 				  "ehea_neq", adapter);
 	if (ret) {
 		dev_err(&dev->dev, "requesting NEQ IRQ failed\n");
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index e8266cc..0da5346 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1508,7 +1508,7 @@ fec_probe(struct platform_device *pdev)
 		irq = platform_get_irq(pdev, i);
 		if (i && irq < 0)
 			break;
-		ret = request_irq(irq, fec_enet_interrupt, IRQF_DISABLED, pdev->name, ndev);
+		ret = request_irq(irq, fec_enet_interrupt, 0, pdev->name, ndev);
 		if (ret) {
 			while (--i >= 0) {
 				irq = platform_get_irq(pdev, i);
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
index 3365581..f432f32 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1735,7 +1735,7 @@ static int scc_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 			if (!Ivec[hwcfg.irq].used && hwcfg.irq)
 			{
 				if (request_irq(hwcfg.irq, scc_isr,
-						IRQF_DISABLED, "AX.25 SCC",
+						0, "AX.25 SCC",
 						(void *)(long) hwcfg.irq))
 					printk(KERN_WARNING "z8530drv: warning, cannot get IRQ %d\n", hwcfg.irq);
 				else
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 96a98d2..9d60f06 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -890,7 +890,7 @@ static int yam_open(struct net_device *dev)
 		goto out_release_base;
 	}
 	outb(0, IER(dev->base_addr));
-	if (request_irq(dev->irq, yam_interrupt, IRQF_DISABLED | IRQF_SHARED, dev->name, dev)) {
+	if (request_irq(dev->irq, yam_interrupt, IRQF_SHARED, dev->name, dev)) {
 		printk(KERN_ERR "%s: irq %d busy\n", dev->name, dev->irq);
 		ret = -EBUSY;
 		goto out_release_base;
diff --git a/drivers/net/hp100.c b/drivers/net/hp100.c
index b6519c1..e3b7c1d 100644
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -1097,7 +1097,7 @@ static int hp100_open(struct net_device *dev)
 	/* New: if bus is PCI or EISA, interrupts might be shared interrupts */
 	if (request_irq(dev->irq, hp100_interrupt,
 			lp->bus == HP100_BUS_PCI || lp->bus ==
-			HP100_BUS_EISA ? IRQF_SHARED : IRQF_DISABLED,
+			HP100_BUS_EISA ? IRQF_SHARED : 0,
 			"hp100", dev)) {
 		printk("hp100: %s: unable to get IRQ %d\n", dev->name, dev->irq);
 		return -EAGAIN;
diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index 9d4ce1a..529317b 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -410,12 +410,12 @@ static int bfin_sir_startup(struct bfin_sir_port *port, struct net_device *dev)
 
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
index b45b2cc..04e4528 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -1353,7 +1353,7 @@ toshoboe_net_open (struct net_device *dev)
     return 0;
 
   rc = request_irq (self->io.irq, toshoboe_interrupt,
-                    IRQF_SHARED | IRQF_DISABLED, dev->name, self);
+                    IRQF_SHARED, dev->name, self);
   if (rc)
   	return rc;
 
@@ -1560,7 +1560,7 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
   self->io.fir_base = self->base;
   self->io.fir_ext = OBOE_IO_EXTENT;
   self->io.irq = pci_dev->irq;
-  self->io.irqflags = IRQF_SHARED | IRQF_DISABLED;
+  self->io.irqflags = IRQF_SHARED;
 
   self->speed = self->io.speed = 9600;
   self->async = 0;
diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index 8266067..2b23e0b 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -810,7 +810,7 @@ static int __devinit sh_irda_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 
-	if (request_irq(irq, sh_irda_irq, IRQF_DISABLED, "sh_irda", self)) {
+	if (request_irq(irq, sh_irda_irq, 0, "sh_irda", self)) {
 		dev_warn(&pdev->dev, "Unable to attach sh_irda interrupt\n");
 		goto err_mem_4;
 	}
diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index ed7d7d6..d5575f7 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -761,7 +761,7 @@ static int __devinit sh_sir_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, ndev);
 
-	if (request_irq(irq, sh_sir_irq, IRQF_DISABLED, "sh_sir", self)) {
+	if (request_irq(irq, sh_sir_irq, 0, "sh_sir", self)) {
 		dev_warn(&pdev->dev, "Unable to attach sh_sir interrupt\n");
 		goto err_mem_4;
 	}
diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index 949c1f9..363d71c 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -84,7 +84,7 @@ static int jazzsonic_open(struct net_device* dev)
 {
 	int retval;
 
-	retval = request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED,
+	retval = request_irq(dev->irq, sonic_interrupt, 0,
 				"sonic", dev);
 	if (retval) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index 763844c..b78c4b9 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -1002,14 +1002,14 @@ static int korina_open(struct net_device *dev)
 	 * that handles the Done Finished
 	 * Ovr and Und Events */
 	ret = request_irq(lp->rx_irq, korina_rx_dma_interrupt,
-			IRQF_DISABLED, "Korina ethernet Rx", dev);
+			0, "Korina ethernet Rx", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get Rx DMA IRQ %d\n",
 		    dev->name, lp->rx_irq);
 		goto err_release;
 	}
 	ret = request_irq(lp->tx_irq, korina_tx_dma_interrupt,
-			IRQF_DISABLED, "Korina ethernet Tx", dev);
+			0, "Korina ethernet Tx", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get Tx DMA IRQ %d\n",
 		    dev->name, lp->tx_irq);
@@ -1018,7 +1018,7 @@ static int korina_open(struct net_device *dev)
 
 	/* Install handler for overrun error. */
 	ret = request_irq(lp->ovr_irq, korina_ovr_interrupt,
-			IRQF_DISABLED, "Ethernet Overflow", dev);
+			0, "Ethernet Overflow", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get OVR IRQ %d\n",
 		    dev->name, lp->ovr_irq);
@@ -1027,7 +1027,7 @@ static int korina_open(struct net_device *dev)
 
 	/* Install handler for underflow error. */
 	ret = request_irq(lp->und_irq, korina_und_interrupt,
-			IRQF_DISABLED, "Ethernet Underflow", dev);
+			0, "Ethernet Underflow", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get UND IRQ %d\n",
 		    dev->name, lp->und_irq);
diff --git a/drivers/net/ks8851_mll.c b/drivers/net/ks8851_mll.c
index d19c849..a6b427b 100644
--- a/drivers/net/ks8851_mll.c
+++ b/drivers/net/ks8851_mll.c
@@ -899,7 +899,7 @@ static int ks_net_open(struct net_device *netdev)
 	struct ks_net *ks = netdev_priv(netdev);
 	int err;
 
-#define	KS_INT_FLAGS	(IRQF_DISABLED|IRQF_TRIGGER_LOW)
+#define	KS_INT_FLAGS	(IRQF_TRIGGER_LOW)
 	/* lock the card, even if we may not actually do anything
 	 * else at the moment.
 	 */
diff --git a/drivers/net/lantiq_etop.c b/drivers/net/lantiq_etop.c
index 45f252b..4f69e57 100644
--- a/drivers/net/lantiq_etop.c
+++ b/drivers/net/lantiq_etop.c
@@ -280,7 +280,7 @@ ltq_etop_hw_init(struct net_device *dev)
 
 		if (IS_TX(i)) {
 			ltq_dma_alloc_tx(&ch->dma);
-			request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
+			request_irq(irq, ltq_etop_dma_irq, 0,
 				"etop_tx", priv);
 		} else if (IS_RX(i)) {
 			ltq_dma_alloc_rx(&ch->dma);
@@ -289,7 +289,7 @@ ltq_etop_hw_init(struct net_device *dev)
 				if (ltq_etop_alloc_skb(ch))
 					return -ENOMEM;
 			ch->dma.desc = 0;
-			request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
+			request_irq(irq, ltq_etop_dma_irq, 0,
 				"etop_rx", priv);
 		}
 		ch->dma.irq = irq;
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 9ec112c..dc58485 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1218,7 +1218,7 @@ static int pasemi_mac_open(struct net_device *dev)
 	snprintf(mac->tx_irq_name, sizeof(mac->tx_irq_name), "%s tx",
 		 dev->name);
 
-	ret = request_irq(mac->tx->chan.irq, pasemi_mac_tx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->tx->chan.irq, pasemi_mac_tx_intr, 0,
 			  mac->tx_irq_name, mac->tx);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
@@ -1229,7 +1229,7 @@ static int pasemi_mac_open(struct net_device *dev)
 	snprintf(mac->rx_irq_name, sizeof(mac->rx_irq_name), "%s rx",
 		 dev->name);
 
-	ret = request_irq(mac->rx->chan.irq, pasemi_mac_rx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->rx->chan.irq, pasemi_mac_rx_intr, 0,
 			  mac->rx_irq_name, mac->rx);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index d82a82d..aaa79f5 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1732,7 +1732,7 @@ static int __devinit ps3_gelic_driver_probe(struct ps3_system_bus_device *dev)
 		goto fail_alloc_irq;
 	}
 	result = request_irq(card->irq, gelic_card_interrupt,
-			     IRQF_DISABLED, netdev->name, card);
+			     0, netdev->name, card);
 
 	if (result) {
 		dev_info(ctodev(card), "%s:request_irq failed (%d)\n",
diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 1a3033d..8abc407 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -1131,7 +1131,7 @@ static int pxa168_eth_open(struct net_device *dev)
 	int err;
 
 	err = request_irq(dev->irq, pxa168_eth_int_handler,
-			  IRQF_DISABLED, dev->name, dev);
+			  0, dev->name, dev);
 	if (err) {
 		dev_printk(KERN_ERR, &dev->dev, "can't assign irq\n");
 		return -EAGAIN;
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 5f53fbb..e6319f5 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -271,7 +271,7 @@ static inline void mcf_outsw(void *a, unsigned char *p, int l)
 #define SMC_insw(a, r, p, l)	mcf_insw(a + r, p, l)
 #define SMC_outsw(a, r, p, l)	mcf_outsw(a + r, p, l)
 
-#define SMC_IRQ_FLAGS		(IRQF_DISABLED)
+#define SMC_IRQ_FLAGS		(0)
 
 #else
 
diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 459726f..25ae3f1 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1359,7 +1359,7 @@ static int smsc9420_open(struct net_device *dev)
 	smsc9420_reg_write(pd, INT_STAT, 0xFFFFFFFF);
 	smsc9420_pci_flush_write(pd);
 
-	if (request_irq(dev->irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
+	if (request_irq(dev->irq, smsc9420_isr, IRQF_SHARED,
 			DRV_NAME, pd)) {
 		smsc_warn(IFUP, "Unable to use IRQ = %d", dev->irq);
 		result = -ENODEV;
diff --git a/drivers/net/sun3lance.c b/drivers/net/sun3lance.c
index 7d9ec23..2a749a7 100644
--- a/drivers/net/sun3lance.c
+++ b/drivers/net/sun3lance.c
@@ -358,7 +358,7 @@ static int __init lance_probe( struct net_device *dev)
 
 	REGA(CSR0) = CSR0_STOP;
 
-	if (request_irq(LANCE_IRQ, lance_interrupt, IRQF_DISABLED, "SUN3 Lance", dev) < 0) {
+	if (request_irq(LANCE_IRQ, lance_interrupt, 0, "SUN3 Lance", dev) < 0) {
 #ifdef CONFIG_SUN3
 		iounmap((void __iomem *)ioaddr);
 #endif
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index 959b410..7b230b4 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1321,7 +1321,7 @@ de4x5_open(struct net_device *dev)
     if (request_irq(dev->irq, de4x5_interrupt, IRQF_SHARED,
 		                                     lp->adapter_name, dev)) {
 	printk("de4x5_open(): Requested IRQ%d is busy - attemping FAST/SHARE...", dev->irq);
-	if (request_irq(dev->irq, de4x5_interrupt, IRQF_DISABLED | IRQF_SHARED,
+	if (request_irq(dev->irq, de4x5_interrupt, IRQF_SHARED,
 			                             lp->adapter_name, dev)) {
 	    printk("\n              Cannot get IRQ- reconfigure your hardware.\n");
 	    disable_ast(dev);
diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index 3d80e42..3d74166 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -220,7 +220,7 @@ static struct z8530_dev *sv11_init(int iobase, int irq)
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
 
-	if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
+	if (request_irq(irq, z8530_interrupt, 0,
 			"Hostess SV11", sv) < 0) {
 		pr_warn("IRQ %d already in use\n", irq);
 		goto err_irq;
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 0b4fd05..6027e47 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -266,7 +266,7 @@ static __init struct slvl_board *slvl_init(int iobase, int irq,
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
 
-	if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
+	if (request_irq(irq, z8530_interrupt, 0,
 			"SeaLevel", dev) < 0) {
 		pr_warn("IRQ %d already in use\n", irq);
 		goto err_request_irq;
diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
index 6d9204fe..1ebc5e5 100644
--- a/drivers/net/wireless/p54/p54spi.c
+++ b/drivers/net/wireless/p54/p54spi.c
@@ -642,7 +642,7 @@ static int __devinit p54spi_probe(struct spi_device *spi)
 	gpio_direction_input(p54spi_gpio_irq);
 
 	ret = request_irq(gpio_to_irq(p54spi_gpio_irq),
-			  p54spi_interrupt, IRQF_DISABLED, "p54spi",
+			  p54spi_interrupt, 0, "p54spi",
 			  priv->spi);
 	if (ret < 0) {
 		dev_err(&priv->spi->dev, "request_irq() failed");
diff --git a/drivers/net/xtsonic.c b/drivers/net/xtsonic.c
index 9f12026..cc4876f 100644
--- a/drivers/net/xtsonic.c
+++ b/drivers/net/xtsonic.c
@@ -95,7 +95,7 @@ static int xtsonic_open(struct net_device *dev)
 {
 	int retval;
 
-	retval = request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED,
+	retval = request_irq(dev->irq, sonic_interrupt, 0,
 				"sonic", dev);
 	if (retval) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
diff --git a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
index 94c852d..1141747 100644
--- a/include/net/irda/irda_device.h
+++ b/include/net/irda/irda_device.h
@@ -162,7 +162,7 @@ typedef struct {
         int irq, irq2;        /* Interrupts used */
         int dma, dma2;        /* DMA channel(s) used */
         int fifo_size;        /* FIFO size */
-        int irqflags;         /* interrupt flags (ie, IRQF_SHARED|IRQF_DISABLED) */
+        int irqflags;         /* interrupt flags (ie, IRQF_SHARED) */
 	int direction;        /* Link direction, used by some FIR drivers */
 	int enabled;          /* Powered on? */
 	int suspended;        /* Suspended by APM */
-- 
1.7.4.1
