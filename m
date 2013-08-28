From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/8] ipv6: xfrm: dereference inner ipv6 header if encapsulated
Date: Wed, 28 Aug 2013 13:04:51 +0200
Message-ID: <1377687895-5780-5-git-send-email-steffen.klassert@secunet.com>
References: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56734 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753904Ab3H1LFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 07:05:06 -0400
In-Reply-To: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>

In xfrm6_local_error use inner_header if the packet was encapsulated.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_output.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 3ac5ab2..e092e30 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -59,10 +59,12 @@ static void xfrm6_local_rxpmtu(struct sk_buff *skb, u32 mtu)
 void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
 {
 	struct flowi6 fl6;
+	const struct ipv6hdr *hdr;
 	struct sock *sk = skb->sk;
 
+	hdr = skb->encapsulation ? inner_ipv6_hdr(skb) : ipv6_hdr(skb);
 	fl6.fl6_dport = inet_sk(sk)->inet_dport;
-	fl6.daddr = ipv6_hdr(skb)->daddr;
+	fl6.daddr = hdr->daddr;
 
 	ipv6_local_error(sk, EMSGSIZE, &fl6, mtu);
 }
-- 
1.7.9.5
