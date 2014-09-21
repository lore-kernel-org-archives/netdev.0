From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2 net-next 4/9] ipv6: if no function for cleaner is specified only visit fib6_nodes
Date: Sun, 21 Sep 2014 16:11:48 +0200
Message-ID: <28641f9c60fce5968850ac2c1b6fb90cf73edd7a.1411308211.git.hannes@stressinduktion.org>
References: <cover.1411308211.git.hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, hideaki@yoshifuji.org, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:36566 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751335AbaIUOMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 10:12:09 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id B010F207DD
	for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 10:12:08 -0400 (EDT)
In-Reply-To: <cover.1411308211.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1411308211.git.hannes@stressinduktion.org>
References: <cover.1411308211.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We now allow NULL rt6_info walker functions to we only visit nodes.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index d8f0af4..4dfadd4 100644
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
