From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/17] sfc: Update MCDI protocol definitions
Date: Wed, 28 Apr 2010 20:29:14 +0100
Message-ID: <1272482954.2549.26.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12545 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755918Ab0D1T3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:29:17 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi_pcol.h |   71 +++++++++++++++++++++++++++++++++----------
 1 files changed, 55 insertions(+), 16 deletions(-)

diff --git a/drivers/net/sfc/mcdi_pcol.h b/drivers/net/sfc/mcdi_pcol.h
index bd59302..90359e6 100644
--- a/drivers/net/sfc/mcdi_pcol.h
+++ b/drivers/net/sfc/mcdi_pcol.h
@@ -863,7 +863,7 @@
  * bist output. The driver should only consume the BIST output
  * after validating OUTLEN and PHY_CFG.PHY_TYPE.
  *
- * If a driver can't succesfully parse the BIST output, it should
+ * If a driver can't successfully parse the BIST output, it should
  * still respect the pass/Fail in OUT.RESULT
  *
  * Locks required: PHY_LOCK if doing a  PHY BIST
@@ -872,7 +872,7 @@
 #define MC_CMD_POLL_BIST 0x26
 #define MC_CMD_POLL_BIST_IN_LEN 0
 #define MC_CMD_POLL_BIST_OUT_LEN UNKNOWN
-#define MC_CMD_POLL_BIST_OUT_SFT9001_LEN 40
+#define MC_CMD_POLL_BIST_OUT_SFT9001_LEN 36
 #define MC_CMD_POLL_BIST_OUT_MRSFP_LEN 8
 #define MC_CMD_POLL_BIST_OUT_RESULT_OFST 0
 #define MC_CMD_POLL_BIST_RUNNING 1
@@ -882,15 +882,14 @@
 /* Generic: */
 #define MC_CMD_POLL_BIST_OUT_PRIVATE_OFST 4
 /* SFT9001-specific: */
-/* (offset 4 unused?) */
-#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_A_OFST 8
-#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_B_OFST 12
-#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_C_OFST 16
-#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_D_OFST 20
-#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_A_OFST 24
-#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_B_OFST 28
-#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_C_OFST 32
-#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_D_OFST 36
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_A_OFST 4
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_B_OFST 8
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_C_OFST 12
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_D_OFST 16
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_A_OFST 20
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_B_OFST 24
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_C_OFST 28
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_D_OFST 32
 #define MC_CMD_POLL_BIST_SFT9001_PAIR_OK 1
 #define MC_CMD_POLL_BIST_SFT9001_PAIR_OPEN 2
 #define MC_CMD_POLL_BIST_SFT9001_INTRA_PAIR_SHORT 3
@@ -1054,9 +1053,13 @@
 /* MC_CMD_PHY_STATS:
  * Get generic PHY statistics
  *
- * This call returns the statistics for a generic PHY, by direct DMA
- * into host memory, in a sparse array (indexed by the enumerate).
- * Each value is represented by a 32bit number.
+ * This call returns the statistics for a generic PHY in a sparse
+ * array (indexed by the enumerate). Each value is represented by
+ * a 32bit number.
+ *
+ * If the DMA_ADDR is 0, then no DMA is performed, and the statistics
+ * may be read directly out of shared memory. If DMA_ADDR != 0, then
+ * the statistics are dmad to that (page-aligned location)
  *
  * Locks required: None
  * Returns: 0, ETIME
@@ -1066,7 +1069,8 @@
 #define MC_CMD_PHY_STATS_IN_LEN 8
 #define MC_CMD_PHY_STATS_IN_DMA_ADDR_LO_OFST 0
 #define MC_CMD_PHY_STATS_IN_DMA_ADDR_HI_OFST 4
-#define MC_CMD_PHY_STATS_OUT_LEN 0
+#define MC_CMD_PHY_STATS_OUT_DMA_LEN 0
+#define MC_CMD_PHY_STATS_OUT_NO_DMA_LEN (MC_CMD_PHY_NSTATS * 4)
 
 /* Unified MAC statistics enumeration */
 #define MC_CMD_MAC_GENERATION_START 0
