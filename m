From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 3/3] net: mvneta: adjust multiline comments to net/ style
Date: Mon, 19 Nov 2012 12:00:34 +0100
Message-ID: <1353322834-16952-4-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1353322834-16952-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>, netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:35979 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910Ab2KSLBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 06:01:05 -0500
In-Reply-To: <1353322834-16952-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As reported by checkpatch, the multiline comments for net/ and
drivers/net/ have a slightly different format than the one used in the
rest of the kernel, so we adjust our multiline comments accordingly.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c |   84 ++++++++++++++++-----------------
 1 file changed, 42 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index a7826f0..d9dadee 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -178,8 +178,7 @@
 /* Napi polling weight */
 #define MVNETA_RX_POLL_WEIGHT		64
 
-/*
- * The two bytes Marvell header. Either contains a special value used
+/* The two bytes Marvell header. Either contains a special value used
  * by Marvell switches when a specific hardware mode is enabled (not
  * supported by this driver) or is filled automatically by zeroes on
  * the RX side. Those two bytes being at the front of the Ethernet
@@ -259,8 +258,7 @@ struct mvneta_port {
 	unsigned int speed;
 };
 
-/*
- * The mvneta_tx_desc and mvneta_rx_desc structures describe the
+/* The mvneta_tx_desc and mvneta_rx_desc structures describe the
  * layout of the transmit and reception DMA descriptors, and their
  * layout is therefore defined by the hardware design
  */
