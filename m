From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 01/16] sfc: Add permissions to MCDI commands
Date: Mon, 18 May 2015 16:27:00 +0100
Message-ID: <555A04C4.4080307@solarflare.com>
References: <555A044A.4060202@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:57690 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753753AbbERP1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:27:15 -0400
In-Reply-To: <555A044A.4060202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is one primary function per adaptor, one link control function
per port and the rest as categorised as general.

This patch adds privileges to the MCDI commands based on which
functions are allowed to call them.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h | 441 +++++++++++++++++++++++++++++++++++
 1 file changed, 441 insertions(+)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 4fa6eb2..ecb1144 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -637,6 +637,9 @@
  * Read multiple 32byte words from MC memory.
  */
 #define MC_CMD_READ32 0x1
+#undef MC_CMD_0x1_PRIVILEGE_CTG
+
+#define MC_CMD_0x1_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_READ32_IN msgrequest */
 #define    MC_CMD_READ32_IN_LEN 8
@@ -658,6 +661,9 @@
  * Write multiple 32byte words to MC memory.
  */
 #define MC_CMD_WRITE32 0x2
+#undef MC_CMD_0x2_PRIVILEGE_CTG
+
+#define MC_CMD_0x2_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_WRITE32_IN msgrequest */
 #define    MC_CMD_WRITE32_IN_LENMIN 8
@@ -678,6 +684,9 @@
  * Copy MC code between two locations and jump.
  */
 #define MC_CMD_COPYCODE 0x3
+#undef MC_CMD_0x3_PRIVILEGE_CTG
+
+#define MC_CMD_0x3_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_COPYCODE_IN msgrequest */
 #define    MC_CMD_COPYCODE_IN_LEN 16
@@ -716,6 +725,9 @@
  * Select function for function-specific commands.
  */
 #define MC_CMD_SET_FUNC 0x4
+#undef MC_CMD_0x4_PRIVILEGE_CTG
+
+#define MC_CMD_0x4_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SET_FUNC_IN msgrequest */
 #define    MC_CMD_SET_FUNC_IN_LEN 4
@@ -731,6 +743,9 @@
  * Get the instruction address from which the MC booted.
  */
 #define MC_CMD_GET_BOOT_STATUS 0x5
+#undef MC_CMD_0x5_PRIVILEGE_CTG
+
+#define MC_CMD_0x5_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_GET_BOOT_STATUS_IN msgrequest */
 #define    MC_CMD_GET_BOOT_STATUS_IN_LEN 0
@@ -757,6 +772,9 @@
  * fields will only be present if OUT.GLOBAL_FLAGS != NO_FAILS
  */
 #define MC_CMD_GET_ASSERTS 0x6
+#undef MC_CMD_0x6_PRIVILEGE_CTG
+
+#define MC_CMD_0x6_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_GET_ASSERTS_IN msgrequest */
 #define    MC_CMD_GET_ASSERTS_IN_LEN 4
@@ -793,6 +811,9 @@
  * Configure the output stream for various events and messages.
  */
 #define MC_CMD_LOG_CTRL 0x7
+#undef MC_CMD_0x7_PRIVILEGE_CTG
+
+#define MC_CMD_0x7_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_LOG_CTRL_IN msgrequest */
 #define    MC_CMD_LOG_CTRL_IN_LEN 8
@@ -813,6 +834,9 @@
  * Get version information about the MC firmware.
  */
 #define MC_CMD_GET_VERSION 0x8
+#undef MC_CMD_0x8_PRIVILEGE_CTG
+
+#define MC_CMD_0x8_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_VERSION_IN msgrequest */
 #define    MC_CMD_GET_VERSION_IN_LEN 0
@@ -869,6 +893,9 @@
  * Perform PTP operation
  */
 #define MC_CMD_PTP 0xb
+#undef MC_CMD_0xb_PRIVILEGE_CTG
+
+#define MC_CMD_0xb_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_PTP_IN msgrequest */
 #define    MC_CMD_PTP_IN_LEN 1
@@ -1403,6 +1430,9 @@
  * Read 32bit words from the indirect memory map.
  */
 #define MC_CMD_CSR_READ32 0xc
+#undef MC_CMD_0xc_PRIVILEGE_CTG
+
+#define MC_CMD_0xc_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_CSR_READ32_IN msgrequest */
 #define    MC_CMD_CSR_READ32_IN_LEN 12
@@ -1427,6 +1457,9 @@
  * Write 32bit dwords to the indirect memory map.
  */
 #define MC_CMD_CSR_WRITE32 0xd
+#undef MC_CMD_0xd_PRIVILEGE_CTG
+
+#define MC_CMD_0xd_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_CSR_WRITE32_IN msgrequest */
 #define    MC_CMD_CSR_WRITE32_IN_LENMIN 12
@@ -1451,6 +1484,9 @@
  * MCDI command to avoid creating too many MCDI commands.
  */
 #define MC_CMD_HP 0x54
+#undef MC_CMD_0x54_PRIVILEGE_CTG
+
+#define MC_CMD_0x54_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_HP_IN msgrequest */
 #define    MC_CMD_HP_IN_LEN 16
@@ -1492,6 +1528,9 @@
  * Get stack information.
  */
 #define MC_CMD_STACKINFO 0xf
+#undef MC_CMD_0xf_PRIVILEGE_CTG
+
+#define MC_CMD_0xf_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_STACKINFO_IN msgrequest */
 #define    MC_CMD_STACKINFO_IN_LEN 0
@@ -1512,6 +1551,9 @@
  * MDIO register read.
  */
 #define MC_CMD_MDIO_READ 0x10
+#undef MC_CMD_0x10_PRIVILEGE_CTG
+
+#define MC_CMD_0x10_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_MDIO_READ_IN msgrequest */
 #define    MC_CMD_MDIO_READ_IN_LEN 16
@@ -1551,6 +1593,9 @@
  * MDIO register write.
  */
 #define MC_CMD_MDIO_WRITE 0x11
+#undef MC_CMD_0x11_PRIVILEGE_CTG
+
+#define MC_CMD_0x11_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_MDIO_WRITE_IN msgrequest */
 #define    MC_CMD_MDIO_WRITE_IN_LEN 20
@@ -1590,6 +1635,9 @@
  * Write DBI register(s).
  */
 #define MC_CMD_DBI_WRITE 0x12
+#undef MC_CMD_0x12_PRIVILEGE_CTG
+
+#define MC_CMD_0x12_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_DBI_WRITE_IN msgrequest */
 #define    MC_CMD_DBI_WRITE_IN_LENMIN 12
@@ -1738,6 +1786,9 @@
  * Returns the MC firmware configuration structure.
  */
 #define MC_CMD_GET_BOARD_CFG 0x18
+#undef MC_CMD_0x18_PRIVILEGE_CTG
+
+#define MC_CMD_0x18_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_BOARD_CFG_IN msgrequest */
 #define    MC_CMD_GET_BOARD_CFG_IN_LEN 0
@@ -1777,6 +1828,9 @@
  * Read DBI register(s) -- extended functionality
  */
 #define MC_CMD_DBI_READX 0x19
+#undef MC_CMD_0x19_PRIVILEGE_CTG
+
+#define MC_CMD_0x19_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_DBI_READX_IN msgrequest */
 #define    MC_CMD_DBI_READX_IN_LENMIN 8
@@ -1821,6 +1875,9 @@
  * Set the 16byte seed for the MC pseudo-random generator.
  */
 #define MC_CMD_SET_RAND_SEED 0x1a
+#undef MC_CMD_0x1a_PRIVILEGE_CTG
+
+#define MC_CMD_0x1a_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SET_RAND_SEED_IN msgrequest */
 #define    MC_CMD_SET_RAND_SEED_IN_LEN 16
@@ -1862,6 +1919,9 @@
  * platforms.
  */
 #define MC_CMD_DRV_ATTACH 0x1c
