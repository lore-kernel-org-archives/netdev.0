From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/4] r8169: adjust rtl8169_set_speed_xmii function.
Date: Sat, 5 Mar 2011 10:39:18 +0100
Message-ID: <20110305093918.GA13854@electric-eye.fr.zoreil.com>
References: <20110305093716.GA13835@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50177 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab1CEJnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 04:43:53 -0500
Content-Disposition: inline
In-Reply-To: <20110305093716.GA13835@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- adjust code of rtl8169_set_speed_xmii function
- remove parts of code which are done in rtl_pll_power_up
  function (8168 only)

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
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
1.7.4


