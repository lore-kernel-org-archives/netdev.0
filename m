From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: [PATCH 6/7] Topcliff GbE: Add The common header files [1/2]
Date: Fri, 23 Apr 2010 21:01:20 +0900
Message-ID: <003601cae2dd$211b5690$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: message/partial;
	total=2;
	id="01CAE2DD.1F185AA0@tsmail03";
	number=1
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "NETDEV" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:34085 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757351Ab0DWMEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 08:04:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
To: "NETDEV" <netdev@vger.kernel.org>
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
Subject: [PATCH 6/7] Topcliff GbE: Add The common header files
Date: Fri, 23 Apr 2010 21:01:20 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
X-Priority: 3
X-MSMail-Priority: Normal
X-Mailer: Microsoft Outlook Express 6.00.2800.1983
X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2800.1983

From: Masayuki Ohtake <masa-korg@dsn.okisemi.com>

This patch adds the common header files of GbE driver for Topcliff.
The GbE driver needs all patch[1/7 to 7/7].

Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_debug.h            | 56 ++
 drivers/net/pch_gbe/pch_gbe_defines.h      | 344
 drivers/net/pch_gbe/pch_gbe.h              | 228
 drivers/net/pch_gbe/pch_gbe_hw.h           | 258
 drivers/net/pch_gbe/pch_gbe_osdep.h        | 74
 drivers/net/pch_gbe/pch_gbe_pci_ids.h      | 37
 drivers/net/pch_gbe/pch_gbe_regs.h         | 350
