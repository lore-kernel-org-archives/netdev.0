From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/10] sfc: Update MCDI protocol definitions
Date: Wed, 03 Feb 2010 19:28:14 +0000
Message-ID: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27787 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024Ab0BCT2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 14:28:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi_pcol.h |  202 ++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 179 insertions(+), 23 deletions(-)

diff --git a/drivers/net/sfc/mcdi_pcol.h b/drivers/net/sfc/mcdi_pcol.h
index 73e71f4..bd59302 100644
--- a/drivers/net/sfc/mcdi_pcol.h
+++ b/drivers/net/sfc/mcdi_pcol.h
@@ -786,16 +786,18 @@
 #define MC_CMD_GET_PHY_CFG_OUT_FLAGS_OFST 0
 #define MC_CMD_GET_PHY_CFG_PRESENT_LBN 0
 #define MC_CMD_GET_PHY_CFG_PRESENT_WIDTH 1
-#define MC_CMD_GET_PHY_CFG_SHORTBIST_LBN 1
-#define MC_CMD_GET_PHY_CFG_SHORTBIST_WIDTH 1
-#define MC_CMD_GET_PHY_CFG_LONGBIST_LBN 2
-#define MC_CMD_GET_PHY_CFG_LONGBIST_WIDTH 1
+#define MC_CMD_GET_PHY_CFG_BIST_CABLE_SHORT_LBN 1
+#define MC_CMD_GET_PHY_CFG_BIST_CABLE_SHORT_WIDTH 1
+#define MC_CMD_GET_PHY_CFG_BIST_CABLE_LONG_LBN 2
+#define MC_CMD_GET_PHY_CFG_BIST_CABLE_LONG_WIDTH 1
 #define MC_CMD_GET_PHY_CFG_LOWPOWER_LBN 3
 #define MC_CMD_GET_PHY_CFG_LOWPOWER_WIDTH 1
 #define MC_CMD_GET_PHY_CFG_POWEROFF_LBN 4
 #define MC_CMD_GET_PHY_CFG_POWEROFF_WIDTH 1
 #define MC_CMD_GET_PHY_CFG_TXDIS_LBN 5
 #define MC_CMD_GET_PHY_CFG_TXDIS_WIDTH 1
+#define MC_CMD_GET_PHY_CFG_BIST_LBN 6
+#define MC_CMD_GET_PHY_CFG_BIST_WIDTH 1
 #define MC_CMD_GET_PHY_CFG_OUT_TYPE_OFST 4
 /* Bitmask of supported capabilities */
 #define MC_CMD_GET_PHY_CFG_OUT_SUPPORTED_CAP_OFST 8
@@ -832,7 +834,7 @@
 #define MC_CMD_GET_PHY_CFG_OUT_REVISION_OFST 52
 #define MC_CMD_GET_PHY_CFG_OUT_REVISION_LEN 20
 
-/* MC_CMD_START_PHY_BIST:
+/* MC_CMD_START_BIST:
  * Start a BIST test on the PHY.
  *
  * Locks required: PHY_LOCK if doing a  PHY BIST
@@ -840,34 +842,71 @@
  */
 #define MC_CMD_START_BIST 0x25
 #define MC_CMD_START_BIST_IN_LEN 4
-#define MC_CMD_START_BIST_TYPE_OFST 0
+#define MC_CMD_START_BIST_IN_TYPE_OFST 0
+#define MC_CMD_START_BIST_OUT_LEN 0
 
-/* Run the PHY's short BIST */
-#define MC_CMD_PHY_BIST_SHORT  1
-/* Run the PHY's long BIST */
-#define MC_CMD_PHY_BIST_LONG   2
+/* Run the PHY's short cable BIST */
+#define MC_CMD_PHY_BIST_CABLE_SHORT  1
+/* Run the PHY's long cable BIST */
+#define MC_CMD_PHY_BIST_CABLE_LONG   2
 /* Run BIST on the currently selected BPX Serdes (XAUI or XFI) */
 #define MC_CMD_BPX_SERDES_BIST 3
