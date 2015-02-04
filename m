From: Jouni Malinen <jouni@codeaurora.org>
Subject: [PATCH 3/3] bridge: Allow proxy ARP for unicast ARP requests
Date: Wed,  4 Feb 2015 11:51:07 +0200
Message-ID: <1423043467-11148-3-git-send-email-jouni@codeaurora.org>
References: <1423043467-11148-1-git-send-email-jouni@codeaurora.org>
Cc: netdev@vger.kernel.org, Kyeyoon Park <kyeyoonp@codeaurora.org>,
	Jouni Malinen <jouni@codeaurora.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:42415 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964988AbbBDJwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 04:52:20 -0500
In-Reply-To: <1423043467-11148-1-git-send-email-jouni@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyeyoon Park <kyeyoonp@codeaurora.org>

It is possible for unicast ARP requests to be used and the same proxyarp
mechanism should work for them as well as for the broadcast case.

Signed-off-by: Kyeyoon Park <kyeyoonp@codeaurora.org>
Signed-off-by: Jouni Malinen <jouni@codeaurora.org>
---
 net/bridge/br_input.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 41d1d3f..c60100f 100644
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
