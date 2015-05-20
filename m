From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 01/16] sfc: Add permissions to MCDI commands
Date: Wed, 20 May 2015 11:08:23 +0100
Message-ID: <555C5D17.3050006@solarflare.com>
References: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:53240 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753189AbbETKIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:08:34 -0400
In-Reply-To: <555C5C91.4000004@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is one primary function per adaptor, one link control function
per port and the rest as categorised as general.

This patch adds privileges to the MCDI commands based on which
functions are allowed to call them.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_pcol.h | 294 +++++++++++++++++++++++++++++++++++
 1 file changed, 294 insertions(+)

diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 4fa6eb2..797b9df 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -638,6 +638,8 @@
  */
 #define MC_CMD_READ32 0x1
 
+#define MC_CMD_0x1_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_READ32_IN msgrequest */
 #define    MC_CMD_READ32_IN_LEN 8
 #define       MC_CMD_READ32_IN_ADDR_OFST 0
@@ -659,6 +661,8 @@
  */
 #define MC_CMD_WRITE32 0x2
 
+#define MC_CMD_0x2_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_WRITE32_IN msgrequest */
 #define    MC_CMD_WRITE32_IN_LENMIN 8
 #define    MC_CMD_WRITE32_IN_LENMAX 252
@@ -679,6 +683,8 @@
  */
 #define MC_CMD_COPYCODE 0x3
 
+#define MC_CMD_0x3_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_COPYCODE_IN msgrequest */
 #define    MC_CMD_COPYCODE_IN_LEN 16
 /* Source address */
@@ -717,6 +723,8 @@
  */
 #define MC_CMD_SET_FUNC 0x4
 
+#define MC_CMD_0x4_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SET_FUNC_IN msgrequest */
 #define    MC_CMD_SET_FUNC_IN_LEN 4
 /* Set function */
@@ -732,6 +740,8 @@
  */
 #define MC_CMD_GET_BOOT_STATUS 0x5
 
+#define MC_CMD_0x5_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_GET_BOOT_STATUS_IN msgrequest */
 #define    MC_CMD_GET_BOOT_STATUS_IN_LEN 0
 
@@ -758,6 +768,8 @@
  */
 #define MC_CMD_GET_ASSERTS 0x6
 
+#define MC_CMD_0x6_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_GET_ASSERTS_IN msgrequest */
 #define    MC_CMD_GET_ASSERTS_IN_LEN 4
 /* Set to clear assertion */
@@ -794,6 +806,8 @@
  */
 #define MC_CMD_LOG_CTRL 0x7
 
+#define MC_CMD_0x7_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_LOG_CTRL_IN msgrequest */
 #define    MC_CMD_LOG_CTRL_IN_LEN 8
 /* Log destination */
@@ -814,6 +828,8 @@
  */
 #define MC_CMD_GET_VERSION 0x8
 
+#define MC_CMD_0x8_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_VERSION_IN msgrequest */
 #define    MC_CMD_GET_VERSION_IN_LEN 0
 
@@ -870,6 +886,8 @@
  */
 #define MC_CMD_PTP 0xb
 
+#define MC_CMD_0xb_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_PTP_IN msgrequest */
 #define    MC_CMD_PTP_IN_LEN 1
 /* PTP operation code */
@@ -1404,6 +1422,8 @@
  */
 #define MC_CMD_CSR_READ32 0xc
 
+#define MC_CMD_0xc_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_CSR_READ32_IN msgrequest */
 #define    MC_CMD_CSR_READ32_IN_LEN 12
 /* Address */
@@ -1428,6 +1448,8 @@
  */
 #define MC_CMD_CSR_WRITE32 0xd
 
+#define MC_CMD_0xd_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_CSR_WRITE32_IN msgrequest */
 #define    MC_CMD_CSR_WRITE32_IN_LENMIN 12
 #define    MC_CMD_CSR_WRITE32_IN_LENMAX 252
@@ -1452,6 +1474,8 @@
  */
 #define MC_CMD_HP 0x54
 
+#define MC_CMD_0x54_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_HP_IN msgrequest */
 #define    MC_CMD_HP_IN_LEN 16
 /* HP OCSD sub-command. When address is not NULL, request activation of OCSD at
@@ -1493,6 +1517,8 @@
  */
 #define MC_CMD_STACKINFO 0xf
 
+#define MC_CMD_0xf_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_STACKINFO_IN msgrequest */
 #define    MC_CMD_STACKINFO_IN_LEN 0
 
@@ -1513,6 +1539,8 @@
  */
 #define MC_CMD_MDIO_READ 0x10
 
+#define MC_CMD_0x10_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_MDIO_READ_IN msgrequest */
 #define    MC_CMD_MDIO_READ_IN_LEN 16
 /* Bus number; there are two MDIO buses: one for the internal PHY, and one for
@@ -1552,6 +1580,8 @@
  */
 #define MC_CMD_MDIO_WRITE 0x11
 
+#define MC_CMD_0x11_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_MDIO_WRITE_IN msgrequest */
 #define    MC_CMD_MDIO_WRITE_IN_LEN 20
 /* Bus number; there are two MDIO buses: one for the internal PHY, and one for
@@ -1591,6 +1621,8 @@
  */
 #define MC_CMD_DBI_WRITE 0x12
 
+#define MC_CMD_0x12_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_DBI_WRITE_IN msgrequest */
 #define    MC_CMD_DBI_WRITE_IN_LENMIN 12
 #define    MC_CMD_DBI_WRITE_IN_LENMAX 252
@@ -1739,6 +1771,8 @@
  */
 #define MC_CMD_GET_BOARD_CFG 0x18
 
+#define MC_CMD_0x18_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_BOARD_CFG_IN msgrequest */
 #define    MC_CMD_GET_BOARD_CFG_IN_LEN 0
 
@@ -1778,6 +1812,8 @@
  */
 #define MC_CMD_DBI_READX 0x19
 
+#define MC_CMD_0x19_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_DBI_READX_IN msgrequest */
 #define    MC_CMD_DBI_READX_IN_LENMIN 8
 #define    MC_CMD_DBI_READX_IN_LENMAX 248
@@ -1822,6 +1858,8 @@
  */
 #define MC_CMD_SET_RAND_SEED 0x1a
 
+#define MC_CMD_0x1a_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SET_RAND_SEED_IN msgrequest */
 #define    MC_CMD_SET_RAND_SEED_IN_LEN 16
 /* Seed value. */
@@ -1863,6 +1901,8 @@
  */
 #define MC_CMD_DRV_ATTACH 0x1c
 
