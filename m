From: Jouni Malinen <jouni@codeaurora.org>
Subject: [PATCH 1/3] bridge: Base the BR_PROXYARP decision on the target port flag
Date: Wed,  4 Feb 2015 11:51:05 +0200
Message-ID: <1423043467-11148-1-git-send-email-jouni@codeaurora.org>
Cc: netdev@vger.kernel.org, Kyeyoon Park <kyeyoonp@codeaurora.org>,
	Jouni Malinen <jouni@codeaurora.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:42395 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964916AbbBDJwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 04:52:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyeyoon Park <kyeyoonp@codeaurora.org>

When doing proxy ARP, instead of checking the bridge port flag for
BR_PROXYARP on the bridge port on which the frame was received, check
the bridge port flag of the bridge port to which the target device
belongs.

Signed-off-by: Kyeyoon Park <kyeyoonp@codeaurora.org>
Signed-off-by: Jouni Malinen <jouni@codeaurora.org>
---
 net/bridge/br_input.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index e2aa7be..cfd46c6 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -105,7 +105,7 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 		}
 
 		f = __br_fdb_get(br, n->ha, vid);
-		if (f)
+		if (f && f->dst->flags & BR_PROXYARP)
 			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, skb->dev, tip,
 				 sha, n->ha, sha);
 
@@ -155,7 +155,6 @@ int br_handle_frame_finish(struct sk_buff *skb)
 
 	if (is_broadcast_ether_addr(dest)) {
 		if (IS_ENABLED(CONFIG_INET) &&
-		    p->flags & BR_PROXYARP &&
 		    skb->protocol == htons(ETH_P_ARP))
 			br_do_proxy_arp(skb, br, vid);
 
-- 
1.9.1
