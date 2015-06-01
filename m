From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v2 04/14] sfc: add "port_" prefix to MAC stats
Date: Mon, 1 Jun 2015 14:01:17 +0100
Message-ID: <556C579D.7010209@solarflare.com>
References: <556C5704.4060901@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:52728 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753162AbbFANC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 09:02:28 -0400
In-Reply-To: <556C5704.4060901@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The MAC stats are per-port and will only be displayed on the PF
with control of the link (one per physical port). Vadapter stats
will also be displayed for this PF, so distinguish the MAC stats
by adding a prefix of "port_".

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c      | 251 ++++++++++++++++++-----------------
 drivers/net/ethernet/sfc/mcdi_pcol.h |   4 +-
 drivers/net/ethernet/sfc/nic.h       | 106 +++++++--------
 3 files changed, 182 insertions(+), 179 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 714e7cf..a574dd3 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -990,93 +990,94 @@ static int efx_ef10_reset(struct efx_nic *efx, enum reset_type reset_type)
 	[GENERIC_STAT_ ## ext_name] = { #ext_name, 0, 0 }
 
 static const struct efx_hw_stat_desc efx_ef10_stat_desc[EF10_STAT_COUNT] = {
-	EF10_DMA_STAT(tx_bytes, TX_BYTES),
-	EF10_DMA_STAT(tx_packets, TX_PKTS),
-	EF10_DMA_STAT(tx_pause, TX_PAUSE_PKTS),
-	EF10_DMA_STAT(tx_control, TX_CONTROL_PKTS),
-	EF10_DMA_STAT(tx_unicast, TX_UNICAST_PKTS),
-	EF10_DMA_STAT(tx_multicast, TX_MULTICAST_PKTS),
-	EF10_DMA_STAT(tx_broadcast, TX_BROADCAST_PKTS),
-	EF10_DMA_STAT(tx_lt64, TX_LT64_PKTS),
-	EF10_DMA_STAT(tx_64, TX_64_PKTS),
-	EF10_DMA_STAT(tx_65_to_127, TX_65_TO_127_PKTS),
-	EF10_DMA_STAT(tx_128_to_255, TX_128_TO_255_PKTS),
-	EF10_DMA_STAT(tx_256_to_511, TX_256_TO_511_PKTS),
-	EF10_DMA_STAT(tx_512_to_1023, TX_512_TO_1023_PKTS),
-	EF10_DMA_STAT(tx_1024_to_15xx, TX_1024_TO_15XX_PKTS),
-	EF10_DMA_STAT(tx_15xx_to_jumbo, TX_15XX_TO_JUMBO_PKTS),
-	EF10_DMA_STAT(rx_bytes, RX_BYTES),
-	EF10_DMA_INVIS_STAT(rx_bytes_minus_good_bytes, RX_BAD_BYTES),
-	EF10_OTHER_STAT(rx_good_bytes),
-	EF10_OTHER_STAT(rx_bad_bytes),
-	EF10_DMA_STAT(rx_packets, RX_PKTS),
-	EF10_DMA_STAT(rx_good, RX_GOOD_PKTS),
-	EF10_DMA_STAT(rx_bad, RX_BAD_FCS_PKTS),
-	EF10_DMA_STAT(rx_pause, RX_PAUSE_PKTS),
-	EF10_DMA_STAT(rx_control, RX_CONTROL_PKTS),
-	EF10_DMA_STAT(rx_unicast, RX_UNICAST_PKTS),
-	EF10_DMA_STAT(rx_multicast, RX_MULTICAST_PKTS),
-	EF10_DMA_STAT(rx_broadcast, RX_BROADCAST_PKTS),
-	EF10_DMA_STAT(rx_lt64, RX_UNDERSIZE_PKTS),
-	EF10_DMA_STAT(rx_64, RX_64_PKTS),
-	EF10_DMA_STAT(rx_65_to_127, RX_65_TO_127_PKTS),
-	EF10_DMA_STAT(rx_128_to_255, RX_128_TO_255_PKTS),
-	EF10_DMA_STAT(rx_256_to_511, RX_256_TO_511_PKTS),
-	EF10_DMA_STAT(rx_512_to_1023, RX_512_TO_1023_PKTS),
-	EF10_DMA_STAT(rx_1024_to_15xx, RX_1024_TO_15XX_PKTS),
-	EF10_DMA_STAT(rx_15xx_to_jumbo, RX_15XX_TO_JUMBO_PKTS),
-	EF10_DMA_STAT(rx_gtjumbo, RX_GTJUMBO_PKTS),
-	EF10_DMA_STAT(rx_bad_gtjumbo, RX_JABBER_PKTS),
-	EF10_DMA_STAT(rx_overflow, RX_OVERFLOW_PKTS),
-	EF10_DMA_STAT(rx_align_error, RX_ALIGN_ERROR_PKTS),
-	EF10_DMA_STAT(rx_length_error, RX_LENGTH_ERROR_PKTS),
-	EF10_DMA_STAT(rx_nodesc_drops, RX_NODESC_DROPS),
+	EF10_DMA_STAT(port_tx_bytes, TX_BYTES),
+	EF10_DMA_STAT(port_tx_packets, TX_PKTS),
+	EF10_DMA_STAT(port_tx_pause, TX_PAUSE_PKTS),
+	EF10_DMA_STAT(port_tx_control, TX_CONTROL_PKTS),
+	EF10_DMA_STAT(port_tx_unicast, TX_UNICAST_PKTS),
+	EF10_DMA_STAT(port_tx_multicast, TX_MULTICAST_PKTS),
+	EF10_DMA_STAT(port_tx_broadcast, TX_BROADCAST_PKTS),
+	EF10_DMA_STAT(port_tx_lt64, TX_LT64_PKTS),
+	EF10_DMA_STAT(port_tx_64, TX_64_PKTS),
+	EF10_DMA_STAT(port_tx_65_to_127, TX_65_TO_127_PKTS),
+	EF10_DMA_STAT(port_tx_128_to_255, TX_128_TO_255_PKTS),
+	EF10_DMA_STAT(port_tx_256_to_511, TX_256_TO_511_PKTS),
+	EF10_DMA_STAT(port_tx_512_to_1023, TX_512_TO_1023_PKTS),
+	EF10_DMA_STAT(port_tx_1024_to_15xx, TX_1024_TO_15XX_PKTS),
+	EF10_DMA_STAT(port_tx_15xx_to_jumbo, TX_15XX_TO_JUMBO_PKTS),
+	EF10_DMA_STAT(port_rx_bytes, RX_BYTES),
+	EF10_DMA_INVIS_STAT(port_rx_bytes_minus_good_bytes, RX_BAD_BYTES),
+	EF10_OTHER_STAT(port_rx_good_bytes),
+	EF10_OTHER_STAT(port_rx_bad_bytes),
+	EF10_DMA_STAT(port_rx_packets, RX_PKTS),
+	EF10_DMA_STAT(port_rx_good, RX_GOOD_PKTS),
+	EF10_DMA_STAT(port_rx_bad, RX_BAD_FCS_PKTS),
+	EF10_DMA_STAT(port_rx_pause, RX_PAUSE_PKTS),
+	EF10_DMA_STAT(port_rx_control, RX_CONTROL_PKTS),
+	EF10_DMA_STAT(port_rx_unicast, RX_UNICAST_PKTS),
+	EF10_DMA_STAT(port_rx_multicast, RX_MULTICAST_PKTS),
+	EF10_DMA_STAT(port_rx_broadcast, RX_BROADCAST_PKTS),
+	EF10_DMA_STAT(port_rx_lt64, RX_UNDERSIZE_PKTS),
+	EF10_DMA_STAT(port_rx_64, RX_64_PKTS),
+	EF10_DMA_STAT(port_rx_65_to_127, RX_65_TO_127_PKTS),
+	EF10_DMA_STAT(port_rx_128_to_255, RX_128_TO_255_PKTS),
+	EF10_DMA_STAT(port_rx_256_to_511, RX_256_TO_511_PKTS),
+	EF10_DMA_STAT(port_rx_512_to_1023, RX_512_TO_1023_PKTS),
+	EF10_DMA_STAT(port_rx_1024_to_15xx, RX_1024_TO_15XX_PKTS),
+	EF10_DMA_STAT(port_rx_15xx_to_jumbo, RX_15XX_TO_JUMBO_PKTS),
+	EF10_DMA_STAT(port_rx_gtjumbo, RX_GTJUMBO_PKTS),
+	EF10_DMA_STAT(port_rx_bad_gtjumbo, RX_JABBER_PKTS),
+	EF10_DMA_STAT(port_rx_overflow, RX_OVERFLOW_PKTS),
+	EF10_DMA_STAT(port_rx_align_error, RX_ALIGN_ERROR_PKTS),
+	EF10_DMA_STAT(port_rx_length_error, RX_LENGTH_ERROR_PKTS),
+	EF10_DMA_STAT(port_rx_nodesc_drops, RX_NODESC_DROPS),
 	GENERIC_SW_STAT(rx_nodesc_trunc),
 	GENERIC_SW_STAT(rx_noskb_drops),
-	EF10_DMA_STAT(rx_pm_trunc_bb_overflow, PM_TRUNC_BB_OVERFLOW),
-	EF10_DMA_STAT(rx_pm_discard_bb_overflow, PM_DISCARD_BB_OVERFLOW),
-	EF10_DMA_STAT(rx_pm_trunc_vfifo_full, PM_TRUNC_VFIFO_FULL),
-	EF10_DMA_STAT(rx_pm_discard_vfifo_full, PM_DISCARD_VFIFO_FULL),
-	EF10_DMA_STAT(rx_pm_trunc_qbb, PM_TRUNC_QBB),
-	EF10_DMA_STAT(rx_pm_discard_qbb, PM_DISCARD_QBB),
-	EF10_DMA_STAT(rx_pm_discard_mapping, PM_DISCARD_MAPPING),
-	EF10_DMA_STAT(rx_dp_q_disabled_packets, RXDP_Q_DISABLED_PKTS),
-	EF10_DMA_STAT(rx_dp_di_dropped_packets, RXDP_DI_DROPPED_PKTS),
-	EF10_DMA_STAT(rx_dp_streaming_packets, RXDP_STREAMING_PKTS),
-	EF10_DMA_STAT(rx_dp_hlb_fetch, RXDP_EMERGENCY_FETCH_CONDITIONS),
-	EF10_DMA_STAT(rx_dp_hlb_wait, RXDP_EMERGENCY_WAIT_CONDITIONS),
+	EF10_DMA_STAT(port_rx_pm_trunc_bb_overflow, PM_TRUNC_BB_OVERFLOW),
+	EF10_DMA_STAT(port_rx_pm_discard_bb_overflow, PM_DISCARD_BB_OVERFLOW),
+	EF10_DMA_STAT(port_rx_pm_trunc_vfifo_full, PM_TRUNC_VFIFO_FULL),
+	EF10_DMA_STAT(port_rx_pm_discard_vfifo_full, PM_DISCARD_VFIFO_FULL),
+	EF10_DMA_STAT(port_rx_pm_trunc_qbb, PM_TRUNC_QBB),
+	EF10_DMA_STAT(port_rx_pm_discard_qbb, PM_DISCARD_QBB),
+	EF10_DMA_STAT(port_rx_pm_discard_mapping, PM_DISCARD_MAPPING),
+	EF10_DMA_STAT(port_rx_dp_q_disabled_packets, RXDP_Q_DISABLED_PKTS),
+	EF10_DMA_STAT(port_rx_dp_di_dropped_packets, RXDP_DI_DROPPED_PKTS),
+	EF10_DMA_STAT(port_rx_dp_streaming_packets, RXDP_STREAMING_PKTS),
+	EF10_DMA_STAT(port_rx_dp_hlb_fetch, RXDP_HLB_FETCH_CONDITIONS),
+	EF10_DMA_STAT(port_rx_dp_hlb_wait, RXDP_HLB_WAIT_CONDITIONS),
 };
 
-#define HUNT_COMMON_STAT_MASK ((1ULL << EF10_STAT_tx_bytes) |		\
-			       (1ULL << EF10_STAT_tx_packets) |		\
-			       (1ULL << EF10_STAT_tx_pause) |		\
-			       (1ULL << EF10_STAT_tx_unicast) |		\
-			       (1ULL << EF10_STAT_tx_multicast) |	\
-			       (1ULL << EF10_STAT_tx_broadcast) |	\
-			       (1ULL << EF10_STAT_rx_bytes) |		\
-			       (1ULL << EF10_STAT_rx_bytes_minus_good_bytes) | \
-			       (1ULL << EF10_STAT_rx_good_bytes) |	\
-			       (1ULL << EF10_STAT_rx_bad_bytes) |	\
-			       (1ULL << EF10_STAT_rx_packets) |		\
-			       (1ULL << EF10_STAT_rx_good) |		\
-			       (1ULL << EF10_STAT_rx_bad) |		\
-			       (1ULL << EF10_STAT_rx_pause) |		\
-			       (1ULL << EF10_STAT_rx_control) |		\
-			       (1ULL << EF10_STAT_rx_unicast) |		\
-			       (1ULL << EF10_STAT_rx_multicast) |	\
-			       (1ULL << EF10_STAT_rx_broadcast) |	\
-			       (1ULL << EF10_STAT_rx_lt64) |		\
-			       (1ULL << EF10_STAT_rx_64) |		\
-			       (1ULL << EF10_STAT_rx_65_to_127) |	\
-			       (1ULL << EF10_STAT_rx_128_to_255) |	\
-			       (1ULL << EF10_STAT_rx_256_to_511) |	\
-			       (1ULL << EF10_STAT_rx_512_to_1023) |	\
-			       (1ULL << EF10_STAT_rx_1024_to_15xx) |	\
-			       (1ULL << EF10_STAT_rx_15xx_to_jumbo) |	\
-			       (1ULL << EF10_STAT_rx_gtjumbo) |		\
-			       (1ULL << EF10_STAT_rx_bad_gtjumbo) |	\
-			       (1ULL << EF10_STAT_rx_overflow) |	\
-			       (1ULL << EF10_STAT_rx_nodesc_drops) |	\
+#define HUNT_COMMON_STAT_MASK ((1ULL << EF10_STAT_port_tx_bytes) |	\
+			       (1ULL << EF10_STAT_port_tx_packets) |	\
+			       (1ULL << EF10_STAT_port_tx_pause) |	\
+			       (1ULL << EF10_STAT_port_tx_unicast) |	\
+			       (1ULL << EF10_STAT_port_tx_multicast) |	\
+			       (1ULL << EF10_STAT_port_tx_broadcast) |	\
+			       (1ULL << EF10_STAT_port_rx_bytes) |	\
+			       (1ULL <<                                 \
+				EF10_STAT_port_rx_bytes_minus_good_bytes) | \
+			       (1ULL << EF10_STAT_port_rx_good_bytes) |	\
+			       (1ULL << EF10_STAT_port_rx_bad_bytes) |	\
+			       (1ULL << EF10_STAT_port_rx_packets) |	\
+			       (1ULL << EF10_STAT_port_rx_good) |	\
+			       (1ULL << EF10_STAT_port_rx_bad) |	\
+			       (1ULL << EF10_STAT_port_rx_pause) |	\
+			       (1ULL << EF10_STAT_port_rx_control) |	\
+			       (1ULL << EF10_STAT_port_rx_unicast) |	\
+			       (1ULL << EF10_STAT_port_rx_multicast) |	\
+			       (1ULL << EF10_STAT_port_rx_broadcast) |	\
+			       (1ULL << EF10_STAT_port_rx_lt64) |	\
+			       (1ULL << EF10_STAT_port_rx_64) |		\
+			       (1ULL << EF10_STAT_port_rx_65_to_127) |	\
+			       (1ULL << EF10_STAT_port_rx_128_to_255) |	\
+			       (1ULL << EF10_STAT_port_rx_256_to_511) |	\
+			       (1ULL << EF10_STAT_port_rx_512_to_1023) |\
+			       (1ULL << EF10_STAT_port_rx_1024_to_15xx) |\
+			       (1ULL << EF10_STAT_port_rx_15xx_to_jumbo) |\
+			       (1ULL << EF10_STAT_port_rx_gtjumbo) |	\
+			       (1ULL << EF10_STAT_port_rx_bad_gtjumbo) |\
+			       (1ULL << EF10_STAT_port_rx_overflow) |	\
+			       (1ULL << EF10_STAT_port_rx_nodesc_drops) |\
 			       (1ULL << GENERIC_STAT_rx_nodesc_trunc) |	\
 			       (1ULL << GENERIC_STAT_rx_noskb_drops))
 