+#undef MC_CMD_0x1c_PRIVILEGE_CTG
+
+#define MC_CMD_0x1c_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_DRV_ATTACH_IN msgrequest */
 #define    MC_CMD_DRV_ATTACH_IN_LEN 12
@@ -1921,6 +1981,9 @@
  * use MC_CMD_ENTITY_RESET instead.
  */
 #define MC_CMD_PORT_RESET 0x20
+#undef MC_CMD_0x20_PRIVILEGE_CTG
+
+#define MC_CMD_0x20_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_PORT_RESET_IN msgrequest */
 #define    MC_CMD_PORT_RESET_IN_LEN 0
@@ -1936,6 +1999,7 @@
  * extended version of the deprecated MC_CMD_PORT_RESET with added fields.
  */
 #define MC_CMD_ENTITY_RESET 0x20
+/*      MC_CMD_0x20_PRIVILEGE_CTG SRIOV_CTG_GENERAL */
 
 /* MC_CMD_ENTITY_RESET_IN msgrequest */
 #define    MC_CMD_ENTITY_RESET_IN_LEN 4
@@ -2024,6 +2088,9 @@
  * Copy the given ASCII string out onto UART and/or out of the network port.
  */
 #define MC_CMD_PUTS 0x23
+#undef MC_CMD_0x23_PRIVILEGE_CTG
+
+#define MC_CMD_0x23_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_PUTS_IN msgrequest */
 #define    MC_CMD_PUTS_IN_LENMIN 13
@@ -2051,6 +2118,9 @@
  * 'zombie' state. Locks required: None
  */
 #define MC_CMD_GET_PHY_CFG 0x24
+#undef MC_CMD_0x24_PRIVILEGE_CTG
+
+#define MC_CMD_0x24_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_PHY_CFG_IN msgrequest */
 #define    MC_CMD_GET_PHY_CFG_IN_LEN 0
@@ -2150,6 +2220,9 @@
  * Return code: 0, EINVAL, EACCES (if PHY_LOCK is not held)
  */
 #define MC_CMD_START_BIST 0x25
+#undef MC_CMD_0x25_PRIVILEGE_CTG
+
+#define MC_CMD_0x25_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_START_BIST_IN msgrequest */
 #define    MC_CMD_START_BIST_IN_LEN 4
@@ -2186,6 +2259,9 @@
  * EACCES (if PHY_LOCK is not held).
  */
 #define MC_CMD_POLL_BIST 0x26
+#undef MC_CMD_0x26_PRIVILEGE_CTG
+
+#define MC_CMD_0x26_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_POLL_BIST_IN msgrequest */
 #define    MC_CMD_POLL_BIST_IN_LEN 0
@@ -2345,6 +2421,9 @@
  * Returns a bitmask of loopback modes available at each speed.
  */
 #define MC_CMD_GET_LOOPBACK_MODES 0x28
+#undef MC_CMD_0x28_PRIVILEGE_CTG
+
+#define MC_CMD_0x28_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_LOOPBACK_MODES_IN msgrequest */
 #define    MC_CMD_GET_LOOPBACK_MODES_IN_LEN 0
@@ -2464,6 +2543,9 @@
  * ETIME.
  */
 #define MC_CMD_GET_LINK 0x29
+#undef MC_CMD_0x29_PRIVILEGE_CTG
+
+#define MC_CMD_0x29_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_LINK_IN msgrequest */
 #define    MC_CMD_GET_LINK_IN_LEN 0
@@ -2520,6 +2602,9 @@
  * code: 0, EINVAL, ETIME
  */
 #define MC_CMD_SET_LINK 0x2a
+#undef MC_CMD_0x2a_PRIVILEGE_CTG
+
+#define MC_CMD_0x2a_PRIVILEGE_CTG SRIOV_CTG_LINK
 
 /* MC_CMD_SET_LINK_IN msgrequest */
 #define    MC_CMD_SET_LINK_IN_LEN 16
@@ -2551,6 +2636,9 @@
  * Set identification LED state. Locks required: None. Return code: 0, EINVAL
  */
 #define MC_CMD_SET_ID_LED 0x2b
+#undef MC_CMD_0x2b_PRIVILEGE_CTG
+
+#define MC_CMD_0x2b_PRIVILEGE_CTG SRIOV_CTG_LINK
 
 /* MC_CMD_SET_ID_LED_IN msgrequest */
 #define    MC_CMD_SET_ID_LED_IN_LEN 4
@@ -2569,6 +2657,9 @@
  * Set MAC configuration. Locks required: None. Return code: 0, EINVAL
  */
 #define MC_CMD_SET_MAC 0x2c
+#undef MC_CMD_0x2c_PRIVILEGE_CTG
+
+#define MC_CMD_0x2c_PRIVILEGE_CTG SRIOV_CTG_LINK
 
 /* MC_CMD_SET_MAC_IN msgrequest */
 #define    MC_CMD_SET_MAC_IN_LEN 24
@@ -2610,6 +2701,9 @@
  * Returns: 0, ETIME
  */
 #define MC_CMD_PHY_STATS 0x2d
+#undef MC_CMD_0x2d_PRIVILEGE_CTG
+
+#define MC_CMD_0x2d_PRIVILEGE_CTG SRIOV_CTG_LINK
 
 /* MC_CMD_PHY_STATS_IN msgrequest */
 #define    MC_CMD_PHY_STATS_IN_LEN 8
@@ -2688,6 +2782,9 @@
  * Locks required: None. Returns: 0, ETIME
  */
 #define MC_CMD_MAC_STATS 0x2e
+#undef MC_CMD_0x2e_PRIVILEGE_CTG
+
+#define MC_CMD_0x2e_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_MAC_STATS_IN msgrequest */
 #define    MC_CMD_MAC_STATS_IN_LEN 16
@@ -2927,6 +3024,9 @@
  * Set a WoL filter.
  */
 #define MC_CMD_WOL_FILTER_SET 0x32
+#undef MC_CMD_0x32_PRIVILEGE_CTG
+
+#define MC_CMD_0x32_PRIVILEGE_CTG SRIOV_CTG_LINK
 
 /* MC_CMD_WOL_FILTER_SET_IN msgrequest */
 #define    MC_CMD_WOL_FILTER_SET_IN_LEN 192
@@ -3021,6 +3121,9 @@
  * Remove a WoL filter. Locks required: None. Returns: 0, EINVAL, ENOSYS
  */
 #define MC_CMD_WOL_FILTER_REMOVE 0x33
+#undef MC_CMD_0x33_PRIVILEGE_CTG
+
+#define MC_CMD_0x33_PRIVILEGE_CTG SRIOV_CTG_LINK
 
 /* MC_CMD_WOL_FILTER_REMOVE_IN msgrequest */
 #define    MC_CMD_WOL_FILTER_REMOVE_IN_LEN 4
@@ -3036,6 +3139,9 @@
  * ENOSYS
  */
 #define MC_CMD_WOL_FILTER_RESET 0x34
+#undef MC_CMD_0x34_PRIVILEGE_CTG
+
+#define MC_CMD_0x34_PRIVILEGE_CTG SRIOV_CTG_LINK
 
 /* MC_CMD_WOL_FILTER_RESET_IN msgrequest */
 #define    MC_CMD_WOL_FILTER_RESET_IN_LEN 4
@@ -3070,6 +3176,9 @@
  * Locks required: none. Returns: 0
  */
 #define MC_CMD_NVRAM_TYPES 0x36
+#undef MC_CMD_0x36_PRIVILEGE_CTG
+
+#define MC_CMD_0x36_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_NVRAM_TYPES_IN msgrequest */
 #define    MC_CMD_NVRAM_TYPES_IN_LEN 0
@@ -3126,6 +3235,9 @@
  * EINVAL (bad type).
  */
 #define MC_CMD_NVRAM_INFO 0x37
