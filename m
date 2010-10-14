From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/2]: stmmac: make ethtool functions local
Date: Wed, 13 Oct 2010 17:50:31 -0700
Message-ID: <20101013175031.41c29349@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Deepak SIKRI <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38170 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab0JNAvg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 20:51:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/stmmac/stmmac_ethtool.c	2010-10-13 17:39:03.228159654 -0700
+++ b/drivers/net/stmmac/stmmac_ethtool.c	2010-10-13 17:41:07.317236754 -0700
@@ -89,8 +89,8 @@ static const struct  stmmac_stats stmmac
 };
 #define STMMAC_STATS_LEN ARRAY_SIZE(stmmac_gstrings_stats)
 
-void stmmac_ethtool_getdrvinfo(struct net_device *dev,
-			       struct ethtool_drvinfo *info)
+static void stmmac_ethtool_getdrvinfo(struct net_device *dev,
+				      struct ethtool_drvinfo *info)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
@@ -104,7 +104,8 @@ void stmmac_ethtool_getdrvinfo(struct ne
 	info->n_stats = STMMAC_STATS_LEN;
 }
 
-int stmmac_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int stmmac_ethtool_getsettings(struct net_device *dev,
+				      struct ethtool_cmd *cmd)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phy = priv->phydev;
@@ -126,7 +127,8 @@ int stmmac_ethtool_getsettings(struct ne
 	return rc;
 }
 
-int stmmac_ethtool_setsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int stmmac_ethtool_setsettings(struct net_device *dev,
+				      struct ethtool_cmd *cmd)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phy = priv->phydev;
@@ -139,32 +141,32 @@ int stmmac_ethtool_setsettings(struct ne
 	return rc;
 }
 
-u32 stmmac_ethtool_getmsglevel(struct net_device *dev)
+static u32 stmmac_ethtool_getmsglevel(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	return priv->msg_enable;
 }
 
-void stmmac_ethtool_setmsglevel(struct net_device *dev, u32 level)
+static void stmmac_ethtool_setmsglevel(struct net_device *dev, u32 level)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	priv->msg_enable = level;
 
 }
 
-int stmmac_check_if_running(struct net_device *dev)
+static int stmmac_check_if_running(struct net_device *dev)
 {
 	if (!netif_running(dev))
 		return -EBUSY;
 	return 0;
 }
 
-int stmmac_ethtool_get_regs_len(struct net_device *dev)
+static int stmmac_ethtool_get_regs_len(struct net_device *dev)
 {
 	return REG_SPACE_SIZE;
 }
 
-void stmmac_ethtool_gregs(struct net_device *dev,
+static void stmmac_ethtool_gregs(struct net_device *dev,
 			  struct ethtool_regs *regs, void *space)
 {
 	int i;
@@ -195,7 +197,7 @@ void stmmac_ethtool_gregs(struct net_dev
 	}
 }
 
-int stmmac_ethtool_set_tx_csum(struct net_device *netdev, u32 data)
+static int stmmac_ethtool_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	if (data)
 		netdev->features |= NETIF_F_HW_CSUM;
@@ -205,7 +207,7 @@ int stmmac_ethtool_set_tx_csum(struct ne
 	return 0;
 }
 
-u32 stmmac_ethtool_get_rx_csum(struct net_device *dev)
+static u32 stmmac_ethtool_get_rx_csum(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