@@ -1084,39 +1085,39 @@ static const struct efx_hw_stat_desc efx_ef10_stat_desc[EF10_STAT_COUNT] = {
  * switchable port we do not expose these because they might not
  * include all the packets they should.
  */
-#define HUNT_10G_ONLY_STAT_MASK ((1ULL << EF10_STAT_tx_control) |	\
-				 (1ULL << EF10_STAT_tx_lt64) |		\
-				 (1ULL << EF10_STAT_tx_64) |		\
-				 (1ULL << EF10_STAT_tx_65_to_127) |	\
-				 (1ULL << EF10_STAT_tx_128_to_255) |	\
-				 (1ULL << EF10_STAT_tx_256_to_511) |	\
-				 (1ULL << EF10_STAT_tx_512_to_1023) |	\
-				 (1ULL << EF10_STAT_tx_1024_to_15xx) |	\
-				 (1ULL << EF10_STAT_tx_15xx_to_jumbo))
+#define HUNT_10G_ONLY_STAT_MASK ((1ULL << EF10_STAT_port_tx_control) |	\
+				 (1ULL << EF10_STAT_port_tx_lt64) |	\
+				 (1ULL << EF10_STAT_port_tx_64) |	\
+				 (1ULL << EF10_STAT_port_tx_65_to_127) |\
+				 (1ULL << EF10_STAT_port_tx_128_to_255) |\
+				 (1ULL << EF10_STAT_port_tx_256_to_511) |\
+				 (1ULL << EF10_STAT_port_tx_512_to_1023) |\
+				 (1ULL << EF10_STAT_port_tx_1024_to_15xx) |\
+				 (1ULL << EF10_STAT_port_tx_15xx_to_jumbo))
 
 /* These statistics are only provided by the 40G MAC.  For a 10G/40G
  * switchable port we do expose these because the errors will otherwise
  * be silent.
  */
