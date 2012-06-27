From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Unknown chipsets from Realtek's 8168 driver
Date: Wed, 27 Jun 2012 23:43:45 +0200
Message-ID: <20120627214345.GA9931@electric-eye.fr.zoreil.com>
References: <20120626102635.GB1854@electric-eye.fr.zoreil.com> <A8D0CF5460074425A9047CB50C94617D@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35210 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754206Ab2F0Vyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 17:54:38 -0400
Content-Disposition: inline
In-Reply-To: <A8D0CF5460074425A9047CB50C94617D@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> Thanks. I would complete it as soon as possible.

There may be some 810x candidates as well.

[PATCH] r8169: more 810x chipsets from Realtek's 1.022.00 8101 driver

CFG_METHOD_15 / RTL_GIGA_MAC_VER_42
CFG_METHOD_16 / RTL_GIGA_MAC_VER_43
CFG_METHOD_6  / RTL_GIGA_MAC_VER_44
CFG_METHOD_7  / RTL_GIGA_MAC_VER_45
CFG_METHOD_8  / RTL_GIGA_MAC_VER_46

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |  161 +++++++++++++++++++++++++++++++++-
 1 file changed, 160 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 8381640..5544e36 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -145,6 +145,11 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_39,
 	RTL_GIGA_MAC_VER_40,
 	RTL_GIGA_MAC_VER_41,
+	RTL_GIGA_MAC_VER_42,
+	RTL_GIGA_MAC_VER_43,
+	RTL_GIGA_MAC_VER_44,
+	RTL_GIGA_MAC_VER_45,
+	RTL_GIGA_MAC_VER_46,
 	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
@@ -270,6 +275,16 @@ static const struct {
 		_R("RTL8168g/8111g",	RTL_TD_1, NULL, JUMBO_9K, false),
 	[RTL_GIGA_MAC_VER_41] =
 		_R("RTL8168ep/8111ep",	RTL_TD_1, NULL, JUMBO_9K, false),
+	[RTL_GIGA_MAC_VER_42] =
+		_R("RTL8106e",		RTL_TD_1, NULL, JUMBO_1K, false),
+	[RTL_GIGA_MAC_VER_43] =
+		_R("RTL8106e",		RTL_TD_1, NULL, JUMBO_1K, false),
+	[RTL_GIGA_MAC_VER_44] =
+		_R("RTL8103e",		RTL_TD_1, NULL, JUMBO_1K, false),
+	[RTL_GIGA_MAC_VER_45] =
+		_R("RTL8103e",		RTL_TD_1, NULL, JUMBO_1K, false),
+	[RTL_GIGA_MAC_VER_46] =
+		_R("RTL8103e",		RTL_TD_1, NULL, JUMBO_1K, false),
 };
 #undef _R
 
@@ -1427,7 +1442,9 @@ static void rtl_link_chg_patch(struct rtl8169_private *tp)
 			rtl_eri_write(ioaddr, 0x1dc, ERIAR_MASK_1111,
 				      0x0000003f, ERIAR_EXGMAC);
 		}
