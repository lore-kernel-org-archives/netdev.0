From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 08/17] ndisc: Set skb->dev and skb->protocol inside
 ndisc_alloc_skb().
Date: Tue, 18 Dec 2012 19:54:42 +0900
Message-ID: <50D04B72.9080801@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56619 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754178Ab2LRKyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:54:43 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index f2942f3..b32f079 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -388,20 +388,18 @@ static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
 		return NULL;
 	}
 
+	skb->protocol = htons(ETH_P_IPV6);
+	skb->dev = dev;
+
 	skb_reserve(skb, hlen);
 	return skb;
 }
 
-static void ip6_nd_hdr(struct sk_buff *skb, struct net_device *dev,
-		       const struct in6_addr *saddr,
-		       const struct in6_addr *daddr,
-		       int hoplimit, int len)
+static void ip6_nd_hdr(struct sk_buff *skb, const struct in6_addr *saddr,
+		       const struct in6_addr *daddr, int hoplimit, int len)
 {
 	struct ipv6hdr *hdr;
 
-	skb->protocol = htons(ETH_P_IPV6);
-	skb->dev = dev;
-
 	skb_reset_network_header(skb);
 	skb_put(skb, sizeof(struct ipv6hdr));
 	hdr = ipv6_hdr(skb);
@@ -435,7 +433,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (!skb)
 		return NULL;
 
-	ip6_nd_hdr(skb, dev, saddr, daddr, inet6_sk(sk)->hop_limit, len);
+	ip6_nd_hdr(skb, saddr, daddr, inet6_sk(sk)->hop_limit, len);
 
 	skb->transport_header = skb->tail;
 	skb_put(skb, len);
@@ -1459,7 +1457,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	ip6_nd_hdr(buff, dev, &saddr_buf, &ipv6_hdr(skb)->saddr,
+	ip6_nd_hdr(buff, &saddr_buf, &ipv6_hdr(skb)->saddr,
 		   inet6_sk(sk)->hop_limit, len);
 
 	skb_set_transport_header(buff, skb_tail_pointer(buff) - buff->data);
-- 
1.7.9.5