@@ -318,7 +316,8 @@ struct mvneta_tx_queue {
 	int size;
 
 	/* Number of currently used TX DMA descriptor in the
-	 * descriptor ring */
+	 * descriptor ring
+	 */
 	int count;
 
 	/* Array of transmitted skb */
@@ -454,8 +453,7 @@ struct rtnl_link_stats64 *mvneta_get_stats64(struct net_device *dev,
 
 /* Rx descriptors helper methods */
 
-/*
- * Checks whether the given RX descriptor is both the first and the
+/* Checks whether the given RX descriptor is both the first and the
  * last descriptor for the RX packet. Each RX packet is currently
  * received through a single RX descriptor, so not having each RX
  * descriptor with its first and last bits set is an error
@@ -472,7 +470,8 @@ static void mvneta_rxq_non_occup_desc_add(struct mvneta_port *pp,
 					  int ndescs)
 {
 	/* Only MVNETA_RXQ_ADD_NON_OCCUPIED_MAX (255) descriptors can
-	 * be added at once */
+	 * be added at once
+	 */
 	while (ndescs > MVNETA_RXQ_ADD_NON_OCCUPIED_MAX) {
 		mvreg_write(pp, MVNETA_RXQ_STATUS_UPDATE_REG(rxq->id),
 			    (MVNETA_RXQ_ADD_NON_OCCUPIED_MAX <<
@@ -494,8 +493,7 @@ static int mvneta_rxq_busy_desc_num_get(struct mvneta_port *pp,
 	return val & MVNETA_RXQ_OCCUPIED_ALL_MASK;
 }
 
-/*
- * Update num of rx desc called upon return from rx path or
+/* Update num of rx desc called upon return from rx path or
  * from mvneta_rxq_drop_pkts().
  */
 static void mvneta_rxq_desc_num_update(struct mvneta_port *pp,
@@ -580,7 +578,8 @@ static void mvneta_txq_pend_desc_add(struct mvneta_port *pp,
 	u32 val;
 
 	/* Only 255 descriptors can be added at once ; Assume caller
-	   process TX desriptors in quanta less than 256 */
+	 * process TX desriptors in quanta less than 256
+	 */
 	val = pend_desc;
 	mvreg_write(pp, MVNETA_TXQ_UPDATE_REG(txq->id), val);
 }
@@ -596,7 +595,8 @@ mvneta_txq_next_desc_get(struct mvneta_tx_queue *txq)
 }
 
 /* Release the last allocated TX descriptor. Useful to handle DMA
- * mapping failures in the TX path. */
+ * mapping failures in the TX path.
+ */
 static void mvneta_txq_desc_put(struct mvneta_tx_queue *txq)
 {
 	if (txq->next_desc_to_proc == 0)
@@ -714,7 +714,8 @@ static void mvneta_port_down(struct mvneta_port *pp)
 	} while (val & 0xff);
 
 	/* Stop Tx port activity. Check port Tx activity. Issue stop
-	   command for active channels only  */
+	 * command for active channels only
+	 */
 	val = (mvreg_read(pp, MVNETA_TXQ_CMD)) & MVNETA_TXQ_ENABLE_MASK;
 
 	if (val != 0)
@@ -865,7 +866,8 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	mvreg_write(pp, MVNETA_MBUS_RETRY, 0x20);
 
 	/* Set CPU queue access map - all CPUs have access to all RX
-	   queues and to all TX queues */
+	 * queues and to all TX queues
+	 */
 	for (cpu = 0; cpu < CONFIG_NR_CPUS; cpu++)
 		mvreg_write(pp, MVNETA_CPU_MAP(cpu),
 			    (MVNETA_CPU_RXQ_ACCESS_ALL_MASK |
@@ -1010,9 +1012,8 @@ static void mvneta_mac_addr_set(struct mvneta_port *pp, unsigned char *addr,
 	mvneta_set_ucast_addr(pp, addr[5], queue);
 }
 
-/*
- * Set the number of packets that will be received before
- * RX interrupt will be generated by HW.
+/* Set the number of packets that will be received before RX interrupt
+ * will be generated by HW.
  */
 static void mvneta_rx_pkts_coal_set(struct mvneta_port *pp,
 				    struct mvneta_rx_queue *rxq, u32 value)
@@ -1022,9 +1023,8 @@ static void mvneta_rx_pkts_coal_set(struct mvneta_port *pp,
 	rxq->pkts_coal = value;
 }
 
-/*
- * Set the time delay in usec before
- * RX interrupt will be generated by HW.
+/* Set the time delay in usec before RX interrupt will be generated by
+ * HW.
  */
 static void mvneta_rx_time_coal_set(struct mvneta_port *pp,
 				    struct mvneta_rx_queue *rxq, u32 value)
@@ -1102,8 +1102,7 @@ static int mvneta_txq_sent_desc_num_get(struct mvneta_port *pp,
 	return sent_desc;
 }
 
-/*
- * Get number of sent descriptors and decrement counter.
+/* Get number of sent descriptors and decrement counter.
  *  The number of sent descriptors is returned.
  */
 static int mvneta_txq_sent_desc_proc(struct mvneta_port *pp,
@@ -1128,8 +1127,9 @@ static u32 mvneta_txq_desc_csum(int l3_offs, int l3_proto,
 	u32 command;
 
 	/* Fields: L3_offset, IP_hdrlen, L3_type, G_IPv4_chk,
-	   G_L4_chk, L4_type; required only for checksum
-	   calculation */
+	 * G_L4_chk, L4_type; required only for checksum
+	 * calculation
+	 */
 	command =  l3_offs    << MVNETA_TX_L3_OFF_SHIFT;
 	command |= ip_hdr_len << MVNETA_TX_IP_HLEN_SHIFT;
 
@@ -1305,8 +1305,7 @@ static u32 mvneta_skb_tx_csum(struct mvneta_port *pp, struct sk_buff *skb)
 	return MVNETA_TX_L4_CSUM_NOT;
 }
 
-/*
- * Returns rx queue pointer (find last set bit) according to causeRxTx
+/* Returns rx queue pointer (find last set bit) according to causeRxTx
  * value
  */
 static struct mvneta_rx_queue *mvneta_rx_policy(struct mvneta_port *pp,
@@ -1454,7 +1453,8 @@ static int mvneta_tx_frag_process(struct mvneta_port *pp, struct sk_buff *skb,
 
 error:
 	/* Release all descriptors that were used to map fragments of
-	 * this packet, as well as the corresponding DMA mappings */
+	 * this packet, as well as the corresponding DMA mappings
+	 */
 	for (i = i - 1; i >= 0; i--) {
 		tx_desc = txq->descs + i;
 		dma_unmap_single(pp->dev->dev.parent,
@@ -1546,7 +1546,8 @@ out:
 		mvneta_txq_done(pp, txq);
 
 	/* If after calling mvneta_txq_done, count equals
-		frags, we need to set the timer */
+	 * frags, we need to set the timer
+	 */
 	if (txq->count == frags && frags > 0)
 		mvneta_add_tx_done_timer(pp);
 
@@ -1598,8 +1599,7 @@ static u32 mvneta_tx_done_gbe(struct mvneta_port *pp, u32 cause_tx_done,
 	return tx_done;
 }
 
-/*
- * Compute crc8 of the specified address, using a unique algorithm ,
+/* Compute crc8 of the specified address, using a unique algorithm ,
  * according to hw spec, different than generic crc8 algorithm
  */
 static int mvneta_addr_crc(unsigned char *addr)
@@ -1828,8 +1828,7 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	cause_rx_tx = mvreg_read(pp, MVNETA_INTR_NEW_CAUSE) &
 		MVNETA_RX_INTR_MASK(rxq_number);
 
-	/*
-	 * For the case where the last mvneta_poll did not process all
+	/* For the case where the last mvneta_poll did not process all
 	 * RX packets
 	 */
 	cause_rx_tx |= pp->cause_rx_tx;
@@ -1847,10 +1846,12 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 			rx_done += count;
 			budget -= count;
 			if (budget > 0) {
-				/* set off the rx bit of the corresponding bit
-				  in the cause rx tx register, so that next
-				  iteration will find the next rx queue where
-				  packets are received on */
+				/* set off the rx bit of the
+				 * corresponding bit in the cause rx
+				 * tx register, so that next iteration
+				 * will find the next rx queue where
+				 * packets are received on
+				 */
 				cause_rx_tx &= ~((1 << rxq->id) << 8);
 			}
 		}
@@ -1925,7 +1926,8 @@ static int mvneta_rxq_fill(struct mvneta_port *pp, struct mvneta_rx_queue *rxq,
 	}
 
 	/* Add this number of RX descriptors as non occupied (ready to
-	   get packets) */
+	 * get packets)
+	 */
 	mvneta_rxq_non_occup_desc_add(pp, rxq, i);
 
 	return i;
@@ -2201,7 +2203,7 @@ static int mvneta_check_mtu_valid(struct net_device *dev, int mtu)
 		return -EINVAL;
 	}
 
-        /* 9676 == 9700 - 20 and rounding to 8 */
+	/* 9676 == 9700 - 20 and rounding to 8 */
 	if (mtu > 9676) {
 		netdev_info(dev, "Illegal MTU value %d, round to 9676\n", mtu);
 		mtu = 9676;
@@ -2231,8 +2233,7 @@ static int mvneta_change_mtu(struct net_device *dev, int mtu)
 	if (!netif_running(dev))
 		return 0;
 
-	/*
-	 * The interface is running, so we have to force a
+	/* The interface is running, so we have to force a
 	 * reallocation of the RXQs
 	 */
 	mvneta_stop_dev(pp);
@@ -2677,8 +2678,7 @@ static int __devinit mvneta_probe(struct platform_device *pdev)
 	int phy_mode;
 	int err;
 
-	/*
-	 * Our multiqueue support is not complete, so for now, only
+	/* Our multiqueue support is not complete, so for now, only
 	 * allow the usage of the first RX queue
 	 */
 	if (rxq_def != 0) {
-- 
1.7.9.5