+#define MC_CMD_0x1c_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_DRV_ATTACH_IN msgrequest */
 #define    MC_CMD_DRV_ATTACH_IN_LEN 12
 /* new state (0=detached, 1=attached) to set if UPDATE=1 */
@@ -1922,6 +1962,8 @@
  */
 #define MC_CMD_PORT_RESET 0x20
 
+#define MC_CMD_0x20_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_PORT_RESET_IN msgrequest */
 #define    MC_CMD_PORT_RESET_IN_LEN 0
 
@@ -1936,6 +1978,7 @@
  * extended version of the deprecated MC_CMD_PORT_RESET with added fields.
  */
 #define MC_CMD_ENTITY_RESET 0x20
+/*      MC_CMD_0x20_PRIVILEGE_CTG SRIOV_CTG_GENERAL */
 
 /* MC_CMD_ENTITY_RESET_IN msgrequest */
 #define    MC_CMD_ENTITY_RESET_IN_LEN 4
@@ -2025,6 +2068,8 @@
  */
 #define MC_CMD_PUTS 0x23
 
+#define MC_CMD_0x23_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_PUTS_IN msgrequest */
 #define    MC_CMD_PUTS_IN_LENMIN 13
 #define    MC_CMD_PUTS_IN_LENMAX 252
@@ -2052,6 +2097,8 @@
  */
 #define MC_CMD_GET_PHY_CFG 0x24
 
+#define MC_CMD_0x24_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_PHY_CFG_IN msgrequest */
 #define    MC_CMD_GET_PHY_CFG_IN_LEN 0
 
@@ -2151,6 +2198,8 @@
  */
 #define MC_CMD_START_BIST 0x25
 
+#define MC_CMD_0x25_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_START_BIST_IN msgrequest */
 #define    MC_CMD_START_BIST_IN_LEN 4
 /* Type of test. */
@@ -2187,6 +2236,8 @@
  */
 #define MC_CMD_POLL_BIST 0x26
 
+#define MC_CMD_0x26_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_POLL_BIST_IN msgrequest */
 #define    MC_CMD_POLL_BIST_IN_LEN 0
 
@@ -2346,6 +2397,8 @@
  */
 #define MC_CMD_GET_LOOPBACK_MODES 0x28
 
+#define MC_CMD_0x28_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_LOOPBACK_MODES_IN msgrequest */
 #define    MC_CMD_GET_LOOPBACK_MODES_IN_LEN 0
 
@@ -2465,6 +2518,8 @@
  */
 #define MC_CMD_GET_LINK 0x29
 
+#define MC_CMD_0x29_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_LINK_IN msgrequest */
 #define    MC_CMD_GET_LINK_IN_LEN 0
 
@@ -2521,6 +2576,8 @@
  */
 #define MC_CMD_SET_LINK 0x2a
 
+#define MC_CMD_0x2a_PRIVILEGE_CTG SRIOV_CTG_LINK
+
 /* MC_CMD_SET_LINK_IN msgrequest */
 #define    MC_CMD_SET_LINK_IN_LEN 16
 /* ??? */
@@ -2552,6 +2609,8 @@
  */
 #define MC_CMD_SET_ID_LED 0x2b
 
+#define MC_CMD_0x2b_PRIVILEGE_CTG SRIOV_CTG_LINK
+
 /* MC_CMD_SET_ID_LED_IN msgrequest */
 #define    MC_CMD_SET_ID_LED_IN_LEN 4
 /* Set LED state. */
@@ -2570,6 +2629,8 @@
  */
 #define MC_CMD_SET_MAC 0x2c
 
+#define MC_CMD_0x2c_PRIVILEGE_CTG SRIOV_CTG_LINK
+
 /* MC_CMD_SET_MAC_IN msgrequest */
 #define    MC_CMD_SET_MAC_IN_LEN 24
 /* The MTU is the MTU programmed directly into the XMAC/GMAC (inclusive of
@@ -2611,6 +2672,8 @@
  */
 #define MC_CMD_PHY_STATS 0x2d
 
+#define MC_CMD_0x2d_PRIVILEGE_CTG SRIOV_CTG_LINK
+
 /* MC_CMD_PHY_STATS_IN msgrequest */
 #define    MC_CMD_PHY_STATS_IN_LEN 8
 /* ??? */
@@ -2689,6 +2752,8 @@
  */
 #define MC_CMD_MAC_STATS 0x2e
 
+#define MC_CMD_0x2e_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_MAC_STATS_IN msgrequest */
 #define    MC_CMD_MAC_STATS_IN_LEN 16
 /* ??? */
@@ -2928,6 +2993,8 @@
  */
 #define MC_CMD_WOL_FILTER_SET 0x32
 
+#define MC_CMD_0x32_PRIVILEGE_CTG SRIOV_CTG_LINK
+
 /* MC_CMD_WOL_FILTER_SET_IN msgrequest */
 #define    MC_CMD_WOL_FILTER_SET_IN_LEN 192
 #define       MC_CMD_WOL_FILTER_SET_IN_FILTER_MODE_OFST 0
@@ -3022,6 +3089,8 @@
  */
 #define MC_CMD_WOL_FILTER_REMOVE 0x33
 
+#define MC_CMD_0x33_PRIVILEGE_CTG SRIOV_CTG_LINK
+
 /* MC_CMD_WOL_FILTER_REMOVE_IN msgrequest */
 #define    MC_CMD_WOL_FILTER_REMOVE_IN_LEN 4
 #define       MC_CMD_WOL_FILTER_REMOVE_IN_FILTER_ID_OFST 0
@@ -3037,6 +3106,8 @@
  */
 #define MC_CMD_WOL_FILTER_RESET 0x34
 
+#define MC_CMD_0x34_PRIVILEGE_CTG SRIOV_CTG_LINK
+
 /* MC_CMD_WOL_FILTER_RESET_IN msgrequest */
 #define    MC_CMD_WOL_FILTER_RESET_IN_LEN 4
 #define       MC_CMD_WOL_FILTER_RESET_IN_MASK_OFST 0
@@ -3071,6 +3142,8 @@
  */
 #define MC_CMD_NVRAM_TYPES 0x36
 
+#define MC_CMD_0x36_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_NVRAM_TYPES_IN msgrequest */
 #define    MC_CMD_NVRAM_TYPES_IN_LEN 0
 
@@ -3127,6 +3200,8 @@
  */
 #define MC_CMD_NVRAM_INFO 0x37
 
+#define MC_CMD_0x37_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_NVRAM_INFO_IN msgrequest */
 #define    MC_CMD_NVRAM_INFO_IN_LEN 4
 #define       MC_CMD_NVRAM_INFO_IN_TYPE_OFST 0
