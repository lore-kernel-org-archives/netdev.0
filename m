From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 01/10] stmmac: Allow stmmac to work with other PHY buses(v3).
Date: Fri, 23 Mar 2012 10:08:32 +0100
Message-ID: <1332493721-28309-2-git-send-email-peppe.cavallaro@st.com>
References: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, srinivas.kandagatla@st.com,
	deepak.sikri@st.com, spear-devel@list.st.com, shiraz.hashim@st.com,
	viresh.kumar@st.com, bhutchings@solarflare.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:57043 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757575Ab2CWJJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 05:09:25 -0400
In-Reply-To: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

As stmmac mdio bus name prefix is hardcoded in the driver, this allows
only phys on stmmac mdio buses to connect, however stmmac should allow
phys on other mdio buses too.

This patch adds new variable phy_bus_name to plat_stmmacenet_data
struct to let the BSP decide which phy bus to be used by stmmac driver.
A typical use-case is to have generic MDIO buses like mdio-gpio on top
of stmmac.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
Acked-by: Florian Fainelli <florian@openwrt.org>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    8 +++++++-
 include/linux/stmmac.h                            |    1 +
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e85ffbd..860519c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -307,7 +307,13 @@ static int stmmac_init_phy(struct net_device *dev)
 	priv->speed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x", priv->plat->bus_id);
+	if (priv->plat->phy_bus_name)
+		snprintf(bus_id, MII_BUS_ID_SIZE, "%s-%x",
+				priv->plat->phy_bus_name, priv->plat->bus_id);
+	else
+		snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x",
+				priv->plat->bus_id);
+
 	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 		 priv->plat->phy_addr);
 	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id);
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 0dddc9e..172b5e1 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -39,6 +39,7 @@ struct stmmac_mdio_bus_data {
 };
 
 struct plat_stmmacenet_data {
+	char *phy_bus_name;
 	int bus_id;
 	int phy_addr;
 	int interface;
-- 
1.7.4.4