+#undef MC_CMD_0x37_PRIVILEGE_CTG
+
+#define MC_CMD_0x37_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_NVRAM_INFO_IN msgrequest */
 #define    MC_CMD_NVRAM_INFO_IN_LEN 4
@@ -3158,6 +3270,9 @@
  * PHY_LOCK required and not held).
  */
 #define MC_CMD_NVRAM_UPDATE_START 0x38
+#undef MC_CMD_0x38_PRIVILEGE_CTG
+
+#define MC_CMD_0x38_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_NVRAM_UPDATE_START_IN msgrequest */
 #define    MC_CMD_NVRAM_UPDATE_START_IN_LEN 4
@@ -3176,6 +3291,9 @@
  * PHY_LOCK required and not held)
  */
 #define MC_CMD_NVRAM_READ 0x39
+#undef MC_CMD_0x39_PRIVILEGE_CTG
+
+#define MC_CMD_0x39_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_NVRAM_READ_IN msgrequest */
 #define    MC_CMD_NVRAM_READ_IN_LEN 12
@@ -3203,6 +3321,9 @@
  * PHY_LOCK required and not held)
  */
 #define MC_CMD_NVRAM_WRITE 0x3a
+#undef MC_CMD_0x3a_PRIVILEGE_CTG
+
+#define MC_CMD_0x3a_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_NVRAM_WRITE_IN msgrequest */
 #define    MC_CMD_NVRAM_WRITE_IN_LENMIN 13
@@ -3229,6 +3350,9 @@
  * PHY_LOCK required and not held)
  */
 #define MC_CMD_NVRAM_ERASE 0x3b
+#undef MC_CMD_0x3b_PRIVILEGE_CTG
+
+#define MC_CMD_0x3b_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_NVRAM_ERASE_IN msgrequest */
 #define    MC_CMD_NVRAM_ERASE_IN_LEN 12
@@ -3249,6 +3373,9 @@
  * type/offset/length), EACCES (if PHY_LOCK required and not held)
  */
 #define MC_CMD_NVRAM_UPDATE_FINISH 0x3c
+#undef MC_CMD_0x3c_PRIVILEGE_CTG
+
+#define MC_CMD_0x3c_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_NVRAM_UPDATE_FINISH_IN msgrequest */
 #define    MC_CMD_NVRAM_UPDATE_FINISH_IN_LEN 8
@@ -3280,6 +3407,9 @@
  * DATALEN=0
  */
 #define MC_CMD_REBOOT 0x3d
+#undef MC_CMD_0x3d_PRIVILEGE_CTG
+
+#define MC_CMD_0x3d_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_REBOOT_IN msgrequest */
 #define    MC_CMD_REBOOT_IN_LEN 4
@@ -3317,6 +3447,9 @@
  * mode to the specified value. Returns the old mode.
  */
 #define MC_CMD_REBOOT_MODE 0x3f
+#undef MC_CMD_0x3f_PRIVILEGE_CTG
+
+#define MC_CMD_0x3f_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_REBOOT_MODE_IN msgrequest */
 #define    MC_CMD_REBOOT_MODE_IN_LEN 4
@@ -3369,6 +3502,9 @@
  * Locks required: None Returns: 0
  */
 #define MC_CMD_SENSOR_INFO 0x41
+#undef MC_CMD_0x41_PRIVILEGE_CTG
+
+#define MC_CMD_0x41_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SENSOR_INFO_IN msgrequest */
 #define    MC_CMD_SENSOR_INFO_IN_LEN 0
@@ -3543,6 +3679,9 @@
  * STATE_WARNING. Otherwise the board should not be expected to function.
  */
 #define MC_CMD_READ_SENSORS 0x42
+#undef MC_CMD_0x42_PRIVILEGE_CTG
+
+#define MC_CMD_0x42_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_READ_SENSORS_IN msgrequest */
 #define    MC_CMD_READ_SENSORS_IN_LEN 8
@@ -3603,6 +3742,9 @@
  * code: 0
  */
 #define MC_CMD_GET_PHY_STATE 0x43
+#undef MC_CMD_0x43_PRIVILEGE_CTG
+
+#define MC_CMD_0x43_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_PHY_STATE_IN msgrequest */
 #define    MC_CMD_GET_PHY_STATE_IN_LEN 0
@@ -3637,6 +3779,9 @@
  * Retrieve ID of any WoL filters. Locks required: None. Returns: 0, ENOSYS
  */
 #define MC_CMD_WOL_FILTER_GET 0x45
+#undef MC_CMD_0x45_PRIVILEGE_CTG
+
+#define MC_CMD_0x45_PRIVILEGE_CTG SRIOV_CTG_LINK
 
 /* MC_CMD_WOL_FILTER_GET_IN msgrequest */
 #define    MC_CMD_WOL_FILTER_GET_IN_LEN 0
@@ -3652,6 +3797,9 @@
  * Returns: 0, ENOSYS
  */
 #define MC_CMD_ADD_LIGHTSOUT_OFFLOAD 0x46
+#undef MC_CMD_0x46_PRIVILEGE_CTG
+
+#define MC_CMD_0x46_PRIVILEGE_CTG SRIOV_CTG_LINK
 
 /* MC_CMD_ADD_LIGHTSOUT_OFFLOAD_IN msgrequest */
 #define    MC_CMD_ADD_LIGHTSOUT_OFFLOAD_IN_LENMIN 8
@@ -3693,6 +3841,9 @@
  * None. Returns: 0, ENOSYS
  */
 #define MC_CMD_REMOVE_LIGHTSOUT_OFFLOAD 0x47
+#undef MC_CMD_0x47_PRIVILEGE_CTG
+
+#define MC_CMD_0x47_PRIVILEGE_CTG SRIOV_CTG_LINK
 
 /* MC_CMD_REMOVE_LIGHTSOUT_OFFLOAD_IN msgrequest */
 #define    MC_CMD_REMOVE_LIGHTSOUT_OFFLOAD_IN_LEN 8
@@ -3723,6 +3874,9 @@
  * required: None Returns: 0
  */
 #define MC_CMD_TESTASSERT 0x49
+#undef MC_CMD_0x49_PRIVILEGE_CTG
+
+#define MC_CMD_0x49_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_TESTASSERT_IN msgrequest */
 #define    MC_CMD_TESTASSERT_IN_LEN 0
@@ -3740,6 +3894,9 @@
  * basis. Locks required: None. Returns: 0, EINVAL .
  */
 #define MC_CMD_WORKAROUND 0x4a
+#undef MC_CMD_0x4a_PRIVILEGE_CTG
+
+#define MC_CMD_0x4a_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_WORKAROUND_IN msgrequest */
 #define    MC_CMD_WORKAROUND_IN_LEN 8
@@ -3766,6 +3923,9 @@
  * Anything else: currently undefined. Locks required: None. Return code: 0.
  */
 #define MC_CMD_GET_PHY_MEDIA_INFO 0x4b
+#undef MC_CMD_0x4b_PRIVILEGE_CTG
+
+#define MC_CMD_0x4b_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_GET_PHY_MEDIA_INFO_IN msgrequest */
 #define    MC_CMD_GET_PHY_MEDIA_INFO_IN_LEN 4
@@ -3789,6 +3949,9 @@
  * on the type of partition).
  */
 #define MC_CMD_NVRAM_TEST 0x4c
+#undef MC_CMD_0x4c_PRIVILEGE_CTG
+
+#define MC_CMD_0x4c_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_NVRAM_TEST_IN msgrequest */
 #define    MC_CMD_NVRAM_TEST_IN_LEN 4
@@ -3850,6 +4013,9 @@
  * of range.
  */
 #define MC_CMD_SENSOR_SET_LIMS 0x4e
