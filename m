From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT 4/4] fib_trie: whitespace cleanup
Date: Fri, 27 Jul 2007 08:59:21 +0100
Message-ID: <20070727080049.893283689@linux-foundation.org>
References: <20070727075917.470055328@linux-foundation.org>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42335 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764932AbXG0IBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 04:01:41 -0400
Content-Disposition: inline; filename=fib-whitespace.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Try and be consistent with whitespace and line wrapping.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/ipv4/fib_trie.c	2007-07-27 08:57:53.000000000 +0100
+++ b/net/ipv4/fib_trie.c	2007-07-27 08:57:54.000000000 +0100
@@ -154,7 +154,8 @@ struct trie {
 };
 
 static void put_child(struct trie *t, struct tnode *tn, int i, struct node *n);
-static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n, int wasfull);
+static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n,
+				  int wasfull);
 static struct node *resize(struct trie *t, struct tnode *tn);
 static struct tnode *inflate(struct trie *t, struct tnode *tn);
 static struct tnode *halve(struct trie *t, struct tnode *tn);
@@ -222,7 +223,7 @@ static inline int tkey_mismatch(t_key a,
 
 	if (!diff)
 		return 0;
-	while ((diff << i) >> (KEYLENGTH-1) == 0)
+	while ((diff << i) >> (KEYLENGTH - 1) == 0)
 		i++;
 	return i;
 }
