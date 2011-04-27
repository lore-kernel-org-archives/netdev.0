From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next] r8169: fix merge conflict fix.
Date: Wed, 27 Apr 2011 22:36:40 +0200
Message-ID: <20110427203640.GC19708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- use adequate MAC_VER id
  (see 01dc7fec4025f6bb72b6b98ec88b375346b6dbbb)
- remove duplicate rtl_firmware_info record
- remove duplicate functions

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
---
 drivers/net/r8169.c |   25 +++++--------------------
 1 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 025dedd..6364e0b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -191,9 +191,8 @@ static const struct rtl_firmware_info {
 	{ .mac_version = RTL_GIGA_MAC_VER_26, .fw_name = FIRMWARE_8168D_2 },
 	{ .mac_version = RTL_GIGA_MAC_VER_29, .fw_name = FIRMWARE_8105E_1 },
 	{ .mac_version = RTL_GIGA_MAC_VER_30, .fw_name = FIRMWARE_8105E_1 },
-	{ .mac_version = RTL_GIGA_MAC_VER_30, .fw_name = FIRMWARE_8105E_1 },
-	{ .mac_version = RTL_GIGA_MAC_VER_31, .fw_name = FIRMWARE_8168E_1 },
-	{ .mac_version = RTL_GIGA_MAC_VER_32, .fw_name = FIRMWARE_8168E_2 }
+	{ .mac_version = RTL_GIGA_MAC_VER_32, .fw_name = FIRMWARE_8168E_1 },
+	{ .mac_version = RTL_GIGA_MAC_VER_33, .fw_name = FIRMWARE_8168E_2 }
 };
 
 enum cfg_version {
@@ -2535,6 +2534,8 @@ static void rtl8168e_hw_phy_config(struct rtl8169_private *tp)
 		{ 0x1f, 0x0000 }
 	};
 
+	rtl_apply_firmware(tp);
+
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 
 	/* DCO enable for 10M IDLE Power */
@@ -2576,20 +2577,6 @@ static void rtl8168e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x0d, 0x0000);
 }
 
-static void rtl8168e_1_hw_phy_config(struct rtl8169_private *tp)
-{
-	rtl_apply_firmware(tp);
-
-	rtl8168e_hw_phy_config(tp);
-}
-
-static void rtl8168e_2_hw_phy_config(struct rtl8169_private *tp)
-{
-	rtl_apply_firmware(tp);
-
-	rtl8168e_hw_phy_config(tp);
-}
-
 static void rtl8102e_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] = {
@@ -2705,10 +2692,8 @@ static void rtl_hw_phy_config(struct net_device *dev)
 		rtl8105e_hw_phy_config(tp);
 		break;
 	case RTL_GIGA_MAC_VER_32:
-		rtl8168e_1_hw_phy_config(tp);
-		break;
 	case RTL_GIGA_MAC_VER_33:
-		rtl8168e_2_hw_phy_config(tp);
+		rtl8168e_hw_phy_config(tp);
 		break;
 
 	default:
-- 
1.7.4.4