+#undef MC_CMD_0x4e_PRIVILEGE_CTG
+
+#define MC_CMD_0x4e_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SENSOR_SET_LIMS_IN msgrequest */
 #define    MC_CMD_SENSOR_SET_LIMS_IN_LEN 20
@@ -3891,6 +4057,9 @@
  * none. Returns: 0, EINVAL (bad type).
  */
 #define MC_CMD_NVRAM_PARTITIONS 0x51
+#undef MC_CMD_0x51_PRIVILEGE_CTG
+
+#define MC_CMD_0x51_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_NVRAM_PARTITIONS_IN msgrequest */
 #define    MC_CMD_NVRAM_PARTITIONS_IN_LEN 0
@@ -3914,6 +4083,9 @@
  * none. Returns: 0, EINVAL (bad type).
  */
 #define MC_CMD_NVRAM_METADATA 0x52
+#undef MC_CMD_0x52_PRIVILEGE_CTG
+
+#define MC_CMD_0x52_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_NVRAM_METADATA_IN msgrequest */
 #define    MC_CMD_NVRAM_METADATA_IN_LEN 4
@@ -3959,6 +4131,9 @@
  * Returns the base MAC, count and stride for the requestiong function
  */
 #define MC_CMD_GET_MAC_ADDRESSES 0x55
+#undef MC_CMD_0x55_PRIVILEGE_CTG
+
+#define MC_CMD_0x55_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_MAC_ADDRESSES_IN msgrequest */
 #define    MC_CMD_GET_MAC_ADDRESSES_IN_LEN 0
@@ -4114,6 +4289,9 @@
  * Get a dump of the MCPU registers
  */
 #define MC_CMD_READ_REGS 0x50
+#undef MC_CMD_0x50_PRIVILEGE_CTG
+
+#define MC_CMD_0x50_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_READ_REGS_IN msgrequest */
 #define    MC_CMD_READ_REGS_IN_LEN 0
@@ -4137,6 +4315,9 @@
  * end with an address for each 4k of host memory required to back the EVQ.
  */
 #define MC_CMD_INIT_EVQ 0x80
+#undef MC_CMD_0x80_PRIVILEGE_CTG
+
+#define MC_CMD_0x80_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_INIT_EVQ_IN msgrequest */
 #define    MC_CMD_INIT_EVQ_IN_LENMIN 44
@@ -4235,6 +4416,9 @@
  * the RXQ.
  */
 #define MC_CMD_INIT_RXQ 0x81
+#undef MC_CMD_0x81_PRIVILEGE_CTG
+
+#define MC_CMD_0x81_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_INIT_RXQ_IN msgrequest */
 #define    MC_CMD_INIT_RXQ_IN_LENMIN 36
@@ -4287,6 +4471,9 @@
 /* MC_CMD_INIT_TXQ
  */
 #define MC_CMD_INIT_TXQ 0x82
+#undef MC_CMD_0x82_PRIVILEGE_CTG
+
+#define MC_CMD_0x82_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_INIT_TXQ_IN msgrequest */
 #define    MC_CMD_INIT_TXQ_IN_LENMIN 36
@@ -4344,6 +4531,9 @@
  * or the operation will fail with EBUSY
  */
 #define MC_CMD_FINI_EVQ 0x83
+#undef MC_CMD_0x83_PRIVILEGE_CTG
+
+#define MC_CMD_0x83_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_FINI_EVQ_IN msgrequest */
 #define    MC_CMD_FINI_EVQ_IN_LEN 4
@@ -4361,6 +4551,9 @@
  * Teardown a RXQ.
  */
 #define MC_CMD_FINI_RXQ 0x84
+#undef MC_CMD_0x84_PRIVILEGE_CTG
+
+#define MC_CMD_0x84_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_FINI_RXQ_IN msgrequest */
 #define    MC_CMD_FINI_RXQ_IN_LEN 4
@@ -4376,6 +4569,9 @@
  * Teardown a TXQ.
  */
 #define MC_CMD_FINI_TXQ 0x85
+#undef MC_CMD_0x85_PRIVILEGE_CTG
+
+#define MC_CMD_0x85_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_FINI_TXQ_IN msgrequest */
 #define    MC_CMD_FINI_TXQ_IN_LEN 4
@@ -4391,6 +4587,9 @@
  * Generate an event on an EVQ belonging to the function issuing the command.
  */
 #define MC_CMD_DRIVER_EVENT 0x86
+#undef MC_CMD_0x86_PRIVILEGE_CTG
+
+#define MC_CMD_0x86_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_DRIVER_EVENT_IN msgrequest */
 #define    MC_CMD_DRIVER_EVENT_IN_LEN 12
@@ -4414,6 +4613,9 @@
  * MC_CMD_SET_FUNC, which remains available for Siena but now deprecated.
  */
 #define MC_CMD_PROXY_CMD 0x5b
+#undef MC_CMD_0x5b_PRIVILEGE_CTG
+
+#define MC_CMD_0x5b_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_PROXY_CMD_IN msgrequest */
 #define    MC_CMD_PROXY_CMD_IN_LEN 4
@@ -4436,6 +4638,9 @@
  * cannot do so). The buffer table entries will initially be zeroed.
  */
 #define MC_CMD_ALLOC_BUFTBL_CHUNK 0x87
+#undef MC_CMD_0x87_PRIVILEGE_CTG
+
+#define MC_CMD_0x87_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
 
 /* MC_CMD_ALLOC_BUFTBL_CHUNK_IN msgrequest */
 #define    MC_CMD_ALLOC_BUFTBL_CHUNK_IN_LEN 8
@@ -4459,6 +4664,9 @@
  * Reprogram a set of buffer table entries in the specified chunk.
  */
 #define MC_CMD_PROGRAM_BUFTBL_ENTRIES 0x88
+#undef MC_CMD_0x88_PRIVILEGE_CTG
+
+#define MC_CMD_0x88_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
 
 /* MC_CMD_PROGRAM_BUFTBL_ENTRIES_IN msgrequest */
 #define    MC_CMD_PROGRAM_BUFTBL_ENTRIES_IN_LENMIN 20
@@ -4485,6 +4693,9 @@
 /* MC_CMD_FREE_BUFTBL_CHUNK
  */
 #define MC_CMD_FREE_BUFTBL_CHUNK 0x89
+#undef MC_CMD_0x89_PRIVILEGE_CTG
+
+#define MC_CMD_0x89_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
 
 /* MC_CMD_FREE_BUFTBL_CHUNK_IN msgrequest */
 #define    MC_CMD_FREE_BUFTBL_CHUNK_IN_LEN 4
@@ -4499,6 +4710,9 @@
  * Multiplexed MCDI call for filter operations
  */
 #define MC_CMD_FILTER_OP 0x8a
+#undef MC_CMD_0x8a_PRIVILEGE_CTG
+
+#define MC_CMD_0x8a_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_FILTER_OP_IN msgrequest */
 #define    MC_CMD_FILTER_OP_IN_LEN 108
@@ -4659,6 +4873,9 @@
  * Get information related to the parser-dispatcher subsystem
  */
 #define MC_CMD_GET_PARSER_DISP_INFO 0xe4
+#undef MC_CMD_0xe4_PRIVILEGE_CTG
+
+#define MC_CMD_0xe4_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_PARSER_DISP_INFO_IN msgrequest */
 #define    MC_CMD_GET_PARSER_DISP_INFO_IN_LEN 4
@@ -4691,6 +4908,9 @@
  * Direct read/write of parser-dispatcher state (DICPUs and LUE) for debugging
  */
 #define MC_CMD_PARSER_DISP_RW 0xe5
+#undef MC_CMD_0xe5_PRIVILEGE_CTG
+
+#define MC_CMD_0xe5_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_PARSER_DISP_RW_IN msgrequest */
 #define    MC_CMD_PARSER_DISP_RW_IN_LEN 32
