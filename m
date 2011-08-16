From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/5] ethtool: Reformat struct ethtool_coalesce
 comments into kernel-doc format
Date: Tue, 16 Aug 2011 01:06:20 +0100
Message-ID: <1313453180.2731.57.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eli Cohen <eli@dev.mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41014 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab1HPAG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 20:06:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reorders and duplicates some wording, but should make no
substantive changes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |  135 ++++++++++++++++++++++-------------------------
 1 files changed, 64 insertions(+), 71 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c6e427a..be32dd0 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -117,99 +117,92 @@ struct ethtool_eeprom {
 	__u8	data[0];
 };
 
-/* for configuring coalescing parameters of chip */
+/**
+ * struct ethtool_coalesce - coalescing parameters of chip
+ * @cmd: ETHTOOL_{G,S}COALESCE
+ * @rx_coalesce_usecs: How many usecs to delay an RX interrupt after
+ *	a packet arrives.  If 0, only @rx_max_coalesced_frames is used.
+ * @rx_max_coalesced_frames: How many packets to delay an RX interrupt
+ *	after a packet arrives.  If 0, only @rx_coalesce_usecs is used.
+ * @rx_coalesce_usecs_irq: Same as @rx_coalesce_usecs, except that
+ *	this value applies while an IRQ is being serviced by the host.
+ * @rx_max_coalesced_frames_irq: Same as @rx_max_coalesced_frames,
+ *	except that this value applies while an IRQ is being serviced
+ *	by the host.
+ * @tx_coalesce_usecs: How many usecs to delay a TX interrupt after
+ *	a packet is sent.  If 0, only @tx_max_coalesced_frames
+ *	is used.
+ * @tx_max_coalesced_frames: How many packets to delay a TX interrupt
+ *	after a packet is sent.  If 0, only @tx_coalesce_usecs is
+ *	used.
+ * @tx_coalesce_usecs_irq: Same as @tx_coalesce_usecs, except that
+ *	this value applies while an IRQ is being serviced by the host.
+ * @tx_max_coalesced_frames_irq: Same as @tx_max_coalesced_frames,
+ *	except that this value applies while an IRQ is being serviced
+ *	by the host.
+ * @stats_block_coalesce_usecs: How many usecs to delay in-memory
+ *	statistics block updates.  Some drivers do not have an
+ *	in-memory statistic block, and in such cases this value is
+ *	ignored.  This value must not be zero.
+ * @use_adaptive_rx_coalesce: Enable adaptive RX coalescing.
+ * @use_adaptive_tx_coalesce: Enable adaptive TX coalescing.
+ * @pkt_rate_low: Threshold for low packet rate (packets per second).
+ * @rx_coalesce_usecs_low: How many usecs to delay an RX interrupt after
+ *	a packet arrives, when the packet rate is below @pkt_rate_low.
+ * @rx_max_coalesced_frames_low: How many packets to delay an RX interrupt
+ *	after a packet arrives, when the packet rate is below @pkt_rate_low.
+ * @tx_coalesce_usecs_low: How many usecs to delay a TX interrupt after
+ *	a packet is sent, when the packet rate is below @pkt_rate_low.
+ * @tx_max_coalesced_frames_low: How many packets to delay a TX interrupt
+ *	after a packet is sent, when the packet rate is below @pkt_rate_low.
+ * @pkt_rate_high: Threshold for high packet rate (packets per second).
+ * @rx_coalesce_usecs_high: How many usecs to delay an RX interrupt after
+ *	a packet arrives, when the packet rate is above @pkt_rate_high.
+ * @rx_max_coalesced_frames_high: How many packets to delay an RX interrupt
+ *	after a packet arrives, when the packet rate is above @pkt_rate_high.
+ * @tx_coalesce_usecs_high: How many usecs to delay a TX interrupt after
+ *	a packet is sent, when the packet rate is above @pkt_rate_high.
+ * @tx_max_coalesced_frames_high: How many packets to delay a TX interrupt
+ *	after a packet is sent, when the packet rate is above @pkt_rate_high.
+ * @rate_sample_interval: How often to do adaptive coalescing packet rate
+ *	sampling, measured in seconds.  Must not be zero.
+ *
+ * It is illegal to set both usecs and max frames to zero as this
+ * would cause interrupts to never be generated.
+ *
+ * Adaptive RX/TX coalescing is an algorithm implemented by some
+ * drivers to improve latency under low packet rates and improve
+ * throughput under high packet rates.  Some drivers only implement
+ * one of RX or TX adaptive coalescing.  Anything not implemented by
+ * the driver causes these values to be silently ignored.
+ *
+ * When the packet rate is below @pkt_rate_high but above
+ * @pkt_rate_low (both measured in packets per second) the
+ * normal {rx,tx}_* coalescing parameters are used.
+ */
 struct ethtool_coalesce {
-	__u32	cmd;	/* ETHTOOL_{G,S}COALESCE */
-
-	/* How many usecs to delay an RX interrupt after
-	 * a packet arrives.  If 0, only rx_max_coalesced_frames
-	 * is used.
-	 */
+	__u32	cmd;
 	__u32	rx_coalesce_usecs;
-
-	/* How many packets to delay an RX interrupt after
-	 * a packet arrives.  If 0, only rx_coalesce_usecs is
-	 * used.  It is illegal to set both usecs and max frames
-	 * to zero as this would cause RX interrupts to never be
-	 * generated.
-	 */
 	__u32	rx_max_coalesced_frames;
-
-	/* Same as above two parameters, except that these values
-	 * apply while an IRQ is being serviced by the host.  Not
-	 * all cards support this feature and the values are ignored
-	 * in that case.
-	 */
 	__u32	rx_coalesce_usecs_irq;
 	__u32	rx_max_coalesced_frames_irq;
-
-	/* How many usecs to delay a TX interrupt after
-	 * a packet is sent.  If 0, only tx_max_coalesced_frames
-	 * is used.
-	 */
 	__u32	tx_coalesce_usecs;
-
-	/* How many packets to delay a TX interrupt after
-	 * a packet is sent.  If 0, only tx_coalesce_usecs is
-	 * used.  It is illegal to set both usecs and max frames
-	 * to zero as this would cause TX interrupts to never be
-	 * generated.
-	 */
 	__u32	tx_max_coalesced_frames;
-
-	/* Same as above two parameters, except that these values
-	 * apply while an IRQ is being serviced by the host.  Not
-	 * all cards support this feature and the values are ignored
-	 * in that case.
-	 */
 	__u32	tx_coalesce_usecs_irq;
 	__u32	tx_max_coalesced_frames_irq;
-
-	/* How many usecs to delay in-memory statistics
-	 * block updates.  Some drivers do not have an in-memory
-	 * statistic block, and in such cases this value is ignored.
-	 * This value must not be zero.
-	 */
 	__u32	stats_block_coalesce_usecs;
-
-	/* Adaptive RX/TX coalescing is an algorithm implemented by
-	 * some drivers to improve latency under low packet rates and
-	 * improve throughput under high packet rates.  Some drivers
-	 * only implement one of RX or TX adaptive coalescing.  Anything
-	 * not implemented by the driver causes these values to be
-	 * silently ignored.
-	 */
 	__u32	use_adaptive_rx_coalesce;
 	__u32	use_adaptive_tx_coalesce;
-
-	/* When the packet rate (measured in packets per second)
-	 * is below pkt_rate_low, the {rx,tx}_*_low parameters are
-	 * used.
-	 */
 	__u32	pkt_rate_low;
 	__u32	rx_coalesce_usecs_low;
 	__u32	rx_max_coalesced_frames_low;
 	__u32	tx_coalesce_usecs_low;
 	__u32	tx_max_coalesced_frames_low;
-
-	/* When the packet rate is below pkt_rate_high but above
-	 * pkt_rate_low (both measured in packets per second) the
-	 * normal {rx,tx}_* coalescing parameters are used.
-	 */
-
-	/* When the packet rate is (measured in packets per second)
-	 * is above pkt_rate_high, the {rx,tx}_*_high parameters are
-	 * used.
-	 */
 	__u32	pkt_rate_high;
 	__u32	rx_coalesce_usecs_high;
 	__u32	rx_max_coalesced_frames_high;
 	__u32	tx_coalesce_usecs_high;
 	__u32	tx_max_coalesced_frames_high;
-
-	/* How often to do adaptive coalescing packet rate sampling,
-	 * measured in seconds.  Must not be zero.
-	 */
 	__u32	rate_sample_interval;
 };
 
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

