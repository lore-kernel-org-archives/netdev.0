From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 2/4] stmmac: replace hardcoded function name by __func__
Date: Wed,  9 Sep 2015 15:14:14 +0200
Message-ID: <1441804456-15914-2-git-send-email-clabbe.montjoie@gmail.com>
References: <1441804456-15914-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33872 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbbIINOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 09:14:51 -0400
In-Reply-To: <1441804456-15914-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some printing have the function name hardcoded.
It is better to use __func__ instead.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index cb9efb3..c1dc41b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -831,7 +831,7 @@ static int stmmac_init_phy(struct net_device *dev)
 
 		snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 			 priv->plat->phy_addr);
-		dev_dbg(priv->device, "stmmac_init_phy: trying to attach to %s\n",
+		dev_dbg(priv->device, "%s: trying to attach to %s\n", __func__,
 			phy_id_fmt);
 
 		phydev = phy_connect(dev, phy_id_fmt, &stmmac_adjust_link,
@@ -862,8 +862,8 @@ static int stmmac_init_phy(struct net_device *dev)
 		phy_disconnect(phydev);
 		return -ENODEV;
 	}
-	dev_dbg(priv->device, "stmmac_init_phy: %s: attached to PHY (UID 0x%x) Link = %d\n",
-		dev->name, phydev->phy_id, phydev->link);
+	dev_dbg(priv->device, "%s: %s: attached to PHY (UID 0x%x) Link = %d\n",
+		__func__, dev->name, phydev->phy_id, phydev->link);
 
 	priv->phydev = phydev;
 
-- 
2.4.6
