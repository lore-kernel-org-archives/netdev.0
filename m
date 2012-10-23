From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v2 net-next 2/2] r8169: update the settings for RTL8111G
Date: Tue, 23 Oct 2012 14:47:11 +0800
Message-ID: <1350974831-1438-2-git-send-email-hayeswang@realtek.com>
References: <1350893153-18320-1-git-send-email-hayeswang@realtek.com>
 <1350974831-1438-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1350974831-1438-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the parameters of RTL8111G

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 118 ++++++++++++++++++++++++++++++-----
 1 file changed, 101 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index cdd46de..3a393f7 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -335,6 +335,7 @@ enum rtl_registers {
 #define	RXCFG_FIFO_SHIFT		13
 					/* No threshold before first PCI xfer */
 #define	RX_FIFO_THRESH			(7 << RXCFG_FIFO_SHIFT)
+#define	RX_EARLY_OFF			(1 << 11)
 #define	RXCFG_DMA_SHIFT			8
 					/* Unlimited maximum PCI burst. */
 #define	RX_DMA_BURST			(7 << RXCFG_DMA_SHIFT)
@@ -2434,6 +2435,15 @@ static void r8168_aldps_enable_1(struct rtl8169_private *tp)
 	rtl_w1w0_phy(tp, 0x15, 0x1000, 0x0000);
 }
 
+static void r8168_aldps_enable_2(struct rtl8169_private *tp)
+{
+	if (!(tp->features & RTL_FEATURE_EXTENDED))
+		return;
+
+	rtl_writephy(tp, 0x1f, 0x0a43);
+	rtl_w1w0_phy(tp, 0x10, 0x0004, 0x0000);
+}
+
 static void rtl8169s_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -3400,29 +3410,57 @@ static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const u16 mac_ocp_patch[] = {
 		0xe008, 0xe01b, 0xe01d, 0xe01f,
-		0xe021, 0xe023, 0xe025, 0xe027,
+		0xe022, 0xe025, 0xe031, 0xe04d,
 		0x49d2, 0xf10d, 0x766c, 0x49e2,
 		0xf00a, 0x1ec0, 0x8ee1, 0xc60a,
-
 		0x77c0, 0x4870, 0x9fc0, 0x1ea0,
 		0xc707, 0x8ee1, 0x9d6c, 0xc603,
 		0xbe00, 0xb416, 0x0076, 0xe86c,
-		0xc602, 0xbe00, 0x0000, 0xc602,
-
-		0xbe00, 0x0000, 0xc602, 0xbe00,
-		0x0000, 0xc602, 0xbe00, 0x0000,
-		0xc602, 0xbe00, 0x0000, 0xc602,
-		0xbe00, 0x0000, 0xc602, 0xbe00,
-
-		0x0000, 0x0000, 0x0000, 0x0000
+		0xc602, 0xbe00, 0xa000, 0xc602,
+		0xbe00, 0x0000, 0x1b76, 0xc202,
+		0xba00, 0x059c, 0x1b76, 0xc602,
+		0xbe00, 0x065a, 0x74e6, 0x1b78,
+		0x46dc, 0x1300, 0xf005, 0x74f8,
+		0x48c3, 0x48c4, 0x8cf8, 0x64e7,
+		0xc302, 0xbb00, 0x06a0, 0x74e4,
+		0x49c5, 0xf106, 0x49c6, 0xf107,
+		0x48c8, 0x48c9, 0xe011, 0x48c9,
+		0x4848, 0xe00e, 0x4848, 0x49c7,
+		0xf00a, 0x48c9, 0xc60d, 0x1d1f,
+		0x8dc2, 0x1d00, 0x8dc3, 0x1d11,
+		0x8dc0, 0xe002, 0x4849, 0x94e5,
+		0xc602, 0xbe00, 0x01f0, 0xe434,
+		0x49d9, 0xf01b, 0xc31e, 0x7464,
+		0x49c4, 0xf114, 0xc31b, 0x6460,
+		0x14fa, 0xfa02, 0xe00f, 0xc317,
+		0x7460, 0x49c0, 0xf10b, 0xc311,
+		0x7462, 0x48c1, 0x9c62, 0x4841,
+		0x9c62, 0xc30a, 0x1c04, 0x8c60,
+		0xe004, 0x1c15, 0xc305, 0x8c60,
+		0xc602, 0xbe00, 0x0384, 0xe434,
+		0xe030, 0xe61c, 0xe906
 	};
 	u32 i;
 
 	/* Patch code for GPHY reset */
+	r8168_mac_ocp_write(tp, 0xfc26, 0x0000);
+	r8168_mac_ocp_write(tp, 0xfc28, 0x0000);
+	r8168_mac_ocp_write(tp, 0xfc2a, 0x0000);
+	r8168_mac_ocp_write(tp, 0xfc2c, 0x0000);
+	r8168_mac_ocp_write(tp, 0xfc2e, 0x0000);
+	r8168_mac_ocp_write(tp, 0xfc30, 0x0000);
+	r8168_mac_ocp_write(tp, 0xfc32, 0x0000);
+	r8168_mac_ocp_write(tp, 0xfc34, 0x0000);
+	r8168_mac_ocp_write(tp, 0xfc36, 0x0000);
 	for (i = 0; i < ARRAY_SIZE(mac_ocp_patch); i++)
