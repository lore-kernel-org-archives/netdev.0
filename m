From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH] netxen: fix LRO disable warning
Date: Mon, 21 Mar 2011 03:37:08 -0700
Message-ID: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:34965 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752942Ab1CUKhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2011 06:37:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netxen_nic_set_flags() rejects data if other flag than ETH_FLAG_LRO is set.
Driver also supports NETIF_F_HW_VLAN_TX.
Now compare data with ethtool_op_get_flags(), to get all supported features.

Reported-by: Jesper Dangaard Brouer <jdb@comx.dk>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_ethtool.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 653d308..31c41d6 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -871,7 +871,8 @@ static int netxen_nic_set_flags(struct net_device *netdev, u32 data)
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	int hw_lro;
 
-	if (data & ~ETH_FLAG_LRO)
+	if ((ethtool_op_get_flags(netdev) & ~ETH_FLAG_LRO) !=
+	    (data & ~ETH_FLAG_LRO))
 		return -EINVAL;
 
 	if (!(adapter->capabilities & NX_FW_CAPABILITY_HW_LRO))
-- 
1.7.3.2

