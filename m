From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 08/12] infiniband/ipoib: implement ndo_get_iflink
Date: Thu,  2 Apr 2015 17:07:07 +0200
Message-ID: <1427987231-3669-9-git-send-email-nicolas.dichtel@6wind.com>
References: <1422979929.907.19.camel@edumazet-glaptop2.roam.corp.google.com>
 <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Roland Dreier <roland@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56627 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223AbbDBPH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:07:26 -0400
In-Reply-To: <1427987231-3669-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't use dev->iflink anymore.

CC: Roland Dreier <roland@kernel.org>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 8 ++++++++
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c | 1 -
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 58b5aa3b6f2d..657b89b1d291 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -842,6 +842,13 @@ static void ipoib_set_mcast_list(struct net_device *dev)
 	queue_work(ipoib_workqueue, &priv->restart_task);
 }
 
+static int ipoib_get_iflink(const struct net_device *dev)
+{
+	struct ipoib_dev_priv *priv = netdev_priv(dev);
+
+	return priv->parent->ifindex;
+}
+
 static u32 ipoib_addr_hash(struct ipoib_neigh_hash *htbl, u8 *daddr)
 {
 	/*
@@ -1341,6 +1348,7 @@ static const struct net_device_ops ipoib_netdev_ops = {
 	.ndo_start_xmit	 	 = ipoib_start_xmit,
 	.ndo_tx_timeout		 = ipoib_timeout,
 	.ndo_set_rx_mode	 = ipoib_set_mcast_list,
+	.ndo_get_iflink		 = ipoib_get_iflink,
 };
 
 void ipoib_setup(struct net_device *dev)
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
index 9fad7b5ac8b9..4dd1313056a4 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_vlan.c
@@ -102,7 +102,6 @@ int __ipoib_vlan_add(struct ipoib_dev_priv *ppriv, struct ipoib_dev_priv *priv,
 	}
 
 	priv->child_type  = type;
-	priv->dev->iflink = ppriv->dev->ifindex;
 	list_add_tail(&priv->list, &ppriv->child_intfs);
 
 	return 0;
-- 
2.2.2
