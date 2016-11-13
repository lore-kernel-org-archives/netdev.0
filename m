From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] net: stmmac: Add support for ethtool::nway_reset
Date: Sun, 13 Nov 2016 13:24:44 -0800
Message-ID: <20161113212444.3777-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we have a PHY device, just invoke genphy_restart_aneg() to restart
auto-negotiation.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 3fe9340b748f..7a487c9ccdea 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -862,6 +862,16 @@ static int stmmac_set_tunable(struct net_device *dev,
 	return ret;
 }
 
+static int stmmac_nway_reset(struct net_device *dev)
+{
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	if (!dev->phydev)
+		return -ENODEV;
+
+	return genphy_restart_aneg(dev->phydev);
+}
+
 static const struct ethtool_ops stmmac_ethtool_ops = {
 	.begin = stmmac_check_if_running,
 	.get_drvinfo = stmmac_ethtool_getdrvinfo,
@@ -886,6 +896,7 @@ static const struct ethtool_ops stmmac_ethtool_ops = {
 	.set_tunable = stmmac_set_tunable,
 	.get_link_ksettings = stmmac_ethtool_get_link_ksettings,
 	.set_link_ksettings = stmmac_ethtool_set_link_ksettings,
+	.nway_reset = stmmac_nway_reset,
 };
 
 void stmmac_set_ethtool_ops(struct net_device *netdev)
-- 
2.9.3
