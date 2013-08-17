From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH ipsec 2/3] ipv6: xfrm: dereference inner ipv6 header if encapsulated
Date: Sat, 17 Aug 2013 19:51:30 +0200
Message-ID: <20130817175130.GA7039@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57919 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992Ab3HQRvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 13:51:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In xfrm6_local_error use inner_header if the packet was encapsulated.

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

This patch is based on Steffen Klassert's ipsec tree. 

 net/ipv6/xfrm6_output.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 3ac5ab2..45effcc 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -59,10 +59,12 @@ static void xfrm6_local_rxpmtu(struct sk_buff *skb, u32 mtu)
 void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
 {
 	struct flowi6 fl6;
+	struct ipv6hdr *hdr;
 	struct sock *sk = skb->sk;
 
+	hdr = skb->encapsulation ? inner_ipv6_hdr(skb) : ipv6_hdr(skb);
 	fl6.fl6_dport = inet_sk(sk)->inet_dport;
-	fl6.daddr = ipv6_hdr(skb)->daddr;
+	fl6.daddr = hdr->daddr;
 
 	ipv6_local_error(sk, EMSGSIZE, &fl6, mtu);
 }
-- 
1.8.3.1
