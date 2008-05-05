From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] amd8111e: use netstats in net_device structure
Date: Tue, 06 May 2008 00:46:43 +0300
Message-ID: <fvnv83$lke$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000905050101010602090404"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:48763 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759224AbYEEVqy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 17:46:54 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jt8WJ-0005l4-2u
	for netdev@vger.kernel.org; Mon, 05 May 2008 21:46:51 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 21:46:51 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 21:46:51 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000905050101010602090404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------000905050101010602090404
Content-Type: text/x-patch;
 name="amd8111e_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="amd8111e_netstats.patch"

diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 85f7276..b61d059 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1022,30 +1022,28 @@ static struct net_device_stats *amd8111e_get_stats(struct net_device * dev)
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	void __iomem *mmio = lp->mmio;
 	unsigned long flags;
-	/* struct net_device_stats *prev_stats = &lp->prev_stats; */
-	struct net_device_stats* new_stats = &lp->stats;
 
 	if(!lp->opened)
-		return &lp->stats;
+		return &dev->stats;
 	spin_lock_irqsave (&lp->lock, flags);
 
 	/* stats.rx_packets */
-	new_stats->rx_packets = amd8111e_read_mib(mmio, rcv_broadcast_pkts)+
+	dev->stats.rx_packets = amd8111e_read_mib(mmio, rcv_broadcast_pkts)+
 				amd8111e_read_mib(mmio, rcv_multicast_pkts)+
 				amd8111e_read_mib(mmio, rcv_unicast_pkts);
 
 	/* stats.tx_packets */
-	new_stats->tx_packets = amd8111e_read_mib(mmio, xmt_packets);
+	dev->stats.tx_packets = amd8111e_read_mib(mmio, xmt_packets);
 
 	/*stats.rx_bytes */
-	new_stats->rx_bytes = amd8111e_read_mib(mmio, rcv_octets);
+	dev->stats.rx_bytes = amd8111e_read_mib(mmio, rcv_octets);
 
 	/* stats.tx_bytes */
-	new_stats->tx_bytes = amd8111e_read_mib(mmio, xmt_octets);
+	dev->stats.tx_bytes = amd8111e_read_mib(mmio, xmt_octets);
 
 	/* stats.rx_errors */
 	/* hw errors + errors driver reported */
-	new_stats->rx_errors = amd8111e_read_mib(mmio, rcv_undersize_pkts)+
+	dev->stats.rx_errors = amd8111e_read_mib(mmio, rcv_undersize_pkts)+
 				amd8111e_read_mib(mmio, rcv_fragments)+
 				amd8111e_read_mib(mmio, rcv_jabbers)+
 				amd8111e_read_mib(mmio, rcv_alignment_errors)+
@@ -1054,54 +1052,54 @@ static struct net_device_stats *amd8111e_get_stats(struct net_device * dev)
 				lp->drv_rx_errors;
 
 	/* stats.tx_errors */
-	new_stats->tx_errors = amd8111e_read_mib(mmio, xmt_underrun_pkts);
+	dev->stats.tx_errors = amd8111e_read_mib(mmio, xmt_underrun_pkts);
 
 	/* stats.rx_dropped*/
-	new_stats->rx_dropped = amd8111e_read_mib(mmio, rcv_miss_pkts);
+	dev->stats.rx_dropped = amd8111e_read_mib(mmio, rcv_miss_pkts);
 
 	/* stats.tx_dropped*/
-	new_stats->tx_dropped = amd8111e_read_mib(mmio,  xmt_underrun_pkts);
+	dev->stats.tx_dropped = amd8111e_read_mib(mmio,  xmt_underrun_pkts);
 
 	/* stats.multicast*/
-	new_stats->multicast = amd8111e_read_mib(mmio, rcv_multicast_pkts);
+	dev->stats.multicast = amd8111e_read_mib(mmio, rcv_multicast_pkts);
 
 	/* stats.collisions*/
-	new_stats->collisions = amd8111e_read_mib(mmio, xmt_collisions);
+	dev->stats.collisions = amd8111e_read_mib(mmio, xmt_collisions);
 
 	/* stats.rx_length_errors*/
-	new_stats->rx_length_errors =
+	dev->stats.rx_length_errors =
 		amd8111e_read_mib(mmio, rcv_undersize_pkts)+
 		amd8111e_read_mib(mmio, rcv_oversize_pkts);
 
 	/* stats.rx_over_errors*/
-	new_stats->rx_over_errors = amd8111e_read_mib(mmio, rcv_miss_pkts);
+	dev->stats.rx_over_errors = amd8111e_read_mib(mmio, rcv_miss_pkts);
 
 	/* stats.rx_crc_errors*/
-	new_stats->rx_crc_errors = amd8111e_read_mib(mmio, rcv_fcs_errors);
+	dev->stats.rx_crc_errors = amd8111e_read_mib(mmio, rcv_fcs_errors);
 
 	/* stats.rx_frame_errors*/
-	new_stats->rx_frame_errors =
+	dev->stats.rx_frame_errors =
 		amd8111e_read_mib(mmio, rcv_alignment_errors);
 
 	/* stats.rx_fifo_errors */
-	new_stats->rx_fifo_errors = amd8111e_read_mib(mmio, rcv_miss_pkts);
+	dev->stats.rx_fifo_errors = amd8111e_read_mib(mmio, rcv_miss_pkts);
 
 	/* stats.rx_missed_errors */
-	new_stats->rx_missed_errors = amd8111e_read_mib(mmio, rcv_miss_pkts);
+	dev->stats.rx_missed_errors = amd8111e_read_mib(mmio, rcv_miss_pkts);
 
 	/* stats.tx_aborted_errors*/
-	new_stats->tx_aborted_errors =
+	dev->stats.tx_aborted_errors =
 		amd8111e_read_mib(mmio, xmt_excessive_collision);
 
 	/* stats.tx_carrier_errors*/
-	new_stats->tx_carrier_errors =
+	dev->stats.tx_carrier_errors =
 		amd8111e_read_mib(mmio, xmt_loss_carrier);
 
 	/* stats.tx_fifo_errors*/
-	new_stats->tx_fifo_errors = amd8111e_read_mib(mmio, xmt_underrun_pkts);
+	dev->stats.tx_fifo_errors = amd8111e_read_mib(mmio, xmt_underrun_pkts);
 
 	/* stats.tx_window_errors*/
-	new_stats->tx_window_errors =
+	dev->stats.tx_window_errors =
 		amd8111e_read_mib(mmio, xmt_late_collision);
 
 	/* Reset the mibs for collecting new statistics */
@@ -1109,7 +1107,7 @@ static struct net_device_stats *amd8111e_get_stats(struct net_device * dev)
 
 	spin_unlock_irqrestore (&lp->lock, flags);
 
-	return new_stats;
+	return &dev->stats;
 }
 /* This function recalculate the interrupt coalescing  mode on every interrupt
 according to the datarate and the packet rate.
diff --git a/drivers/net/amd8111e.h b/drivers/net/amd8111e.h
index 28c60a7..5027759 100644
--- a/drivers/net/amd8111e.h
+++ b/drivers/net/amd8111e.h
@@ -787,7 +787,6 @@ struct amd8111e_priv{
 	struct vlan_group		*vlgrp;
 #endif
 	char opened;
-	struct net_device_stats stats;
 	unsigned int drv_rx_errors;
 	struct dev_mc_list* mc_list;
 	struct amd8111e_coalesce_conf coal_conf;

--------------000905050101010602090404--