@@ -4741,6 +4961,9 @@
  * Get number of PFs on the device.
  */
 #define MC_CMD_GET_PF_COUNT 0xb6
+#undef MC_CMD_0xb6_PRIVILEGE_CTG
+
+#define MC_CMD_0xb6_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_PF_COUNT_IN msgrequest */
 #define    MC_CMD_GET_PF_COUNT_IN_LEN 0
@@ -4772,6 +4995,9 @@
  * Get port assignment for current PCI function.
  */
 #define MC_CMD_GET_PORT_ASSIGNMENT 0xb8
+#undef MC_CMD_0xb8_PRIVILEGE_CTG
+
+#define MC_CMD_0xb8_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_PORT_ASSIGNMENT_IN msgrequest */
 #define    MC_CMD_GET_PORT_ASSIGNMENT_IN_LEN 0
@@ -4787,6 +5013,9 @@
  * Set port assignment for current PCI function.
  */
 #define MC_CMD_SET_PORT_ASSIGNMENT 0xb9
+#undef MC_CMD_0xb9_PRIVILEGE_CTG
+
+#define MC_CMD_0xb9_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SET_PORT_ASSIGNMENT_IN msgrequest */
 #define    MC_CMD_SET_PORT_ASSIGNMENT_IN_LEN 4
@@ -4802,6 +5031,9 @@
  * Allocate VIs for current PCI function.
  */
 #define MC_CMD_ALLOC_VIS 0x8b
+#undef MC_CMD_0x8b_PRIVILEGE_CTG
+
+#define MC_CMD_0x8b_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_ALLOC_VIS_IN msgrequest */
 #define    MC_CMD_ALLOC_VIS_IN_LEN 8
@@ -4826,6 +5058,9 @@
  * but not freed.
  */
 #define MC_CMD_FREE_VIS 0x8c
+#undef MC_CMD_0x8c_PRIVILEGE_CTG
+
+#define MC_CMD_0x8c_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_FREE_VIS_IN msgrequest */
 #define    MC_CMD_FREE_VIS_IN_LEN 0
@@ -4839,6 +5074,9 @@
  * Get SRIOV config for this PF.
  */
 #define MC_CMD_GET_SRIOV_CFG 0xba
+#undef MC_CMD_0xba_PRIVILEGE_CTG
+
+#define MC_CMD_0xba_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_SRIOV_CFG_IN msgrequest */
 #define    MC_CMD_GET_SRIOV_CFG_IN_LEN 0
@@ -4863,6 +5101,9 @@
  * Set SRIOV config for this PF.
  */
 #define MC_CMD_SET_SRIOV_CFG 0xbb
+#undef MC_CMD_0xbb_PRIVILEGE_CTG
+
+#define MC_CMD_0xbb_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SET_SRIOV_CFG_IN msgrequest */
 #define    MC_CMD_SET_SRIOV_CFG_IN_LEN 20
@@ -4892,6 +5133,9 @@
  * function.
  */
 #define MC_CMD_GET_VI_ALLOC_INFO 0x8d
+#undef MC_CMD_0x8d_PRIVILEGE_CTG
+
+#define MC_CMD_0x8d_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_VI_ALLOC_INFO_IN msgrequest */
 #define    MC_CMD_GET_VI_ALLOC_INFO_IN_LEN 0
@@ -4911,6 +5155,9 @@
  * For CmdClient use. Dump pertinent information on a specific absolute VI.
  */
 #define MC_CMD_DUMP_VI_STATE 0x8e
+#undef MC_CMD_0x8e_PRIVILEGE_CTG
+
+#define MC_CMD_0x8e_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_DUMP_VI_STATE_IN msgrequest */
 #define    MC_CMD_DUMP_VI_STATE_IN_LEN 4
@@ -5020,6 +5267,9 @@
  * Allocate a push I/O buffer for later use with a tx queue.
  */
 #define MC_CMD_ALLOC_PIOBUF 0x8f
+#undef MC_CMD_0x8f_PRIVILEGE_CTG
+
+#define MC_CMD_0x8f_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
 
 /* MC_CMD_ALLOC_PIOBUF_IN msgrequest */
 #define    MC_CMD_ALLOC_PIOBUF_IN_LEN 0
@@ -5035,6 +5285,9 @@
  * Free a push I/O buffer.
  */
 #define MC_CMD_FREE_PIOBUF 0x90
+#undef MC_CMD_0x90_PRIVILEGE_CTG
+
+#define MC_CMD_0x90_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
 
 /* MC_CMD_FREE_PIOBUF_IN msgrequest */
 #define    MC_CMD_FREE_PIOBUF_IN_LEN 4
@@ -5050,6 +5303,9 @@
  * Get TLP steering and ordering information for a VI.
  */
 #define MC_CMD_GET_VI_TLP_PROCESSING 0xb0
+#undef MC_CMD_0xb0_PRIVILEGE_CTG
+
+#define MC_CMD_0xb0_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_VI_TLP_PROCESSING_IN msgrequest */
 #define    MC_CMD_GET_VI_TLP_PROCESSING_IN_LEN 4
@@ -5084,6 +5340,9 @@
  * Set TLP steering and ordering information for a VI.
  */
 #define MC_CMD_SET_VI_TLP_PROCESSING 0xb1
+#undef MC_CMD_0xb1_PRIVILEGE_CTG
+
+#define MC_CMD_0xb1_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_SET_VI_TLP_PROCESSING_IN msgrequest */
 #define    MC_CMD_SET_VI_TLP_PROCESSING_IN_LEN 8
@@ -5118,6 +5377,9 @@
  * Get global PCIe steering and transaction processing configuration.
  */
 #define MC_CMD_GET_TLP_PROCESSING_GLOBALS 0xbc
+#undef MC_CMD_0xbc_PRIVILEGE_CTG
+
+#define MC_CMD_0xbc_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_GET_TLP_PROCESSING_GLOBALS_IN msgrequest */
 #define    MC_CMD_GET_TLP_PROCESSING_GLOBALS_IN_LEN 4
@@ -5179,6 +5441,9 @@
  * Set global PCIe steering and transaction processing configuration.
  */
 #define MC_CMD_SET_TLP_PROCESSING_GLOBALS 0xbd
+#undef MC_CMD_0xbd_PRIVILEGE_CTG
+
+#define MC_CMD_0xbd_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SET_TLP_PROCESSING_GLOBALS_IN msgrequest */
 #define    MC_CMD_SET_TLP_PROCESSING_GLOBALS_IN_LEN 8
@@ -5225,6 +5490,9 @@
  * Download a new set of images to the satellite CPUs from the host.
  */
 #define MC_CMD_SATELLITE_DOWNLOAD 0x91
+#undef MC_CMD_0x91_PRIVILEGE_CTG
+
+#define MC_CMD_0x91_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SATELLITE_DOWNLOAD_IN msgrequest: The reset requirements for the CPUs
  * are subtle, and so downloads must proceed in a number of phases.
@@ -5340,7 +5608,9 @@
  * reference inherent device capabilities as opposed to current NVRAM config.
  */
 #define MC_CMD_GET_CAPABILITIES 0xbe
+#undef MC_CMD_0xbe_PRIVILEGE_CTG
 
+#define MC_CMD_0xbe_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 /* MC_CMD_GET_CAPABILITIES_IN msgrequest */
 #define    MC_CMD_GET_CAPABILITIES_IN_LEN 0
 
@@ -5455,6 +5725,9 @@
  * Allocate a pacer bucket (for qau rp or a snapper test)
  */
 #define MC_CMD_TCM_BUCKET_ALLOC 0xb2
+#undef MC_CMD_0xb2_PRIVILEGE_CTG
+
+#define MC_CMD_0xb2_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_TCM_BUCKET_ALLOC_IN msgrequest */
 #define    MC_CMD_TCM_BUCKET_ALLOC_IN_LEN 0
