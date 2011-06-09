From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/9] netxen: convert to 64 bit statistics
Date: Wed, 08 Jun 2011 17:54:01 -0700
Message-ID: <20110609005417.572148247@vyatta.com>
References: <20110609005356.160260858@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751652Ab1FIBQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 21:16:31 -0400
Content-Disposition: inline; filename=netxen-getstats64.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change to 64 bit statistics interface, driver was already maintaining 64 bit
value.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/netxen/netxen_nic_main.c	2011-06-07 20:33:48.150337471 +0900
+++ b/drivers/net/netxen/netxen_nic_main.c	2011-06-07 20:57:29.912628921 +0900
@@ -92,7 +92,8 @@ static irqreturn_t netxen_msi_intr(int i
 static irqreturn_t netxen_msix_intr(int irq, void *data);
 
 static void netxen_config_indev_addr(struct net_device *dev, unsigned long);
-static struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
+static struct rtnl_link_stats64 *netxen_nic_get_stats(struct net_device *dev,
+						      struct rtnl_link_stats64 *stats);
 static int netxen_nic_set_mac(struct net_device *netdev, void *p);
 
 /*  PCI Device ID Table  */
@@ -520,7 +521,7 @@ static const struct net_device_ops netxe
 	.ndo_open	   = netxen_nic_open,
 	.ndo_stop	   = netxen_nic_close,
 	.ndo_start_xmit    = netxen_nic_xmit_frame,
-	.ndo_get_stats	   = netxen_nic_get_stats,
+	.ndo_get_stats64   = netxen_nic_get_stats,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_set_multicast_list = netxen_set_multicast_list,
 	.ndo_set_mac_address    = netxen_nic_set_mac,
@@ -2110,10 +2111,10 @@ request_reset:
 	clear_bit(__NX_RESETTING, &adapter->state);
 }
 
-static struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
+static struct rtnl_link_stats64 *netxen_nic_get_stats(struct net_device *netdev,
+						      struct rtnl_link_stats64 *stats)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
-	struct net_device_stats *stats = &netdev->stats;
 
 	stats->rx_packets = adapter->stats.rx_pkts + adapter->stats.lro_pkts;
 	stats->tx_packets = adapter->stats.xmitfinished;


