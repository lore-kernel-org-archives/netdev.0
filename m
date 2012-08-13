From: igorm@etf.rs
Subject: [PATCH] net: ipv4: fib_trie: Don't unnecessarily search for already found fib leaf
Date: Mon, 13 Aug 2012 10:26:08 +0200
Message-ID: <1344846368-4141-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:52055 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753517Ab2HMIuk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 04:50:40 -0400
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

We've already found leaf, don't search for it again. Same is for fib leaf info.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 net/ipv4/fib_trie.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 30b88d7..8063a8c 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1657,7 +1657,12 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	if (!l)
 		return -ESRCH;
 
-	fa_head = get_fa_head(l, plen);
+	li = find_leaf_info(l, plen);
+
+	if (!li)
+		return -ESRCH;
+
+	fa_head = &li->falh;
 	fa = fib_find_alias(fa_head, tos, 0);
 
 	if (!fa)
@@ -1693,9 +1698,6 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
-	l = fib_find_node(t, key);
-	li = find_leaf_info(l, plen);
-
 	list_del_rcu(&fa->fa_list);
 
 	if (!plen)
-- 
1.7.9.5