-	} else if (tp->mac_version == RTL_GIGA_MAC_VER_37) {
+	} else if (tp->mac_version == RTL_GIGA_MAC_VER_37 ||
+		   tp->mac_version == RTL_GIGA_MAC_VER_42 ||
+		   tp->mac_version == RTL_GIGA_MAC_VER_43) {
 		if (RTL_R8(PHYstatus) & _10bps) {
 			rtl_eri_write(ioaddr, 0x1d0, ERIAR_MASK_0011,
 				      0x4d02, ERIAR_EXGMAC);
@@ -2062,6 +2079,14 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		{ 0x7c800000, 0x30000000,	RTL_GIGA_MAC_VER_11 },
 
 		/* 8101 family. */
+		{ 0x7cf00000, 0x34e00000,	RTL_GIGA_MAC_VER_46 },
+		{ 0x7cf00000, 0x24e00000,	RTL_GIGA_MAC_VER_46 },
+		{ 0x7cf00000, 0x34d00000,	RTL_GIGA_MAC_VER_45 },
+		{ 0x7cf00000, 0x24d00000,	RTL_GIGA_MAC_VER_45 },
+		{ 0x7cf00000, 0x34c00000,	RTL_GIGA_MAC_VER_44 },
+		{ 0x7cf00000, 0x24c00000,	RTL_GIGA_MAC_VER_44 },
+		{ 0x7cf00000, 0x44900000,	RTL_GIGA_MAC_VER_43 },
+		{ 0x7cf00000, 0x44800000,	RTL_GIGA_MAC_VER_42 },
 		{ 0x7c800000, 0x44000000,	RTL_GIGA_MAC_VER_37 },
 		{ 0x7cf00000, 0x40b00000,	RTL_GIGA_MAC_VER_30 },
 		{ 0x7cf00000, 0x40a00000,	RTL_GIGA_MAC_VER_30 },
@@ -3428,6 +3453,64 @@ static void rtl8168ep_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
+static void rtl8106e_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0000 },
+		{ 0x18, 0x0310 }
+	};
+
+
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+	msleep(20);
+}
+
+static void rtl8106e_1_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x11, 0x83ba },		
+		{ 0x1f, 0x0000 },
+		{ 0x18, 0x8310 },		
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl8106e_hw_phy_config(tp);
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8106e_2_hw_phy_config(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	static const struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0000 },
+		{ 0x18, 0x8310 },		
+		{ 0x1f, 0x0000 }
+	};
+
+
+	rtl8106e_hw_phy_config(tp);
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8103e_hw_phy_config(struct rtl8169_private *tp)
+{
+	static const struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0003 },
+		{ 0x08, 0x441d },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_writephy(tp, 0x1f, 0x0000);
+	rtl_w1w0_phy(tp, 0x11, 0x1000, 0x0000);
+	rtl_w1w0_phy(tp, 0x19, 0x2000, 0x0000);
+	rtl_w1w0_phy(tp, 0x10, 0x8000, 0x0000);
+
+	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
 static void rtl_hw_phy_config(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3536,6 +3619,20 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8168ep_hw_phy_config(tp);
 		break;
 
+	case RTL_GIGA_MAC_VER_42:
+		rtl8106e_2_hw_phy_config(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_43:
+		rtl8106e_2_hw_phy_config(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_44:
+		rtl8103e_hw_phy_config(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_45:
+	case RTL_GIGA_MAC_VER_46:
 	default:
 		break;
 	}
@@ -3781,6 +3878,8 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_34:
 	case RTL_GIGA_MAC_VER_37:
 	case RTL_GIGA_MAC_VER_38:
+	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_43:
 		RTL_W32(RxConfig, RTL_R32(RxConfig) |
 			AcceptBroadcast | AcceptMulticast | AcceptMyPhys);
 		break;
@@ -3788,6 +3887,9 @@ static void rtl_wol_suspend_quirk(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_39:
 	case RTL_GIGA_MAC_VER_40:
 	case RTL_GIGA_MAC_VER_41:
+	case RTL_GIGA_MAC_VER_44:
+	case RTL_GIGA_MAC_VER_45:
+	case RTL_GIGA_MAC_VER_46:
 	default:
 		break;
 	}
@@ -3835,6 +3937,17 @@ static void r810x_pll_power_down(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_13:
 	case RTL_GIGA_MAC_VER_16:
 		break;
+
+	case RTL_GIGA_MAC_VER_44:
+		// ..
+		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
+		break;
+
+	case RTL_GIGA_MAC_VER_46:
+		// ..
+		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
+		break;
+
 	default:
 		RTL_W8(PMCH, RTL_R8(PMCH) & ~0x80);
 		break;
@@ -3855,6 +3968,7 @@ static void r810x_pll_power_up(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_13:
 	case RTL_GIGA_MAC_VER_16:
 		break;
+	case RTL_GIGA_MAC_VER_44:
 	default:
 		RTL_W8(PMCH, RTL_R8(PMCH) | 0x80);
 		break;
@@ -5374,6 +5488,34 @@ static void rtl_hw_start_8402(struct rtl8169_private *tp)
 		     ERIAR_EXGMAC);
 }
 
+static void rtl_hw_start_8106e(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	// ...
+}
+
+static void rtl_hw_start_8103e_1(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	// ...
+}
+
+static void rtl_hw_start_8103e_2(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	// ...
+}
+
+static void rtl_hw_start_8103e_3(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	// ...
+}
+
 static void rtl_hw_start_8101(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -5418,6 +5560,23 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_37:
 		rtl_hw_start_8402(tp);
 		break;
+
+	case RTL_GIGA_MAC_VER_42:
+	case RTL_GIGA_MAC_VER_43:
+		rtl_hw_start_8106e(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_44:
+		rtl_hw_start_8103e_1(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_45:
+		rtl_hw_start_8103e_2(tp);
+		break;
+
+	case RTL_GIGA_MAC_VER_46:
+		rtl_hw_start_8103e_3(tp);
+		break;
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Lock);
-- 
1.7.10.2
