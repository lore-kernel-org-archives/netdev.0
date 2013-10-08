From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 4/6] sfc: Add definitions for new stats counters and
 capability flag
Date: Tue, 8 Oct 2013 18:44:23 +0100
Message-ID: <1381254263.1530.14.camel@bwh-desktop.uk.level5networks.com>
References: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56454 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473Ab3JHRo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 13:44:27 -0400
In-Reply-To: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Slattery <mslattery@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h | 56 ++++++++++++++++++++++++++++++++++--
 1 file changed, 54 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index b5cf624..e0a63dd 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -2574,8 +2574,58 @@
 #define          MC_CMD_MAC_RX_LANES01_DISP_ERR  0x39 /* enum */
 #define          MC_CMD_MAC_RX_LANES23_DISP_ERR  0x3a /* enum */
 #define          MC_CMD_MAC_RX_MATCH_FAULT  0x3b /* enum */
-#define          MC_CMD_GMAC_DMABUF_START  0x40 /* enum */
-#define          MC_CMD_GMAC_DMABUF_END    0x5f /* enum */
+/* enum: PM trunc_bb_overflow counter. Valid for EF10 with PM_AND_RXDP_COUNTERS
+ * capability only.
+ */
+#define          MC_CMD_MAC_PM_TRUNC_BB_OVERFLOW  0x3c
+/* enum: PM discard_bb_overflow counter. Valid for EF10 with
+ * PM_AND_RXDP_COUNTERS capability only.
+ */
+#define          MC_CMD_MAC_PM_DISCARD_BB_OVERFLOW  0x3d
+/* enum: PM trunc_vfifo_full counter. Valid for EF10 with PM_AND_RXDP_COUNTERS
+ * capability only.
+ */
+#define          MC_CMD_MAC_PM_TRUNC_VFIFO_FULL  0x3e
+/* enum: PM discard_vfifo_full counter. Valid for EF10 with
+ * PM_AND_RXDP_COUNTERS capability only.
+ */
+#define          MC_CMD_MAC_PM_DISCARD_VFIFO_FULL  0x3f
+/* enum: PM trunc_qbb counter. Valid for EF10 with PM_AND_RXDP_COUNTERS
+ * capability only.
+ */
+#define          MC_CMD_MAC_PM_TRUNC_QBB  0x40
+/* enum: PM discard_qbb counter. Valid for EF10 with PM_AND_RXDP_COUNTERS
+ * capability only.
+ */
+#define          MC_CMD_MAC_PM_DISCARD_QBB  0x41
+/* enum: PM discard_mapping counter. Valid for EF10 with PM_AND_RXDP_COUNTERS
+ * capability only.
+ */
+#define          MC_CMD_MAC_PM_DISCARD_MAPPING  0x42
+/* enum: RXDP counter: Number of packets dropped due to the queue being
+ * disabled. Valid for EF10 with PM_AND_RXDP_COUNTERS capability only.
+ */
+#define          MC_CMD_MAC_RXDP_Q_DISABLED_PKTS  0x43
+/* enum: RXDP counter: Number of packets dropped by the DICPU. Valid for EF10
+ * with PM_AND_RXDP_COUNTERS capability only.
+ */
+#define          MC_CMD_MAC_RXDP_DI_DROPPED_PKTS  0x45
+/* enum: RXDP counter: Number of non-host packets. Valid for EF10 with
+ * PM_AND_RXDP_COUNTERS capability only.
+ */
+#define          MC_CMD_MAC_RXDP_STREAMING_PKTS  0x46
+/* enum: RXDP counter: Number of times an emergency descriptor fetch was
+ * performed. Valid for EF10 with PM_AND_RXDP_COUNTERS capability only.
+ */
+#define          MC_CMD_MAC_RXDP_EMERGENCY_FETCH_CONDITIONS  0x47
+/* enum: RXDP counter: Number of times the DPCPU waited for an existing
+ * descriptor fetch. Valid for EF10 with PM_AND_RXDP_COUNTERS capability only.
+ */
+#define          MC_CMD_MAC_RXDP_EMERGENCY_WAIT_CONDITIONS  0x48
+/* enum: Start of GMAC stats buffer space, for Siena only. */
+#define          MC_CMD_GMAC_DMABUF_START  0x40
+/* enum: End of GMAC stats buffer space, for Siena only. */
+#define          MC_CMD_GMAC_DMABUF_END    0x5f
 #define          MC_CMD_MAC_GENERATION_END 0x60 /* enum */
 #define          MC_CMD_MAC_NSTATS  0x61 /* enum */
 
@@ -5065,6 +5115,8 @@
 #define        MC_CMD_GET_CAPABILITIES_OUT_RX_BATCHING_WIDTH 1
 #define        MC_CMD_GET_CAPABILITIES_OUT_MCAST_FILTER_CHAINING_LBN 26
 #define        MC_CMD_GET_CAPABILITIES_OUT_MCAST_FILTER_CHAINING_WIDTH 1
+#define        MC_CMD_GET_CAPABILITIES_OUT_PM_AND_RXDP_COUNTERS_LBN 27
+#define        MC_CMD_GET_CAPABILITIES_OUT_PM_AND_RXDP_COUNTERS_WIDTH 1
 /* RxDPCPU firmware id. */
 #define       MC_CMD_GET_CAPABILITIES_OUT_RX_DPCPU_FW_ID_OFST 4
 #define       MC_CMD_GET_CAPABILITIES_OUT_RX_DPCPU_FW_ID_LEN 2


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
