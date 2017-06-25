From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH] net: Remove ndo_dfwd_start_xmit
Date: Sun, 25 Jun 2017 11:09:12 +0300
Message-ID: <20170625080912.27999-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Jason Wang <jasowang@redhat.com>,
        John Fastabend <john.r.fastabend@intel.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0042.outbound.protection.outlook.com ([104.47.33.42]:52943
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751114AbdFYIKA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Jun 2017 04:10:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like commit f663dd9aaf9e ("net: core: explicitly select a txq before doing l2 forwarding")
has removed the need for this dedicated xmit function [it even explicitly
states so in its commit log message] but it hasn't removed the definition
of the ndo.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
CC: Jason Wang <jasowang@redhat.com>
CC: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/netdevice.h | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 68f5d89..85f01d6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1114,12 +1114,6 @@ struct xfrmdev_ops {
  *	by 'ndo_dfwd_add_station'. 'pdev' is the net device backing
  *	the station and priv is the structure returned by the add
  *	operation.
- * netdev_tx_t (*ndo_dfwd_start_xmit)(struct sk_buff *skb,
- *				      struct net_device *dev,
- *				      void *priv);
- *	Callback to use for xmit over the accelerated station. This
- *	is used in place of ndo_start_xmit on accelerated net
- *	devices.
  * int (*ndo_set_tx_maxrate)(struct net_device *dev,
  *			     int queue_index, u32 maxrate);
  *	Called when a user wants to set a max-rate limitation of specific
@@ -1316,9 +1310,6 @@ struct net_device_ops {
 	void			(*ndo_dfwd_del_station)(struct net_device *pdev,
 							void *priv);
 
-	netdev_tx_t		(*ndo_dfwd_start_xmit) (struct sk_buff *skb,
-							struct net_device *dev,
-							void *priv);
 	int			(*ndo_get_lock_subclass)(struct net_device *dev);
 	int			(*ndo_set_tx_maxrate)(struct net_device *dev,
 						      int queue_index,
-- 
2.9.4
