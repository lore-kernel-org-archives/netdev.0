From: Jouni Malinen <jouni@codeaurora.org>
Subject: [PATCH v2 3/3] bridge: Allow proxy ARP for unicast ARP requests
Date: Thu,  5 Feb 2015 11:54:23 +0200
Message-ID: <1423130063-18323-3-git-send-email-jouni@codeaurora.org>
References: <1423130063-18323-1-git-send-email-jouni@codeaurora.org>
Cc: netdev@vger.kernel.org, Kyeyoon Park <kyeyoonp@codeaurora.org>,
	Jouni Malinen <jouni@codeaurora.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:54274 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757097AbbBEJzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 04:55:11 -0500
In-Reply-To: <1423130063-18323-1-git-send-email-jouni@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyeyoon Park <kyeyoonp@codeaurora.org>

It is possible for unicast ARP requests to be used and the same proxyarp
mechanism should work for them as well as for the broadcast case.

Signed-off-by: Kyeyoon Park <kyeyoonp@codeaurora.org>
Signed-off-by: Jouni Malinen <jouni@codeaurora.org>
---
v2: rebased, but identical to v1

 net/bridge/br_input.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index c3640d8..41d7cfa 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -157,11 +157,11 @@ int br_handle_frame_finish(struct sk_buff *skb)
 
 	dst = NULL;
 
-	if (is_broadcast_ether_addr(dest)) {
-		if (IS_ENABLED(CONFIG_INET) &&
-		    skb->protocol == htons(ETH_P_ARP))
-			br_do_proxy_arp(skb, br, vid);
+	if (IS_ENABLED(CONFIG_INET) &&
+	    skb->protocol == htons(ETH_P_ARP))
+		br_do_proxy_arp(skb, br, vid);
 
+	if (is_broadcast_ether_addr(dest)) {
 		skb2 = skb;
 		unicast = false;
 	} else if (is_multicast_ether_addr(dest)) {
-- 
1.9.1
