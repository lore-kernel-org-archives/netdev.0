From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 3/10] Staging: et131x: convert to netdev_ops
Date: Sun, 29 Mar 2009 19:25:33 +0400
Message-ID: <20090329152533.GC11056@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: gregkh@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:41798 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbZC2PZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 11:25:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/staging/et131x/et131x_netdev.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/et131x/et131x_netdev.c b/drivers/staging/et131x/et131x_netdev.c
index de65972..951c73d 100644
--- a/drivers/staging/et131x/et131x_netdev.c
+++ b/drivers/staging/et131x/et131x_netdev.c
@@ -112,6 +112,19 @@ void et131x_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp);
 void et131x_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid);
 void et131x_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
 
+static const struct net_device_ops et131x_netdev_ops = {
+	.ndo_open		= et131x_open,
+	.ndo_stop		= et131x_close,
+	.ndo_start_xmit		= et131x_tx,
+	.ndo_set_multicast_list	= et131x_multicast,
+	.ndo_tx_timeout		= et131x_tx_timeout,
+	.ndo_change_mtu		= et131x_change_mtu,
+	.ndo_set_mac_address	= et131x_set_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_get_stats		= et131x_stats,
+	.ndo_do_ioctl		= et131x_ioctl,
+};
+
 /**
  * et131x_device_alloc
  *
@@ -142,16 +155,8 @@ struct net_device *et131x_device_alloc(void)
 	 */
 	//netdev->init               = &et131x_init;
 	//netdev->set_config = &et131x_config;
-	netdev->get_stats = &et131x_stats;
-	netdev->open = &et131x_open;
-	netdev->stop = &et131x_close;
-	netdev->do_ioctl = &et131x_ioctl;
-	netdev->set_multicast_list = &et131x_multicast;
-	netdev->hard_start_xmit = &et131x_tx;
-	netdev->tx_timeout = &et131x_tx_timeout;
 	netdev->watchdog_timeo = ET131X_TX_TIMEOUT;
-	netdev->change_mtu = &et131x_change_mtu;
-	netdev->set_mac_address = &et131x_set_mac_addr;
+	netdev->netdev_ops = &et131x_netdev_ops;
 
 	//netdev->ethtool_ops        = &et131x_ethtool_ops;
 
