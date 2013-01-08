From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH v2 3/3] net: stmmac: add gmac autonego set for ethtool support
Date: Tue, 08 Jan 2013 15:32:02 -0800
Message-ID: <000601cdedf8$5d39bdf0$17ad39d0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, kgene.kim@samsung.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-language: en-zw
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds gmac auto-negotiation setting for ethtool.
If interface is SGMII, TBI or RTBI, gmac's auto-negotiation
enable bit is need to set.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 1372ce2..457c1a4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -335,6 +335,7 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	struct phy_device *phy = priv->phydev;
 	int new_pause = FLOW_OFF;
 	int ret = 0;
+	int interface = priv->plat->interface;
 
 	spin_lock(&priv->lock);
 
@@ -348,6 +349,10 @@ stmmac_set_pauseparam(struct net_device *netdev,
 
 	if (phy->autoneg) {
 		if (netif_running(netdev))
+			if((interface == PHY_INTERFACE_MODE_SGMII) ||
+				(interface == PHY_INTERFACE_MODE_TBI) ||
+				(interface == PHY_INTERFACE_MODE_RTBI)) 
+				priv->hw->mac->set_autoneg(priv->ioaddr);
 			ret = phy_start_aneg(phy);
 	} else
 		priv->hw->mac->flow_ctrl(priv->ioaddr, phy->duplex,
-- 
1.7.10.4
