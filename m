From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] add more tg3 hardware stats to ethtool -S
Date: Wed, 12 May 2004 20:37:10 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40A1FE56.37308F98@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

G'day,

This patch adds a bunch of the more obscure tg3 hardware stats to the
output of "ethtool -S".  Some of these are useful for diagnosing
performance problems, others are just for completeness.


Index: linux/drivers/net/tg3.c
===================================================================
--- linux.orig/drivers/net/tg3.c	Mon May 10 12:32:38 2004
+++ linux/drivers/net/tg3.c	Wed May 12 20:34:18 2004
@@ -126,7 +126,8 @@
 /* minimum number of free TX descriptors required to wake up TX process */
 #define TG3_TX_WAKEUP_THRESH		(TG3_TX_RING_SIZE / 4)
 
-#define TG3_NUM_STATS		25	/* number of ETHTOOL_GSTATS u64's */
+/* number of ETHTOOL_GSTATS u64's */
+#define TG3_NUM_STATS		(sizeof(struct tg3_ethtool_stats)/sizeof(u64))
 
 static char version[] __devinitdata =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
@@ -204,10 +205,13 @@
 struct {
 	char string[ETH_GSTRING_LEN];
 } ethtool_stats_keys[TG3_NUM_STATS] = {
+	{ "rx_octets" },
 	{ "rx_fragments" },
 	{ "rx_ucast_packets" },
+	{ "rx_mcast_packets" },
 	{ "rx_bcast_packets" },
 	{ "rx_fcs_errors" },
+	{ "rx_align_errors" },
 	{ "rx_xon_pause_rcvd" },
 	{ "rx_xoff_pause_rcvd" },
 	{ "rx_mac_ctrl_rcvd" },
@@ -217,6 +221,19 @@
 	{ "rx_undersize_packets" },
 	{ "rx_in_length_errors" },
 	{ "rx_out_length_errors" },
+	{ "rx_64_or_less_octet_packets" },
+	{ "rx_65_to_127_octet_packets" },
+	{ "rx_128_to_255_octet_packets" },
+	{ "rx_256_to_511_octet_packets" },
+	{ "rx_512_to_1023_octet_packets" },
+	{ "rx_1024_to_1522_octet_packets" },
+	{ "rx_1523_to_2047_octet_packets" },
+	{ "rx_2048_to_4095_octet_packets" },
+	{ "rx_4096_to_8191_octet_packets" },
+	{ "rx_8192_to_9022_octet_packets" },
+
+	{ "tx_octets" },
+	{ "tx_collisions" },
 
 	{ "tx_xon_sent" },
 	{ "tx_xoff_sent" },
@@ -227,9 +244,43 @@
 	{ "tx_deferred" },
 	{ "tx_excessive_collisions" },
 	{ "tx_late_collisions" },
+	{ "tx_collide_2times" },
+	{ "tx_collide_3times" },
+	{ "tx_collide_4times" },
+	{ "tx_collide_5times" },
+	{ "tx_collide_6times" },
+	{ "tx_collide_7times" },
+	{ "tx_collide_8times" },
+	{ "tx_collide_9times" },
+	{ "tx_collide_10times" },
+	{ "tx_collide_11times" },
+	{ "tx_collide_12times" },
+	{ "tx_collide_13times" },
+	{ "tx_collide_14times" },
+	{ "tx_collide_15times" },
 	{ "tx_ucast_packets" },
 	{ "tx_mcast_packets" },
-	{ "tx_bcast_packets" }
+	{ "tx_bcast_packets" },
+	{ "tx_carrier_sense_errors" },
+	{ "tx_discards" },
+	{ "tx_errors" },
+
+	{ "dma_writeq_full" },
+	{ "dma_write_prioq_full" },
+	{ "rxbds_empty" },
+	{ "rx_discards" },
+	{ "rx_errors" },
+	{ "rx_threshold_hit" },
+
+	{ "dma_readq_full" },
+	{ "dma_read_prioq_full" },
+	{ "tx_comp_queue_full" },
+
+	{ "ring_set_send_prod_index" },
+	{ "ring_status_update" },
+	{ "nic_irqs" },
+	{ "nic_avoided_irqs" },
+	{ "nic_tx_threshold_hit" }
 };
 
 static void tg3_write_indirect_reg32(struct tg3 *tp, u32 off, u32 val)
