From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH RESEND] at91_ether: use netstats in net_device structure
Date: Thu, 17 Jul 2008 11:01:26 +0300
Message-ID: <g5mu8n$hne$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030309070203030905070201"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:56131 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757486AbYGQIBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 04:01:37 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1KJOQg-0002Rr-MP
	for netdev@vger.kernel.org; Thu, 17 Jul 2008 08:01:34 +0000
Received: from 82-135-208-232.static.zebra.lt ([82.135.208.232])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 08:01:34 +0000
Received: from paulius.zaleckas by 82-135-208-232.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 08:01:34 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030309070203030905070201
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------030309070203030905070201
Content-Type: text/x-patch;
 name="at91_ether_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="at91_ether_netstats.patch"

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Tested-by: Marc Pignat <marc.pignat@hevs.ch>
Acked-by: Andrew Victor <linux@maxim.org.za>
---

diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 1e39e78..49c320b 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -820,7 +820,7 @@ static int at91ether_tx(struct sk_buff *skb, struct net_device *dev)
 		lp->skb = skb;
 		lp->skb_length = skb->len;
 		lp->skb_physaddr = dma_map_single(NULL, skb->data, skb->len, DMA_TO_DEVICE);
-		lp->stats.tx_bytes += skb->len;
+		dev->stats.tx_bytes += skb->len;
 
 		/* Set address of the data in the Transmit Address register */
 		at91_emac_write(AT91_EMAC_TAR, lp->skb_physaddr);
@@ -843,34 +843,33 @@ static int at91ether_tx(struct sk_buff *skb, struct net_device *dev)
  */
 static struct net_device_stats *at91ether_stats(struct net_device *dev)
 {
-	struct at91_private *lp = netdev_priv(dev);
 	int ale, lenerr, seqe, lcol, ecol;
 
 	if (netif_running(dev)) {
-		lp->stats.rx_packets += at91_emac_read(AT91_EMAC_OK);		/* Good frames received */
+		dev->stats.rx_packets += at91_emac_read(AT91_EMAC_OK);		/* Good frames received */
 		ale = at91_emac_read(AT91_EMAC_ALE);
-		lp->stats.rx_frame_errors += ale;				/* Alignment errors */
+		dev->stats.rx_frame_errors += ale;				/* Alignment errors */
 		lenerr = at91_emac_read(AT91_EMAC_ELR) + at91_emac_read(AT91_EMAC_USF);
-		lp->stats.rx_length_errors += lenerr;				/* Excessive Length or Undersize Frame error */
+		dev->stats.rx_length_errors += lenerr;				/* Excessive Length or Undersize Frame error */
 		seqe = at91_emac_read(AT91_EMAC_SEQE);
-		lp->stats.rx_crc_errors += seqe;				/* CRC error */
-		lp->stats.rx_fifo_errors += at91_emac_read(AT91_EMAC_DRFC);	/* Receive buffer not available */
-		lp->stats.rx_errors += (ale + lenerr + seqe
+		dev->stats.rx_crc_errors += seqe;				/* CRC error */
+		dev->stats.rx_fifo_errors += at91_emac_read(AT91_EMAC_DRFC);	/* Receive buffer not available */
+		dev->stats.rx_errors += (ale + lenerr + seqe
 			+ at91_emac_read(AT91_EMAC_CDE) + at91_emac_read(AT91_EMAC_RJB));
 
-		lp->stats.tx_packets += at91_emac_read(AT91_EMAC_FRA);		/* Frames successfully transmitted */
-		lp->stats.tx_fifo_errors += at91_emac_read(AT91_EMAC_TUE);	/* Transmit FIFO underruns */
-		lp->stats.tx_carrier_errors += at91_emac_read(AT91_EMAC_CSE);	/* Carrier Sense errors */
-		lp->stats.tx_heartbeat_errors += at91_emac_read(AT91_EMAC_SQEE);/* Heartbeat error */
+		dev->stats.tx_packets += at91_emac_read(AT91_EMAC_FRA);		/* Frames successfully transmitted */
+		dev->stats.tx_fifo_errors += at91_emac_read(AT91_EMAC_TUE);	/* Transmit FIFO underruns */
+		dev->stats.tx_carrier_errors += at91_emac_read(AT91_EMAC_CSE);	/* Carrier Sense errors */
+		dev->stats.tx_heartbeat_errors += at91_emac_read(AT91_EMAC_SQEE);/* Heartbeat error */
 
 		lcol = at91_emac_read(AT91_EMAC_LCOL);
 		ecol = at91_emac_read(AT91_EMAC_ECOL);
-		lp->stats.tx_window_errors += lcol;			/* Late collisions */
-		lp->stats.tx_aborted_errors += ecol;			/* 16 collisions */
+		dev->stats.tx_window_errors += lcol;			/* Late collisions */
+		dev->stats.tx_aborted_errors += ecol;			/* 16 collisions */
 
-		lp->stats.collisions += (at91_emac_read(AT91_EMAC_SCOL) + at91_emac_read(AT91_EMAC_MCOL) + lcol + ecol);
+		dev->stats.collisions += (at91_emac_read(AT91_EMAC_SCOL) + at91_emac_read(AT91_EMAC_MCOL) + lcol + ecol);
 	}
-	return &lp->stats;
+	return &dev->stats;
 }
 
 /*
@@ -896,16 +895,16 @@ static void at91ether_rx(struct net_device *dev)
 
 			skb->protocol = eth_type_trans(skb, dev);
 			dev->last_rx = jiffies;
-			lp->stats.rx_bytes += pktlen;
+			dev->stats.rx_bytes += pktlen;
 			netif_rx(skb);
 		}
 		else {
-			lp->stats.rx_dropped += 1;
+			dev->stats.rx_dropped += 1;
 			printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n", dev->name);
 		}
 
 		if (dlist->descriptors[lp->rxBuffIndex].size & EMAC_MULTICAST)
-			lp->stats.multicast++;
+			dev->stats.multicast++;
 
 		dlist->descriptors[lp->rxBuffIndex].addr &= ~EMAC_DESC_DONE;	/* reset ownership bit */
 		if (lp->rxBuffIndex == MAX_RX_DESCR-1)				/* wrap after last buffer */
@@ -934,7 +933,7 @@ static irqreturn_t at91ether_interrupt(int irq, void *dev_id)
 	if (intstatus & AT91_EMAC_TCOM) {	/* Transmit complete */
 		/* The TCOM bit is set even if the transmission failed. */
 		if (intstatus & (AT91_EMAC_TUND | AT91_EMAC_RTRY))
-			lp->stats.tx_errors += 1;
+			dev->stats.tx_errors += 1;
 
 		if (lp->skb) {
 			dev_kfree_skb_irq(lp->skb);
diff --git a/drivers/net/arm/at91_ether.h b/drivers/net/arm/at91_ether.h
index a38fd2d..353f4da 100644
--- a/drivers/net/arm/at91_ether.h
+++ b/drivers/net/arm/at91_ether.h
@@ -84,7 +84,6 @@ struct recv_desc_bufs
 
 struct at91_private
 {
-	struct net_device_stats stats;
 	struct mii_if_info mii;			/* ethtool support */
 	struct at91_eth_data board_data;	/* board-specific configuration */
 	struct clk *ether_clk;			/* clock */

--------------030309070203030905070201--