@@ -3159,6 +3234,8 @@
  */
 #define MC_CMD_NVRAM_UPDATE_START 0x38
 
+#define MC_CMD_0x38_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_NVRAM_UPDATE_START_IN msgrequest */
 #define    MC_CMD_NVRAM_UPDATE_START_IN_LEN 4
 #define       MC_CMD_NVRAM_UPDATE_START_IN_TYPE_OFST 0
@@ -3177,6 +3254,8 @@
  */
 #define MC_CMD_NVRAM_READ 0x39
 
+#define MC_CMD_0x39_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_NVRAM_READ_IN msgrequest */
 #define    MC_CMD_NVRAM_READ_IN_LEN 12
 #define       MC_CMD_NVRAM_READ_IN_TYPE_OFST 0
@@ -3204,6 +3283,8 @@
  */
 #define MC_CMD_NVRAM_WRITE 0x3a
 
+#define MC_CMD_0x3a_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_NVRAM_WRITE_IN msgrequest */
 #define    MC_CMD_NVRAM_WRITE_IN_LENMIN 13
 #define    MC_CMD_NVRAM_WRITE_IN_LENMAX 252
@@ -3230,6 +3311,8 @@
  */
 #define MC_CMD_NVRAM_ERASE 0x3b
 
+#define MC_CMD_0x3b_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_NVRAM_ERASE_IN msgrequest */
 #define    MC_CMD_NVRAM_ERASE_IN_LEN 12
 #define       MC_CMD_NVRAM_ERASE_IN_TYPE_OFST 0
@@ -3250,6 +3333,8 @@
  */
 #define MC_CMD_NVRAM_UPDATE_FINISH 0x3c
 
+#define MC_CMD_0x3c_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_NVRAM_UPDATE_FINISH_IN msgrequest */
 #define    MC_CMD_NVRAM_UPDATE_FINISH_IN_LEN 8
 #define       MC_CMD_NVRAM_UPDATE_FINISH_IN_TYPE_OFST 0
@@ -3281,6 +3366,8 @@
  */
 #define MC_CMD_REBOOT 0x3d
 
+#define MC_CMD_0x3d_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_REBOOT_IN msgrequest */
 #define    MC_CMD_REBOOT_IN_LEN 4
 #define       MC_CMD_REBOOT_IN_FLAGS_OFST 0
@@ -3318,6 +3405,8 @@
  */
 #define MC_CMD_REBOOT_MODE 0x3f
 
+#define MC_CMD_0x3f_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_REBOOT_MODE_IN msgrequest */
 #define    MC_CMD_REBOOT_MODE_IN_LEN 4
 #define       MC_CMD_REBOOT_MODE_IN_VALUE_OFST 0
@@ -3370,6 +3459,8 @@
  */
 #define MC_CMD_SENSOR_INFO 0x41
 
+#define MC_CMD_0x41_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SENSOR_INFO_IN msgrequest */
 #define    MC_CMD_SENSOR_INFO_IN_LEN 0
 
@@ -3544,6 +3635,8 @@
  */
 #define MC_CMD_READ_SENSORS 0x42
 
+#define MC_CMD_0x42_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_READ_SENSORS_IN msgrequest */
 #define    MC_CMD_READ_SENSORS_IN_LEN 8
 /* DMA address of host buffer for sensor readings (must be 4Kbyte aligned). */
@@ -3604,6 +3697,8 @@
  */
 #define MC_CMD_GET_PHY_STATE 0x43
 
+#define MC_CMD_0x43_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_PHY_STATE_IN msgrequest */
 #define    MC_CMD_GET_PHY_STATE_IN_LEN 0
 
@@ -3638,6 +3733,8 @@
  */
 #define MC_CMD_WOL_FILTER_GET 0x45
 
+#define MC_CMD_0x45_PRIVILEGE_CTG SRIOV_CTG_LINK
+
 /* MC_CMD_WOL_FILTER_GET_IN msgrequest */
 #define    MC_CMD_WOL_FILTER_GET_IN_LEN 0
 
@@ -3653,6 +3750,8 @@
  */
 #define MC_CMD_ADD_LIGHTSOUT_OFFLOAD 0x46
 
+#define MC_CMD_0x46_PRIVILEGE_CTG SRIOV_CTG_LINK
+
 /* MC_CMD_ADD_LIGHTSOUT_OFFLOAD_IN msgrequest */
 #define    MC_CMD_ADD_LIGHTSOUT_OFFLOAD_IN_LENMIN 8
 #define    MC_CMD_ADD_LIGHTSOUT_OFFLOAD_IN_LENMAX 252
@@ -3694,6 +3793,8 @@
  */
 #define MC_CMD_REMOVE_LIGHTSOUT_OFFLOAD 0x47
 
+#define MC_CMD_0x47_PRIVILEGE_CTG SRIOV_CTG_LINK
+
 /* MC_CMD_REMOVE_LIGHTSOUT_OFFLOAD_IN msgrequest */
 #define    MC_CMD_REMOVE_LIGHTSOUT_OFFLOAD_IN_LEN 8
 #define       MC_CMD_REMOVE_LIGHTSOUT_OFFLOAD_IN_PROTOCOL_OFST 0
@@ -3724,6 +3825,8 @@
  */
 #define MC_CMD_TESTASSERT 0x49
 
+#define MC_CMD_0x49_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_TESTASSERT_IN msgrequest */
 #define    MC_CMD_TESTASSERT_IN_LEN 0
 
@@ -3741,6 +3844,8 @@
  */
 #define MC_CMD_WORKAROUND 0x4a
 
+#define MC_CMD_0x4a_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_WORKAROUND_IN msgrequest */
 #define    MC_CMD_WORKAROUND_IN_LEN 8
 #define       MC_CMD_WORKAROUND_IN_TYPE_OFST 0
@@ -3767,6 +3872,8 @@
  */
 #define MC_CMD_GET_PHY_MEDIA_INFO 0x4b
 
+#define MC_CMD_0x4b_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_GET_PHY_MEDIA_INFO_IN msgrequest */
 #define    MC_CMD_GET_PHY_MEDIA_INFO_IN_LEN 4
 #define       MC_CMD_GET_PHY_MEDIA_INFO_IN_PAGE_OFST 0
@@ -3790,6 +3897,8 @@
  */
 #define MC_CMD_NVRAM_TEST 0x4c
 
+#define MC_CMD_0x4c_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_NVRAM_TEST_IN msgrequest */
 #define    MC_CMD_NVRAM_TEST_IN_LEN 4
 #define       MC_CMD_NVRAM_TEST_IN_TYPE_OFST 0