-#define HUNT_40G_EXTRA_STAT_MASK ((1ULL << EF10_STAT_rx_align_error) |	\
-				  (1ULL << EF10_STAT_rx_length_error))
+#define HUNT_40G_EXTRA_STAT_MASK ((1ULL << EF10_STAT_port_rx_align_error) |\
+				  (1ULL << EF10_STAT_port_rx_length_error))
 
 /* These statistics are only provided if the firmware supports the
  * capability PM_AND_RXDP_COUNTERS.
  */
 #define HUNT_PM_AND_RXDP_STAT_MASK (					\
-	(1ULL << EF10_STAT_rx_pm_trunc_bb_overflow) |			\
-	(1ULL << EF10_STAT_rx_pm_discard_bb_overflow) |			\
-	(1ULL << EF10_STAT_rx_pm_trunc_vfifo_full) |			\
-	(1ULL << EF10_STAT_rx_pm_discard_vfifo_full) |			\
-	(1ULL << EF10_STAT_rx_pm_trunc_qbb) |				\
-	(1ULL << EF10_STAT_rx_pm_discard_qbb) |				\
-	(1ULL << EF10_STAT_rx_pm_discard_mapping) |			\
-	(1ULL << EF10_STAT_rx_dp_q_disabled_packets) |			\
-	(1ULL << EF10_STAT_rx_dp_di_dropped_packets) |			\
-	(1ULL << EF10_STAT_rx_dp_streaming_packets) |			\
-	(1ULL << EF10_STAT_rx_dp_hlb_fetch) |				\
-	(1ULL << EF10_STAT_rx_dp_hlb_wait))
+	(1ULL << EF10_STAT_port_rx_pm_trunc_bb_overflow) |		\
+	(1ULL << EF10_STAT_port_rx_pm_discard_bb_overflow) |		\
+	(1ULL << EF10_STAT_port_rx_pm_trunc_vfifo_full) |		\
+	(1ULL << EF10_STAT_port_rx_pm_discard_vfifo_full) |		\
+	(1ULL << EF10_STAT_port_rx_pm_trunc_qbb) |			\
+	(1ULL << EF10_STAT_port_rx_pm_discard_qbb) |			\
+	(1ULL << EF10_STAT_port_rx_pm_discard_mapping) |		\
+	(1ULL << EF10_STAT_port_rx_dp_q_disabled_packets) |		\
+	(1ULL << EF10_STAT_port_rx_dp_di_dropped_packets) |		\
+	(1ULL << EF10_STAT_port_rx_dp_streaming_packets) |		\
+	(1ULL << EF10_STAT_port_rx_dp_hlb_fetch) |			\
+	(1ULL << EF10_STAT_port_rx_dp_hlb_wait))
 
 static u64 efx_ef10_raw_stat_mask(struct efx_nic *efx)
 {
@@ -1182,12 +1183,13 @@ static int efx_ef10_try_update_nic_stats(struct efx_nic *efx)
 		return -EAGAIN;
 
 	/* Update derived statistics */
-	efx_nic_fix_nodesc_drop_stat(efx, &stats[EF10_STAT_rx_nodesc_drops]);
-	stats[EF10_STAT_rx_good_bytes] =
-		stats[EF10_STAT_rx_bytes] -
-		stats[EF10_STAT_rx_bytes_minus_good_bytes];
-	efx_update_diff_stat(&stats[EF10_STAT_rx_bad_bytes],
-			     stats[EF10_STAT_rx_bytes_minus_good_bytes]);
+	efx_nic_fix_nodesc_drop_stat(efx,
+				     &stats[EF10_STAT_port_rx_nodesc_drops]);
+	stats[EF10_STAT_port_rx_good_bytes] =
+		stats[EF10_STAT_port_rx_bytes] -
+		stats[EF10_STAT_port_rx_bytes_minus_good_bytes];
+	efx_update_diff_stat(&stats[EF10_STAT_port_rx_bad_bytes],
+			     stats[EF10_STAT_port_rx_bytes_minus_good_bytes]);
 	efx_update_sw_stats(efx, stats);
 	return 0;
 }
