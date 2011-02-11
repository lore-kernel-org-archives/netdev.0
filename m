From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 09/14] net/fec: consistenly name struct net_device pointers "ndev"
Date: Fri, 11 Feb 2011 11:32:17 +0100
Message-ID: <1297420342-17739-9-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45155 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756037Ab1BKKcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:54 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A variable named "dev" usually (usually subjective) points to a struct
device.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |  242 ++++++++++++++++++++++++++-------------------=
-------
 1 files changed, 121 insertions(+), 121 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index d3dbff5..c70503a 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -206,11 +206,11 @@ struct fec_enet_private {
 };
=20
 static irqreturn_t fec_enet_interrupt(int irq, void * dev_id);
-static void fec_enet_tx(struct net_device *dev);
-static void fec_enet_rx(struct net_device *dev);
-static int fec_enet_close(struct net_device *dev);
-static void fec_restart(struct net_device *dev, int duplex);
-static void fec_stop(struct net_device *dev);
+static void fec_enet_tx(struct net_device *ndev);
+static void fec_enet_rx(struct net_device *ndev);
+static int fec_enet_close(struct net_device *ndev);
+static void fec_restart(struct net_device *ndev, int duplex);
+static void fec_stop(struct net_device *ndev);
=20
 /* FEC MII MMFR bits definition */
 #define FEC_MMFR_ST		(1 << 30)
@@ -238,9 +238,9 @@ static void *swap_buffer(void *bufaddr, int len)
 }
=20
 static netdev_tx_t
-fec_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
+fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	const struct platform_device_id *id_entry =3D
 				platform_get_device_id(fep->pdev);
 	struct bufdesc *bdp;
