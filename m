From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH 08/11] ipv6: move route updating for redirect to ndisc layer
Date: Thu, 12 Sep 2013 18:50:43 +0800
Message-ID: <52319C83.20406@cn.fujitsu.com>
References: <52319A6E.6090503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:30888 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751379Ab3ILKvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 06:51:40 -0400
In-Reply-To: <52319A6E.6090503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>


Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv6/tcp_ipv6.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5c71501..d3ca8a4 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -346,6 +346,10 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	__u32 seq;
 	struct net *net = dev_net(skb->dev);
 
+
+	if (type == NDISC_REDIRECT)
+		return;
+
 	sk = inet6_lookup(net, &tcp_hashinfo, &hdr->daddr,
 			th->dest, &hdr->saddr, th->source, skb->dev->ifindex);
 
@@ -382,14 +386,6 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	np = inet6_sk(sk);
 
-	if (type == NDISC_REDIRECT) {
-		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
-
-		if (dst)
-			dst->ops->redirect(dst, sk, skb);
-		goto out;
-	}
-
 	if (type == ICMPV6_PKT_TOOBIG) {
 		/* We are not interested in TCP_LISTEN and open_requests
 		 * (SYN-ACKs send out by Linux are always <576bytes so
-- 
1.8.3.1