@@ -3851,6 +3960,8 @@
  */
 #define MC_CMD_SENSOR_SET_LIMS 0x4e
 
+#define MC_CMD_0x4e_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SENSOR_SET_LIMS_IN msgrequest */
 #define    MC_CMD_SENSOR_SET_LIMS_IN_LEN 20
 #define       MC_CMD_SENSOR_SET_LIMS_IN_SENSOR_OFST 0
@@ -3892,6 +4003,8 @@
  */
 #define MC_CMD_NVRAM_PARTITIONS 0x51
 
+#define MC_CMD_0x51_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_NVRAM_PARTITIONS_IN msgrequest */
 #define    MC_CMD_NVRAM_PARTITIONS_IN_LEN 0
 
@@ -3915,6 +4028,8 @@
  */
 #define MC_CMD_NVRAM_METADATA 0x52
 
+#define MC_CMD_0x52_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_NVRAM_METADATA_IN msgrequest */
 #define    MC_CMD_NVRAM_METADATA_IN_LEN 4
 /* Partition type ID code */
@@ -3960,6 +4075,8 @@
  */
 #define MC_CMD_GET_MAC_ADDRESSES 0x55
 
+#define MC_CMD_0x55_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_MAC_ADDRESSES_IN msgrequest */
 #define    MC_CMD_GET_MAC_ADDRESSES_IN_LEN 0
 
@@ -4115,6 +4232,8 @@
  */
 #define MC_CMD_READ_REGS 0x50
 
+#define MC_CMD_0x50_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_READ_REGS_IN msgrequest */
 #define    MC_CMD_READ_REGS_IN_LEN 0
 
@@ -4138,6 +4257,8 @@
  */
 #define MC_CMD_INIT_EVQ 0x80
 
+#define MC_CMD_0x80_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_INIT_EVQ_IN msgrequest */
 #define    MC_CMD_INIT_EVQ_IN_LENMIN 44
 #define    MC_CMD_INIT_EVQ_IN_LENMAX 548
@@ -4236,6 +4357,8 @@
  */
 #define MC_CMD_INIT_RXQ 0x81
 
+#define MC_CMD_0x81_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_INIT_RXQ_IN msgrequest */
 #define    MC_CMD_INIT_RXQ_IN_LENMIN 36
 #define    MC_CMD_INIT_RXQ_IN_LENMAX 252
@@ -4288,6 +4411,8 @@
  */
 #define MC_CMD_INIT_TXQ 0x82
 
+#define MC_CMD_0x82_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_INIT_TXQ_IN msgrequest */
 #define    MC_CMD_INIT_TXQ_IN_LENMIN 36
 #define    MC_CMD_INIT_TXQ_IN_LENMAX 252
@@ -4345,6 +4470,8 @@
  */
 #define MC_CMD_FINI_EVQ 0x83
 
+#define MC_CMD_0x83_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_FINI_EVQ_IN msgrequest */
 #define    MC_CMD_FINI_EVQ_IN_LEN 4
 /* Instance of EVQ to destroy. Should be the same instance as that previously
@@ -4362,6 +4489,8 @@
  */
 #define MC_CMD_FINI_RXQ 0x84
 
+#define MC_CMD_0x84_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_FINI_RXQ_IN msgrequest */
 #define    MC_CMD_FINI_RXQ_IN_LEN 4
 /* Instance of RXQ to destroy */
@@ -4377,6 +4506,8 @@
  */
 #define MC_CMD_FINI_TXQ 0x85
 
+#define MC_CMD_0x85_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_FINI_TXQ_IN msgrequest */
 #define    MC_CMD_FINI_TXQ_IN_LEN 4
 /* Instance of TXQ to destroy */
@@ -4392,6 +4523,8 @@
  */
 #define MC_CMD_DRIVER_EVENT 0x86
 
+#define MC_CMD_0x86_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_DRIVER_EVENT_IN msgrequest */
 #define    MC_CMD_DRIVER_EVENT_IN_LEN 12
 /* Handle of target EVQ */
@@ -4415,6 +4548,8 @@
  */
 #define MC_CMD_PROXY_CMD 0x5b
 
+#define MC_CMD_0x5b_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_PROXY_CMD_IN msgrequest */
 #define    MC_CMD_PROXY_CMD_IN_LEN 4
 /* The handle of the target function. */
@@ -4437,6 +4572,8 @@
  */
 #define MC_CMD_ALLOC_BUFTBL_CHUNK 0x87
 
+#define MC_CMD_0x87_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
+
 /* MC_CMD_ALLOC_BUFTBL_CHUNK_IN msgrequest */
 #define    MC_CMD_ALLOC_BUFTBL_CHUNK_IN_LEN 8
 /* Owner ID to use */
@@ -4460,6 +4597,8 @@
  */
 #define MC_CMD_PROGRAM_BUFTBL_ENTRIES 0x88
 
+#define MC_CMD_0x88_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
+
 /* MC_CMD_PROGRAM_BUFTBL_ENTRIES_IN msgrequest */
 #define    MC_CMD_PROGRAM_BUFTBL_ENTRIES_IN_LENMIN 20
 #define    MC_CMD_PROGRAM_BUFTBL_ENTRIES_IN_LENMAX 268
@@ -4486,6 +4625,8 @@
  */
 #define MC_CMD_FREE_BUFTBL_CHUNK 0x89
 
+#define MC_CMD_0x89_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
+
 /* MC_CMD_FREE_BUFTBL_CHUNK_IN msgrequest */
 #define    MC_CMD_FREE_BUFTBL_CHUNK_IN_LEN 4
 #define       MC_CMD_FREE_BUFTBL_CHUNK_IN_HANDLE_OFST 0
@@ -4500,6 +4641,8 @@
  */
 #define MC_CMD_FILTER_OP 0x8a
 
+#define MC_CMD_0x8a_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_FILTER_OP_IN msgrequest */
 #define    MC_CMD_FILTER_OP_IN_LEN 108
 /* identifies the type of operation requested */
@@ -4660,6 +4803,8 @@
  */
 #define MC_CMD_GET_PARSER_DISP_INFO 0xe4
 
+#define MC_CMD_0xe4_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_PARSER_DISP_INFO_IN msgrequest */
 #define    MC_CMD_GET_PARSER_DISP_INFO_IN_LEN 4
 /* identifies the type of operation requested */
@@ -4692,6 +4837,8 @@
  */
 #define MC_CMD_PARSER_DISP_RW 0xe5
 
+#define MC_CMD_0xe5_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_PARSER_DISP_RW_IN msgrequest */
 #define    MC_CMD_PARSER_DISP_RW_IN_LEN 32
 /* identifies the target of the operation */