@@ -5470,6 +5743,9 @@
  * Free a pacer bucket
  */
 #define MC_CMD_TCM_BUCKET_FREE 0xb3
+#undef MC_CMD_0xb3_PRIVILEGE_CTG
+
+#define MC_CMD_0xb3_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_TCM_BUCKET_FREE_IN msgrequest */
 #define    MC_CMD_TCM_BUCKET_FREE_IN_LEN 4
@@ -5485,6 +5761,9 @@
  * Initialise pacer bucket with a given rate
  */
 #define MC_CMD_TCM_BUCKET_INIT 0xb4
+#undef MC_CMD_0xb4_PRIVILEGE_CTG
+
+#define MC_CMD_0xb4_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_TCM_BUCKET_INIT_IN msgrequest */
 #define    MC_CMD_TCM_BUCKET_INIT_IN_LEN 8
@@ -5502,6 +5781,9 @@
  * Initialise txq in pacer with given options or set options
  */
 #define MC_CMD_TCM_TXQ_INIT 0xb5
+#undef MC_CMD_0xb5_PRIVILEGE_CTG
+
+#define MC_CMD_0xb5_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_TCM_TXQ_INIT_IN msgrequest */
 #define    MC_CMD_TCM_TXQ_INIT_IN_LEN 28
@@ -5533,6 +5815,9 @@
  * Link a push I/O buffer to a TxQ
  */
 #define MC_CMD_LINK_PIOBUF 0x92
+#undef MC_CMD_0x92_PRIVILEGE_CTG
+
+#define MC_CMD_0x92_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
 
 /* MC_CMD_LINK_PIOBUF_IN msgrequest */
 #define    MC_CMD_LINK_PIOBUF_IN_LEN 8
@@ -5550,6 +5835,9 @@
  * Unlink a push I/O buffer from a TxQ
  */
 #define MC_CMD_UNLINK_PIOBUF 0x93
+#undef MC_CMD_0x93_PRIVILEGE_CTG
+
+#define MC_CMD_0x93_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
 
 /* MC_CMD_UNLINK_PIOBUF_IN msgrequest */
 #define    MC_CMD_UNLINK_PIOBUF_IN_LEN 4
@@ -5565,6 +5853,9 @@
  * allocate and initialise a v-switch.
  */
 #define MC_CMD_VSWITCH_ALLOC 0x94
+#undef MC_CMD_0x94_PRIVILEGE_CTG
+
+#define MC_CMD_0x94_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_VSWITCH_ALLOC_IN msgrequest */
 #define    MC_CMD_VSWITCH_ALLOC_IN_LEN 16
@@ -5594,6 +5885,9 @@
  * de-allocate a v-switch.
  */
 #define MC_CMD_VSWITCH_FREE 0x95
+#undef MC_CMD_0x95_PRIVILEGE_CTG
+
+#define MC_CMD_0x95_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_VSWITCH_FREE_IN msgrequest */
 #define    MC_CMD_VSWITCH_FREE_IN_LEN 4
@@ -5609,6 +5903,9 @@
  * allocate a v-port.
  */
 #define MC_CMD_VPORT_ALLOC 0x96
+#undef MC_CMD_0x96_PRIVILEGE_CTG
+
+#define MC_CMD_0x96_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_VPORT_ALLOC_IN msgrequest */
 #define    MC_CMD_VPORT_ALLOC_IN_LEN 20
@@ -5658,6 +5955,9 @@
  * de-allocate a v-port.
  */
 #define MC_CMD_VPORT_FREE 0x97
+#undef MC_CMD_0x97_PRIVILEGE_CTG
+
+#define MC_CMD_0x97_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_VPORT_FREE_IN msgrequest */
 #define    MC_CMD_VPORT_FREE_IN_LEN 4
@@ -5673,6 +5973,9 @@
  * allocate a v-adaptor.
  */
 #define MC_CMD_VADAPTOR_ALLOC 0x98
+#undef MC_CMD_0x98_PRIVILEGE_CTG
+
+#define MC_CMD_0x98_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_VADAPTOR_ALLOC_IN msgrequest */
 #define    MC_CMD_VADAPTOR_ALLOC_IN_LEN 16
@@ -5694,6 +5997,9 @@
  * de-allocate a v-adaptor.
  */
 #define MC_CMD_VADAPTOR_FREE 0x99
+#undef MC_CMD_0x99_PRIVILEGE_CTG
+
+#define MC_CMD_0x99_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_VADAPTOR_FREE_IN msgrequest */
 #define    MC_CMD_VADAPTOR_FREE_IN_LEN 4
@@ -5709,6 +6015,9 @@
  * assign a port to a PCI function.
  */
 #define MC_CMD_EVB_PORT_ASSIGN 0x9a
+#undef MC_CMD_0x9a_PRIVILEGE_CTG
+
+#define MC_CMD_0x9a_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_EVB_PORT_ASSIGN_IN msgrequest */
 #define    MC_CMD_EVB_PORT_ASSIGN_IN_LEN 8
@@ -5730,6 +6039,9 @@
  * Assign the 64 bit region addresses.
  */
 #define MC_CMD_RDWR_A64_REGIONS 0x9b
+#undef MC_CMD_0x9b_PRIVILEGE_CTG
+
+#define MC_CMD_0x9b_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_RDWR_A64_REGIONS_IN msgrequest */
 #define    MC_CMD_RDWR_A64_REGIONS_IN_LEN 17
@@ -5758,6 +6070,9 @@
  * Allocate an Onload stack ID.
  */
 #define MC_CMD_ONLOAD_STACK_ALLOC 0x9c
+#undef MC_CMD_0x9c_PRIVILEGE_CTG
+
+#define MC_CMD_0x9c_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
 
 /* MC_CMD_ONLOAD_STACK_ALLOC_IN msgrequest */
 #define    MC_CMD_ONLOAD_STACK_ALLOC_IN_LEN 4
@@ -5775,6 +6090,9 @@
  * Free an Onload stack ID.
  */
 #define MC_CMD_ONLOAD_STACK_FREE 0x9d
+#undef MC_CMD_0x9d_PRIVILEGE_CTG
+
+#define MC_CMD_0x9d_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
 
 /* MC_CMD_ONLOAD_STACK_FREE_IN msgrequest */
 #define    MC_CMD_ONLOAD_STACK_FREE_IN_LEN 4
@@ -5790,6 +6108,9 @@
  * Allocate an RSS context.
  */
 #define MC_CMD_RSS_CONTEXT_ALLOC 0x9e
+#undef MC_CMD_0x9e_PRIVILEGE_CTG
+
+#define MC_CMD_0x9e_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_RSS_CONTEXT_ALLOC_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_ALLOC_IN_LEN 12
@@ -5822,6 +6143,9 @@
  * Free an RSS context.
  */
 #define MC_CMD_RSS_CONTEXT_FREE 0x9f
+#undef MC_CMD_0x9f_PRIVILEGE_CTG
+
+#define MC_CMD_0x9f_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_RSS_CONTEXT_FREE_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_FREE_IN_LEN 4
@@ -5837,6 +6161,9 @@
  * Set the Toeplitz hash key for an RSS context.
  */
 #define MC_CMD_RSS_CONTEXT_SET_KEY 0xa0
+#undef MC_CMD_0xa0_PRIVILEGE_CTG
+
+#define MC_CMD_0xa0_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_RSS_CONTEXT_SET_KEY_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_SET_KEY_IN_LEN 44
@@ -5855,6 +6182,9 @@
  * Get the Toeplitz hash key for an RSS context.
  */
 #define MC_CMD_RSS_CONTEXT_GET_KEY 0xa1
+#undef MC_CMD_0xa1_PRIVILEGE_CTG
+
+#define MC_CMD_0xa1_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_RSS_CONTEXT_GET_KEY_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_GET_KEY_IN_LEN 4
@@ -5873,6 +6203,9 @@
  * Set the indirection table for an RSS context.
  */
 #define MC_CMD_RSS_CONTEXT_SET_TABLE 0xa2
