From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v4 3/3] enic: Add tunable_ops support for rx_copybreak
Date: Wed,  3 Sep 2014 03:17:21 +0530
Message-ID: <1409694441-3843-4-git-send-email-_govind@gmx.com>
References: <1409694441-3843-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, ben@decadent.org.uk,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:59238 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754183AbaIBVsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 17:48:31 -0400
In-Reply-To: <1409694441-3843-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for setting/getting rx_copybreak using
generic ethtool tunable.

Defines enic_get_tunable() & enic_set_tunable() to get/set rx_copybreak.
As of now, these two function supports only rx_copybreak.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 39 ++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 523c9ce..85173d6 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -379,6 +379,43 @@ static int enic_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 	return ret;
 }
 
+static int enic_get_tunable(struct net_device *dev,
+			    const struct ethtool_tunable *tuna, void *data)
+{
+	struct enic *enic = netdev_priv(dev);
+	int ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		*(u32 *)data = enic->rx_copybreak;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+static int enic_set_tunable(struct net_device *dev,
+			    const struct ethtool_tunable *tuna,
+			    const void *data)
+{
+	struct enic *enic = netdev_priv(dev);
+	int ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		enic->rx_copybreak = *(u32 *)data;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
 static const struct ethtool_ops enic_ethtool_ops = {
 	.get_settings = enic_get_settings,
 	.get_drvinfo = enic_get_drvinfo,
@@ -391,6 +428,8 @@ static const struct ethtool_ops enic_ethtool_ops = {
 	.get_coalesce = enic_get_coalesce,
 	.set_coalesce = enic_set_coalesce,
 	.get_rxnfc = enic_get_rxnfc,
+	.get_tunable = enic_get_tunable,
+	.set_tunable = enic_set_tunable,
 };
 
 void enic_set_ethtool_ops(struct net_device *netdev)
-- 
2.1.0