@@ -4742,6 +4889,8 @@
  */
 #define MC_CMD_GET_PF_COUNT 0xb6
 
+#define MC_CMD_0xb6_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_PF_COUNT_IN msgrequest */
 #define    MC_CMD_GET_PF_COUNT_IN_LEN 0
 
@@ -4773,6 +4922,8 @@
  */
 #define MC_CMD_GET_PORT_ASSIGNMENT 0xb8
 
+#define MC_CMD_0xb8_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_PORT_ASSIGNMENT_IN msgrequest */
 #define    MC_CMD_GET_PORT_ASSIGNMENT_IN_LEN 0
 
@@ -4788,6 +4939,8 @@
  */
 #define MC_CMD_SET_PORT_ASSIGNMENT 0xb9
 
+#define MC_CMD_0xb9_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SET_PORT_ASSIGNMENT_IN msgrequest */
 #define    MC_CMD_SET_PORT_ASSIGNMENT_IN_LEN 4
 /* Identifies the port assignment for this function. */
@@ -4803,6 +4956,8 @@
  */
 #define MC_CMD_ALLOC_VIS 0x8b
 
+#define MC_CMD_0x8b_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_ALLOC_VIS_IN msgrequest */
 #define    MC_CMD_ALLOC_VIS_IN_LEN 8
 /* The minimum number of VIs that is acceptable */
@@ -4827,6 +4982,8 @@
  */
 #define MC_CMD_FREE_VIS 0x8c
 
+#define MC_CMD_0x8c_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_FREE_VIS_IN msgrequest */
 #define    MC_CMD_FREE_VIS_IN_LEN 0
 
@@ -4840,6 +4997,8 @@
  */
 #define MC_CMD_GET_SRIOV_CFG 0xba
 
+#define MC_CMD_0xba_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_SRIOV_CFG_IN msgrequest */
 #define    MC_CMD_GET_SRIOV_CFG_IN_LEN 0
 
@@ -4864,6 +5023,8 @@
  */
 #define MC_CMD_SET_SRIOV_CFG 0xbb
 
+#define MC_CMD_0xbb_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SET_SRIOV_CFG_IN msgrequest */
 #define    MC_CMD_SET_SRIOV_CFG_IN_LEN 20
 /* Number of VFs currently enabled. */
@@ -4893,6 +5054,8 @@
  */
 #define MC_CMD_GET_VI_ALLOC_INFO 0x8d
 
+#define MC_CMD_0x8d_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_VI_ALLOC_INFO_IN msgrequest */
 #define    MC_CMD_GET_VI_ALLOC_INFO_IN_LEN 0
 
@@ -4912,6 +5075,8 @@
  */
 #define MC_CMD_DUMP_VI_STATE 0x8e
 
+#define MC_CMD_0x8e_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_DUMP_VI_STATE_IN msgrequest */
 #define    MC_CMD_DUMP_VI_STATE_IN_LEN 4
 /* The VI number to query. */
@@ -5021,6 +5186,8 @@
  */
 #define MC_CMD_ALLOC_PIOBUF 0x8f
 
+#define MC_CMD_0x8f_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
+
 /* MC_CMD_ALLOC_PIOBUF_IN msgrequest */
 #define    MC_CMD_ALLOC_PIOBUF_IN_LEN 0
 
@@ -5036,6 +5203,8 @@
  */
 #define MC_CMD_FREE_PIOBUF 0x90
 
+#define MC_CMD_0x90_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
+
 /* MC_CMD_FREE_PIOBUF_IN msgrequest */
 #define    MC_CMD_FREE_PIOBUF_IN_LEN 4
 /* Handle for allocated push I/O buffer. */
@@ -5051,6 +5220,8 @@
  */
 #define MC_CMD_GET_VI_TLP_PROCESSING 0xb0
 
+#define MC_CMD_0xb0_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_VI_TLP_PROCESSING_IN msgrequest */
 #define    MC_CMD_GET_VI_TLP_PROCESSING_IN_LEN 4
 /* VI number to get information for. */
@@ -5085,6 +5256,8 @@
  */
 #define MC_CMD_SET_VI_TLP_PROCESSING 0xb1
 
+#define MC_CMD_0xb1_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_SET_VI_TLP_PROCESSING_IN msgrequest */
 #define    MC_CMD_SET_VI_TLP_PROCESSING_IN_LEN 8
 /* VI number to set information for. */
@@ -5119,6 +5292,8 @@
  */
 #define MC_CMD_GET_TLP_PROCESSING_GLOBALS 0xbc
 
+#define MC_CMD_0xbc_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_GET_TLP_PROCESSING_GLOBALS_IN msgrequest */
 #define    MC_CMD_GET_TLP_PROCESSING_GLOBALS_IN_LEN 4
 #define       MC_CMD_GET_TLP_PROCESSING_GLOBALS_IN_TLP_GLOBAL_CATEGORY_OFST 0
@@ -5180,6 +5355,8 @@
  */
 #define MC_CMD_SET_TLP_PROCESSING_GLOBALS 0xbd
 
+#define MC_CMD_0xbd_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SET_TLP_PROCESSING_GLOBALS_IN msgrequest */
 #define    MC_CMD_SET_TLP_PROCESSING_GLOBALS_IN_LEN 8
 #define       MC_CMD_SET_TLP_PROCESSING_GLOBALS_IN_TLP_GLOBAL_CATEGORY_OFST 0
@@ -5226,6 +5403,8 @@
  */
 #define MC_CMD_SATELLITE_DOWNLOAD 0x91
 
+#define MC_CMD_0x91_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SATELLITE_DOWNLOAD_IN msgrequest: The reset requirements for the CPUs
  * are subtle, and so downloads must proceed in a number of phases.
  *
@@ -5341,6 +5520,7 @@
  */
 #define MC_CMD_GET_CAPABILITIES 0xbe
 
+#define MC_CMD_0xbe_PRIVILEGE_CTG SRIOV_CTG_GENERAL
 /* MC_CMD_GET_CAPABILITIES_IN msgrequest */
 #define    MC_CMD_GET_CAPABILITIES_IN_LEN 0
 
@@ -5456,6 +5636,8 @@
  */
 #define MC_CMD_TCM_BUCKET_ALLOC 0xb2
 
+#define MC_CMD_0xb2_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_TCM_BUCKET_ALLOC_IN msgrequest */
 #define    MC_CMD_TCM_BUCKET_ALLOC_IN_LEN 0
 
@@ -5471,6 +5653,8 @@
  */
 #define MC_CMD_TCM_BUCKET_FREE 0xb3
 