+/* Run the MC loopback tests */
+#define MC_CMD_MC_LOOPBACK_BIST 4
+/* Run the PHY's standard BIST */
+#define MC_CMD_PHY_BIST 5
 
 /* MC_CMD_POLL_PHY_BIST: (variadic output)
  * Poll for BIST completion
  *
- * Returns a single status code, and a binary blob of phy-specific
- * bist output. If the driver can't succesfully parse the BIST output,
- * it should still respect the Pass/Fail in OUT.RESULT.
+ * Returns a single status code, and optionally some PHY specific
+ * bist output. The driver should only consume the BIST output
+ * after validating OUTLEN and PHY_CFG.PHY_TYPE.
  *
- * Locks required: PHY_LOCK  if doing a  PHY BIST
+ * If a driver can't succesfully parse the BIST output, it should
+ * still respect the pass/Fail in OUT.RESULT
+ *
+ * Locks required: PHY_LOCK if doing a  PHY BIST
  * Return code: 0, EACCES (if PHY_LOCK is not held)
  */
 #define MC_CMD_POLL_BIST 0x26
 #define MC_CMD_POLL_BIST_IN_LEN 0
 #define MC_CMD_POLL_BIST_OUT_LEN UNKNOWN
+#define MC_CMD_POLL_BIST_OUT_SFT9001_LEN 40
+#define MC_CMD_POLL_BIST_OUT_MRSFP_LEN 8
 #define MC_CMD_POLL_BIST_OUT_RESULT_OFST 0
 #define MC_CMD_POLL_BIST_RUNNING 1
 #define MC_CMD_POLL_BIST_PASSED 2
 #define MC_CMD_POLL_BIST_FAILED 3
 #define MC_CMD_POLL_BIST_TIMEOUT 4
+/* Generic: */
 #define MC_CMD_POLL_BIST_OUT_PRIVATE_OFST 4
+/* SFT9001-specific: */
+/* (offset 4 unused?) */
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_A_OFST 8
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_B_OFST 12
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_C_OFST 16
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_LENGTH_D_OFST 20
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_A_OFST 24
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_B_OFST 28
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_C_OFST 32
+#define MC_CMD_POLL_BIST_OUT_SFT9001_CABLE_STATUS_D_OFST 36
+#define MC_CMD_POLL_BIST_SFT9001_PAIR_OK 1
+#define MC_CMD_POLL_BIST_SFT9001_PAIR_OPEN 2
+#define MC_CMD_POLL_BIST_SFT9001_INTRA_PAIR_SHORT 3
+#define MC_CMD_POLL_BIST_SFT9001_INTER_PAIR_SHORT 4
+#define MC_CMD_POLL_BIST_SFT9001_PAIR_BUSY 9
+/* mrsfp "PHY" driver: */
+#define MC_CMD_POLL_BIST_OUT_MRSFP_TEST_OFST 4
+#define MC_CMD_POLL_BIST_MRSFP_TEST_COMPLETE 0
+#define MC_CMD_POLL_BIST_MRSFP_TEST_BUS_SWITCH_OFF_I2C_WRITE 1
+#define MC_CMD_POLL_BIST_MRSFP_TEST_BUS_SWITCH_OFF_I2C_NO_ACCESS_IO_EXP 2
+#define MC_CMD_POLL_BIST_MRSFP_TEST_BUS_SWITCH_OFF_I2C_NO_ACCESS_MODULE 3
+#define MC_CMD_POLL_BIST_MRSFP_TEST_IO_EXP_I2C_CONFIGURE 4
+#define MC_CMD_POLL_BIST_MRSFP_TEST_BUS_SWITCH_I2C_NO_CROSSTALK 5
+#define MC_CMD_POLL_BIST_MRSFP_TEST_MODULE_PRESENCE 6
+#define MC_CMD_POLL_BIST_MRSFP_TEST_MODULE_ID_I2C_ACCESS 7
+#define MC_CMD_POLL_BIST_MRSFP_TEST_MODULE_ID_SANE_VALUE 8
 
 /* MC_CMD_PHY_SPI: (variadic in, variadic out)
  * Read/Write/Erase the PHY SPI device
@@ -1206,6 +1245,13 @@
 #define MC_CMD_WOL_FILTER_SET_IN_BITMAP_LAYER4_OFST	\
 	(MC_CMD_WOL_FILTER_SET_IN_DATA_OFST + 178)
 
+#define MC_CMD_WOL_FILTER_SET_IN_LINK_MASK_OFST	\
+	MC_CMD_WOL_FILTER_SET_IN_DATA_OFST
+#define MC_CMD_WOL_FILTER_SET_IN_LINK_UP_LBN	0
+#define MC_CMD_WOL_FILTER_SET_IN_LINK_UP_WIDTH	1
+#define MC_CMD_WOL_FILTER_SET_IN_LINK_DOWN_LBN	1
+#define MC_CMD_WOL_FILTER_SET_IN_LINK_DOWN_WIDTH 1
+
 #define MC_CMD_WOL_FILTER_SET_OUT_LEN 4
 #define MC_CMD_WOL_FILTER_SET_OUT_FILTER_ID_OFST 0
 
@@ -1216,7 +1262,8 @@
 #define MC_CMD_WOL_TYPE_IPV4_SYN   0x3
 #define MC_CMD_WOL_TYPE_IPV6_SYN   0x4
 #define MC_CMD_WOL_TYPE_BITMAP     0x5
-#define MC_CMD_WOL_TYPE_MAX        0x6
+#define MC_CMD_WOL_TYPE_LINK       0x6
+#define MC_CMD_WOL_TYPE_MAX        0x7
 
 #define MC_CMD_FILTER_MODE_SIMPLE     0x0
 #define MC_CMD_FILTER_MODE_STRUCTURED 0xffffffff
@@ -1357,14 +1404,24 @@
  * Returns: 0, EINVAL (bad type/offset/length), EACCES (if PHY_LOCK required and not held)
  */
 #define MC_CMD_NVRAM_UPDATE_FINISH 0x3c
