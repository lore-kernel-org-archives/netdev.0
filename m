From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v3 3/3] enic: Add tunable_ops support for rx_copybreak
Date: Thu, 14 Aug 2014 14:59:20 +0530
Message-ID: <1408008560-1067-4-git-send-email-_govind@gmx.com>
References: <1408008560-1067-1-git-send-email-_govind@gmx.com>
Cc: ben@decadent.org.uk, stephen@networkplumber.org, ssujith@cisco.com,
	benve@cisco.com, Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:57637 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754327AbaHNJaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2014 05:30:23 -0400
In-Reply-To: <1408008560-1067-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for setting/getting rx_copybreak using
tunable_ops.

Defines enic_get_rx_copybreak() & enic_set_rx_copybreak() tunable_ops.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 30 ++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 523c9ce..9bf53fc 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -379,6 +379,30 @@ static int enic_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 	return ret;
 }
 
+static int enic_get_rx_copybreak(struct net_device *dev,
+				 struct ethtool_tunable *tuna)
+{
+	struct enic *enic = netdev_priv(dev);
+
+	if (tuna->len < sizeof(tuna->data.rx_copybreak))
+		return -ENOSPC;
+	tuna->data.rx_copybreak = enic->rx_copybreak;
+
+	return 0;
+}
+
+static int enic_set_rx_copybreak(struct net_device *dev,
+				 struct ethtool_tunable *tuna)
+{
+	struct enic *enic = netdev_priv(dev);
+
+	if (tuna->len != sizeof(tuna->data.rx_copybreak))
+		return -EINVAL;
+	enic->rx_copybreak = tuna->data.rx_copybreak;
+
+	return 0;
+}
+
 static const struct ethtool_ops enic_ethtool_ops = {
 	.get_settings = enic_get_settings,
 	.get_drvinfo = enic_get_drvinfo,
@@ -391,6 +415,12 @@ static const struct ethtool_ops enic_ethtool_ops = {
 	.get_coalesce = enic_get_coalesce,
 	.set_coalesce = enic_set_coalesce,
 	.get_rxnfc = enic_get_rxnfc,
+	.tunable_ops = {
+		[ETHTOOL_RX_COPYBREAK] = {
+			.set = enic_set_rx_copybreak,
+			.get = enic_get_rx_copybreak,
+		},
+	},
 };
 
 void enic_set_ethtool_ops(struct net_device *netdev)
-- 
2.0.4