+#define MC_CMD_0xb3_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_TCM_BUCKET_FREE_IN msgrequest */
 #define    MC_CMD_TCM_BUCKET_FREE_IN_LEN 4
 /* the bucket id */
@@ -5486,6 +5670,8 @@
  */
 #define MC_CMD_TCM_BUCKET_INIT 0xb4
 
+#define MC_CMD_0xb4_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_TCM_BUCKET_INIT_IN msgrequest */
 #define    MC_CMD_TCM_BUCKET_INIT_IN_LEN 8
 /* the bucket id */
@@ -5503,6 +5689,8 @@
  */
 #define MC_CMD_TCM_TXQ_INIT 0xb5
 
+#define MC_CMD_0xb5_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_TCM_TXQ_INIT_IN msgrequest */
 #define    MC_CMD_TCM_TXQ_INIT_IN_LEN 28
 /* the txq id */
@@ -5534,6 +5722,8 @@
  */
 #define MC_CMD_LINK_PIOBUF 0x92
 
+#define MC_CMD_0x92_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
+
 /* MC_CMD_LINK_PIOBUF_IN msgrequest */
 #define    MC_CMD_LINK_PIOBUF_IN_LEN 8
 /* Handle for allocated push I/O buffer. */
@@ -5551,6 +5741,8 @@
  */
 #define MC_CMD_UNLINK_PIOBUF 0x93
 
+#define MC_CMD_0x93_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
+
 /* MC_CMD_UNLINK_PIOBUF_IN msgrequest */
 #define    MC_CMD_UNLINK_PIOBUF_IN_LEN 4
 /* Function Local Instance (VI) number. */
@@ -5566,6 +5758,8 @@
  */
 #define MC_CMD_VSWITCH_ALLOC 0x94
 
+#define MC_CMD_0x94_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_VSWITCH_ALLOC_IN msgrequest */
 #define    MC_CMD_VSWITCH_ALLOC_IN_LEN 16
 /* The port to connect to the v-switch's upstream port. */
@@ -5595,6 +5789,8 @@
  */
 #define MC_CMD_VSWITCH_FREE 0x95
 
+#define MC_CMD_0x95_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_VSWITCH_FREE_IN msgrequest */
 #define    MC_CMD_VSWITCH_FREE_IN_LEN 4
 /* The port to which the v-switch is connected. */
@@ -5610,6 +5806,8 @@
  */
 #define MC_CMD_VPORT_ALLOC 0x96
 
+#define MC_CMD_0x96_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_VPORT_ALLOC_IN msgrequest */
 #define    MC_CMD_VPORT_ALLOC_IN_LEN 20
 /* The port to which the v-switch is connected. */
@@ -5659,6 +5857,8 @@
  */
 #define MC_CMD_VPORT_FREE 0x97
 
+#define MC_CMD_0x97_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_VPORT_FREE_IN msgrequest */
 #define    MC_CMD_VPORT_FREE_IN_LEN 4
 /* The handle of the v-port */
@@ -5674,6 +5874,8 @@
  */
 #define MC_CMD_VADAPTOR_ALLOC 0x98
 
+#define MC_CMD_0x98_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_VADAPTOR_ALLOC_IN msgrequest */
 #define    MC_CMD_VADAPTOR_ALLOC_IN_LEN 16
 /* The port to connect to the v-adaptor's port. */
@@ -5695,6 +5897,8 @@
  */
 #define MC_CMD_VADAPTOR_FREE 0x99
 
+#define MC_CMD_0x99_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_VADAPTOR_FREE_IN msgrequest */
 #define    MC_CMD_VADAPTOR_FREE_IN_LEN 4
 /* The port to which the v-adaptor is connected. */
@@ -5710,6 +5914,8 @@
  */
 #define MC_CMD_EVB_PORT_ASSIGN 0x9a
 
+#define MC_CMD_0x9a_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_EVB_PORT_ASSIGN_IN msgrequest */
 #define    MC_CMD_EVB_PORT_ASSIGN_IN_LEN 8
 /* The port to assign. */
@@ -5731,6 +5937,8 @@
  */
 #define MC_CMD_RDWR_A64_REGIONS 0x9b
 
+#define MC_CMD_0x9b_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_RDWR_A64_REGIONS_IN msgrequest */
 #define    MC_CMD_RDWR_A64_REGIONS_IN_LEN 17
 #define       MC_CMD_RDWR_A64_REGIONS_IN_REGION0_OFST 0
@@ -5759,6 +5967,8 @@
  */
 #define MC_CMD_ONLOAD_STACK_ALLOC 0x9c
 
+#define MC_CMD_0x9c_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
+
 /* MC_CMD_ONLOAD_STACK_ALLOC_IN msgrequest */
 #define    MC_CMD_ONLOAD_STACK_ALLOC_IN_LEN 4
 /* The handle of the owning upstream port */
@@ -5776,6 +5986,8 @@
  */
 #define MC_CMD_ONLOAD_STACK_FREE 0x9d
 
+#define MC_CMD_0x9d_PRIVILEGE_CTG SRIOV_CTG_ONLOAD
+
 /* MC_CMD_ONLOAD_STACK_FREE_IN msgrequest */
 #define    MC_CMD_ONLOAD_STACK_FREE_IN_LEN 4
 /* The handle of the Onload stack */
@@ -5791,6 +6003,8 @@
  */
 #define MC_CMD_RSS_CONTEXT_ALLOC 0x9e
 
+#define MC_CMD_0x9e_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_RSS_CONTEXT_ALLOC_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_ALLOC_IN_LEN 12
 /* The handle of the owning upstream port */
@@ -5823,6 +6037,8 @@
  */
 #define MC_CMD_RSS_CONTEXT_FREE 0x9f
 
+#define MC_CMD_0x9f_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_RSS_CONTEXT_FREE_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_FREE_IN_LEN 4
 /* The handle of the RSS context */
@@ -5838,6 +6054,8 @@
  */
 #define MC_CMD_RSS_CONTEXT_SET_KEY 0xa0
 
+#define MC_CMD_0xa0_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_RSS_CONTEXT_SET_KEY_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_SET_KEY_IN_LEN 44
 /* The handle of the RSS context */
@@ -5856,6 +6074,8 @@
  */
 #define MC_CMD_RSS_CONTEXT_GET_KEY 0xa1
 
+#define MC_CMD_0xa1_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_RSS_CONTEXT_GET_KEY_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_GET_KEY_IN_LEN 4
 /* The handle of the RSS context */
@@ -5874,6 +6094,8 @@
  */
 #define MC_CMD_RSS_CONTEXT_SET_TABLE 0xa2
 
+#define MC_CMD_0xa2_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_RSS_CONTEXT_SET_TABLE_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_SET_TABLE_IN_LEN 132
 /* The handle of the RSS context */
