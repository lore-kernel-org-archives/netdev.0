From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 02/15] e1000e: checkpatch error - macro panethesis
Date: Fri, 24 Dec 2010 22:06:01 -0800
Message-ID: <1293257174-15498-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832Ab0LYGGr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:06:47 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

ERROR: Macros with complex values should be enclosed in parenthesis

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ethtool.c |  114 ++++++++++++++++++++++--------------------
 drivers/net/e1000e/netdev.c  |    2 +-
 2 files changed, 60 insertions(+), 56 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 39349d6..15c6330 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -45,63 +45,67 @@ struct e1000_stats {
 	int stat_offset;
 };
 
-#define E1000_STAT(m)		E1000_STATS, \
-				sizeof(((struct e1000_adapter *)0)->m), \
-		      		offsetof(struct e1000_adapter, m)
-#define E1000_NETDEV_STAT(m)	NETDEV_STATS, \
-				sizeof(((struct net_device *)0)->m), \
-				offsetof(struct net_device, m)
+#define E1000_STAT(str, m) { \
+			.stat_string = str, \
+			.type = E1000_STATS, \
+			.sizeof_stat = sizeof(((struct e1000_adapter *)0)->m), \
+			.stat_offset = offsetof(struct e1000_adapter, m) }
+#define E1000_NETDEV_STAT(str, m) { \
+			.stat_string = str, \
+			.type = NETDEV_STATS, \
+			.sizeof_stat = sizeof(((struct net_device *)0)->m), \
+			.stat_offset = offsetof(struct net_device, m) }
 
 static const struct e1000_stats e1000_gstrings_stats[] = {
-	{ "rx_packets", E1000_STAT(stats.gprc) },
-	{ "tx_packets", E1000_STAT(stats.gptc) },
-	{ "rx_bytes", E1000_STAT(stats.gorc) },
-	{ "tx_bytes", E1000_STAT(stats.gotc) },
-	{ "rx_broadcast", E1000_STAT(stats.bprc) },
-	{ "tx_broadcast", E1000_STAT(stats.bptc) },
-	{ "rx_multicast", E1000_STAT(stats.mprc) },
-	{ "tx_multicast", E1000_STAT(stats.mptc) },
-	{ "rx_errors", E1000_NETDEV_STAT(stats.rx_errors) },
-	{ "tx_errors", E1000_NETDEV_STAT(stats.tx_errors) },
-	{ "tx_dropped", E1000_NETDEV_STAT(stats.tx_dropped) },
-	{ "multicast", E1000_STAT(stats.mprc) },
-	{ "collisions", E1000_STAT(stats.colc) },
-	{ "rx_length_errors", E1000_NETDEV_STAT(stats.rx_length_errors) },
-	{ "rx_over_errors", E1000_NETDEV_STAT(stats.rx_over_errors) },
-	{ "rx_crc_errors", E1000_STAT(stats.crcerrs) },
-	{ "rx_frame_errors", E1000_NETDEV_STAT(stats.rx_frame_errors) },
-	{ "rx_no_buffer_count", E1000_STAT(stats.rnbc) },
-	{ "rx_missed_errors", E1000_STAT(stats.mpc) },
-	{ "tx_aborted_errors", E1000_STAT(stats.ecol) },
-	{ "tx_carrier_errors", E1000_STAT(stats.tncrs) },
-	{ "tx_fifo_errors", E1000_NETDEV_STAT(stats.tx_fifo_errors) },
-	{ "tx_heartbeat_errors", E1000_NETDEV_STAT(stats.tx_heartbeat_errors) },
-	{ "tx_window_errors", E1000_STAT(stats.latecol) },
-	{ "tx_abort_late_coll", E1000_STAT(stats.latecol) },
-	{ "tx_deferred_ok", E1000_STAT(stats.dc) },
-	{ "tx_single_coll_ok", E1000_STAT(stats.scc) },
-	{ "tx_multi_coll_ok", E1000_STAT(stats.mcc) },
-	{ "tx_timeout_count", E1000_STAT(tx_timeout_count) },
-	{ "tx_restart_queue", E1000_STAT(restart_queue) },
-	{ "rx_long_length_errors", E1000_STAT(stats.roc) },
-	{ "rx_short_length_errors", E1000_STAT(stats.ruc) },
-	{ "rx_align_errors", E1000_STAT(stats.algnerrc) },
-	{ "tx_tcp_seg_good", E1000_STAT(stats.tsctc) },
-	{ "tx_tcp_seg_failed", E1000_STAT(stats.tsctfc) },
-	{ "rx_flow_control_xon", E1000_STAT(stats.xonrxc) },
-	{ "rx_flow_control_xoff", E1000_STAT(stats.xoffrxc) },
-	{ "tx_flow_control_xon", E1000_STAT(stats.xontxc) },
-	{ "tx_flow_control_xoff", E1000_STAT(stats.xofftxc) },
-	{ "rx_long_byte_count", E1000_STAT(stats.gorc) },
-	{ "rx_csum_offload_good", E1000_STAT(hw_csum_good) },
-	{ "rx_csum_offload_errors", E1000_STAT(hw_csum_err) },
-	{ "rx_header_split", E1000_STAT(rx_hdr_split) },
-	{ "alloc_rx_buff_failed", E1000_STAT(alloc_rx_buff_failed) },
-	{ "tx_smbus", E1000_STAT(stats.mgptc) },
-	{ "rx_smbus", E1000_STAT(stats.mgprc) },
-	{ "dropped_smbus", E1000_STAT(stats.mgpdc) },
-	{ "rx_dma_failed", E1000_STAT(rx_dma_failed) },
-	{ "tx_dma_failed", E1000_STAT(tx_dma_failed) },
+	E1000_STAT("rx_packets", stats.gprc),
+	E1000_STAT("tx_packets", stats.gptc),
+	E1000_STAT("rx_bytes", stats.gorc),
+	E1000_STAT("tx_bytes", stats.gotc),
+	E1000_STAT("rx_broadcast", stats.bprc),
+	E1000_STAT("tx_broadcast", stats.bptc),
+	E1000_STAT("rx_multicast", stats.mprc),
+	E1000_STAT("tx_multicast", stats.mptc),
+	E1000_NETDEV_STAT("rx_errors", stats.rx_errors),
+	E1000_NETDEV_STAT("tx_errors", stats.tx_errors),
+	E1000_NETDEV_STAT("tx_dropped", stats.tx_dropped),
+	E1000_STAT("multicast", stats.mprc),
+	E1000_STAT("collisions", stats.colc),
+	E1000_NETDEV_STAT("rx_length_errors", stats.rx_length_errors),
+	E1000_NETDEV_STAT("rx_over_errors", stats.rx_over_errors),
+	E1000_STAT("rx_crc_errors", stats.crcerrs),
+	E1000_NETDEV_STAT("rx_frame_errors", stats.rx_frame_errors),
+	E1000_STAT("rx_no_buffer_count", stats.rnbc),
+	E1000_STAT("rx_missed_errors", stats.mpc),
+	E1000_STAT("tx_aborted_errors", stats.ecol),
+	E1000_STAT("tx_carrier_errors", stats.tncrs),
+	E1000_NETDEV_STAT("tx_fifo_errors", stats.tx_fifo_errors),
+	E1000_NETDEV_STAT("tx_heartbeat_errors", stats.tx_heartbeat_errors),
+	E1000_STAT("tx_window_errors", stats.latecol),
+	E1000_STAT("tx_abort_late_coll", stats.latecol),
+	E1000_STAT("tx_deferred_ok", stats.dc),
+	E1000_STAT("tx_single_coll_ok", stats.scc),
+	E1000_STAT("tx_multi_coll_ok", stats.mcc),
+	E1000_STAT("tx_timeout_count", tx_timeout_count),
+	E1000_STAT("tx_restart_queue", restart_queue),
+	E1000_STAT("rx_long_length_errors", stats.roc),
+	E1000_STAT("rx_short_length_errors", stats.ruc),
+	E1000_STAT("rx_align_errors", stats.algnerrc),
+	E1000_STAT("tx_tcp_seg_good", stats.tsctc),
+	E1000_STAT("tx_tcp_seg_failed", stats.tsctfc),
+	E1000_STAT("rx_flow_control_xon", stats.xonrxc),
+	E1000_STAT("rx_flow_control_xoff", stats.xoffrxc),
+	E1000_STAT("tx_flow_control_xon", stats.xontxc),
+	E1000_STAT("tx_flow_control_xoff", stats.xofftxc),
+	E1000_STAT("rx_long_byte_count", stats.gorc),
+	E1000_STAT("rx_csum_offload_good", hw_csum_good),
+	E1000_STAT("rx_csum_offload_errors", hw_csum_err),
+	E1000_STAT("rx_header_split", rx_hdr_split),
+	E1000_STAT("alloc_rx_buff_failed", alloc_rx_buff_failed),
+	E1000_STAT("tx_smbus", stats.mgptc),
+	E1000_STAT("rx_smbus", stats.mgprc),
+	E1000_STAT("dropped_smbus", stats.mgpdc),
+	E1000_STAT("rx_dma_failed", rx_dma_failed),
+	E1000_STAT("tx_dma_failed", tx_dma_failed),
 };
 
 #define E1000_GLOBAL_STATS_LEN	ARRAY_SIZE(e1000_gstrings_stats)
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index a45dafd..ec7b77f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1325,7 +1325,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				goto next_desc;
 		}
 
-#define rxtop rx_ring->rx_skb_top
+#define rxtop (rx_ring->rx_skb_top)
 		if (!(status & E1000_RXD_STAT_EOP)) {
 			/* this descriptor is only the beginning (or middle) */
 			if (!rxtop) {
-- 
1.7.3.4

