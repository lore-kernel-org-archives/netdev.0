From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 04/24] ixgbevf: Fix Compiler Warnings
Date: Thu,  3 Mar 2011 05:03:29 -0800
Message-ID: <1299157429-15878-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51571 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757104Ab1CCNET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 08:04:19 -0500
In-Reply-To: <1299157429-15878-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Fix Compiler warnings of variables that are initialized but not used.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbevf/ixgbevf_main.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 1e735a1..8276881 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -178,8 +178,6 @@ static inline bool ixgbevf_check_tx_hang(struct ixgbevf_adapter *adapter,
 	    tx_ring->tx_buffer_info[eop].time_stamp &&
 	    time_after(jiffies, tx_ring->tx_buffer_info[eop].time_stamp + HZ)) {
 		/* detected Tx unit hang */
-		union ixgbe_adv_tx_desc *tx_desc;
-		tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
 		printk(KERN_ERR "Detected Tx Unit Hang\n"
 		       "  Tx Queue             <%d>\n"
 		       "  TDH, TDT             <%x>, <%x>\n"
@@ -334,7 +332,6 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
-	int ret;
 
 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
 		if (adapter->vlgrp && is_vlan)
@@ -345,9 +342,9 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
 			napi_gro_receive(&q_vector->napi, skb);
 	} else {
 		if (adapter->vlgrp && is_vlan)
-			ret = vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
+			vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
 		else
-			ret = netif_rx(skb);
+			netif_rx(skb);
 	}
 }
 
@@ -3287,8 +3284,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 
 static void ixgbevf_assign_netdev_ops(struct net_device *dev)
 {
-	struct ixgbevf_adapter *adapter;
-	adapter = netdev_priv(dev);
 	dev->netdev_ops = &ixgbe_netdev_ops;
 	ixgbevf_set_ethtool_ops(dev);
 	dev->watchdog_timeo = 5 * HZ;
-- 
1.7.4