@@ -1223,20 +1225,21 @@ static size_t efx_ef10_update_stats(struct efx_nic *efx, u64 *full_stats,
 	}
 
 	if (core_stats) {
-		core_stats->rx_packets = stats[EF10_STAT_rx_packets];
-		core_stats->tx_packets = stats[EF10_STAT_tx_packets];
-		core_stats->rx_bytes = stats[EF10_STAT_rx_bytes];
-		core_stats->tx_bytes = stats[EF10_STAT_tx_bytes];
-		core_stats->rx_dropped = stats[EF10_STAT_rx_nodesc_drops] +
+		core_stats->rx_packets = stats[EF10_STAT_port_rx_packets];
+		core_stats->tx_packets = stats[EF10_STAT_port_tx_packets];
+		core_stats->rx_bytes = stats[EF10_STAT_port_rx_bytes];
+		core_stats->tx_bytes = stats[EF10_STAT_port_tx_bytes];
+		core_stats->rx_dropped = stats[EF10_STAT_port_rx_nodesc_drops] +
 					 stats[GENERIC_STAT_rx_nodesc_trunc] +
 					 stats[GENERIC_STAT_rx_noskb_drops];
-		core_stats->multicast = stats[EF10_STAT_rx_multicast];
+		core_stats->multicast = stats[EF10_STAT_port_rx_multicast];
 		core_stats->rx_length_errors =
-			stats[EF10_STAT_rx_gtjumbo] +
-			stats[EF10_STAT_rx_length_error];
-		core_stats->rx_crc_errors = stats[EF10_STAT_rx_bad];
-		core_stats->rx_frame_errors = stats[EF10_STAT_rx_align_error];
-		core_stats->rx_fifo_errors = stats[EF10_STAT_rx_overflow];
+			stats[EF10_STAT_port_rx_gtjumbo] +
+			stats[EF10_STAT_port_rx_length_error];
+		core_stats->rx_crc_errors = stats[EF10_STAT_port_rx_bad];
+		core_stats->rx_frame_errors =
+			stats[EF10_STAT_port_rx_align_error];
+		core_stats->rx_fifo_errors = stats[EF10_STAT_port_rx_overflow];
 		core_stats->rx_errors = (core_stats->rx_length_errors +
 					 core_stats->rx_crc_errors +
 					 core_stats->rx_frame_errors);
@@ -1371,7 +1374,7 @@ static int efx_ef10_mcdi_poll_reboot(struct efx_nic *efx)
 	/* MAC statistics have been cleared on the NIC; clear the local
 	 * statistic that we update with efx_update_diff_stat().
 	 */
-	nic_data->stats[EF10_STAT_rx_bad_bytes] = 0;
+	nic_data->stats[EF10_STAT_port_rx_bad_bytes] = 0;
 
 	return -EIO;
 }
diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 9efdf0a..1e11bb8 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -2891,11 +2891,11 @@
 /* enum: RXDP counter: Number of times an emergency descriptor fetch was
  * performed. Valid for EF10 with PM_AND_RXDP_COUNTERS capability only.
  */
-#define          MC_CMD_MAC_RXDP_EMERGENCY_FETCH_CONDITIONS  0x47
+#define          MC_CMD_MAC_RXDP_HLB_FETCH_CONDITIONS  0x47
 /* enum: RXDP counter: Number of times the DPCPU waited for an existing
  * descriptor fetch. Valid for EF10 with PM_AND_RXDP_COUNTERS capability only.
  */
-#define          MC_CMD_MAC_RXDP_EMERGENCY_WAIT_CONDITIONS  0x48
+#define          MC_CMD_MAC_RXDP_HLB_WAIT_CONDITIONS  0x48
 /* enum: Start of GMAC stats buffer space, for Siena only. */
 #define          MC_CMD_GMAC_DMABUF_START  0x40
 /* enum: End of GMAC stats buffer space, for Siena only. */
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index e146e30..8b69a31 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -407,59 +407,59 @@ struct siena_nic_data {
 };
 
 enum {
-	EF10_STAT_tx_bytes = GENERIC_STAT_COUNT,
-	EF10_STAT_tx_packets,
-	EF10_STAT_tx_pause,
-	EF10_STAT_tx_control,
-	EF10_STAT_tx_unicast,
-	EF10_STAT_tx_multicast,
-	EF10_STAT_tx_broadcast,
-	EF10_STAT_tx_lt64,
-	EF10_STAT_tx_64,
-	EF10_STAT_tx_65_to_127,
-	EF10_STAT_tx_128_to_255,
-	EF10_STAT_tx_256_to_511,
-	EF10_STAT_tx_512_to_1023,
-	EF10_STAT_tx_1024_to_15xx,
-	EF10_STAT_tx_15xx_to_jumbo,
-	EF10_STAT_rx_bytes,
-	EF10_STAT_rx_bytes_minus_good_bytes,
-	EF10_STAT_rx_good_bytes,
-	EF10_STAT_rx_bad_bytes,
-	EF10_STAT_rx_packets,
-	EF10_STAT_rx_good,
-	EF10_STAT_rx_bad,
-	EF10_STAT_rx_pause,
-	EF10_STAT_rx_control,
-	EF10_STAT_rx_unicast,
-	EF10_STAT_rx_multicast,
-	EF10_STAT_rx_broadcast,
-	EF10_STAT_rx_lt64,
-	EF10_STAT_rx_64,
-	EF10_STAT_rx_65_to_127,
-	EF10_STAT_rx_128_to_255,
-	EF10_STAT_rx_256_to_511,
-	EF10_STAT_rx_512_to_1023,
-	EF10_STAT_rx_1024_to_15xx,
-	EF10_STAT_rx_15xx_to_jumbo,
-	EF10_STAT_rx_gtjumbo,
-	EF10_STAT_rx_bad_gtjumbo,
-	EF10_STAT_rx_overflow,
-	EF10_STAT_rx_align_error,
-	EF10_STAT_rx_length_error,
-	EF10_STAT_rx_nodesc_drops,
-	EF10_STAT_rx_pm_trunc_bb_overflow,
-	EF10_STAT_rx_pm_discard_bb_overflow,
-	EF10_STAT_rx_pm_trunc_vfifo_full,
-	EF10_STAT_rx_pm_discard_vfifo_full,
-	EF10_STAT_rx_pm_trunc_qbb,
-	EF10_STAT_rx_pm_discard_qbb,
-	EF10_STAT_rx_pm_discard_mapping,
-	EF10_STAT_rx_dp_q_disabled_packets,
-	EF10_STAT_rx_dp_di_dropped_packets,
-	EF10_STAT_rx_dp_streaming_packets,
-	EF10_STAT_rx_dp_hlb_fetch,
-	EF10_STAT_rx_dp_hlb_wait,
+	EF10_STAT_port_tx_bytes = GENERIC_STAT_COUNT,
+	EF10_STAT_port_tx_packets,
+	EF10_STAT_port_tx_pause,
+	EF10_STAT_port_tx_control,
+	EF10_STAT_port_tx_unicast,
+	EF10_STAT_port_tx_multicast,
+	EF10_STAT_port_tx_broadcast,
+	EF10_STAT_port_tx_lt64,
+	EF10_STAT_port_tx_64,
+	EF10_STAT_port_tx_65_to_127,
+	EF10_STAT_port_tx_128_to_255,
+	EF10_STAT_port_tx_256_to_511,
+	EF10_STAT_port_tx_512_to_1023,
+	EF10_STAT_port_tx_1024_to_15xx,
+	EF10_STAT_port_tx_15xx_to_jumbo,
+	EF10_STAT_port_rx_bytes,
+	EF10_STAT_port_rx_bytes_minus_good_bytes,
+	EF10_STAT_port_rx_good_bytes,
+	EF10_STAT_port_rx_bad_bytes,
+	EF10_STAT_port_rx_packets,
+	EF10_STAT_port_rx_good,
+	EF10_STAT_port_rx_bad,
+	EF10_STAT_port_rx_pause,
+	EF10_STAT_port_rx_control,
+	EF10_STAT_port_rx_unicast,
+	EF10_STAT_port_rx_multicast,
+	EF10_STAT_port_rx_broadcast,
+	EF10_STAT_port_rx_lt64,
+	EF10_STAT_port_rx_64,
+	EF10_STAT_port_rx_65_to_127,
+	EF10_STAT_port_rx_128_to_255,
+	EF10_STAT_port_rx_256_to_511,
+	EF10_STAT_port_rx_512_to_1023,
+	EF10_STAT_port_rx_1024_to_15xx,
+	EF10_STAT_port_rx_15xx_to_jumbo,
+	EF10_STAT_port_rx_gtjumbo,
+	EF10_STAT_port_rx_bad_gtjumbo,
+	EF10_STAT_port_rx_overflow,
+	EF10_STAT_port_rx_align_error,
+	EF10_STAT_port_rx_length_error,
+	EF10_STAT_port_rx_nodesc_drops,
+	EF10_STAT_port_rx_pm_trunc_bb_overflow,
+	EF10_STAT_port_rx_pm_discard_bb_overflow,
+	EF10_STAT_port_rx_pm_trunc_vfifo_full,
+	EF10_STAT_port_rx_pm_discard_vfifo_full,
+	EF10_STAT_port_rx_pm_trunc_qbb,
+	EF10_STAT_port_rx_pm_discard_qbb,
+	EF10_STAT_port_rx_pm_discard_mapping,
+	EF10_STAT_port_rx_dp_q_disabled_packets,
+	EF10_STAT_port_rx_dp_di_dropped_packets,
+	EF10_STAT_port_rx_dp_streaming_packets,
+	EF10_STAT_port_rx_dp_hlb_fetch,
+	EF10_STAT_port_rx_dp_hlb_wait,
 	EF10_STAT_COUNT
 };
 
