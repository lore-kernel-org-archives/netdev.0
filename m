From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] net/core/: possible cleanups
Date: Thu, 13 Apr 2006 13:58:28 +0200
Message-ID: <20060413115828.GD8171@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:30222 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S964894AbWDML63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 07:58:29 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the following possible cleanups:
- make the following needlessly global functions static:
  - skbuff.c: kfree_skbmem()
  - skbuff.c: skb_prepare_seq_read()
  - skbuff.c: skb_seq_read()
  - skbuff.c: skb_abort_seq_read()
- #if 0 the following unused global functions:
  - skbuff.c: alloc_skb_from_cache()
  - skbuff.c: skb_insert()
- make the following trivial wrapper function a static inline:
  - neighbour.c: neigh_parms_destroy()
- remove the following unused EXPORT_SYMBOL's:
  - dev.c: netdev_features_change
  - dev.c: register_gifconf
  - flow.c: flow_cache_genid
  - flow.c: flow_cache_lookup
  - gen_stats.c: gnet_stats_start_copy
  - iovec.c: csum_partial_copy_fromiovecend
  - neighbour.c: neigh_add
  - neighbour.c: neigh_compat_output
  - neighbour.c: neigh_delete
  - neighbour.c: neigh_dump_info
  - neighbour.c: neigh_event_ns
  - neighbour.c: neigh_update_hhs (static inline function!)
  - neighbour.c: neightbl_dump_info
  - neighbour.c: neightbl_set
  - request_sock.c: reqsk_queue_alloc
  - request_sock.c: reqsk_queue_destroy
  - skbuff.c: skb_clone_fraglist (static function!)
  - skbuff.c: skb_split
  - stream.c: sk_stream_wait_memory
  - stream.c: sk_stream_rfree
  - stream.c: __sk_stream_mem_reclaim
  - stream.c: sk_stream_mem_schedule
  - stream.c: sk_stream_kill_queues
- remove the following unused EXPORT_SYMBOL_GPL:
  - sock.c: sk_clone

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/linux/skbuff.h  |   12 ------------
 include/net/neighbour.h |    6 +++++-
 net/core/dev.c          |    2 --
 net/core/flow.c         |    2 --
 net/core/gen_stats.c    |    1 -
 net/core/iovec.c        |    1 -
 net/core/neighbour.c    |   14 --------------
 net/core/request_sock.c |    3 ---
 net/core/skbuff.c       |   26 ++++++++++++--------------
 net/core/sock.c         |    2 --
 net/core/stream.c       |    9 ---------
 11 files changed, 17 insertions(+), 61 deletions(-)

--- linux-2.6.17-rc1-mm2-full/net/core/dev.c.old	2006-04-13 11:02:21.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/net/core/dev.c	2006-04-13 11:03:13.000000000 +0200
@@ -752,7 +752,6 @@
 {
 	blocking_notifier_call_chain(&netdev_chain, NETDEV_FEAT_CHANGE, dev);
 }
