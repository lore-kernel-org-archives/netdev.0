From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 1/8] netxen: fix tx csum status
Date: Wed, 24 Mar 2010 06:29:16 -0700
Message-ID: <1269437363-2606-2-git-send-email-amit.salecha@qlogic.com>
References: <1269437363-2606-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:28631 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756225Ab0CXN3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 09:29:25 -0400
In-Reply-To: <1269437363-2606-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Kernel default tx csum function (ethtool_op_get_tx_csum) doesn't show
correct csum status. It takes various FLAGS (NETIF_F_ALL_CSUM) in account
to show tx csum status, which driver doesn't set while disabling tx csum.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_ethtool.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index f8499e5..aecba78 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -703,6 +703,11 @@ netxen_nic_get_ethtool_stats(struct net_device *dev,
 	}
 }
 
+static u32 netxen_nic_get_tx_csum(struct net_device *dev)
+{
+	return dev->features & NETIF_F_IP_CSUM;
+}
+
 static u32 netxen_nic_get_rx_csum(struct net_device *dev)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
@@ -909,6 +914,7 @@ const struct ethtool_ops netxen_nic_ethtool_ops = {
 	.set_ringparam = netxen_nic_set_ringparam,
 	.get_pauseparam = netxen_nic_get_pauseparam,
 	.set_pauseparam = netxen_nic_set_pauseparam,
+	.get_tx_csum = netxen_nic_get_tx_csum,
 	.set_tx_csum = ethtool_op_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = netxen_nic_get_tso,
-- 
1.6.0.2

