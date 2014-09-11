From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 3/6] ipv6: if no function for cleaner is specified only visit nodes
Date: Fri, 12 Sep 2014 01:21:50 +0200
Message-ID: <ee139a874fbb76f5116e9a66e764382d5cfaf6d2.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:53524 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753938AbaIKXWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 19:22:02 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 197DE20D33
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 19:22:02 -0400 (EDT)
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1410477596.git.hannes@stressinduktion.org>
References: <cover.1410477596.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We now allow NULL rt6_info walker functions to we only visit nodes.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 101efab..590c5d2 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1529,6 +1529,13 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 	if (c->sernum)
 		c->w.node->fn_sernum = c->sernum;
 
+	/* if func is NULL only visit node to update sernum */
+	if (!c->func) {
+		WARN_ON_ONCE(!c->sernum);
+		w->leaf = NULL;
+		return 0;
+	}
+
 	for (rt = w->leaf; rt; rt = rt->dst.rt6_next) {
 		res = c->func(rt, c->arg);
 		if (res < 0) {
-- 
1.9.3
