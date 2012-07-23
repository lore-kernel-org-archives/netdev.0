From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3] net: Make skb->skb_iif always track skb->dev
Date: Mon, 23 Jul 2012 16:45:42 -0700 (PDT)
Message-ID: <20120723.164542.1890653324956444632.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755130Ab2GWXpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 19:45:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Make it follow device decapsulation, from things such as VLAN and
bonding.

The stuff that actually cares about pre-demuxed device pointers, is
handled by the "orig_dev" variable in __netif_receive_skb().  And
the only consumer of that is the po->origdev feature of AF_PACKET
sockets.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index cca02ae..0ebaea1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3173,8 +3173,6 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	if (netpoll_receive_skb(skb))
 		return NET_RX_DROP;
 
-	if (!skb->skb_iif)
-		skb->skb_iif = skb->dev->ifindex;
 	orig_dev = skb->dev;
 
 	skb_reset_network_header(skb);
@@ -3186,6 +3184,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	rcu_read_lock();
 
 another_round:
+	skb->skb_iif = skb->dev->ifindex;
 
 	__this_cpu_inc(softnet_data.processed);
 
-- 
1.7.10.4
