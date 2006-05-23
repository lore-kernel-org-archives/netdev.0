From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/9] ixgb: remove duplicate code setting duplex and speed
Date: Tue, 23 May 2006 11:04:07 -0700
Message-ID: <20060523180407.17428.40761.stgit@gitlost.site>
References: <20060523180302.17428.89125.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke <auke-jan.h.kok"@intel.com,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:40197 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932126AbWEWR7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:59:09 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523180302.17428.89125.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Removed duplicate code.  Create ixgb_set_speed_duplex function to contain
duplicate code.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_ethtool.c |   35 ++++++++++++++---------------------
 1 files changed, 14 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index d38ade5..4db63e0 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -117,6 +117,16 @@ ixgb_get_settings(struct net_device *net
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
@@ -130,12 +140,7 @@ ixgb_set_settings(struct net_device *net
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
 
@@ -183,11 +188,7 @@ ixgb_set_pauseparam(struct net_device *n
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
 		
@@ -212,11 +213,7 @@ ixgb_set_rx_csum(struct net_device *netd
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
@@ -593,11 +590,7 @@ ixgb_set_ringparam(struct net_device *ne
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



--
Auke Kok <auke-jan.h.kok@intel.com>
