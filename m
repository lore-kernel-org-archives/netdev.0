From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 4/5] r8169: adjust some functions of 8111f
Date: Wed, 28 Mar 2012 16:26:53 +0800
Message-ID: <1332923214-5071-4-git-send-email-hayeswang@realtek.com>
References: <1332923214-5071-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332923214-5071-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Put some settings of 8111f into one function which may be reused.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   99 ++++++++++++++++------------------
 1 files changed, 47 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index aa23a25..cde5cea 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3005,6 +3005,28 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
+static void rtl8168f_hw_phy_config(struct rtl8169_private *tp)
+{
+	/* For 4-corner performance improve */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b80);
+	rtl_w1w0_phy(tp, 0x06, 0x0006, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+
+	/* PHY auto speed down */
+	rtl_writephy(tp, 0x1f, 0x0007);
+	rtl_writephy(tp, 0x1e, 0x002d);
+	rtl_w1w0_phy(tp, 0x18, 0x0010, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
+
+	/* Improve 10M EEE waveform */
+	rtl_writephy(tp, 0x1f, 0x0005);
+	rtl_writephy(tp, 0x05, 0x8b86);
+	rtl_w1w0_phy(tp, 0x06, 0x0001, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
+}
+
 static void rtl8168f_1_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -3046,24 +3068,7 @@ static void rtl8168f_1_hw_phy_config(struct rtl8169_private *tp)
 
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
-	/* For 4-corner performance improve */
-	rtl_writephy(tp, 0x1f, 0x0005);
-	rtl_writephy(tp, 0x05, 0x8b80);
-	rtl_w1w0_phy(tp, 0x06, 0x0006, 0x0000);
-	rtl_writephy(tp, 0x1f, 0x0000);
-
-	/* PHY auto speed down */
-	rtl_writephy(tp, 0x1f, 0x0007);
-	rtl_writephy(tp, 0x1e, 0x002d);
-	rtl_w1w0_phy(tp, 0x18, 0x0010, 0x0000);
-	rtl_writephy(tp, 0x1f, 0x0000);
-	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
-
-	/* Improve 10M EEE waveform */
-	rtl_writephy(tp, 0x1f, 0x0005);
-	rtl_writephy(tp, 0x05, 0x8b86);
-	rtl_w1w0_phy(tp, 0x06, 0x0001, 0x0000);
-	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl8168f_hw_phy_config(tp);
 
 	/* Improve 2-pair detection performance */
 	rtl_writephy(tp, 0x1f, 0x0005);
@@ -3076,24 +3081,7 @@ static void rtl8168f_2_hw_phy_config(struct rtl8169_private *tp)
 {
 	rtl_apply_firmware(tp);
 
-	/* For 4-corner performance improve */
-	rtl_writephy(tp, 0x1f, 0x0005);
-	rtl_writephy(tp, 0x05, 0x8b80);
-	rtl_w1w0_phy(tp, 0x06, 0x0006, 0x0000);
-	rtl_writephy(tp, 0x1f, 0x0000);
-
-	/* PHY auto speed down */
-	rtl_writephy(tp, 0x1f, 0x0007);
-	rtl_writephy(tp, 0x1e, 0x002d);
-	rtl_w1w0_phy(tp, 0x18, 0x0010, 0x0000);
-	rtl_writephy(tp, 0x1f, 0x0000);
-	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
-
-	/* Improve 10M EEE waveform */
-	rtl_writephy(tp, 0x1f, 0x0005);
-	rtl_writephy(tp, 0x05, 0x8b86);
-	rtl_w1w0_phy(tp, 0x06, 0x0001, 0x0000);
-	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl8168f_hw_phy_config(tp);
 }
 
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
@@ -4687,20 +4675,12 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
-static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
+static void rtl_hw_start_8168f(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
-	static const struct ephy_info e_info_8168f_1[] = {
-		{ 0x06, 0x00c0,	0x0020 },
-		{ 0x08, 0x0001,	0x0002 },
-		{ 0x09, 0x0000,	0x0080 },
-		{ 0x19, 0x0000,	0x0224 }
-	};
-
-	rtl_csi_access_enable_1(tp);
 
-	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+	rtl_csi_access_enable_2(tp);
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
@@ -4714,8 +4694,6 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 	rtl_w1w0_eri(ioaddr, 0x1d0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
 	rtl_eri_write(ioaddr, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
 	rtl_eri_write(ioaddr, 0xd0, ERIAR_MASK_1111, 0x00000060, ERIAR_EXGMAC);
-	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
-		     ERIAR_EXGMAC);
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
@@ -4723,15 +4701,32 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 
 	RTL_W32(TxConfig, RTL_R32(TxConfig) | TXCFG_AUTO_FIFO);
 	RTL_W8(MCU, RTL_R8(MCU) & ~NOW_IS_OOB);
-
-	/* Adjust EEE LED frequency */
-	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
-
 	RTL_W8(DLLPR, RTL_R8(DLLPR) | PFM_EN);
 	RTL_W32(MISC, RTL_R32(MISC) | PWM_EN);
 	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
+static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct ephy_info e_info_8168f_1[] = {
+		{ 0x06, 0x00c0,	0x0020 },
+		{ 0x08, 0x0001,	0x0002 },
+		{ 0x09, 0x0000,	0x0080 },
+		{ 0x19, 0x0000,	0x0224 }
+	};
+
+	rtl_hw_start_8168f(tp);
+
+	rtl_ephy_init(ioaddr, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
+
+	rtl_w1w0_eri(ioaddr, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00,
+		     ERIAR_EXGMAC);
+
+	/* Adjust EEE LED frequency */
+	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-- 
1.7.7.6
