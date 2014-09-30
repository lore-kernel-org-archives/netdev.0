From: Chun-Hao Lin <hau@realtek.com>
Subject: [PATCH net-next 07/10] r8169:change function name of function "rtl_w1w0_eri"
Date: Tue, 30 Sep 2014 23:00:27 +0800
Message-ID: <1412089230-10208-7-git-send-email-hau@realtek.com>
References: <1412089230-10208-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chun-Hao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412089230-10208-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the name of this function to "rtl_w0_w1_eri".
It is more suitable for this function's behavior.

Signed-off-by: Chun-Hao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 58 ++++++++++++++++++------------------
 1 file changed, 29 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e68fe5e..e79def5 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1320,7 +1320,7 @@ static u32 rtl_eri_read(struct rtl8169_private *tp, int addr, int type)
 		RTL_R32(ERIDR) : ~0;
 }
 
-static void rtl_w1w0_eri(struct rtl8169_private *tp, int addr, u32 mask, u32 p,
+static void rtl_w0w1_eri(struct rtl8169_private *tp, int addr, u32 mask, u32 p,
 			 u32 m, int type)
 {
 	u32 val;
@@ -1473,9 +1473,9 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
 				      ERIAR_EXGMAC);
 		}
 		/* Reset packet filter */
-		rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01,
+		rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01,
 			     ERIAR_EXGMAC);
-		rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00,
+		rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00,
 			     ERIAR_EXGMAC);
 	} else if (tp->mac_version == RTL_GIGA_MAC_VER_35 ||
 		   tp->mac_version == RTL_GIGA_MAC_VER_36) {
@@ -1629,14 +1629,14 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 	case RTL_GIGA_MAC_VER_48:
 		tmp = ARRAY_SIZE(cfg) - 1;
 		if (wolopts & WAKE_MAGIC)
-			rtl_w1w0_eri(tp,
+			rtl_w0w1_eri(tp,
 				     0x0dc,
 				     ERIAR_MASK_0100,
 				     MagicPacket_v2,
 				     0x0000,
 				     ERIAR_EXGMAC);
 		else
-			rtl_w1w0_eri(tp,
+			rtl_w0w1_eri(tp,
 				     0x0dc,
 				     ERIAR_MASK_0100,
 				     0x0000,
@@ -3292,7 +3292,7 @@ static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* EEE setting */
-	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_1111, 0x0000, 0x0003, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x1b0, ERIAR_MASK_1111, 0x0000, 0x0003, ERIAR_EXGMAC);
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x8b85);
 	rtl_w0w1_phy(tp, 0x06, 0x0000, 0x2000);
@@ -3472,7 +3472,7 @@ static void rtl8411_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* eee setting */
-	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x00, 0x03, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x00, 0x03, ERIAR_EXGMAC);
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x8b85);
 	rtl_w0w1_phy(tp, 0x06, 0x0000, 0x2000);
