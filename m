From: Martin Wetterwald <martin@wetterwald.eu>
Subject: [PATCH v2] smsc95xx: Add comments to the registers definition
Date: Mon, 10 Apr 2017 11:32:34 +0200
Message-ID: <20170410093234.il2pszgyqtukuxv7@SMX-2>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcorrecteurs.net ([94.23.204.81]:57643 "EHLO zcorrecteurs.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752348AbdDJJc5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 05:32:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This chip is used by a lot of embedded devices and also by the Raspberry
Pi 1, 2 & 3 which were created to promote the study of computer
sciences. Students wanting to learn kernel / network device driver
programming through those devices can only rely on the Linux kernel
driver source to make their own.

This commit adds a lot of comments to the registers definition to expand
the register names.

Cc: Steve Glendinning <steve.glendinning@shawell.net>
Cc: Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
CC: David Miller <davem@davemloft.net>
Signed-off-by: Martin Wetterwald <martin@wetterwald.eu>
---
Changes in v2:
 * Correct David's email address (replace org by net)
 * Remove duplicate register definition (INT_ENP_TX_STOP_)

 drivers/net/usb/smsc95xx.c |   6 +-
 drivers/net/usb/smsc95xx.h | 473 ++++++++++++++++++++++++++-------------------
 2 files changed, 272 insertions(+), 207 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 831aa33..52d71a8 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -33,7 +33,7 @@
 #include "smsc95xx.h"
 
 #define SMSC_CHIPNAME			"smsc95xx"
-#define SMSC_DRIVER_VERSION		"1.0.5"
+#define SMSC_DRIVER_VERSION		"1.0.6"
 #define HS_USB_PKT_SIZE			(512)
 #define FS_USB_PKT_SIZE			(64)
 #define DEFAULT_HS_BURST_CAP_SIZE	(16 * 1024 + 5 * HS_USB_PKT_SIZE)
@@ -1498,7 +1498,7 @@ static int smsc95xx_enter_suspend3(struct usbnet *dev)
 	if (ret < 0)
 		return ret;
 
-	if (val & 0xFFFF) {
+	if (val & RX_FIFO_INF_USED_) {
 		netdev_info(dev->net, "rx fifo not empty in autosuspend\n");
 		return -EBUSY;
 	}
@@ -2032,7 +2032,7 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
 	skb_push(skb, 4);
 	tx_cmd_b = (u32)(skb->len - 4);
 	if (csum)
-		tx_cmd_b |= TX_CMD_B_CSUM_ENABLE;
+		tx_cmd_b |= TX_CMD_B_CSUM_EN;
 	cpu_to_le32s(&tx_cmd_b);
 	memcpy(skb->data, &tx_cmd_b, 4);
 
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index 29a4d9e..6c8acf1 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -21,128 +21,158 @@
 #define _SMSC95XX_H
 
 /* Tx command words */
-#define TX_CMD_A_DATA_OFFSET_		(0x001F0000)
-#define TX_CMD_A_FIRST_SEG_		(0x00002000)
-#define TX_CMD_A_LAST_SEG_		(0x00001000)
-#define TX_CMD_A_BUF_SIZE_		(0x000007FF)
+#define TX_CMD_A_DATA_OFFSET_	(0x001F0000)	/* Data Start Offset */
+#define TX_CMD_A_FIRST_SEG_	(0x00002000)	/* First Segment */
+#define TX_CMD_A_LAST_SEG_	(0x00001000)	/* Last Segment */
+#define TX_CMD_A_BUF_SIZE_	(0x000007FF)	/* Buffer Size */
 
-#define TX_CMD_B_CSUM_ENABLE		(0x00004000)
-#define TX_CMD_B_ADD_CRC_DISABLE_	(0x00002000)
-#define TX_CMD_B_DISABLE_PADDING_	(0x00001000)
-#define TX_CMD_B_PKT_BYTE_LENGTH_	(0x000007FF)
+#define TX_CMD_B_CSUM_EN	(0x00004000)	/* TX Checksum Enable */
+#define TX_CMD_B_ADD_CRC_DIS_	(0x00002000)	/* Add CRC Disable */
+#define TX_CMD_B_DIS_PADDING_	(0x00001000)	/* Disable Frame Padding */
+#define TX_CMD_B_FRAME_LENGTH_	(0x000007FF)	/* Frame Length (bytes) */
 
 /* Rx status word */
-#define RX_STS_FF_			(0x40000000)	/* Filter Fail */
-#define RX_STS_FL_			(0x3FFF0000)	/* Frame Length */
-#define RX_STS_ES_			(0x00008000)	/* Error Summary */
-#define RX_STS_BF_			(0x00002000)	/* Broadcast Frame */
-#define RX_STS_LE_			(0x00001000)	/* Length Error */
-#define RX_STS_RF_			(0x00000800)	/* Runt Frame */
-#define RX_STS_MF_			(0x00000400)	/* Multicast Frame */
-#define RX_STS_TL_			(0x00000080)	/* Frame too long */
-#define RX_STS_CS_			(0x00000040)	/* Collision Seen */
-#define RX_STS_FT_			(0x00000020)	/* Frame Type */
-#define RX_STS_RW_			(0x00000010)	/* Receive Watchdog */
-#define RX_STS_ME_			(0x00000008)	/* Mii Error */
-#define RX_STS_DB_			(0x00000004)	/* Dribbling */
-#define RX_STS_CRC_			(0x00000002)	/* CRC Error */
-
-/* SCSRs */
-#define ID_REV				(0x00)
-#define ID_REV_CHIP_ID_MASK_		(0xFFFF0000)
-#define ID_REV_CHIP_REV_MASK_		(0x0000FFFF)
-#define ID_REV_CHIP_ID_9500_		(0x9500)
-#define ID_REV_CHIP_ID_9500A_		(0x9E00)
-#define ID_REV_CHIP_ID_9512_		(0xEC00)
-#define ID_REV_CHIP_ID_9530_		(0x9530)
-#define ID_REV_CHIP_ID_89530_		(0x9E08)
-#define ID_REV_CHIP_ID_9730_		(0x9730)
-
-#define INT_STS				(0x08)
-#define INT_STS_TX_STOP_		(0x00020000)
-#define INT_STS_RX_STOP_		(0x00010000)
-#define INT_STS_PHY_INT_		(0x00008000)
-#define INT_STS_TXE_			(0x00004000)
-#define INT_STS_TDFU_			(0x00002000)
-#define INT_STS_TDFO_			(0x00001000)
-#define INT_STS_RXDF_			(0x00000800)
-#define INT_STS_GPIOS_			(0x000007FF)
-#define INT_STS_CLEAR_ALL_		(0xFFFFFFFF)
-
-#define RX_CFG				(0x0C)
-#define RX_FIFO_FLUSH_			(0x00000001)
-
-#define TX_CFG				(0x10)
-#define TX_CFG_ON_			(0x00000004)
-#define TX_CFG_STOP_			(0x00000002)
-#define TX_CFG_FIFO_FLUSH_		(0x00000001)
-
-#define HW_CFG				(0x14)
-#define HW_CFG_BIR_			(0x00001000)
-#define HW_CFG_LEDB_			(0x00000800)
-#define HW_CFG_RXDOFF_			(0x00000600)
-#define HW_CFG_DRP_			(0x00000040)
-#define HW_CFG_MEF_			(0x00000020)
-#define HW_CFG_LRST_			(0x00000008)
-#define HW_CFG_PSEL_			(0x00000004)
-#define HW_CFG_BCE_			(0x00000002)
-#define HW_CFG_SRST_			(0x00000001)
-
-#define RX_FIFO_INF			(0x18)
-
-#define PM_CTRL				(0x20)
-#define PM_CTL_RES_CLR_WKP_STS		(0x00000200)
-#define PM_CTL_DEV_RDY_			(0x00000080)
-#define PM_CTL_SUS_MODE_		(0x00000060)
-#define PM_CTL_SUS_MODE_0		(0x00000000)
-#define PM_CTL_SUS_MODE_1		(0x00000020)
-#define PM_CTL_SUS_MODE_2		(0x00000040)
-#define PM_CTL_SUS_MODE_3		(0x00000060)
-#define PM_CTL_PHY_RST_			(0x00000010)
-#define PM_CTL_WOL_EN_			(0x00000008)
-#define PM_CTL_ED_EN_			(0x00000004)
-#define PM_CTL_WUPS_			(0x00000003)
-#define PM_CTL_WUPS_NO_			(0x00000000)
-#define PM_CTL_WUPS_ED_			(0x00000001)
-#define PM_CTL_WUPS_WOL_		(0x00000002)
-#define PM_CTL_WUPS_MULTI_		(0x00000003)
-
-#define LED_GPIO_CFG			(0x24)
-#define LED_GPIO_CFG_SPD_LED		(0x01000000)
-#define LED_GPIO_CFG_LNK_LED		(0x00100000)
-#define LED_GPIO_CFG_FDX_LED		(0x00010000)
-
-#define GPIO_CFG			(0x28)
-
-#define AFC_CFG				(0x2C)
-
+#define RX_STS_FF_		(0x40000000)	/* Filter Fail */
+#define RX_STS_FL_		(0x3FFF0000)	/* Frame Length */
+#define RX_STS_ES_		(0x00008000)	/* Error Summary */
+#define RX_STS_BF_		(0x00002000)	/* Broadcast Frame */
+#define RX_STS_LE_		(0x00001000)	/* Length Error */
+#define RX_STS_RF_		(0x00000800)	/* Runt Frame */
+#define RX_STS_MF_		(0x00000400)	/* Multicast Frame */
+#define RX_STS_TL_		(0x00000080)	/* Frame too long */
+#define RX_STS_CS_		(0x00000040)	/* Collision Seen */
+#define RX_STS_FT_		(0x00000020)	/* Frame Type */
+#define RX_STS_RW_		(0x00000010)	/* Receive Watchdog */
+#define RX_STS_ME_		(0x00000008)	/* MII Error */
+#define RX_STS_DB_		(0x00000004)	/* Dribbling */
+#define RX_STS_CRC_		(0x00000002)	/* CRC Error */
+
+/* SCSRs - System Control and Status Registers */
+/* Device ID and Revision Register */
+#define ID_REV			(0x00)
+#define ID_REV_CHIP_ID_MASK_	(0xFFFF0000)
+#define ID_REV_CHIP_REV_MASK_	(0x0000FFFF)
+#define ID_REV_CHIP_ID_9500_	(0x9500)
+#define ID_REV_CHIP_ID_9500A_	(0x9E00)
+#define ID_REV_CHIP_ID_9512_	(0xEC00)
+#define ID_REV_CHIP_ID_9530_	(0x9530)
+#define ID_REV_CHIP_ID_89530_	(0x9E08)
+#define ID_REV_CHIP_ID_9730_	(0x9730)
+
+/* Interrupt Status Register */
+#define INT_STS			(0x08)
+#define INT_STS_MAC_RTO_	(0x00040000)	/* MAC Reset Time Out */
+#define INT_STS_TX_STOP_	(0x00020000)	/* TX Stopped */
+#define INT_STS_RX_STOP_	(0x00010000)	/* RX Stopped */
+#define INT_STS_PHY_INT_	(0x00008000)	/* PHY Interrupt */
+#define INT_STS_TXE_		(0x00004000)	/* Transmitter Error */
+#define INT_STS_TDFU_		(0x00002000)	/* TX Data FIFO Underrun */
+#define INT_STS_TDFO_		(0x00001000)	/* TX Data FIFO Overrun */
+#define INT_STS_RXDF_		(0x00000800)	/* RX Dropped Frame */
+#define INT_STS_GPIOS_		(0x000007FF)	/* GPIOs Interrupts */
+#define INT_STS_CLEAR_ALL_	(0xFFFFFFFF)
+
+/* Receive Configuration Register */
+#define RX_CFG			(0x0C)
+#define RX_FIFO_FLUSH_		(0x00000001)	/* Receive FIFO Flush */
+
+/* Transmit Configuration Register */
+#define TX_CFG			(0x10)
+#define TX_CFG_ON_		(0x00000004)	/* Transmitter Enable */
+#define TX_CFG_STOP_		(0x00000002)	/* Stop Transmitter */
+#define TX_CFG_FIFO_FLUSH_	(0x00000001)	/* Transmit FIFO Flush */
+
+/* Hardware Configuration Register */
+#define HW_CFG			(0x14)
+#define HW_CFG_BIR_		(0x00001000)	/* Bulk In Empty Response */
+#define HW_CFG_LEDB_		(0x00000800)	/* Activity LED 80ms Bypass */
+#define HW_CFG_RXDOFF_		(0x00000600)	/* RX Data Offset */
+#define HW_CFG_SBP_		(0x00000100)	/* Stall Bulk Out Pipe Dis. */
+#define HW_CFG_IME_		(0x00000080)	/* Internal MII Visi. Enable */
+#define HW_CFG_DRP_		(0x00000040)	/* Discard Errored RX Frame */
+#define HW_CFG_MEF_		(0x00000020)	/* Mult. ETH Frames/USB pkt */
+#define HW_CFG_ETC_		(0x00000010)	/* EEPROM Timeout Control */
+#define HW_CFG_LRST_		(0x00000008)	/* Soft Lite Reset */
+#define HW_CFG_PSEL_		(0x00000004)
+#define HW_CFG_BCE_		(0x00000002)	/* Burst Cap Enable */
+#define HW_CFG_SRST_		(0x00000001)	/* Soft Reset */
+
+/* Receive FIFO Information Register */
+#define RX_FIFO_INF		(0x18)
+#define RX_FIFO_INF_USED_	(0x0000FFFF)	/* RX Data FIFO Used Space */
+
+/* Transmit FIFO Information Register */
+#define TX_FIFO_INF		(0x1C)
+#define TX_FIFO_INF_FREE_	(0x0000FFFF)	/* TX Data FIFO Free Space */
+
+/* Power Management Control Register */
+#define PM_CTRL			(0x20)
+#define PM_CTL_RES_CLR_WKP_STS	(0x00000200)	/* Resume Clears Wakeup STS */
+#define PM_CTL_RES_CLR_WKP_EN	(0x00000100)	/* Resume Clears Wkp Enables */
+#define PM_CTL_DEV_RDY_		(0x00000080)	/* Device Ready */
+#define PM_CTL_SUS_MODE_	(0x00000060)	/* Suspend Mode */
+#define PM_CTL_SUS_MODE_0	(0x00000000)
+#define PM_CTL_SUS_MODE_1	(0x00000020)
+#define PM_CTL_SUS_MODE_2	(0x00000040)
+#define PM_CTL_SUS_MODE_3	(0x00000060)
+#define PM_CTL_PHY_RST_		(0x00000010)	/* PHY Reset */
+#define PM_CTL_WOL_EN_		(0x00000008)	/* Wake On Lan Enable */
+#define PM_CTL_ED_EN_		(0x00000004)	/* Energy Detect Enable */
+#define PM_CTL_WUPS_		(0x00000003)	/* Wake Up Status */
+#define PM_CTL_WUPS_NO_		(0x00000000)	/* No Wake Up Event Detected */
+#define PM_CTL_WUPS_ED_		(0x00000001)	/* Energy Detect */
+#define PM_CTL_WUPS_WOL_	(0x00000002)	/* Wake On Lan */
+#define PM_CTL_WUPS_MULTI_	(0x00000003)	/* Multiple Events Occurred */
+
+/* LED General Purpose IO Configuration Register */
+#define LED_GPIO_CFG		(0x24)
+#define LED_GPIO_CFG_SPD_LED	(0x01000000)	/* GPIO2 as SPD LED */
+#define LED_GPIO_CFG_LNK_LED	(0x00100000)	/* GPIO1 as LNK LED */
+#define LED_GPIO_CFG_FDX_LED	(0x00010000)	/* GPIO0 as FDX LED */
+
+/* General Purpose IO Configuration Register */
+#define GPIO_CFG		(0x28)
+
+/* Automatic Flow Control Configuration Register */
+#define AFC_CFG			(0x2C)
+#define AFC_CFG_HI_		(0x00FF0000)	/* Auto Flow Ctrl High Level */
+#define AFC_CFG_LO_		(0x0000FF00)	/* Auto Flow Ctrl Low Level */
+#define AFC_CFG_BACK_DUR_	(0x000000F0)	/* Back Pressure Duration */
+#define AFC_CFG_FC_MULT_	(0x00000008)	/* Flow Ctrl on Mcast Frame */
+#define AFC_CFG_FC_BRD_		(0x00000004)	/* Flow Ctrl on Bcast Frame */
+#define AFC_CFG_FC_ADD_		(0x00000002)	/* Flow Ctrl on Addr. Decode */
+#define AFC_CFG_FC_ANY_		(0x00000001)	/* Flow Ctrl on Any Frame */
 /* Hi watermark = 15.5Kb (~10 mtu pkts) */
 /* low watermark = 3k (~2 mtu pkts) */
 /* backpressure duration = ~ 350us */
 /* Apply FC on any frame. */
-#define AFC_CFG_DEFAULT			(0x00F830A1)
-
-#define E2P_CMD				(0x30)
-#define E2P_CMD_BUSY_			(0x80000000)
-#define E2P_CMD_MASK_			(0x70000000)
-#define E2P_CMD_READ_			(0x00000000)
-#define E2P_CMD_EWDS_			(0x10000000)
-#define E2P_CMD_EWEN_			(0x20000000)
-#define E2P_CMD_WRITE_			(0x30000000)
-#define E2P_CMD_WRAL_			(0x40000000)
-#define E2P_CMD_ERASE_			(0x50000000)
-#define E2P_CMD_ERAL_			(0x60000000)
-#define E2P_CMD_RELOAD_			(0x70000000)
-#define E2P_CMD_TIMEOUT_		(0x00000400)
-#define E2P_CMD_LOADED_			(0x00000200)
-#define E2P_CMD_ADDR_			(0x000001FF)
-
-#define MAX_EEPROM_SIZE			(512)
-
-#define E2P_DATA			(0x34)
-#define E2P_DATA_MASK_			(0x000000FF)
-
-#define BURST_CAP			(0x38)
+#define AFC_CFG_DEFAULT		(0x00F830A1)
+
+/* EEPROM Command Register */
+#define E2P_CMD			(0x30)
+#define E2P_CMD_BUSY_		(0x80000000)	/* E2P Controller Busy */
+#define E2P_CMD_MASK_		(0x70000000)	/* Command Mask (see below) */
+#define E2P_CMD_READ_		(0x00000000)	/* Read Location */
+#define E2P_CMD_EWDS_		(0x10000000)	/* Erase/Write Disable */
+#define E2P_CMD_EWEN_		(0x20000000)	/* Erase/Write Enable */
+#define E2P_CMD_WRITE_		(0x30000000)	/* Write Location */
+#define E2P_CMD_WRAL_		(0x40000000)	/* Write All */
+#define E2P_CMD_ERASE_		(0x50000000)	/* Erase Location */
+#define E2P_CMD_ERAL_		(0x60000000)	/* Erase All */
+#define E2P_CMD_RELOAD_		(0x70000000)	/* Data Reload */
+#define E2P_CMD_TIMEOUT_	(0x00000400)	/* Set if no resp within 30ms */
+#define E2P_CMD_LOADED_		(0x00000200)	/* Valid EEPROM found */
+#define E2P_CMD_ADDR_		(0x000001FF)	/* Byte aligned address */
+
+#define MAX_EEPROM_SIZE		(512)
+
+/* EEPROM Data Register */
+#define E2P_DATA		(0x34)
+#define E2P_DATA_MASK_		(0x000000FF)	/* EEPROM Data Mask */
+
+/* Burst Cap Register */
+#define BURST_CAP		(0x38)
+#define BURST_CAP_MASK_		(0x000000FF)	/* Max burst sent by the UTX */
 
 #define	STRAP_STATUS			(0x3C)
 #define	STRAP_STATUS_PWR_SEL_		(0x00000020)
@@ -152,87 +182,118 @@
 #define	STRAP_STATUS_RMT_WKP_		(0x00000002)
 #define	STRAP_STATUS_EEP_DISABLE_	(0x00000001)
 
-#define GPIO_WAKE			(0x64)
-
-#define INT_EP_CTL			(0x68)
-#define INT_EP_CTL_INTEP_		(0x80000000)
-#define INT_EP_CTL_MACRTO_		(0x00080000)
-#define INT_EP_CTL_TX_STOP_		(0x00020000)
-#define INT_EP_CTL_RX_STOP_		(0x00010000)
-#define INT_EP_CTL_PHY_INT_		(0x00008000)
-#define INT_EP_CTL_TXE_			(0x00004000)
-#define INT_EP_CTL_TDFU_		(0x00002000)
-#define INT_EP_CTL_TDFO_		(0x00001000)
-#define INT_EP_CTL_RXDF_		(0x00000800)
-#define INT_EP_CTL_GPIOS_		(0x000007FF)
-
-#define BULK_IN_DLY			(0x6C)
-
-/* MAC CSRs */
-#define MAC_CR				(0x100)
-#define MAC_CR_RXALL_			(0x80000000)
-#define MAC_CR_RCVOWN_			(0x00800000)
-#define MAC_CR_LOOPBK_			(0x00200000)
-#define MAC_CR_FDPX_			(0x00100000)
-#define MAC_CR_MCPAS_			(0x00080000)
-#define MAC_CR_PRMS_			(0x00040000)
-#define MAC_CR_INVFILT_			(0x00020000)
-#define MAC_CR_PASSBAD_			(0x00010000)
-#define MAC_CR_HFILT_			(0x00008000)
-#define MAC_CR_HPFILT_			(0x00002000)
-#define MAC_CR_LCOLL_			(0x00001000)
-#define MAC_CR_BCAST_			(0x00000800)
-#define MAC_CR_DISRTY_			(0x00000400)
-#define MAC_CR_PADSTR_			(0x00000100)
-#define MAC_CR_BOLMT_MASK		(0x000000C0)
-#define MAC_CR_DFCHK_			(0x00000020)
-#define MAC_CR_TXEN_			(0x00000008)
-#define MAC_CR_RXEN_			(0x00000004)
-
-#define ADDRH				(0x104)
-
-#define ADDRL				(0x108)
-
-#define HASHH				(0x10C)
-
-#define HASHL				(0x110)
-
-#define MII_ADDR			(0x114)
-#define MII_WRITE_			(0x02)
-#define MII_BUSY_			(0x01)
-#define MII_READ_			(0x00) /* ~of MII Write bit */
-
-#define MII_DATA			(0x118)
-
-#define FLOW				(0x11C)
-#define FLOW_FCPT_			(0xFFFF0000)
-#define FLOW_FCPASS_			(0x00000004)
-#define FLOW_FCEN_			(0x00000002)
-#define FLOW_FCBSY_			(0x00000001)
-
-#define VLAN1				(0x120)
-
-#define VLAN2				(0x124)
-
-#define WUFF				(0x128)
-#define LAN9500_WUFF_NUM		(4)
-#define LAN9500A_WUFF_NUM		(8)
-
-#define WUCSR				(0x12C)
-#define WUCSR_WFF_PTR_RST_		(0x80000000)
-#define WUCSR_GUE_			(0x00000200)
-#define WUCSR_WUFR_			(0x00000040)
-#define WUCSR_MPR_			(0x00000020)
-#define WUCSR_WAKE_EN_			(0x00000004)
-#define WUCSR_MPEN_			(0x00000002)
-
-#define COE_CR				(0x130)
-#define Tx_COE_EN_			(0x00010000)
-#define Rx_COE_MODE_			(0x00000002)
-#define Rx_COE_EN_			(0x00000001)
-
-/* Vendor-specific PHY Definitions */
-
+/* Data Port Select Register */
+#define DP_SEL			(0x40)
+
+/* Data Port Command Register */
+#define DP_CMD			(0x44)
+
+/* Data Port Address Register */
+#define DP_ADDR			(0x48)
+
+/* Data Port Data 0 Register */
+#define DP_DATA0		(0x4C)
+
+/* Data Port Data 1 Register */
+#define DP_DATA1		(0x50)
+
+/* General Purpose IO Wake Enable and Polarity Register */
+#define GPIO_WAKE		(0x64)
+
+/* Interrupt Endpoint Control Register */
+#define INT_EP_CTL		(0x68)
+#define INT_EP_CTL_INTEP_	(0x80000000)	/* Always TX Interrupt PKT */
+#define INT_EP_CTL_MAC_RTO_	(0x00080000)	/* MAC Reset Time Out */
+#define INT_EP_CTL_RX_FIFO_	(0x00040000)	/* RX FIFO Has Frame */
+#define INT_EP_CTL_TX_STOP_	(0x00020000)	/* TX Stopped */
+#define INT_EP_CTL_RX_STOP_	(0x00010000)	/* RX Stopped */
+#define INT_EP_CTL_PHY_INT_	(0x00008000)	/* PHY Interrupt */
+#define INT_EP_CTL_TXE_		(0x00004000)	/* TX Error */
+#define INT_EP_CTL_TDFU_	(0x00002000)	/* TX Data FIFO Underrun */
+#define INT_EP_CTL_TDFO_	(0x00001000)	/* TX Data FIFO Overrun */
+#define INT_EP_CTL_RXDF_	(0x00000800)	/* RX Dropped Frame */
+#define INT_EP_CTL_GPIOS_	(0x000007FF)	/* GPIOs Interrupt Enable */
+
+/* Bulk In Delay Register (units of 16.667ns, until ~1092µs) */
+#define BULK_IN_DLY		(0x6C)
+
+/* MAC CSRs - MAC Control and Status Registers */
+/* MAC Control Register */
+#define MAC_CR			(0x100)
+#define MAC_CR_RXALL_		(0x80000000)	/* Receive All Mode */
+#define MAC_CR_RCVOWN_		(0x00800000)	/* Disable Receive Own */
+#define MAC_CR_LOOPBK_		(0x00200000)	/* Loopback Operation Mode */
+#define MAC_CR_FDPX_		(0x00100000)	/* Full Duplex Mode */
+#define MAC_CR_MCPAS_		(0x00080000)	/* Pass All Multicast */
+#define MAC_CR_PRMS_		(0x00040000)	/* Promiscuous Mode */
+#define MAC_CR_INVFILT_		(0x00020000)	/* Inverse Filtering */
+#define MAC_CR_PASSBAD_		(0x00010000)	/* Pass Bad Frames */
+#define MAC_CR_HFILT_		(0x00008000)	/* Hash Only Filtering Mode */
+#define MAC_CR_HPFILT_		(0x00002000)	/* Hash/Perfect Filt. Mode */
+#define MAC_CR_LCOLL_		(0x00001000)	/* Late Collision Control */
+#define MAC_CR_BCAST_		(0x00000800)	/* Disable Broadcast Frames */
+#define MAC_CR_DISRTY_		(0x00000400)	/* Disable Retry */
+#define MAC_CR_PADSTR_		(0x00000100)	/* Automatic Pad Stripping */
+#define MAC_CR_BOLMT_MASK	(0x000000C0)	/* BackOff Limit */
+#define MAC_CR_DFCHK_		(0x00000020)	/* Deferral Check */
+#define MAC_CR_TXEN_		(0x00000008)	/* Transmitter Enable */
+#define MAC_CR_RXEN_		(0x00000004)	/* Receiver Enable */
+
+/* MAC Address High Register */
+#define ADDRH			(0x104)
+
+/* MAC Address Low Register */
+#define ADDRL			(0x108)
+
+/* Multicast Hash Table High Register */
+#define HASHH			(0x10C)
+
+/* Multicast Hash Table Low Register */
+#define HASHL			(0x110)
+
+/* MII Access Register */
+#define MII_ADDR		(0x114)
+#define MII_WRITE_		(0x02)
+#define MII_BUSY_		(0x01)
+#define MII_READ_		(0x00) /* ~of MII Write bit */
+
+/* MII Data Register */
+#define MII_DATA		(0x118)
+
+/* Flow Control Register */
+#define FLOW			(0x11C)
+#define FLOW_FCPT_		(0xFFFF0000)	/* Pause Time */
+#define FLOW_FCPASS_		(0x00000004)	/* Pass Control Frames */
+#define FLOW_FCEN_		(0x00000002)	/* Flow Control Enable */
+#define FLOW_FCBSY_		(0x00000001)	/* Flow Control Busy */
+
+/* VLAN1 Tag Register */
+#define VLAN1			(0x120)
+
+/* VLAN2 Tag Register */
+#define VLAN2			(0x124)
+
+/* Wake Up Frame Filter Register */
+#define WUFF			(0x128)
+#define LAN9500_WUFF_NUM	(4)
+#define LAN9500A_WUFF_NUM	(8)
+
+/* Wake Up Control and Status Register */
+#define WUCSR			(0x12C)
+#define WUCSR_WFF_PTR_RST_	(0x80000000)	/* WFrame Filter Pointer Rst */
+#define WUCSR_GUE_		(0x00000200)	/* Global Unicast Enable */
+#define WUCSR_WUFR_		(0x00000040)	/* Wakeup Frame Received */
+#define WUCSR_MPR_		(0x00000020)	/* Magic Packet Received */
+#define WUCSR_WAKE_EN_		(0x00000004)	/* Wakeup Frame Enable */
+#define WUCSR_MPEN_		(0x00000002)	/* Magic Packet Enable */
+
+/* Checksum Offload Engine Control Register */
+#define COE_CR			(0x130)
+#define Tx_COE_EN_		(0x00010000)	/* TX Csum Offload Enable */
+#define Rx_COE_MODE_		(0x00000002)	/* RX Csum Offload Mode */
+#define Rx_COE_EN_		(0x00000001)	/* RX Csum Offload Enable */
+
+/* Vendor-specific PHY Definitions (via MII access) */
 /* EDPD NLP / crossover time configuration (LAN9500A only) */
 #define PHY_EDPD_CONFIG			(16)
 #define PHY_EDPD_CONFIG_TX_NLP_EN_	((u16)0x8000)
@@ -255,17 +316,20 @@
 #define MODE_CTRL_STS_EDPWRDOWN_	((u16)0x2000)
 #define MODE_CTRL_STS_ENERGYON_		((u16)0x0002)
 
+/* Control/Status Indication Register */
 #define SPECIAL_CTRL_STS		(27)
 #define SPECIAL_CTRL_STS_OVRRD_AMDIX_	((u16)0x8000)
 #define SPECIAL_CTRL_STS_AMDIX_ENABLE_	((u16)0x4000)
 #define SPECIAL_CTRL_STS_AMDIX_STATE_	((u16)0x2000)
 
+/* Interrupt Source Register */
 #define PHY_INT_SRC			(29)
 #define PHY_INT_SRC_ENERGY_ON_		((u16)0x0080)
 #define PHY_INT_SRC_ANEG_COMP_		((u16)0x0040)
 #define PHY_INT_SRC_REMOTE_FAULT_	((u16)0x0020)
 #define PHY_INT_SRC_LINK_DOWN_		((u16)0x0010)
 
+/* Interrupt Mask Register */
 #define PHY_INT_MASK			(30)
 #define PHY_INT_MASK_ENERGY_ON_		((u16)0x0080)
 #define PHY_INT_MASK_ANEG_COMP_		((u16)0x0040)
@@ -273,7 +337,7 @@
 #define PHY_INT_MASK_LINK_DOWN_		((u16)0x0010)
 #define PHY_INT_MASK_DEFAULT_		(PHY_INT_MASK_ANEG_COMP_ | \
 					 PHY_INT_MASK_LINK_DOWN_)
-
+/* PHY Special Control/Status Register */
 #define PHY_SPECIAL			(31)
 #define PHY_SPECIAL_SPD_		((u16)0x001C)
 #define PHY_SPECIAL_SPD_10HALF_		((u16)0x0004)
@@ -287,12 +351,13 @@
 #define USB_VENDOR_REQUEST_GET_STATS		0xA2
 
 /* Interrupt Endpoint status word bitfields */
-#define INT_ENP_TX_STOP_		((u32)BIT(17))
-#define INT_ENP_RX_STOP_		((u32)BIT(16))
-#define INT_ENP_PHY_INT_		((u32)BIT(15))
-#define INT_ENP_TXE_			((u32)BIT(14))
-#define INT_ENP_TDFU_			((u32)BIT(13))
-#define INT_ENP_TDFO_			((u32)BIT(12))
-#define INT_ENP_RXDF_			((u32)BIT(11))
+#define INT_ENP_MAC_RTO_		((u32)BIT(18))	/* MAC Reset Time Out */
+#define INT_ENP_TX_STOP_		((u32)BIT(17))	/* TX Stopped */
+#define INT_ENP_RX_STOP_		((u32)BIT(16))	/* RX Stopped */
+#define INT_ENP_PHY_INT_		((u32)BIT(15))	/* PHY Interrupt */
+#define INT_ENP_TXE_			((u32)BIT(14))	/* TX Error */
+#define INT_ENP_TDFU_			((u32)BIT(13))	/* TX FIFO Underrun */
+#define INT_ENP_TDFO_			((u32)BIT(12))	/* TX FIFO Overrun */
+#define INT_ENP_RXDF_			((u32)BIT(11))	/* RX Dropped Frame */
 
 #endif /* _SMSC95XX_H */
-- 
2.1.4
