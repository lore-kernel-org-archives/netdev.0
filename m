From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/9] enic: update to support 64 bit stats
Date: Wed, 08 Jun 2011 17:54:02 -0700
Message-ID: <20110609005417.630728228@vyatta.com>
References: <20110609005356.160260858@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Christian Benvenuti <benve@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>,
	David Wang <dwang2@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683Ab1FIBQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 21:16:43 -0400
Content-Disposition: inline; filename=enic-stats64.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device driver already uses 64 bit statistics, it just
doesn't use the 64 bit interface.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/enic/enic_main.c	2011-06-07 16:58:31.317079332 -0700
+++ b/drivers/net/enic/enic_main.c	2011-06-07 17:29:09.670195233 -0700
@@ -801,10 +801,10 @@ static netdev_tx_t enic_hard_start_xmit(
 }
 
 /* dev_base_lock rwlock held, nominally process context */
-static struct net_device_stats *enic_get_stats(struct net_device *netdev)
+static struct rtnl_link_stats64 *enic_get_stats(struct net_device *netdev,
+						struct rtnl_link_stats64 *net_stats)
 {
 	struct enic *enic = netdev_priv(netdev);
-	struct net_device_stats *net_stats = &netdev->stats;
 	struct vnic_stats *stats;
 
 	enic_dev_stats_dump(enic, &stats);
@@ -2117,7 +2117,7 @@ static const struct net_device_ops enic_
 	.ndo_open		= enic_open,
 	.ndo_stop		= enic_stop,
 	.ndo_start_xmit		= enic_hard_start_xmit,
-	.ndo_get_stats		= enic_get_stats,
+	.ndo_get_stats64	= enic_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_rx_mode	= enic_set_rx_mode,
 	.ndo_set_multicast_list	= enic_set_rx_mode,
@@ -2139,7 +2139,7 @@ static const struct net_device_ops enic_
 	.ndo_open		= enic_open,
 	.ndo_stop		= enic_stop,
 	.ndo_start_xmit		= enic_hard_start_xmit,
-	.ndo_get_stats		= enic_get_stats,
+	.ndo_get_stats64	= enic_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= enic_set_mac_address,
 	.ndo_set_rx_mode	= enic_set_rx_mode,