+#undef MC_CMD_0xa2_PRIVILEGE_CTG
+
+#define MC_CMD_0xa2_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_RSS_CONTEXT_SET_TABLE_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_SET_TABLE_IN_LEN 132
@@ -5891,6 +6224,9 @@
  * Get the indirection table for an RSS context.
  */
 #define MC_CMD_RSS_CONTEXT_GET_TABLE 0xa3
+#undef MC_CMD_0xa3_PRIVILEGE_CTG
+
+#define MC_CMD_0xa3_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_RSS_CONTEXT_GET_TABLE_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_GET_TABLE_IN_LEN 4
@@ -5909,6 +6245,9 @@
  * Set various control flags for an RSS context.
  */
 #define MC_CMD_RSS_CONTEXT_SET_FLAGS 0xe1
+#undef MC_CMD_0xe1_PRIVILEGE_CTG
+
+#define MC_CMD_0xe1_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_RSS_CONTEXT_SET_FLAGS_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_LEN 8
@@ -5934,6 +6273,9 @@
  * Get various control flags for an RSS context.
  */
 #define MC_CMD_RSS_CONTEXT_GET_FLAGS 0xe2
+#undef MC_CMD_0xe2_PRIVILEGE_CTG
+
+#define MC_CMD_0xe2_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_RSS_CONTEXT_GET_FLAGS_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_GET_FLAGS_IN_LEN 4
@@ -5959,6 +6301,9 @@
  * Allocate a .1p mapping.
  */
 #define MC_CMD_DOT1P_MAPPING_ALLOC 0xa4
+#undef MC_CMD_0xa4_PRIVILEGE_CTG
+
+#define MC_CMD_0xa4_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_DOT1P_MAPPING_ALLOC_IN msgrequest */
 #define    MC_CMD_DOT1P_MAPPING_ALLOC_IN_LEN 8
@@ -5981,6 +6326,9 @@
  * Free a .1p mapping.
  */
 #define MC_CMD_DOT1P_MAPPING_FREE 0xa5
+#undef MC_CMD_0xa5_PRIVILEGE_CTG
+
+#define MC_CMD_0xa5_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_DOT1P_MAPPING_FREE_IN msgrequest */
 #define    MC_CMD_DOT1P_MAPPING_FREE_IN_LEN 4
@@ -5996,6 +6344,9 @@
  * Set the mapping table for a .1p mapping.
  */
 #define MC_CMD_DOT1P_MAPPING_SET_TABLE 0xa6
+#undef MC_CMD_0xa6_PRIVILEGE_CTG
+
+#define MC_CMD_0xa6_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_DOT1P_MAPPING_SET_TABLE_IN msgrequest */
 #define    MC_CMD_DOT1P_MAPPING_SET_TABLE_IN_LEN 36
@@ -6016,6 +6367,9 @@
  * Get the mapping table for a .1p mapping.
  */
 #define MC_CMD_DOT1P_MAPPING_GET_TABLE 0xa7
+#undef MC_CMD_0xa7_PRIVILEGE_CTG
+
+#define MC_CMD_0xa7_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_DOT1P_MAPPING_GET_TABLE_IN msgrequest */
 #define    MC_CMD_DOT1P_MAPPING_GET_TABLE_IN_LEN 4
@@ -6036,6 +6390,9 @@
  * Get Interrupt Vector config for this PF.
  */
 #define MC_CMD_GET_VECTOR_CFG 0xbf
+#undef MC_CMD_0xbf_PRIVILEGE_CTG
+
+#define MC_CMD_0xbf_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_VECTOR_CFG_IN msgrequest */
 #define    MC_CMD_GET_VECTOR_CFG_IN_LEN 0
@@ -6055,6 +6412,9 @@
  * Set Interrupt Vector config for this PF.
  */
 #define MC_CMD_SET_VECTOR_CFG 0xc0
+#undef MC_CMD_0xc0_PRIVILEGE_CTG
+
+#define MC_CMD_0xc0_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_SET_VECTOR_CFG_IN msgrequest */
 #define    MC_CMD_SET_VECTOR_CFG_IN_LEN 12
@@ -6445,6 +6805,9 @@
  * Add a MAC address to a v-port
  */
 #define MC_CMD_VPORT_ADD_MAC_ADDRESS 0xa8
+#undef MC_CMD_0xa8_PRIVILEGE_CTG
+
+#define MC_CMD_0xa8_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_VPORT_ADD_MAC_ADDRESS_IN msgrequest */
 #define    MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_LEN 10
@@ -6463,6 +6826,9 @@
  * Delete a MAC address from a v-port
  */
 #define MC_CMD_VPORT_DEL_MAC_ADDRESS 0xa9
+#undef MC_CMD_0xa9_PRIVILEGE_CTG
+
+#define MC_CMD_0xa9_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_VPORT_DEL_MAC_ADDRESS_IN msgrequest */
 #define    MC_CMD_VPORT_DEL_MAC_ADDRESS_IN_LEN 10
@@ -6481,6 +6847,9 @@
  * Delete a MAC address from a v-port
  */
 #define MC_CMD_VPORT_GET_MAC_ADDRESSES 0xaa
+#undef MC_CMD_0xaa_PRIVILEGE_CTG
+
+#define MC_CMD_0xaa_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_VPORT_GET_MAC_ADDRESSES_IN msgrequest */
 #define    MC_CMD_VPORT_GET_MAC_ADDRESSES_IN_LEN 4
@@ -6508,6 +6877,9 @@
  * lifted in future.
  */
 #define MC_CMD_DUMP_BUFTBL_ENTRIES 0xab
+#undef MC_CMD_0xab_PRIVILEGE_CTG
+
+#define MC_CMD_0xab_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_DUMP_BUFTBL_ENTRIES_IN msgrequest */
 #define    MC_CMD_DUMP_BUFTBL_ENTRIES_IN_LEN 8
@@ -6532,6 +6904,9 @@
  * Set global RXDP configuration settings
  */
 #define MC_CMD_SET_RXDP_CONFIG 0xc1
+#undef MC_CMD_0xc1_PRIVILEGE_CTG
+
+#define MC_CMD_0xc1_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SET_RXDP_CONFIG_IN msgrequest */
 #define    MC_CMD_SET_RXDP_CONFIG_IN_LEN 4
@@ -6548,6 +6923,9 @@
  * Get global RXDP configuration settings
  */
 #define MC_CMD_GET_RXDP_CONFIG 0xc2
+#undef MC_CMD_0xc2_PRIVILEGE_CTG
+
+#define MC_CMD_0xc2_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_GET_RXDP_CONFIG_IN msgrequest */
 #define    MC_CMD_GET_RXDP_CONFIG_IN_LEN 0
@@ -6912,6 +7290,9 @@
  * Return the system and PDCPU clock frequencies.
  */
 #define MC_CMD_GET_CLOCK 0xac
+#undef MC_CMD_0xac_PRIVILEGE_CTG
+
+#define MC_CMD_0xac_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_CLOCK_IN msgrequest */
 #define    MC_CMD_GET_CLOCK_IN_LEN 0
@@ -6929,6 +7310,9 @@
  * Control the system and DPCPU clock frequencies. Changes are lost reboot.
  */
 #define MC_CMD_SET_CLOCK 0xad
+#undef MC_CMD_0xad_PRIVILEGE_CTG
+
+#define MC_CMD_0xad_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SET_CLOCK_IN msgrequest */
 #define    MC_CMD_SET_CLOCK_IN_LEN 12
@@ -6954,6 +7338,9 @@
  * Send an arbitrary DPCPU message.
  */
 #define MC_CMD_DPCPU_RPC 0xae
