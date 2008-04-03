From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] ipv4: fib_trie remove unused argument
Date: Wed, 2 Apr 2008 21:57:24 -0700
Message-ID: <20080402215724.4cf5fbf0@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:47731 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbYDCE7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 00:59:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The trie pointer is passed down to flush_list and flush_leaf
but never used.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/fib_trie.c	2008-04-02 10:55:44.000000000 -0700
+++ b/net/ipv4/fib_trie.c	2008-04-02 11:01:04.000000000 -0700
@@ -1665,7 +1665,7 @@ static int fn_trie_delete(struct fib_tab
 	return 0;
 }
 
-static int trie_flush_list(struct trie *t, struct list_head *head)
+static int trie_flush_list(struct list_head *head)
 {
 	struct fib_alias *fa, *fa_node;
 	int found = 0;
@@ -1683,7 +1683,7 @@ static int trie_flush_list(struct trie *
 	return found;
 }
 
-static int trie_flush_leaf(struct trie *t, struct leaf *l)
+static int trie_flush_leaf(struct leaf *l)
 {
 	int found = 0;
 	struct hlist_head *lih = &l->list;
@@ -1691,7 +1691,7 @@ static int trie_flush_leaf(struct trie *
 	struct leaf_info *li = NULL;
 
 	hlist_for_each_entry_safe(li, node, tmp, lih, hlist) {
-		found += trie_flush_list(t, &li->falh);
+		found += trie_flush_list(&li->falh);
 
 		if (list_empty(&li->falh)) {
 			hlist_del_rcu(&li->hlist);
@@ -1782,7 +1782,7 @@ static int fn_trie_flush(struct fib_tabl
 	int found = 0;
 
 	for (l = trie_firstleaf(t); l; l = trie_nextleaf(l)) {
-		found += trie_flush_leaf(t, l);
+		found += trie_flush_leaf(l);
 
 		if (ll && hlist_empty(&ll->list))
 			trie_leaf_remove(t, ll);
