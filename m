From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8169: add a new chip for RTL8411
Date: Mon, 8 Jul 2013 17:09:01 +0800
Message-ID: <1373274541-1095-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new chip for RTL8411 series.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 67 ++++++++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 393f961..4106a74 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -46,6 +46,7 @@
 #define FIRMWARE_8105E_1	"rtl_nic/rtl8105e-1.fw"
 #define FIRMWARE_8402_1		"rtl_nic/rtl8402-1.fw"
 #define FIRMWARE_8411_1		"rtl_nic/rtl8411-1.fw"
+#define FIRMWARE_8411_2		"rtl_nic/rtl8411-2.fw"
 #define FIRMWARE_8106E_1	"rtl_nic/rtl8106e-1.fw"
 #define FIRMWARE_8106E_2	"rtl_nic/rtl8106e-2.fw"
 #define FIRMWARE_8168G_2	"rtl_nic/rtl8168g-2.fw"
@@ -144,6 +145,7 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_41,
 	RTL_GIGA_MAC_VER_42,
 	RTL_GIGA_MAC_VER_43,
+	RTL_GIGA_MAC_VER_44,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -276,6 +278,9 @@ static const struct {
 	[RTL_GIGA_MAC_VER_43] =
 		_R("RTL8106e",		RTL_TD_1, FIRMWARE_8106E_2,
 							JUMBO_1K, true),
+	[RTL_GIGA_MAC_VER_44] =
+		_R("RTL8411",		RTL_TD_1, FIRMWARE_8411_2,
+							JUMBO_9K, false),
 };
 #undef _R
 
@@ -394,6 +399,7 @@ enum rtl8168_8101_registers {
 #define CSIAR_FUNC_CARD			0x00000000
 #define CSIAR_FUNC_SDIO			0x00010000
 #define CSIAR_FUNC_NIC			0x00020000
+#define CSIAR_FUNC_NIC2			0x00010000
 	PMCH			= 0x6f,
 	EPHYAR			= 0x80,
 #define	EPHYAR_FLAG			0x80000000
@@ -826,6 +832,7 @@ MODULE_FIRMWARE(FIRMWARE_8168F_1);
 MODULE_FIRMWARE(FIRMWARE_8168F_2);
 MODULE_FIRMWARE(FIRMWARE_8402_1);
 MODULE_FIRMWARE(FIRMWARE_8411_1);
+MODULE_FIRMWARE(FIRMWARE_8411_2);
 MODULE_FIRMWARE(FIRMWARE_8106E_1);
 MODULE_FIRMWARE(FIRMWARE_8106E_2);
 MODULE_FIRMWARE(FIRMWARE_8168G_2);
@@ -2051,6 +2058,7 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		int mac_version;
 	} mac_info[] = {
 		/* 8168G family. */
+		{ 0x7cf00000, 0x5c800000,	RTL_GIGA_MAC_VER_44 },
 		{ 0x7cf00000, 0x50900000,	RTL_GIGA_MAC_VER_42 },
 		{ 0x7cf00000, 0x4c100000,	RTL_GIGA_MAC_VER_41 },
 		{ 0x7cf00000, 0x4c000000,	RTL_GIGA_MAC_VER_40 },
@@ -3651,6 +3659,7 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		break;
 	case RTL_GIGA_MAC_VER_42:
 	case RTL_GIGA_MAC_VER_43:
+	case RTL_GIGA_MAC_VER_44:
 		rtl8168g_2_hw_phy_config(tp);
 		break;
 
@@ -3863,6 +3872,7 @@ static void rtl_init_mdio_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
 	case RTL_GIGA_MAC_VER_43:
+	case RTL_GIGA_MAC_VER_44:
 		ops->write	= r8168g_mdio_write;
 		ops->read	= r8168g_mdio_read;
 		break;
@@ -3916,6 +3926,7 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
 	case RTL_GIGA_MAC_VER_43:
+	case RTL_GIGA_MAC_VER_44:
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
@@ -4178,6 +4189,7 @@ static void rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_44:
 		ops->down	= r8168_pll_power_down;
 		ops->up		= r8168_pll_power_up;
 		break;
@@ -4224,6 +4236,7 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
 	case RTL_GIGA_MAC_VER_43:
+	case RTL_GIGA_MAC_VER_44:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_DMA_BURST | RX_EARLY_OFF);
 		break;
 	default:
@@ -4384,6 +4397,7 @@ static void rtl_init_jumbo_ops(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
 	case RTL_GIGA_MAC_VER_43:
+	case RTL_GIGA_MAC_VER_44:
 	default:
 		ops->disable	= NULL;
 		ops->enable	= NULL;
@@ -4493,6 +4507,7 @@ static void rtl8169_hw_reset(struct rtl8169_private *tp)
 	           tp->mac_version == RTL_GIGA_MAC_VER_41 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_42 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_43 ||
+	           tp->mac_version == RTL_GIGA_MAC_VER_44 ||
 	           tp->mac_version == RTL_GIGA_MAC_VER_38) {
 		RTL_W8(ChipCmd, RTL_R8(ChipCmd) | StopReq);
 		rtl_udelay_loop_wait_high(tp, &rtl_txcfg_empty_cond, 100, 666);
@@ -4782,6 +4797,29 @@ static u32 r8402_csi_read(struct rtl8169_private *tp, int addr)
 		RTL_R32(CSIDR) : ~0;
 }
 
+static void r8411_csi_write(struct rtl8169_private *tp, int addr, int value)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W32(CSIDR, value);
+	RTL_W32(CSIAR, CSIAR_WRITE_CMD | (addr & CSIAR_ADDR_MASK) |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT |
+		CSIAR_FUNC_NIC2);
+
+	rtl_udelay_loop_wait_low(tp, &rtl_csiar_cond, 10, 100);
+}
+
+static u32 r8411_csi_read(struct rtl8169_private *tp, int addr)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	RTL_W32(CSIAR, (addr & CSIAR_ADDR_MASK) | CSIAR_FUNC_NIC2 |
+		CSIAR_BYTE_ENABLE << CSIAR_BYTE_ENABLE_SHIFT);
+
+	return rtl_udelay_loop_wait_high(tp, &rtl_csiar_cond, 10, 100) ?
+		RTL_R32(CSIDR) : ~0;
+}
+
 static void rtl_init_csi_ops(struct rtl8169_private *tp)
 {
 	struct csi_ops *ops = &tp->csi_ops;
@@ -4811,6 +4849,11 @@ static void rtl_init_csi_ops(struct rtl8169_private *tp)
 		ops->read	= r8402_csi_read;
 		break;
 
+	case RTL_GIGA_MAC_VER_44:
+		ops->write	= r8411_csi_write;
+		ops->read	= r8411_csi_read;
+		break;
+
 	default:
 		ops->write	= r8169_csi_write;
 		ops->read	= r8169_csi_read;
@@ -5255,6 +5298,25 @@ static void rtl_hw_start_8168g_2(struct rtl8169_private *tp)
 	rtl_ephy_init(tp, e_info_8168g_2, ARRAY_SIZE(e_info_8168g_2));
 }
 
+static void rtl_hw_start_8411_2(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct ephy_info e_info_8411_2[] = {
+		{ 0x00, 0x0000,	0x0008 },
+		{ 0x0c, 0x3df0,	0x0200 },
+		{ 0x0f, 0xffff,	0x5200 },
+		{ 0x19, 0x0020,	0x0000 },
+		{ 0x1e, 0x0000,	0x2000 }
+	};
+
+	rtl_hw_start_8168g_1(tp);
+
+	/* disable aspm and clock request before access ephy */
+	RTL_W8(Config2, RTL_R8(Config2) & ~ClkReqEn);
+	RTL_W8(Config5, RTL_R8(Config5) & ~ASPM_en);
+	rtl_ephy_init(tp, e_info_8411_2, ARRAY_SIZE(e_info_8411_2));
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -5361,6 +5423,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 		rtl_hw_start_8168g_2(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_44:
+		rtl_hw_start_8411_2(tp);
+		break;
+
 	default:
 		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
 			dev->name, tp->mac_version);
@@ -6877,6 +6943,7 @@ static void rtl_hw_initialize(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_41:
 	case RTL_GIGA_MAC_VER_42:
 	case RTL_GIGA_MAC_VER_43:
+	case RTL_GIGA_MAC_VER_44:
 		rtl_hw_init_8168g(tp);
 		break;
 
-- 
1.8.3.1
