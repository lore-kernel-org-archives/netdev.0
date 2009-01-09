From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 34/45] bpqether: convert to internal net_device_stats
Date: Fri, 09 Jan 2009 15:01:31 -0800
Message-ID: <20090109230139.233133611@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42241 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754458AbZAIXSE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:18:04 -0500
Content-Disposition: inline; filename=bpqether-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/hamradio/bpqether.c	2009-01-08 08:30:11.000000000 -0800
+++ b/drivers/net/hamradio/bpqether.c	2009-01-08 11:51:31.000000000 -0800
@@ -110,7 +110,6 @@ struct bpqdev {
 	struct list_head bpq_list;	/* list of bpq devices chain */
 	struct net_device *ethdev;	/* link to ethernet device */
 	struct net_device *axdev;	/* bpq device (bpq#) */
-	struct net_device_stats stats;	/* some statistics */
 	char   dest_addr[6];		/* ether destination address */
 	char   acpt_addr[6];		/* accept ether frames from this address only */
 };
@@ -222,8 +221,8 @@ static int bpq_rcv(struct sk_buff *skb, 
 	skb_pull(skb, 2);	/* Remove the length bytes */
 	skb_trim(skb, len);	/* Set the length of the data */
 
-	bpq->stats.rx_packets++;
-	bpq->stats.rx_bytes += len;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += len;
 
 	ptr = skb_push(skb, 1);
 	*ptr = 0;
@@ -292,7 +291,7 @@ static int bpq_xmit(struct sk_buff *skb,
 	bpq = netdev_priv(dev);
 
 	if ((dev = bpq_get_ether_dev(dev)) == NULL) {
-		bpq->stats.tx_dropped++;
+		dev->stats.tx_dropped++;
 		kfree_skb(skb);
 		return -ENODEV;
 	}
@@ -300,8 +299,8 @@ static int bpq_xmit(struct sk_buff *skb,
 	skb->protocol = ax25_type_trans(skb, dev);
 	skb_reset_network_header(skb);
 	dev_hard_header(skb, dev, ETH_P_BPQ, bpq->dest_addr, NULL, 0);
-	bpq->stats.tx_packets++;
-	bpq->stats.tx_bytes+=skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes+=skb->len;
   
 	dev_queue_xmit(skb);
 	netif_wake_queue(dev);
@@ -309,16 +308,6 @@ static int bpq_xmit(struct sk_buff *skb,
 }
 
 /*
- *	Statistics
- */
-static struct net_device_stats *bpq_get_stats(struct net_device *dev)
-{
-	struct bpqdev *bpq = netdev_priv(dev);
-
-	return &bpq->stats;
-}
-
-/*
  *	Set AX.25 callsign
  */
 static int bpq_set_mac_address(struct net_device *dev, void *addr)


