From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6] bridge br_multicast: Ensure to initialize BR_INPUT_SKB_CB(skb)->mrouters_only.
Date: Mon, 26 Apr 2010 03:59:07 +0900
Message-ID: <201004251859.o3PIx7Vo012485@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:47088 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373Ab0DYS7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 14:59:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even with commit 32dec5dd0233ebffa9cae25ce7ba6daeb7df4467 ("bridge
br_multicast: Don't refer to BR_INPUT_SKB_CB(skb)->mrouters_only
without IGMP snooping."), BR_INPUT_SKB_CB(skb)->mrouters_only is
not appropriately initialized if IGMP snooping support is
compiled and disabled, so we can see garbage.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/bridge/br_multicast.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 386c153..eaa0e1b 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -957,9 +957,6 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	unsigned offset;
 	int err;
 
-	BR_INPUT_SKB_CB(skb)->igmp = 0;
-	BR_INPUT_SKB_CB(skb)->mrouters_only = 0;
-
 	/* We treat OOM as packet loss for now. */
 	if (!pskb_may_pull(skb, sizeof(*iph)))
 		return -EINVAL;
@@ -1049,6 +1046,9 @@ err_out:
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

