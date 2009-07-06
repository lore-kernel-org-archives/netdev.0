From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: [patch] ipv6: correct return on ipv6_rcv() packet drop
Date: Tue, 7 Jul 2009 06:56:24 +0930
Message-ID: <20090707065624.ee55809e.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.adam.net.au ([202.136.110.249]:41250 "EHLO
	smtp3.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194AbZGFV0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 17:26:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The routine ipv6_rcv() uses magic number 0 for a return when it drops a
packet. This corresponds to NET_RX_SUCCESS, which is obviously
incorrect. Correct this by using NET_RX_DROP instead.

ps. It isn't exactly clear who the IPv6 maintainers are, apologies if
I've missed any.

Signed-off-by: Mark Smith <markzzzsmith@yahoo.com.au>


diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 8f04bd9..bb05c17 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -63,7 +63,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	if (skb->pkt_type == PACKET_OTHERHOST) {
 		kfree_skb(skb);
-		return 0;
+		return NET_RX_DROP;
 	}
 
 	rcu_read_lock();
@@ -133,7 +133,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 		if (ipv6_parse_hopopts(skb) < 0) {
 			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
 			rcu_read_unlock();
-			return 0;
+			return NET_RX_DROP;
 		}
 	}
 
@@ -146,7 +146,7 @@ err:
 drop:
 	rcu_read_unlock();
 	kfree_skb(skb);
-	return 0;
+	return NET_RX_DROP;
 }
 
 /*