-#define MC_CMD_NVRAM_UPDATE_FINISH_IN_LEN 4
+#define MC_CMD_NVRAM_UPDATE_FINISH_IN_LEN 8
 #define MC_CMD_NVRAM_UPDATE_FINISH_IN_TYPE_OFST 0
+#define MC_CMD_NVRAM_UPDATE_FINISH_IN_REBOOT_OFST 4
 #define MC_CMD_NVRAM_UPDATE_FINISH_OUT_LEN 0
 
 /* MC_CMD_REBOOT:
- * Reboot the MC. The AFTER_ASSERTION flag is intended to be used
- * when the driver notices an assertion failure, to allow two ports to
- * both recover (semi-)gracefully.
+ * Reboot the MC.
+ *
+ * The AFTER_ASSERTION flag is intended to be used when the driver notices
+ * an assertion failure (at which point it is expected to perform a complete
+ * tear down and reinitialise), to allow both ports to reset the MC once
+ * in an atomic fashion.
+ *
+ * Production mc firmwares are generally compiled with REBOOT_ON_ASSERT=1,
+ * which means that they will automatically reboot out of the assertion
+ * handler, so this is in practise an optional operation. It is still
+ * recommended that drivers execute this to support custom firmwares
+ * with REBOOT_ON_ASSERT=0.
  *
  * Locks required: NONE
  * Returns: Nothing. You get back a response with ERR=1, DATALEN=0
@@ -1469,11 +1526,10 @@
 	((_ofst) + 6)
 
 /* MC_CMD_READ_SENSORS
- * Returns the current (value, state) for each sensor
+ * Returns the current reading from each sensor
  *
- * Returns the current (value, state) [each 16bit] of each sensor supported by
- * this board, by DMA'ing a sparse array (indexed by the sensor type) into host
- * memory.
+ * Returns a sparse array of sensor readings (indexed by the sensor
+ * type) into host memory.  Each array element is a dword.
  *
  * The MC will send a SENSOREVT event every time any sensor changes state. The
  * driver is responsible for ensuring that it doesn't miss any events. The board
@@ -1486,6 +1542,12 @@
 #define MC_CMD_READ_SENSORS_IN_DMA_ADDR_HI_OFST 4
 #define MC_CMD_READ_SENSORS_OUT_LEN 0
 
+/* Sensor reading fields */
+#define MC_CMD_READ_SENSOR_VALUE_LBN 0
+#define MC_CMD_READ_SENSOR_VALUE_WIDTH 16
+#define MC_CMD_READ_SENSOR_STATE_LBN 16
+#define MC_CMD_READ_SENSOR_STATE_WIDTH 8
+
 
 /* MC_CMD_GET_PHY_STATE:
  * Report current state of PHY.  A "zombie" PHY is a PHY that has failed to
@@ -1577,4 +1639,98 @@
 #define MC_CMD_MAC_RESET_RESTORE_IN_LEN 0
 #define MC_CMD_MAC_RESET_RESTORE_OUT_LEN 0
 
+
+/* MC_CMD_TEST_ASSERT:
+ * Deliberately trigger an assert-detonation in the firmware for testing
+ * purposes (i.e. to allow tests that the driver copes gracefully).
+ *
+ * Locks required: None
+ * Returns: 0
+ */
+
+#define MC_CMD_TESTASSERT 0x49
+#define MC_CMD_TESTASSERT_IN_LEN 0
+#define MC_CMD_TESTASSERT_OUT_LEN 0
+
+/* MC_CMD_WORKAROUND 0x4a
+ *
+ * Enable/Disable a given workaround. The mcfw will return EINVAL if it
+ * doesn't understand the given workaround number - which should not
+ * be treated as a hard error by client code.
+ *
+ * This op does not imply any semantics about each workaround, that's between
+ * the driver and the mcfw on a per-workaround basis.
+ *
+ * Locks required: None
+ * Returns: 0, EINVAL
+ */
+#define MC_CMD_WORKAROUND 0x4a
+#define MC_CMD_WORKAROUND_IN_LEN 8
+#define MC_CMD_WORKAROUND_IN_TYPE_OFST 0
+#define MC_CMD_WORKAROUND_BUG17230 1
+#define MC_CMD_WORKAROUND_IN_ENABLED_OFST 4
+#define MC_CMD_WORKAROUND_OUT_LEN 0
+
+/* MC_CMD_GET_PHY_MEDIA_INFO:
+ * Read media-specific data from PHY (e.g. SFP/SFP+ module ID information for
+ * SFP+ PHYs).
+ *
+ * The "media type" can be found via GET_PHY_CFG (GET_PHY_CFG_OUT_MEDIA_TYPE);
+ * the valid "page number" input values, and the output data, are interpreted
+ * on a per-type basis.
+ *
+ * For SFP+: PAGE=0 or 1 returns a 128-byte block read from module I2C address
+ *           0xA0 offset 0 or 0x80.
+ * Anything else: currently undefined.
+ *
+ * Locks required: None
+ * Return code: 0
+ */
+#define MC_CMD_GET_PHY_MEDIA_INFO 0x4b
+#define MC_CMD_GET_PHY_MEDIA_INFO_IN_LEN 4
+#define MC_CMD_GET_PHY_MEDIA_INFO_IN_PAGE_OFST 0
+#define MC_CMD_GET_PHY_MEDIA_INFO_OUT_LEN(_num_bytes) (4 + (_num_bytes))
+#define MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATALEN_OFST 0
+#define MC_CMD_GET_PHY_MEDIA_INFO_OUT_DATA_OFST 4
+
+/* MC_CMD_NVRAM_TEST:
+ * Test a particular NVRAM partition for valid contents (where "valid"
+ * depends on the type of partition).
+ *
+ * Locks required: None
+ * Return code: 0
+ */
+#define MC_CMD_NVRAM_TEST 0x4c
+#define MC_CMD_NVRAM_TEST_IN_LEN 4
+#define MC_CMD_NVRAM_TEST_IN_TYPE_OFST 0
+#define MC_CMD_NVRAM_TEST_OUT_LEN 4
+#define MC_CMD_NVRAM_TEST_OUT_RESULT_OFST 0
+#define MC_CMD_NVRAM_TEST_PASS 0
+#define MC_CMD_NVRAM_TEST_FAIL 1
+#define MC_CMD_NVRAM_TEST_NOTSUPP 2
+
+/* MC_CMD_MRSFP_TWEAK: (debug)
+ * Read status and/or set parameters for the "mrsfp" driver in mr_rusty builds.
+ * I2C I/O expander bits are always read; if equaliser parameters are supplied,
+ * they are configured first.
+ *
+ * Locks required: None
+ * Return code: 0, EINVAL
+ */
+#define MC_CMD_MRSFP_TWEAK 0x4d
+#define MC_CMD_MRSFP_TWEAK_IN_LEN_READ_ONLY 0
+#define MC_CMD_MRSFP_TWEAK_IN_LEN_EQ_CONFIG 16
+#define MC_CMD_MRSFP_TWEAK_IN_TXEQ_LEVEL_OFST 0    /* 0-6 low->high de-emph. */
+#define MC_CMD_MRSFP_TWEAK_IN_TXEQ_DT_CFG_OFST 4   /* 0-8 low->high ref.V */
+#define MC_CMD_MRSFP_TWEAK_IN_RXEQ_BOOST_OFST 8    /* 0-8 low->high boost */
+#define MC_CMD_MRSFP_TWEAK_IN_RXEQ_DT_CFG_OFST 12  /* 0-8 low->high ref.V */
+#define MC_CMD_MRSFP_TWEAK_OUT_LEN 12
+#define MC_CMD_MRSFP_TWEAK_OUT_IOEXP_INPUTS_OFST 0     /* input bits */
+#define MC_CMD_MRSFP_TWEAK_OUT_IOEXP_OUTPUTS_OFST 4    /* output bits */
+#define MC_CMD_MRSFP_TWEAK_OUT_IOEXP_DIRECTION_OFST 8  /* dirs: 0=out, 1=in */
+
+/* Do NOT add new commands beyond 0x4f as part of 3.0 : 0x50 - 0x7f will be
+ * used for post-3.0 extensions. If you run out of space, look for gaps or
+ * commands that are unused in the existing range. */
+
 #endif /* MCDI_PCOL_H */
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

