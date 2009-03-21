From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 50/77] lapbether: convert to internal net_device_stats
Date: Fri, 20 Mar 2009 22:36:17 -0700
Message-ID: <20090321053716.346826057@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36657 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760813AbZCUFsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:19 -0400
Content-Disposition: inline; filename=lapbether-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wan/lapbether.c	2009-03-20 21:45:41.177964217 -0700
+++ b/drivers/net/wan/lapbether.c	2009-03-20 22:04:49.754653610 -0700
@@ -55,7 +55,6 @@ struct lapbethdev {
 	struct list_head	node;
 	struct net_device	*ethdev;	/* link to ethernet device */
 	struct net_device	*axdev;		/* lapbeth device (lapb#) */
-	struct net_device_stats stats;		/* some statistics */
 };
 
 static LIST_HEAD(lapbeth_devices);
@@ -107,10 +106,9 @@ static int lapbeth_rcv(struct sk_buff *s
 	if (!netif_running(lapbeth->axdev))
 		goto drop_unlock;
 
-	lapbeth->stats.rx_packets++;
-
 	len = skb->data[0] + skb->data[1] * 256;
-	lapbeth->stats.rx_bytes += len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += len;
 
 	skb_pull(skb, 2);	/* Remove the length bytes */
 	skb_trim(skb, len);	/* Set the length of the data */
@@ -210,8 +208,8 @@ static void lapbeth_data_transmit(struct
 	*ptr++ = size % 256;
 	*ptr++ = size / 256;
 
-	lapbeth->stats.tx_packets++;
-	lapbeth->stats.tx_bytes += size;
+	ndev->stats.tx_packets++;
+	ndev->stats.tx_bytes += size;
 
 	skb->dev = dev = lapbeth->ethdev;
 
@@ -255,15 +253,6 @@ static void lapbeth_disconnected(struct 
 }
 
 /*
- *	Statistics
- */
-static struct net_device_stats *lapbeth_get_stats(struct net_device *dev)
-{
-	struct lapbethdev *lapbeth = netdev_priv(dev);
-	return &lapbeth->stats;
-}
-
-/*
  *	Set AX.25 callsign
  */
 static int lapbeth_set_mac_address(struct net_device *dev, void *addr)
@@ -321,7 +310,6 @@ static void lapbeth_setup(struct net_dev
 	dev->stop	     = lapbeth_close;
 	dev->destructor	     = free_netdev;
 	dev->set_mac_address = lapbeth_set_mac_address;
-	dev->get_stats	     = lapbeth_get_stats;
 	dev->type            = ARPHRD_X25;
 	dev->hard_header_len = 3;
 	dev->mtu             = 1000;

-- 

