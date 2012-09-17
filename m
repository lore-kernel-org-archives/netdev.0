From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 01/15] rtlwifi: rtl8723ae: Add new driver - Part 1
Date: Mon, 17 Sep 2012 16:18:40 -0500
Message-ID: <1347916754-9219-1-git-send-email-Larry.Finger@lwfinger.net>
References: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, <chaoming_li@realsil.com.cn>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:61147 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943Ab2IQVTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 17:19:23 -0400
In-Reply-To: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is part 1 of the addition of files for a new driver to handle
the Realtek RTL8723AE wireless device.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: <chaoming_li@realsil.com.cn>
---
 drivers/net/wireless/rtlwifi/rtl8723ae/btc.h |   41 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/def.h |  291 ++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c  |  952 ++++++++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h  |  174 +++++
 4 files changed, 1458 insertions(+)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/btc.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h

Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/btc.h
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/btc.h
@@ -0,0 +1,40 @@
+/******************************************************************************
+ **
+ ** Copyright(c) 2009-2012  Realtek Corporation.
+ **
+ ** This program is free software; you can redistribute it and/or modify it
+ ** under the terms of version 2 of the GNU General Public License as
+ ** published by the Free Software Foundation.
+ **
+ ** This program is distributed in the hope that it will be useful, but WITHOUT
+ ** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ ** FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ ** more details.
+ **
+ ** You should have received a copy of the GNU General Public License along with
+ ** this program; if not, write to the Free Software Foundation, Inc.,
+ ** 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ **
+ ** The full GNU General Public License is included in this distribution in the
+ ** file called LICENSE.
+ **
+ ** Contact Information:
+ ** wlanfae <wlanfae@realtek.com>
+ ** Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ ** Hsinchu 300, Taiwan.
+ ** Larry Finger <Larry.Finger@lwfinger.net>
+ **
+ ******************************************************************************/
+
+#ifndef __RTL8723E_BTC_H__
+#define __RTL8723E_BTC_H__
+
+#include "../wifi.h"
+#include "hal_bt_coexist.h"
+
+struct bt_coexist_c2h_info {
+	u8 no_parse_c2h;
+	u8 has_c2h;
+};
+
+#endif
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/def.h
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/def.h
@@ -0,0 +1,290 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2012  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef __RTL8723E_DEF_H__
+#define __RTL8723E_DEF_H__
+
+#define HAL_RETRY_LIMIT_INFRA				48
+#define HAL_RETRY_LIMIT_AP_ADHOC			7
+
+#define RESET_DELAY_8185				20
+
+#define RT_IBSS_INT_MASKS	(IMR_BCNINT | IMR_TBDOK | IMR_TBDER)
+#define RT_AC_INT_MASKS		(IMR_VIDOK | IMR_VODOK | IMR_BEDOK|IMR_BKDOK)
+
+#define NUM_OF_FIRMWARE_QUEUE				10
+#define NUM_OF_PAGES_IN_FW				0x100
+#define NUM_OF_PAGE_IN_FW_QUEUE_BK			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_BE			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_VI			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_VO			0x07
+#define NUM_OF_PAGE_IN_FW_QUEUE_HCCA			0x0
+#define NUM_OF_PAGE_IN_FW_QUEUE_CMD			0x0
+#define NUM_OF_PAGE_IN_FW_QUEUE_MGNT			0x02
+#define NUM_OF_PAGE_IN_FW_QUEUE_HIGH			0x02
+#define NUM_OF_PAGE_IN_FW_QUEUE_BCN			0x2
+#define NUM_OF_PAGE_IN_FW_QUEUE_PUB			0xA1
+
+#define NUM_OF_PAGE_IN_FW_QUEUE_BK_DTM			0x026
+#define NUM_OF_PAGE_IN_FW_QUEUE_BE_DTM			0x048
+#define NUM_OF_PAGE_IN_FW_QUEUE_VI_DTM			0x048
+#define NUM_OF_PAGE_IN_FW_QUEUE_VO_DTM			0x026
+#define NUM_OF_PAGE_IN_FW_QUEUE_PUB_DTM			0x00
+
+#define MAX_LINES_HWCONFIG_TXT				1000
+#define MAX_BYTES_LINE_HWCONFIG_TXT			256
+
+#define SW_THREE_WIRE					0
+#define HW_THREE_WIRE					2
+
+#define BT_DEMO_BOARD					0
+#define BT_QA_BOARD					1
+#define BT_FPGA						2
+
+#define HAL_PRIME_CHNL_OFFSET_DONT_CARE			0
+#define HAL_PRIME_CHNL_OFFSET_LOWER			1
+#define HAL_PRIME_CHNL_OFFSET_UPPER			2
+
+#define MAX_H2C_QUEUE_NUM				10
+
+#define RX_MPDU_QUEUE					0
+#define RX_CMD_QUEUE					1
+#define RX_MAX_QUEUE					2
+#define AC2QUEUEID(_AC)					(_AC)
+
+#define	C2H_RX_CMD_HDR_LEN				8
+#define	GET_C2H_CMD_CMD_LEN(__prxhdr)			\
+	LE_BITS_TO_4BYTE((__prxhdr), 0, 16)
+#define	GET_C2H_CMD_ELEMENT_ID(__prxhdr)		\
+	LE_BITS_TO_4BYTE((__prxhdr), 16, 8)
+#define	GET_C2H_CMD_CMD_SEQ(__prxhdr)			\
+	LE_BITS_TO_4BYTE((__prxhdr), 24, 7)
+#define	GET_C2H_CMD_CONTINUE(__prxhdr)			\
+	LE_BITS_TO_4BYTE((__prxhdr), 31, 1)
+#define	GET_C2H_CMD_CONTENT(__prxhdr)			\
+	((u8 *)(__prxhdr) + C2H_RX_CMD_HDR_LEN)
+
+#define	GET_C2H_CMD_FEEDBACK_ELEMENT_ID(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE((__pcmdfbhdr), 0, 8)
+#define	GET_C2H_CMD_FEEDBACK_CCX_LEN(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE((__pcmdfbhdr), 8, 8)
+#define	GET_C2H_CMD_FEEDBACK_CCX_CMD_CNT(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE((__pcmdfbhdr), 16, 16)
+#define	GET_C2H_CMD_FEEDBACK_CCX_MAC_ID(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 0, 5)
+#define	GET_C2H_CMD_FEEDBACK_CCX_VALID(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 7, 1)
+#define	GET_C2H_CMD_FEEDBACK_CCX_RETRY_CNT(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 8, 5)
+#define	GET_C2H_CMD_FEEDBACK_CCX_TOK(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 15, 1)
+#define	GET_C2H_CMD_FEEDBACK_CCX_QSEL(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 16, 4)
+#define	GET_C2H_CMD_FEEDBACK_CCX_SEQ(__pcmdfbhdr)	\
+	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 20, 12)
+
+#define CHIP_BONDING_IDENTIFIER(_value)	(((_value)>>22)&0x3)
+#define	CHIP_BONDING_92C_1T2R		0x1
+
+#define CHIP_8723			BIT(0)
+#define NORMAL_CHIP			BIT(3)
+#define RF_TYPE_1T1R			(~(BIT(4)|BIT(5)|BIT(6)))
+#define RF_TYPE_1T2R			BIT(4)
+#define RF_TYPE_2T2R			BIT(5)
+#define CHIP_VENDOR_UMC			BIT(7)
+#define B_CUT_VERSION			BIT(12)
+#define C_CUT_VERSION			BIT(13)
+#define D_CUT_VERSION			((BIT(12)|BIT(13)))
+#define E_CUT_VERSION			BIT(14)
+#define	RF_RL_ID			(BIT(31)|BIT(30)|BIT(29)|BIT(28))
+
+enum version_8723e {
+	VERSION_TEST_UMC_CHIP_8723 = 0x0081,
+	VERSION_NORMAL_UMC_CHIP_8723_1T1R_A_CUT = 0x0089,
+	VERSION_NORMAL_UMC_CHIP_8723_1T1R_B_CUT = 0x1089,
+};
+
+/* MASK */
+#define IC_TYPE_MASK			(BIT(0)|BIT(1)|BIT(2))
+#define CHIP_TYPE_MASK			BIT(3)
+#define RF_TYPE_MASK			(BIT(4)|BIT(5)|BIT(6))
+#define MANUFACTUER_MASK		BIT(7)
+#define ROM_VERSION_MASK		(BIT(11)|BIT(10)|BIT(9)|BIT(8))
+#define CUT_VERSION_MASK		(BIT(15)|BIT(14)|BIT(13)|BIT(12))
+
+/* Get element */
+#define GET_CVID_IC_TYPE(version)	((version) & IC_TYPE_MASK)
+#define GET_CVID_CHIP_TYPE(version)	((version) & CHIP_TYPE_MASK)
+#define GET_CVID_RF_TYPE(version)	((version) & RF_TYPE_MASK)
+#define GET_CVID_MANUFACTUER(version)	((version) & MANUFACTUER_MASK)
+#define GET_CVID_ROM_VERSION(version)	((version) & ROM_VERSION_MASK)
+#define GET_CVID_CUT_VERSION(version)	((version) & CUT_VERSION_MASK)
+
+#define IS_81XXC(version)		((GET_CVID_IC_TYPE(version) == 0) ?\
+					true : false)
+#define IS_8723_SERIES(version)						\
+		((GET_CVID_IC_TYPE(version) == CHIP_8723) ? true : false)
+#define IS_1T1R(version)						\
+		((GET_CVID_RF_TYPE(version)) ? false : true)
+#define IS_1T2R(version)						\
+		((GET_CVID_RF_TYPE(version) == RF_TYPE_1T2R) ?		\
+		true : false)
+#define IS_2T2R(version)						\
+		((GET_CVID_RF_TYPE(version) == RF_TYPE_2T2R) ?		\
+		true : false)
+#define IS_CHIP_VENDOR_UMC(version)					\
+		((GET_CVID_MANUFACTUER(version)) ? true : false)
+
+#define IS_VENDOR_UMC_A_CUT(version)	((IS_CHIP_VENDOR_UMC(version)) ? \
+		((GET_CVID_CUT_VERSION(version)) ? false : true) : false)
+#define IS_VENDOR_8723_A_CUT(version)	((IS_8723_SERIES(version)) ?	\
+		((GET_CVID_CUT_VERSION(version)) ? false : true) : false)
+#define IS_VENDOR_8723A_B_CUT(version)	((IS_8723_SERIES(version))\
+		? ((GET_CVID_CUT_VERSION(version) == B_CUT_VERSION) ? \
+		true : false) : false)
+#define IS_81xxC_VENDOR_UMC_B_CUT(version)	((IS_CHIP_VENDOR_UMC(version)) \
+		? ((GET_CVID_CUT_VERSION(version) == B_CUT_VERSION) ? \
+		true : false) : false)
+
+enum rf_optype {
+	RF_OP_BY_SW_3WIRE = 0,
+	RF_OP_BY_FW,
+	RF_OP_MAX
+};
+
+enum rf_power_state {
+	RF_ON,
+	RF_OFF,
+	RF_SLEEP,
+	RF_SHUT_DOWN,
+};
+
+enum power_save_mode {
+	POWER_SAVE_MODE_ACTIVE,
+	POWER_SAVE_MODE_SAVE,
+};
+
+enum power_polocy_config {
+	POWERCFG_MAX_POWER_SAVINGS,
+	POWERCFG_GLOBAL_POWER_SAVINGS,
+	POWERCFG_LOCAL_POWER_SAVINGS,
+	POWERCFG_LENOVO,
+};
+
+enum interface_select_pci {
+	INTF_SEL1_MINICARD = 0,
+	INTF_SEL0_PCIE = 1,
+	INTF_SEL2_RSV = 2,
+	INTF_SEL3_RSV = 3,
+};
+
+enum hal_fw_c2h_cmd_id {
+	HAL_FW_C2H_CMD_Read_MACREG = 0,
+	HAL_FW_C2H_CMD_Read_BBREG = 1,
+	HAL_FW_C2H_CMD_Read_RFREG = 2,
+	HAL_FW_C2H_CMD_Read_EEPROM = 3,
+	HAL_FW_C2H_CMD_Read_EFUSE = 4,
+	HAL_FW_C2H_CMD_Read_CAM = 5,
+	HAL_FW_C2H_CMD_Get_BasicRate = 6,
+	HAL_FW_C2H_CMD_Get_DataRate = 7,
+	HAL_FW_C2H_CMD_Survey = 8,
+	HAL_FW_C2H_CMD_SurveyDone = 9,
+	HAL_FW_C2H_CMD_JoinBss = 10,
+	HAL_FW_C2H_CMD_AddSTA = 11,
+	HAL_FW_C2H_CMD_DelSTA = 12,
+	HAL_FW_C2H_CMD_AtimDone = 13,
+	HAL_FW_C2H_CMD_TX_Report = 14,
+	HAL_FW_C2H_CMD_CCX_Report = 15,
+	HAL_FW_C2H_CMD_DTM_Report = 16,
+	HAL_FW_C2H_CMD_TX_Rate_Statistics = 17,
+	HAL_FW_C2H_CMD_C2HLBK = 18,
+	HAL_FW_C2H_CMD_C2HDBG = 19,
+	HAL_FW_C2H_CMD_C2HFEEDBACK = 20,
+	HAL_FW_C2H_CMD_MAX
+};
+
+enum rtl_desc_qsel {
+	QSLT_BK = 0x2,
+	QSLT_BE = 0x0,
+	QSLT_VI = 0x5,
+	QSLT_VO = 0x7,
+	QSLT_BEACON = 0x10,
+	QSLT_HIGH = 0x11,
+	QSLT_MGNT = 0x12,
+	QSLT_CMD = 0x13,
+};
+
+enum rtl_desc8723e_rate {
+	DESC92C_RATE1M = 0x00,
+	DESC92C_RATE2M = 0x01,
+	DESC92C_RATE5_5M = 0x02,
+	DESC92C_RATE11M = 0x03,
+
+	DESC92C_RATE6M = 0x04,
+	DESC92C_RATE9M = 0x05,
+	DESC92C_RATE12M = 0x06,
+	DESC92C_RATE18M = 0x07,
+	DESC92C_RATE24M = 0x08,
+	DESC92C_RATE36M = 0x09,
+	DESC92C_RATE48M = 0x0a,
+	DESC92C_RATE54M = 0x0b,
+
+	DESC92C_RATEMCS0 = 0x0c,
+	DESC92C_RATEMCS1 = 0x0d,
+	DESC92C_RATEMCS2 = 0x0e,
+	DESC92C_RATEMCS3 = 0x0f,
+	DESC92C_RATEMCS4 = 0x10,
+	DESC92C_RATEMCS5 = 0x11,
+	DESC92C_RATEMCS6 = 0x12,
+	DESC92C_RATEMCS7 = 0x13,
+	DESC92C_RATEMCS8 = 0x14,
+	DESC92C_RATEMCS9 = 0x15,
+	DESC92C_RATEMCS10 = 0x16,
+	DESC92C_RATEMCS11 = 0x17,
+	DESC92C_RATEMCS12 = 0x18,
+	DESC92C_RATEMCS13 = 0x19,
+	DESC92C_RATEMCS14 = 0x1a,
+	DESC92C_RATEMCS15 = 0x1b,
+	DESC92C_RATEMCS15_SG = 0x1c,
+	DESC92C_RATEMCS32 = 0x20,
+};
+
+struct phy_sts_cck_8723e_t {
+	u8 adc_pwdb_X[4];
+	u8 sq_rpt;
+	u8 cck_agc_rpt;
+};
+
+struct h2c_cmd_8723e {
+	u8 element_id;
+	u32 cmd_len;
+	u8 *p_cmdbuffer;
+};
+
+#endif
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
@@ -0,0 +1,952 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2012  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#include "../wifi.h"
+#include "../base.h"
+#include "../pci.h"
+#include "reg.h"
+#include "def.h"
+#include "phy.h"
+#include "dm.h"
+#include "fw.h"
+#include "hal_btc.h"
+
+static const u32 ofdmswing_table[OFDM_TABLE_SIZE] = {
+	0x7f8001fe,
+	0x788001e2,
+	0x71c001c7,
+	0x6b8001ae,
+	0x65400195,
+	0x5fc0017f,
+	0x5a400169,
+	0x55400155,
+	0x50800142,
+	0x4c000130,
+	0x47c0011f,
+	0x43c0010f,
+	0x40000100,
+	0x3c8000f2,
+	0x390000e4,
+	0x35c000d7,
+	0x32c000cb,
+	0x300000c0,
+	0x2d4000b5,
+	0x2ac000ab,
+	0x288000a2,
+	0x26000098,
+	0x24000090,
+	0x22000088,
+	0x20000080,
+	0x1e400079,
+	0x1c800072,
+	0x1b00006c,
+	0x19800066,
+	0x18000060,
+	0x16c0005b,
+	0x15800056,
+	0x14400051,
+	0x1300004c,
+	0x12000048,
+	0x11000044,
+	0x10000040,
+};
+
+static const u8 cckswing_table_ch1ch13[CCK_TABLE_SIZE][8] = {
+	{0x36, 0x35, 0x2e, 0x25, 0x1c, 0x12, 0x09, 0x04},
+	{0x33, 0x32, 0x2b, 0x23, 0x1a, 0x11, 0x08, 0x04},
+	{0x30, 0x2f, 0x29, 0x21, 0x19, 0x10, 0x08, 0x03},
+	{0x2d, 0x2d, 0x27, 0x1f, 0x18, 0x0f, 0x08, 0x03},
+	{0x2b, 0x2a, 0x25, 0x1e, 0x16, 0x0e, 0x07, 0x03},
+	{0x28, 0x28, 0x22, 0x1c, 0x15, 0x0d, 0x07, 0x03},
+	{0x26, 0x25, 0x21, 0x1b, 0x14, 0x0d, 0x06, 0x03},
+	{0x24, 0x23, 0x1f, 0x19, 0x13, 0x0c, 0x06, 0x03},
+	{0x22, 0x21, 0x1d, 0x18, 0x11, 0x0b, 0x06, 0x02},
+	{0x20, 0x20, 0x1b, 0x16, 0x11, 0x08, 0x05, 0x02},
+	{0x1f, 0x1e, 0x1a, 0x15, 0x10, 0x0a, 0x05, 0x02},
+	{0x1d, 0x1c, 0x18, 0x14, 0x0f, 0x0a, 0x05, 0x02},
+	{0x1b, 0x1a, 0x17, 0x13, 0x0e, 0x09, 0x04, 0x02},
+	{0x1a, 0x19, 0x16, 0x12, 0x0d, 0x09, 0x04, 0x02},
+	{0x18, 0x17, 0x15, 0x11, 0x0c, 0x08, 0x04, 0x02},
+	{0x17, 0x16, 0x13, 0x10, 0x0c, 0x08, 0x04, 0x02},
+	{0x16, 0x15, 0x12, 0x0f, 0x0b, 0x07, 0x04, 0x01},
+	{0x14, 0x14, 0x11, 0x0e, 0x0b, 0x07, 0x03, 0x02},
+	{0x13, 0x13, 0x10, 0x0d, 0x0a, 0x06, 0x03, 0x01},
+	{0x12, 0x12, 0x0f, 0x0c, 0x09, 0x06, 0x03, 0x01},
+	{0x11, 0x11, 0x0f, 0x0c, 0x09, 0x06, 0x03, 0x01},
+	{0x10, 0x10, 0x0e, 0x0b, 0x08, 0x05, 0x03, 0x01},
+	{0x0f, 0x0f, 0x0d, 0x0b, 0x08, 0x05, 0x03, 0x01},
+	{0x0e, 0x0e, 0x0c, 0x0a, 0x08, 0x05, 0x02, 0x01},
+	{0x0d, 0x0d, 0x0c, 0x0a, 0x07, 0x05, 0x02, 0x01},
+	{0x0d, 0x0c, 0x0b, 0x09, 0x07, 0x04, 0x02, 0x01},
+	{0x0c, 0x0c, 0x0a, 0x09, 0x06, 0x04, 0x02, 0x01},
+	{0x0b, 0x0b, 0x0a, 0x08, 0x06, 0x04, 0x02, 0x01},
+	{0x0b, 0x0a, 0x09, 0x08, 0x06, 0x04, 0x02, 0x01},
+	{0x0a, 0x0a, 0x09, 0x07, 0x05, 0x03, 0x02, 0x01},
+	{0x0a, 0x09, 0x08, 0x07, 0x05, 0x03, 0x02, 0x01},
+	{0x09, 0x09, 0x08, 0x06, 0x05, 0x03, 0x01, 0x01},
+	{0x09, 0x08, 0x07, 0x06, 0x04, 0x03, 0x01, 0x01}
+};
+
+static const u8 cckswing_table_ch14[CCK_TABLE_SIZE][8] = {
+	{0x36, 0x35, 0x2e, 0x1b, 0x00, 0x00, 0x00, 0x00},
+	{0x33, 0x32, 0x2b, 0x19, 0x00, 0x00, 0x00, 0x00},
+	{0x30, 0x2f, 0x29, 0x18, 0x00, 0x00, 0x00, 0x00},
+	{0x2d, 0x2d, 0x17, 0x17, 0x00, 0x00, 0x00, 0x00},
+	{0x2b, 0x2a, 0x25, 0x15, 0x00, 0x00, 0x00, 0x00},
+	{0x28, 0x28, 0x24, 0x14, 0x00, 0x00, 0x00, 0x00},
+	{0x26, 0x25, 0x21, 0x13, 0x00, 0x00, 0x00, 0x00},
+	{0x24, 0x23, 0x1f, 0x12, 0x00, 0x00, 0x00, 0x00},
+	{0x22, 0x21, 0x1d, 0x11, 0x00, 0x00, 0x00, 0x00},
+	{0x20, 0x20, 0x1b, 0x10, 0x00, 0x00, 0x00, 0x00},
+	{0x1f, 0x1e, 0x1a, 0x0f, 0x00, 0x00, 0x00, 0x00},
+	{0x1d, 0x1c, 0x18, 0x0e, 0x00, 0x00, 0x00, 0x00},
+	{0x1b, 0x1a, 0x17, 0x0e, 0x00, 0x00, 0x00, 0x00},
+	{0x1a, 0x19, 0x16, 0x0d, 0x00, 0x00, 0x00, 0x00},
+	{0x18, 0x17, 0x15, 0x0c, 0x00, 0x00, 0x00, 0x00},
+	{0x17, 0x16, 0x13, 0x0b, 0x00, 0x00, 0x00, 0x00},
+	{0x16, 0x15, 0x12, 0x0b, 0x00, 0x00, 0x00, 0x00},
+	{0x14, 0x14, 0x11, 0x0a, 0x00, 0x00, 0x00, 0x00},
+	{0x13, 0x13, 0x10, 0x0a, 0x00, 0x00, 0x00, 0x00},
+	{0x12, 0x12, 0x0f, 0x09, 0x00, 0x00, 0x00, 0x00},
+	{0x11, 0x11, 0x0f, 0x09, 0x00, 0x00, 0x00, 0x00},
+	{0x10, 0x10, 0x0e, 0x08, 0x00, 0x00, 0x00, 0x00},
+	{0x0f, 0x0f, 0x0d, 0x08, 0x00, 0x00, 0x00, 0x00},
+	{0x0e, 0x0e, 0x0c, 0x07, 0x00, 0x00, 0x00, 0x00},
+	{0x0d, 0x0d, 0x0c, 0x07, 0x00, 0x00, 0x00, 0x00},
+	{0x0d, 0x0c, 0x0b, 0x06, 0x00, 0x00, 0x00, 0x00},
+	{0x0c, 0x0c, 0x0a, 0x06, 0x00, 0x00, 0x00, 0x00},
+	{0x0b, 0x0b, 0x0a, 0x06, 0x00, 0x00, 0x00, 0x00},
+	{0x0b, 0x0a, 0x09, 0x05, 0x00, 0x00, 0x00, 0x00},
+	{0x0a, 0x0a, 0x09, 0x05, 0x00, 0x00, 0x00, 0x00},
+	{0x0a, 0x09, 0x08, 0x05, 0x00, 0x00, 0x00, 0x00},
+	{0x09, 0x09, 0x08, 0x05, 0x00, 0x00, 0x00, 0x00},
+	{0x09, 0x08, 0x07, 0x04, 0x00, 0x00, 0x00, 0x00}
+};
+
+static void rtl8723ae_dm_diginit(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+
+	dm_digtable->dig_enable_flag = true;
+	dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
+	dm_digtable->cur_igvalue = 0x20;
+	dm_digtable->pre_igvalue = 0x0;
+	dm_digtable->cursta_connectstate = DIG_STA_DISCONNECT;
+	dm_digtable->presta_connectstate = DIG_STA_DISCONNECT;
+	dm_digtable->curmultista_connectstate = DIG_MULTISTA_DISCONNECT;
+	dm_digtable->rssi_lowthresh = DM_DIG_THRESH_LOW;
+	dm_digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
+	dm_digtable->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
+	dm_digtable->fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
+	dm_digtable->rx_gain_range_max = DM_DIG_MAX;
+	dm_digtable->rx_gain_range_min = DM_DIG_MIN;
+	dm_digtable->backoff_val = DM_DIG_BACKOFF_DEFAULT;
+	dm_digtable->backoff_val_range_max = DM_DIG_BACKOFF_MAX;
+	dm_digtable->backoff_val_range_min = DM_DIG_BACKOFF_MIN;
+	dm_digtable->pre_cck_pd_state = CCK_PD_STAGE_MAX;
+	dm_digtable->cur_cck_pd_state = CCK_PD_STAGE_MAX;
+}
+
+static u8 rtl8723ae_dm_initial_gain_min_pwdb(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+	long rssi_val_min = 0;
+
+	if ((dm_digtable->curmultista_connectstate == DIG_MULTISTA_CONNECT) &&
+	    (dm_digtable->cursta_connectstate == DIG_STA_CONNECT)) {
+		if (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb != 0)
+			rssi_val_min =
+			    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb >
+			     rtlpriv->dm.undecorated_smoothed_pwdb) ?
+			    rtlpriv->dm.undecorated_smoothed_pwdb :
+			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+		else
+			rssi_val_min = rtlpriv->dm.undecorated_smoothed_pwdb;
+	} else if (dm_digtable->cursta_connectstate == DIG_STA_CONNECT ||
+		   dm_digtable->cursta_connectstate == DIG_STA_BEFORE_CONNECT) {
+		rssi_val_min = rtlpriv->dm.undecorated_smoothed_pwdb;
+	} else if (dm_digtable->curmultista_connectstate ==
+		DIG_MULTISTA_CONNECT) {
+		rssi_val_min = rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+	}
+
+	return (u8) rssi_val_min;
+}
+
+static void rtl8723ae_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
+{
+	u32 ret_value;
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct false_alarm_statistics *falsealm_cnt = &(rtlpriv->falsealm_cnt);
+
+	ret_value = rtl_get_bbreg(hw, ROFDM_PHYCOUNTER1, MASKDWORD);
+	falsealm_cnt->cnt_parity_fail = ((ret_value & 0xffff0000) >> 16);
+
+	ret_value = rtl_get_bbreg(hw, ROFDM_PHYCOUNTER2, MASKDWORD);
+	falsealm_cnt->cnt_rate_illegal = (ret_value & 0xffff);
+	falsealm_cnt->cnt_crc8_fail = ((ret_value & 0xffff0000) >> 16);
+
+	ret_value = rtl_get_bbreg(hw, ROFDM_PHYCOUNTER3, MASKDWORD);
+	falsealm_cnt->cnt_mcs_fail = (ret_value & 0xffff);
+	falsealm_cnt->cnt_ofdm_fail = falsealm_cnt->cnt_parity_fail +
+	    falsealm_cnt->cnt_rate_illegal +
+	    falsealm_cnt->cnt_crc8_fail + falsealm_cnt->cnt_mcs_fail;
+
+	rtl_set_bbreg(hw, RCCK0_FALSEALARMREPORT, BIT(14), 1);
+	ret_value = rtl_get_bbreg(hw, RCCK0_FACOUNTERLOWER, MASKBYTE0);
+	falsealm_cnt->cnt_cck_fail = ret_value;
+
+	ret_value = rtl_get_bbreg(hw, RCCK0_FACOUNTERUPPER, MASKBYTE3);
+	falsealm_cnt->cnt_cck_fail += (ret_value & 0xff) << 8;
+	falsealm_cnt->cnt_all = (falsealm_cnt->cnt_parity_fail +
+				 falsealm_cnt->cnt_rate_illegal +
+				 falsealm_cnt->cnt_crc8_fail +
+				 falsealm_cnt->cnt_mcs_fail +
+				 falsealm_cnt->cnt_cck_fail);
+
+	rtl_set_bbreg(hw, ROFDM1_LSTF, 0x08000000, 1);
+	rtl_set_bbreg(hw, ROFDM1_LSTF, 0x08000000, 0);
+	rtl_set_bbreg(hw, RCCK0_FALSEALARMREPORT, 0x0000c000, 0);
+	rtl_set_bbreg(hw, RCCK0_FALSEALARMREPORT, 0x0000c000, 2);
+
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
+		 "cnt_parity_fail = %d, cnt_rate_illegal = %d, "
+		 "cnt_crc8_fail = %d, cnt_mcs_fail = %d\n",
+		 falsealm_cnt->cnt_parity_fail,
+		 falsealm_cnt->cnt_rate_illegal,
+		 falsealm_cnt->cnt_crc8_fail, falsealm_cnt->cnt_mcs_fail);
+
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
+		 "cnt_ofdm_fail = %x, cnt_cck_fail = %x, cnt_all = %x\n",
+		 falsealm_cnt->cnt_ofdm_fail,
+		 falsealm_cnt->cnt_cck_fail, falsealm_cnt->cnt_all);
+}
+
+static void rtl92c_dm_ctrl_initgain_by_fa(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+	u8 value_igi = dm_digtable->cur_igvalue;
+
+	if (rtlpriv->falsealm_cnt.cnt_all < DM_DIG_FA_TH0)
+		value_igi--;
+	else if (rtlpriv->falsealm_cnt.cnt_all < DM_DIG_FA_TH1)
+		value_igi += 0;
+	else if (rtlpriv->falsealm_cnt.cnt_all < DM_DIG_FA_TH2)
+		value_igi++;
+	else if (rtlpriv->falsealm_cnt.cnt_all >= DM_DIG_FA_TH2)
+		value_igi += 2;
+	if (value_igi > DM_DIG_FA_UPPER)
+		value_igi = DM_DIG_FA_UPPER;
+	else if (value_igi < DM_DIG_FA_LOWER)
+		value_igi = DM_DIG_FA_LOWER;
+	if (rtlpriv->falsealm_cnt.cnt_all > 10000)
+		value_igi = 0x32;
+
+	dm_digtable->cur_igvalue = value_igi;
+	rtl8723ae_dm_write_dig(hw);
+}
+
+static void rtl92c_dm_ctrl_initgain_by_rssi(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+
+	if (rtlpriv->falsealm_cnt.cnt_all > dm_digtable->fa_highthresh) {
+		if ((dm_digtable->backoff_val - 2) <
+		    dm_digtable->backoff_val_range_min)
+			dm_digtable->backoff_val =
+			    dm_digtable->backoff_val_range_min;
+		else
+			dm_digtable->backoff_val -= 2;
+	} else if (rtlpriv->falsealm_cnt.cnt_all < dm_digtable->fa_lowthresh) {
+		if ((dm_digtable->backoff_val + 2) >
+		    dm_digtable->backoff_val_range_max)
+			dm_digtable->backoff_val =
+			    dm_digtable->backoff_val_range_max;
+		else
+			dm_digtable->backoff_val += 2;
+	}
+
+	if ((dm_digtable->rssi_val_min + 10 - dm_digtable->backoff_val) >
+	    dm_digtable->rx_gain_range_max)
+		dm_digtable->cur_igvalue = dm_digtable->rx_gain_range_max;
+	else if ((dm_digtable->rssi_val_min + 10 -
+		  dm_digtable->backoff_val) < dm_digtable->rx_gain_range_min)
+		dm_digtable->cur_igvalue = dm_digtable->rx_gain_range_min;
+	else
+		dm_digtable->cur_igvalue = dm_digtable->rssi_val_min + 10 -
+		    dm_digtable->backoff_val;
+
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
+		 "rssi_val_min = %x backoff_val %x\n",
+		 dm_digtable->rssi_val_min, dm_digtable->backoff_val);
+
+	rtl8723ae_dm_write_dig(hw);
+}
+
+static void rtl8723ae_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+	long rssi_strength = rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+	bool multi_sta = false;
+
+	if (mac->opmode == NL80211_IFTYPE_ADHOC)
+		multi_sta = true;
+
+	if ((!multi_sta) ||
+	    (dm_digtable->cursta_connectstate != DIG_STA_DISCONNECT)) {
+		rtlpriv->initialized = false;
+		dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
+		return;
+	} else if (!rtlpriv->initialized) {
+		rtlpriv->initialized = true;
+		dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_0;
+		dm_digtable->cur_igvalue = 0x20;
+		rtl8723ae_dm_write_dig(hw);
+	}
+
+	if (dm_digtable->curmultista_connectstate == DIG_MULTISTA_CONNECT) {
+		if ((rssi_strength < dm_digtable->rssi_lowthresh) &&
+		    (dm_digtable->dig_ext_port_stage != DIG_EXT_PORT_STAGE_1)) {
+
+			if (dm_digtable->dig_ext_port_stage ==
+			    DIG_EXT_PORT_STAGE_2) {
+				dm_digtable->cur_igvalue = 0x20;
+				rtl8723ae_dm_write_dig(hw);
+			}
+
+			dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_1;
+		} else if (rssi_strength > dm_digtable->rssi_highthresh) {
+			dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_2;
+			rtl92c_dm_ctrl_initgain_by_fa(hw);
+		}
+	} else if (dm_digtable->dig_ext_port_stage != DIG_EXT_PORT_STAGE_0) {
+		dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_0;
+		dm_digtable->cur_igvalue = 0x20;
+		rtl8723ae_dm_write_dig(hw);
+	}
+
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
+		 "curmultista_connectstate = "
+		 "%x dig_ext_port_stage %x\n",
+		 dm_digtable->curmultista_connectstate,
+		 dm_digtable->dig_ext_port_stage);
+}
+
+static void rtl8723ae_dm_initial_gain_sta(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
+		 "presta_connectstate = %x,"
+		 " cursta_connectstate = %x\n",
+		 dm_digtable->presta_connectstate,
+		 dm_digtable->cursta_connectstate);
+
+	if (dm_digtable->presta_connectstate == dm_digtable->cursta_connectstate
+	    || dm_digtable->cursta_connectstate == DIG_STA_BEFORE_CONNECT
+	    || dm_digtable->cursta_connectstate == DIG_STA_CONNECT) {
+
+		if (dm_digtable->cursta_connectstate != DIG_STA_DISCONNECT) {
+			dm_digtable->rssi_val_min =
+			    rtl8723ae_dm_initial_gain_min_pwdb(hw);
+			rtl92c_dm_ctrl_initgain_by_rssi(hw);
+		}
+	} else {
+		dm_digtable->rssi_val_min = 0;
+		dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
+		dm_digtable->backoff_val = DM_DIG_BACKOFF_DEFAULT;
+		dm_digtable->cur_igvalue = 0x20;
+		dm_digtable->pre_igvalue = 0;
+		rtl8723ae_dm_write_dig(hw);
+	}
+}
+static void rtl8723ae_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+
+	if (dm_digtable->cursta_connectstate == DIG_STA_CONNECT) {
+		dm_digtable->rssi_val_min =
+					 rtl8723ae_dm_initial_gain_min_pwdb(hw);
+
+		if (dm_digtable->pre_cck_pd_state == CCK_PD_STAGE_LowRssi) {
+			if (dm_digtable->rssi_val_min <= 25)
+				dm_digtable->cur_cck_pd_state =
+				    CCK_PD_STAGE_LowRssi;
+			else
+				dm_digtable->cur_cck_pd_state =
+				    CCK_PD_STAGE_HighRssi;
+		} else {
+			if (dm_digtable->rssi_val_min <= 20)
+				dm_digtable->cur_cck_pd_state =
+				    CCK_PD_STAGE_LowRssi;
+			else
+				dm_digtable->cur_cck_pd_state =
+				    CCK_PD_STAGE_HighRssi;
+		}
+	} else {
+		dm_digtable->cur_cck_pd_state = CCK_PD_STAGE_MAX;
+	}
+
+	if (dm_digtable->pre_cck_pd_state != dm_digtable->cur_cck_pd_state) {
+		if (dm_digtable->cur_cck_pd_state == CCK_PD_STAGE_LowRssi) {
+			if (rtlpriv->falsealm_cnt.cnt_cck_fail > 800)
+				dm_digtable->cur_cck_fa_state =
+				    CCK_FA_STAGE_High;
+			else
+				dm_digtable->cur_cck_fa_state =
+							 CCK_FA_STAGE_Low;
+
+			if (dm_digtable->pre_cck_fa_state !=
+			    dm_digtable->cur_cck_fa_state) {
+				if (dm_digtable->cur_cck_fa_state ==
+				    CCK_FA_STAGE_Low)
+					rtl_set_bbreg(hw, RCCK0_CCA, MASKBYTE2,
+						      0x83);
+				else
+					rtl_set_bbreg(hw, RCCK0_CCA, MASKBYTE2,
+						      0xcd);
+
+				dm_digtable->pre_cck_fa_state =
+				    dm_digtable->cur_cck_fa_state;
+			}
+
+			rtl_set_bbreg(hw, RCCK0_SYSTEM, MASKBYTE1, 0x40);
+
+		} else {
+			rtl_set_bbreg(hw, RCCK0_CCA, MASKBYTE2, 0xcd);
+			rtl_set_bbreg(hw, RCCK0_SYSTEM, MASKBYTE1, 0x47);
+
+		}
+		dm_digtable->pre_cck_pd_state = dm_digtable->cur_cck_pd_state;
+	}
+
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
+		 "CCKPDStage=%x\n", dm_digtable->cur_cck_pd_state);
+
+}
+
+static void rtl8723ae_dm_ctrl_initgain_by_twoport(struct ieee80211_hw *hw)
+{
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+
+	if (mac->act_scanning == true)
+		return;
+
+	if (mac->link_state >= MAC80211_LINKED)
+		dm_digtable->cursta_connectstate = DIG_STA_CONNECT;
+	else
+		dm_digtable->cursta_connectstate = DIG_STA_DISCONNECT;
+
+	rtl8723ae_dm_initial_gain_sta(hw);
+	rtl8723ae_dm_initial_gain_multi_sta(hw);
+	rtl8723ae_dm_cck_packet_detection_thresh(hw);
+
+	dm_digtable->presta_connectstate = dm_digtable->cursta_connectstate;
+
+}
+
+static void rtl8723ae_dm_dig(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+
+	if (rtlpriv->dm.dm_initialgain_enable == false)
+		return;
+	if (dm_digtable->dig_enable_flag == false)
+		return;
+
+	rtl8723ae_dm_ctrl_initgain_by_twoport(hw);
+}
+
+static void rtl8723ae_dm_init_dynamic_txpower(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->dm.dynamic_txpower_enable = false;
+
+	rtlpriv->dm.last_dtp_lvl = TXHIGHPWRLEVEL_NORMAL;
+	rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
+}
+
+static void rtl8723ae_dm_dynamic_txpower(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_phy *rtlphy = &(rtlpriv->phy);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	long undecorated_smoothed_pwdb;
+
+	if (!rtlpriv->dm.dynamic_txpower_enable)
+		return;
+
+	if (rtlpriv->dm.dm_flag & HAL_DM_HIPWR_DISABLE) {
+		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
+		return;
+	}
+
+	if ((mac->link_state < MAC80211_LINKED) &&
+	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
+			 "Not connected\n");
+
+		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
+
+		rtlpriv->dm.last_dtp_lvl = TXHIGHPWRLEVEL_NORMAL;
+		return;
+	}
+
+	if (mac->link_state >= MAC80211_LINKED) {
+		if (mac->opmode == NL80211_IFTYPE_ADHOC) {
+			undecorated_smoothed_pwdb =
+			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+				 "AP Client PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
+		} else {
+			undecorated_smoothed_pwdb =
+			    rtlpriv->dm.undecorated_smoothed_pwdb;
+			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+				 "STA Default Port PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
+		}
+	} else {
+		undecorated_smoothed_pwdb =
+		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "AP Ext Port PWDB = 0x%lx\n",
+			  undecorated_smoothed_pwdb);
+	}
+
+	if (undecorated_smoothed_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL2) {
+		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n");
+	} else if ((undecorated_smoothed_pwdb <
+		   (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
+		   (undecorated_smoothed_pwdb >=
+		   TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
+		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n");
+	} else if (undecorated_smoothed_pwdb <
+		   (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
+		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "TXHIGHPWRLEVEL_NORMAL\n");
+	}
+
+	if ((rtlpriv->dm.dynamic_txhighpower_lvl != rtlpriv->dm.last_dtp_lvl)) {
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "PHY_SetTxPowerLevel8192S() Channel = %d\n",
+			  rtlphy->current_channel);
+		rtl8723ae_phy_set_txpower_level(hw, rtlphy->current_channel);
+	}
+
+	rtlpriv->dm.last_dtp_lvl = rtlpriv->dm.dynamic_txhighpower_lvl;
+}
+
+void rtl8723ae_dm_write_dig(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+		 "cur_igvalue = 0x%x, "
+		 "pre_igvalue = 0x%x, backoff_val = %d\n",
+		 dm_digtable->cur_igvalue, dm_digtable->pre_igvalue,
+		 dm_digtable->backoff_val);
+
+	if (dm_digtable->pre_igvalue != dm_digtable->cur_igvalue) {
+		rtl_set_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7f,
+			      dm_digtable->cur_igvalue);
+		rtl_set_bbreg(hw, ROFDM0_XBAGCCORE1, 0x7f,
+			      dm_digtable->cur_igvalue);
+
+		dm_digtable->pre_igvalue = dm_digtable->cur_igvalue;
+	}
+}
+
+static void rtl8723ae_dm_pwdmonitor(struct ieee80211_hw *hw)
+{
+	return;
+}
+
+void rtl8723ae_dm_init_edca_turbo(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->dm.current_turbo_edca = false;
+	rtlpriv->dm.is_any_nonbepkts = false;
+	rtlpriv->dm.is_cur_rdlstate = false;
+}
+
+static void rtl8723ae_dm_check_edca_turbo(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+
+	u64 cur_txok_cnt = 0;
+	u64 cur_rxok_cnt = 0;
+	u32 edca_be_ul = 0x5ea42b;
+	u32 edca_be_dl = 0x5ea42b;
+	bool bt_change_edca = false;
+
+	if ((mac->last_bt_edca_ul != rtlpcipriv->bt_coexist.bt_edca_ul) ||
+	    (mac->last_bt_edca_dl != rtlpcipriv->bt_coexist.bt_edca_dl)) {
+		rtlpriv->dm.current_turbo_edca = false;
+		mac->last_bt_edca_ul = rtlpcipriv->bt_coexist.bt_edca_ul;
+		mac->last_bt_edca_dl = rtlpcipriv->bt_coexist.bt_edca_dl;
+	}
+
+	if (rtlpcipriv->bt_coexist.bt_edca_ul != 0) {
+		edca_be_ul = rtlpcipriv->bt_coexist.bt_edca_ul;
+		bt_change_edca = true;
+	}
+
+	if (rtlpcipriv->bt_coexist.bt_edca_dl != 0) {
+		edca_be_ul = rtlpcipriv->bt_coexist.bt_edca_dl;
+		bt_change_edca = true;
+	}
+
+	if (mac->link_state != MAC80211_LINKED) {
+		rtlpriv->dm.current_turbo_edca = false;
+		return;
+	}
+
+	if ((!mac->ht_enable) && (!rtlpcipriv->bt_coexist.bt_coexistence)) {
+		if (!(edca_be_ul & 0xffff0000))
+			edca_be_ul |= 0x005e0000;
+
+		if (!(edca_be_dl & 0xffff0000))
+			edca_be_dl |= 0x005e0000;
+	}
+
+	if ((bt_change_edca) || ((!rtlpriv->dm.is_any_nonbepkts) &&
+	     (!rtlpriv->dm.disable_framebursting))) {
+
+		cur_txok_cnt = rtlpriv->stats.txbytesunicast -
+			       mac->last_txok_cnt;
+		cur_rxok_cnt = rtlpriv->stats.rxbytesunicast -
+			       mac->last_rxok_cnt;
+
+		if (cur_rxok_cnt > 4 * cur_txok_cnt) {
+			if (!rtlpriv->dm.is_cur_rdlstate ||
+			    !rtlpriv->dm.current_turbo_edca) {
+				rtl_write_dword(rtlpriv,
+						REG_EDCA_BE_PARAM,
+						edca_be_dl);
+				rtlpriv->dm.is_cur_rdlstate = true;
+			}
+		} else {
+			if (rtlpriv->dm.is_cur_rdlstate ||
+			    !rtlpriv->dm.current_turbo_edca) {
+				rtl_write_dword(rtlpriv,
+						REG_EDCA_BE_PARAM,
+						edca_be_ul);
+				rtlpriv->dm.is_cur_rdlstate = false;
+			}
+		}
+		rtlpriv->dm.current_turbo_edca = true;
+	} else {
+		if (rtlpriv->dm.current_turbo_edca) {
+			u8 tmp = AC0_BE;
+			rtlpriv->cfg->ops->set_hw_reg(hw,
+						      HW_VAR_AC_PARAM,
+						      (u8 *) (&tmp));
+			rtlpriv->dm.current_turbo_edca = false;
+		}
+	}
+
+	rtlpriv->dm.is_any_nonbepkts = false;
+	mac->last_txok_cnt = rtlpriv->stats.txbytesunicast;
+	mac->last_rxok_cnt = rtlpriv->stats.rxbytesunicast;
+}
+
+static void rtl8723ae_dm_initialize_txpower_tracking_thermalmeter(
+				struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->dm.txpower_tracking = true;
+	rtlpriv->dm.txpower_trackinginit = false;
+
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+		 "pMgntInfo->txpower_tracking = %d\n",
+		 rtlpriv->dm.txpower_tracking);
+}
+
+static void rtl8723ae_dm_initialize_txpower_tracking(struct ieee80211_hw *hw)
+{
+	rtl8723ae_dm_initialize_txpower_tracking_thermalmeter(hw);
+}
+
+void rtl8723ae_dm_check_txpower_tracking(struct ieee80211_hw *hw)
+{
+	return;
+}
+
+void rtl8723ae_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rate_adaptive *p_ra = &(rtlpriv->ra);
+
+	p_ra->ratr_state = DM_RATR_STA_INIT;
+	p_ra->pre_ratr_state = DM_RATR_STA_INIT;
+
+	if (rtlpriv->dm.dm_type == DM_TYPE_BYDRIVER)
+		rtlpriv->dm.useramask = true;
+	else
+		rtlpriv->dm.useramask = false;
+}
+
+static void rtl8723ae_dm_init_dynamic_bpowersaving(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->dm_pstable.pre_ccastate = CCA_MAX;
+	rtlpriv->dm_pstable.cur_ccasate = CCA_MAX;
+	rtlpriv->dm_pstable.pre_rfstate = RF_MAX;
+	rtlpriv->dm_pstable.cur_rfstate = RF_MAX;
+	rtlpriv->dm_pstable.rssi_val_min = 0;
+}
+
+void rtl8723ae_dm_rf_saving(struct ieee80211_hw *hw, u8 force_in_normal)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct ps_t *dm_pstable = &rtlpriv->dm_pstable;
+
+	if (!rtlpriv->reg_init) {
+		rtlpriv->reg_874 = (rtl_get_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
+				    MASKDWORD) & 0x1CC000) >> 14;
+
+		rtlpriv->reg_c70 = (rtl_get_bbreg(hw, ROFDM0_AGCPARAMETER1,
+				    MASKDWORD) & BIT(3)) >> 3;
+
+		rtlpriv->reg_85c = (rtl_get_bbreg(hw, RFPGA0_XCD_SWITCHCONTROL,
+				    MASKDWORD) & 0xFF000000) >> 24;
+
+		rtlpriv->reg_a74 = (rtl_get_bbreg(hw, 0xa74, MASKDWORD) &
+				   0xF000) >> 12;
+
+		rtlpriv->reg_init = true;
+	}
+
+	if (!force_in_normal) {
+		if (dm_pstable->rssi_val_min != 0) {
+			if (dm_pstable->pre_rfstate == RF_NORMAL) {
+				if (dm_pstable->rssi_val_min >= 30)
+					dm_pstable->cur_rfstate = RF_SAVE;
+				else
+					dm_pstable->cur_rfstate = RF_NORMAL;
+			} else {
+				if (dm_pstable->rssi_val_min <= 25)
+					dm_pstable->cur_rfstate = RF_NORMAL;
+				else
+					dm_pstable->cur_rfstate = RF_SAVE;
+			}
+		} else {
+			dm_pstable->cur_rfstate = RF_MAX;
+		}
+	} else {
+		dm_pstable->cur_rfstate = RF_NORMAL;
+	}
+
+	if (dm_pstable->pre_rfstate != dm_pstable->cur_rfstate) {
+		if (dm_pstable->cur_rfstate == RF_SAVE) {
+
+			rtl_set_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
+				      BIT(5), 0x1);
+			rtl_set_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
+				      0x1C0000, 0x2);
+			rtl_set_bbreg(hw, ROFDM0_AGCPARAMETER1, BIT(3), 0);
+			rtl_set_bbreg(hw, RFPGA0_XCD_SWITCHCONTROL,
+				      0xFF000000, 0x63);
+			rtl_set_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
+				      0xC000, 0x2);
+			rtl_set_bbreg(hw, 0xa74, 0xF000, 0x3);
+			rtl_set_bbreg(hw, 0x818, BIT(28), 0x0);
+			rtl_set_bbreg(hw, 0x818, BIT(28), 0x1);
+		} else {
+			rtl_set_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
+				      0x1CC000, rtlpriv->reg_874);
+			rtl_set_bbreg(hw, ROFDM0_AGCPARAMETER1, BIT(3),
+				      rtlpriv->reg_c70);
+			rtl_set_bbreg(hw, RFPGA0_XCD_SWITCHCONTROL, 0xFF000000,
+				      rtlpriv->reg_85c);
+			rtl_set_bbreg(hw, 0xa74, 0xF000, rtlpriv->reg_a74);
+			rtl_set_bbreg(hw, 0x818, BIT(28), 0x0);
+			rtl_set_bbreg(hw, RFPGA0_XCD_RFINTERFACESW,
+				      BIT(5), 0x0);
+		}
+
+		dm_pstable->pre_rfstate = dm_pstable->cur_rfstate;
+	}
+}
+
+static void rtl8723ae_dm_dynamic_bpowersaving(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
+	struct ps_t *dm_pstable = &rtlpriv->dm_pstable;
+
+	if (((mac->link_state == MAC80211_NOLINK)) &&
+	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
+		dm_pstable->rssi_val_min = 0;
+		RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
+			 "Not connected to any\n");
+	}
+
+	if (mac->link_state == MAC80211_LINKED) {
+		if (mac->opmode == NL80211_IFTYPE_ADHOC) {
+			dm_pstable->rssi_val_min =
+			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+			RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
+				 "AP Client PWDB = 0x%lx\n",
+				 dm_pstable->rssi_val_min);
+		} else {
+			dm_pstable->rssi_val_min =
+			    rtlpriv->dm.undecorated_smoothed_pwdb;
+			RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
+				 "STA Default Port PWDB = 0x%lx\n",
+				 dm_pstable->rssi_val_min);
+		}
+	} else {
+		dm_pstable->rssi_val_min =
+		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+
+		RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
+			 "AP Ext Port PWDB = 0x%lx\n",
+			 dm_pstable->rssi_val_min);
+	}
+
+	rtl8723ae_dm_rf_saving(hw, false);
+}
+
+void rtl8723ae_dm_init(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+
+	rtlpriv->dm.dm_type = DM_TYPE_BYDRIVER;
+	rtl8723ae_dm_diginit(hw);
+	rtl8723ae_dm_init_dynamic_txpower(hw);
+	rtl8723ae_dm_init_edca_turbo(hw);
+	rtl8723ae_dm_init_rate_adaptive_mask(hw);
+	rtl8723ae_dm_initialize_txpower_tracking(hw);
+	rtl8723ae_dm_init_dynamic_bpowersaving(hw);
+}
+
+void rtl8723ae_dm_watchdog(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
+	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
+	bool fw_current_inpsmode = false;
+	bool fw_ps_awake = true;
+	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FW_PSMODE_STATUS,
+				      (u8 *) (&fw_current_inpsmode));
+	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_FWLPS_RF_ON,
+				      (u8 *) (&fw_ps_awake));
+
+	if ((ppsc->rfpwr_state == ERFON)
+		&& ((!fw_current_inpsmode) && fw_ps_awake)
+		&& (!ppsc->rfchange_inprogress)) {
+		rtl8723ae_dm_pwdmonitor(hw);
+		rtl8723ae_dm_dig(hw);
+		rtl8723ae_dm_false_alarm_counter_statistics(hw);
+		rtl8723ae_dm_dynamic_bpowersaving(hw);
+		rtl8723ae_dm_dynamic_txpower(hw);
+		rtl8723ae_dm_check_txpower_tracking(hw);
+		/* rtl92c_dm_refresh_rate_adaptive_mask(hw); */
+		rtl8723ae_dm_bt_coexist(hw);
+		rtl8723ae_dm_check_edca_turbo(hw);
+	}
+	if (rtlpcipriv->bt_coexist.init_set)
+		rtl_write_byte(rtlpriv, 0x76e, 0xc);
+}
+
+static void rtl8723ae_dm_init_bt_coexist(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
+
+	rtlpcipriv->bt_coexist.bt_rfreg_origin_1e
+		= rtl_get_rfreg(hw, (enum radio_path)0, RF_RCK1, 0xfffff);
+	rtlpcipriv->bt_coexist.bt_rfreg_origin_1f
+		= rtl_get_rfreg(hw, (enum radio_path)0, RF_RCK2, 0xf0);
+
+	rtlpcipriv->bt_coexist.current_state = 0;
+	rtlpcipriv->bt_coexist.previous_state = 0;
+	rtlpcipriv->bt_coexist.current_state_h = 0;
+	rtlpcipriv->bt_coexist.previous_state_h = 0;
+	rtlpcipriv->bt_coexist.lps_counter = 0;
+
+	/*  Enable counter statistics */
+	rtl_write_byte(rtlpriv, 0x76e, 0x4);
+	rtl_write_byte(rtlpriv, 0x778, 0x3);
+	rtl_write_byte(rtlpriv, 0x40, 0x20);
+
+	rtlpcipriv->bt_coexist.init_set = true;
+}
+
+void rtl8723ae_dm_bt_coexist(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
+	u8 tmp_byte = 0;
+	if (!rtlpcipriv->bt_coexist.bt_coexistence) {
+		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_LOUD,
+			 "[DM]{BT], BT not exist!!\n");
+		return;
+	}
+
+	if (!rtlpcipriv->bt_coexist.init_set) {
+		RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_LOUD,
+			 "[DM][BT], rtl8723ae_dm_bt_coexist()\n");
+
+		rtl8723ae_dm_init_bt_coexist(hw);
+	}
+
+	tmp_byte = rtl_read_byte(rtlpriv, 0x40);
+	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_LOUD,
+		 "[DM][BT], 0x40 is 0x%x", tmp_byte);
+	RT_TRACE(rtlpriv, COMP_BT_COEXIST, DBG_DMESG,
+		 "[DM][BT], bt_dm_coexist start");
+	rtl8723ae_dm_bt_coexist_8723(hw);
+}
Index: wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
===================================================================
--- /dev/null
+++ wireless-testing-new/drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
@@ -0,0 +1,174 @@
+/******************************************************************************
+ *
+ * Copyright(c) 2009-2012  Realtek Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110, USA
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * wlanfae <wlanfae@realtek.com>
+ * Realtek Corporation, No. 2, Innovation Road II, Hsinchu Science Park,
+ * Hsinchu 300, Taiwan.
+ *
+ * Larry Finger <Larry.Finger@lwfinger.net>
+ *
+ *****************************************************************************/
+
+#ifndef	__RTL8723E_DM_H__
+#define __RTL8723E_DM_H__
+
+#define HAL_DM_DIG_DISABLE			BIT(0)
+#define HAL_DM_HIPWR_DISABLE			BIT(1)
+
+#define OFDM_TABLE_LENGTH			37
+#define CCK_TABLE_LENGTH			33
+
+#define OFDM_TABLE_SIZE				37
+#define CCK_TABLE_SIZE				33
+
+#define BW_AUTO_SWITCH_HIGH_LOW			25
+#define BW_AUTO_SWITCH_LOW_HIGH			30
+
+#define DM_DIG_THRESH_HIGH			40
+#define DM_DIG_THRESH_LOW			35
+
+#define DM_FALSEALARM_THRESH_LOW		400
+#define DM_FALSEALARM_THRESH_HIGH		1000
+
+#define DM_DIG_MAX				0x3e
+#define DM_DIG_MIN				0x1e
+
+#define DM_DIG_FA_UPPER				0x32
+#define DM_DIG_FA_LOWER				0x20
+#define DM_DIG_FA_TH0				0x20
+#define DM_DIG_FA_TH1				0x100
+#define DM_DIG_FA_TH2				0x200
+
+#define DM_DIG_BACKOFF_MAX			12
+#define DM_DIG_BACKOFF_MIN			-4
+#define DM_DIG_BACKOFF_DEFAULT			10
+
+#define RXPATHSELECTION_SS_TH_lOW		30
+#define RXPATHSELECTION_DIFF_TH			18
+
+#define DM_RATR_STA_INIT			0
+#define DM_RATR_STA_HIGH			1
+#define DM_RATR_STA_MIDDLE			2
+#define DM_RATR_STA_LOW				3
+
+#define CTS2SELF_THVAL				30
+#define REGC38_TH				20
+
+#define WAIOTTHVal				25
+
+#define TXHIGHPWRLEVEL_NORMAL			0
+#define TXHIGHPWRLEVEL_LEVEL1			1
+#define TXHIGHPWRLEVEL_LEVEL2			2
+#define TXHIGHPWRLEVEL_BT1			3
+#define TXHIGHPWRLEVEL_BT2			4
+
+#define DM_TYPE_BYFW				0
+#define DM_TYPE_BYDRIVER			1
+
+#define TX_POWER_NEAR_FIELD_THRESH_LVL2		74
+#define TX_POWER_NEAR_FIELD_THRESH_LVL1		67
+
+struct swat_t {
+	u8 failure_cnt;
+	u8 try_flag;
+	u8 stop_trying;
+	long pre_rssi;
+	long trying_threshold;
+	u8 cur_antenna;
+	u8 pre_antenna;
+};
+
+enum tag_dynamic_init_gain_operation_type_definition {
+	DIG_TYPE_THRESH_HIGH = 0,
+	DIG_TYPE_THRESH_LOW = 1,
+	DIG_TYPE_BACKOFF = 2,
+	DIG_TYPE_RX_GAIN_MIN = 3,
+	DIG_TYPE_RX_GAIN_MAX = 4,
+	DIG_TYPE_ENABLE = 5,
+	DIG_TYPE_DISABLE = 6,
+	DIG_OP_TYPE_MAX
+};
+
+enum tag_cck_packet_detection_threshold_type_definition {
+	CCK_PD_STAGE_LowRssi = 0,
+	CCK_PD_STAGE_HighRssi = 1,
+	CCK_FA_STAGE_Low = 2,
+	CCK_FA_STAGE_High = 3,
+	CCK_PD_STAGE_MAX = 4,
+};
+
+enum dm_1r_cca_e {
+	CCA_1R = 0,
+	CCA_2R = 1,
+	CCA_MAX = 2,
+};
+
+enum dm_rf_e {
+	RF_SAVE = 0,
+	RF_NORMAL = 1,
+	RF_MAX = 2,
+};
+
+enum dm_sw_ant_switch_e {
+	ANS_ANTENNA_B = 1,
+	ANS_ANTENNA_A = 2,
+	ANS_ANTENNA_MAX = 3,
+};
+
+enum dm_dig_ext_port_alg_e {
+	DIG_EXT_PORT_STAGE_0 = 0,
+	DIG_EXT_PORT_STAGE_1 = 1,
+	DIG_EXT_PORT_STAGE_2 = 2,
+	DIG_EXT_PORT_STAGE_3 = 3,
+	DIG_EXT_PORT_STAGE_MAX = 4,
+};
+
+enum dm_dig_connect_e {
+	DIG_STA_DISCONNECT = 0,
+	DIG_STA_CONNECT = 1,
+	DIG_STA_BEFORE_CONNECT = 2,
+	DIG_MULTISTA_DISCONNECT = 3,
+	DIG_MULTISTA_CONNECT = 4,
+	DIG_CONNECT_MAX
+};
+
+#define BT_RSSI_STATE_NORMAL_POWER      BIT_OFFSET_LEN_MASK_32(0, 1)
+#define BT_RSSI_STATE_AMDPU_OFF         BIT_OFFSET_LEN_MASK_32(1, 1)
+#define BT_RSSI_STATE_SPECIAL_LOW       BIT_OFFSET_LEN_MASK_32(2, 1)
+#define BT_RSSI_STATE_BG_EDCA_LOW       BIT_OFFSET_LEN_MASK_32(3, 1)
+#define BT_RSSI_STATE_TXPOWER_LOW       BIT_OFFSET_LEN_MASK_32(4, 1)
+#define GET_UNDECORATED_AVERAGE_RSSI(_priv)     \
+	((((struct rtl_priv *)(_priv))->mac80211.opmode ==	\
+	NL80211_IFTYPE_ADHOC) ?  \
+	(((struct rtl_priv *)(_priv))->dm.entry_min_undecoratedsmoothed_pwdb) \
+	: (((struct rtl_priv *)(_priv))->dm.undecorated_smoothed_pwdb))
+extern struct dig_t dm_digtable;
+void rtl8723ae_dm_init(struct ieee80211_hw *hw);
+void rtl8723ae_dm_watchdog(struct ieee80211_hw *hw);
+void rtl8723ae_dm_write_dig(struct ieee80211_hw *hw);
+void rtl8723ae_dm_init_edca_turbo(struct ieee80211_hw *hw);
+void rtl8723ae_dm_check_txpower_tracking(struct ieee80211_hw *hw);
+void rtl8723ae_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw);
+void rtl8723ae_dm_rf_saving(struct ieee80211_hw *hw, u8 bforce_in_normal);
+void rtl8723ae_dm_bt_coexist(struct ieee80211_hw *hw);
+
+#endif
+
