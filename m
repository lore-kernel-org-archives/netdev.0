From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/2] ipv6: call iptunnel_xmit with NULL sock pointer if no tunnel sock is available
Date: Wed,  8 Apr 2015 17:01:23 +0200
Message-ID: <8994d7096bfee43cc0313b1776478536f785793e.1428505261.git.hannes@stressinduktion.org>
References: <46878d19779a655995b36701de854cb23a3bf4b5.1428505261.git.hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:54335 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754116AbbDHPBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 11:01:30 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 57E722051F
	for <netdev@vger.kernel.org>; Wed,  8 Apr 2015 11:01:26 -0400 (EDT)
Received: from stressinduktion.org (unknown [217.192.177.51])
	by mail.messagingengine.com (Postfix) with ESMTPA id CACA46800A8
	for <netdev@vger.kernel.org>; Wed,  8 Apr 2015 11:01:29 -0400 (EDT)
In-Reply-To: <46878d19779a655995b36701de854cb23a3bf4b5.1428505261.git.hannes@stressinduktion.org>
In-Reply-To: <46878d19779a655995b36701de854cb23a3bf4b5.1428505261.git.hannes@stressinduktion.org>
References: <46878d19779a655995b36701de854cb23a3bf4b5.1428505261.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 79b16aadea32cce ("udp_tunnel: Pass UDP socket down through udp_tunnel{, 6}_xmit_skb().")
Reported-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/sit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 6cf2026..ac35a28 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -983,7 +983,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 
 	skb_set_inner_ipproto(skb, IPPROTO_IPV6);
 
-	err = iptunnel_xmit(skb->sk, rt, skb, fl4.saddr, fl4.daddr,
+	err = iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr,
 			    protocol, tos, ttl, df,
 			    !net_eq(tunnel->net, dev_net(dev)));
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
-- 
2.1.0
