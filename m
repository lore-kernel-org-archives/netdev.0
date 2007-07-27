From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT 3/4] fib_trie: fix sparse warnings
Date: Fri, 27 Jul 2007 08:59:20 +0100
Message-ID: <20070727080049.717355554@linux-foundation.org>
References: <20070727075917.470055328@linux-foundation.org>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51522 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764335AbXG0IBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 04:01:37 -0400
Content-Disposition: inline; filename=fib-trie-sparse.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There were a couple of places where sparse found declarations that covered
earlier declarations.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/ipv4/fib_trie.c	2007-07-27 08:41:46.000000000 +0100
+++ b/net/ipv4/fib_trie.c	2007-07-27 08:47:05.000000000 +0100
@@ -651,7 +651,6 @@ static struct node *resize(struct trie *
 
 static struct tnode *inflate(struct trie *t, struct tnode *tn)
 {
-	struct tnode *inode;
 	struct tnode *oldtnode = tn;
 	int olen = tnode_child_length(tn);
 	int i;
@@ -700,7 +699,7 @@ static struct tnode *inflate(struct trie
 
 	for (i = 0; i < olen; i++) {
 		struct node *node = tnode_get_child(oldtnode, i);
-		struct tnode *left, *right;
+		struct tnode *left, *right, *inode;
 		int size, j;
 
 		/* An empty child */
@@ -1049,7 +1048,7 @@ fib_insert_node(struct trie *t, int *err
 	/* Case 1: n is a leaf. Compare prefixes */
 
 	if (n != NULL && IS_LEAF(n) && tkey_equals(key, n->key)) {
-		struct leaf *l = (struct leaf *) n;
+		struct leaf *nl = (struct leaf *) n;
 
 		li = leaf_info_new(plen);
 
@@ -1059,7 +1058,7 @@ fib_insert_node(struct trie *t, int *err
 		}
 
 		fa_head = &li->falh;
-		insert_leaf_info(&l->list, li);
+		insert_leaf_info(&nl->list, li);
 		goto done;
 	}
 	t->size++;

-- 

