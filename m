From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 6/8] net: stmmac: split the stmmac_adjust_link 10/100 case
Date: Wed, 15 Feb 2017 10:46:43 +0100
Message-ID: <20170215094645.591-7-clabbe.montjoie@gmail.com>
References: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34025 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751613AbdBOJs7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 04:48:59 -0500
In-Reply-To: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 10/100 case have too many ifcase.
This patch split it for removing an if.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index bebe810..3cbe096 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -721,15 +721,19 @@ static void stmmac_adjust_link(struct net_device *dev)
 					ctrl &= ~priv->hw->link.port;
 				break;
 			case 100:
+				if (priv->plat->has_gmac ||
+				    priv->plat->has_gmac4) {
+					ctrl |= priv->hw->link.port;
+					ctrl |= priv->hw->link.speed;
+				} else {
+					ctrl &= ~priv->hw->link.port;
+				}
+				break;
 			case 10:
 				if (priv->plat->has_gmac ||
 				    priv->plat->has_gmac4) {
 					ctrl |= priv->hw->link.port;
-					if (phydev->speed == SPEED_100) {
-						ctrl |= priv->hw->link.speed;
-					} else {
-						ctrl &= ~(priv->hw->link.speed);
-					}
+					ctrl &= ~(priv->hw->link.speed);
 				} else {
 					ctrl &= ~priv->hw->link.port;
 				}
-- 
2.10.2
