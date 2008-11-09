From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/2] dsa: fix skb->pkt_type when mac address of slave interface differs
Date: Mon, 10 Nov 2008 00:22:55 +0100
Message-ID: <20081109232255.GD32552@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:54003 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756500AbYKIXW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2008 18:22:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a dsa slave interface has a mac address that differs from that
of the master interface, eth_type_trans() won't explicitly set
skb->pkt_type back to PACKET_HOST -- we need to do this ourselves
before calling eth_type_trans().

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index bdc0510..3186654 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -159,6 +159,7 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	skb->dev = ds->ports[source_port];
 	skb_push(skb, ETH_HLEN);
+	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, skb->dev);
 
 	skb->dev->last_rx = jiffies;
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index f985ea9..9f4ce55 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -178,6 +178,7 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	skb->dev = ds->ports[source_port];
 	skb_push(skb, ETH_HLEN);
+	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, skb->dev);
 
 	skb->dev->last_rx = jiffies;
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index d311776..efd2669 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -95,6 +95,7 @@ static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	skb->dev = ds->ports[source_port];
 	skb_push(skb, ETH_HLEN);
+	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, skb->dev);
 
 	skb->dev->last_rx = jiffies;