-EXPORT_SYMBOL(netdev_features_change);
 
 /**
  *	netdev_state_change - device changes state
@@ -3398,7 +3397,6 @@
 EXPORT_SYMBOL(netdev_state_change);
 EXPORT_SYMBOL(netif_receive_skb);
 EXPORT_SYMBOL(netif_rx);
-EXPORT_SYMBOL(register_gifconf);
 EXPORT_SYMBOL(register_netdevice);
 EXPORT_SYMBOL(register_netdevice_notifier);
 EXPORT_SYMBOL(skb_checksum_help);
--- linux-2.6.17-rc1-mm2-full/net/core/flow.c.old	2006-04-13 11:04:23.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/net/core/flow.c	2006-04-13 11:04:45.000000000 +0200
@@ -370,5 +370,3 @@
 
 module_init(flow_cache_init);
 
-EXPORT_SYMBOL(flow_cache_genid);
-EXPORT_SYMBOL(flow_cache_lookup);
--- linux-2.6.17-rc1-mm2-full/net/core/gen_stats.c.old	2006-04-13 11:06:35.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/net/core/gen_stats.c	2006-04-13 11:07:05.000000000 +0200
@@ -230,7 +230,6 @@
 }
 
 
-EXPORT_SYMBOL(gnet_stats_start_copy);
 EXPORT_SYMBOL(gnet_stats_start_copy_compat);
 EXPORT_SYMBOL(gnet_stats_copy_basic);
 EXPORT_SYMBOL(gnet_stats_copy_rate_est);
--- linux-2.6.17-rc1-mm2-full/net/core/iovec.c.old	2006-04-13 11:07:56.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/net/core/iovec.c	2006-04-13 11:08:03.000000000 +0200
@@ -233,7 +233,6 @@
 	goto out;
 }
 
-EXPORT_SYMBOL(csum_partial_copy_fromiovecend);
 EXPORT_SYMBOL(memcpy_fromiovec);
 EXPORT_SYMBOL(memcpy_fromiovecend);
 EXPORT_SYMBOL(memcpy_toiovec);
--- linux-2.6.17-rc1-mm2-full/include/net/neighbour.h.old	2006-04-13 11:08:59.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/include/net/neighbour.h	2006-04-13 11:32:05.000000000 +0200
@@ -235,7 +235,6 @@
 
 extern struct neigh_parms	*neigh_parms_alloc(struct net_device *dev, struct neigh_table *tbl);
 extern void			neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms);
-extern void			neigh_parms_destroy(struct neigh_parms *parms);
 extern unsigned long		neigh_rand_reach_time(unsigned long base);
 
 extern void			pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
@@ -279,6 +278,11 @@
 						      ctl_handler *strategy);
 extern void			neigh_sysctl_unregister(struct neigh_parms *p);
 
+static inline void neigh_parms_destroy(struct neigh_parms *parms)
+{
+	kfree(parms);
+}
+
 static inline void __neigh_parms_put(struct neigh_parms *parms)
 {
 	atomic_dec(&parms->refcnt);
--- linux-2.6.17-rc1-mm2-full/net/core/neighbour.c.old	2006-04-13 11:09:19.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/net/core/neighbour.c	2006-04-13 11:14:40.000000000 +0200
@@ -1321,12 +1321,6 @@
 	NEIGH_PRINTK1("neigh_parms_release: not found\n");
 }
 
-void neigh_parms_destroy(struct neigh_parms *parms)
-{
-	kfree(parms);
-}
-
-
 void neigh_table_init(struct neigh_table *tbl)
 {
 	unsigned long now = jiffies;
@@ -2639,15 +2633,10 @@
 #endif	/* CONFIG_SYSCTL */
 
 EXPORT_SYMBOL(__neigh_event_send);
-EXPORT_SYMBOL(neigh_add);
 EXPORT_SYMBOL(neigh_changeaddr);
-EXPORT_SYMBOL(neigh_compat_output);
 EXPORT_SYMBOL(neigh_connected_output);
 EXPORT_SYMBOL(neigh_create);
-EXPORT_SYMBOL(neigh_delete);
 EXPORT_SYMBOL(neigh_destroy);
-EXPORT_SYMBOL(neigh_dump_info);
-EXPORT_SYMBOL(neigh_event_ns);
 EXPORT_SYMBOL(neigh_ifdown);
 EXPORT_SYMBOL(neigh_lookup);
 EXPORT_SYMBOL(neigh_lookup_nodev);
@@ -2658,11 +2647,8 @@
 EXPORT_SYMBOL(neigh_table_clear);
 EXPORT_SYMBOL(neigh_table_init);
 EXPORT_SYMBOL(neigh_update);
-EXPORT_SYMBOL(neigh_update_hhs);
 EXPORT_SYMBOL(pneigh_enqueue);
 EXPORT_SYMBOL(pneigh_lookup);
-EXPORT_SYMBOL(neightbl_dump_info);
-EXPORT_SYMBOL(neightbl_set);
 
 #ifdef CONFIG_ARPD
 EXPORT_SYMBOL(neigh_app_ns);
--- linux-2.6.17-rc1-mm2-full/net/core/request_sock.c.old	2006-04-13 11:16:31.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/net/core/request_sock.c	2006-04-13 11:16:50.000000000 +0200
@@ -59,8 +59,6 @@
 	return 0;
 }
 
