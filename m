From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 01/13] stmmac: use MII_BUS_ID_SIZE instead of BUS_ID_SIZE
Date: Thu,  7 Jan 2010 10:07:11 +0100
Message-ID: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:48053 "EHLO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754465Ab0AGJH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:28 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id B7187E7
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:23 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 317E4BC7
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:23 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 508fba8..79a9381 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -305,8 +305,8 @@ static int stmmac_init_phy(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev;
-	char phy_id[BUS_ID_SIZE];	/* PHY to connect */
-	char bus_id[BUS_ID_SIZE];
+	char phy_id[MII_BUS_ID_SIZE + 3];
+	char bus_id[MII_BUS_ID_SIZE];
 
 	priv->oldlink = 0;
 	priv->speed = 0;
@@ -318,7 +318,8 @@ static int stmmac_init_phy(struct net_device *dev)
 	}
 
 	snprintf(bus_id, MII_BUS_ID_SIZE, "%x", priv->bus_id);
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, bus_id, priv->phy_addr);
+	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
+		 priv->phy_addr);
 	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id);
 
 	phydev = phy_connect(dev, phy_id, &stmmac_adjust_link, 0,
-- 
1.6.0.4

