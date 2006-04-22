From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 04/11] ixgb: Fix duplicate code
Date: Fri, 21 Apr 2006 18:00:39 -0700
Message-ID: <20060422010039.24255.56047.stgit@jk-desktop.jf.intel.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:48769 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750811AbWDVA5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 20:57:33 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
In-Reply-To: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- created function ixgb_set_speed_duplex to remove duplicate code

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_ethtool.c |   35 ++++++++++++++---------------------
 1 files changed, 14 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 978be30..55a54bb 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -119,6 +119,16 @@ ixgb_get_settings(struct net_device *net
 	return 0;
 }
 
+static void ixgb_set_speed_duplex(struct net_device *netdev)
+{
+	struct ixgb_adapter *adapter = netdev_priv(netdev);
+	/* be optimistic about our link, since we were up before */
+	adapter->link_speed = 10000;
+	adapter->link_duplex = FULL_DUPLEX;
+	netif_carrier_on(netdev);
+	netif_wake_queue(netdev);
+}
+
 static int
 ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
@@ -132,12 +142,7 @@ ixgb_set_settings(struct net_device *net
 		ixgb_down(adapter, TRUE);
 		ixgb_reset(adapter);
 		ixgb_up(adapter);
-		/* be optimistic about our link, since we were up before */
-		adapter->link_speed = 10000;
-		adapter->link_duplex = FULL_DUPLEX;
-		netif_carrier_on(netdev);
-		netif_wake_queue(netdev);
-		
+		ixgb_set_speed_duplex(netdev);
 	} else
 		ixgb_reset(adapter);
 
@@ -185,11 +190,7 @@ ixgb_set_pauseparam(struct net_device *n
 	if(netif_running(adapter->netdev)) {
 		ixgb_down(adapter, TRUE);
 		ixgb_up(adapter);
-		/* be optimistic about our link, since we were up before */
-		adapter->link_speed = 10000;
-		adapter->link_duplex = FULL_DUPLEX;
-		netif_carrier_on(netdev);
-		netif_wake_queue(netdev);
+		ixgb_set_speed_duplex(netdev);
 	} else
 		ixgb_reset(adapter);
 		
@@ -214,11 +215,7 @@ ixgb_set_rx_csum(struct net_device *netd
 	if(netif_running(netdev)) {
 		ixgb_down(adapter,TRUE);
 		ixgb_up(adapter);
-		/* be optimistic about our link, since we were up before */
-		adapter->link_speed = 10000;
-		adapter->link_duplex = FULL_DUPLEX;
-		netif_carrier_on(netdev);
-		netif_wake_queue(netdev);
+		ixgb_set_speed_duplex(netdev);
 	} else
 		ixgb_reset(adapter);
 	return 0;
@@ -609,11 +606,7 @@ ixgb_set_ringparam(struct net_device *ne
 		adapter->tx_ring = tx_new;
 		if((err = ixgb_up(adapter)))
 			return err;
-		/* be optimistic about our link, since we were up before */
-		adapter->link_speed = 10000;
-		adapter->link_duplex = FULL_DUPLEX;
-		netif_carrier_on(netdev);
-		netif_wake_queue(netdev);
+		ixgb_set_speed_duplex(netdev);
 	}
 
 	return 0;

