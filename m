From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/14] tcp: Optimise GRO port comparisons
Date: Wed, 27 May 2009 14:50:24 +1000
Message-ID: <E1M9B5s-0001Rk-Em@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49809 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754719AbZE0FHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:07:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp: Optimise GRO port comparisons

Instead of doing two 16-bit operations for the source/destination
ports, we can do one 32-bit operation to take care both.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/tcp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 7a0f0b2..ff6adec 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2544,7 +2544,7 @@ struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 		th2 = tcp_hdr(p);
 
-		if ((th->source ^ th2->source) | (th->dest ^ th2->dest)) {
+		if (*(u32 *)&th->source ^ *(u32 *)&th2->source) {
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