-EXPORT_SYMBOL(reqsk_queue_alloc);
-
 void reqsk_queue_destroy(struct request_sock_queue *queue)
 {
 	/* make all the listen_opt local to us */
@@ -84,4 +82,3 @@
 	kfree(lopt);
 }
 
-EXPORT_SYMBOL(reqsk_queue_destroy);
--- linux-2.6.17-rc1-mm2-full/include/linux/skbuff.h.old	2006-04-13 11:17:44.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/include/linux/skbuff.h	2006-04-13 11:59:40.000000000 +0200
@@ -320,10 +320,6 @@
 	return __alloc_skb(size, priority, 1);
 }
 
-extern struct sk_buff *alloc_skb_from_cache(kmem_cache_t *cp,
-					    unsigned int size,
-					    gfp_t priority);
-extern void	       kfree_skbmem(struct sk_buff *skb);
 extern struct sk_buff *skb_clone(struct sk_buff *skb,
 				 gfp_t priority);
 extern struct sk_buff *skb_copy(const struct sk_buff *skb,
@@ -361,13 +357,6 @@
 	__u8		*frag_data;
 };
 
-extern void	      skb_prepare_seq_read(struct sk_buff *skb,
-					   unsigned int from, unsigned int to,
-					   struct skb_seq_state *st);
-extern unsigned int   skb_seq_read(unsigned int consumed, const u8 **data,
-				   struct skb_seq_state *st);
-extern void	      skb_abort_seq_read(struct skb_seq_state *st);
-
 extern unsigned int   skb_find_text(struct sk_buff *skb, unsigned int from,
 				    unsigned int to, struct ts_config *config,
 				    struct ts_state *state);
@@ -685,7 +674,6 @@
 /*
  *	Insert a packet on a list.
  */
-extern void        skb_insert(struct sk_buff *old, struct sk_buff *newsk, struct sk_buff_head *list);
 static inline void __skb_insert(struct sk_buff *newsk,
 				struct sk_buff *prev, struct sk_buff *next,
 				struct sk_buff_head *list)
--- linux-2.6.17-rc1-mm2-full/net/core/skbuff.c.old	2006-04-13 11:17:16.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/net/core/skbuff.c	2006-04-13 11:25:13.000000000 +0200
@@ -187,6 +187,7 @@
 	goto out;
 }
 
+#if 0
 /**
  *	alloc_skb_from_cache	-	allocate a network buffer
  *	@cp: kmem_cache from which to allocate the data area
@@ -240,6 +241,7 @@
 	skb = NULL;
 	goto out;
 }
+#endif  /*  0  */
 
 
 static void skb_drop_fraglist(struct sk_buff *skb)
@@ -284,7 +286,7 @@
 /*
  *	Free an skbuff by memory without cleaning the state.
  */
-void kfree_skbmem(struct sk_buff *skb)
+static void kfree_skbmem(struct sk_buff *skb)
 {
 	struct sk_buff *other;
 	atomic_t *fclone_ref;
@@ -1458,6 +1460,8 @@
 }
 
 
+#if 0
+
 /**
  *	skb_insert	-	insert a buffer
  *	@old: buffer to insert before
@@ -1479,7 +1483,6 @@
 	spin_unlock_irqrestore(&list->lock, flags);
 }
 
-#if 0
 /*
  * 	Tune the memory allocator for a new MTU size.
  */
@@ -1490,7 +1493,8 @@
 
 	kmem_add_cache_size(mtu);
 }
