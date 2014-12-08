From: Jouni Malinen <jouni@codeaurora.org>
Subject: [PATCH] bridge: Remove BR_PROXYARP flooding check code
Date: Mon,  8 Dec 2014 17:27:40 +0200
Message-ID: <1418052460-30691-1-git-send-email-jouni@codeaurora.org>
Cc: netdev@vger.kernel.org, Kyeyoon Park <kyeyoonp@codeaurora.org>,
	Jouni Malinen <jouni@codeaurora.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:46748 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbaLHP2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 10:28:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyeyoon Park <kyeyoonp@codeaurora.org>

Because dropping broadcast packets for IEEE 802.11 Proxy ARP is more
selective than previously thought, it is better to remove the direct
dropping logic in the bridge code in favor of using the netfilter
infrastructure to provide more control on which frames get dropped. This
code was added in commit 958501163ddd ("bridge: Add support for IEEE
802.11 Proxy ARP").

Signed-off-by: Kyeyoon Park <kyeyoonp@codeaurora.org>
Signed-off-by: Jouni Malinen <jouni@codeaurora.org>
---
 net/bridge/br_forward.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index f96933a..8a025a7 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -185,10 +185,6 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		if (unicast && !(p->flags & BR_FLOOD))
 			continue;
 
-		/* Do not flood to ports that enable proxy ARP */
-		if (p->flags & BR_PROXYARP)
-			continue;
-
 		prev = maybe_deliver(prev, p, skb, __packet_hook);
 		if (IS_ERR(prev))
 			goto out;
-- 
1.9.1