@@ -1158,11 +1162,13 @@
 #define MC_CMD_MAC_STATS_CMD_CLEAR_WIDTH 1
 #define MC_CMD_MAC_STATS_CMD_PERIODIC_CHANGE_LBN 2
 #define MC_CMD_MAC_STATS_CMD_PERIODIC_CHANGE_WIDTH 1
-/* Fields only relevent when PERIODIC_CHANGE is set */
+/* Remaining PERIOD* fields only relevent when PERIODIC_CHANGE is set */
 #define MC_CMD_MAC_STATS_CMD_PERIODIC_ENABLE_LBN 3
 #define MC_CMD_MAC_STATS_CMD_PERIODIC_ENABLE_WIDTH 1
 #define MC_CMD_MAC_STATS_CMD_PERIODIC_CLEAR_LBN 4
 #define MC_CMD_MAC_STATS_CMD_PERIODIC_CLEAR_WIDTH 1
+#define MC_CMD_MAC_STATS_CMD_PERIODIC_NOEVENT_LBN 5
+#define MC_CMD_MAC_STATS_CMD_PERIODIC_NOEVENT_WIDTH 1
 #define MC_CMD_MAC_STATS_CMD_PERIOD_MS_LBN 16
 #define MC_CMD_MAC_STATS_CMD_PERIOD_MS_WIDTH 16
 #define MC_CMD_MAC_STATS_IN_DMA_LEN_OFST 12
@@ -1729,6 +1735,39 @@
 #define MC_CMD_MRSFP_TWEAK_OUT_IOEXP_OUTPUTS_OFST 4    /* output bits */
 #define MC_CMD_MRSFP_TWEAK_OUT_IOEXP_DIRECTION_OFST 8  /* dirs: 0=out, 1=in */
 
+/* MC_CMD_TEST_HACK: (debug (unsurprisingly))
+  * Change bits of network port state for test purposes in ways that would never be
+  * useful in normal operation and so need a special command to change. */
+#define MC_CMD_TEST_HACK 0x2f
+#define MC_CMD_TEST_HACK_IN_LEN 8
+#define MC_CMD_TEST_HACK_IN_TXPAD_OFST 0
+#define   MC_CMD_TEST_HACK_IN_TXPAD_AUTO  0 /* Let the MC manage things */
+#define   MC_CMD_TEST_HACK_IN_TXPAD_ON    1 /* Force on */
+#define   MC_CMD_TEST_HACK_IN_TXPAD_OFF   2 /* Force on */
+#define MC_CMD_TEST_HACK_IN_IPG_OFST   4 /* Takes a value in bits */
+#define   MC_CMD_TEST_HACK_IN_IPG_AUTO    0 /* The MC picks the value */
+#define MC_CMD_TEST_HACK_OUT_LEN 0
+
+/* MC_CMD_SENSOR_SET_LIMS: (debug) (mostly) adjust the sensor limits. This
+ * is a warranty-voiding operation.
+  *
+ * IN: sensor identifier (one of the enumeration starting with MC_CMD_SENSOR_CONTROLLER_TEMP
+ * followed by 4 32-bit values: min(warning) max(warning), min(fatal), max(fatal). Which
+ * of these limits are meaningful and what their interpretation is is sensor-specific.
+ *
+ * OUT: nothing
+ *
+ * Returns: ENOENT if the sensor specified does not exist, EINVAL if the limits are
+  * out of range.
+ */
+#define MC_CMD_SENSOR_SET_LIMS 0x4e
+#define MC_CMD_SENSOR_SET_LIMS_IN_LEN 20
+#define MC_CMD_SENSOR_SET_LIMS_IN_SENSOR_OFST 0
+#define MC_CMD_SENSOR_SET_LIMS_IN_LOW0_OFST 4
+#define MC_CMD_SENSOR_SET_LIMS_IN_HI0_OFST  8
+#define MC_CMD_SENSOR_SET_LIMS_IN_LOW1_OFST 12
+#define MC_CMD_SENSOR_SET_LIMS_IN_HI1_OFST  16
+
 /* Do NOT add new commands beyond 0x4f as part of 3.0 : 0x50 - 0x7f will be
  * used for post-3.0 extensions. If you run out of space, look for gaps or
  * commands that are unused in the existing range. */
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

