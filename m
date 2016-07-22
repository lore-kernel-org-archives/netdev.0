From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] net: davinci_cpdma: remove excessive dump of register values to kernel log
Date: Fri, 22 Jul 2016 21:58:54 +0200
Message-ID: <1469217534-6232-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:60811 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754308AbcGVT7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 15:59:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Such a big dump of register values is hardly useful on a production
system.

Another downside of the now removed functions is that calling
emac_dump_regs resulted in at least 87 calls to dev_info while holding =
a
spinlock and having irqs off which is a big source of latency.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 119 ------------------------=
--------
 drivers/net/ethernet/ti/davinci_cpdma.h |   2 -
 drivers/net/ethernet/ti/davinci_emac.c  |  96 ------------------------=
--
 3 files changed, 217 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethe=
rnet/ti/davinci_cpdma.c
index b7902bb74deb..4eee86397f29 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -357,77 +357,6 @@ int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr)
 }
 EXPORT_SYMBOL_GPL(cpdma_ctlr_stop);
=20
-int cpdma_ctlr_dump(struct cpdma_ctlr *ctlr)
-{
-	struct device *dev =3D ctlr->dev;
-	unsigned long flags;
-	int i;
-
-	spin_lock_irqsave(&ctlr->lock, flags);
-
-	dev_info(dev, "CPDMA: state: %s", cpdma_state_str[ctlr->state]);
-
-	dev_info(dev, "CPDMA: txidver: %x",
-		 dma_reg_read(ctlr, CPDMA_TXIDVER));
-	dev_info(dev, "CPDMA: txcontrol: %x",
-		 dma_reg_read(ctlr, CPDMA_TXCONTROL));
-	dev_info(dev, "CPDMA: txteardown: %x",
-		 dma_reg_read(ctlr, CPDMA_TXTEARDOWN));
-	dev_info(dev, "CPDMA: rxidver: %x",
-		 dma_reg_read(ctlr, CPDMA_RXIDVER));
-	dev_info(dev, "CPDMA: rxcontrol: %x",
-		 dma_reg_read(ctlr, CPDMA_RXCONTROL));
-	dev_info(dev, "CPDMA: softreset: %x",
-		 dma_reg_read(ctlr, CPDMA_SOFTRESET));
-	dev_info(dev, "CPDMA: rxteardown: %x",
-		 dma_reg_read(ctlr, CPDMA_RXTEARDOWN));
-	dev_info(dev, "CPDMA: txintstatraw: %x",
-		 dma_reg_read(ctlr, CPDMA_TXINTSTATRAW));
-	dev_info(dev, "CPDMA: txintstatmasked: %x",
-		 dma_reg_read(ctlr, CPDMA_TXINTSTATMASKED));
-	dev_info(dev, "CPDMA: txintmaskset: %x",
-		 dma_reg_read(ctlr, CPDMA_TXINTMASKSET));
-	dev_info(dev, "CPDMA: txintmaskclear: %x",
-		 dma_reg_read(ctlr, CPDMA_TXINTMASKCLEAR));
-	dev_info(dev, "CPDMA: macinvector: %x",
-		 dma_reg_read(ctlr, CPDMA_MACINVECTOR));
-	dev_info(dev, "CPDMA: maceoivector: %x",
-		 dma_reg_read(ctlr, CPDMA_MACEOIVECTOR));
-	dev_info(dev, "CPDMA: rxintstatraw: %x",
-		 dma_reg_read(ctlr, CPDMA_RXINTSTATRAW));
-	dev_info(dev, "CPDMA: rxintstatmasked: %x",
-		 dma_reg_read(ctlr, CPDMA_RXINTSTATMASKED));
-	dev_info(dev, "CPDMA: rxintmaskset: %x",
-		 dma_reg_read(ctlr, CPDMA_RXINTMASKSET));
-	dev_info(dev, "CPDMA: rxintmaskclear: %x",
-		 dma_reg_read(ctlr, CPDMA_RXINTMASKCLEAR));
-	dev_info(dev, "CPDMA: dmaintstatraw: %x",
-		 dma_reg_read(ctlr, CPDMA_DMAINTSTATRAW));
-	dev_info(dev, "CPDMA: dmaintstatmasked: %x",
-		 dma_reg_read(ctlr, CPDMA_DMAINTSTATMASKED));
-	dev_info(dev, "CPDMA: dmaintmaskset: %x",
-		 dma_reg_read(ctlr, CPDMA_DMAINTMASKSET));
-	dev_info(dev, "CPDMA: dmaintmaskclear: %x",
-		 dma_reg_read(ctlr, CPDMA_DMAINTMASKCLEAR));
-
-	if (!ctlr->params.has_ext_regs) {
-		dev_info(dev, "CPDMA: dmacontrol: %x",
-			 dma_reg_read(ctlr, CPDMA_DMACONTROL));
-		dev_info(dev, "CPDMA: dmastatus: %x",
-			 dma_reg_read(ctlr, CPDMA_DMASTATUS));
-		dev_info(dev, "CPDMA: rxbuffofs: %x",
-			 dma_reg_read(ctlr, CPDMA_RXBUFFOFS));
-	}
-
-	for (i =3D 0; i < ARRAY_SIZE(ctlr->channels); i++)
-		if (ctlr->channels[i])
-			cpdma_chan_dump(ctlr->channels[i]);
-
-	spin_unlock_irqrestore(&ctlr->lock, flags);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(cpdma_ctlr_dump);
-
 int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 {
 	unsigned long flags;
@@ -569,54 +498,6 @@ int cpdma_chan_get_stats(struct cpdma_chan *chan,
 }
 EXPORT_SYMBOL_GPL(cpdma_chan_get_stats);
=20
-int cpdma_chan_dump(struct cpdma_chan *chan)
-{
-	unsigned long flags;
-	struct device *dev =3D chan->ctlr->dev;
-
-	spin_lock_irqsave(&chan->lock, flags);
-
-	dev_info(dev, "channel %d (%s %d) state %s",
-		 chan->chan_num, is_rx_chan(chan) ? "rx" : "tx",
-		 chan_linear(chan), cpdma_state_str[chan->state]);
-	dev_info(dev, "\thdp: %x\n", chan_read(chan, hdp));
-	dev_info(dev, "\tcp: %x\n", chan_read(chan, cp));
-	if (chan->rxfree) {
-		dev_info(dev, "\trxfree: %x\n",
-			 chan_read(chan, rxfree));
-	}
-
-	dev_info(dev, "\tstats head_enqueue: %d\n",
-		 chan->stats.head_enqueue);
-	dev_info(dev, "\tstats tail_enqueue: %d\n",
-		 chan->stats.tail_enqueue);
-	dev_info(dev, "\tstats pad_enqueue: %d\n",
-		 chan->stats.pad_enqueue);
-	dev_info(dev, "\tstats misqueued: %d\n",
-		 chan->stats.misqueued);
-	dev_info(dev, "\tstats desc_alloc_fail: %d\n",
-		 chan->stats.desc_alloc_fail);
-	dev_info(dev, "\tstats pad_alloc_fail: %d\n",
-		 chan->stats.pad_alloc_fail);
-	dev_info(dev, "\tstats runt_receive_buff: %d\n",
-		 chan->stats.runt_receive_buff);
-	dev_info(dev, "\tstats runt_transmit_buff: %d\n",
-		 chan->stats.runt_transmit_buff);
-	dev_info(dev, "\tstats empty_dequeue: %d\n",
-		 chan->stats.empty_dequeue);
-	dev_info(dev, "\tstats busy_dequeue: %d\n",
-		 chan->stats.busy_dequeue);
-	dev_info(dev, "\tstats good_dequeue: %d\n",
-		 chan->stats.good_dequeue);
-	dev_info(dev, "\tstats requeue: %d\n",
-		 chan->stats.requeue);
-	dev_info(dev, "\tstats teardown_dequeue: %d\n",
-		 chan->stats.teardown_dequeue);
-
-	spin_unlock_irqrestore(&chan->lock, flags);
-	return 0;
-}
-
 static void __cpdma_chan_submit(struct cpdma_chan *chan,
 				struct cpdma_desc __iomem *desc)
 {
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethe=
rnet/ti/davinci_cpdma.h
index 80c015cbbce5..4b46cd6e9a3f 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -77,7 +77,6 @@ struct cpdma_ctlr *cpdma_ctlr_create(struct cpdma_par=
ams *params);
 int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr);
 int cpdma_ctlr_start(struct cpdma_ctlr *ctlr);
 int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr);
-int cpdma_ctlr_dump(struct cpdma_ctlr *ctlr);
=20
 struct cpdma_chan *cpdma_chan_create(struct cpdma_ctlr *ctlr, int chan=
_num,
 				     cpdma_handler_fn handler);
@@ -85,7 +84,6 @@ int cpdma_chan_get_rx_buf_num(struct cpdma_ctlr *ctlr=
);
 int cpdma_chan_destroy(struct cpdma_chan *chan);
 int cpdma_chan_start(struct cpdma_chan *chan);
 int cpdma_chan_stop(struct cpdma_chan *chan);
-int cpdma_chan_dump(struct cpdma_chan *chan);
=20
 int cpdma_chan_get_stats(struct cpdma_chan *chan,
 			 struct cpdma_chan_stats *stats);
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ether=
net/ti/davinci_emac.c
index c6c54659f8d4..6e305a82ed43 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -379,97 +379,6 @@ static char *emac_rxhost_errcodes[16] =3D {
 #define emac_ctrl_write(reg, val) iowrite32(val, (priv->ctrl_base + (r=
eg)))
=20
 /**
- * emac_dump_regs - Dump important EMAC registers to debug terminal
- * @priv: The DaVinci EMAC private adapter structure
- *
- * Executes ethtool set cmd & sets phy mode
- *
- */
-static void emac_dump_regs(struct emac_priv *priv)
-{
-	struct device *emac_dev =3D &priv->ndev->dev;
-
-	/* Print important registers in EMAC */
-	dev_info(emac_dev, "EMAC Basic registers\n");
-	if (priv->version =3D=3D EMAC_VERSION_1) {
-		dev_info(emac_dev, "EMAC: EWCTL: %08X, EWINTTCNT: %08X\n",
-			emac_ctrl_read(EMAC_CTRL_EWCTL),
-			emac_ctrl_read(EMAC_CTRL_EWINTTCNT));
-	}
-	dev_info(emac_dev, "EMAC: EmuControl:%08X, FifoControl: %08X\n",
-		emac_read(EMAC_EMCONTROL), emac_read(EMAC_FIFOCONTROL));
-	dev_info(emac_dev, "EMAC: MBPEnable:%08X, RXUnicastSet: %08X, "\
-		"RXMaxLen=3D%08X\n", emac_read(EMAC_RXMBPENABLE),
-		emac_read(EMAC_RXUNICASTSET), emac_read(EMAC_RXMAXLEN));
-	dev_info(emac_dev, "EMAC: MacControl:%08X, MacStatus: %08X, "\
-		"MacConfig=3D%08X\n", emac_read(EMAC_MACCONTROL),
-		emac_read(EMAC_MACSTATUS), emac_read(EMAC_MACCONFIG));
-	dev_info(emac_dev, "EMAC Statistics\n");
-	dev_info(emac_dev, "EMAC: rx_good_frames:%d\n",
-		emac_read(EMAC_RXGOODFRAMES));
-	dev_info(emac_dev, "EMAC: rx_broadcast_frames:%d\n",
-		emac_read(EMAC_RXBCASTFRAMES));
-	dev_info(emac_dev, "EMAC: rx_multicast_frames:%d\n",
-		emac_read(EMAC_RXMCASTFRAMES));
-	dev_info(emac_dev, "EMAC: rx_pause_frames:%d\n",
-		emac_read(EMAC_RXPAUSEFRAMES));
-	dev_info(emac_dev, "EMAC: rx_crcerrors:%d\n",
-		emac_read(EMAC_RXCRCERRORS));
-	dev_info(emac_dev, "EMAC: rx_align_code_errors:%d\n",
-		emac_read(EMAC_RXALIGNCODEERRORS));
-	dev_info(emac_dev, "EMAC: rx_oversized_frames:%d\n",
-		emac_read(EMAC_RXOVERSIZED));
-	dev_info(emac_dev, "EMAC: rx_jabber_frames:%d\n",
-		emac_read(EMAC_RXJABBER));
-	dev_info(emac_dev, "EMAC: rx_undersized_frames:%d\n",
-		emac_read(EMAC_RXUNDERSIZED));
-	dev_info(emac_dev, "EMAC: rx_fragments:%d\n",
-		emac_read(EMAC_RXFRAGMENTS));
-	dev_info(emac_dev, "EMAC: rx_filtered_frames:%d\n",
-		emac_read(EMAC_RXFILTERED));
-	dev_info(emac_dev, "EMAC: rx_qos_filtered_frames:%d\n",
-		emac_read(EMAC_RXQOSFILTERED));
-	dev_info(emac_dev, "EMAC: rx_octets:%d\n",
-		emac_read(EMAC_RXOCTETS));
-	dev_info(emac_dev, "EMAC: tx_goodframes:%d\n",
-		emac_read(EMAC_TXGOODFRAMES));
-	dev_info(emac_dev, "EMAC: tx_bcastframes:%d\n",
-		emac_read(EMAC_TXBCASTFRAMES));
-	dev_info(emac_dev, "EMAC: tx_mcastframes:%d\n",
-		emac_read(EMAC_TXMCASTFRAMES));
-	dev_info(emac_dev, "EMAC: tx_pause_frames:%d\n",
-		emac_read(EMAC_TXPAUSEFRAMES));
-	dev_info(emac_dev, "EMAC: tx_deferred_frames:%d\n",
-		emac_read(EMAC_TXDEFERRED));
-	dev_info(emac_dev, "EMAC: tx_collision_frames:%d\n",
-		emac_read(EMAC_TXCOLLISION));
-	dev_info(emac_dev, "EMAC: tx_single_coll_frames:%d\n",
-		emac_read(EMAC_TXSINGLECOLL));
-	dev_info(emac_dev, "EMAC: tx_mult_coll_frames:%d\n",
-		emac_read(EMAC_TXMULTICOLL));
-	dev_info(emac_dev, "EMAC: tx_excessive_collisions:%d\n",
-		emac_read(EMAC_TXEXCESSIVECOLL));
-	dev_info(emac_dev, "EMAC: tx_late_collisions:%d\n",
-		emac_read(EMAC_TXLATECOLL));
-	dev_info(emac_dev, "EMAC: tx_underrun:%d\n",
-		emac_read(EMAC_TXUNDERRUN));
-	dev_info(emac_dev, "EMAC: tx_carrier_sense_errors:%d\n",
-		emac_read(EMAC_TXCARRIERSENSE));
-	dev_info(emac_dev, "EMAC: tx_octets:%d\n",
-		emac_read(EMAC_TXOCTETS));
-	dev_info(emac_dev, "EMAC: net_octets:%d\n",
-		emac_read(EMAC_NETOCTETS));
-	dev_info(emac_dev, "EMAC: rx_sof_overruns:%d\n",
-		emac_read(EMAC_RXSOFOVERRUNS));
-	dev_info(emac_dev, "EMAC: rx_mof_overruns:%d\n",
-		emac_read(EMAC_RXMOFOVERRUNS));
-	dev_info(emac_dev, "EMAC: rx_dma_overruns:%d\n",
-		emac_read(EMAC_RXDMAOVERRUNS));
-
-	cpdma_ctlr_dump(priv->dma);
-}
-
-/**
  * emac_get_drvinfo - Get EMAC driver information
  * @ndev: The DaVinci EMAC network adapter
  * @info: ethtool info structure containing name and version
@@ -1096,8 +1005,6 @@ static void emac_dev_tx_timeout(struct net_device=
 *ndev)
 	if (netif_msg_tx_err(priv))
 		dev_err(emac_dev, "DaVinci EMAC: xmit timeout, restarting TX");
=20
-	emac_dump_regs(priv);
-
 	ndev->stats.tx_errors++;
 	emac_int_disable(priv);
 	cpdma_chan_stop(priv->txchan);
@@ -1617,9 +1524,6 @@ static int emac_dev_open(struct net_device *ndev)
 		emac_update_phystatus(priv);
 	}
=20
-	if (!netif_running(ndev)) /* debug only - to avoid compiler warning *=
/
-		emac_dump_regs(priv);
-
 	if (netif_msg_drv(priv))
 		dev_notice(emac_dev, "DaVinci EMAC: Opened %s\n", ndev->name);
=20
--=20
2.8.1
