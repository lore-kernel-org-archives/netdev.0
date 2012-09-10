From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 3/3] fib6: remove some useless empty lines and comments
Date: Mon, 10 Sep 2012 20:48:46 +0800
Message-ID: <1347281326-26890-3-git-send-email-amwang@redhat.com>
References: <1347281326-26890-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757856Ab2IJMs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 08:48:58 -0400
In-Reply-To: <1347281326-26890-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are too many empty lines in this source file,
remove the useless ones, together with some useless
comments.

Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/ip6_fib.c |   78 +--------------------------------------------------
 1 files changed, 2 insertions(+), 76 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 13690d6..b4faf2d 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -88,7 +88,6 @@ static int fib6_walk_continue(struct fib6_walker_t *w);
  *	tested when modifications are made to the destination cache as a
  *	result of redirects, path MTU changes, etc.
  */
-
 static __u32 rt_sernum;
 
 static void fib6_gc_timer_cb(unsigned long arg);
@@ -123,10 +122,6 @@ static __inline__ u32 fib6_new_sernum(void)
  *	These assume a 32bit processor (although it will work on
  *	64bit processors)
  */
-
-/*
- *	test bit
- */
 #if defined(__LITTLE_ENDIAN)
 # define BITOP_BE32_SWIZZLE	(0x1F & ~7)
 #else
@@ -369,7 +364,6 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 
 	s_h = cb->args[0];
 	s_e = cb->args[1];