@@ -5892,6 +6114,8 @@
  */
 #define MC_CMD_RSS_CONTEXT_GET_TABLE 0xa3
 
+#define MC_CMD_0xa3_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_RSS_CONTEXT_GET_TABLE_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_GET_TABLE_IN_LEN 4
 /* The handle of the RSS context */
@@ -5910,6 +6134,8 @@
  */
 #define MC_CMD_RSS_CONTEXT_SET_FLAGS 0xe1
 
+#define MC_CMD_0xe1_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_RSS_CONTEXT_SET_FLAGS_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_LEN 8
 /* The handle of the RSS context */
@@ -5935,6 +6161,8 @@
  */
 #define MC_CMD_RSS_CONTEXT_GET_FLAGS 0xe2
 
+#define MC_CMD_0xe2_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_RSS_CONTEXT_GET_FLAGS_IN msgrequest */
 #define    MC_CMD_RSS_CONTEXT_GET_FLAGS_IN_LEN 4
 /* The handle of the RSS context */
@@ -5960,6 +6188,8 @@
  */
 #define MC_CMD_DOT1P_MAPPING_ALLOC 0xa4
 
+#define MC_CMD_0xa4_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_DOT1P_MAPPING_ALLOC_IN msgrequest */
 #define    MC_CMD_DOT1P_MAPPING_ALLOC_IN_LEN 8
 /* The handle of the owning upstream port */
@@ -5982,6 +6212,8 @@
  */
 #define MC_CMD_DOT1P_MAPPING_FREE 0xa5
 
+#define MC_CMD_0xa5_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_DOT1P_MAPPING_FREE_IN msgrequest */
 #define    MC_CMD_DOT1P_MAPPING_FREE_IN_LEN 4
 /* The handle of the .1p mapping */
@@ -5997,6 +6229,8 @@
  */
 #define MC_CMD_DOT1P_MAPPING_SET_TABLE 0xa6
 
+#define MC_CMD_0xa6_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_DOT1P_MAPPING_SET_TABLE_IN msgrequest */
 #define    MC_CMD_DOT1P_MAPPING_SET_TABLE_IN_LEN 36
 /* The handle of the .1p mapping */
@@ -6017,6 +6251,8 @@
  */
 #define MC_CMD_DOT1P_MAPPING_GET_TABLE 0xa7
 
+#define MC_CMD_0xa7_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_DOT1P_MAPPING_GET_TABLE_IN msgrequest */
 #define    MC_CMD_DOT1P_MAPPING_GET_TABLE_IN_LEN 4
 /* The handle of the .1p mapping */
@@ -6037,6 +6273,8 @@
  */
 #define MC_CMD_GET_VECTOR_CFG 0xbf
 
+#define MC_CMD_0xbf_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_VECTOR_CFG_IN msgrequest */
 #define    MC_CMD_GET_VECTOR_CFG_IN_LEN 0
 
@@ -6056,6 +6294,8 @@
  */
 #define MC_CMD_SET_VECTOR_CFG 0xc0
 
+#define MC_CMD_0xc0_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_SET_VECTOR_CFG_IN msgrequest */
 #define    MC_CMD_SET_VECTOR_CFG_IN_LEN 12
 /* Base absolute interrupt vector number, or MC_CMD_RESOURCE_INSTANCE_ANY to
@@ -6446,6 +6686,8 @@
  */
 #define MC_CMD_VPORT_ADD_MAC_ADDRESS 0xa8
 
+#define MC_CMD_0xa8_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_VPORT_ADD_MAC_ADDRESS_IN msgrequest */
 #define    MC_CMD_VPORT_ADD_MAC_ADDRESS_IN_LEN 10
 /* The handle of the v-port */
@@ -6464,6 +6706,8 @@
  */
 #define MC_CMD_VPORT_DEL_MAC_ADDRESS 0xa9
 
+#define MC_CMD_0xa9_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_VPORT_DEL_MAC_ADDRESS_IN msgrequest */
 #define    MC_CMD_VPORT_DEL_MAC_ADDRESS_IN_LEN 10
 /* The handle of the v-port */
@@ -6482,6 +6726,8 @@
  */
 #define MC_CMD_VPORT_GET_MAC_ADDRESSES 0xaa
 
+#define MC_CMD_0xaa_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_VPORT_GET_MAC_ADDRESSES_IN msgrequest */
 #define    MC_CMD_VPORT_GET_MAC_ADDRESSES_IN_LEN 4
 /* The handle of the v-port */
@@ -6509,6 +6755,8 @@
  */
 #define MC_CMD_DUMP_BUFTBL_ENTRIES 0xab
 
+#define MC_CMD_0xab_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_DUMP_BUFTBL_ENTRIES_IN msgrequest */
 #define    MC_CMD_DUMP_BUFTBL_ENTRIES_IN_LEN 8
 /* Index of the first buffer table entry. */
@@ -6533,6 +6781,8 @@
  */
 #define MC_CMD_SET_RXDP_CONFIG 0xc1
 
+#define MC_CMD_0xc1_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SET_RXDP_CONFIG_IN msgrequest */
 #define    MC_CMD_SET_RXDP_CONFIG_IN_LEN 4
 #define       MC_CMD_SET_RXDP_CONFIG_IN_DATA_OFST 0
@@ -6549,6 +6799,8 @@
  */
 #define MC_CMD_GET_RXDP_CONFIG 0xc2
 
+#define MC_CMD_0xc2_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_GET_RXDP_CONFIG_IN msgrequest */
 #define    MC_CMD_GET_RXDP_CONFIG_IN_LEN 0
 
@@ -6913,6 +7165,8 @@
  */
 #define MC_CMD_GET_CLOCK 0xac
 
+#define MC_CMD_0xac_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_CLOCK_IN msgrequest */
 #define    MC_CMD_GET_CLOCK_IN_LEN 0
 
@@ -6930,6 +7184,8 @@
  */
 #define MC_CMD_SET_CLOCK 0xad
 
+#define MC_CMD_0xad_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SET_CLOCK_IN msgrequest */
 #define    MC_CMD_SET_CLOCK_IN_LEN 12
 /* Requested system frequency in MHz; 0 leaves unchanged. */
@@ -6955,6 +7211,8 @@
  */
 #define MC_CMD_DPCPU_RPC 0xae
 
+#define MC_CMD_0xae_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_DPCPU_RPC_IN msgrequest */
 #define    MC_CMD_DPCPU_RPC_IN_LEN 36
 #define       MC_CMD_DPCPU_RPC_IN_CPU_OFST 0
