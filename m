From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: drop frames with attached skb->sk in forwarding
Date: Thu,  8 Oct 2015 18:19:53 +0200
Message-ID: <1444321193-26486-1-git-send-email-hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:50243 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934131AbbJHQUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 12:20:02 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id CB39720DE4
	for <netdev@vger.kernel.org>; Thu,  8 Oct 2015 12:20:01 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a clone of commit 2ab957492d13b ("ip_forward: Drop frames with
attached skb->sk") for ipv6.

This commit has exactly the same reasons as the above mentioned commit,
namely to prevent panics during netfilter reload or a misconfigured stack.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_output.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index caf7d14..89b679a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -389,6 +389,9 @@ int ip6_forward(struct sk_buff *skb)
 	if (skb->pkt_type != PACKET_HOST)
 		goto drop;
 
+	if (unlikely(skb->sk))
+		goto drop;
+
 	if (skb_warn_if_lro(skb))
 		goto drop;
 
-- 
2.5.0
