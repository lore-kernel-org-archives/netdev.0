From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 14/19] ndisc: Remove icmp6h argument from ndisc_send_skb().
Date: Tue, 22 Jan 2013 01:48:58 +0900
Message-ID: <50FD717A.5040807@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50371 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753053Ab3AUQs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:48:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_transport_header() (thus icmp6_hdr()) is available here,
use it.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index ed78644..f0c436b 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -465,8 +465,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 
 static void ndisc_send_skb(struct sk_buff *skb,
 			   const struct in6_addr *daddr,
-			   const struct in6_addr *saddr,
-			   struct icmp6hdr *icmp6h)
+			   const struct in6_addr *saddr)
 {
 	struct flowi6 fl6;
 	struct dst_entry *dst;
@@ -474,6 +473,7 @@ static void ndisc_send_skb(struct sk_buff *skb,
 	struct sock *sk = net->ipv6.ndisc_sk;
 	struct inet6_dev *idev;
 	int err;
+	struct icmp6hdr *icmp6h = icmp6_hdr(skb);
 	u8 type;
 
 	type = icmp6h->icmp6_type;
@@ -516,7 +516,7 @@ static void __ndisc_send(struct net_device *dev,
 	if (!skb)
 		return;
 
-	ndisc_send_skb(skb, daddr, saddr, icmp6h);
+	ndisc_send_skb(skb, daddr, saddr);
 }
 
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
-- 
1.7.9.5
