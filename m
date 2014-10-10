From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH net-next 1/2] macvlan: pass 'bool' type to macvlan_count_rx()
Date: Fri, 10 Oct 2014 03:13:27 +0000 (GMT)
Message-ID: <963dbe730f442c6fca6ff3b34221b2fc96409ab3.1412908929.git.jbaron@akamai.com>
References: <cover.1412908929.git.jbaron@akamai.com>
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
	vyasevich@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:44582 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751128AbaJJDN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 23:13:28 -0400
In-Reply-To: <cover.1412908929.git.jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass last argument to macvlan_count_rx() as the correct bool type.

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 drivers/net/macvlan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 38b4fae..c7c58af 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -260,7 +260,7 @@ static void macvlan_broadcast(struct sk_buff *skb,
 					mode == MACVLAN_MODE_BRIDGE) ?:
 				      netif_rx_ni(nskb);
 			macvlan_count_rx(vlan, skb->len + ETH_HLEN,
-					 err == NET_RX_SUCCESS, 1);
+					 err == NET_RX_SUCCESS, true);
 		}
 	}
 }
@@ -379,7 +379,7 @@ static void macvlan_forward_source_one(struct sk_buff *skb,
 	nskb->pkt_type = PACKET_HOST;
 
 	ret = netif_rx(nskb);
-	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
+	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, false);
 }
 
 static void macvlan_forward_source(struct sk_buff *skb,
@@ -457,7 +457,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 	ret = netif_rx(skb);
 
 out:
-	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, 0);
+	macvlan_count_rx(vlan, len, ret == NET_RX_SUCCESS, false);
 	return RX_HANDLER_CONSUMED;
 }
 
-- 
1.8.2.rc2