@@ -261,9 +261,9 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net=
_device *dev)
=20
 	if (status & BD_ENET_TX_READY) {
 		/* Ooops.  All transmit buffers are full.  Bail out.
-		 * This should not happen, since dev->tbusy should be set.
+		 * This should not happen, since ndev->tbusy should be set.
 		 */
-		printk("%s: tx queue full!.\n", dev->name);
+		printk("%s: tx queue full!.\n", ndev->name);
 		spin_unlock_irqrestore(&fep->hw_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
@@ -298,13 +298,13 @@ fec_enet_start_xmit(struct sk_buff *skb, struct n=
et_device *dev)
 	/* Save skb pointer */
 	fep->tx_skbuff[fep->skb_cur] =3D skb;
=20
-	dev->stats.tx_bytes +=3D skb->len;
+	ndev->stats.tx_bytes +=3D skb->len;
 	fep->skb_cur =3D (fep->skb_cur+1) & TX_RING_MOD_MASK;
=20
 	/* Push the data cache so the CPM does not get stale memory
 	 * data.
 	 */
-	bdp->cbd_bufaddr =3D dma_map_single(&dev->dev, bufaddr,
+	bdp->cbd_bufaddr =3D dma_map_single(&ndev->dev, bufaddr,
 			FEC_ENET_TX_FRSIZE, DMA_TO_DEVICE);
=20
 	/* Send it on its way.  Tell FEC it's ready, interrupt when done,
@@ -325,7 +325,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net=
_device *dev)
=20
 	if (bdp =3D=3D fep->dirty_tx) {
 		fep->tx_full =3D 1;
-		netif_stop_queue(dev);
+		netif_stop_queue(ndev);
 	}
=20
 	fep->cur_tx =3D bdp;
@@ -336,22 +336,22 @@ fec_enet_start_xmit(struct sk_buff *skb, struct n=
et_device *dev)
 }
=20
 static void
-fec_timeout(struct net_device *dev)
+fec_timeout(struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
=20
-	dev->stats.tx_errors++;
+	ndev->stats.tx_errors++;
=20
-	fec_restart(dev, fep->full_duplex);
-	netif_wake_queue(dev);
+	fec_restart(ndev, fep->full_duplex);
+	netif_wake_queue(ndev);
 }
=20
 static irqreturn_t
-fec_enet_interrupt(int irq, void * dev_id)
+fec_enet_interrupt(int irq, void *dev_id)
 {
-	struct	net_device *dev =3D dev_id;
-	struct fec_enet_private *fep =3D netdev_priv(dev);
-	uint	int_events;
+	struct net_device *ndev =3D dev_id;
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
+	uint int_events;
 	irqreturn_t ret =3D IRQ_NONE;
=20
 	do {
@@ -360,7 +360,7 @@ fec_enet_interrupt(int irq, void * dev_id)
=20
 		if (int_events & FEC_ENET_RXF) {
 			ret =3D IRQ_HANDLED;
-			fec_enet_rx(dev);
+			fec_enet_rx(ndev);
 		}
=20
 		/* Transmit OK, or non-fatal error. Update the buffer
@@ -369,7 +369,7 @@ fec_enet_interrupt(int irq, void * dev_id)
 		 */
 		if (int_events & FEC_ENET_TXF) {
 			ret =3D IRQ_HANDLED;
-			fec_enet_tx(dev);
+			fec_enet_tx(ndev);
 		}
=20
 		if (int_events & FEC_ENET_MII) {
@@ -383,14 +383,14 @@ fec_enet_interrupt(int irq, void * dev_id)
=20
=20
 static void
-fec_enet_tx(struct net_device *dev)
+fec_enet_tx(struct net_device *ndev)
 {
 	struct	fec_enet_private *fep;
 	struct bufdesc *bdp;
 	unsigned short status;
 	struct	sk_buff	*skb;
=20
-	fep =3D netdev_priv(dev);
+	fep =3D netdev_priv(ndev);
 	spin_lock(&fep->hw_lock);
 	bdp =3D fep->dirty_tx;
=20
@@ -398,7 +398,7 @@ fec_enet_tx(struct net_device *dev)
 		if (bdp =3D=3D fep->cur_tx && fep->tx_full =3D=3D 0)
 			break;
=20
-		dma_unmap_single(&dev->dev, bdp->cbd_bufaddr, FEC_ENET_TX_FRSIZE, DM=
A_TO_DEVICE);
+		dma_unmap_single(&ndev->dev, bdp->cbd_bufaddr, FEC_ENET_TX_FRSIZE, D=
MA_TO_DEVICE);
 		bdp->cbd_bufaddr =3D 0;
=20
 		skb =3D fep->tx_skbuff[fep->skb_dirty];
@@ -406,19 +406,19 @@ fec_enet_tx(struct net_device *dev)
 		if (status & (BD_ENET_TX_HB | BD_ENET_TX_LC |
 				   BD_ENET_TX_RL | BD_ENET_TX_UN |
 				   BD_ENET_TX_CSL)) {
-			dev->stats.tx_errors++;
+			ndev->stats.tx_errors++;
 			if (status & BD_ENET_TX_HB)  /* No heartbeat */
-				dev->stats.tx_heartbeat_errors++;
+				ndev->stats.tx_heartbeat_errors++;
 			if (status & BD_ENET_TX_LC)  /* Late collision */
-				dev->stats.tx_window_errors++;
+				ndev->stats.tx_window_errors++;
 			if (status & BD_ENET_TX_RL)  /* Retrans limit */
-				dev->stats.tx_aborted_errors++;
+				ndev->stats.tx_aborted_errors++;
 			if (status & BD_ENET_TX_UN)  /* Underrun */
-				dev->stats.tx_fifo_errors++;
+				ndev->stats.tx_fifo_errors++;
 			if (status & BD_ENET_TX_CSL) /* Carrier lost */
-				dev->stats.tx_carrier_errors++;
+				ndev->stats.tx_carrier_errors++;
 		} else {
-			dev->stats.tx_packets++;
+			ndev->stats.tx_packets++;
 		}
=20
 		if (status & BD_ENET_TX_READY)
@@ -428,7 +428,7 @@ fec_enet_tx(struct net_device *dev)
 		 * but we eventually sent the packet OK.
 		 */
 		if (status & BD_ENET_TX_DEF)
-			dev->stats.collisions++;
+			ndev->stats.collisions++;
=20
 		/* Free the sk buffer associated with this last transmit */
 		dev_kfree_skb_any(skb);
@@ -445,8 +445,8 @@ fec_enet_tx(struct net_device *dev)
 		 */
 		if (fep->tx_full) {
 			fep->tx_full =3D 0;
-			if (netif_queue_stopped(dev))
-				netif_wake_queue(dev);
+			if (netif_queue_stopped(ndev))
+				netif_wake_queue(ndev);
 		}
 	}
 	fep->dirty_tx =3D bdp;
@@ -460,9 +460,9 @@ fec_enet_tx(struct net_device *dev)
  * effectively tossing the packet.
  */
 static void
-fec_enet_rx(struct net_device *dev)
+fec_enet_rx(struct net_device *ndev)
 {
-	struct	fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	const struct platform_device_id *id_entry =3D
 				platform_get_device_id(fep->pdev);
 	struct bufdesc *bdp;
@@ -496,17 +496,17 @@ fec_enet_rx(struct net_device *dev)
 		/* Check for errors. */
 		if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH | BD_ENET_RX_NO |
 			   BD_ENET_RX_CR | BD_ENET_RX_OV)) {
-			dev->stats.rx_errors++;
+			ndev->stats.rx_errors++;
 			if (status & (BD_ENET_RX_LG | BD_ENET_RX_SH)) {
 				/* Frame too long or too short. */
-				dev->stats.rx_length_errors++;
+				ndev->stats.rx_length_errors++;
 			}
 			if (status & BD_ENET_RX_NO)	/* Frame alignment */
-				dev->stats.rx_frame_errors++;
+				ndev->stats.rx_frame_errors++;
 			if (status & BD_ENET_RX_CR)	/* CRC Error */
-				dev->stats.rx_crc_errors++;
+				ndev->stats.rx_crc_errors++;
 			if (status & BD_ENET_RX_OV)	/* FIFO overrun */
-				dev->stats.rx_fifo_errors++;
+				ndev->stats.rx_fifo_errors++;
 		}
=20
 		/* Report late collisions as a frame error.
@@ -514,15 +514,15 @@ fec_enet_rx(struct net_device *dev)
 		 * have in the buffer.  So, just drop this frame on the floor.
 		 */
 		if (status & BD_ENET_RX_CL) {
-			dev->stats.rx_errors++;
-			dev->stats.rx_frame_errors++;
+			ndev->stats.rx_errors++;
+			ndev->stats.rx_frame_errors++;
 			goto rx_processing_done;
 		}
=20
 		/* Process the incoming frame. */
-		dev->stats.rx_packets++;
+		ndev->stats.rx_packets++;
 		pkt_len =3D bdp->cbd_datlen;
-		dev->stats.rx_bytes +=3D pkt_len;
+		ndev->stats.rx_bytes +=3D pkt_len;
 		data =3D (__u8*)__va(bdp->cbd_bufaddr);
=20
 	        dma_unmap_single(NULL, bdp->cbd_bufaddr, bdp->cbd_datlen,
@@ -540,13 +540,13 @@ fec_enet_rx(struct net_device *dev)
=20
 		if (unlikely(!skb)) {
 			printk("%s: Memory squeeze, dropping packet.\n",
-					dev->name);
-			dev->stats.rx_dropped++;
+					ndev->name);
+			ndev->stats.rx_dropped++;
 		} else {
 			skb_reserve(skb, NET_IP_ALIGN);
 			skb_put(skb, pkt_len - 4);	/* Make room */
 			skb_copy_to_linear_data(skb, data, pkt_len - 4);
-			skb->protocol =3D eth_type_trans(skb, dev);
+			skb->protocol =3D eth_type_trans(skb, ndev);
 			netif_rx(skb);
 		}
=20
@@ -577,9 +577,9 @@ rx_processing_done:
 }
=20
 /* -------------------------------------------------------------------=
------ */
-static void __inline__ fec_get_mac(struct net_device *dev)
+static void __inline__ fec_get_mac(struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct fec_platform_data *pdata =3D fep->pdev->dev.platform_data;
 	unsigned char *iap, tmpaddr[ETH_ALEN];
=20
@@ -615,11 +615,11 @@ static void __inline__ fec_get_mac(struct net_dev=
ice *dev)
 		iap =3D &tmpaddr[0];
 	}
=20
-	memcpy(dev->dev_addr, iap, ETH_ALEN);
+	memcpy(ndev->dev_addr, iap, ETH_ALEN);
=20
 	/* Adjust MAC if using macaddr */
 	if (iap =3D=3D macaddr)
-		 dev->dev_addr[ETH_ALEN-1] =3D macaddr[ETH_ALEN-1] + fep->pdev->id;
+		 ndev->dev_addr[ETH_ALEN-1] =3D macaddr[ETH_ALEN-1] + fep->pdev->id;
 }
=20
 /* -------------------------------------------------------------------=
------ */
@@ -627,9 +627,9 @@ static void __inline__ fec_get_mac(struct net_devic=
e *dev)
 /*
  * Phy section
  */
-static void fec_enet_adjust_link(struct net_device *dev)
+static void fec_enet_adjust_link(struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct phy_device *phy_dev =3D fep->phy_dev;
 	unsigned long flags;
=20
@@ -646,7 +646,7 @@ static void fec_enet_adjust_link(struct net_device =
*dev)
 	/* Duplex link change */
 	if (phy_dev->link) {
 		if (fep->full_duplex !=3D phy_dev->duplex) {
-			fec_restart(dev, phy_dev->duplex);
+			fec_restart(ndev, phy_dev->duplex);
 			status_change =3D 1;
 		}
 	}
@@ -655,9 +655,9 @@ static void fec_enet_adjust_link(struct net_device =
*dev)
 	if (phy_dev->link !=3D fep->link) {
 		fep->link =3D phy_dev->link;
 		if (phy_dev->link)
-			fec_restart(dev, phy_dev->duplex);
+			fec_restart(ndev, phy_dev->duplex);
 		else
-			fec_stop(dev);
+			fec_stop(ndev);
 		status_change =3D 1;
 	}
=20
@@ -726,9 +726,9 @@ static int fec_enet_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
=20
-static int fec_enet_mii_probe(struct net_device *dev)
+static int fec_enet_mii_probe(struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct phy_device *phy_dev =3D NULL;
 	char mdio_bus_id[MII_BUS_ID_SIZE];
 	char phy_name[MII_BUS_ID_SIZE + 3];
@@ -753,16 +753,16 @@ static int fec_enet_mii_probe(struct net_device *=
dev)
=20
 	if (phy_id >=3D PHY_MAX_ADDR) {
 		printk(KERN_INFO "%s: no PHY, assuming direct connection "
-			"to switch\n", dev->name);
+			"to switch\n", ndev->name);
 		strncpy(mdio_bus_id, "0", MII_BUS_ID_SIZE);
 		phy_id =3D 0;
 	}
=20
 	snprintf(phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
-	phy_dev =3D phy_connect(dev, phy_name, &fec_enet_adjust_link, 0,
+	phy_dev =3D phy_connect(ndev, phy_name, &fec_enet_adjust_link, 0,
 		PHY_INTERFACE_MODE_MII);
 	if (IS_ERR(phy_dev)) {
-		printk(KERN_ERR "%s: could not attach to PHY\n", dev->name);
+		printk(KERN_ERR "%s: could not attach to PHY\n", ndev->name);
 		return PTR_ERR(phy_dev);
 	}
=20
@@ -775,7 +775,7 @@ static int fec_enet_mii_probe(struct net_device *de=
v)
 	fep->full_duplex =3D 0;
=20
 	printk(KERN_INFO "%s: Freescale FEC PHY driver [%s] "
-		"(mii_bus:phy_addr=3D%s, irq=3D%d)\n", dev->name,
+		"(mii_bus:phy_addr=3D%s, irq=3D%d)\n", ndev->name,
 		fep->phy_dev->drv->name, dev_name(&fep->phy_dev->dev),
 		fep->phy_dev->irq);
=20
@@ -785,8 +785,8 @@ static int fec_enet_mii_probe(struct net_device *de=
v)
 static int fec_enet_mii_init(struct platform_device *pdev)
 {
 	static struct mii_bus *fec0_mii_bus;
-	struct net_device *dev =3D platform_get_drvdata(pdev);
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct net_device *ndev =3D platform_get_drvdata(pdev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	const struct platform_device_id *id_entry =3D
 				platform_get_device_id(fep->pdev);
 	int err =3D -ENXIO, i;
@@ -844,7 +844,7 @@ static int fec_enet_mii_init(struct platform_device=
 *pdev)
 	for (i =3D 0; i < PHY_MAX_ADDR; i++)
 		fep->mii_bus->irq[i] =3D PHY_POLL;
=20
-	platform_set_drvdata(dev, fep->mii_bus);
+	platform_set_drvdata(ndev, fep->mii_bus);
=20
 	if (mdiobus_register(fep->mii_bus))
 		goto err_out_free_mdio_irq;
@@ -872,10 +872,10 @@ static void fec_enet_mii_remove(struct fec_enet_p=
rivate *fep)
 	mdiobus_free(fep->mii_bus);
 }
=20
-static int fec_enet_get_settings(struct net_device *dev,
+static int fec_enet_get_settings(struct net_device *ndev,
 				  struct ethtool_cmd *cmd)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct phy_device *phydev =3D fep->phy_dev;
=20
 	if (!phydev)
@@ -884,10 +884,10 @@ static int fec_enet_get_settings(struct net_devic=
e *dev,
 	return phy_ethtool_gset(phydev, cmd);
 }
=20
-static int fec_enet_set_settings(struct net_device *dev,
+static int fec_enet_set_settings(struct net_device *ndev,
 				 struct ethtool_cmd *cmd)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct phy_device *phydev =3D fep->phy_dev;
=20
 	if (!phydev)
@@ -896,14 +896,14 @@ static int fec_enet_set_settings(struct net_devic=
e *dev,
 	return phy_ethtool_sset(phydev, cmd);
 }
=20
-static void fec_enet_get_drvinfo(struct net_device *dev,
+static void fec_enet_get_drvinfo(struct net_device *ndev,
 				 struct ethtool_drvinfo *info)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
=20
 	strcpy(info->driver, fep->pdev->dev.driver->name);
 	strcpy(info->version, "Revision: 1.0");
-	strcpy(info->bus_info, dev_name(&dev->dev));
+	strcpy(info->bus_info, dev_name(&ndev->dev));
 }
=20
 static struct ethtool_ops fec_enet_ethtool_ops =3D {
@@ -913,12 +913,12 @@ static struct ethtool_ops fec_enet_ethtool_ops =3D=
 {
 	.get_link		=3D ethtool_op_get_link,
 };
=20
-static int fec_enet_ioctl(struct net_device *dev, struct ifreq *rq, in=
t cmd)
+static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, i=
nt cmd)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct phy_device *phydev =3D fep->phy_dev;
=20
-	if (!netif_running(dev))
+	if (!netif_running(ndev))
 		return -EINVAL;
=20
 	if (!phydev)
@@ -927,9 +927,9 @@ static int fec_enet_ioctl(struct net_device *dev, s=
truct ifreq *rq, int cmd)
 	return phy_mii_ioctl(phydev, rq, cmd);
 }
=20
-static void fec_enet_free_buffers(struct net_device *dev)
+static void fec_enet_free_buffers(struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	int i;
 	struct sk_buff *skb;
 	struct bufdesc	*bdp;
@@ -939,7 +939,7 @@ static void fec_enet_free_buffers(struct net_device=
 *dev)
 		skb =3D fep->rx_skbuff[i];
=20
 		if (bdp->cbd_bufaddr)
-			dma_unmap_single(&dev->dev, bdp->cbd_bufaddr,
+			dma_unmap_single(&ndev->dev, bdp->cbd_bufaddr,
 					FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
 		if (skb)
 			dev_kfree_skb(skb);
@@ -951,9 +951,9 @@ static void fec_enet_free_buffers(struct net_device=
 *dev)
 		kfree(fep->tx_bounce[i]);
 }
=20
-static int fec_enet_alloc_buffers(struct net_device *dev)
+static int fec_enet_alloc_buffers(struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	int i;
 	struct sk_buff *skb;
 	struct bufdesc	*bdp;
@@ -962,12 +962,12 @@ static int fec_enet_alloc_buffers(struct net_devi=
ce *dev)
 	for (i =3D 0; i < RX_RING_SIZE; i++) {
 		skb =3D dev_alloc_skb(FEC_ENET_RX_FRSIZE);
 		if (!skb) {
-			fec_enet_free_buffers(dev);
+			fec_enet_free_buffers(ndev);
 			return -ENOMEM;
 		}
 		fep->rx_skbuff[i] =3D skb;
=20
-		bdp->cbd_bufaddr =3D dma_map_single(&dev->dev, skb->data,
+		bdp->cbd_bufaddr =3D dma_map_single(&ndev->dev, skb->data,
 				FEC_ENET_RX_FRSIZE, DMA_FROM_DEVICE);
 		bdp->cbd_sc =3D BD_ENET_RX_EMPTY;
 		bdp++;
@@ -994,47 +994,47 @@ static int fec_enet_alloc_buffers(struct net_devi=
ce *dev)
 }
=20
 static int
-fec_enet_open(struct net_device *dev)
+fec_enet_open(struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	int ret;
=20
 	/* I should reset the ring buffers here, but I don't yet know
 	 * a simple way to do that.
 	 */
=20
-	ret =3D fec_enet_alloc_buffers(dev);
+	ret =3D fec_enet_alloc_buffers(ndev);
 	if (ret)
 		return ret;
=20
 	/* Probe and connect to PHY when open the interface */
-	ret =3D fec_enet_mii_probe(dev);
+	ret =3D fec_enet_mii_probe(ndev);
 	if (ret) {
-		fec_enet_free_buffers(dev);
+		fec_enet_free_buffers(ndev);
 		return ret;
 	}
 	phy_start(fep->phy_dev);
-	netif_start_queue(dev);
+	netif_start_queue(ndev);
 	fep->opened =3D 1;
 	return 0;
 }
=20
 static int
-fec_enet_close(struct net_device *dev)
+fec_enet_close(struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
=20
 	/* Don't know what to do yet. */
 	fep->opened =3D 0;
-	netif_stop_queue(dev);
-	fec_stop(dev);
+	netif_stop_queue(ndev);
+	fec_stop(ndev);
=20
 	if (fep->phy_dev) {
 		phy_stop(fep->phy_dev);
 		phy_disconnect(fep->phy_dev);
 	}
=20
-        fec_enet_free_buffers(dev);
+        fec_enet_free_buffers(ndev);
=20
 	return 0;
 }
@@ -1052,14 +1052,14 @@ fec_enet_close(struct net_device *dev)
 #define HASH_BITS	6		/* #bits in hash */
 #define CRC32_POLY	0xEDB88320
=20
-static void set_multicast_list(struct net_device *dev)
+static void set_multicast_list(struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct netdev_hw_addr *ha;
 	unsigned int i, bit, data, crc, tmp;
 	unsigned char hash;
=20
-	if (dev->flags & IFF_PROMISC) {
+	if (ndev->flags & IFF_PROMISC) {
 		tmp =3D readl(fep->hwp + FEC_R_CNTRL);
 		tmp |=3D 0x8;
 		writel(tmp, fep->hwp + FEC_R_CNTRL);
@@ -1070,7 +1070,7 @@ static void set_multicast_list(struct net_device =
*dev)
 	tmp &=3D ~0x8;
 	writel(tmp, fep->hwp + FEC_R_CNTRL);
=20
-	if (dev->flags & IFF_ALLMULTI) {
+	if (ndev->flags & IFF_ALLMULTI) {
 		/* Catch all multicast addresses, so set the
 		 * filter to all 1's
 		 */
@@ -1085,7 +1085,7 @@ static void set_multicast_list(struct net_device =
*dev)
 	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
 	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
=20
-	netdev_for_each_mc_addr(ha, dev) {
+	netdev_for_each_mc_addr(ha, ndev) {
 		/* Only support group multicast for now */
 		if (!(ha->addr[0] & 1))
 			continue;
@@ -1093,7 +1093,7 @@ static void set_multicast_list(struct net_device =
*dev)
 		/* calculate crc32 value of mac address */
 		crc =3D 0xffffffff;
=20
-		for (i =3D 0; i < dev->addr_len; i++) {
+		for (i =3D 0; i < ndev->addr_len; i++) {
 			data =3D ha->addr[i];
 			for (bit =3D 0; bit < 8; bit++, data >>=3D 1) {
 				crc =3D (crc >> 1) ^
@@ -1120,20 +1120,20 @@ static void set_multicast_list(struct net_devic=
e *dev)
=20
 /* Set a MAC change in hardware. */
 static int
-fec_set_mac_address(struct net_device *dev, void *p)
+fec_set_mac_address(struct net_device *ndev, void *p)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct sockaddr *addr =3D p;
=20
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
=20
-	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
=20
-	writel(dev->dev_addr[3] | (dev->dev_addr[2] << 8) |
-		(dev->dev_addr[1] << 16) | (dev->dev_addr[0] << 24),
+	writel(ndev->dev_addr[3] | (ndev->dev_addr[2] << 8) |
+		(ndev->dev_addr[1] << 16) | (ndev->dev_addr[0] << 24),
 		fep->hwp + FEC_ADDR_LOW);
-	writel((dev->dev_addr[5] << 16) | (dev->dev_addr[4] << 24),
+	writel((ndev->dev_addr[5] << 16) | (ndev->dev_addr[4] << 24),
 		fep->hwp + FEC_ADDR_HIGH);
 	return 0;
 }
@@ -1154,9 +1154,9 @@ static const struct net_device_ops fec_netdev_ops=
 =3D {
   * XXX:  We need to clean up on failure exits here.
   *
   */
-static int fec_enet_init(struct net_device *dev)
+static int fec_enet_init(struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	struct bufdesc *cbd_base;
 	struct bufdesc *bdp;
 	int i;
@@ -1171,19 +1171,19 @@ static int fec_enet_init(struct net_device *dev=
)
=20
 	spin_lock_init(&fep->hw_lock);
=20
-	fep->netdev =3D dev;
+	fep->netdev =3D ndev;
=20
 	/* Get the Ethernet address */
-	fec_get_mac(dev);
+	fec_get_mac(ndev);
=20
 	/* Set receive and transmit descriptor base. */
 	fep->rx_bd_base =3D cbd_base;
 	fep->tx_bd_base =3D cbd_base + RX_RING_SIZE;
=20
 	/* The FEC Ethernet specific entries in the device structure */
-	dev->watchdog_timeo =3D TX_TIMEOUT;
-	dev->netdev_ops =3D &fec_netdev_ops;
-	dev->ethtool_ops =3D &fec_enet_ethtool_ops;
+	ndev->watchdog_timeo =3D TX_TIMEOUT;
+	ndev->netdev_ops =3D &fec_netdev_ops;
+	ndev->ethtool_ops =3D &fec_enet_ethtool_ops;
=20
 	/* Initialize the receive buffer descriptors. */
 	bdp =3D fep->rx_bd_base;
@@ -1212,7 +1212,7 @@ static int fec_enet_init(struct net_device *dev)
 	bdp--;
 	bdp->cbd_sc |=3D BD_SC_WRAP;
=20
-	fec_restart(dev, 0);
+	fec_restart(ndev, 0);
=20
 	return 0;
 }
@@ -1222,9 +1222,9 @@ static int fec_enet_init(struct net_device *dev)
  * duplex.
  */
 static void
-fec_restart(struct net_device *dev, int duplex)
+fec_restart(struct net_device *ndev, int duplex)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	const struct platform_device_id *id_entry =3D
 				platform_get_device_id(fep->pdev);
 	int i;
@@ -1239,7 +1239,7 @@ fec_restart(struct net_device *dev, int duplex)
 	 * so need to reconfigure it.
 	 */
 	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
-		memcpy(&temp_mac, dev->dev_addr, ETH_ALEN);
+		memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
 		writel(cpu_to_be32(temp_mac[0]), fep->hwp + FEC_ADDR_LOW);
 		writel(cpu_to_be32(temp_mac[1]), fep->hwp + FEC_ADDR_HIGH);
 	}
@@ -1339,9 +1339,9 @@ fec_restart(struct net_device *dev, int duplex)
 }
=20
 static void
-fec_stop(struct net_device *dev)
+fec_stop(struct net_device *ndev)
 {
-	struct fec_enet_private *fep =3D netdev_priv(dev);
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
=20
 	/* We cannot expect a graceful transmit stop without link !!! */
 	if (fep->link) {
--=20
1.7.2.3