-		r8168_mac_ocp_write(tp, 0xf800 + 2*i, mac_ocp_patch[i]);
+		r8168_mac_ocp_write(tp, 0xf800 + 2 * i, mac_ocp_patch[i]);
 	r8168_mac_ocp_write(tp, 0xfc26, 0x8000);
 	r8168_mac_ocp_write(tp, 0xfc28, 0x0075);
+	r8168_mac_ocp_write(tp, 0xfc2e, 0x059b);
+	r8168_mac_ocp_write(tp, 0xfc30, 0x0659);
+	r8168_mac_ocp_write(tp, 0xfc32, 0x069f);
+	r8168_mac_ocp_write(tp, 0xfc34, 0x01cd);
+	r8168_mac_ocp_write(tp, 0xfc36, 0x0303);
 
 	rtl_apply_firmware(tp);
 
@@ -3436,13 +3474,46 @@ static void rtl8168g_1_hw_phy_config(struct rtl8169_private *tp)
 	else
 		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x0000, 0x0002);
 
-	rtl_w1w0_phy_ocp(tp, 0xa442, 0x000c, 0x0000);
-	rtl_w1w0_phy_ocp(tp, 0xa4b2, 0x0004, 0x0000);
+	/* Enable PHY auto speed down */
+	rtl_writephy(tp, 0x1f, 0x0a44);
+	rtl_w1w0_phy(tp, 0x11, 0x000c, 0x0000);
+
+	rtl_writephy(tp, 0x1f, 0x0bcc);
+	rtl_w1w0_phy(tp, 0x14, 0x0100, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0a44);
+	rtl_w1w0_phy(tp, 0x11, 0x00c0, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0a43);
+	rtl_writephy(tp, 0x13, 0x8084);
+	rtl_w1w0_phy(tp, 0x14, 0x0000, 0x6000);
+	rtl_w1w0_phy(tp, 0x10, 0x1003, 0x0000);
+
+	/* EEE auto-fallback function */
+	rtl_writephy(tp, 0x1f, 0x0a4b);
+	rtl_w1w0_phy(tp, 0x11, 0x0004, 0x0000);
+
+	/* Enable UC LPF tune function */
+	rtl_writephy(tp, 0x1f, 0x0a43);
+	rtl_writephy(tp, 0x13, 0x8012);
+	rtl_w1w0_phy(tp, 0x14, 0x8000, 0x0000);
+
+	rtl_writephy(tp, 0x1f, 0x0c42);
+	rtl_w1w0_phy(tp, 0x11, 0x4000, 0x2000);
 
-	r8168_phy_ocp_write(tp, 0xa436, 0x8012);
-	rtl_w1w0_phy_ocp(tp, 0xa438, 0x8000, 0x0000);
+	/* Improve SWR Efficiency */
+	rtl_writephy(tp, 0x1f, 0x0bcd);
+	rtl_writephy(tp, 0x14, 0x5065);
+	rtl_writephy(tp, 0x14, 0xd065);
+	rtl_writephy(tp, 0x1f, 0x0bc8);
+	rtl_writephy(tp, 0x11, 0x5655);
+	rtl_writephy(tp, 0x1f, 0x0bcd);
+	rtl_writephy(tp, 0x14, 0x1065);
+	rtl_writephy(tp, 0x14, 0x9065);
+	rtl_writephy(tp, 0x14, 0x1065);
 
-	rtl_w1w0_phy_ocp(tp, 0xc422, 0x4000, 0x2000);
+	/* ALDPS enable */
+	r8168_aldps_enable_2(tp);
+
+	rtl_writephy(tp, 0x1f, 0x0000);
 }
 
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
@@ -4047,6 +4118,10 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_33:
 		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
 		break;
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x40);
+		break;
 	}
 }
 
@@ -4064,6 +4139,10 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_33:
 		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
 		break;
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		RTL_W8(PMCH, RTL_R8(PMCH) | 0x40);
+		break;
 	}
 
 	r8168_phy_power_up(tp);
@@ -4169,6 +4248,10 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_34:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
 		break;
+	case RTL_GIGA_MAC_VER_40:
+	case RTL_GIGA_MAC_VER_41:
+		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST | RX_EARLY_OFF);
+		break;
 	default:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST);
 		break;
@@ -5157,7 +5240,8 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	/* Adjust EEE LED frequency */
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
 
-	rtl_w1w0_eri(tp, 0x2fc, ERIAR_MASK_0001, 0x01, 0x02, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x2fc, ERIAR_MASK_0001, 0x01, 0x06, ERIAR_EXGMAC);
+	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, 0x1000, ERIAR_EXGMAC);
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
-- 
1.7.11.4
