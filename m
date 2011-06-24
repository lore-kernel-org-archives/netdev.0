From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] ixgbe: add basic support for setting and getting nfc controls
Date: Thu, 23 Jun 2011 23:03:10 -0700
Message-ID: <1308895397-23133-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21960 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546Ab1FXGDe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 02:03:34 -0400
In-Reply-To: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds basic support for the obtaining of RSS ring counts.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index a2d8ed5..8373244 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2336,6 +2336,24 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 	return 0;
 }
 
+static int ixgbe_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
+			   void *rule_locs)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int ret = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXRINGS:
+		cmd->data = adapter->num_rx_queues;
+		ret = 0;
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -2371,6 +2389,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_flags              = ethtool_op_get_flags,
 	.set_flags              = ixgbe_set_flags,
+	.get_rxnfc		= ixgbe_get_rxnfc,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.5.4