@@ -284,7 +285,6 @@ static inline int tkey_mismatch(t_key a,
   The bits from (n->pos) to (n->pos + n->bits - 1) - "C" - are the index into
   n's child array, and will of course be different for each child.
 
-
   The rest of the bits, from (n->pos + n->bits) onward, are completely unknown
   at this point.
 
@@ -292,7 +292,7 @@ static inline int tkey_mismatch(t_key a,
 
 static inline void check_tnode(const struct tnode *tn)
 {
-	WARN_ON(tn && tn->pos+tn->bits > 32);
+	WARN_ON(tn && tn->pos + tn->bits > 32);
 }
 
 static int halve_threshold = 25;
@@ -300,7 +300,6 @@ static int inflate_threshold = 50;
 static int halve_threshold_root = 8;
 static int inflate_threshold_root = 15;
 
-
 static void __alias_free_mem(struct rcu_head *head)
 {
 	struct fib_alias *fa = container_of(head, struct fib_alias, rcu);
@@ -334,7 +333,7 @@ static struct tnode *tnode_alloc(unsigne
 	if (size <= PAGE_SIZE)
 		return kcalloc(size, 1, GFP_KERNEL);
 
-	pages = alloc_pages(GFP_KERNEL|__GFP_ZERO, get_order(size));
+	pages = alloc_pages(GFP_KERNEL | __GFP_ZERO, get_order(size));
 	if (!pages)
 		return NULL;
 
@@ -345,7 +344,7 @@ static void __tnode_free_rcu(struct rcu_
 {
 	struct tnode *tn = container_of(head, struct tnode, rcu);
 	unsigned int size = sizeof(struct tnode) +
-		(1 << tn->bits) * sizeof(struct node *);
+	    (1 << tn->bits) * sizeof(struct node *);
 
 	if (size <= PAGE_SIZE)
 		kfree(tn);
@@ -356,7 +355,7 @@ static void __tnode_free_rcu(struct rcu_
 static inline void tnode_free(struct tnode *tn)
 {
 	if (IS_LEAF(tn)) {
-		struct leaf *l = (struct leaf *) tn;
+		struct leaf *l = (struct leaf *)tn;
 		call_rcu_bh(&l->rcu, __leaf_free_rcu);
 	} else
 		call_rcu(&tn->rcu, __tnode_free_rcu);
@@ -364,7 +363,7 @@ static inline void tnode_free(struct tno
 
 static struct leaf *leaf_new(void)
 {
-	struct leaf *l = kmalloc(sizeof(struct leaf),  GFP_KERNEL);
+	struct leaf *l = kmalloc(sizeof(struct leaf), GFP_KERNEL);
 	if (l) {
 		l->parent = T_LEAF;
 		INIT_HLIST_HEAD(&l->list);
@@ -374,7 +373,7 @@ static struct leaf *leaf_new(void)
 
 static struct leaf_info *leaf_info_new(int plen)
 {
-	struct leaf_info *li = kmalloc(sizeof(struct leaf_info),  GFP_KERNEL);
+	struct leaf_info *li = kmalloc(sizeof(struct leaf_info), GFP_KERNEL);
 	if (li) {
 		li->plen = plen;
 		INIT_LIST_HEAD(&li->falh);
@@ -382,9 +381,9 @@ static struct leaf_info *leaf_info_new(i
 	return li;
 }
 
-static struct tnode* tnode_new(t_key key, int pos, int bits)
+static struct tnode *tnode_new(t_key key, int pos, int bits)
 {
-	int nchildren = 1<<bits;
+	int nchildren = 1 << bits;
 	int sz = sizeof(struct tnode) + nchildren * sizeof(struct node *);
 	struct tnode *tn = tnode_alloc(sz);
 
@@ -395,11 +394,11 @@ static struct tnode* tnode_new(t_key key
 		tn->bits = bits;
 		tn->key = key;
 		tn->full_children = 0;
-		tn->empty_children = 1<<bits;
+		tn->empty_children = 1 << bits;
 	}
 
-	pr_debug("AT %p s=%u %u\n", tn, (unsigned int) sizeof(struct tnode),
-		 (unsigned int) (sizeof(struct node) * 1<<bits));
+	pr_debug("AT %p s=%u %u\n", tn, (unsigned int)sizeof(struct tnode),
+		 (unsigned int)(sizeof(struct node) * 1 << bits));
 	return tn;
 }
 
@@ -413,10 +412,11 @@ static inline int tnode_full(const struc
 	if (n == NULL || IS_LEAF(n))
 		return 0;
 
-	return ((struct tnode *) n)->pos == tn->pos + tn->bits;
+	return ((struct tnode *)n)->pos == tn->pos + tn->bits;
 }
 
-static inline void put_child(struct trie *t, struct tnode *tn, int i, struct node *n)
+static inline void put_child(struct trie *t, struct tnode *tn, int i,
+			     struct node *n)
 {
 	tnode_put_child_reorg(tn, i, n, -1);
 }
@@ -426,13 +426,13 @@ static inline void put_child(struct trie
   * Update the value of full_children and empty_children.
   */
 
-static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n, int wasfull)
+static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n,
+				  int wasfull)
 {
 	struct node *chi = tn->child[i];
 	int isfull;
 
-	BUG_ON(i >= 1<<tn->bits);
-
+	BUG_ON(i >= 1 << tn->bits);
 
 	/* update emptyChildren */
 	if (n == NULL && chi != NULL)
@@ -565,9 +565,10 @@ static struct node *resize(struct trie *
 
 	err = 0;
 	max_resize = 10;
-	while ((tn->full_children > 0 &&  max_resize-- &&
-	       50 * (tn->full_children + tnode_child_length(tn) - tn->empty_children) >=
-				inflate_threshold_use * tnode_child_length(tn))) {
+	while ((tn->full_children > 0 && max_resize-- &&
+		50 * (tn->full_children + tnode_child_length(tn) -
+		      tn->empty_children) >=
+		inflate_threshold_use * tnode_child_length(tn))) {
 
 		old_tn = tn;
 		tn = inflate(t, tn);
@@ -582,10 +583,12 @@ static struct node *resize(struct trie *
 
 	if (max_resize < 0) {
 		if (!tn->parent)
-			printk(KERN_WARNING "Fix inflate_threshold_root. Now=%d size=%d bits\n",
+			printk(KERN_WARNING
+			       "Fix inflate_threshold_root. Now=%d size=%d bits\n",
 			       inflate_threshold_root, tn->bits);
 		else
-			printk(KERN_WARNING "Fix inflate_threshold. Now=%d size=%d bits\n",
+			printk(KERN_WARNING
+			       "Fix inflate_threshold. Now=%d size=%d bits\n",
 			       inflate_threshold, tn->bits);
 	}
 
@@ -596,7 +599,6 @@ static struct node *resize(struct trie *
 	 * node is above threshold.
 	 */
 
-
 	/* Keep root node larger  */
 
 	if (!tn->parent)
@@ -606,7 +608,7 @@ static struct node *resize(struct trie *
 
 	err = 0;
 	max_resize = 10;
-	while (tn->bits > 1 &&  max_resize-- &&
+	while (tn->bits > 1 && max_resize-- &&
 	       100 * (tnode_child_length(tn) - tn->empty_children) <
 	       halve_threshold_use * tnode_child_length(tn)) {
 
@@ -623,10 +625,12 @@ static struct node *resize(struct trie *
 
 	if (max_resize < 0) {
 		if (!tn->parent)
-			printk(KERN_WARNING "Fix halve_threshold_root. Now=%d size=%d bits\n",
+			printk(KERN_WARNING
+			       "Fix halve_threshold_root. Now=%d size=%d bits\n",
 			       halve_threshold_root, tn->bits);
 		else
-			printk(KERN_WARNING "Fix halve_threshold. Now=%d size=%d bits\n",
+			printk(KERN_WARNING
+			       "Fix halve_threshold. Now=%d size=%d bits\n",
 			       halve_threshold, tn->bits);
 	}
 
@@ -646,7 +650,7 @@ static struct node *resize(struct trie *
 			return n;
 		}
 
-	return (struct node *) tn;
+	return (struct node *)tn;
 }
 
 static struct tnode *inflate(struct trie *t, struct tnode *tn)
@@ -670,7 +674,8 @@ static struct tnode *inflate(struct trie
 	 */
 
 	for (i = 0; i < olen; i++) {
-		struct tnode *inode = (struct tnode *) tnode_get_child(oldtnode, i);
+		struct tnode *inode =
+		    (struct tnode *)tnode_get_child(oldtnode, i);
 
 		if (inode &&
 		    IS_TNODE(inode) &&
@@ -679,12 +684,12 @@ static struct tnode *inflate(struct trie
 			struct tnode *left, *right;
 			t_key m = ~0U << (KEYLENGTH - 1) >> inode->pos;
 
-			left = tnode_new(inode->key&(~m), inode->pos + 1,
+			left = tnode_new(inode->key & (~m), inode->pos + 1,
 					 inode->bits - 1);
 			if (!left)
 				goto nomem;
 
-			right = tnode_new(inode->key|m, inode->pos + 1,
+			right = tnode_new(inode->key | m, inode->pos + 1,
 					  inode->bits - 1);
 
 			if (!right) {
@@ -692,8 +697,8 @@ static struct tnode *inflate(struct trie
 				goto nomem;
 			}
 
-			put_child(t, tn, 2*i, (struct node *) left);
-			put_child(t, tn, 2*i+1, (struct node *) right);
+			put_child(t, tn, 2 * i, (struct node *)left);
+			put_child(t, tn, 2 * i + 1, (struct node *)right);
 		}
 	}
 
@@ -708,22 +713,22 @@ static struct tnode *inflate(struct trie
 
 		/* A leaf or an internal node with skipped bits */
 
-		if (IS_LEAF(node) || ((struct tnode *) node)->pos >
-		   tn->pos + tn->bits - 1) {
-			if (tkey_extract_bits(node->key, oldtnode->pos + oldtnode->bits,
-					     1) == 0)
-				put_child(t, tn, 2*i, node);
+		if (IS_LEAF(node) || ((struct tnode *)node)->pos >
+		    tn->pos + tn->bits - 1) {
+			if (!tkey_extract_bits(node->key,
+					      oldtnode->pos + oldtnode->bits, 1))
+				put_child(t, tn, 2 * i, node);
 			else
-				put_child(t, tn, 2*i+1, node);
+				put_child(t, tn, 2 * i + 1, node);
 			continue;
 		}
 
 		/* An internal node with two children */
-		inode = (struct tnode *) node;
+		inode = (struct tnode *)node;
 
 		if (inode->bits == 1) {
-			put_child(t, tn, 2*i, inode->child[0]);
-			put_child(t, tn, 2*i+1, inode->child[1]);
+			put_child(t, tn, 2 * i, inode->child[0]);
+			put_child(t, tn, 2 * i + 1, inode->child[1]);
 
 			tnode_free(inode);
 			continue;
@@ -752,13 +757,13 @@ static struct tnode *inflate(struct trie
 		 *   bit to zero.
 		 */
 
-		left = (struct tnode *) tnode_get_child(tn, 2*i);
-		put_child(t, tn, 2*i, NULL);
+		left = (struct tnode *)tnode_get_child(tn, 2 * i);
+		put_child(t, tn, 2 * i, NULL);
 
 		BUG_ON(!left);
 
-		right = (struct tnode *) tnode_get_child(tn, 2*i+1);
-		put_child(t, tn, 2*i+1, NULL);
+		right = (struct tnode *)tnode_get_child(tn, 2 * i + 1);
+		put_child(t, tn, 2 * i + 1, NULL);
 
 		BUG_ON(!right);
 
@@ -767,8 +772,8 @@ static struct tnode *inflate(struct trie
 			put_child(t, left, j, inode->child[j]);
 			put_child(t, right, j, inode->child[j + size]);
 		}
-		put_child(t, tn, 2*i, resize(t, left));
-		put_child(t, tn, 2*i+1, resize(t, right));
+		put_child(t, tn, 2 * i, resize(t, left));
+		put_child(t, tn, 2 * i + 1, resize(t, right));
 
 		tnode_free(inode);
 	}
@@ -812,7 +817,7 @@ static struct tnode *halve(struct trie *
 
 	for (i = 0; i < olen; i += 2) {
 		left = tnode_get_child(oldtnode, i);
-		right = tnode_get_child(oldtnode, i+1);
+		right = tnode_get_child(oldtnode, i + 1);
 
 		/* Two nonempty children */
 		if (left && right) {
@@ -823,7 +828,7 @@ static struct tnode *halve(struct trie *
 			if (!newn)
 				goto nomem;
 
-			put_child(t, tn, i/2, (struct node *)newn);
+			put_child(t, tn, i / 2, (struct node *)newn);
 		}
 
 	}
@@ -832,27 +837,27 @@ static struct tnode *halve(struct trie *
 		struct tnode *newBinNode;
 
 		left = tnode_get_child(oldtnode, i);
-		right = tnode_get_child(oldtnode, i+1);
+		right = tnode_get_child(oldtnode, i + 1);
 
 		/* At least one of the children is empty */
 		if (left == NULL) {
-			if (right == NULL)    /* Both are empty */
+			if (right == NULL)	/* Both are empty */
 				continue;
-			put_child(t, tn, i/2, right);
+			put_child(t, tn, i / 2, right);
 			continue;
 		}
 
 		if (right == NULL) {
-			put_child(t, tn, i/2, left);
+			put_child(t, tn, i / 2, left);
 			continue;
 		}
 
 		/* Two nonempty children */
-		newBinNode = (struct tnode *) tnode_get_child(tn, i/2);
-		put_child(t, tn, i/2, NULL);
+		newBinNode = (struct tnode *)tnode_get_child(tn, i / 2);
+		put_child(t, tn, i / 2, NULL);
 		put_child(t, newBinNode, 0, left);
 		put_child(t, newBinNode, 1, right);
-		put_child(t, tn, i/2, resize(t, newBinNode));
+		put_child(t, tn, i / 2, resize(t, newBinNode));
 	}
 	tnode_free(oldtnode);
 	return tn;
@@ -894,13 +899,13 @@ static struct leaf_info *find_leaf_info(
 	struct leaf_info *li;
 
 	hlist_for_each_entry_rcu(li, node, head, hlist)
-		if (li->plen == plen)
-			return li;
+	    if (li->plen == plen)
+		return li;
 
 	return NULL;
 }
 
-static inline struct list_head * get_fa_head(struct leaf *l, int plen)
+static inline struct list_head *get_fa_head(struct leaf *l, int plen)
 {
 	struct leaf_info *li = find_leaf_info(l, plen);
 
@@ -933,8 +938,7 @@ static void insert_leaf_info(struct hlis
 
 /* rcu_read_lock needs to be hold by caller from readside */
 
-static struct leaf *
-fib_find_node(struct trie *t, u32 key)
+static struct leaf *fib_find_node(struct trie *t, u32 key)
 {
 	int pos;
 	struct tnode *tn;
@@ -944,7 +948,7 @@ fib_find_node(struct trie *t, u32 key)
 	n = rcu_dereference(t->trie);
 
 	while (n && IS_TNODE(n)) {
-		tn = (struct tnode *) n;
+		tn = (struct tnode *)n;
 
 		check_tnode(tn);
 
@@ -971,10 +975,11 @@ static struct node *trie_rebalance(struc
 	while (tn && (tp = node_parent((struct node *)tn)) ) {
 		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
 		wasfull = tnode_full(tp, tnode_get_child(tp, cindex));
-		tn = (struct tnode *) resize (t, (struct tnode *)tn);
-		tnode_put_child_reorg((struct tnode *)tp, cindex,(struct node*)tn, wasfull);
+		tn = (struct tnode *)resize(t, (struct tnode *)tn);
+		tnode_put_child_reorg((struct tnode *)tp, cindex,
+				      (struct node *)tn, wasfull);
 
-		tp = node_parent((struct node *) tn);
+		tp = node_parent((struct node *)tn);
 		if (!tp)
 			break;
 		tn = tp;
@@ -982,15 +987,15 @@ static struct node *trie_rebalance(struc
 
 	/* Handle last (top) tnode */
 	if (IS_TNODE(tn))
-		tn = (struct tnode*) resize(t, (struct tnode *)tn);
+		tn = (struct tnode *)resize(t, (struct tnode *)tn);
 
-	return (struct node*) tn;
+	return (struct node *)tn;
 }
 
 /* only used from updater-side */
 
-static  struct list_head *
-fib_insert_node(struct trie *t, int *err, u32 key, int plen)
+static struct list_head *fib_insert_node(struct trie *t, int *err, u32 key,
+					 int plen)
 {
 	int pos, newpos;
 	struct tnode *tp = NULL, *tn = NULL;
@@ -1023,7 +1028,7 @@ fib_insert_node(struct trie *t, int *err
 	 */
 
 	while (n && IS_TNODE(n)) {
-		tn = (struct tnode *) n;
+		tn = (struct tnode *)n;
 
 		check_tnode(tn);
 
@@ -1048,7 +1053,7 @@ fib_insert_node(struct trie *t, int *err
 	/* Case 1: n is a leaf. Compare prefixes */
 
 	if (n != NULL && IS_LEAF(n) && tkey_equals(key, n->key)) {
-		struct leaf *nl = (struct leaf *) n;
+		struct leaf *nl = (struct leaf *)n;
 
 		li = leaf_info_new(plen);
 
@@ -1073,7 +1078,7 @@ fib_insert_node(struct trie *t, int *err
 	li = leaf_info_new(plen);
 
 	if (!li) {
-		tnode_free((struct tnode *) l);
+		tnode_free((struct tnode *)l);
 		*err = -ENOMEM;
 		goto err;
 	}
@@ -1096,7 +1101,7 @@ fib_insert_node(struct trie *t, int *err
 		 */
 
 		if (tp)
-			pos = tp->pos+tp->bits;
+			pos = tp->pos + tp->bits;
 		else
 			pos = 0;
 
@@ -1105,12 +1110,12 @@ fib_insert_node(struct trie *t, int *err
 			tn = tnode_new(n->key, newpos, 1);
 		} else {
 			newpos = 0;
-			tn = tnode_new(key, newpos, 1); /* First tnode */
+			tn = tnode_new(key, newpos, 1);	/* First tnode */
 		}
 
 		if (!tn) {
 			free_leaf_info(li);
-			tnode_free((struct tnode *) l);
+			tnode_free((struct tnode *)l);
 			*err = -ENOMEM;
 			goto err;
 		}
@@ -1119,20 +1124,22 @@ fib_insert_node(struct trie *t, int *err
 
 		missbit = tkey_extract_bits(key, newpos, 1);
 		put_child(t, tn, missbit, (struct node *)l);
-		put_child(t, tn, 1-missbit, n);
+		put_child(t, tn, 1 - missbit, n);
 
 		if (tp) {
 			cindex = tkey_extract_bits(key, tp->pos, tp->bits);
-			put_child(t, (struct tnode *)tp, cindex, (struct node *)tn);
+			put_child(t, (struct tnode *)tp, cindex,
+				  (struct node *)tn);
 		} else {
-			rcu_assign_pointer(t->trie, (struct node *)tn); /* First tnode */
+			rcu_assign_pointer(t->trie, (struct node *)tn);	/* First tnode */
 			tp = tn;
 		}
 	}
 
 	if (tp && tp->pos + tp->bits > 32)
-		printk(KERN_WARNING "fib_trie tp=%p pos=%d, bits=%d, key=%0x plen=%d\n",
-		       tp, tp->pos, tp->bits, key, plen);
+		printk(KERN_WARNING
+		       "fib_trie tp=%p pos=%d, bits=%d, key=%0x plen=%d\n", tp,
+		       tp->pos, tp->bits, key, plen);
 
 	/* Rebalance the trie */
 
@@ -1148,7 +1155,7 @@ err:
  */
 static int fn_trie_insert(struct fib_table *tb, struct fib_config *cfg)
 {
-	struct trie *t = (struct trie *) tb->tb_data;
+	struct trie *t = (struct trie *)tb->tb_data;
 	struct fib_alias *fa, *new_fa;
 	struct list_head *fa_head = NULL;
 	struct fib_info *fi;
@@ -1228,7 +1235,7 @@ static int fn_trie_insert(struct fib_tab
 			if (state & FA_S_ACCESSED)
 				rt_cache_flush(-1);
 			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
-				tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
+				  tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
 
 			goto succeeded;
 		}
@@ -1276,8 +1283,7 @@ static int fn_trie_insert(struct fib_tab
 			goto out_free_new_fa;
 	}
 
-	list_add_tail_rcu(&new_fa->fa_list,
-			  (fa ? &fa->fa_list : fa_head));
+	list_add_tail_rcu(&new_fa->fa_list, (fa ? &fa->fa_list : fa_head));
 
 	rt_cache_flush(-1);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
@@ -1293,7 +1299,6 @@ err:
 	return err;
 }
 
-
 /* should be called with rcu_read_lock */
 static inline int check_leaf(struct trie *t, struct leaf *l,
 			     t_key key, int *plen, const struct flowi *flp,
@@ -1311,7 +1316,9 @@ static inline int check_leaf(struct trie
 		if (l->key != (key & ntohl(mask)))
 			continue;
 
-		if ((err = fib_semantic_match(&li->falh, flp, res, htonl(l->key), mask, i)) <= 0) {
+		err = fib_semantic_match(&li->falh, flp, res, htonl(l->key),
+					 mask, i);
+		if (err <= 0) {
 			*plen = i;
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 			t->stats.semantic_match_passed++;
@@ -1326,9 +1333,10 @@ static inline int check_leaf(struct trie
 }
 
 static int
-fn_trie_lookup(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
+fn_trie_lookup(struct fib_table *tb, const struct flowi *flp,
+	       struct fib_result *res)
 {
-	struct trie *t = (struct trie *) tb->tb_data;
+	struct trie *t = (struct trie *)tb->tb_data;
 	int plen, ret = 0;
 	struct node *n;
 	struct tnode *pn;
@@ -1353,11 +1361,12 @@ fn_trie_lookup(struct fib_table *tb, con
 
 	/* Just a leaf? */
 	if (IS_LEAF(n)) {
-		if ((ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res)) <= 0)
+		ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res);
+		if (ret <= 0)
 			goto found;
 		goto failed;
 	}
-	pn = (struct tnode *) n;
+	pn = (struct tnode *)n;
 	chopped_off = 0;
 
 	while (pn) {
@@ -1365,7 +1374,7 @@ fn_trie_lookup(struct fib_table *tb, con
 		bits = pn->bits;
 
 		if (!chopped_off)
-			cindex = tkey_extract_bits(mask_pfx(key, current_prefix_length),
+			cindex = tkey_extract_bits(mask_pfx (key, current_prefix_length),
 						   pos, bits);
 
 		n = tnode_get_child(pn, cindex);
@@ -1378,12 +1387,12 @@ fn_trie_lookup(struct fib_table *tb, con
 		}
 
 		if (IS_LEAF(n)) {
-			if ((ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res)) <= 0)
+			ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res);
+			if (ret <= 0)
 				goto found;
 			else
 				goto backtrace;
 		}
-
 #define HL_OPTIMIZE
 #ifdef HL_OPTIMIZE
 		cn = (struct tnode *)n;
@@ -1416,10 +1425,10 @@ fn_trie_lookup(struct fib_table *tb, con
 
 		/* NOTA BENE: CHECKING ONLY SKIPPED BITS FOR THE NEW NODE HERE */
 
-		if (current_prefix_length < pos+bits) {
+		if (current_prefix_length < pos + bits) {
 			if (tkey_extract_bits(cn->key, current_prefix_length,
-						cn->pos - current_prefix_length) != 0 ||
-			    !(cn->child[0]))
+					      cn->pos - current_prefix_length) != 0
+			    || !(cn->child[0]))
 				goto backtrace;
 		}
 
@@ -1454,19 +1463,19 @@ fn_trie_lookup(struct fib_table *tb, con
 
 		node_prefix = mask_pfx(cn->key, cn->pos);
 		key_prefix = mask_pfx(key, cn->pos);
-		pref_mismatch = key_prefix^node_prefix;
+		pref_mismatch = key_prefix ^ node_prefix;
 		mp = 0;
 
 		/* In short: If skipped bits in this node do not match the search
 		 * key, enter the "prefix matching" state.directly.
 		 */
 		if (pref_mismatch) {
-			while (!(pref_mismatch & (1<<(KEYLENGTH-1)))) {
+			while (!(pref_mismatch & (1 << (KEYLENGTH - 1)))) {
 				mp++;
-				pref_mismatch = pref_mismatch <<1;
+				pref_mismatch = pref_mismatch << 1;
 			}
-			key_prefix = tkey_extract_bits(cn->key, mp, cn->pos-mp);
 
+			key_prefix = tkey_extract_bits(cn->key, mp, cn->pos - mp);
 			if (key_prefix != 0)
 				goto backtrace;
 
@@ -1474,7 +1483,7 @@ fn_trie_lookup(struct fib_table *tb, con
 				current_prefix_length = mp;
 		}
 #endif
-		pn = (struct tnode *)n; /* Descend */
+		pn = (struct tnode *)n;	/* Descend */
 		chopped_off = 0;
 		continue;
 
@@ -1482,12 +1491,14 @@ backtrace:
 		chopped_off++;
 
 		/* As zero don't change the child key (cindex) */
-		while ((chopped_off <= pn->bits) && !(cindex & (1<<(chopped_off-1))))
+		while (chopped_off <= pn->bits
+		       && !(cindex & (1 << (chopped_off - 1))))
 			chopped_off++;
 
 		/* Decrease current_... with bits chopped off */
 		if (current_prefix_length > pn->pos + pn->bits - chopped_off)
-			current_prefix_length = pn->pos + pn->bits - chopped_off;
+			current_prefix_length =
+			    pn->pos + pn->bits - chopped_off;
 
 		/*
 		 * Either we do the actual chop off according or if we have
@@ -1495,14 +1506,15 @@ backtrace:
 		 */
 
 		if (chopped_off <= pn->bits) {
-			cindex &= ~(1 << (chopped_off-1));
+			cindex &= ~(1 << (chopped_off - 1));
 		} else {
-			struct tnode *parent = node_parent((struct node *) pn);
+			struct tnode *parent = node_parent((struct node *)pn);
 			if (!parent)
 				goto failed;
 
 			/* Get Child's index */
-			cindex = tkey_extract_bits(pn->key, parent->pos, parent->bits);
+			cindex = tkey_extract_bits(pn->key,
+						   parent->pos, parent->bits);
 			pn = parent;
 			chopped_off = 0;
 
@@ -1535,13 +1547,13 @@ static int trie_leaf_remove(struct trie 
 	 */
 
 	while (n != NULL && IS_TNODE(n)) {
-		struct tnode *tn = (struct tnode *) n;
+		struct tnode *tn = (struct tnode *)n;
 		check_tnode(tn);
-		n = tnode_get_child(tn ,tkey_extract_bits(key, tn->pos, tn->bits));
+		n = tnode_get_child(tn, tkey_extract_bits(key, tn->pos, tn->bits));
 
 		BUG_ON(n && node_parent(n) != tn);
 	}
-	l = (struct leaf *) n;
+	l = (struct leaf *)n;
 
 	if (!n || !tkey_equals(l->key, key))
 		return 0;
@@ -1555,7 +1567,7 @@ static int trie_leaf_remove(struct trie 
 	t->size--;
 
 	tp = node_parent(n);
-	tnode_free((struct tnode *) n);
+	tnode_free((struct tnode *)n);
 
 	if (tp) {
 		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
@@ -1572,7 +1584,7 @@ static int trie_leaf_remove(struct trie 
  */
 static int fn_trie_delete(struct fib_table *tb, struct fib_config *cfg)
 {
-	struct trie *t = (struct trie *) tb->tb_data;
+	struct trie *t = (struct trie *)tb->tb_data;
 	u32 key, mask;
 	int plen = cfg->fc_dst_len;
 	u8 tos = cfg->fc_tos;
@@ -1692,7 +1704,7 @@ static int trie_flush_leaf(struct trie *
 
 static struct leaf *nextleaf(struct trie *t, struct leaf *thisleaf)
 {
-	struct node *c = (struct node *) thisleaf;
+	struct node *c = (struct node *)thisleaf;
 	struct tnode *p;
 	int idx;
 	struct node *trie = rcu_dereference(t->trie);
@@ -1701,10 +1713,10 @@ static struct leaf *nextleaf(struct trie
 		if (trie == NULL)
 			return NULL;
 
-		if (IS_LEAF(trie))          /* trie w. just a leaf */
-			return (struct leaf *) trie;
+		if (IS_LEAF(trie))	/* trie w. just a leaf */
+			return (struct leaf *)trie;
 
-		p = (struct tnode*) trie;  /* Start */
+		p = (struct tnode *)trie;	/* Start */
 	} else
 		p = node_parent(c);
 
@@ -1718,7 +1730,7 @@ static struct leaf *nextleaf(struct trie
 			pos = 0;
 
 		last = 1 << p->bits;
-		for (idx = pos; idx < last ; idx++) {
+		for (idx = pos; idx < last; idx++) {
 			c = rcu_dereference(p->child[idx]);
 
 			if (!c)
@@ -1726,26 +1738,28 @@ static struct leaf *nextleaf(struct trie
 
 			/* Decend if tnode */
 			while (IS_TNODE(c)) {
-				p = (struct tnode *) c;
+				p = (struct tnode *)c;
 				idx = 0;
 
 				/* Rightmost non-NULL branch */
 				if (p && IS_TNODE(p))
 					while (!(c = rcu_dereference(p->child[idx]))
-					       && idx < (1<<p->bits)) idx++;
+					       && idx < (1 << p->bits))
+						idx++;
 
 				/* Done with this tnode? */
 				if (idx >= (1 << p->bits) || !c)
 					goto up;
 			}
-			return (struct leaf *) c;
+			return (struct leaf *)c;
 		}
 up:
 		/* No more children go up one step  */
-		c = (struct node *) p;
+		c = (struct node *)p;
 		p = node_parent(c);
 	}
-	return NULL; /* Ready. Root of trie */
+
+	return NULL;		/* Ready. Root of trie */
 }
 
 /*
@@ -1753,7 +1767,7 @@ up:
  */
 static int fn_trie_flush(struct fib_table *tb)
 {
-	struct trie *t = (struct trie *) tb->tb_data;
+	struct trie *t = (struct trie *)tb->tb_data;
 	struct leaf *ll = NULL, *l = NULL;
 	int found = 0, h;
 
@@ -1777,9 +1791,10 @@ static int fn_trie_flush(struct fib_tabl
 static int trie_last_dflt = -1;
 
 static void
-fn_trie_select_default(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
+fn_trie_select_default(struct fib_table *tb, const struct flowi *flp,
+		       struct fib_result *res)
 {
-	struct trie *t = (struct trie *) tb->tb_data;
+	struct trie *t = (struct trie *)tb->tb_data;
 	int order, last_idx;
 	struct fib_info *fi = NULL;
 	struct fib_info *last_resort;
@@ -1807,8 +1822,7 @@ fn_trie_select_default(struct fib_table 
 	list_for_each_entry_rcu(fa, fa_head, fa_list) {
 		struct fib_info *next_fi = fa->fa_info;
 
-		if (fa->fa_scope != res->scope ||
-		    fa->fa_type != RTN_UNICAST)
+		if (fa->fa_scope != res->scope || fa->fa_type != RTN_UNICAST)
 			continue;
 
 		if (next_fi->fib_priority > res->fi->fib_priority)
@@ -1854,12 +1868,13 @@ fn_trie_select_default(struct fib_table 
 			atomic_inc(&last_resort->fib_clntref);
 	}
 	trie_last_dflt = last_idx;
- out:;
+out:
 	rcu_read_unlock();
 }
 
-static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah, struct fib_table *tb,
-			   struct sk_buff *skb, struct netlink_callback *cb)
+static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah,
+			   struct fib_table *tb, struct sk_buff *skb,
+			   struct netlink_callback *cb)
 {
 	int i, s_i;
 	struct fib_alias *fa;
@@ -1884,10 +1899,7 @@ static int fn_trie_dump_fa(t_key key, in
 				  tb->tb_id,
 				  fa->fa_type,
 				  fa->fa_scope,
-				  xkey,
-				  plen,
-				  fa->fa_tos,
-				  fa->fa_info, 0) < 0) {
+				  xkey, plen, fa->fa_tos, fa->fa_info, 0) < 0) {
 			cb->args[4] = i;
 			return -1;
 		}
@@ -1897,8 +1909,8 @@ static int fn_trie_dump_fa(t_key key, in
 	return skb->len;
 }
 
-static int fn_trie_dump_plen(struct trie *t, int plen, struct fib_table *tb, struct sk_buff *skb,
-			     struct netlink_callback *cb)
+static int fn_trie_dump_plen(struct trie *t, int plen, struct fib_table *tb,
+			     struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int h, s_h;
 	struct list_head *fa_head;
@@ -1911,7 +1923,7 @@ static int fn_trie_dump_plen(struct trie
 			continue;
 		if (h > s_h)
 			memset(&cb->args[4], 0,
-			       sizeof(cb->args) - 4*sizeof(cb->args[0]));
+			       sizeof(cb->args) - 4 * sizeof(cb->args[0]));
 
 		fa_head = get_fa_head(l, plen);
 
@@ -1921,7 +1933,7 @@ static int fn_trie_dump_plen(struct trie
 		if (list_empty(fa_head))
 			continue;
 
-		if (fn_trie_dump_fa(l->key, plen, fa_head, tb, skb, cb)<0) {
+		if (fn_trie_dump_fa(l->key, plen, fa_head, tb, skb, cb) < 0) {
 			cb->args[3] = h;
 			return -1;
 		}
@@ -1930,10 +1942,11 @@ static int fn_trie_dump_plen(struct trie
 	return skb->len;
 }
 
-static int fn_trie_dump(struct fib_table *tb, struct sk_buff *skb, struct netlink_callback *cb)
+static int fn_trie_dump(struct fib_table *tb, struct sk_buff *skb,
+			struct netlink_callback *cb)
 {
 	int m, s_m;
-	struct trie *t = (struct trie *) tb->tb_data;
+	struct trie *t = (struct trie *)tb->tb_data;
 
 	s_m = cb->args[2];
 
@@ -1943,9 +1956,9 @@ static int fn_trie_dump(struct fib_table
 			continue;
 		if (m > s_m)
 			memset(&cb->args[3], 0,
-				sizeof(cb->args) - 3*sizeof(cb->args[0]));
+			       sizeof(cb->args) - 3 * sizeof(cb->args[0]));
 
-		if (fn_trie_dump_plen(t, 32-m, tb, skb, cb)<0) {
+		if (fn_trie_dump_plen(t, 32 - m, tb, skb, cb) < 0) {
 			cb->args[2] = m;
 			goto out;
 		}
@@ -1961,9 +1974,9 @@ out:
 /* Fix more generic FIB names for init later */
 
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-struct fib_table * fib_hash_init(u32 id)
+struct fib_table *fib_hash_init(u32 id)
 #else
-struct fib_table * __init fib_hash_init(u32 id)
+struct fib_table *__init fib_hash_init(u32 id)
 #endif
 {
 	struct fib_table *tb;
@@ -1972,8 +1985,7 @@ struct fib_table * __init fib_hash_init(
 	if (fn_alias_kmem == NULL)
 		fn_alias_kmem = kmem_cache_create("ip_fib_alias",
 						  sizeof(struct fib_alias),
-						  0, SLAB_HWCACHE_ALIGN,
-						  NULL);
+						  0, SLAB_HWCACHE_ALIGN, NULL);
 
 	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct trie),
 		     GFP_KERNEL);
@@ -1989,7 +2001,7 @@ struct fib_table * __init fib_hash_init(
 	tb->tb_dump = fn_trie_dump;
 	memset(tb->tb_data, 0, sizeof(struct trie));
 
-	t = (struct trie *) tb->tb_data;
+	t = (struct trie *)tb->tb_data;
 
 	trie_init(t);
 
@@ -1999,7 +2011,8 @@ struct fib_table * __init fib_hash_init(
 		trie_main = t;
 
 	if (id == RT_TABLE_LOCAL)
-		printk(KERN_INFO "IPv4 FIB: Using LC-trie version %s\n", VERSION);
+		printk(KERN_INFO "IPv4 FIB: Using LC-trie version %s\n",
+		       VERSION);
 
 	return tb;
 }
@@ -2026,7 +2039,7 @@ static struct node *fib_trie_get_next(st
 	pr_debug("get_next iter={node=%p index=%d depth=%d}\n",
 		 iter->tnode, iter->index, iter->depth);
 rescan:
-	while (cindex < (1<<tn->bits)) {
+	while (cindex < (1 << tn->bits)) {
 		struct node *n = tnode_get_child(tn, cindex);
 
 		if (n) {
@@ -2035,7 +2048,7 @@ rescan:
 				iter->index = cindex + 1;
 			} else {
 				/* push down one level */
-				iter->tnode = (struct tnode *) n;
+				iter->tnode = (struct tnode *)n;
 				iter->index = 0;
 				++iter->depth;
 			}
@@ -2048,7 +2061,7 @@ rescan:
 	/* Current node exhausted, pop back up */
 	p = node_parent((struct node *)tn);
 	if (p) {
-		cindex = tkey_extract_bits(tn->key, p->pos, p->bits)+1;
+		cindex = tkey_extract_bits(tn->key, p->pos, p->bits) + 1;
 		tn = p;
 		--iter->depth;
 		goto rescan;
@@ -2061,7 +2074,7 @@ rescan:
 static struct node *fib_trie_get_first(struct fib_trie_iter *iter,
 				       struct trie *t)
 {
-	struct node *n ;
+	struct node *n;
 
 	if (!t)
 		return NULL;
@@ -2073,13 +2086,13 @@ static struct node *fib_trie_get_first(s
 
 	if (n) {
 		if (IS_TNODE(n)) {
-			iter->tnode = (struct tnode *) n;
+			iter->tnode = (struct tnode *)n;
 			iter->trie = t;
 			iter->index = 0;
 			iter->depth = 1;
 		} else {
 			iter->tnode = NULL;
-			iter->trie  = t;
+			iter->trie = t;
 			iter->index = 0;
 			iter->depth = 0;
 		}
@@ -2096,22 +2109,21 @@ static void trie_collect_stats(struct tr
 	memset(s, 0, sizeof(*s));
 
 	rcu_read_lock();
-	for (n = fib_trie_get_first(&iter, t); n;
-	     n = fib_trie_get_next(&iter)) {
+	for (n = fib_trie_get_first(&iter, t); n; n = fib_trie_get_next(&iter)) {
 		if (IS_LEAF(n)) {
 			s->leaves++;
 			s->totdepth += iter.depth;
 			if (iter.depth > s->maxdepth)
 				s->maxdepth = iter.depth;
 		} else {
-			const struct tnode *tn = (const struct tnode *) n;
+			const struct tnode *tn = (const struct tnode *)n;
 			int i;
 
 			s->tnodes++;
 			if (tn->bits < MAX_STAT_DEPTH)
 				s->nodesizes[tn->bits]++;
 
-			for (i = 0; i < (1<<tn->bits); i++)
+			for (i = 0; i < (1 << tn->bits); i++)
 				if (!tn->child[i])
 					s->nullpointers++;
 		}
@@ -2127,11 +2139,12 @@ static void trie_show_stats(struct seq_f
 	unsigned i, max, pointers, bytes, avdepth;
 
 	if (stat->leaves)
-		avdepth = stat->totdepth*100 / stat->leaves;
+		avdepth = stat->totdepth * 100 / stat->leaves;
 	else
 		avdepth = 0;
 
-	seq_printf(seq, "\tAver depth:     %d.%02d\n", avdepth / 100, avdepth % 100 );
+	seq_printf(seq, "\tAver depth:     %d.%02d\n", avdepth / 100,
+		   avdepth % 100);
 	seq_printf(seq, "\tMax depth:      %u\n", stat->maxdepth);
 
 	seq_printf(seq, "\tLeaves:         %u\n", stat->leaves);
@@ -2141,14 +2154,14 @@ static void trie_show_stats(struct seq_f
 	bytes += sizeof(struct tnode) * stat->tnodes;
 
 	max = MAX_STAT_DEPTH;
-	while (max > 0 && stat->nodesizes[max-1] == 0)
+	while (max > 0 && stat->nodesizes[max - 1] == 0)
 		max--;
 
 	pointers = 0;
 	for (i = 1; i <= max; i++)
 		if (stat->nodesizes[i] != 0) {
-			seq_printf(seq, "  %d: %d",  i, stat->nodesizes[i]);
-			pointers += (1<<i) * stat->nodesizes[i];
+			seq_printf(seq, "  %d: %d", i, stat->nodesizes[i]);
+			pointers += (1 << i) * stat->nodesizes[i];
 		}
 	seq_putc(seq, '\n');
 	seq_printf(seq, "\tPointers: %d\n", pointers);
@@ -2159,12 +2172,15 @@ static void trie_show_stats(struct seq_f
 
 #ifdef CONFIG_IP_FIB_TRIE_STATS
 	seq_printf(seq, "Counters:\n---------\n");
-	seq_printf(seq,"gets = %d\n", t->stats.gets);
-	seq_printf(seq,"backtracks = %d\n", t->stats.backtrack);
-	seq_printf(seq,"semantic match passed = %d\n", t->stats.semantic_match_passed);
-	seq_printf(seq,"semantic match miss = %d\n", t->stats.semantic_match_miss);
-	seq_printf(seq,"null node hit= %d\n", t->stats.null_node_hit);
-	seq_printf(seq,"skipped node resize = %d\n", t->stats.resize_node_skipped);
+	seq_printf(seq, "gets = %d\n", t->stats.gets);
+	seq_printf(seq, "backtracks = %d\n", t->stats.backtrack);
+	seq_printf(seq, "semantic match passed = %d\n",
+		   t->stats.semantic_match_passed);
+	seq_printf(seq, "semantic match miss = %d\n",
+		   t->stats.semantic_match_miss);
+	seq_printf(seq, "null node hit= %d\n", t->stats.null_node_hit);
+	seq_printf(seq, "skipped node resize = %d\n",
+		   t->stats.resize_node_skipped);
 #ifdef CLEAR_STATS
 	memset(&(t->stats), 0, sizeof(t->stats));
 #endif
@@ -2179,7 +2195,8 @@ static int fib_triestat_seq_show(struct 
 	if (!stat)
 		return -ENOMEM;
 
-	seq_printf(seq, "Basic info: size of leaf: %Zd bytes, size of tnode: %Zd bytes.\n",
+	seq_printf(seq,
+		   "Basic info: size of leaf: %Zd bytes, size of tnode: %Zd bytes.\n",
 		   sizeof(struct leaf), sizeof(struct tnode));
 
 	if (trie_local) {
@@ -2211,8 +2228,7 @@ static const struct file_operations fib_
 	.release = single_release,
 };
 
-static struct node *fib_trie_get_idx(struct fib_trie_iter *iter,
-				      loff_t pos)
+static struct node *fib_trie_get_idx(struct fib_trie_iter *iter, loff_t pos)
 {
 	loff_t idx = 0;
 	struct node *n;
@@ -2231,7 +2247,7 @@ static struct node *fib_trie_get_idx(str
 	return NULL;
 }
 
-static void *fib_trie_seq_start(struct seq_file *seq, loff_t *pos)
+static void *fib_trie_seq_start(struct seq_file *seq, loff_t * pos)
 {
 	rcu_read_lock();
 	if (*pos == 0)
@@ -2239,7 +2255,7 @@ static void *fib_trie_seq_start(struct s
 	return fib_trie_get_idx(seq->private, *pos - 1);
 }
 
-static void *fib_trie_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *fib_trie_seq_next(struct seq_file *seq, void *v, loff_t * pos)
 {
 	struct fib_trie_iter *iter = seq->private;
 	void *l = v;
@@ -2267,7 +2283,8 @@ static void fib_trie_seq_stop(struct seq
 
 static void seq_indent(struct seq_file *seq, int n)
 {
-	while (n-- > 0) seq_puts(seq, "   ");
+	while (n-- > 0)
+		seq_puts(seq, "   ");
 }
 
 static inline const char *rtn_scope(enum rt_scope_t s)
@@ -2275,11 +2292,16 @@ static inline const char *rtn_scope(enum
 	static char buf[32];
 
 	switch (s) {
-	case RT_SCOPE_UNIVERSE: return "universe";
-	case RT_SCOPE_SITE:	return "site";
-	case RT_SCOPE_LINK:	return "link";
-	case RT_SCOPE_HOST:	return "host";
-	case RT_SCOPE_NOWHERE:	return "nowhere";
+	case RT_SCOPE_UNIVERSE:
+		return "universe";
+	case RT_SCOPE_SITE:
+		return "site";
+	case RT_SCOPE_LINK:
+		return "link";
+	case RT_SCOPE_HOST:
+		return "host";
+	case RT_SCOPE_NOWHERE:
+		return "nowhere";
 	default:
 		snprintf(buf, sizeof(buf), "scope=%d", s);
 		return buf;
@@ -2328,16 +2350,16 @@ static int fib_trie_seq_show(struct seq_
 	}
 
 	if (IS_TNODE(n)) {
-		struct tnode *tn = (struct tnode *) n;
+		struct tnode *tn = (struct tnode *)n;
 		__be32 prf = htonl(mask_pfx(tn->key, tn->pos));
 
-		seq_indent(seq, iter->depth-1);
+		seq_indent(seq, iter->depth - 1);
 		seq_printf(seq, "  +-- %d.%d.%d.%d/%d %d %d %d\n",
 			   NIPQUAD(prf), tn->pos, tn->bits, tn->full_children,
 			   tn->empty_children);
 
 	} else {
-		struct leaf *l = (struct leaf *) n;
+		struct leaf *l = (struct leaf *)n;
 		int i;
 		__be32 val = htonl(l->key);
 
@@ -2348,7 +2370,7 @@ static int fib_trie_seq_show(struct seq_
 			if (li) {
 				struct fib_alias *fa;
 				list_for_each_entry_rcu(fa, &li->falh, fa_list) {
-					seq_indent(seq, iter->depth+1);
+					seq_indent(seq, iter->depth + 1);
 					seq_printf(seq, "  /%d %s %s", i,
 						   rtn_scope(fa->fa_scope),
 						   rtn_type(fa->fa_type));
@@ -2384,7 +2406,7 @@ static int fib_trie_seq_open(struct inod
 	if (rc)
 		goto out_kfree;
 
-	seq	     = file->private_data;
+	seq = file->private_data;
 	seq->private = s;
 	memset(s, 0, sizeof(*s));
 out:
@@ -2405,7 +2427,8 @@ static const struct file_operations fib_
 static unsigned fib_flag_trans(int type, __be32 mask, const struct fib_info *fi)
 {
 	static unsigned type2flags[RTN_MAX + 1] = {
-		[7] = RTF_REJECT, [8] = RTF_REJECT,
+		[7] = RTF_REJECT,
+		[8] = RTF_REJECT,
 	};
 	unsigned flags = type2flags[type];
 
@@ -2442,7 +2465,7 @@ static int fib_route_seq_show(struct seq
 	if (IS_TNODE(l))
 		return 0;
 
-	for (i=32; i>=0; i--) {
+	for (i = 32; i >= 0; i--) {
 		struct leaf_info *li = find_leaf_info(l, i);
 		struct fib_alias *fa;
 		__be32 mask, prefix;
@@ -2469,7 +2492,7 @@ static int fib_route_seq_show(struct seq
 					 fi->fib_nh->nh_gw, flags, 0, 0,
 					 fi->fib_priority,
 					 mask,
-					 (fi->fib_advmss ? fi->fib_advmss + 40 : 0),
+					 fi->fib_advmss ? fi->fib_advmss + 40 : 0,
 					 fi->fib_window,
 					 fi->fib_rtt >> 3);
 			else
@@ -2505,7 +2528,7 @@ static int fib_route_seq_open(struct ino
 	if (rc)
 		goto out_kfree;
 
-	seq	     = file->private_data;
+	seq = file->private_data;
 	seq->private = s;
 	memset(s, 0, sizeof(*s));
 out:

-- 

