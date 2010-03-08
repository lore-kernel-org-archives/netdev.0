From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 1/6] qlcnic: fix tx csum status
Date: Mon,  8 Mar 2010 02:14:45 -0800
Message-ID: <1268043290-19929-2-git-send-email-amit.salecha@qlogic.com>
References: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:35704 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753400Ab0CHKOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 05:14:52 -0500
In-Reply-To: <1268043290-19929-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Kernel default tx csum function (ethtool_op_get_tx_csum) doesn't show
correct csum status. It takes various FLAGS (NETIF_F_ALL_CSUM) in account
to show tx csum status, which driver doesn't set while disabling tx csum.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 8da6ec8..ef12792 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -785,6 +785,11 @@ qlcnic_get_ethtool_stats(struct net_device *dev,
 	}
 }
 
+static u32 qlcnic_get_tx_csum(struct net_device *dev)
+{
+	return dev->features & NETIF_F_IP_CSUM;
+}
+
 static u32 qlcnic_get_rx_csum(struct net_device *dev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
@@ -995,6 +1000,7 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
 	.set_ringparam = qlcnic_set_ringparam,
 	.get_pauseparam = qlcnic_get_pauseparam,
 	.set_pauseparam = qlcnic_set_pauseparam,
+	.get_tx_csum = qlcnic_get_tx_csum,
 	.set_tx_csum = ethtool_op_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = qlcnic_get_tso,
-- 
1.6.0.2

