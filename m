From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/3] ipv4: Always call ip_options_build() after rest of IP
 header is filled in.
Date: Fri, 13 May 2011 17:51:37 -0400 (EDT)
Message-ID: <20110513.175137.693283908570960534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48459 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757238Ab1EMVvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 17:51:39 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4DLpbNZ021427
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:51:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This will allow ip_options_build() to reliably look at the values of
iph->{daddr,saddr}

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_output.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 70778d4..98af369 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1327,10 +1327,6 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	iph = (struct iphdr *)skb->data;
 	iph->version = 4;
 	iph->ihl = 5;
-	if (opt) {
-		iph->ihl += opt->optlen>>2;
-		ip_options_build(skb, opt, cork->addr, rt, 0);
-	}
 	iph->tos = inet->tos;
 	iph->frag_off = df;
 	ip_select_ident(iph, &rt->dst, sk);
@@ -1339,6 +1335,11 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	iph->saddr = fl4->saddr;
 	iph->daddr = fl4->daddr;
 
+	if (opt) {
+		iph->ihl += opt->optlen>>2;
+		ip_options_build(skb, opt, cork->addr, rt, 0);
+	}
+
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 	/*
-- 
1.7.4.4