-#endif
+
+#endif  /*  0  */
 
 static inline void skb_split_inside_header(struct sk_buff *skb,
 					   struct sk_buff* skb1,
@@ -1580,8 +1584,8 @@
  * Initializes the specified state variable. Must be called before
  * invoking skb_seq_read() for the first time.
  */
-void skb_prepare_seq_read(struct sk_buff *skb, unsigned int from,
-			  unsigned int to, struct skb_seq_state *st)
+static void skb_prepare_seq_read(struct sk_buff *skb, unsigned int from,
+				 unsigned int to, struct skb_seq_state *st)
 {
 	st->lower_offset = from;
 	st->upper_offset = to;
@@ -1615,8 +1619,8 @@
  *       at the moment, state->root_skb could be replaced with
  *       a stack for this purpose.
  */
-unsigned int skb_seq_read(unsigned int consumed, const u8 **data,
-			  struct skb_seq_state *st)
+static unsigned int skb_seq_read(unsigned int consumed, const u8 **data,
+				 struct skb_seq_state *st)
 {
 	unsigned int block_limit, abs_offset = consumed + st->lower_offset;
 	skb_frag_t *frag;
@@ -1678,7 +1682,7 @@
  * Must be called if skb_seq_read() was not called until it
  * returned 0.
  */
-void skb_abort_seq_read(struct skb_seq_state *st)
+static void skb_abort_seq_read(struct skb_seq_state *st)
 {
 	if (st->frag_data)
 		kunmap_skb_frag(st->frag_data);
@@ -1847,7 +1851,6 @@
 EXPORT_SYMBOL(pskb_expand_head);
 EXPORT_SYMBOL(skb_checksum);
 EXPORT_SYMBOL(skb_clone);
-EXPORT_SYMBOL(skb_clone_fraglist);
 EXPORT_SYMBOL(skb_copy);
 EXPORT_SYMBOL(skb_copy_and_csum_bits);
 EXPORT_SYMBOL(skb_copy_and_csum_dev);
@@ -1859,15 +1862,10 @@
 EXPORT_SYMBOL(skb_under_panic);
 EXPORT_SYMBOL(skb_dequeue);
 EXPORT_SYMBOL(skb_dequeue_tail);
-EXPORT_SYMBOL(skb_insert);
 EXPORT_SYMBOL(skb_queue_purge);
 EXPORT_SYMBOL(skb_queue_head);
 EXPORT_SYMBOL(skb_queue_tail);
 EXPORT_SYMBOL(skb_unlink);
 EXPORT_SYMBOL(skb_append);
-EXPORT_SYMBOL(skb_split);
-EXPORT_SYMBOL(skb_prepare_seq_read);
-EXPORT_SYMBOL(skb_seq_read);
-EXPORT_SYMBOL(skb_abort_seq_read);
 EXPORT_SYMBOL(skb_find_text);
 EXPORT_SYMBOL(skb_append_datato_frags);
--- linux-2.6.17-rc1-mm2-full/net/core/sock.c.old	2006-04-13 11:26:25.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/net/core/sock.c	2006-04-13 11:26:34.000000000 +0200
@@ -885,8 +885,6 @@
 	return newsk;
 }
 
-EXPORT_SYMBOL_GPL(sk_clone);
-
 void __init sk_init(void)
 {
 	if (num_physpages <= 4096) {
--- linux-2.6.17-rc1-mm2-full/net/core/stream.c.old	2006-04-13 11:27:43.000000000 +0200
+++ linux-2.6.17-rc1-mm2-full/net/core/stream.c	2006-04-13 11:30:30.000000000 +0200
@@ -170,8 +170,6 @@
 	goto out;
 }
 
-EXPORT_SYMBOL(sk_stream_wait_memory);
-
 void sk_stream_rfree(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
@@ -180,8 +178,6 @@
 	sk->sk_forward_alloc += skb->truesize;
 }
 
-EXPORT_SYMBOL(sk_stream_rfree);
-
 int sk_stream_error(struct sock *sk, int flags, int err)
 {
 	if (err == -EPIPE)
@@ -206,8 +202,6 @@
 	}
 }
 
-EXPORT_SYMBOL(__sk_stream_mem_reclaim);
-
 int sk_stream_mem_schedule(struct sock *sk, int size, int kind)
 {
 	int amt = sk_stream_pages(size);
@@ -266,8 +260,6 @@
 	return 0;
 }
 
-EXPORT_SYMBOL(sk_stream_mem_schedule);
-
 void sk_stream_kill_queues(struct sock *sk)
 {
 	/* First the read buffer. */
@@ -291,4 +283,3 @@
 	 */
 }
 
-EXPORT_SYMBOL(sk_stream_kill_queues);