@@ -5709,10 +5760,13 @@
 	if (!hw_stats)
 		return old_estats;
 
+	ESTAT_ADD(rx_octets);
 	ESTAT_ADD(rx_fragments);
 	ESTAT_ADD(rx_ucast_packets);
+	ESTAT_ADD(rx_mcast_packets);
 	ESTAT_ADD(rx_bcast_packets);
 	ESTAT_ADD(rx_fcs_errors);
+	ESTAT_ADD(rx_align_errors);
 	ESTAT_ADD(rx_xon_pause_rcvd);
 	ESTAT_ADD(rx_xoff_pause_rcvd);
 	ESTAT_ADD(rx_mac_ctrl_rcvd);
@@ -5722,7 +5776,19 @@
 	ESTAT_ADD(rx_undersize_packets);
 	ESTAT_ADD(rx_in_length_errors);
 	ESTAT_ADD(rx_out_length_errors);
+	ESTAT_ADD(rx_64_or_less_octet_packets);
+	ESTAT_ADD(rx_65_to_127_octet_packets);
+	ESTAT_ADD(rx_128_to_255_octet_packets);
+	ESTAT_ADD(rx_256_to_511_octet_packets);
+	ESTAT_ADD(rx_512_to_1023_octet_packets);
+	ESTAT_ADD(rx_1024_to_1522_octet_packets);
+	ESTAT_ADD(rx_1523_to_2047_octet_packets);
+	ESTAT_ADD(rx_2048_to_4095_octet_packets);
+	ESTAT_ADD(rx_4096_to_8191_octet_packets);
+	ESTAT_ADD(rx_8192_to_9022_octet_packets);
 
+	ESTAT_ADD(tx_octets);
+	ESTAT_ADD(tx_collisions);
 	ESTAT_ADD(tx_xon_sent);
 	ESTAT_ADD(tx_xoff_sent);
 	ESTAT_ADD(tx_flow_control);
@@ -5732,9 +5798,43 @@
 	ESTAT_ADD(tx_deferred);
 	ESTAT_ADD(tx_excessive_collisions);
 	ESTAT_ADD(tx_late_collisions);
+	ESTAT_ADD(tx_collide_2times);
+	ESTAT_ADD(tx_collide_3times);
+	ESTAT_ADD(tx_collide_4times);
+	ESTAT_ADD(tx_collide_5times);
+	ESTAT_ADD(tx_collide_6times);
+	ESTAT_ADD(tx_collide_7times);
+	ESTAT_ADD(tx_collide_8times);
+	ESTAT_ADD(tx_collide_9times);
+	ESTAT_ADD(tx_collide_10times);
+	ESTAT_ADD(tx_collide_11times);
+	ESTAT_ADD(tx_collide_12times);
+	ESTAT_ADD(tx_collide_13times);
+	ESTAT_ADD(tx_collide_14times);
+	ESTAT_ADD(tx_collide_15times);
 	ESTAT_ADD(tx_ucast_packets);
 	ESTAT_ADD(tx_mcast_packets);
 	ESTAT_ADD(tx_bcast_packets);
