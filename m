From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 4/8] net: stmmac: set speed at SPEED_UNKNOWN in case of broken speed
Date: Tue, 14 Feb 2017 20:54:37 +0100
Message-ID: <20170214195441.30425-5-clabbe.montjoie@gmail.com>
References: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34297 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754062AbdBNT5T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:57:19 -0500
In-Reply-To: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of invalid speed given, stmmac_adjust_link() still record it as
current speed.
This patch modify the default case to set speed as SPEED_UNKNOWN if not
10/100/1000.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a87071d..f7664b9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -739,6 +739,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 			default:
 				netif_warn(priv, link, priv->dev,
 					   "broken speed: %d\n", phydev->speed);
+				phydev->speed = SPEED_UNKNOWN;
 				break;
 			}
 
-- 
2.10.2
