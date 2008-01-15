From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: [PATCH 4/6] [IPV4] fib_trie style cleanup
Date: Mon, 14 Jan 2008 16:47:27 -0800
Message-ID: <20080114164727.210047f6@deepthought>
References: <20080112064646.282104074@linux-foundation.org>
	<20080112.205520.55747078.davem@davemloft.net>
	<4789A29C.6080000@linux-foundation.org>
	<20080112.214417.154179770.davem@davemloft.net>
	<20080114125755.6157a3bf@deepthought>
	<20080114164450.55f8c9b2@deepthought>
	<20080114164621.2bc5011f@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:44177 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbYAOFDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 00:03:05 -0500
In-Reply-To: <20080114164621.2bc5011f@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of #ifdef, and split out embedded function calls in if statements.

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

--- a/net/ipv4/fib_trie.c	2008-01-14 14:24:58.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-14 14:26:05.000000000 -0800
@@ -1293,7 +1293,9 @@ static inline int check_leaf(struct trie
 		if (l->key != (key & ntohl(mask)))
 			continue;
 
-		if ((err = fib_semantic_match(&li->falh, flp, res, htonl(l->key), mask, i)) <= 0) {
+		err = fib_semantic_match(&li->falh, flp, res,
+					 htonl(l->key), mask, i);
+		if (err <= 0) {
 			*plen = i;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			t->stats.semantic_match_passed++;
@@ -1335,7 +1337,8 @@ fn_trie_lookup(struct fib_table *tb, con
 
 	/* Just a leaf? */
 	if (IS_LEAF(n)) {
-		if ((ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res)) <= 0)
+		ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res);
+		if (ret <= 0)
 			goto found;
 		goto failed;
 	}
@@ -1360,14 +1363,13 @@ fn_trie_lookup(struct fib_table *tb, con
 		}
 
 		if (IS_LEAF(n)) {
-			if ((ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res)) <= 0)
+			ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res);
+			if (ret <= 0)
 				goto found;
 			else
 				goto backtrace;
 		}
 
-#define HL_OPTIMIZE
-#ifdef HL_OPTIMIZE
 		cn = (struct tnode *)n;
 
 		/*
@@ -1455,7 +1457,7 @@ fn_trie_lookup(struct fib_table *tb, con
 			if (current_prefix_length >= cn->pos)
 				current_prefix_length = mp;
 		}
-#endif
+
 		pn = (struct tnode *)n; /* Descend */
 		chopped_off = 0;
 		continue;
