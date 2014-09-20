From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 4/8] ipv6: if no function for cleaner is specified only visit fib6_nodes
Date: Sun, 21 Sep 2014 00:05:21 +0200
Message-ID: <fd290b544e615a1452622860ac61d214423e15ec.1411249633.git.hannes@stressinduktion.org>
References: <cover.1411249633.git.hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:44495 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751061AbaITWFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 18:05:37 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 0B0DD20446
	for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:05:37 -0400 (EDT)
In-Reply-To: <cover.1411249633.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1411249633.git.hannes@stressinduktion.org>
References: <cover.1411249633.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We now allow NULL rt6_info walker functions to we only visit nodes.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 0725fc1..8db8b1c 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1518,6 +1518,12 @@ static int fib6_clean_node(struct fib6_walker_t *w)
 	if (c->sernum != FIB6_NO_SERNUM_CHANGE)
 		c->w.node->fn_sernum = c->sernum;
 
+	if (!c->func) {
+		WARN_ON_ONCE(c->sernum == FIB6_NO_SERNUM_CHANGE);
+		w->leaf = NULL;
+		return 0;
+	}
+
 	for (rt = w->leaf; rt; rt = rt->dst.rt6_next) {
 		res = c->func(rt, c->arg);
 		if (res < 0) {
-- 
1.9.3
