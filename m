From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 07/19] ndisc: Simplify arguments for ip6_nd_hdr().
Date: Tue, 22 Jan 2013 01:48:24 +0900
Message-ID: <50FD7158.3070302@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50349 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752869Ab3AUQsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:48:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 7ce266f..05c6996 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -389,11 +389,10 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 	return skb;
 }
 
-static void ip6_nd_hdr(struct sock *sk,
-		       struct sk_buff *skb, struct net_device *dev,
+static void ip6_nd_hdr(struct sk_buff *skb, struct net_device *dev,
 		       const struct in6_addr *saddr,
 		       const struct in6_addr *daddr,
-		       int proto, int len)
+		       int hop_limit, int len)
 {
 	struct ipv6hdr *hdr;
 
@@ -407,8 +406,8 @@ static void ip6_nd_hdr(struct sock *sk,
 	ip6_flow_hdr(hdr, 0, 0);
 
 	hdr->payload_len = htons(len);
-	hdr->nexthdr = proto;
-	hdr->hop_limit = inet6_sk(sk)->hop_limit;
+	hdr->nexthdr = IPPROTO_ICMPV6;
+	hdr->hop_limit = hop_limit;
 
 	hdr->saddr = *saddr;
 	hdr->daddr = *daddr;
@@ -439,7 +438,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (!skb)
 		return NULL;
 
-	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
+	ip6_nd_hdr(skb, dev, saddr, daddr, inet6_sk(sk)->hop_limit, len);
 
 	skb->transport_header = skb->tail;
 	skb_put(skb, len);
@@ -1480,8 +1479,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	ip6_nd_hdr(sk, buff, dev, &saddr_buf, &ipv6_hdr(skb)->saddr,
-		   IPPROTO_ICMPV6, len);
+	ip6_nd_hdr(buff, dev, &saddr_buf, &ipv6_hdr(skb)->saddr,
+		   inet6_sk(sk)->hop_limit, len);
 
 	skb_set_transport_header(buff, skb_tail_pointer(buff) - buff->data);
 	skb_put(buff, len);
-- 
1.7.9.5