-
 	w = (void *)cb->args[2];
 	if (!w) {
 		/* New dump:
@@ -378,7 +372,6 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 		 */
 		cb->args[3] = (long)cb->done;
 		cb->done = fib6_dump_done;
-
 		/*
 		 * 2. allocate and initialize walker.
 		 */
@@ -426,7 +419,6 @@ out:
  *	by either creating and inserting or by returning an existing
  *	node.
  */
-
 static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 				     int addrlen, int plen,
 				     int offset, int allow_create,
@@ -442,12 +434,9 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 	RT6_TRACE("fib6_add_1\n");
 
 	/* insert node in tree */
-
 	fn = root;
-
 	do {
 		key = (struct rt6key *)((u8 *)fn->leaf + offset);
-
 		/*
 		 *	Prefix match
 		 */
@@ -466,23 +455,17 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 		/*
 		 *	Exact match ?
 		 */
-
 		if (plen == fn->fn_bit) {
 			/* clean up an intermediate node */
 			if (!(fn->fn_flags & RTN_RTINFO)) {
 				rt6_release(fn->leaf);
 				fn->leaf = NULL;
 			}
-
 			fn->fn_sernum = sernum;
 
 			return fn;
 		}
 
-		/*
-		 *	We have more bits to go
-		 */
-
 		/* Try to walk down on tree. */
 		fn->fn_sernum = sernum;
 		dir = addr_bit_set(addr, fn->fn_bit);
@@ -512,11 +495,10 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 	 */
 
 	ln = node_alloc();
-
 	if (!ln)
 		return NULL;
-	ln->fn_bit = plen;
 
+	ln->fn_bit = plen;
 	ln->parent = pn;
 	ln->fn_sernum = sernum;
 
@@ -527,7 +509,6 @@ static struct fib6_node * fib6_add_1(struct fib6_node *root, void *addr,
 
 	return ln;
 
-
 insert_above:
 	/*
 	 * split since we don't have a common prefix anymore or
@@ -536,17 +517,13 @@ insert_above:
 	 * this new node will point to the one we need to create
 	 * and the current
 	 */
-
 	pn = fn->parent;
-
 	/* find 1st bit in difference between the 2 addrs.
 
 	   See comment in __ipv6_addr_diff: bit may be an invalid value,
 	   but if it is >= plen, the value is ignored in any case.
 	 */
-
 	bit = __ipv6_addr_diff(addr, &key->addr, addrlen);
-
 	/*
 	 *		(intermediate)[in]
 	 *	          /	   \
@@ -571,15 +548,11 @@ insert_above:
 		 * the branches would not match less specific routes
 		 * in the other branch
 		 */
-
 		in->fn_bit = bit;
-
 		in->parent = pn;
 		in->leaf = fn->leaf;
 		atomic_inc(&in->leaf->rt6i_ref);
-
 		in->fn_sernum = sernum;
-
 		/* update parent pointer */
 		if (dir)
 			pn->right = in;
@@ -587,10 +560,8 @@ insert_above:
 			pn->left  = in;
 
 		ln->fn_bit = plen;
-
 		ln->parent = in;
 		fn->parent = in;
-
 		ln->fn_sernum = sernum;
 
 		if (addr_bit_set(addr, bit)) {
@@ -607,16 +578,12 @@ insert_above:
 		 *	          /	   \
 		 *	     (old node)[fn] NULL
 		 */
-
 		ln = node_alloc();
-
 		if (!ln)
 			return NULL;
 
 		ln->fn_bit = plen;
-
 		ln->parent = pn;
-
 		ln->fn_sernum = sernum;
 
 		if (dir)
@@ -637,7 +604,6 @@ insert_above:
 /*
  *	Insert routing information in a node.
  */
-
 static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 			    struct nl_info *info)
 {
@@ -650,12 +616,10 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 	int found = 0;
 
 	ins = &fn->leaf;
-
 	for (iter = fn->leaf; iter; iter = iter->dst.rt6_next) {
 		/*
 		 *	Search for duplicates
 		 */
-
 		if (iter->rt6i_metric == rt->rt6i_metric) {
 			/*
 			 *	Same priority level
@@ -667,7 +631,6 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 				found++;
 				break;
 			}
-
 			if (iter->dst.dev == rt->dst.dev &&
 			    iter->rt6i_idev == rt->rt6i_idev &&
 			    ipv6_addr_equal(&iter->rt6i_gateway,
@@ -681,24 +644,20 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
 				return -EEXIST;
 			}
 		}
-
 		if (iter->rt6i_metric > rt->rt6i_metric)
 			break;
-
 		ins = &iter->dst.rt6_next;
 	}
 
 	/* Reset round-robin state, if necessary */
 	if (ins == &fn->leaf)
 		fn->rr_ptr = NULL;
-
 	/*
 	 *	insert node
 	 */
 	if (!replace) {
 		if (!add)
 			pr_warn("NLM_F_CREATE should be set when creating new route\n");
-
 add:
 		rt->dst.rt6_next = iter;
 		*ins = rt;
@@ -706,12 +665,10 @@ add:
 		atomic_inc(&rt->rt6i_ref);
 		inet6_rt_notify(RTM_NEWROUTE, rt, info);
 		info->nl_net->ipv6.rt6_stats->fib_rt_entries++;
-
 		if (!(fn->fn_flags & RTN_RTINFO)) {
 			info->nl_net->ipv6.rt6_stats->fib_route_nodes++;
 			fn->fn_flags |= RTN_RTINFO;
 		}
-
 	} else {
 		if (!found) {
 			if (add)
@@ -818,7 +775,6 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 					sizeof(struct in6_addr), rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
 					allow_create, replace_required);
-
 			if (!sn) {
 				/* If it is failed, discard just allocated
 				   root, and then (in st_failure) stale node
@@ -827,7 +783,6 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 				node_free(sfn);
 				goto st_failure;
 			}
-
 			/* Now link new subtree to main tree */
 			sfn->parent = fn;
 			fn->subtree = sfn;
@@ -836,7 +791,6 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 					sizeof(struct in6_addr), rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
 					allow_create, replace_required);
-
 			if (IS_ERR(sn)) {
 				err = PTR_ERR(sn);
 				sn = NULL;
@@ -852,7 +806,6 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info)
 		fn = sn;
 	}
 #endif
-
 	err = fib6_add_rt2node(fn, rt, info);
 	if (!err) {
 		fib6_start_gc(info->nl_net, rt);
@@ -916,20 +869,15 @@ static struct fib6_node * fib6_lookup_1(struct fib6_node *root,
 
 	if (unlikely(args->offset == 0))
 		return NULL;
-
 	/*
 	 *	Descend on a tree
 	 */
-
 	fn = root;
-
 	for (;;) {
 		struct fib6_node *next;
 
 		dir = addr_bit_set(args->addr, fn->fn_bit);
-
 		next = dir ? fn->right : fn->left;
-
 		if (next) {
 			fn = next;
 			continue;
@@ -943,7 +891,6 @@ static struct fib6_node * fib6_lookup_1(struct fib6_node *root,
 
 			key = (struct rt6key *) ((u8 *) fn->leaf +
 						 args->offset);
-
 			if (ipv6_prefix_equal(&key->addr, args->addr, key->plen)) {
 #ifdef CONFIG_IPV6_SUBTREES
 				if (fn->subtree)
@@ -953,10 +900,8 @@ static struct fib6_node * fib6_lookup_1(struct fib6_node *root,
 					return fn;
 			}
 		}
-
 		if (fn->fn_flags & RTN_ROOT)
 			break;
-
 		fn = fn->parent;
 	}
 
@@ -994,8 +939,6 @@ struct fib6_node * fib6_lookup(struct fib6_node *root, const struct in6_addr *da
  *	Get node with specified destination prefix (and source prefix,
  *	if subtrees are used)
  */
-
-
 static struct fib6_node * fib6_locate_1(struct fib6_node *root,
 					const struct in6_addr *addr,
 					int plen, int offset)
@@ -1004,17 +947,14 @@ static struct fib6_node * fib6_locate_1(struct fib6_node *root,
 
 	for (fn = root; fn ; ) {
 		struct rt6key *key = (struct rt6key *)((u8 *)fn->leaf + offset);
-
 		/*
 		 *	Prefix match
 		 */
 		if (plen < fn->fn_bit ||
 		    !ipv6_prefix_equal(&key->addr, addr, fn->fn_bit))
 			return NULL;
-
 		if (plen == fn->fn_bit)
 			return fn;
-
 		/*
 		 *	We have more bits to go
 		 */
@@ -1034,7 +974,6 @@ struct fib6_node * fib6_locate(struct fib6_node *root,
 
 	fn = fib6_locate_1(root, daddr, dst_len,
 			   offsetof(struct rt6_info, rt6i_dst));
-
 #ifdef CONFIG_IPV6_SUBTREES
 	if (src_len) {
 		WARN_ON(saddr == NULL);
@@ -1043,19 +982,12 @@ struct fib6_node * fib6_locate(struct fib6_node *root,
 					   offsetof(struct rt6_info, rt6i_src));
 	}
 #endif
-
 	if (fn && fn->fn_flags & RTN_RTINFO)
 		return fn;
 
 	return NULL;
 }
 
-
-/*
- *	Deletion
- *
- */
-
 static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn)
 {
 	if (fn->fn_flags & RTN_ROOT)
@@ -1076,7 +1008,6 @@ static struct rt6_info *fib6_find_prefix(struct net *net, struct fib6_node *fn)
  *	Called to trim the tree of intermediate nodes when possible. "fn"
  *	is the node we want to try and remove.
  */
-
 static struct fib6_node *fib6_repair_tree(struct net *net,
 					   struct fib6_node *fn)
 {
@@ -1270,11 +1201,9 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
 #endif
 		fib6_prune_clones(info->nl_net, pn, rt);
 	}
-
 	/*
 	 *	Walk the leaf entries looking for ourself
 	 */
-
 	for (rtp = &fn->leaf; *rtp; rtp = &(*rtp)->dst.rt6_next) {
 		if (*rtp == rt) {
 			fib6_del_route(fn, rtp, info);
@@ -1307,7 +1236,6 @@ int fib6_del(struct rt6_info *rt, struct nl_info *info)
  *	>0  -> walk is incomplete (i.e. suspended)
  *	<0  -> walk is terminated by an error.
  */
-
 static int fib6_walk_continue(struct fib6_walker_t *w)
 {
 	struct fib6_node *fn, *pn;
@@ -1444,7 +1372,6 @@ static int fib6_clean_node(struct fib6_walker_t *w)
  *	prune==1 -> only immediate children of node (certainly,
  *	ignoring pure split nodes) will be scanned.
  */
-
 static void fib6_clean_tree(struct net *net, struct fib6_node *root,
 			    int (*func)(struct rt6_info *, void *arg),
 			    int prune, void *arg)
@@ -1483,6 +1410,7 @@ void fib6_clean_all_ro(struct net *net, int (*func)(struct rt6_info *, void *arg
 	}
 	rcu_read_unlock();
 }
+
 void fib6_clean_all(struct net *net, int (*func)(struct rt6_info *, void *arg),
 		    int prune, void *arg)
 {
@@ -1523,7 +1451,6 @@ static void fib6_prune_clones(struct net *net, struct fib6_node *fn,
 /*
  *	Garbage collection
  */
-
 static struct fib6_gc_args
 {
 	int			timeout;
@@ -1541,7 +1468,6 @@ static int fib6_age(struct rt6_info *rt, void *arg)
 	 *	Also age clones. Note, that clones are aged out
 	 *	only if they are not in use now.
 	 */
-
 	if (rt->rt6i_flags & RTF_EXPIRES && rt->dst.expires) {
 		if (time_after(now, rt->dst.expires)) {
 			RT6_TRACE("expiring %p\n", rt);
-- 
1.7.7.6
