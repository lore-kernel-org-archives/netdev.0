From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH 02/11] dccp: move route updating for redirect to ndisc layer
Date: Thu, 12 Sep 2013 18:44:49 +0800
Message-ID: <52319B21.6080203@cn.fujitsu.com>
References: <52319A6E.6090503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:41758 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751831Ab3ILKpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 06:45:45 -0400
In-Reply-To: <52319A6E.6090503@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

In additon, like net/ipv6/tcp_ipv6.c, when dealing with
redirect message, it should directly return;

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/dccp/ipv6.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9c61f9c..300840c 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -98,6 +98,9 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 	}
 
+	if (type == NDISC_REDIRECT)
+		return;
+
 	sk = inet6_lookup(net, &dccp_hashinfo,
 			&hdr->daddr, dh->dccph_dport,
 			&hdr->saddr, dh->dccph_sport, inet6_iif(skb));
@@ -130,13 +133,6 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	np = inet6_sk(sk);
 
-	if (type == NDISC_REDIRECT) {
-		struct dst_entry *dst = __sk_dst_check(sk, np->dst_cookie);
-
-		if (dst)
-			dst->ops->redirect(dst, sk, skb);
-	}
-
 	if (type == ICMPV6_PKT_TOOBIG) {
 		struct dst_entry *dst = NULL;
 
-- 
1.8.3.1
