From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v2 net-next 8/8] r8169: add a new chip for RTL8106E
Date: Tue, 2 Apr 2013 16:23:42 +0800
Message-ID: <1364891022-3220-8-git-send-email-hayeswang@realtek.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
 <1364891022-3220-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364891022-3220-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new chip for RTL8106E series.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 85536bf..e392dd0 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -47,6 +47,7 @@
 #define FIRMWARE_8402_1		"rtl_nic/rtl8402-1.fw"
 #define FIRMWARE_8411_1		"rtl_nic/rtl8411-1.fw"
 #define FIRMWARE_8106E_1	"rtl_nic/rtl8106e-1.fw"
+#define FIRMWARE_8106E_2	"rtl_nic/rtl8106e-2.fw"
 #define FIRMWARE_8168G_2	"rtl_nic/rtl8168g-2.fw"
 #define FIRMWARE_8168G_3	"rtl_nic/rtl8168g-3.fw"
 
@@ -142,6 +143,7 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_40,
 	RTL_GIGA_MAC_VER_41,
 	RTL_GIGA_MAC_VER_42,
+	RTL_GIGA_MAC_VER_43,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -271,6 +273,9 @@ static const struct {
 	[RTL_GIGA_MAC_VER_42] =
 		_R("RTL8168g/8111g",	RTL_TD_1, FIRMWARE_8168G_3,
 							JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_43] =
+		_R("RTL8106e",		RTL_TD_1, FIRMWARE_8106E_2,
+							JUMBO_1K, true),
 };
 #undef _R
 
@@ -822,6 +827,7 @@ MODULE_FIRMWARE(FIRMWARE_8168F_2);
 MODULE_FIRMWARE(FIRMWARE_8402_1);
 MODULE_FIRMWARE(FIRMWARE_8411_1);
 MODULE_FIRMWARE(FIRMWARE_8106E_1);
+MODULE_FIRMWARE(FIRMWARE_8106E_2);
 MODULE_FIRMWARE(FIRMWARE_8168G_2);
 MODULE_FIRMWARE(FIRMWARE_8168G_3);
 
@@ -2133,6 +2139,10 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		netif_notice(tp, probe, dev,
 			     "unknown MAC, using family default\n");
 		tp->mac_version = default_version;
+	} else if (tp->mac_version == RTL_GIGA_MAC_VER_42) {
+		tp->mac_version = tp->mii.supports_gmii ?
+				  RTL_GIGA_MAC_VER_42 :
+				  RTL_GIGA_MAC_VER_43;
 	}
 }
 
@@ -3639,6 +3649,7 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8168g_1_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_43:
 		rtl8168g_2_hw_phy_config(tp);
 		break;
 
@@ -3850,6 +3861,7 @@ static void rtl_init_mdio_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_43:
 		ops->write	= r8168g_mdio_write;
 		ops->read	= r8168g_mdio_read;
 		break;
@@ -3878,6 +3890,7 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_43:
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
@@ -4113,6 +4126,7 @@ static void rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_30:
 	case RTL_GIGA_MAC_VER_37:
 	case RTL_GIGA_MAC_VER_39:
+	case RTL_GIGA_MAC_VER_43:
 		ops->down	= r810x_pll_power_down;
 		ops->up		= r810x_pll_power_up;
 		break;
@@ -4186,6 +4200,7 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_43:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST | RX_EARLY_OFF);
 		break;
 	default:
@@ -4345,6 +4360,7 @@ static void rtl_init_jumbo_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_43:
 	default:
 		ops->disable	= NULL;
 		ops->enable	= NULL;
@@ -4453,6 +4469,7 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	           tp->mac_version == RTL_GIGA_MAC_VER_40 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_41 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_42 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_43 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		rtl_udelay_loop_wait_high(tp, &rtl_txcfg_empty_cond, 100, 666);
@@ -5527,6 +5544,9 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_39:
 		rtl_hw_start_8106(tp);
 		break;
+	case RTL_GIGA_MAC_VER_43:
+		rtl_hw_start_8168g_2(tp);
+		break;
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
@@ -6811,6 +6831,7 @@ static void rtl_hw_initialize(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_43:
 		rtl_hw_init_8168g(tp);
 		break;
 
-- 
1.8.1