+++++++++++++++++++++++++++++++ 7 files changed, 1347 insertions(+)
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_debug.h
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_debug.h
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_debug.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_debug.h 2010-04-13
19:06:39.000000000 +0900
@@ -0,0 +1,56 @@
+/*!
+ * @file pch_debug.h
+ * @brief Provides the macro definitions used for debugging.
+ * @version 1.0.0.0
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ *
+ */
+
+#ifndef __PCH_DEBUG_H__
+#define __PCH_DEBUG_H__
+
+#ifdef MODULE
+#define PCH_LOG(level, fmt, args...) printk(level "%s:" fmt "\n",\
+       THIS_MODULE->name, ##args)
+#else
+#define PCH_LOG(level, fmt, args...) printk(level "%s:" fmt "\n" ,\
+        __FILE__, ##args)
+#endif
+
+#ifdef DEBUG
+ #define PCH_DEBUG(fmt, args...) PCH_LOG(KERN_DEBUG, fmt, ##args)
+#else
+ #define PCH_DEBUG(fmt, args...)
+#endif
+
+#ifdef PCH_TRACE_ENABLED
+ #define PCH_TRACE PCH_DEBUG
+#else
+ #define PCH_TRACE(fmt, args...)
+#endif
+
+#define PCH_TRACE_ENTER PCH_TRACE("Enter %s", __func__)
+#define PCH_TRACE_EXIT  PCH_TRACE("Exit %s", __func__)
+
+
+#endif
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_defines.h
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_defines.h
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_defines.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_defines.h 2010-04-13
18:11:28.000000000 +0900
@@ -0,0 +1,344 @@
+/*!
+ * @file pch_gbe_defines.h
+ * @brief Linux PCH Gigabit Ethernet Driver defines macro header file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+#ifndef _PCH_GBE_DEFINES_H_
+#define _PCH_GBE_DEFINES_H_
+
+#include "pch_gbe_pci_ids.h" /* Pci vender/device ID */
+
+/* DEBUG OPTION */
+/* #define DEBUG_TEST */
+/* #define NVM_MAC_FIX *//* MAC: 00 21 97 77 65 13 */
+
+#define PHY_RESET_REG_INIT
+
+#ifdef DEBUG_TEST
+#define PCH_GBE_NETIF_MSG_DEFAULT       0x7fff /* ALL Enable */
+#else
+#define PCH_GBE_NETIF_MSG_DEFAULT       0x0000 /* All Disable */
+#endif
+/*-- Kind of Messege --------------------------
+ NETIF_MSG_DRV  = 0x0001,
+ NETIF_MSG_PROBE  = 0x0002,
+ NETIF_MSG_LINK  = 0x0004,
+ NETIF_MSG_TIMER  = 0x0008,
+ NETIF_MSG_IFDOWN = 0x0010,
+ NETIF_MSG_IFUP  = 0x0020,
+ NETIF_MSG_RX_ERR = 0x0040,
+ NETIF_MSG_TX_ERR = 0x0080,
+ NETIF_MSG_TX_QUEUED = 0x0100,
+ NETIF_MSG_INTR  = 0x0200,
+ NETIF_MSG_TX_DONE = 0x0400,
+ NETIF_MSG_RX_STATUS = 0x0800,
+ NETIF_MSG_PKTDATA = 0x1000,
+ NETIF_MSG_HW  = 0x2000,
+ NETIF_MSG_WOL  = 0x4000,
+-----------------------------------------------*/
+
+/* IF OPTION */
+#define PCH_GBE_MAC_IFOP_RGMII
+#define PCH_GBE_MAC_RGMII_CTRL_SETTING ( \
+    PCH_GBE_CHIP_TYPE_INTERNAL | \
+    PCH_GBE_RGMII_MODE_RGMII   | \
+    PCH_GBE_CRS_SEL              \
+    )
+
+/* TX/RX descriptor defines */
+#define PCH_GBE_DEFAULT_TXD                  256
+#define PCH_GBE_MAX_TXD                     4096
+#define PCH_GBE_MIN_TXD                        8
+#define PCH_GBE_DEFAULT_RXD                  256
+#define PCH_GBE_MAX_RXD                     4096
+#define PCH_GBE_MIN_RXD                        8
+/* Number of Transmit and Receive Descriptors must be a multiple of 8 */
+#define PCH_GBE_TX_DESC_MULTIPLE               8
+#define PCH_GBE_RX_DESC_MULTIPLE               8
+
+/* Checksum Offload defines Enable/Disable */
+#define PCH_GBE_DEFAULT_RX_CSUM             TRUE /* TRUEorFALSE */
+#define PCH_GBE_DEFAULT_TX_CSUM             TRUE /* TRUEorFALSE */
+
+/* Copybreak default */
+#define PCH_GBE_COPYBREAK_DEFAULT       256
+#define PCH_GBE_PCI_BAR                 1
+
+/* Device Driver infomation */
+#define DRV_NAME        "pch_gbe"
+#define DRV_STRING      "PCH Network Driver"
+#define DRV_EXT         "-NAPI"
+#define DRV_VERSION     "0.91"DRV_EXT
+#define DRV_DESCRIPTION \
+ "OKI semiconductor sample Linux driver for PCH Gigabit ethernet"
+#define DRV_COPYRIGHT   "Copyright(c) 2009 OKI semiconductor"
+#define FIRM_VERSION    "N/A"
+
+#define PCH_GBE_MAC_REGS_LEN    76
+#define PCH_GBE_PHY_REGS_LEN    32
+#define PCH_GBE_REGS_LEN        (PCH_GBE_MAC_REGS_LEN +
PCH_GBE_PHY_REGS_LEN)
+
+#define PCH_GBE_DMA_ALIGN           (32)
+#define PCH_GBE_ETH_ALEN            6
+
+/* Initialize the wake-on-LAN settings */
+#define PCH_GBE_WL_INIT_SETTING    ( \
+    PCH_GBE_WLC_BR  |\
+    PCH_GBE_WLC_MLT |\
+    PCH_GBE_WLC_IND |\
+    PCH_GBE_WLC_MP   \
+    )
+
+/* This defines the bits that are set in the Interrupt Mask
+ * Set/Read Register.  Each bit is documented below:
+ *   o RXT0   = Receiver Timer Interrupt (ring 0)
+ *   o TXDW   = Transmit Descriptor Written Back
+ *   o RXDMT0 = Receive Descriptor Minimum Threshold hit (ring 0)
+ *   o RXSEQ  = Receive Sequence Error
+ *   o LSC    = Link Status Change
+ */
+#define PCH_GBE_INT_ENABLE_MASK ( \
+ PCH_GBE_INT_RX_DMA_CMPLT |    \
+ PCH_GBE_INT_RX_DSC_EMP   |    \
+ PCH_GBE_INT_WOL_DET      |    \
+ PCH_GBE_INT_TX_CMPLT          \
+    )
+
+/* Ethertype field values */
+#define PCH_GBE_MAX_JUMBO_FRAME_SIZE    (10318)
+#define PCH_GBE_FRAME_SIZE_2048         (2048)
+#define PCH_GBE_FRAME_SIZE_4096         (4096)
+#define PCH_GBE_FRAME_SIZE_8192         (8192)
+
+/* watchdog time */
+#define PCH_GBE_WATCHDOG_PERIOD        (1 * HZ)
+
+#define PCH_GBE_TX_WEIGHT         64
+#define PCH_GBE_RX_WEIGHT         64
+#define PCH_GBE_RX_BUFFER_WRITE   16
+
+#define DSC_INIT16  0xC000
+
+/* MAC Address */
+/* Number of high/low register pairs in the MAC_ADR. The MAC_ADR (MAC
Address
+ * Registers) holds the directed and multicast addresses that we monitor.
+ * Technically, we have 16 spots.  However, we reserve one of these spots
+ * (MAC_ADR[15]) for our directed address used by controllers with
+ * manageability enabled, allowing us room for 15 multicast addresses.
+ */
+#define PCH_GBE_MAR_ENTRIES      16
+#define PCH_GBE_SHORT_PKT        64
+
+/* PHY param */
+#define PCH_GBE_PHY_RESET_DELAY_US  10
+/* NVM param */
+#define PCH_GBE_NVM_WORD_SIZE       3 /* 16bit word size */
+
+/* Error Codes */
+#define PCH_GBE_SUCCESS                      0
+#define PCH_GBE_ERR_NVM                      1
+#define PCH_GBE_ERR_PHY                      2
+#define PCH_GBE_ERR_CONFIG                   3
+#define PCH_GBE_ERR_PARAM                    4
+#define PCH_GBE_ERR_MAC_INIT                 5
+#define PCH_GBE_ERR_PHY_TYPE                 6
+#define PCH_GBE_ERR_RESET                    9
+#define PCH_GBE_ERR_MASTER_REQUESTS_PENDING 10
+#define PCH_GBE_ERR_HOST_INTERFACE_COMMAND  11
+#define PCH_GBE_BLK_PHY_RESET               12
+#define PCH_GBE_ERR_SWFW_SYNC               13
+#define PCH_GBE_NOT_IMPLEMENTED             14
+
+#define PHY_MAX_REG_ADDRESS   0x1F /* 5 bit address bus (0-0x1F) */
+/* PHY 1000 MII Register/Bit Definitions */
+/* PHY Registers defined by IEEE */
+#define PHY_CONTROL           0x00  /* Control Register */
+#define PHY_STATUS            0x01  /* Status Regiser */
+#define PHY_ID1               0x02  /* Phy Id Register (word 1) */
+#define PHY_ID2               0x03  /* Phy Id Register (word 2) */
+#define PHY_AUTONEG_ADV       0x04  /* Autoneg Advertisement */
+#define PHY_LP_ABILITY        0x05  /* Link Partner Ability (Base Page) */
+#define PHY_AUTONEG_EXP       0x06  /* Autoneg Expansion Register */
+#define PHY_NEXT_PAGE_TX      0x07  /* Next Page TX */
+#define PHY_LP_NEXT_PAGE      0x08  /* Link Partner Next Page */
+#define PHY_1000T_CTRL        0x09  /* 1000Base-T Control Register */
+#define PHY_1000T_STATUS      0x0A  /* 1000Base-T Status Register */
+#define PHY_EXT_STATUS        0x0F  /* Extended Status Register */
+#define PHY_PHYSP_CONTROL     0x10  /* PHY Specific Control Register */
+#define PHY_EXT_PHYSP_CONTROL 0x14  /* Extended PHY Specific Control
Register */
+#define PHY_LED_CONTROL       0x18  /* LED Control Register */
+#define PHY_EXT_PHYSP_STATUS  0x1B  /* Extended PHY Specific Status
Register */
+
+/* PHY Control Register */
+#define MII_CR_SPEED_SELECT_MSB 0x0040 /* bits 6,13: 10=1000, 01=100, 00=10
*/
+#define MII_CR_COLL_TEST_ENABLE 0x0080 /* Collision test enable */
+#define MII_CR_FULL_DUPLEX      0x0100 /* FDX =1, half duplex =0 */
+#define MII_CR_RESTART_AUTO_NEG 0x0200 /* Restart auto negotiation */
+#define MII_CR_ISOLATE          0x0400 /* Isolate PHY from MII */
+#define MII_CR_POWER_DOWN       0x0800 /* Power down */
+#define MII_CR_AUTO_NEG_EN      0x1000 /* Auto Neg Enable */
+#define MII_CR_SPEED_SELECT_LSB 0x2000 /* bits 6,13: 10=1000, 01=100, 00=10
*/
+#define MII_CR_LOOPBACK         0x4000 /* 0 = normal, 1 = loopback */
+#define MII_CR_RESET            0x8000 /* 0 = normal, 1 = PHY reset */
+#define MII_CR_SPEED_1000       0x0040
+#define MII_CR_SPEED_100        0x2000
+#define MII_CR_SPEED_10         0x0000
+
+/* PHY Status Register */
+#define MII_SR_EXTENDED_CAPS     0x0001 /* Extended register capabilities
*/
+#define MII_SR_JABBER_DETECT     0x0002 /* Jabber Detected */
+#define MII_SR_LINK_STATUS       0x0004 /* Link Status 1 = link */
+#define MII_SR_AUTONEG_CAPS      0x0008 /* Auto Neg Capable */
+#define MII_SR_REMOTE_FAULT      0x0010 /* Remote Fault Detect */
+#define MII_SR_AUTONEG_COMPLETE  0x0020 /* Auto Neg Complete */
+#define MII_SR_PREAMBLE_SUPPRESS 0x0040 /* Preamble may be suppressed */
+#define MII_SR_EXTENDED_STATUS   0x0100 /* Ext. status info in Reg 0x0F */
+#define MII_SR_100T2_HD_CAPS     0x0200 /* 100T2 Half Duplex Capable */
+#define MII_SR_100T2_FD_CAPS     0x0400 /* 100T2 Full Duplex Capable */
+#define MII_SR_10T_HD_CAPS       0x0800 /* 10T   Half Duplex Capable */
+#define MII_SR_10T_FD_CAPS       0x1000 /* 10T   Full Duplex Capable */
+#define MII_SR_100X_HD_CAPS      0x2000 /* 100X  Half Duplex Capable */
+#define MII_SR_100X_FD_CAPS      0x4000 /* 100X  Full Duplex Capable */
+#define MII_SR_100T4_CAPS        0x8000 /* 100T4 Capable */
+
+/* Phy Id Register (word 2) */
+#define PHY_REVISION_MASK        0x000F
+
+/* Autoneg Advertisement Register */
+#define NWAY_AR_SELECTOR_FIELD   0x0001 /* indicates IEEE 802.3 CSMA/CD */
+#define NWAY_AR_10T_HD_CAPS      0x0020 /* 10T   Half Duplex Capable */
+#define NWAY_AR_10T_FD_CAPS      0x0040 /* 10T   Full Duplex Capable */
+#define NWAY_AR_100TX_HD_CAPS    0x0080 /* 100TX Half Duplex Capable */
+#define NWAY_AR_100TX_FD_CAPS    0x0100 /* 100TX Full Duplex Capable */
+#define NWAY_AR_100T4_CAPS       0x0200 /* 100T4 Capable */
+#define NWAY_AR_PAUSE            0x0400 /* Pause operation desired */
+#define NWAY_AR_ASM_DIR          0x0800 /* Asymmetric Pause Direction bit
*/
+#define NWAY_AR_REMOTE_FAULT     0x2000 /* Remote Fault detected */
+#define NWAY_AR_NEXT_PAGE        0x8000 /* Next Page ability supported */
+
+/* Link Partner Ability Register (Base Page) */
+#define NWAY_LPAR_SELECTOR_FIELD 0x0000 /* LP protocol selector field */
+#define NWAY_LPAR_10T_HD_CAPS    0x0020 /* LP is 10T   Half Duplex Capable
*/
+#define NWAY_LPAR_10T_FD_CAPS    0x0040 /* LP is 10T   Full Duplex Capable
*/
+#define NWAY_LPAR_100TX_HD_CAPS  0x0080 /* LP is 100TX Half Duplex Capable
*/
+#define NWAY_LPAR_100TX_FD_CAPS  0x0100 /* LP is 100TX Full Duplex Capable
*/
+#define NWAY_LPAR_100T4_CAPS     0x0200 /* LP is 100T4 Capable */
+#define NWAY_LPAR_PAUSE          0x0400 /* LP Pause operation desired */
+#define NWAY_LPAR_ASM_DIR        0x0800 /* LP Asymmetric Pause Direction
bit */
+#define NWAY_LPAR_REMOTE_FAULT   0x2000 /* LP has detected Remote Fault */
+#define NWAY_LPAR_ACKNOWLEDGE    0x4000 /* LP has rx'd link code word */
+#define NWAY_LPAR_NEXT_PAGE      0x8000 /* Next Page ability supported */
+
+/* Autoneg Expansion Register */
+#define NWAY_ER_LP_NWAY_CAPS      0x0001 /* LP has Auto Neg Capability */
+#define NWAY_ER_PAGE_RXD          0x0002 /* LP is 10T   Half Duplex Capable
*/
+#define NWAY_ER_NEXT_PAGE_CAPS    0x0004 /* LP is 10T   Full Duplex Capable
*/
+#define NWAY_ER_LP_NEXT_PAGE_CAPS 0x0008 /* LP is 100TX Half Duplex Capable
*/
+#define NWAY_ER_PAR_DETECT_FAULT  0x0010 /* LP is 100TX Full Duplex Capable
*/
+
+/* 1000BASE-T Control Register */
+#define CR_1000T_ASYM_PAUSE      0x0080 /* Advertise asymmetric pause bit
*/
+#define CR_1000T_HD_CAPS         0x0100 /* Advertise 1000T HD capability */
+#define CR_1000T_FD_CAPS         0x0200 /* Advertise 1000T FD capability
*/
+#define CR_1000T_REPEATER_DTE    0x0400 /* 1=Repeater/switch device port */
+     /* 0=DTE device */
+#define CR_1000T_MS_VALUE        0x0800 /* 1=Configure PHY as Master */
+     /* 0=Configure PHY as Slave */
+#define CR_1000T_MS_ENABLE       0x1000 /* 1=Master/Slave manual config
value */
+     /* 0=Automatic Master/Slave config */
+#define CR_1000T_TEST_MODE_NORMAL 0x0000 /* Normal Operation */
+#define CR_1000T_TEST_MODE_1      0x2000 /* Transmit Waveform test */
+#define CR_1000T_TEST_MODE_2      0x4000 /* Master Transmit Jitter test */
+#define CR_1000T_TEST_MODE_3      0x6000 /* Slave Transmit Jitter test */
+#define CR_1000T_TEST_MODE_4      0x8000 /* Transmitter Distortion test */
+
+/* 1000BASE-T Status Register */
+#define SR_1000T_IDLE_ERROR_CNT   0x00FF /* Num idle errors since last read
*/
+#define SR_1000T_ASYM_PAUSE_DIR   0x0100 /* LP asymmetric pause direction
bit */
+#define SR_1000T_LP_HD_CAPS       0x0400 /* LP is 1000T HD capable */
+#define SR_1000T_LP_FD_CAPS       0x0800 /* LP is 1000T FD capable */
+#define SR_1000T_REMOTE_RX_STATUS 0x1000 /* Remote receiver OK */
+#define SR_1000T_LOCAL_RX_STATUS  0x2000 /* Local receiver OK */
+#define SR_1000T_MS_CONFIG_RES    0x4000 /* 1=Local TX is Master, 0=Slave
*/
+#define SR_1000T_MS_CONFIG_FAULT  0x8000 /* Master/Slave config fault */
+
+/* PHY Specific Control Register */
+#define PHYSP_CTRL_ASSERT_CRS_TX  0x0800
+
+/* LED Control Register */
+#define PHY_LED_CTRL_ON           0x4103
+#define PHY_LED_CTRL_OFF          0x4102
+#define PHY_LED_CTRL_CLEANUP      0x4100
+
+/* Extended PHY Specific Status Register */
+#define HWCFG_MODE_GMII_COPPER    0x000F /* GMII to Copper */
+#define HWCFG_MODE_RGMII_COPPER   0x000B /* RGMII/Modiffied MII to Copper
*/
+#define HWCFG_MODE_GMII_FIBER     0x0007 /* GMII to Fiber */
+#define HWCFG_MODE_RGMII_FIBER    0x0003 /* RGMII to Fiber */
+#define HWCFG_MODE_GMII_SGMII     0x000E /* GMII to SGMII */
+#define HWCFG_MODE_RGMII_SGMII    0x0006 /* RGMII to SGMII */
+#define HWCFG_MODE_TBI_COPPER     0x000D /* TBI to Copper */
+#define HWCFG_MODE_RTBI_COPPER    0x0009 /* RTBI to Copper */
+#define HWCFG_MODE_MASK           0x000F
+
+#define PHY_SPEED_10    10
+#define PHY_SPEED_100   100
+#define PHY_SPEED_1000  1000
+#define PHY_HALF_DUPLEX 1
+#define PHY_FULL_DUPLEX 2
+
+#define PHY_ADVERTISE_10_HALF      0x0001
+#define PHY_ADVERTISE_10_FULL      0x0002
+#define PHY_ADVERTISE_100_HALF     0x0004
+#define PHY_ADVERTISE_100_FULL     0x0008
+#define PHY_ADVERTISE_1000_HALF    0x0010 /* Not used, just FYI */
+#define PHY_ADVERTISE_1000_FULL    0x0020
+
+/* 1000/H is not supported, nor spec-compliant. */
+#define PCH_GBE_ALL_SPEED_DUPLEX (PHY_ADVERTISE_10_HALF  | \
+      PHY_ADVERTISE_10_FULL  | \
+      PHY_ADVERTISE_100_HALF | \
+      PHY_ADVERTISE_100_FULL | \
+      PHY_ADVERTISE_1000_FULL)
+#define PCH_GBE_ALL_NOT_GIG  (PHY_ADVERTISE_10_HALF  | \
+      PHY_ADVERTISE_10_FULL  | \
+      PHY_ADVERTISE_100_HALF | \
+      PHY_ADVERTISE_100_FULL)
+#define PCH_GBE_ALL_100_SPEED  (PHY_ADVERTISE_100_HALF | \
+      PHY_ADVERTISE_100_FULL)
+#define PCH_GBE_ALL_10_SPEED  (PHY_ADVERTISE_10_HALF  | \
+      PHY_ADVERTISE_10_FULL)
+#define PCH_GBE_ALL_FULL_DUPLEX  (PHY_ADVERTISE_10_FULL  | \
+      PHY_ADVERTISE_100_FULL | \
+      PHY_ADVERTISE_1000_FULL)
+#define PCH_GBE_ALL_HALF_DUPLEX  (PHY_ADVERTISE_10_HALF  | \
+      PHY_ADVERTISE_100_HALF)
+
+#define AUTONEG_ADVERTISE_SPEED_DEFAULT   PCH_GBE_ALL_SPEED_DUPLEX
+
+#endif
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe.h
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe.h
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe.h 2010-04-13
18:13:03.000000000 +0900
@@ -0,0 +1,228 @@
+/*!
+ * @file pch_gbe.h
+ * @brief Linux PCH Gigabit Ethernet Driver main header file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+
+#ifndef _PCH_GBE_H_
+#define _PCH_GBE_H_
+
+struct pch_gbe_adapter;
+
+#define PFX "pch_gbe: "
+#define DPRINTK(nlevel, klevel, fmt, args...) \
+ do { \
+  if (NETIF_MSG_##nlevel & adapter->msg_enable) \
+   printk(KERN_##klevel PFX "%s: %s: " fmt, \
+    adapter->netdev->name, __func__ , ## args); \
+ } while (0)
+
+/* only works for sizes that are powers of 2 */
+#define PCH_GBE_ROUNDUP(i, size) ((i) = (((i) + (size) - 1) & ~((size) -
1)))
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_buffer
+ * @brief   Buffer infomation
+ * @remarks
+ *  wrapper around a pointer to a socket buffer,
+ *  so a DMA handle can be stored along with the buffer
+ */
+struct pch_gbe_buffer {
+ struct sk_buff *skb;     /**< pointer to a socket buffer  */
+ struct sk_buff *kernel_skb;
+  /**< pointer to a socket buffer received from the kernel */
+ dma_addr_t dma;      /**< DMA address  */
+ unsigned long time_stamp;   /**< time stamp  */
+ u16 length;      /**< data size  */
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_tx_ring
+ * @brief   tx ring infomation
+ */
+struct pch_gbe_tx_ring {
+ void *desc;  /**< pointer to the descriptor ring memory  */
+ dma_addr_t dma;  /**< physical address of the descriptor ring  */
+ unsigned int size; /**< length of descriptor ring in bytes  */
+ unsigned int count; /**< number of descriptors in the ring  */
+ unsigned int next_to_use;
+   /**< next descriptor to associate a buffer with  */
+ unsigned int next_to_clean;
+   /**< next descriptor to check for DD status bit  */
+ struct pch_gbe_buffer *buffer_info;
+   /**< array of buffer information structs  */
+ spinlock_t tx_lock; /**< spinlock structs  */
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_rx_ring
+ * @brief   rx ring infomation
+ */
+struct pch_gbe_rx_ring {
+ void *desc;  /**< pointer to the descriptor ring memory  */
+ dma_addr_t dma;  /**< physical address of the descriptor ring  */
+ unsigned int size; /**< length of descriptor ring in bytes  */
+ unsigned int count; /**< number of descriptors in the ring  */
+ unsigned int next_to_use;
+   /**< next descriptor to associate a buffer with  */
+ unsigned int next_to_clean;
+   /**< next descriptor to check for DD status bit  */
+ struct pch_gbe_buffer *buffer_info;
+   /**< array of buffer information structs  */
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_hw_stats
+ * @brief   Statistics counters collected by the MAC
+ */
+struct pch_gbe_hw_stats {
+ u64 rx_packets;      /**< total packets received  */
+ u64 tx_packets;      /**< total packets transmitted  */
+ u64 rx_bytes;      /**< total bytes received  */
+ u64 tx_bytes;      /**< total bytes transmitted  */
+ u64 rx_errors;      /**< bad packets received  */
+ u64 tx_errors;      /**< packet transmit problems  */
+ u64 rx_dropped;      /**< no space in Linux buffers  */
+ u64 tx_dropped;      /**< no space available in Linux  */
+ u64 multicast;      /**< multicast packets received  */
+ u64 collisions;      /**< collisions */
+ u64 rx_crc_errors;     /**< received packet with crc error  */
+ u64 rx_frame_errors;     /**< received frame alignment error  */
+ u64 rx_alloc_buff_failed;   /**< allocate failure of a receive buffer */
+ u64 tx_length_errors;     /**< transmit length error  */
+ u64 tx_aborted_errors;     /**< transmit aborted error  */
+ u64 tx_carrier_errors;     /**< transmit carrier error  */
+ u64 tx_timeout_count;     /**< Number of transmit timeout  */
+ u64 tx_restart_count;     /**< Number of transmit restert  */
+ u64 intr_rx_dsc_empty_count;
+   /**< Interrupt count of receive descriptor empty  */
+ u64 intr_rx_frame_err_count;
+   /**< Interrupt count of receive frame error  */
+ u64 intr_rx_fifo_err_count;
+   /**< Interrupt count of receive FIFO error  */
+ u64 intr_rx_dma_err_count;
+   /**< Interrupt count of receive DMA error  */
+ u64 intr_tx_fifo_err_count;
+   /**< Interrupt count of transmit FIFO error  */
+ u64 intr_tx_dma_err_count;
+   /**< Interrupt count of transmit DMA error  */
+ u64 intr_tcpip_err_count;
+   /**< Interrupt count of TCP/IP Accelerator  */
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_adapter
+ * @brief   board specific private data structure
+ */
+struct pch_gbe_adapter {
+ /* OS defined structs */
+ struct net_device *netdev;  /**<  Pointer of network device structure */
+ struct pci_dev *pdev;     /**<  Pointer of pci device structure */
+ struct net_device_stats net_stats; /**<  Network status */
+ struct net_device *polling_netdev;
+   /**<  Pointer of polling network device structure */
+ struct napi_struct napi; /**<  NAPI structure */
+
+ /* structs defined in pch_gbe_hw.h */
+ struct pch_gbe_hw hw;  /**<  Pointer of hardware structure */
+ struct pch_gbe_hw_stats stats; /**<  Hardware status */
+ struct work_struct reset_task; /**<  Reset task */
+ struct mii_if_info mii;  /**<  MII information structure */
+ struct timer_list watchdog_timer; /**<  Watchdog timer list */
+
+ u32 bd_number;  /**<  The number of the found NIC cards */
+ u32 wake_up_evt; /**<  Wake up event */
+ u32 *config_space; /**<  Configuration space */
+ int msg_enable;  /**<  Driver message level */
+
+ spinlock_t stats_lock;     /**<  Spinlock structure for status */
+ spinlock_t tx_queue_lock;   /**<  Spinlock structure for transmit */
+ spinlock_t int_en_lock;     /**<  Spinlock structure for IRQ enable */
+ atomic_t irq_sem;     /**<  Semaphore for interrupt */
+
+ struct timer_list blink_timer; /**<  LED blink timer list */
+ unsigned long led_status; /**<  LED status */
+
+ /* TX,RX */
+ struct pch_gbe_tx_ring *tx_ring;
+  /**<  Pointer of Tx descriptor ring structure  */
+ struct pch_gbe_rx_ring *rx_ring;
+  /**<  Pointer of Rx descriptor ring structure */
+ unsigned long rx_buffer_len; /**<  Receive buffer length */
+ unsigned long tx_queue_len; /**<  Transmit queue length */
+
+ unsigned char rx_csum;
+  /**<  Receive TCP/IP checksum enable/disable */
+ unsigned char tx_csum;
+  /**<  Transmit TCP/IP checksum enable/disable */
+
+ unsigned char have_msi;  /**<  PCI MSI mode flag */
+
+ /* to not mess up cache alignment, always add to the bottom */
+ unsigned long flags;  /**<  Driver status flag */
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @def  pch_gbe_state_t
+ * @brief   Driver Status
+ */
+enum pch_gbe_state_t {
+ __PCH_GBE_TESTING,    /**<  Testing  */
+ __PCH_GBE_RESETTING,    /**<  Reseting */
+};
+
+/* pch_gbe_main.c */
+int pch_gbe_up(struct pch_gbe_adapter *adapter);
+void pch_gbe_down(struct pch_gbe_adapter *adapter);
+void pch_gbe_reinit_locked(struct pch_gbe_adapter *adapter);
+void pch_gbe_reset(struct pch_gbe_adapter *adapter);
+int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_tx_ring *txdr);
+int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_rx_ring *rxdr);
+void pch_gbe_free_tx_resources(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_tx_ring *tx_ring);
+void pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
+    struct pch_gbe_rx_ring *rx_ring);
+void pch_gbe_update_stats(struct pch_gbe_adapter *adapter);
+int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg);
+void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg, int
data);
+/* pch_gbe_param.c */
+void pch_gbe_check_options(struct pch_gbe_adapter *adapter);
+
+/* pch_gbe_ethtool.c */
+void pch_gbe_set_ethtool_ops(struct net_device *netdev);
+
+
+#endif /* _PCH_GBE_H_ */
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_hw.h
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_hw.h
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_hw.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_hw.h 2010-04-13
19:25:36.000000000 +0900
@@ -0,0 +1,258 @@
+/*!
+ * @file pch_gbe_hw.h
+ * @brief Linux PCH Gigabit Ethernet Driver Hardware layer header file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+#ifndef _PCH_GBE_HW_H_
+#define _PCH_GBE_HW_H_
+
+struct pch_gbe_hw;
+
+/* mac type values */
+#define PCH_GBE_MAC_TYPE_UNDEFINED 0
+#define PCH_GBE_MAC_TYPE_PCH1  1
+#define PCH_GBE_MAC_TYPE_PCH2  2
+
+/* bus type values */
+#define pch_gbe_bus_type_unknown 0
+#define pch_gbe_bus_type_pci  1
+#define pch_gbe_bus_type_pcix  2
+#define pch_gbe_bus_type_pci_express 3
+#define pch_gbe_bus_type_reserved 4
+
+/* bus speed values */
+#define pch_gbe_bus_speed_unknown 0
+#define pch_gbe_bus_speed_33  1
+#define pch_gbe_bus_speed_66  2
+#define pch_gbe_bus_speed_100  3
+#define pch_gbe_bus_speed_120  4
+#define pch_gbe_bus_speed_133  5
+#define pch_gbe_bus_speed_2500  6
+#define pch_gbe_bus_speed_reserved 7
+
+/* bus width values */
+#define pch_gbe_bus_width_unknown 0
+#define pch_gbe_bus_width_pcie_x1 1
+#define pch_gbe_bus_width_pcie_x2 2
+#define pch_gbe_bus_width_pcie_x4 4
+#define pch_gbe_bus_width_32  5
+#define pch_gbe_bus_width_64  6
+#define pch_gbe_bus_width_reserved 7
+
+/* flow control values */
+#define pch_gbe_fc_none   0
+#define pch_gbe_fc_rx_pause  1
+#define pch_gbe_fc_tx_pause  2
+#define pch_gbe_fc_full   3
+
+#define PCH_GBE_FC_DEFAULT  pch_gbe_fc_full
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_rx_desc
+ * @brief   Receive Descriptor
+ */
+struct pch_gbe_rx_desc {
+ u32 buffer_addr; /** RX Frame Buffer Address */
+ u32 tcp_ip_status; /** TCP/IP Accelerator Status */
+ u16 rx_words_eob; /** RX word count and Byte position */
+ u16 gbec_status; /** GMAC Status */
+ u8 dma_status;  /** DMA Status */
+ u8 reserved1;  /** Reserved */
+ u16 reserved2;  /** Reserved */
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_tx_desc
+ * @brief   Transmit Descriptor
+ */
+struct pch_gbe_tx_desc {
+ u32 buffer_addr; /** TX Frame Buffer Address */
+ u16 length;  /** Data buffer length */
+ u16 reserved1;  /** Reserved */
+ u16 tx_words_eob; /** TX word count and Byte position */
+ u16 tx_frame_ctrl; /** TX Frame Control */
+ u8 dma_status;  /** DMA Status */
+ u8 reserved2;  /** Reserved */
+ u16 gbec_status; /** GMAC Status */
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_functions
+ * @brief   HAL APi function pointer
+ */
+struct pch_gbe_functions {
+ /* Function pointers for the MAC. */
+ s32(*cleanup_led) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_cleanup_led */
+
+ void (*get_bus_info) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_get_bus_info */
+
+ s32(*led_on) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_led_on */
+
+ s32(*led_off) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_led_off */
+
+ void (*mc_addr_list_update) (struct pch_gbe_hw *, u8 *, u32, u32, u32);
+  /** for pch_gbe_hal_mc_addr_list_update */
+
+ void (*reset_hw) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_reset_hw */
+
+ s32(*init_hw) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_init_hw */
+
+ s32(*setup_link) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_setup_link */
+
+ s32(*setup_physical_interface) (struct pch_gbe_hw *);
+  /** for setup link of PHY */
+
+ s32(*setup_led) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_setup_led */
+
+ void (*pause_packet) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_set_pause_packet */
+
+ /* Function pointers for the PHY. */
+ s32(*read_phy_reg) (struct pch_gbe_hw *, u32, u16 *);
+  /** for pch_gbe_hal_read_phy_reg */
+
+ s32(*write_phy_reg) (struct pch_gbe_hw *, u32, u16);
+  /** for pch_gbe_hal_write_phy_reg */
+
+ void (*reset_phy) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_phy_hw_reset */
+
+ void (*sw_reset_phy) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_phy_sw_reset */
+
+ void (*power_up_phy) (struct pch_gbe_hw *hw);
+  /** for pch_gbe_hal_power_up_phy */
+
+ void (*power_down_phy) (struct pch_gbe_hw *hw);
+  /** for pch_gbe_hal_power_down_phy */
+#ifdef CONFIG_PCH_PHUB
+ /* Function pointers for the NVM. */
+ s32(*validate_nvm) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_validate_nvm_checksum */
+
+ s32(*read_nvm) (struct pch_gbe_hw *, u32, u8 *);
+  /** for pch_gbe_hal_read_nvm */
+
+ s32(*write_nvm) (struct pch_gbe_hw *, u32, u8 *);
+  /** for pch_gbe_hal_write_nvm */
+#endif
+ s32(*read_mac_addr) (struct pch_gbe_hw *);
+  /** for pch_gbe_hal_read_mac_addr */
+
+ u16(*ctrl_miim) (struct pch_gbe_hw *, u32, u32, u32, u16);
+  /** for pch_gbe_hal_ctrl_miim */
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_mac_info
+ * @brief   MAC infomation
+ */
+struct pch_gbe_mac_info {
+ u8 addr[6];  /** Store the MAC address */
+ u8 type;  /** Type of MAC */
+ u8 fc;   /** Mode of flow control */
+ u8 fc_autoneg;   /** Auto negotiation enable for flow control setting */
+ u8 tx_fc_enable; /** Enable flag of Transmit flow control */
+ u32 max_frame_size; /** Max transmit frame size */
+ u32 min_frame_size; /** Min transmit frame size */
+ u16 mar_entry_count; /** Entry count of MAC address registers */
+ u8 autoneg; /** Auto negotiation enable */
+ u16 link_speed;  /** Link speed */
+ u16 link_duplex; /** Link duplex */
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_phy_info
+ * @brief   PHY infomation
+ */
+struct pch_gbe_phy_info {
+ u32 addr;  /** PHY address */
+ u32 id;   /** PHY's identifier */
+ u32 revision;  /** PHY's revision */
+ u32 reset_delay_us; /** HW reset delay time[us] */
+ u16 autoneg_advertised; /** Autoneg advertised */
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_nvm_info
+ * @brief   NVM infomation
+ */
+struct pch_gbe_nvm_info {
+ u16 word_size;
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_bus_info
+ * @brief   Bus infomation
+ */
+struct pch_gbe_bus_info {
+ u8 type;
+ u8 speed;
+ u8 width;
+};
+
+/*!
+ * @ingroup Gigabit Ether driver Layer
+ * @struct  pch_gbe_hw
+ * @brief   Hardware infomation
+ */
+struct pch_gbe_hw {
+ void *back;
+
+ u8 *hw_addr;
+ spinlock_t miim_lock;
+
+ struct pch_gbe_functions func;
+ struct pch_gbe_mac_info mac;
+ struct pch_gbe_phy_info phy;
+ struct pch_gbe_nvm_info nvm;
+ struct pch_gbe_bus_info bus;
+
+ u16 vendor_id;
+ u16 device_id;
+ u16 subsystem_vendor_id;
+ u16 subsystem_device_id;
+ u8 revision_id;
+};
+
+#endif
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_osdep.h
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_osdep.h
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_osdep.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_osdep.h 2010-04-13
18:17:05.000000000 +0900
@@ -0,0 +1,74 @@
+/*!
+ * @file pch_gbe_osdep.h
+ * @brief Linux PCH Gigabit Ethernet Driver OS independent header file
+ *
+ *        glue for the OS independent part of pch
+ *        includes register access macros
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+#ifndef _PCH_GBE_OSDEP_H_
+#define _PCH_GBE_OSDEP_H_
+
+#include <linux/delay.h>
+#include <linux/io.h>
+
+#define usec_delay(x) udelay(x)
+#ifndef msec_delay
+#define msec_delay(x) \
+  do {if (in_interrupt()) { \
+   /* Don't mdelay in interrupt context! */ \
+   BUG(); \
+  } else { \
+   msleep(x); \
+  } } while (0)
+
+/* Some workarounds require millisecond delays and are run during interrupt
+ * context.  Most notably, when establishing link, the phy may need
tweaking
+ * but cannot process phy register reads/writes faster than millisecond
+ * intervals...and we establish link due to a "link status change"
interrupt.
+ */
+#define msec_delay_irq(x) mdelay(x)
+#endif
+
+#undef FALSE
+#define FALSE 0
+#undef TRUE
+#define TRUE 1
+
+
+#define PCH_GBE_WRITE_REG(a, reg, value) ( \
+  writel((value), ((a)->hw_addr + PCH_GBE_##reg)))
+
+#define PCH_GBE_READ_REG(a, reg) ( \
+  readl((a)->hw_addr + PCH_GBE_##reg))
+
+#define PCH_GBE_WRITE_REG_ARRAY(a, reg, offset, value) ( \
+  writel((value), \
+  ((a)->hw_addr + PCH_GBE_##reg + ((offset) << 2))))
+
+#endif /* _PCH_GBE_OSDEP_H_ */
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_pci_ids.h
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_pci_ids.h
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_pci_ids.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_pci_ids.h 2010-04-13
18:18:44.000000000 +0900
@@ -0,0 +1,37 @@
+/*!
+ * @file pch_gbe_pci_ids.h
+ * @brief Linux PCH Gigabit Ethernet Driver PCI ID header file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+#ifndef _PCH_GBE_PCI_IDS_H_
+#define _PCH_GBE_PCI_IDS_H_
+
+/* Pci vender/device ID */
+#define PCI_DEVICE_ID_INTEL_IOH1_GBE    (u16)(0x8802)
+
+#endif
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_regs.h
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_regs.h
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_regs.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_regs.h 2010-04-13
18:18:34.000000000 +0900
@@ -0,0 +1,350 @@
+/*!
+ * @file pch_gbe_regs.h
+ * @brief Linux PCH Gigabit Ethernet Driver register macro header file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify

