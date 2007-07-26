From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] fib_trie: whitespace cleanup
Date: Thu, 26 Jul 2007 08:44:21 -0700
Message-ID: <20070726154421.GB24650@linux.vnet.ibm.com>
References: <20070725040304.111550f4.akpm@linux-foundation.org> <20070725181557.GF3572@stusta.de> <20070726094648.3b7301ae@oldman> <20070726020431.1e693866.akpm@linux-foundation.org> <20070726114942.5615ed7b@oldman.hamilton.local>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Adrian Bunk <bunk@stusta.de>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Ingo Molnar <mingo@elte.hu>, Josh Triplett <josh@kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:52834 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763939AbXGZPo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 11:44:29 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6QEe81K013239
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 10:40:08 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6QFiNvd526600
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 11:44:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6QFiMKq017857
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 11:44:23 -0400
Content-Disposition: inline
In-Reply-To: <20070726114942.5615ed7b@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 26, 2007 at 11:49:42AM +0100, Stephen Hemminger wrote:
> Whitespace cleanup run code through lindent then cleanup results.
> Applys after other two patches.
> 
> --- a/net/ipv4/fib_trie.c	2007-07-26 10:17:21.000000000 +0100
> +++ b/net/ipv4/fib_trie.c	2007-07-26 11:47:52.000000000 +0100
> @@ -156,7 +156,8 @@ struct trie {
>  };
> 
>  static void put_child(struct trie *t, struct tnode *tn, int i, struct node *n);
> -static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n, int wasfull);
> +static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n,
> +				  int wasfull);
>  static struct node *resize(struct trie *t, struct tnode *tn);
>  static struct tnode *inflate(struct trie *t, struct tnode *tn);
>  static struct tnode *halve(struct trie *t, struct tnode *tn);
> @@ -167,13 +168,12 @@ static struct trie *trie_local = NULL, *
> 
>  static inline struct tnode *node_parent(struct node *node)
>  {
> -	return rcu_dereference((struct tnode *) (node->parent & ~NODE_TYPE_MASK));
> +	return rcu_dereference((struct tnode *)(node->parent & ~NODE_TYPE_MASK));

The potential issue is applying rcu_dereference() to an rvalue
as opposed to an lvalue.  So how about the following?

	return rcu_dereference(node->parent) & ~NODE_TYPE_MASK;

>  }
> 
>  static inline void node_set_parent(struct node *node, struct tnode *ptr)
>  {
> -	rcu_assign_pointer(node->parent,
> -			   (unsigned long)ptr | NODE_TYPE(node));
> +	rcu_assign_pointer(node->parent, (unsigned long)ptr | NODE_TYPE(node));
>  }
> 
>  /* rcu_read_lock needs to be hold by caller from readside */
> @@ -192,13 +192,13 @@ static inline int tnode_child_length(con
> 
>  static inline t_key mask_pfx(t_key k, unsigned short l)
>  {
> -	return (l == 0) ? 0 : k >> (KEYLENGTH-l) << (KEYLENGTH-l);
> +	return (l == 0) ? 0 : k >> (KEYLENGTH - l) << (KEYLENGTH - l);
>  }
> 
>  static inline t_key tkey_extract_bits(t_key a, int offset, int bits)
>  {
>  	if (offset < KEYLENGTH)
> -		return ((t_key)(a << offset)) >> (KEYLENGTH - bits);
> +		return ((t_key) (a << offset)) >> (KEYLENGTH - bits);
>  	else
>  		return 0;
>  }
> @@ -223,7 +223,7 @@ static inline int tkey_mismatch(t_key a,
> 
>  	if (!diff)
>  		return 0;
> -	while ((diff << i) >> (KEYLENGTH-1) == 0)
> +	while ((diff << i) >> (KEYLENGTH - 1) == 0)
>  		i++;
>  	return i;
>  }
> @@ -285,7 +285,6 @@ static inline int tkey_mismatch(t_key a,
>    The bits from (n->pos) to (n->pos + n->bits - 1) - "C" - are the index into
>    n's child array, and will of course be different for each child.
> 
> -
>    The rest of the bits, from (n->pos + n->bits) onward, are completely unknown
>    at this point.
> 
> @@ -293,7 +292,7 @@ static inline int tkey_mismatch(t_key a,
> 
>  static inline void check_tnode(const struct tnode *tn)
>  {
> -	WARN_ON(tn && tn->pos+tn->bits > 32);
> +	WARN_ON(tn && tn->pos + tn->bits > 32);
>  }
> 
>  static int halve_threshold = 25;
> @@ -301,7 +300,6 @@ static int inflate_threshold = 50;
>  static int halve_threshold_root = 8;
>  static int inflate_threshold_root = 15;
> 
> -
>  static void __alias_free_mem(struct rcu_head *head)
>  {
>  	struct fib_alias *fa = container_of(head, struct fib_alias, rcu);
> @@ -335,7 +333,7 @@ static struct tnode *tnode_alloc(unsigne
>  	if (size <= PAGE_SIZE)
>  		return kcalloc(size, 1, GFP_KERNEL);
> 
> -	pages = alloc_pages(GFP_KERNEL|__GFP_ZERO, get_order(size));
> +	pages = alloc_pages(GFP_KERNEL | __GFP_ZERO, get_order(size));
>  	if (!pages)
>  		return NULL;
> 
> @@ -346,7 +344,7 @@ static void __tnode_free_rcu(struct rcu_
>  {
>  	struct tnode *tn = container_of(head, struct tnode, rcu);
>  	unsigned int size = sizeof(struct tnode) +
> -		(1 << tn->bits) * sizeof(struct node *);
> +	    (1 << tn->bits) * sizeof(struct node *);
> 
>  	if (size <= PAGE_SIZE)
>  		kfree(tn);
> @@ -357,7 +355,7 @@ static void __tnode_free_rcu(struct rcu_
>  static inline void tnode_free(struct tnode *tn)
>  {
>  	if (IS_LEAF(tn)) {
> -		struct leaf *l = (struct leaf *) tn;
> +		struct leaf *l = (struct leaf *)tn;
>  		call_rcu_bh(&l->rcu, __leaf_free_rcu);
>  	} else
>  		call_rcu(&tn->rcu, __tnode_free_rcu);
> @@ -365,7 +363,7 @@ static inline void tnode_free(struct tno
> 
>  static struct leaf *leaf_new(void)
>  {
> -	struct leaf *l = kmalloc(sizeof(struct leaf),  GFP_KERNEL);
> +	struct leaf *l = kmalloc(sizeof(struct leaf), GFP_KERNEL);
>  	if (l) {
>  		l->parent = T_LEAF;
>  		INIT_HLIST_HEAD(&l->list);
> @@ -375,7 +373,7 @@ static struct leaf *leaf_new(void)
> 
>  static struct leaf_info *leaf_info_new(int plen)
>  {
> -	struct leaf_info *li = kmalloc(sizeof(struct leaf_info),  GFP_KERNEL);
> +	struct leaf_info *li = kmalloc(sizeof(struct leaf_info), GFP_KERNEL);
>  	if (li) {
>  		li->plen = plen;
>  		INIT_LIST_HEAD(&li->falh);
> @@ -383,9 +381,9 @@ static struct leaf_info *leaf_info_new(i
>  	return li;
>  }
> 
> -static struct tnode* tnode_new(t_key key, int pos, int bits)
> +static struct tnode *tnode_new(t_key key, int pos, int bits)
>  {
> -	int nchildren = 1<<bits;
> +	int nchildren = 1 << bits;
>  	int sz = sizeof(struct tnode) + nchildren * sizeof(struct node *);
>  	struct tnode *tn = tnode_alloc(sz);
> 
> @@ -396,11 +394,11 @@ static struct tnode* tnode_new(t_key key
>  		tn->bits = bits;
>  		tn->key = key;
>  		tn->full_children = 0;
> -		tn->empty_children = 1<<bits;
> +		tn->empty_children = 1 << bits;
>  	}
> 
> -	pr_debug("AT %p s=%u %u\n", tn, (unsigned int) sizeof(struct tnode),
> -		 (unsigned int) (sizeof(struct node) * 1<<bits));
> +	pr_debug("AT %p s=%u %u\n", tn, (unsigned int)sizeof(struct tnode),
> +		 (unsigned int)(sizeof(struct node) * 1 << bits));
>  	return tn;
>  }
> 
> @@ -414,10 +412,11 @@ static inline int tnode_full(const struc
>  	if (n == NULL || IS_LEAF(n))
>  		return 0;
> 
> -	return ((struct tnode *) n)->pos == tn->pos + tn->bits;
> +	return ((struct tnode *)n)->pos == tn->pos + tn->bits;
>  }
> 
> -static inline void put_child(struct trie *t, struct tnode *tn, int i, struct node *n)
> +static inline void put_child(struct trie *t, struct tnode *tn, int i,
> +			     struct node *n)
>  {
>  	tnode_put_child_reorg(tn, i, n, -1);
>  }
> @@ -427,13 +426,13 @@ static inline void put_child(struct trie
>    * Update the value of full_children and empty_children.
>    */
> 
> -static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n, int wasfull)
> +static void tnode_put_child_reorg(struct tnode *tn, int i, struct node *n,
> +				  int wasfull)
>  {
>  	struct node *chi = tn->child[i];
>  	int isfull;
> 
> -	BUG_ON(i >= 1<<tn->bits);
> -
> +	BUG_ON(i >= 1 << tn->bits);
> 
>  	/* update emptyChildren */
>  	if (n == NULL && chi != NULL)
> @@ -566,9 +565,10 @@ static struct node *resize(struct trie *
> 
>  	err = 0;
>  	max_resize = 10;
> -	while ((tn->full_children > 0 &&  max_resize-- &&
> -	       50 * (tn->full_children + tnode_child_length(tn) - tn->empty_children) >=
> -				inflate_threshold_use * tnode_child_length(tn))) {
> +	while ((tn->full_children > 0 && max_resize-- &&
> +		50 * (tn->full_children + tnode_child_length(tn) -
> +		      tn->empty_children) >=
> +		inflate_threshold_use * tnode_child_length(tn))) {
> 
>  		old_tn = tn;
>  		tn = inflate(t, tn);
> @@ -583,10 +583,12 @@ static struct node *resize(struct trie *
> 
>  	if (max_resize < 0) {
>  		if (!tn->parent)
> -			printk(KERN_WARNING "Fix inflate_threshold_root. Now=%d size=%d bits\n",
> +			printk(KERN_WARNING
> +			       "Fix inflate_threshold_root. Now=%d size=%d bits\n",
>  			       inflate_threshold_root, tn->bits);
>  		else
> -			printk(KERN_WARNING "Fix inflate_threshold. Now=%d size=%d bits\n",
> +			printk(KERN_WARNING
> +			       "Fix inflate_threshold. Now=%d size=%d bits\n",
>  			       inflate_threshold, tn->bits);
>  	}
> 
> @@ -597,7 +599,6 @@ static struct node *resize(struct trie *
>  	 * node is above threshold.
>  	 */
> 
> -
>  	/* Keep root node larger  */
> 
>  	if (!tn->parent)
> @@ -607,7 +608,7 @@ static struct node *resize(struct trie *
> 
>  	err = 0;
>  	max_resize = 10;
> -	while (tn->bits > 1 &&  max_resize-- &&
> +	while (tn->bits > 1 && max_resize-- &&
>  	       100 * (tnode_child_length(tn) - tn->empty_children) <
>  	       halve_threshold_use * tnode_child_length(tn)) {
> 
> @@ -624,10 +625,12 @@ static struct node *resize(struct trie *
> 
>  	if (max_resize < 0) {
>  		if (!tn->parent)
> -			printk(KERN_WARNING "Fix halve_threshold_root. Now=%d size=%d bits\n",
> +			printk(KERN_WARNING
> +			       "Fix halve_threshold_root. Now=%d size=%d bits\n",
>  			       halve_threshold_root, tn->bits);
>  		else
> -			printk(KERN_WARNING "Fix halve_threshold. Now=%d size=%d bits\n",
> +			printk(KERN_WARNING
> +			       "Fix halve_threshold. Now=%d size=%d bits\n",
>  			       halve_threshold, tn->bits);
>  	}
> 
> @@ -647,7 +650,7 @@ static struct node *resize(struct trie *
>  			return n;
>  		}
> 
> -	return (struct node *) tn;
> +	return (struct node *)tn;
>  }
> 
>  static struct tnode *inflate(struct trie *t, struct tnode *tn)
> @@ -672,7 +675,8 @@ static struct tnode *inflate(struct trie
>  	 */
> 
>  	for (i = 0; i < olen; i++) {
> -		struct tnode *inode = (struct tnode *) tnode_get_child(oldtnode, i);
> +		struct tnode *inode =
> +		    (struct tnode *)tnode_get_child(oldtnode, i);
> 
>  		if (inode &&
>  		    IS_TNODE(inode) &&
> @@ -681,12 +685,12 @@ static struct tnode *inflate(struct trie
>  			struct tnode *left, *right;
>  			t_key m = ~0U << (KEYLENGTH - 1) >> inode->pos;
> 
> -			left = tnode_new(inode->key&(~m), inode->pos + 1,
> +			left = tnode_new(inode->key & (~m), inode->pos + 1,
>  					 inode->bits - 1);
>  			if (!left)
>  				goto nomem;
> 
> -			right = tnode_new(inode->key|m, inode->pos + 1,
> +			right = tnode_new(inode->key | m, inode->pos + 1,
>  					  inode->bits - 1);
> 
>  			if (!right) {
> @@ -694,8 +698,8 @@ static struct tnode *inflate(struct trie
>  				goto nomem;
>  			}
> 
> -			put_child(t, tn, 2*i, (struct node *) left);
> -			put_child(t, tn, 2*i+1, (struct node *) right);
> +			put_child(t, tn, 2 * i, (struct node *)left);
> +			put_child(t, tn, 2 * i + 1, (struct node *)right);
>  		}
>  	}
> 
> @@ -710,22 +714,22 @@ static struct tnode *inflate(struct trie
> 
>  		/* A leaf or an internal node with skipped bits */
> 
> -		if (IS_LEAF(node) || ((struct tnode *) node)->pos >
> -		   tn->pos + tn->bits - 1) {
> -			if (tkey_extract_bits(node->key, oldtnode->pos + oldtnode->bits,
> -					     1) == 0)
> -				put_child(t, tn, 2*i, node);
> +		if (IS_LEAF(node) || ((struct tnode *)node)->pos >
> +		    tn->pos + tn->bits - 1) {
> +			if (!tkey_extract_bits(node->key,
> +					      oldtnode->pos + oldtnode->bits, 1))
> +				put_child(t, tn, 2 * i, node);
>  			else
> -				put_child(t, tn, 2*i+1, node);
> +				put_child(t, tn, 2 * i + 1, node);
>  			continue;
>  		}
> 
>  		/* An internal node with two children */
> -		inode = (struct tnode *) node;
> +		inode = (struct tnode *)node;
> 
>  		if (inode->bits == 1) {
> -			put_child(t, tn, 2*i, inode->child[0]);
> -			put_child(t, tn, 2*i+1, inode->child[1]);
> +			put_child(t, tn, 2 * i, inode->child[0]);
> +			put_child(t, tn, 2 * i + 1, inode->child[1]);
> 
>  			tnode_free(inode);
>  			continue;
> @@ -754,13 +758,13 @@ static struct tnode *inflate(struct trie
>  		 *   bit to zero.
>  		 */
> 
> -		left = (struct tnode *) tnode_get_child(tn, 2*i);
> -		put_child(t, tn, 2*i, NULL);
> +		left = (struct tnode *)tnode_get_child(tn, 2 * i);
> +		put_child(t, tn, 2 * i, NULL);
> 
>  		BUG_ON(!left);
> 
> -		right = (struct tnode *) tnode_get_child(tn, 2*i+1);
> -		put_child(t, tn, 2*i+1, NULL);
> +		right = (struct tnode *)tnode_get_child(tn, 2 * i + 1);
> +		put_child(t, tn, 2 * i + 1, NULL);
> 
>  		BUG_ON(!right);
> 
> @@ -769,8 +773,8 @@ static struct tnode *inflate(struct trie
>  			put_child(t, left, j, inode->child[j]);
>  			put_child(t, right, j, inode->child[j + size]);
>  		}
> -		put_child(t, tn, 2*i, resize(t, left));
> -		put_child(t, tn, 2*i+1, resize(t, right));
> +		put_child(t, tn, 2 * i, resize(t, left));
> +		put_child(t, tn, 2 * i + 1, resize(t, right));
> 
>  		tnode_free(inode);
>  	}
> @@ -814,7 +818,7 @@ static struct tnode *halve(struct trie *
> 
>  	for (i = 0; i < olen; i += 2) {
>  		left = tnode_get_child(oldtnode, i);
> -		right = tnode_get_child(oldtnode, i+1);
> +		right = tnode_get_child(oldtnode, i + 1);
> 
>  		/* Two nonempty children */
>  		if (left && right) {
> @@ -825,7 +829,7 @@ static struct tnode *halve(struct trie *
>  			if (!newn)
>  				goto nomem;
> 
> -			put_child(t, tn, i/2, (struct node *)newn);
> +			put_child(t, tn, i / 2, (struct node *)newn);
>  		}
> 
>  	}
> @@ -834,27 +838,27 @@ static struct tnode *halve(struct trie *
>  		struct tnode *newBinNode;
> 
>  		left = tnode_get_child(oldtnode, i);
> -		right = tnode_get_child(oldtnode, i+1);
> +		right = tnode_get_child(oldtnode, i + 1);
> 
>  		/* At least one of the children is empty */
>  		if (left == NULL) {
> -			if (right == NULL)    /* Both are empty */
> +			if (right == NULL)	/* Both are empty */
>  				continue;
> -			put_child(t, tn, i/2, right);
> +			put_child(t, tn, i / 2, right);
>  			continue;
>  		}
> 
>  		if (right == NULL) {
> -			put_child(t, tn, i/2, left);
> +			put_child(t, tn, i / 2, left);
>  			continue;
>  		}
> 
>  		/* Two nonempty children */
> -		newBinNode = (struct tnode *) tnode_get_child(tn, i/2);
> -		put_child(t, tn, i/2, NULL);
> +		newBinNode = (struct tnode *)tnode_get_child(tn, i / 2);
> +		put_child(t, tn, i / 2, NULL);
>  		put_child(t, newBinNode, 0, left);
>  		put_child(t, newBinNode, 1, right);
> -		put_child(t, tn, i/2, resize(t, newBinNode));
> +		put_child(t, tn, i / 2, resize(t, newBinNode));
>  	}
>  	tnode_free(oldtnode);
>  	return tn;
> @@ -896,13 +900,13 @@ static struct leaf_info *find_leaf_info(
>  	struct leaf_info *li;
> 
>  	hlist_for_each_entry_rcu(li, node, head, hlist)
> -		if (li->plen == plen)
> -			return li;
> +	    if (li->plen == plen)
> +		return li;
> 
>  	return NULL;
>  }
> 
> -static inline struct list_head * get_fa_head(struct leaf *l, int plen)
> +static inline struct list_head *get_fa_head(struct leaf *l, int plen)
>  {
>  	struct leaf_info *li = find_leaf_info(l, plen);
> 
> @@ -935,8 +939,7 @@ static void insert_leaf_info(struct hlis
> 
>  /* rcu_read_lock needs to be hold by caller from readside */
> 
> -static struct leaf *
> -fib_find_node(struct trie *t, u32 key)
> +static struct leaf *fib_find_node(struct trie *t, u32 key)
>  {
>  	int pos;
>  	struct tnode *tn;
> @@ -945,14 +948,16 @@ fib_find_node(struct trie *t, u32 key)
>  	pos = 0;
>  	n = rcu_dereference(t->trie);
> 
> -	while (n != NULL &&  NODE_TYPE(n) == T_TNODE) {
> -		tn = (struct tnode *) n;
> +	while (n != NULL && NODE_TYPE(n) == T_TNODE) {
> +		tn = (struct tnode *)n;
> 
>  		check_tnode(tn);
> 
> -		if (tkey_sub_equals(tn->key, pos, tn->pos-pos, key)) {
> +		if (tkey_sub_equals(tn->key, pos, tn->pos - pos, key)) {
>  			pos = tn->pos + tn->bits;
> -			n = tnode_get_child(tn, tkey_extract_bits(key, tn->pos, tn->bits));
> +			n = tnode_get_child(tn,
> +					    tkey_extract_bits(key, tn->pos,
> +							      tn->bits));
>  		} else
>  			break;
>  	}
> @@ -973,10 +978,11 @@ static struct node *trie_rebalance(struc
>  	while (tn != NULL && (tp = node_parent((struct node *)tn)) != NULL) {
>  		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
>  		wasfull = tnode_full(tp, tnode_get_child(tp, cindex));
> -		tn = (struct tnode *) resize (t, (struct tnode *)tn);
> -		tnode_put_child_reorg((struct tnode *)tp, cindex,(struct node*)tn, wasfull);
> +		tn = (struct tnode *)resize(t, (struct tnode *)tn);
> +		tnode_put_child_reorg((struct tnode *)tp, cindex,
> +				      (struct node *)tn, wasfull);
> 
> -		tp = node_parent((struct node *) tn);
> +		tp = node_parent((struct node *)tn);
>  		if (!tp)
>  			break;
>  		tn = tp;
> @@ -984,15 +990,15 @@ static struct node *trie_rebalance(struc
> 
>  	/* Handle last (top) tnode */
>  	if (IS_TNODE(tn))
> -		tn = (struct tnode*) resize(t, (struct tnode *)tn);
> +		tn = (struct tnode *)resize(t, (struct tnode *)tn);
> 
> -	return (struct node*) tn;
> +	return (struct node *)tn;
>  }
> 
>  /* only used from updater-side */
> 
> -static  struct list_head *
> -fib_insert_node(struct trie *t, int *err, u32 key, int plen)
> +static struct list_head *fib_insert_node(struct trie *t, int *err, u32 key,
> +					 int plen)
>  {
>  	int pos, newpos;
>  	struct tnode *tp = NULL, *tn = NULL;
> @@ -1024,15 +1030,17 @@ fib_insert_node(struct trie *t, int *err
>  	 * If it doesn't, we need to replace it with a T_TNODE.
>  	 */
> 
> -	while (n != NULL &&  NODE_TYPE(n) == T_TNODE) {
> -		tn = (struct tnode *) n;
> +	while (n != NULL && NODE_TYPE(n) == T_TNODE) {
> +		tn = (struct tnode *)n;
> 
>  		check_tnode(tn);
> 
> -		if (tkey_sub_equals(tn->key, pos, tn->pos-pos, key)) {
> +		if (tkey_sub_equals(tn->key, pos, tn->pos - pos, key)) {
>  			tp = tn;
>  			pos = tn->pos + tn->bits;
> -			n = tnode_get_child(tn, tkey_extract_bits(key, tn->pos, tn->bits));
> +			n = tnode_get_child(tn,
> +					    tkey_extract_bits(key, tn->pos,
> +							      tn->bits));
> 
>  			BUG_ON(n && node_parent(n) != tn);
>  		} else
> @@ -1050,7 +1058,7 @@ fib_insert_node(struct trie *t, int *err
>  	/* Case 1: n is a leaf. Compare prefixes */
> 
>  	if (n != NULL && IS_LEAF(n) && tkey_equals(key, n->key)) {
> -		struct leaf *l = (struct leaf *) n;
> +		struct leaf *l = (struct leaf *)n;
> 
>  		li = leaf_info_new(plen);
> 
> @@ -1075,7 +1083,7 @@ fib_insert_node(struct trie *t, int *err
>  	li = leaf_info_new(plen);
> 
>  	if (!li) {
> -		tnode_free((struct tnode *) l);
> +		tnode_free((struct tnode *)l);
>  		*err = -ENOMEM;
>  		goto err;
>  	}
> @@ -1098,7 +1106,7 @@ fib_insert_node(struct trie *t, int *err
>  		 */
> 
>  		if (tp)
> -			pos = tp->pos+tp->bits;
> +			pos = tp->pos + tp->bits;
>  		else
>  			pos = 0;
> 
> @@ -1107,12 +1115,12 @@ fib_insert_node(struct trie *t, int *err
>  			tn = tnode_new(n->key, newpos, 1);
>  		} else {
>  			newpos = 0;
> -			tn = tnode_new(key, newpos, 1); /* First tnode */
> +			tn = tnode_new(key, newpos, 1);	/* First tnode */
>  		}
> 
>  		if (!tn) {
>  			free_leaf_info(li);
> -			tnode_free((struct tnode *) l);
> +			tnode_free((struct tnode *)l);
>  			*err = -ENOMEM;
>  			goto err;
>  		}
> @@ -1121,20 +1129,22 @@ fib_insert_node(struct trie *t, int *err
> 
>  		missbit = tkey_extract_bits(key, newpos, 1);
>  		put_child(t, tn, missbit, (struct node *)l);
> -		put_child(t, tn, 1-missbit, n);
> +		put_child(t, tn, 1 - missbit, n);
> 
>  		if (tp) {
>  			cindex = tkey_extract_bits(key, tp->pos, tp->bits);
> -			put_child(t, (struct tnode *)tp, cindex, (struct node *)tn);
> +			put_child(t, (struct tnode *)tp, cindex,
> +				  (struct node *)tn);
>  		} else {
> -			rcu_assign_pointer(t->trie, (struct node *)tn); /* First tnode */
> +			rcu_assign_pointer(t->trie, (struct node *)tn);	/* First tnode */
>  			tp = tn;
>  		}
>  	}
> 
>  	if (tp && tp->pos + tp->bits > 32)
> -		printk(KERN_WARNING "fib_trie tp=%p pos=%d, bits=%d, key=%0x plen=%d\n",
> -		       tp, tp->pos, tp->bits, key, plen);
> +		printk(KERN_WARNING
> +		       "fib_trie tp=%p pos=%d, bits=%d, key=%0x plen=%d\n", tp,
> +		       tp->pos, tp->bits, key, plen);
> 
>  	/* Rebalance the trie */
> 
> @@ -1150,7 +1160,7 @@ err:
>   */
>  static int fn_trie_insert(struct fib_table *tb, struct fib_config *cfg)
>  {
> -	struct trie *t = (struct trie *) tb->tb_data;
> +	struct trie *t = (struct trie *)tb->tb_data;
>  	struct fib_alias *fa, *new_fa;
>  	struct list_head *fa_head = NULL;
>  	struct fib_info *fi;
> @@ -1230,7 +1240,7 @@ static int fn_trie_insert(struct fib_tab
>  			if (state & FA_S_ACCESSED)
>  				rt_cache_flush(-1);
>  			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
> -				tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
> +				  tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
> 
>  			goto succeeded;
>  		}
> @@ -1278,8 +1288,7 @@ static int fn_trie_insert(struct fib_tab
>  			goto out_free_new_fa;
>  	}
> 
> -	list_add_tail_rcu(&new_fa->fa_list,
> -			  (fa ? &fa->fa_list : fa_head));
> +	list_add_tail_rcu(&new_fa->fa_list, (fa ? &fa->fa_list : fa_head));
> 
>  	rt_cache_flush(-1);
>  	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, tb->tb_id,
> @@ -1295,7 +1304,6 @@ err:
>  	return err;
>  }
> 
> -
>  /* should be called with rcu_read_lock */
>  static inline int check_leaf(struct trie *t, struct leaf *l,
>  			     t_key key, int *plen, const struct flowi *flp,
> @@ -1313,7 +1321,9 @@ static inline int check_leaf(struct trie
>  		if (l->key != (key & ntohl(mask)))
>  			continue;
> 
> -		if ((err = fib_semantic_match(&li->falh, flp, res, htonl(l->key), mask, i)) <= 0) {
> +		err = fib_semantic_match(&li->falh, flp, res, htonl(l->key),
> +					 mask, i);
> +		if (err <= 0) {
>  			*plen = i;
>  #ifdef CONFIG_IP_FIB_TRIE_STATS
>  			t->stats.semantic_match_passed++;
> @@ -1328,9 +1338,10 @@ static inline int check_leaf(struct trie
>  }
> 
>  static int
> -fn_trie_lookup(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
> +fn_trie_lookup(struct fib_table *tb, const struct flowi *flp,
> +	       struct fib_result *res)
>  {
> -	struct trie *t = (struct trie *) tb->tb_data;
> +	struct trie *t = (struct trie *)tb->tb_data;
>  	int plen, ret = 0;
>  	struct node *n;
>  	struct tnode *pn;
> @@ -1355,11 +1366,12 @@ fn_trie_lookup(struct fib_table *tb, con
> 
>  	/* Just a leaf? */
>  	if (IS_LEAF(n)) {
> -		if ((ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res)) <= 0)
> +		ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res);
> +		if (ret <= 0)
>  			goto found;
>  		goto failed;
>  	}
> -	pn = (struct tnode *) n;
> +	pn = (struct tnode *)n;
>  	chopped_off = 0;
> 
>  	while (pn) {
> @@ -1367,7 +1379,7 @@ fn_trie_lookup(struct fib_table *tb, con
>  		bits = pn->bits;
> 
>  		if (!chopped_off)
> -			cindex = tkey_extract_bits(mask_pfx(key, current_prefix_length),
> +			cindex = tkey_extract_bits(mask_pfx (key, current_prefix_length),
>  						   pos, bits);
> 
>  		n = tnode_get_child(pn, cindex);
> @@ -1380,12 +1392,12 @@ fn_trie_lookup(struct fib_table *tb, con
>  		}
> 
>  		if (IS_LEAF(n)) {
> -			if ((ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res)) <= 0)
> +			ret = check_leaf(t, (struct leaf *)n, key, &plen, flp, res);
> +			if (ret <= 0)
>  				goto found;
>  			else
>  				goto backtrace;
>  		}
> -
>  #define HL_OPTIMIZE
>  #ifdef HL_OPTIMIZE
>  		cn = (struct tnode *)n;
> @@ -1418,10 +1430,10 @@ fn_trie_lookup(struct fib_table *tb, con
> 
>  		/* NOTA BENE: CHECKING ONLY SKIPPED BITS FOR THE NEW NODE HERE */
> 
> -		if (current_prefix_length < pos+bits) {
> +		if (current_prefix_length < pos + bits) {
>  			if (tkey_extract_bits(cn->key, current_prefix_length,
> -						cn->pos - current_prefix_length) != 0 ||
> -			    !(cn->child[0]))
> +					      cn->pos - current_prefix_length) != 0
> +			    || !(cn->child[0]))
>  				goto backtrace;
>  		}
> 
> @@ -1456,19 +1468,19 @@ fn_trie_lookup(struct fib_table *tb, con
> 
>  		node_prefix = mask_pfx(cn->key, cn->pos);
>  		key_prefix = mask_pfx(key, cn->pos);
> -		pref_mismatch = key_prefix^node_prefix;
> +		pref_mismatch = key_prefix ^ node_prefix;
>  		mp = 0;
> 
>  		/* In short: If skipped bits in this node do not match the search
>  		 * key, enter the "prefix matching" state.directly.
>  		 */
>  		if (pref_mismatch) {
> -			while (!(pref_mismatch & (1<<(KEYLENGTH-1)))) {
> +			while (!(pref_mismatch & (1 << (KEYLENGTH - 1)))) {
>  				mp++;
> -				pref_mismatch = pref_mismatch <<1;
> +				pref_mismatch = pref_mismatch << 1;
>  			}
> -			key_prefix = tkey_extract_bits(cn->key, mp, cn->pos-mp);
> 
> +			key_prefix = tkey_extract_bits(cn->key, mp, cn->pos - mp);
>  			if (key_prefix != 0)
>  				goto backtrace;
> 
> @@ -1476,7 +1488,7 @@ fn_trie_lookup(struct fib_table *tb, con
>  				current_prefix_length = mp;
>  		}
>  #endif
> -		pn = (struct tnode *)n; /* Descend */
> +		pn = (struct tnode *)n;	/* Descend */
>  		chopped_off = 0;
>  		continue;
> 
> @@ -1484,12 +1496,14 @@ backtrace:
>  		chopped_off++;
> 
>  		/* As zero don't change the child key (cindex) */
> -		while ((chopped_off <= pn->bits) && !(cindex & (1<<(chopped_off-1))))
> +		while (chopped_off <= pn->bits
> +		       && !(cindex & (1 << (chopped_off - 1))))
>  			chopped_off++;
> 
>  		/* Decrease current_... with bits chopped off */
>  		if (current_prefix_length > pn->pos + pn->bits - chopped_off)
> -			current_prefix_length = pn->pos + pn->bits - chopped_off;
> +			current_prefix_length =
> +			    pn->pos + pn->bits - chopped_off;
> 
>  		/*
>  		 * Either we do the actual chop off according or if we have
> @@ -1497,14 +1511,15 @@ backtrace:
>  		 */
> 
>  		if (chopped_off <= pn->bits) {
> -			cindex &= ~(1 << (chopped_off-1));
> +			cindex &= ~(1 << (chopped_off - 1));
>  		} else {
> -			struct tnode *parent = node_parent((struct node *) pn);
> +			struct tnode *parent = node_parent((struct node *)pn);
>  			if (!parent)
>  				goto failed;
> 
>  			/* Get Child's index */
> -			cindex = tkey_extract_bits(pn->key, parent->pos, parent->bits);
> +			cindex = tkey_extract_bits(pn->key,
> +						   parent->pos, parent->bits);
>  			pn = parent;
>  			chopped_off = 0;
> 
> @@ -1537,13 +1552,13 @@ static int trie_leaf_remove(struct trie 
>  	 */
> 
>  	while (n != NULL && IS_TNODE(n)) {
> -		struct tnode *tn = (struct tnode *) n;
> +		struct tnode *tn = (struct tnode *)n;
>  		check_tnode(tn);
> -		n = tnode_get_child(tn ,tkey_extract_bits(key, tn->pos, tn->bits));
> +		n = tnode_get_child(tn, tkey_extract_bits(key, tn->pos, tn->bits));
> 
>  		BUG_ON(n && node_parent(n) != tn);
>  	}
> -	l = (struct leaf *) n;
> +	l = (struct leaf *)n;
> 
>  	if (!n || !tkey_equals(l->key, key))
>  		return 0;
> @@ -1557,7 +1572,7 @@ static int trie_leaf_remove(struct trie 
>  	t->size--;
> 
>  	tp = node_parent(n);
> -	tnode_free((struct tnode *) n);
> +	tnode_free((struct tnode *)n);
> 
>  	if (tp) {
>  		cindex = tkey_extract_bits(key, tp->pos, tp->bits);
> @@ -1574,7 +1589,7 @@ static int trie_leaf_remove(struct trie 
>   */
>  static int fn_trie_delete(struct fib_table *tb, struct fib_config *cfg)
>  {
> -	struct trie *t = (struct trie *) tb->tb_data;
> +	struct trie *t = (struct trie *)tb->tb_data;
>  	u32 key, mask;
>  	int plen = cfg->fc_dst_len;
>  	u8 tos = cfg->fc_tos;
> @@ -1694,7 +1709,7 @@ static int trie_flush_leaf(struct trie *
> 
>  static struct leaf *nextleaf(struct trie *t, struct leaf *thisleaf)
>  {
> -	struct node *c = (struct node *) thisleaf;
> +	struct node *c = (struct node *)thisleaf;
>  	struct tnode *p;
>  	int idx;
>  	struct node *trie = rcu_dereference(t->trie);
> @@ -1703,10 +1718,10 @@ static struct leaf *nextleaf(struct trie
>  		if (trie == NULL)
>  			return NULL;
> 
> -		if (IS_LEAF(trie))          /* trie w. just a leaf */
> -			return (struct leaf *) trie;
> +		if (IS_LEAF(trie))	/* trie w. just a leaf */
> +			return (struct leaf *)trie;
> 
> -		p = (struct tnode*) trie;  /* Start */
> +		p = (struct tnode *)trie;	/* Start */
>  	} else
>  		p = node_parent(c);
> 
> @@ -1720,7 +1735,7 @@ static struct leaf *nextleaf(struct trie
>  			pos = 0;
> 
>  		last = 1 << p->bits;
> -		for (idx = pos; idx < last ; idx++) {
> +		for (idx = pos; idx < last; idx++) {
>  			c = rcu_dereference(p->child[idx]);
> 
>  			if (!c)
> @@ -1728,26 +1743,28 @@ static struct leaf *nextleaf(struct trie
> 
>  			/* Decend if tnode */
>  			while (IS_TNODE(c)) {
> -				p = (struct tnode *) c;
> +				p = (struct tnode *)c;
>  				idx = 0;
> 
>  				/* Rightmost non-NULL branch */
>  				if (p && IS_TNODE(p))
>  					while (!(c = rcu_dereference(p->child[idx]))
> -					       && idx < (1<<p->bits)) idx++;
> +					       && idx < (1 << p->bits))
> +						idx++;
> 
>  				/* Done with this tnode? */
>  				if (idx >= (1 << p->bits) || !c)
>  					goto up;
>  			}
> -			return (struct leaf *) c;
> +			return (struct leaf *)c;
>  		}
>  up:
>  		/* No more children go up one step  */
> -		c = (struct node *) p;
> +		c = (struct node *)p;
>  		p = node_parent(c);
>  	}
> -	return NULL; /* Ready. Root of trie */
> +
> +	return NULL;		/* Ready. Root of trie */
>  }
> 
>  /*
> @@ -1755,7 +1772,7 @@ up:
>   */
>  static int fn_trie_flush(struct fib_table *tb)
>  {
> -	struct trie *t = (struct trie *) tb->tb_data;
> +	struct trie *t = (struct trie *)tb->tb_data;
>  	struct leaf *ll = NULL, *l = NULL;
>  	int found = 0, h;
> 
> @@ -1779,9 +1796,10 @@ static int fn_trie_flush(struct fib_tabl
>  static int trie_last_dflt = -1;
> 
>  static void
> -fn_trie_select_default(struct fib_table *tb, const struct flowi *flp, struct fib_result *res)
> +fn_trie_select_default(struct fib_table *tb, const struct flowi *flp,
> +		       struct fib_result *res)
>  {
> -	struct trie *t = (struct trie *) tb->tb_data;
> +	struct trie *t = (struct trie *)tb->tb_data;
>  	int order, last_idx;
>  	struct fib_info *fi = NULL;
>  	struct fib_info *last_resort;
> @@ -1809,8 +1827,7 @@ fn_trie_select_default(struct fib_table 
>  	list_for_each_entry_rcu(fa, fa_head, fa_list) {
>  		struct fib_info *next_fi = fa->fa_info;
> 
> -		if (fa->fa_scope != res->scope ||
> -		    fa->fa_type != RTN_UNICAST)
> +		if (fa->fa_scope != res->scope || fa->fa_type != RTN_UNICAST)
>  			continue;
> 
>  		if (next_fi->fib_priority > res->fi->fib_priority)
> @@ -1856,12 +1873,13 @@ fn_trie_select_default(struct fib_table 
>  			atomic_inc(&last_resort->fib_clntref);
>  	}
>  	trie_last_dflt = last_idx;
> - out:;
> +out:
>  	rcu_read_unlock();
>  }
> 
> -static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah, struct fib_table *tb,
> -			   struct sk_buff *skb, struct netlink_callback *cb)
> +static int fn_trie_dump_fa(t_key key, int plen, struct list_head *fah,
> +			   struct fib_table *tb, struct sk_buff *skb,
> +			   struct netlink_callback *cb)
>  {
>  	int i, s_i;
>  	struct fib_alias *fa;
> @@ -1886,10 +1904,7 @@ static int fn_trie_dump_fa(t_key key, in
>  				  tb->tb_id,
>  				  fa->fa_type,
>  				  fa->fa_scope,
> -				  xkey,
> -				  plen,
> -				  fa->fa_tos,
> -				  fa->fa_info, 0) < 0) {
> +				  xkey, plen, fa->fa_tos, fa->fa_info, 0) < 0) {
>  			cb->args[4] = i;
>  			return -1;
>  		}
> @@ -1899,8 +1914,8 @@ static int fn_trie_dump_fa(t_key key, in
>  	return skb->len;
>  }
> 
> -static int fn_trie_dump_plen(struct trie *t, int plen, struct fib_table *tb, struct sk_buff *skb,
> -			     struct netlink_callback *cb)
> +static int fn_trie_dump_plen(struct trie *t, int plen, struct fib_table *tb,
> +			     struct sk_buff *skb, struct netlink_callback *cb)
>  {
>  	int h, s_h;
>  	struct list_head *fa_head;
> @@ -1913,7 +1928,7 @@ static int fn_trie_dump_plen(struct trie
>  			continue;
>  		if (h > s_h)
>  			memset(&cb->args[4], 0,
> -			       sizeof(cb->args) - 4*sizeof(cb->args[0]));
> +			       sizeof(cb->args) - 4 * sizeof(cb->args[0]));
> 
>  		fa_head = get_fa_head(l, plen);
> 
> @@ -1923,7 +1938,7 @@ static int fn_trie_dump_plen(struct trie
>  		if (list_empty(fa_head))
>  			continue;
> 
> -		if (fn_trie_dump_fa(l->key, plen, fa_head, tb, skb, cb)<0) {
> +		if (fn_trie_dump_fa(l->key, plen, fa_head, tb, skb, cb) < 0) {
>  			cb->args[3] = h;
>  			return -1;
>  		}
> @@ -1932,10 +1947,11 @@ static int fn_trie_dump_plen(struct trie
>  	return skb->len;
>  }
> 
> -static int fn_trie_dump(struct fib_table *tb, struct sk_buff *skb, struct netlink_callback *cb)
> +static int fn_trie_dump(struct fib_table *tb, struct sk_buff *skb,
> +			struct netlink_callback *cb)
>  {
>  	int m, s_m;
> -	struct trie *t = (struct trie *) tb->tb_data;
> +	struct trie *t = (struct trie *)tb->tb_data;
> 
>  	s_m = cb->args[2];
> 
> @@ -1945,9 +1961,9 @@ static int fn_trie_dump(struct fib_table
>  			continue;
>  		if (m > s_m)
>  			memset(&cb->args[3], 0,
> -				sizeof(cb->args) - 3*sizeof(cb->args[0]));
> +			       sizeof(cb->args) - 3 * sizeof(cb->args[0]));
> 
> -		if (fn_trie_dump_plen(t, 32-m, tb, skb, cb)<0) {
> +		if (fn_trie_dump_plen(t, 32 - m, tb, skb, cb) < 0) {
>  			cb->args[2] = m;
>  			goto out;
>  		}
> @@ -1963,9 +1979,9 @@ out:
>  /* Fix more generic FIB names for init later */
> 
>  #ifdef CONFIG_IP_MULTIPLE_TABLES
> -struct fib_table * fib_hash_init(u32 id)
> +struct fib_table *fib_hash_init(u32 id)
>  #else
> -struct fib_table * __init fib_hash_init(u32 id)
> +struct fib_table *__init fib_hash_init(u32 id)
>  #endif
>  {
>  	struct fib_table *tb;
> @@ -1974,8 +1990,7 @@ struct fib_table * __init fib_hash_init(
>  	if (fn_alias_kmem == NULL)
>  		fn_alias_kmem = kmem_cache_create("ip_fib_alias",
>  						  sizeof(struct fib_alias),
> -						  0, SLAB_HWCACHE_ALIGN,
> -						  NULL);
> +						  0, SLAB_HWCACHE_ALIGN, NULL);
> 
>  	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct trie),
>  		     GFP_KERNEL);
> @@ -1991,7 +2006,7 @@ struct fib_table * __init fib_hash_init(
>  	tb->tb_dump = fn_trie_dump;
>  	memset(tb->tb_data, 0, sizeof(struct trie));
> 
> -	t = (struct trie *) tb->tb_data;
> +	t = (struct trie *)tb->tb_data;
> 
>  	trie_init(t);
> 
> @@ -2001,7 +2016,8 @@ struct fib_table * __init fib_hash_init(
>  		trie_main = t;
> 
>  	if (id == RT_TABLE_LOCAL)
> -		printk(KERN_INFO "IPv4 FIB: Using LC-trie version %s\n", VERSION);
> +		printk(KERN_INFO "IPv4 FIB: Using LC-trie version %s\n",
> +		       VERSION);
> 
>  	return tb;
>  }
> @@ -2028,7 +2044,7 @@ static struct node *fib_trie_get_next(st
>  	pr_debug("get_next iter={node=%p index=%d depth=%d}\n",
>  		 iter->tnode, iter->index, iter->depth);
>  rescan:
> -	while (cindex < (1<<tn->bits)) {
> +	while (cindex < (1 << tn->bits)) {
>  		struct node *n = tnode_get_child(tn, cindex);
> 
>  		if (n) {
> @@ -2037,7 +2053,7 @@ rescan:
>  				iter->index = cindex + 1;
>  			} else {
>  				/* push down one level */
> -				iter->tnode = (struct tnode *) n;
> +				iter->tnode = (struct tnode *)n;
>  				iter->index = 0;
>  				++iter->depth;
>  			}
> @@ -2050,7 +2066,7 @@ rescan:
>  	/* Current node exhausted, pop back up */
>  	p = node_parent((struct node *)tn);
>  	if (p) {
> -		cindex = tkey_extract_bits(tn->key, p->pos, p->bits)+1;
> +		cindex = tkey_extract_bits(tn->key, p->pos, p->bits) + 1;
>  		tn = p;
>  		--iter->depth;
>  		goto rescan;
> @@ -2063,7 +2079,7 @@ rescan:
>  static struct node *fib_trie_get_first(struct fib_trie_iter *iter,
>  				       struct trie *t)
>  {
> -	struct node *n ;
> +	struct node *n;
> 
>  	if (!t)
>  		return NULL;
> @@ -2075,13 +2091,13 @@ static struct node *fib_trie_get_first(s
> 
>  	if (n) {
>  		if (IS_TNODE(n)) {
> -			iter->tnode = (struct tnode *) n;
> +			iter->tnode = (struct tnode *)n;
>  			iter->trie = t;
>  			iter->index = 0;
>  			iter->depth = 1;
>  		} else {
>  			iter->tnode = NULL;
> -			iter->trie  = t;
> +			iter->trie = t;
>  			iter->index = 0;
>  			iter->depth = 0;
>  		}
> @@ -2098,22 +2114,21 @@ static void trie_collect_stats(struct tr
>  	memset(s, 0, sizeof(*s));
> 
>  	rcu_read_lock();
> -	for (n = fib_trie_get_first(&iter, t); n;
> -	     n = fib_trie_get_next(&iter)) {
> +	for (n = fib_trie_get_first(&iter, t); n; n = fib_trie_get_next(&iter)) {
>  		if (IS_LEAF(n)) {
>  			s->leaves++;
>  			s->totdepth += iter.depth;
>  			if (iter.depth > s->maxdepth)
>  				s->maxdepth = iter.depth;
>  		} else {
> -			const struct tnode *tn = (const struct tnode *) n;
> +			const struct tnode *tn = (const struct tnode *)n;
>  			int i;
> 
>  			s->tnodes++;
>  			if (tn->bits < MAX_STAT_DEPTH)
>  				s->nodesizes[tn->bits]++;
> 
> -			for (i = 0; i < (1<<tn->bits); i++)
> +			for (i = 0; i < (1 << tn->bits); i++)
>  				if (!tn->child[i])
>  					s->nullpointers++;
>  		}
> @@ -2129,11 +2144,12 @@ static void trie_show_stats(struct seq_f
>  	unsigned i, max, pointers, bytes, avdepth;
> 
>  	if (stat->leaves)
> -		avdepth = stat->totdepth*100 / stat->leaves;
> +		avdepth = stat->totdepth * 100 / stat->leaves;
>  	else
>  		avdepth = 0;
> 
> -	seq_printf(seq, "\tAver depth:     %d.%02d\n", avdepth / 100, avdepth % 100 );
> +	seq_printf(seq, "\tAver depth:     %d.%02d\n", avdepth / 100,
> +		   avdepth % 100);
>  	seq_printf(seq, "\tMax depth:      %u\n", stat->maxdepth);
> 
>  	seq_printf(seq, "\tLeaves:         %u\n", stat->leaves);
> @@ -2143,14 +2159,14 @@ static void trie_show_stats(struct seq_f
>  	bytes += sizeof(struct tnode) * stat->tnodes;
> 
>  	max = MAX_STAT_DEPTH;
> -	while (max > 0 && stat->nodesizes[max-1] == 0)
> +	while (max > 0 && stat->nodesizes[max - 1] == 0)
>  		max--;
> 
>  	pointers = 0;
>  	for (i = 1; i <= max; i++)
>  		if (stat->nodesizes[i] != 0) {
> -			seq_printf(seq, "  %d: %d",  i, stat->nodesizes[i]);
> -			pointers += (1<<i) * stat->nodesizes[i];
> +			seq_printf(seq, "  %d: %d", i, stat->nodesizes[i]);
> +			pointers += (1 << i) * stat->nodesizes[i];
>  		}
>  	seq_putc(seq, '\n');
>  	seq_printf(seq, "\tPointers: %d\n", pointers);
> @@ -2161,12 +2177,15 @@ static void trie_show_stats(struct seq_f
> 
>  #ifdef CONFIG_IP_FIB_TRIE_STATS
>  	seq_printf(seq, "Counters:\n---------\n");
> -	seq_printf(seq,"gets = %d\n", t->stats.gets);
> -	seq_printf(seq,"backtracks = %d\n", t->stats.backtrack);
> -	seq_printf(seq,"semantic match passed = %d\n", t->stats.semantic_match_passed);
> -	seq_printf(seq,"semantic match miss = %d\n", t->stats.semantic_match_miss);
> -	seq_printf(seq,"null node hit= %d\n", t->stats.null_node_hit);
> -	seq_printf(seq,"skipped node resize = %d\n", t->stats.resize_node_skipped);
> +	seq_printf(seq, "gets = %d\n", t->stats.gets);
> +	seq_printf(seq, "backtracks = %d\n", t->stats.backtrack);
> +	seq_printf(seq, "semantic match passed = %d\n",
> +		   t->stats.semantic_match_passed);
> +	seq_printf(seq, "semantic match miss = %d\n",
> +		   t->stats.semantic_match_miss);
> +	seq_printf(seq, "null node hit= %d\n", t->stats.null_node_hit);
> +	seq_printf(seq, "skipped node resize = %d\n",
> +		   t->stats.resize_node_skipped);
>  #ifdef CLEAR_STATS
>  	memset(&(t->stats), 0, sizeof(t->stats));
>  #endif
> @@ -2181,7 +2200,8 @@ static int fib_triestat_seq_show(struct 
>  	if (!stat)
>  		return -ENOMEM;
> 
> -	seq_printf(seq, "Basic info: size of leaf: %Zd bytes, size of tnode: %Zd bytes.\n",
> +	seq_printf(seq,
> +		   "Basic info: size of leaf: %Zd bytes, size of tnode: %Zd bytes.\n",
>  		   sizeof(struct leaf), sizeof(struct tnode));
> 
>  	if (trie_local) {
> @@ -2213,8 +2233,7 @@ static const struct file_operations fib_
>  	.release = single_release,
>  };
> 
> -static struct node *fib_trie_get_idx(struct fib_trie_iter *iter,
> -				      loff_t pos)
> +static struct node *fib_trie_get_idx(struct fib_trie_iter *iter, loff_t pos)
>  {
>  	loff_t idx = 0;
>  	struct node *n;
> @@ -2233,7 +2252,7 @@ static struct node *fib_trie_get_idx(str
>  	return NULL;
>  }
> 
> -static void *fib_trie_seq_start(struct seq_file *seq, loff_t *pos)
> +static void *fib_trie_seq_start(struct seq_file *seq, loff_t * pos)
>  {
>  	rcu_read_lock();
>  	if (*pos == 0)
> @@ -2241,7 +2260,7 @@ static void *fib_trie_seq_start(struct s
>  	return fib_trie_get_idx(seq->private, *pos - 1);
>  }
> 
> -static void *fib_trie_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> +static void *fib_trie_seq_next(struct seq_file *seq, void *v, loff_t * pos)
>  {
>  	struct fib_trie_iter *iter = seq->private;
>  	void *l = v;
> @@ -2269,7 +2288,8 @@ static void fib_trie_seq_stop(struct seq
> 
>  static void seq_indent(struct seq_file *seq, int n)
>  {
> -	while (n-- > 0) seq_puts(seq, "   ");
> +	while (n-- > 0)
> +		seq_puts(seq, "   ");
>  }
> 
>  static inline const char *rtn_scope(enum rt_scope_t s)
> @@ -2277,11 +2297,16 @@ static inline const char *rtn_scope(enum
>  	static char buf[32];
> 
>  	switch (s) {
> -	case RT_SCOPE_UNIVERSE: return "universe";
> -	case RT_SCOPE_SITE:	return "site";
> -	case RT_SCOPE_LINK:	return "link";
> -	case RT_SCOPE_HOST:	return "host";
> -	case RT_SCOPE_NOWHERE:	return "nowhere";
> +	case RT_SCOPE_UNIVERSE:
> +		return "universe";
> +	case RT_SCOPE_SITE:
> +		return "site";
> +	case RT_SCOPE_LINK:
> +		return "link";
> +	case RT_SCOPE_HOST:
> +		return "host";
> +	case RT_SCOPE_NOWHERE:
> +		return "nowhere";
>  	default:
>  		snprintf(buf, sizeof(buf), "scope=%d", s);
>  		return buf;
> @@ -2330,16 +2355,16 @@ static int fib_trie_seq_show(struct seq_
>  	}
> 
>  	if (IS_TNODE(n)) {
> -		struct tnode *tn = (struct tnode *) n;
> +		struct tnode *tn = (struct tnode *)n;
>  		__be32 prf = htonl(mask_pfx(tn->key, tn->pos));
> 
> -		seq_indent(seq, iter->depth-1);
> +		seq_indent(seq, iter->depth - 1);
>  		seq_printf(seq, "  +-- %d.%d.%d.%d/%d %d %d %d\n",
>  			   NIPQUAD(prf), tn->pos, tn->bits, tn->full_children,
>  			   tn->empty_children);
> 
>  	} else {
> -		struct leaf *l = (struct leaf *) n;
> +		struct leaf *l = (struct leaf *)n;
>  		int i;
>  		__be32 val = htonl(l->key);
> 
> @@ -2350,7 +2375,7 @@ static int fib_trie_seq_show(struct seq_
>  			if (li) {
>  				struct fib_alias *fa;
>  				list_for_each_entry_rcu(fa, &li->falh, fa_list) {
> -					seq_indent(seq, iter->depth+1);
> +					seq_indent(seq, iter->depth + 1);
>  					seq_printf(seq, "  /%d %s %s", i,
>  						   rtn_scope(fa->fa_scope),
>  						   rtn_type(fa->fa_type));
> @@ -2386,7 +2411,7 @@ static int fib_trie_seq_open(struct inod
>  	if (rc)
>  		goto out_kfree;
> 
> -	seq	     = file->private_data;
> +	seq = file->private_data;
>  	seq->private = s;
>  	memset(s, 0, sizeof(*s));
>  out:
> @@ -2407,7 +2432,8 @@ static const struct file_operations fib_
>  static unsigned fib_flag_trans(int type, __be32 mask, const struct fib_info *fi)
>  {
>  	static unsigned type2flags[RTN_MAX + 1] = {
> -		[7] = RTF_REJECT, [8] = RTF_REJECT,
> +		[7] = RTF_REJECT,
> +		[8] = RTF_REJECT,
>  	};
>  	unsigned flags = type2flags[type];
> 
> @@ -2444,7 +2470,7 @@ static int fib_route_seq_show(struct seq
>  	if (IS_TNODE(l))
>  		return 0;
> 
> -	for (i=32; i>=0; i--) {
> +	for (i = 32; i >= 0; i--) {
>  		struct leaf_info *li = find_leaf_info(l, i);
>  		struct fib_alias *fa;
>  		__be32 mask, prefix;
> @@ -2471,7 +2497,7 @@ static int fib_route_seq_show(struct seq
>  					 fi->fib_nh->nh_gw, flags, 0, 0,
>  					 fi->fib_priority,
>  					 mask,
> -					 (fi->fib_advmss ? fi->fib_advmss + 40 : 0),
> +					 fi->fib_advmss ? fi->fib_advmss + 40 : 0,
>  					 fi->fib_window,
>  					 fi->fib_rtt >> 3);
>  			else
> @@ -2507,7 +2533,7 @@ static int fib_route_seq_open(struct ino
>  	if (rc)
>  		goto out_kfree;
> 
> -	seq	     = file->private_data;
> +	seq = file->private_data;
>  	seq->private = s;
>  	memset(s, 0, sizeof(*s));
>  out:
