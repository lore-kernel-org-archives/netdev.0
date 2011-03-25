From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: do not ignore route errors
Date: Sat, 26 Mar 2011 01:45:25 +0200
Message-ID: <201103252345.p2PNjP1n025209@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51816 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752095Ab1CYXjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2011 19:39:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	The "ipv4: Inline fib_semantic_match into check_leaf"
change forgets to return the route errors. check_leaf should
return the same results as fib_table_lookup.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/fib_trie.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -urp net-2.6-fcd13f4/linux/net/ipv4/fib_trie.c linux/net/ipv4/fib_trie.c
--- net-2.6-fcd13f4/linux/net/ipv4/fib_trie.c	2011-03-25 22:33:44.000000000 +0200
+++ linux/net/ipv4/fib_trie.c	2011-03-26 01:37:15.027383449 +0200
@@ -1365,9 +1365,9 @@ static int check_leaf(struct fib_table *
 			err = fib_props[fa->fa_type].error;
 			if (err) {
 #ifdef CONFIG_IP_FIB_TRIE_STATS
-				t->stats.semantic_match_miss++;
+				t->stats.semantic_match_passed++;
 #endif
-				return 1;
+				return err;
 			}
 			if (fi->fib_flags & RTNH_F_DEAD)
 				continue;
