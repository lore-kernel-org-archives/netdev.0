From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net-next v3.16]r8169:  Implement definitions from linux/mii.h header
Date: Fri, 25 Mar 2016 12:25:17 +0200
Message-ID: <1458901517-5932-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-53-82.residential.rdsnet.ro ([5.14.53.82]:54254 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbcCYKZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 06:25:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Add definitions from mii and inhibit 0 to advertise.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index a57b650..a450656 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1679,29 +1679,19 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		int auto_nego;
 
 		auto_nego = rtl_readphy(tp, MII_ADVERTISE);
-		auto_nego &= ~(ADVERTISE_10HALF | ADVERTISE_10FULL |
-				ADVERTISE_100HALF | ADVERTISE_100FULL);
-
-		if (adv & ADVERTISED_10baseT_Half)
-			auto_nego |= ADVERTISE_10HALF;
-		if (adv & ADVERTISED_10baseT_Full)
-			auto_nego |= ADVERTISE_10FULL;
-		if (adv & ADVERTISED_100baseT_Half)
-			auto_nego |= ADVERTISE_100HALF;
-		if (adv & ADVERTISED_100baseT_Full)
-			auto_nego |= ADVERTISE_100FULL;
+		auto_nego &= ~(0 | ADVERTISE_10HALF | ADVERTISE_10FULL |
+				ADVERTISE_100HALF | ADVERTISE_100FULL |
+				ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
 
+		auto_nego |= ethtool_adv_to_mii_adv_t(adv);
 		auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
 		giga_ctrl = rtl_readphy(tp, MII_CTRL1000);
-		giga_ctrl &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
+		giga_ctrl &= ~(0 | ADVERTISE_1000FULL | ADVERTISE_1000HALF);
 
 		/* The 8100e/8101e/8102e do Fast Ethernet only. */
 		if (tp->mii.supports_gmii) {
-			if (adv & ADVERTISED_1000baseT_Half)
-				giga_ctrl |= ADVERTISE_1000HALF;
-			if (adv & ADVERTISED_1000baseT_Full)
-				giga_ctrl |= ADVERTISE_1000FULL;
+			giga_ctrl |= ethtool_adv_to_mii_ctrl1000_t(adv);
 		} else if (adv & (ADVERTISED_1000baseT_Half |
 				  ADVERTISED_1000baseT_Full)) {
 			netif_info(tp, link, dev,
-- 
2.1.4