+#undef MC_CMD_0xae_PRIVILEGE_CTG
+
+#define MC_CMD_0xae_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_DPCPU_RPC_IN msgrequest */
 #define    MC_CMD_DPCPU_RPC_IN_LEN 36
@@ -7038,6 +7425,9 @@
  * Trigger an interrupt by prodding the BIU.
  */
 #define MC_CMD_TRIGGER_INTERRUPT 0xe3
+#undef MC_CMD_0xe3_PRIVILEGE_CTG
+
+#define MC_CMD_0xe3_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_TRIGGER_INTERRUPT_IN msgrequest */
 #define    MC_CMD_TRIGGER_INTERRUPT_IN_LEN 4
@@ -7053,6 +7443,9 @@
  * Read multiple 64bit words from capture block memory
  */
 #define MC_CMD_CAP_BLK_READ 0xe7
+#undef MC_CMD_0xe7_PRIVILEGE_CTG
+
+#define MC_CMD_0xe7_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_CAP_BLK_READ_IN msgrequest */
 #define    MC_CMD_CAP_BLK_READ_IN_LEN 12
@@ -7077,6 +7470,9 @@
  * Take a dump of the DUT state
  */
 #define MC_CMD_DUMP_DO 0xe8
+#undef MC_CMD_0xe8_PRIVILEGE_CTG
+
+#define MC_CMD_0xe8_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_DUMP_DO_IN msgrequest */
 #define    MC_CMD_DUMP_DO_IN_LEN 52
@@ -7130,6 +7526,9 @@
  * Configure unsolicited dumps
  */
 #define MC_CMD_DUMP_CONFIGURE_UNSOLICITED 0xe9
+#undef MC_CMD_0xe9_PRIVILEGE_CTG
+
+#define MC_CMD_0xe9_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_DUMP_CONFIGURE_UNSOLICITED_IN msgrequest */
 #define    MC_CMD_DUMP_CONFIGURE_UNSOLICITED_IN_LEN 52
@@ -7173,6 +7572,9 @@
  * the parameter is out of range.
  */
 #define MC_CMD_SET_PSU 0xea
+#undef MC_CMD_0xea_PRIVILEGE_CTG
+
+#define MC_CMD_0xea_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SET_PSU_IN msgrequest */
 #define    MC_CMD_SET_PSU_IN_LEN 12
@@ -7193,6 +7595,9 @@
  * Get function information. PF and VF number.
  */
 #define MC_CMD_GET_FUNCTION_INFO 0xec
+#undef MC_CMD_0xec_PRIVILEGE_CTG
+
+#define MC_CMD_0xec_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_FUNCTION_INFO_IN msgrequest */
 #define    MC_CMD_GET_FUNCTION_INFO_IN_LEN 0
@@ -7210,6 +7615,9 @@
  * reboot.
  */
 #define MC_CMD_ENABLE_OFFLINE_BIST 0xed
+#undef MC_CMD_0xed_PRIVILEGE_CTG
+
+#define MC_CMD_0xed_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_ENABLE_OFFLINE_BIST_IN msgrequest */
 #define    MC_CMD_ENABLE_OFFLINE_BIST_IN_LEN 0
@@ -7225,6 +7633,9 @@
  * forget.
  */
 #define MC_CMD_UART_SEND_DATA 0xee
+#undef MC_CMD_0xee_PRIVILEGE_CTG
+
+#define MC_CMD_0xee_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_UART_SEND_DATA_OUT msgrequest */
 #define    MC_CMD_UART_SEND_DATA_OUT_LENMIN 16
@@ -7253,6 +7664,9 @@
  * subject to change and not currently implemented.
  */
 #define MC_CMD_UART_RECV_DATA 0xef
+#undef MC_CMD_0xef_PRIVILEGE_CTG
+
+#define MC_CMD_0xef_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_UART_RECV_DATA_OUT msgrequest */
 #define    MC_CMD_UART_RECV_DATA_OUT_LEN 16
@@ -7288,6 +7702,9 @@
  * Read data programmed into the device One-Time-Programmable (OTP) Fuses
  */
 #define MC_CMD_READ_FUSES 0xf0
+#undef MC_CMD_0xf0_PRIVILEGE_CTG
+
+#define MC_CMD_0xf0_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_READ_FUSES_IN msgrequest */
 #define    MC_CMD_READ_FUSES_IN_LEN 8
@@ -7314,6 +7731,9 @@
  * Get or set KR Serdes RXEQ and TX Driver settings
  */
 #define MC_CMD_KR_TUNE 0xf1
+#undef MC_CMD_0xf1_PRIVILEGE_CTG
+
+#define MC_CMD_0xf1_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_KR_TUNE_IN msgrequest */
 #define    MC_CMD_KR_TUNE_IN_LENMIN 4
@@ -7572,6 +7992,9 @@
  * Get or set PCIE Serdes RXEQ and TX Driver settings
  */
 #define MC_CMD_PCIE_TUNE 0xf2
+#undef MC_CMD_0xf2_PRIVILEGE_CTG
+
+#define MC_CMD_0xf2_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_PCIE_TUNE_IN msgrequest */
 #define    MC_CMD_PCIE_TUNE_IN_LENMIN 4
@@ -7733,6 +8156,9 @@
  * Operations on the NVRAM_PARTITION_TYPE_LICENSE application license partition
  */
 #define MC_CMD_LICENSING 0xf3
+#undef MC_CMD_0xf3_PRIVILEGE_CTG
+
+#define MC_CMD_0xf3_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_LICENSING_IN msgrequest */
 #define    MC_CMD_LICENSING_IN_LEN 4
@@ -7778,6 +8204,9 @@
  * This will fail on a single-core system.
  */
 #define MC_CMD_MC2MC_PROXY 0xf4
+#undef MC_CMD_0xf4_PRIVILEGE_CTG
+
+#define MC_CMD_0xf4_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_MC2MC_PROXY_IN msgrequest */
 #define    MC_CMD_MC2MC_PROXY_IN_LEN 0
@@ -7793,6 +8222,9 @@
  * or a reboot of the MC.)
  */
 #define MC_CMD_GET_LICENSED_APP_STATE 0xf5
+#undef MC_CMD_0xf5_PRIVILEGE_CTG
+
+#define MC_CMD_0xf5_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_GET_LICENSED_APP_STATE_IN msgrequest */
 #define    MC_CMD_GET_LICENSED_APP_STATE_IN_LEN 4
@@ -7814,6 +8246,9 @@
  * Perform an action for an individual licensed application.
  */
 #define MC_CMD_LICENSED_APP_OP 0xf6
+#undef MC_CMD_0xf6_PRIVILEGE_CTG
+
+#define MC_CMD_0xf6_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 
 /* MC_CMD_LICENSED_APP_OP_IN msgrequest */
 #define    MC_CMD_LICENSED_APP_OP_IN_LENMIN 8
@@ -7869,6 +8304,9 @@
  * delivered to a specific queue, or a set of queues with RSS.
  */
 #define MC_CMD_SET_PORT_SNIFF_CONFIG 0xf7
+#undef MC_CMD_0xf7_PRIVILEGE_CTG
+
+#define MC_CMD_0xf7_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_SET_PORT_SNIFF_CONFIG_IN msgrequest */
 #define    MC_CMD_SET_PORT_SNIFF_CONFIG_IN_LEN 16
@@ -7903,6 +8341,9 @@
  * the configuration.
  */
 #define MC_CMD_GET_PORT_SNIFF_CONFIG 0xf8
+#undef MC_CMD_0xf8_PRIVILEGE_CTG
+
+#define MC_CMD_0xf8_PRIVILEGE_CTG SRIOV_CTG_ADMIN
 
 /* MC_CMD_GET_PORT_SNIFF_CONFIG_IN msgrequest */
 #define    MC_CMD_GET_PORT_SNIFF_CONFIG_IN_LEN 0