@@ -4398,7 +4398,7 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
-		rtl_w1w0_eri(tp, 0x1a8, ERIAR_MASK_1111, 0x00000000,
+		rtl_w0w1_eri(tp, 0x1a8, ERIAR_MASK_1111, 0x00000000,
 			     0xfc000000, ERIAR_EXGMAC);
 		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
 		break;
@@ -4427,7 +4427,7 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
 		RTL_W8(PMCH, RTL_R8(PMCH) | 0xc0);
-		rtl_w1w0_eri(tp, 0x1a8, ERIAR_MASK_1111, 0xfc000000,
+		rtl_w0w1_eri(tp, 0x1a8, ERIAR_MASK_1111, 0xfc000000,
 			     0x00000000, ERIAR_EXGMAC);
 
 		break;
@@ -5502,8 +5502,8 @@ static void rtl_hw_start_8168e_2(struct rtl8169_private *tp)
 	rtl_eri_write(tp, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xd0, ERIAR_MASK_1111, 0x07ff0060, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00, ERIAR_EXGMAC);
 
 	RTL_W8(MaxTxPacketSize, EarlySize);
 
@@ -5533,10 +5533,10 @@ static void rtl_hw_start_8168f(struct rtl8169_private *tp)
 	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xc8, ERIAR_MASK_1111, 0x00100002, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xe8, ERIAR_MASK_1111, 0x00100006, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0x1d0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x1b0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x1d0, ERIAR_MASK_0001, 0x10, 0x00, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xcc, ERIAR_MASK_1111, 0x00000050, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xd0, ERIAR_MASK_1111, 0x00000060, ERIAR_EXGMAC);
 
@@ -5565,7 +5565,7 @@ static void rtl_hw_start_8168f_1(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
 
-	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0xff00, ERIAR_EXGMAC);
 
 	/* Adjust EEE LED frequency */
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
@@ -5585,7 +5585,7 @@ static void rtl_hw_start_8411(struct rtl8169_private *tp)
 
 	rtl_ephy_init(tp, e_info_8168f_1, ARRAY_SIZE(e_info_8168f_1));
 
-	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0c00, 0x0000, ERIAR_EXGMAC);
 }
 
 static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
@@ -5604,8 +5604,8 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
-	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0x2f8, ERIAR_MASK_0011, 0x1d8f, ERIAR_EXGMAC);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
@@ -5618,8 +5618,8 @@ static void rtl_hw_start_8168g_1(struct rtl8169_private *tp)
 	/* Adjust EEE LED frequency */
 	RTL_W8(EEE_LED, RTL_R8(EEE_LED) & ~0x07);
 
-	rtl_w1w0_eri(tp, 0x2fc, ERIAR_MASK_0001, 0x01, 0x06, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, 0x1000, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x2fc, ERIAR_MASK_0001, 0x01, 0x06, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, 0x1000, ERIAR_EXGMAC);
 
 	rtl_pcie_state_l2l3_enable(tp, false);
 }
@@ -5692,12 +5692,12 @@ static void rtl_hw_start_8168h_1(struct rtl8169_private *tp)
 
 	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
-	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
 
-	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_1111, 0x0010, 0x00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_1111, 0x0010, 0x00, ERIAR_EXGMAC);
 
-	rtl_w1w0_eri(tp, 0xd4, ERIAR_MASK_1111, 0x1f00, 0x00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0xd4, ERIAR_MASK_1111, 0x1f00, 0x00, ERIAR_EXGMAC);
 
 	rtl_eri_write(tp, 0x5f0, ERIAR_MASK_0011, 0x4f87, ERIAR_EXGMAC);
 
@@ -5716,7 +5716,7 @@ static void rtl_hw_start_8168h_1(struct rtl8169_private *tp)
 
 	RTL_W8(DLLPR, RTL_R8(DLLPR) & ~TX_10M_PS_EN);
 
-	rtl_w1w0_eri(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, 0x1000, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x1b0, ERIAR_MASK_0011, 0x0000, 0x1000, ERIAR_EXGMAC);
 
 	rtl_pcie_state_l2l3_enable(tp, false);
 
@@ -6010,11 +6010,11 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
 
 	rtl_eri_write(tp, 0xc8, ERIAR_MASK_1111, 0x00000002, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xe8, ERIAR_MASK_1111, 0x00000006, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x00, 0x01, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0xdc, ERIAR_MASK_0001, 0x01, 0x00, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xc0, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
 	rtl_eri_write(tp, 0xb8, ERIAR_MASK_0011, 0x0000, ERIAR_EXGMAC);
-	rtl_w1w0_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0e00, 0xff00, ERIAR_EXGMAC);
+	rtl_w0w1_eri(tp, 0x0d4, ERIAR_MASK_0011, 0x0e00, 0xff00, ERIAR_EXGMAC);
 
 	rtl_pcie_state_l2l3_enable(tp, false);
 }
-- 
1.8.3.2
