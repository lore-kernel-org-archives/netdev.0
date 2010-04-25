From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6] bridge br_multicast: Ensure to initialize BR_INPUT_SKB_CB(skb)->mrouters_only.
Date: Mon, 26 Apr 2010 03:06:40 +0900
Message-ID: <201004251806.o3PI6e2p008200@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.rg, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46009 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652Ab0DYSGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 14:06:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even with commit 32dec5dd0233ebffa9cae25ce7ba6daeb7df4467 ("bridge
br_multicast: Don't refer to BR_INPUT_SKB_CB(skb)->mrouters_only
without IGMP snooping."), BR_INPUT_SKB_CB(skb)->mrouters_only is
not appropriately initialized if IGMP/MLD snooping support is
compiled and disabled, so we can see garbage.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/bridge/br_multicast.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 38d1fbd..e481dbd 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1340,9 +1340,6 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	unsigned offset;
 	int err;
 
-	BR_INPUT_SKB_CB(skb)->igmp = 0;
-	BR_INPUT_SKB_CB(skb)->mrouters_only = 0;
-
 	/* We treat OOM as packet loss for now. */
 	if (!pskb_may_pull(skb, sizeof(*iph)))
 		return -EINVAL;
@@ -1440,9 +1437,6 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	unsigned offset;
 	int err;
 
-	BR_INPUT_SKB_CB(skb)->igmp = 0;
-	BR_INPUT_SKB_CB(skb)->mrouters_only = 0;
-
 	if (!pskb_may_pull(skb, sizeof(*ip6h)))
 		return -EINVAL;
 
@@ -1550,6 +1544,9 @@ out:
 int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 		     struct sk_buff *skb)
 {
+	BR_INPUT_SKB_CB(skb)->igmp = 0;
+	BR_INPUT_SKB_CB(skb)->mrouters_only = 0;
+
 	if (br->multicast_disabled)
 		return 0;
 
-- 
1.5.6.5

