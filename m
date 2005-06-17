From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 2/9] ixgb: Fix unnecessary link state messages
Date: Fri, 17 Jun 2005 16:57:56 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0506131234090.24260@anoushka.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix unnecessary link state messages

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
 
diff -up netdev-2.6/drivers/net/ixgb/ixgb_ethtool.c netdev-2.6/drivers/net/ixgb.new/ixgb_ethtool.c
--- netdev-2.6/drivers/net/ixgb/ixgb_ethtool.c	2005-05-25 12:26:48.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_ethtool.c	2005-05-25 12:26:56.000000000 -0700
@@ -130,6 +130,12 @@ ixgb_get_settings(struct net_device *net
 		ixgb_down(adapter, TRUE);
 		ixgb_reset(adapter);
 		ixgb_up(adapter);
+		/* be optimistic about our link, since we were up before */
+		adapter->link_speed = 10000;
+		adapter->link_duplex = FULL_DUPLEX;
+		netif_carrier_on(netdev);
+		netif_wake_queue(netdev);
+		
 	} else
 		ixgb_reset(adapter);
 
@@ -177,6 +181,11 @@ ixgb_set_pauseparam(struct net_device *n
 	if(netif_running(adapter->netdev)) {
 		ixgb_down(adapter, TRUE);
 		ixgb_up(adapter);
+		/* be optimistic about our link, since we were up before */
+		adapter->link_speed = 10000;
+		adapter->link_duplex = FULL_DUPLEX;
+		netif_carrier_on(netdev);
+		netif_wake_queue(netdev);
 	} else
 		ixgb_reset(adapter);
 		
@@ -199,6 +181,11 @@ 
 	if(netif_running(netdev)) {
 		ixgb_down(adapter,TRUE);
 		ixgb_up(adapter);
+		/* be optimistic about our link, since we were up before */
+		adapter->link_speed = 10000;
+		adapter->link_duplex = FULL_DUPLEX;
+		netif_carrier_on(netdev);
+		netif_wake_queue(netdev);
 	} else
 		ixgb_reset(adapter);
 	return 0;
@@ -573,6 +573,11 @@ ixgb_set_ringparam(struct net_device *ne
 		adapter->tx_ring = tx_new;
 		if((err = ixgb_up(adapter)))
 			return err;
+		/* be optimistic about our link, since we were up before */
+		adapter->link_speed = 10000;
+		adapter->link_duplex = FULL_DUPLEX;
+		netif_carrier_on(netdev);
+		netif_wake_queue(netdev);
 	}
 
 	return 0;
