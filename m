From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Fri, 9 Aug 2013 15:15:39 +0200
Message-ID: <CA+MoWDrsHf4NFE_iszymh6SaBfXsMybC194ZQaKgURmCFwiJRQ@mail.gmail.com>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
	<20130808210918.GE5502@mwanda>
	<20130808.142054.1541424422807503741.davem@davemloft.net>
	<1375997625.2087.14.camel@joe-AO722>
	<520452F4.2070804@gmail.com>
	<1376015984.2087.31.camel@joe-AO722>
	<520457AD.9060508@gmail.com>
	<1376016864.2087.34.camel@joe-AO722>
	<52045B31.9000002@gmail.com>
	<1376018881.2087.48.camel@joe-AO722>
	<5204641C.3090905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>, emilio@elopez.com.ar,
	mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Kumar Gaurav <kumargauravgupta3@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <5204641C.3090905@gmail.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Kumar,


Coccinelle (http://coccinelle.lip6.fr/) can help you in this task. The
semantic patch below takes care of both cases for you:

@@
expression e;
@@
- IRQF_DISABLED | e
+ e

@@
@@
-IRQF_DISABLED
+0

When running it on drivers net, Coccinelle found:


diff -u -p a/hamradio/scc.c b/hamradio/scc.c
--- a/hamradio/scc.c
+++ b/hamradio/scc.c
@@ -1734,7 +1734,7 @@ static int scc_net_ioctl(struct net_devi
  if (!Ivec[hwcfg.irq].used && hwcfg.irq)
  {
  if (request_irq(hwcfg.irq, scc_isr,
- IRQF_DISABLED, "AX.25 SCC",
+ 0, "AX.25 SCC",
  (void *)(long) hwcfg.irq))
  printk(KERN_WARNING "z8530drv: warning, cannot get IRQ %d\n", hwcfg.irq);
  else
diff -u -p a/hamradio/baycom_ser_hdx.c b/hamradio/baycom_ser_hdx.c
--- a/hamradio/baycom_ser_hdx.c
+++ b/hamradio/baycom_ser_hdx.c
@@ -490,7 +490,7 @@ static int ser12_open(struct net_device
  outb(0, FCR(dev->base_addr));  /* disable FIFOs */
  outb(0x0d, MCR(dev->base_addr));
  outb(0, IER(dev->base_addr));
- if (request_irq(dev->irq, ser12_interrupt, IRQF_DISABLED | IRQF_SHARED,
+ if (request_irq(dev->irq, ser12_interrupt, IRQF_SHARED,
  "baycom_ser12", dev)) {
  release_region(dev->base_addr, SER12_EXTENT);
  return -EBUSY;
diff -u -p a/hamradio/baycom_ser_fdx.c b/hamradio/baycom_ser_fdx.c
--- a/hamradio/baycom_ser_fdx.c
+++ b/hamradio/baycom_ser_fdx.c
@@ -445,7 +445,7 @@ static int ser12_open(struct net_device
  outb(0, FCR(dev->base_addr));  /* disable FIFOs */
  outb(0x0d, MCR(dev->base_addr));
  outb(0, IER(dev->base_addr));
- if (request_irq(dev->irq, ser12_interrupt, IRQF_DISABLED | IRQF_SHARED,
+ if (request_irq(dev->irq, ser12_interrupt, IRQF_SHARED,
  "baycom_ser_fdx", dev)) {
  release_region(dev->base_addr, SER12_EXTENT);
  return -EBUSY;
diff -u -p a/hamradio/yam.c b/hamradio/yam.c
--- a/hamradio/yam.c
+++ b/hamradio/yam.c
@@ -888,7 +888,7 @@ static int yam_open(struct net_device *d
  goto out_release_base;
  }
  outb(0, IER(dev->base_addr));
- if (request_irq(dev->irq, yam_interrupt, IRQF_DISABLED |
IRQF_SHARED, dev->name, dev)) {
+ if (request_irq(dev->irq, yam_interrupt, IRQF_SHARED, dev->name, dev)) {
  printk(KERN_ERR "%s: irq %d busy\n", dev->name, dev->irq);
  ret = -EBUSY;
  goto out_release_base;
diff -u -p a/wireless/p54/p54spi.c b/wireless/p54/p54spi.c
--- a/wireless/p54/p54spi.c
+++ b/wireless/p54/p54spi.c
@@ -636,7 +636,7 @@ static int p54spi_probe(struct spi_devic
  gpio_direction_input(p54spi_gpio_irq);

  ret = request_irq(gpio_to_irq(p54spi_gpio_irq),
-  p54spi_interrupt, IRQF_DISABLED, "p54spi",
+  p54spi_interrupt, 0, "p54spi",
   priv->spi);
  if (ret < 0) {
  dev_err(&priv->spi->dev, "request_irq() failed");
diff -u -p a/wan/hostess_sv11.c b/wan/hostess_sv11.c
--- a/wan/hostess_sv11.c
+++ b/wan/hostess_sv11.c
@@ -220,7 +220,7 @@ static struct z8530_dev *sv11_init(int i
  /* We want a fast IRQ for this device. Actually we'd like an even faster
    IRQ ;) - This is one driver RtLinux is made for */

- if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
+ if (request_irq(irq, z8530_interrupt, 0,
  "Hostess SV11", sv) < 0) {
  pr_warn("IRQ %d already in use\n", irq);
  goto err_irq;
diff -u -p a/wan/sealevel.c b/wan/sealevel.c
--- a/wan/sealevel.c
+++ b/wan/sealevel.c
@@ -266,7 +266,7 @@ static __init struct slvl_board *slvl_in
  /* We want a fast IRQ for this device. Actually we'd like an even faster
    IRQ ;) - This is one driver RtLinux is made for */

- if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
+ if (request_irq(irq, z8530_interrupt, 0,
  "SeaLevel", dev) < 0) {
  pr_warn("IRQ %d already in use\n", irq);
  goto err_request_irq;
diff -u -p a/ethernet/natsemi/xtsonic.c b/ethernet/natsemi/xtsonic.c
--- a/ethernet/natsemi/xtsonic.c
+++ b/ethernet/natsemi/xtsonic.c
@@ -95,7 +95,7 @@ static int xtsonic_open(struct net_devic
 {
  int retval;

- retval = request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED,
+ retval = request_irq(dev->irq, sonic_interrupt, 0,
  "sonic", dev);
  if (retval) {
  printk(KERN_ERR "%s: unable to get IRQ %d.\n",
diff -u -p a/ethernet/natsemi/jazzsonic.c b/ethernet/natsemi/jazzsonic.c
--- a/ethernet/natsemi/jazzsonic.c
+++ b/ethernet/natsemi/jazzsonic.c
@@ -83,7 +83,7 @@ static int jazzsonic_open(struct net_dev
 {
  int retval;

- retval = request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED,
+ retval = request_irq(dev->irq, sonic_interrupt, 0,
  "sonic", dev);
  if (retval) {
  printk(KERN_ERR "%s: unable to get IRQ %d.\n",
diff -u -p a/ethernet/smsc/smsc9420.c b/ethernet/smsc/smsc9420.c
--- a/ethernet/smsc/smsc9420.c
+++ b/ethernet/smsc/smsc9420.c
@@ -1356,7 +1356,7 @@ static int smsc9420_open(struct net_devi
  smsc9420_reg_write(pd, INT_STAT, 0xFFFFFFFF);
  smsc9420_pci_flush_write(pd);

- result = request_irq(irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
+ result = request_irq(irq, smsc9420_isr, IRQF_SHARED,
      DRV_NAME, pd);
  if (result) {
  smsc_warn(IFUP, "Unable to use IRQ = %d", irq);
diff -u -p a/ethernet/marvell/pxa168_eth.c b/ethernet/marvell/pxa168_eth.c
--- a/ethernet/marvell/pxa168_eth.c
+++ b/ethernet/marvell/pxa168_eth.c
@@ -1125,7 +1125,7 @@ static int pxa168_eth_open(struct net_de
  int err;

  err = request_irq(dev->irq, pxa168_eth_int_handler,
-  IRQF_DISABLED, dev->name, dev);
+  0, dev->name, dev);
  if (err) {
  dev_err(&dev->dev, "can't assign irq\n");
  return -EAGAIN;
diff -u -p a/ethernet/pasemi/pasemi_mac.c b/ethernet/pasemi/pasemi_mac.c
--- a/ethernet/pasemi/pasemi_mac.c
+++ b/ethernet/pasemi/pasemi_mac.c
@@ -1220,7 +1220,7 @@ static int pasemi_mac_open(struct net_de
  snprintf(mac->tx_irq_name, sizeof(mac->tx_irq_name), "%s tx",
  dev->name);

- ret = request_irq(mac->tx->chan.irq, pasemi_mac_tx_intr, IRQF_DISABLED,
+ ret = request_irq(mac->tx->chan.irq, pasemi_mac_tx_intr, 0,
   mac->tx_irq_name, mac->tx);
  if (ret) {
  dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
@@ -1231,7 +1231,7 @@ static int pasemi_mac_open(struct net_de
  snprintf(mac->rx_irq_name, sizeof(mac->rx_irq_name), "%s rx",
  dev->name);

- ret = request_irq(mac->rx->chan.irq, pasemi_mac_rx_intr, IRQF_DISABLED,
+ ret = request_irq(mac->rx->chan.irq, pasemi_mac_rx_intr, 0,
   mac->rx_irq_name, mac->rx);
  if (ret) {
  dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
diff -u -p a/ethernet/ibm/ehea/ehea_main.c b/ethernet/ibm/ehea/ehea_main.c
--- a/ethernet/ibm/ehea/ehea_main.c
+++ b/ethernet/ibm/ehea/ehea_main.c
@@ -1297,7 +1297,7 @@ static int ehea_reg_interrupts(struct ne

  ret = ibmebus_request_irq(port->qp_eq->attr.ist1,
   ehea_qp_aff_irq_handler,
-  IRQF_DISABLED, port->int_aff_name, port);
+  0, port->int_aff_name, port);
  if (ret) {
  netdev_err(dev, "failed registering irq for qp_aff_irq_handler:ist=%X\n",
    port->qp_eq->attr.ist1);
@@ -1315,7 +1315,7 @@ static int ehea_reg_interrupts(struct ne
  "%s-queue%d", dev->name, i);
  ret = ibmebus_request_irq(pr->eq->attr.ist1,
   ehea_recv_irq_handler,
-  IRQF_DISABLED, pr->int_send_name,
+  0, pr->int_send_name,
   pr);
  if (ret) {
  netdev_err(dev, "failed registering irq for ehea_queue
port_res_nr:%d, ist=%X\n",
@@ -3332,7 +3332,7 @@ static int ehea_probe_adapter(struct pla
  }

  ret = ibmebus_request_irq(adapter->neq->attr.ist1,
-  ehea_interrupt_neq, IRQF_DISABLED,
+  ehea_interrupt_neq, 0,
   "ehea_neq", adapter);
  if (ret) {
  dev_err(&dev->dev, "requesting NEQ IRQ failed\n");
diff -u -p a/ethernet/toshiba/ps3_gelic_net.c b/ethernet/toshiba/ps3_gelic_net.c
--- a/ethernet/toshiba/ps3_gelic_net.c
+++ b/ethernet/toshiba/ps3_gelic_net.c
@@ -1727,7 +1727,7 @@ static int ps3_gelic_driver_probe(struct
  goto fail_alloc_irq;
  }
  result = request_irq(card->irq, gelic_card_interrupt,
-     IRQF_DISABLED, netdev->name, card);
+     0, netdev->name, card);

  if (result) {
  dev_info(ctodev(card), "%s:request_irq failed (%d)\n",
diff -u -p a/ethernet/lantiq_etop.c b/ethernet/lantiq_etop.c
--- a/ethernet/lantiq_etop.c
+++ b/ethernet/lantiq_etop.c
@@ -282,7 +282,7 @@ ltq_etop_hw_init(struct net_device *dev)

  if (IS_TX(i)) {
  ltq_dma_alloc_tx(&ch->dma);
- request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
+ request_irq(irq, ltq_etop_dma_irq, 0,
  "etop_tx", priv);
  } else if (IS_RX(i)) {
  ltq_dma_alloc_rx(&ch->dma);
@@ -291,7 +291,7 @@ ltq_etop_hw_init(struct net_device *dev)
  if (ltq_etop_alloc_skb(ch))
  return -ENOMEM;
  ch->dma.desc = 0;
- request_irq(irq, ltq_etop_dma_irq, IRQF_DISABLED,
+ request_irq(irq, ltq_etop_dma_irq, 0,
  "etop_rx", priv);
  }
  ch->dma.irq = irq;
diff -u -p a/ethernet/hp/hp100.c b/ethernet/hp/hp100.c
--- a/ethernet/hp/hp100.c
+++ b/ethernet/hp/hp100.c
@@ -1097,7 +1097,7 @@ static int hp100_open(struct net_device
  /* New: if bus is PCI or EISA, interrupts might be shared interrupts */
  if (request_irq(dev->irq, hp100_interrupt,
  lp->bus == HP100_BUS_PCI || lp->bus ==
- HP100_BUS_EISA ? IRQF_SHARED : IRQF_DISABLED,
+ HP100_BUS_EISA ? IRQF_SHARED : 0,
  "hp100", dev)) {
  printk("hp100: %s: unable to get IRQ %d\n", dev->name, dev->irq);
  return -EAGAIN;
diff -u -p a/ethernet/broadcom/bcm63xx_enet.c b/ethernet/broadcom/bcm63xx_enet.c
--- a/ethernet/broadcom/bcm63xx_enet.c
+++ b/ethernet/broadcom/bcm63xx_enet.c
@@ -926,13 +926,13 @@ static int bcm_enet_open(struct net_devi
  if (ret)
  goto out_phy_disconnect;

- ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, IRQF_DISABLED,
+ ret = request_irq(priv->irq_rx, bcm_enet_isr_dma, 0,
   dev->name, dev);
  if (ret)
  goto out_freeirq;

  ret = request_irq(priv->irq_tx, bcm_enet_isr_dma,
-  IRQF_DISABLED, dev->name, dev);
+  0, dev->name, dev);
  if (ret)
  goto out_freeirq_rx;

@@ -2158,13 +2158,13 @@ static int bcm_enetsw_open(struct net_de
  enet_dmac_writel(priv, 0, ENETDMAC_IRMASK, priv->tx_chan);

  ret = request_irq(priv->irq_rx, bcm_enet_isr_dma,
-  IRQF_DISABLED, dev->name, dev);
+  0, dev->name, dev);
  if (ret)
  goto out_freeirq;

  if (priv->irq_tx != -1) {
  ret = request_irq(priv->irq_tx, bcm_enet_isr_dma,
-  IRQF_DISABLED, dev->name, dev);
+  0, dev->name, dev);
  if (ret)
  goto out_freeirq_rx;
  }
diff -u -p a/ethernet/korina.c b/ethernet/korina.c
--- a/ethernet/korina.c
+++ b/ethernet/korina.c
@@ -996,14 +996,14 @@ static int korina_open(struct net_device
  * that handles the Done Finished
  * Ovr and Und Events */
  ret = request_irq(lp->rx_irq, korina_rx_dma_interrupt,
- IRQF_DISABLED, "Korina ethernet Rx", dev);
+ 0, "Korina ethernet Rx", dev);
  if (ret < 0) {
  printk(KERN_ERR "%s: unable to get Rx DMA IRQ %d\n",
     dev->name, lp->rx_irq);
  goto err_release;
  }
  ret = request_irq(lp->tx_irq, korina_tx_dma_interrupt,
- IRQF_DISABLED, "Korina ethernet Tx", dev);
+ 0, "Korina ethernet Tx", dev);
  if (ret < 0) {
  printk(KERN_ERR "%s: unable to get Tx DMA IRQ %d\n",
     dev->name, lp->tx_irq);
@@ -1012,7 +1012,7 @@ static int korina_open(struct net_device

  /* Install handler for overrun error. */
  ret = request_irq(lp->ovr_irq, korina_ovr_interrupt,
- IRQF_DISABLED, "Ethernet Overflow", dev);
+ 0, "Ethernet Overflow", dev);
  if (ret < 0) {
  printk(KERN_ERR "%s: unable to get OVR IRQ %d\n",
     dev->name, lp->ovr_irq);
@@ -1021,7 +1021,7 @@ static int korina_open(struct net_device

  /* Install handler for underflow error. */
  ret = request_irq(lp->und_irq, korina_und_interrupt,
- IRQF_DISABLED, "Ethernet Underflow", dev);
+ 0, "Ethernet Underflow", dev);
  if (ret < 0) {
  printk(KERN_ERR "%s: unable to get UND IRQ %d\n",
     dev->name, lp->und_irq);
diff -u -p a/ethernet/amd/sun3lance.c b/ethernet/amd/sun3lance.c
--- a/ethernet/amd/sun3lance.c
+++ b/ethernet/amd/sun3lance.c
@@ -358,7 +358,7 @@ static int __init lance_probe( struct ne

  REGA(CSR0) = CSR0_STOP;

- if (request_irq(LANCE_IRQ, lance_interrupt, IRQF_DISABLED, "SUN3
Lance", dev) < 0) {
+ if (request_irq(LANCE_IRQ, lance_interrupt, 0, "SUN3 Lance", dev) < 0) {
 #ifdef CONFIG_SUN3
  iounmap((void __iomem *)ioaddr);
 #endif
diff -u -p a/ethernet/dec/tulip/de4x5.c b/ethernet/dec/tulip/de4x5.c
--- a/ethernet/dec/tulip/de4x5.c
+++ b/ethernet/dec/tulip/de4x5.c
@@ -1321,7 +1321,7 @@ de4x5_open(struct net_device *dev)
     if (request_irq(dev->irq, de4x5_interrupt, IRQF_SHARED,
                                      lp->adapter_name, dev)) {
  printk("de4x5_open(): Requested IRQ%d is busy - attemping
FAST/SHARE...", dev->irq);
- if (request_irq(dev->irq, de4x5_interrupt, IRQF_DISABLED | IRQF_SHARED,
+ if (request_irq(dev->irq, de4x5_interrupt, IRQF_SHARED,
                              lp->adapter_name, dev)) {
     printk("\n              Cannot get IRQ- reconfigure your hardware.\n");
     disable_ast(dev);
diff -u -p a/ethernet/freescale/fec_main.c b/ethernet/freescale/fec_main.c
--- a/ethernet/freescale/fec_main.c
+++ b/ethernet/freescale/fec_main.c
@@ -2173,7 +2173,7 @@ fec_probe(struct platform_device *pdev)
  goto failed_irq;
  }
  ret = devm_request_irq(&pdev->dev, irq, fec_enet_interrupt,
-       IRQF_DISABLED, pdev->name, ndev);
+       0, pdev->name, ndev);
  if (ret)
  goto failed_irq;
  }
diff -u -p a/ethernet/adi/bfin_mac.c b/ethernet/adi/bfin_mac.c
--- a/ethernet/adi/bfin_mac.c
+++ b/ethernet/adi/bfin_mac.c
@@ -530,7 +530,7 @@ static int bfin_mac_ethtool_setwol(struc
  if (lp->wol && !lp->irq_wake_requested) {
  /* register wake irq handler */
  rc = request_irq(IRQ_MAC_WAKEDET, bfin_mac_wake_interrupt,
- IRQF_DISABLED, "EMAC_WAKE", dev);
+ 0, "EMAC_WAKE", dev);
  if (rc)
  return rc;
  lp->irq_wake_requested = true;
@@ -1686,7 +1686,7 @@ static int bfin_mac_probe(struct platfor
  /* now, enable interrupts */
  /* register irq handler */
  rc = request_irq(IRQ_MAC_RX, bfin_mac_interrupt,
- IRQF_DISABLED, "EMAC_RX", ndev);
+ 0, "EMAC_RX", ndev);
  if (rc) {
  dev_err(&pdev->dev, "Cannot request Blackfin MAC RX IRQ!\n");
  rc = -EBUSY;
diff -u -p a/irda/bfin_sir.c b/irda/bfin_sir.c
--- a/irda/bfin_sir.c
+++ b/irda/bfin_sir.c
@@ -411,12 +411,12 @@ static int bfin_sir_startup(struct bfin_

 #else

- if (request_irq(port->irq, bfin_sir_rx_int, IRQF_DISABLED,
"BFIN_SIR_RX", dev)) {
+ if (request_irq(port->irq, bfin_sir_rx_int, 0, "BFIN_SIR_RX", dev)) {
  dev_warn(&dev->dev, "Unable to attach SIR RX interrupt\n");
  return -EBUSY;
  }

- if (request_irq(port->irq+1, bfin_sir_tx_int, IRQF_DISABLED,
"BFIN_SIR_TX", dev)) {
+ if (request_irq(port->irq+1, bfin_sir_tx_int, 0, "BFIN_SIR_TX", dev)) {
  dev_warn(&dev->dev, "Unable to attach SIR TX interrupt\n");
  free_irq(port->irq, dev);
  return -EBUSY;
diff -u -p a/irda/sh_irda.c b/irda/sh_irda.c
--- a/irda/sh_irda.c
+++ b/irda/sh_irda.c
@@ -804,7 +804,7 @@ static int sh_irda_probe(struct platform
  goto err_mem_4;

  platform_set_drvdata(pdev, ndev);
- err = request_irq(irq, sh_irda_irq, IRQF_DISABLED, "sh_irda", self);
+ err = request_irq(irq, sh_irda_irq, 0, "sh_irda", self);
  if (err) {
  dev_warn(&pdev->dev, "Unable to attach sh_irda interrupt\n");
  goto err_mem_4;
diff -u -p a/irda/sh_sir.c b/irda/sh_sir.c
--- a/irda/sh_sir.c
+++ b/irda/sh_sir.c
@@ -761,7 +761,7 @@ static int sh_sir_probe(struct platform_
  goto err_mem_4;

  platform_set_drvdata(pdev, ndev);
- err = request_irq(irq, sh_sir_irq, IRQF_DISABLED, "sh_sir", self);
+ err = request_irq(irq, sh_sir_irq, 0, "sh_sir", self);
  if (err) {
  dev_warn(&pdev->dev, "Unable to attach sh_sir interrupt\n");
  goto err_mem_4;
diff -u -p a/irda/donauboe.c b/irda/donauboe.c
--- a/irda/donauboe.c
+++ b/irda/donauboe.c
@@ -1352,7 +1352,7 @@ toshoboe_net_open (struct net_device *de
     return 0;

   rc = request_irq (self->io.irq, toshoboe_interrupt,
-                    IRQF_SHARED | IRQF_DISABLED, dev->name, self);
+                    IRQF_SHARED, dev->name, self);
   if (rc)
    return rc;

@@ -1559,7 +1559,7 @@ toshoboe_open (struct pci_dev *pci_dev,
   self->io.fir_base = self->base;
   self->io.fir_ext = OBOE_IO_EXTENT;
   self->io.irq = pci_dev->irq;
-  self->io.irqflags = IRQF_SHARED | IRQF_DISABLED;
+  self->io.irqflags = IRQF_SHARED;

   self->speed = self->io.speed = 9600;
   self->async = 0;

On Fri, Aug 9, 2013 at 5:38 AM, Kumar Gaurav
<kumargauravgupta3@gmail.com> wrote:
> On Friday 09 August 2013 08:58 AM, Joe Perches wrote:
>>
>> On Fri, 2013-08-09 at 08:30 +0530, Kumar Gaurav wrote:
>>>
>>> On Friday 09 August 2013 08:24 AM, Joe Perches wrote:
>>>>
>>>> On Fri, 2013-08-09 at 08:15 +0530, Kumar Gaurav wrote:
>>>>>
>>>>> On Friday 09 August 2013 08:09 AM, Joe Perches wrote:
>>>>
>>>> []
>>>>>>
>>>>>> And, maybe it'd be better to use IRQF_TRIGGER_NONE
>>>>>> instead of 0.
>>>>>
>>>>> I tried googling what to replace IRQF_DISABLED with but found nothing.
>>>>> In the patch fixed earlier (not by me) it was replaced with 0 so i did
>>>>> same. But from now on I'll use IRQF_TRIGGER_NONE. Thanks
>>>>
>>>> Maybe that's not the right thing to do.
>>>> 0 is what's almost exclusively used.
>>>> IRQF_TRIGGER_NONE is only used a few times.
>>>> It's also a lot longer.
>>>>
>>> Sorry to poke back. But just want to confirm. I should use
>>> IRQF_TRIGGER_NONE and not 0 right?
>>
>> Hi again Kumar.
>>
>> There's no rush to submit these sorts of patches.
>> Nothing is going to really be improved because of these
>> changes.
>>
>> Submit an overall rfc patch description to the various
>> mailing lists (affected MAINTAINERS generally don't read
>> lkml but do read their specific mailing list) with options
>> like 0 or IRQF_TRIGGER_NONE to show what the issues are
>> and why you're doing this.
>>
>> Wait at least a week for any comment.
>>
>> You'll likely get some "useless churn" emails.
>> You can generally ignore those.
>>
>> If you get any real comments, deal with them.
>>
>> Then after at least that week passes, submit the patches.
>>
>> cheers, Joe
>>
> Will surely follow that thanks :)
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Peter