@@ -7039,6 +7297,8 @@
  */
 #define MC_CMD_TRIGGER_INTERRUPT 0xe3
 
+#define MC_CMD_0xe3_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_TRIGGER_INTERRUPT_IN msgrequest */
 #define    MC_CMD_TRIGGER_INTERRUPT_IN_LEN 4
 /* Interrupt level relative to base for function. */
@@ -7054,6 +7314,8 @@
  */
 #define MC_CMD_CAP_BLK_READ 0xe7
 
+#define MC_CMD_0xe7_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_CAP_BLK_READ_IN msgrequest */
 #define    MC_CMD_CAP_BLK_READ_IN_LEN 12
 #define       MC_CMD_CAP_BLK_READ_IN_CAP_REG_OFST 0
@@ -7078,6 +7340,8 @@
  */
 #define MC_CMD_DUMP_DO 0xe8
 
+#define MC_CMD_0xe8_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_DUMP_DO_IN msgrequest */
 #define    MC_CMD_DUMP_DO_IN_LEN 52
 #define       MC_CMD_DUMP_DO_IN_PADDING_OFST 0
@@ -7131,6 +7395,8 @@
  */
 #define MC_CMD_DUMP_CONFIGURE_UNSOLICITED 0xe9
 
+#define MC_CMD_0xe9_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_DUMP_CONFIGURE_UNSOLICITED_IN msgrequest */
 #define    MC_CMD_DUMP_CONFIGURE_UNSOLICITED_IN_LEN 52
 #define       MC_CMD_DUMP_CONFIGURE_UNSOLICITED_IN_ENABLE_OFST 0
@@ -7174,6 +7440,8 @@
  */
 #define MC_CMD_SET_PSU 0xea
 
+#define MC_CMD_0xea_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SET_PSU_IN msgrequest */
 #define    MC_CMD_SET_PSU_IN_LEN 12
 #define       MC_CMD_SET_PSU_IN_PARAM_OFST 0
@@ -7194,6 +7462,8 @@
  */
 #define MC_CMD_GET_FUNCTION_INFO 0xec
 
+#define MC_CMD_0xec_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_FUNCTION_INFO_IN msgrequest */
 #define    MC_CMD_GET_FUNCTION_INFO_IN_LEN 0
 
@@ -7211,6 +7481,8 @@
  */
 #define MC_CMD_ENABLE_OFFLINE_BIST 0xed
 
+#define MC_CMD_0xed_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_ENABLE_OFFLINE_BIST_IN msgrequest */
 #define    MC_CMD_ENABLE_OFFLINE_BIST_IN_LEN 0
 
@@ -7226,6 +7498,8 @@
  */
 #define MC_CMD_UART_SEND_DATA 0xee
 
+#define MC_CMD_0xee_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_UART_SEND_DATA_OUT msgrequest */
 #define    MC_CMD_UART_SEND_DATA_OUT_LENMIN 16
 #define    MC_CMD_UART_SEND_DATA_OUT_LENMAX 252
@@ -7254,6 +7528,8 @@
  */
 #define MC_CMD_UART_RECV_DATA 0xef
 
+#define MC_CMD_0xef_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_UART_RECV_DATA_OUT msgrequest */
 #define    MC_CMD_UART_RECV_DATA_OUT_LEN 16
 /* CRC32 over OFFSET, LENGTH, RESERVED */
@@ -7289,6 +7565,8 @@
  */
 #define MC_CMD_READ_FUSES 0xf0
 
+#define MC_CMD_0xf0_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_READ_FUSES_IN msgrequest */
 #define    MC_CMD_READ_FUSES_IN_LEN 8
 /* Offset in OTP to read */
@@ -7315,6 +7593,8 @@
  */
 #define MC_CMD_KR_TUNE 0xf1
 
+#define MC_CMD_0xf1_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_KR_TUNE_IN msgrequest */
 #define    MC_CMD_KR_TUNE_IN_LENMIN 4
 #define    MC_CMD_KR_TUNE_IN_LENMAX 252
@@ -7573,6 +7853,8 @@
  */
 #define MC_CMD_PCIE_TUNE 0xf2
 
+#define MC_CMD_0xf2_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_PCIE_TUNE_IN msgrequest */
 #define    MC_CMD_PCIE_TUNE_IN_LENMIN 4
 #define    MC_CMD_PCIE_TUNE_IN_LENMAX 252
@@ -7734,6 +8016,8 @@
  */
 #define MC_CMD_LICENSING 0xf3
 
+#define MC_CMD_0xf3_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_LICENSING_IN msgrequest */
 #define    MC_CMD_LICENSING_IN_LEN 4
 /* identifies the type of operation requested */
@@ -7779,6 +8063,8 @@
  */
 #define MC_CMD_MC2MC_PROXY 0xf4
 
+#define MC_CMD_0xf4_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_MC2MC_PROXY_IN msgrequest */
 #define    MC_CMD_MC2MC_PROXY_IN_LEN 0
 
@@ -7794,6 +8080,8 @@
  */
 #define MC_CMD_GET_LICENSED_APP_STATE 0xf5
 
+#define MC_CMD_0xf5_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_GET_LICENSED_APP_STATE_IN msgrequest */
 #define    MC_CMD_GET_LICENSED_APP_STATE_IN_LEN 4
 /* application ID to query (LICENSED_APP_ID_xxx) */
@@ -7815,6 +8103,8 @@
  */
 #define MC_CMD_LICENSED_APP_OP 0xf6
 
+#define MC_CMD_0xf6_PRIVILEGE_CTG SRIOV_CTG_GENERAL
+
 /* MC_CMD_LICENSED_APP_OP_IN msgrequest */
 #define    MC_CMD_LICENSED_APP_OP_IN_LENMIN 8
 #define    MC_CMD_LICENSED_APP_OP_IN_LENMAX 252
@@ -7870,6 +8160,8 @@
  */
 #define MC_CMD_SET_PORT_SNIFF_CONFIG 0xf7
 
+#define MC_CMD_0xf7_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_SET_PORT_SNIFF_CONFIG_IN msgrequest */
 #define    MC_CMD_SET_PORT_SNIFF_CONFIG_IN_LEN 16
 /* configuration flags */
@@ -7904,6 +8196,8 @@
  */
 #define MC_CMD_GET_PORT_SNIFF_CONFIG 0xf8
 
+#define MC_CMD_0xf8_PRIVILEGE_CTG SRIOV_CTG_ADMIN
+
 /* MC_CMD_GET_PORT_SNIFF_CONFIG_IN msgrequest */
 #define    MC_CMD_GET_PORT_SNIFF_CONFIG_IN_LEN 0
 
