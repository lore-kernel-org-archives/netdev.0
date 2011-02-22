From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 1/2] net/r8169: adjust rtl8169_set_speed_xmii function
Date: Tue, 22 Feb 2011 17:26:18 +0800
Message-ID: <1298366782-1508-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adjust code of rtl8169_set_speed_xmii function and remove part
codes which have done in rtl_pll_power_up function.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   16 ++--------------
 1 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 469ab0b..de94489 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1124,6 +1124,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int giga_ctrl, bmcr;
 
+	rtl_writephy(tp, 0x1f, 0x0000);
+
 	if (autoneg == AUTONEG_ENABLE) {
 		int auto_nego;
 
@@ -1152,18 +1154,6 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 		bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
 
-		if ((tp->mac_version == RTL_GIGA_MAC_VER_11) ||
-		    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
-		    (tp->mac_version >= RTL_GIGA_MAC_VER_17)) {
-			/*
-			 * Wake up the PHY.
-			 * Vendor specific (0x1f) and reserved (0x0e) MII
-			 * registers.
-			 */
-			rtl_writephy(tp, 0x1f, 0x0000);
-			rtl_writephy(tp, 0x0e, 0x0000);
-		}
-
 		rtl_writephy(tp, MII_ADVERTISE, auto_nego);
 		rtl_writephy(tp, MII_CTRL1000, giga_ctrl);
 	} else {
@@ -1178,8 +1168,6 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 		if (duplex == DUPLEX_FULL)
 			bmcr |= BMCR_FULLDPLX;
-
-		rtl_writephy(tp, 0x1f, 0x0000);
 	}
 
 	tp->phy_1000_ctrl_reg = giga_ctrl;
-- 
1.7.3.2
