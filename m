From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH 5/5] r8169: adjust rtl8169_set_speed_xmii function
Date: Tue, 22 Feb 2011 14:41:57 +0800
Message-ID: <1298356917-486-5-git-send-email-hayeswang@realtek.com>
References: <1298356917-486-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298356917-486-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adjust code of rtl8169_set_speed_xmii function and remove part
codes which have done in rtl_pll_power_up function.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |   16 ++--------------
 1 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9e7e3b3..8c85545 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1137,6 +1137,8 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int giga_ctrl, bmcr;
 
+	rtl_writephy(tp, 0x1f, 0x0000);
+
 	if (autoneg == AUTONEG_ENABLE) {
 		int auto_nego;
 
@@ -1167,18 +1169,6 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
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
@@ -1193,8 +1183,6 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 		if (duplex == DUPLEX_FULL)
 			bmcr |= BMCR_FULLDPLX;
-
-		rtl_writephy(tp, 0x1f, 0x0000);
 	}
 
 	tp->phy_1000_ctrl_reg = giga_ctrl;
-- 
1.7.3.2