+	ESTAT_ADD(tx_carrier_sense_errors);
+	ESTAT_ADD(tx_discards);
+	ESTAT_ADD(tx_errors);
+
+	ESTAT_ADD(dma_writeq_full);
+	ESTAT_ADD(dma_write_prioq_full);
+	ESTAT_ADD(rxbds_empty);
+	ESTAT_ADD(rx_discards);
+	ESTAT_ADD(rx_errors);
+	ESTAT_ADD(rx_threshold_hit);
+
+	ESTAT_ADD(dma_readq_full);
+	ESTAT_ADD(dma_read_prioq_full);
+	ESTAT_ADD(tx_comp_queue_full);
+
+	ESTAT_ADD(ring_set_send_prod_index);
+	ESTAT_ADD(ring_status_update);
+	ESTAT_ADD(nic_irqs);
+	ESTAT_ADD(nic_avoided_irqs);
+	ESTAT_ADD(nic_tx_threshold_hit);
 
 	return estats;
 }
Index: linux/drivers/net/tg3.h
===================================================================
--- linux.orig/drivers/net/tg3.h	Mon May 10 12:32:02 2004
+++ linux/drivers/net/tg3.h	Wed May 12 19:31:41 2004
@@ -1819,10 +1819,13 @@
 
 struct tg3_ethtool_stats {
 	/* Statistics maintained by Receive MAC. */
+	u64 	    	rx_octets;
 	u64		rx_fragments;
 	u64		rx_ucast_packets;
+	u64		rx_mcast_packets;
 	u64		rx_bcast_packets;
 	u64		rx_fcs_errors;
+	u64		rx_align_errors;
 	u64		rx_xon_pause_rcvd;
 	u64		rx_xoff_pause_rcvd;
 	u64		rx_mac_ctrl_rcvd;
@@ -1832,8 +1835,20 @@
 	u64		rx_undersize_packets;
 	u64		rx_in_length_errors;
 	u64		rx_out_length_errors;
+	u64		rx_64_or_less_octet_packets;
+	u64		rx_65_to_127_octet_packets;
+	u64		rx_128_to_255_octet_packets;
+	u64		rx_256_to_511_octet_packets;
+	u64		rx_512_to_1023_octet_packets;
+	u64		rx_1024_to_1522_octet_packets;
+	u64		rx_1523_to_2047_octet_packets;
+	u64		rx_2048_to_4095_octet_packets;
+	u64		rx_4096_to_8191_octet_packets;
+	u64		rx_8192_to_9022_octet_packets;
 
 	/* Statistics maintained by Transmit MAC. */
+	u64		tx_octets;
+	u64		tx_collisions;
 	u64		tx_xon_sent;
 	u64		tx_xoff_sent;
 	u64		tx_flow_control;
@@ -1843,9 +1858,46 @@
 	u64		tx_deferred;
 	u64		tx_excessive_collisions;
 	u64		tx_late_collisions;
+	u64		tx_collide_2times;
+	u64		tx_collide_3times;
+	u64		tx_collide_4times;
+	u64		tx_collide_5times;
+	u64		tx_collide_6times;
+	u64		tx_collide_7times;
+	u64		tx_collide_8times;
+	u64		tx_collide_9times;
+	u64		tx_collide_10times;
+	u64		tx_collide_11times;
+	u64		tx_collide_12times;
+	u64		tx_collide_13times;
+	u64		tx_collide_14times;
+	u64		tx_collide_15times;
 	u64		tx_ucast_packets;
 	u64		tx_mcast_packets;
 	u64		tx_bcast_packets;
+	u64		tx_carrier_sense_errors;
+	u64		tx_discards;
+	u64		tx_errors;
+
+	/* Statistics maintained by Receive List Placement. */
+	u64		dma_writeq_full;
+	u64		dma_write_prioq_full;
+	u64		rxbds_empty;
+	u64		rx_discards;
+	u64		rx_errors;
+	u64		rx_threshold_hit;
+
+	/* Statistics maintained by Send Data Initiator. */
+	u64		dma_readq_full;
+	u64		dma_read_prioq_full;
+	u64		tx_comp_queue_full;
+
+	/* Statistics maintained by Host Coalescing. */
+	u64		ring_set_send_prod_index;
+	u64		ring_status_update;
+	u64		nic_irqs;
+	u64		nic_avoided_irqs;
+	u64		nic_tx_threshold_hit;
 };
 
 struct tg3 {



Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
