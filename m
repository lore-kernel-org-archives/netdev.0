From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/6] r8169: adjust some registers
Date: Tue, 5 Jul 2011 17:44:50 +0800
Message-ID: <1309859095-32031-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Define new registers and modify some existing ones.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index fbd6838..701ab6b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -327,7 +327,7 @@ enum rtl8168_8101_registers {
 #define	EPHYAR_REG_SHIFT		16
 #define	EPHYAR_DATA_MASK		0xffff
 	DLLPR			= 0xd0,
-#define	PM_SWITCH			(1 << 6)
+#define	PFM_EN				(1 << 6)
 	DBG_REG			= 0xd1,
 #define	FIX_NAK_1			(1 << 4)
 #define	FIX_NAK_2			(1 << 3)
@@ -335,6 +335,7 @@ enum rtl8168_8101_registers {
 	MCU			= 0xd3,
 #define	EN_NDP				(1 << 3)
 #define	EN_OOB_RESET			(1 << 2)
+#define NOW_IS_OOB			(1 << 7)
 	EFUSEAR			= 0xdc,
 #define	EFUSEAR_FLAG			0x80000000
 #define	EFUSEAR_WRITE_CMD		0x80000000
@@ -345,18 +346,31 @@ enum rtl8168_8101_registers {
 };
 
 enum rtl8168_registers {
+	LED_FREQ		= 0x1a,
+	EEE_LED			= 0x1b,
+
+	/* TxConfig */
+#define AUTO_FIFO			(1 << 7)
+#define TX_EMPTY			(1 << 11)
+
+	/* RxConfig */
+#define RX128_INT_EN			(1 << 15) /* 8111c and later */
+#define RX_MULTI_EN			(1 << 14) /* 8111c only */
+
 	ERIDR			= 0x70,
 	ERIAR			= 0x74,
 #define ERIAR_FLAG			0x80000000
 #define ERIAR_WRITE_CMD			0x80000000
 #define ERIAR_READ_CMD			0x00000000
 #define ERIAR_ADDR_BYTE_ALIGN		4
-#define ERIAR_EXGMAC			0
-#define ERIAR_MSIX			1
-#define ERIAR_ASF			2
 #define ERIAR_TYPE_SHIFT		16
-#define ERIAR_BYTEEN			0x0f
-#define ERIAR_BYTEEN_SHIFT		12
+#define ERIAR_EXGMAC			(0x00 << ERIAR_TYPE_SHIFT)
+#define ERIAR_MSIX			(0x01 << ERIAR_TYPE_SHIFT)
+#define ERIAR_ASF			(0x02 << ERIAR_TYPE_SHIFT)
+#define ERIAR_MASK_SHIFT		12
+#define ERIAR_MASK_0001			(0x1 << ERIAR_MASK_SHIFT)
+#define ERIAR_MASK_0011			(0x3 << ERIAR_MASK_SHIFT)
+#define ERIAR_MASK_1111			(0xf << ERIAR_MASK_SHIFT)
 	EPHY_RXER_NUM		= 0x7c,
 	OCPDR			= 0xb0,	/* OCP GPHY access */
 #define OCPDR_WRITE_CMD			0x80000000
@@ -371,6 +385,7 @@ enum rtl8168_registers {
 	RDSAR1			= 0xd0,	/* 8168c only. Undocumented on 8168dp */
 	MISC			= 0xf0,	/* 8168e only. */
 #define TXPLA_RST			(1 << 29)
+#define PWM_EN				(1 << 22)
 };
 
 enum rtl_register_content {
@@ -395,6 +410,7 @@ enum rtl_register_content {
 	RxCRC	= (1 << 19),
 
 	/* ChipCmdBits */
+	StopReq		= 0x80,
 	CmdReset	= 0x10,
 	CmdRxEnb	= 0x08,
 	CmdTxEnb	= 0x04,
@@ -4368,7 +4384,7 @@ static void rtl_hw_start_8105e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 	RTL_W32(FuncEvent, RTL_R32(FuncEvent) & ~0x010000);
 
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
-	RTL_W8(DLLPR, RTL_R8(DLLPR) | PM_SWITCH);
+	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
 
 	rtl_ephy_init(ioaddr, e_info_8105e_1, ARRAY_SIZE(e_info_8105e_1));
 }
-- 
1.7.3.2
