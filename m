From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: include/net/sock.h cleanup
Date: Thu, 17 May 2012 10:48:15 +0200
Message-ID: <1337244495.29313.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38969 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756049Ab2EQIsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 04:48:20 -0400
Received: by eaak11 with SMTP id k11so435109eaa.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 01:48:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

bool/const conversions where possible

__inline__ -> inline

space cleanups

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h |  151 +++++++++++++++++++++----------------------
 net/dccp/proto.c   |    4 -
 net/ipv4/tcp.c     |   12 +--
 net/llc/af_llc.c   |    4 -
 4 files changed, 84 insertions(+), 87 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 0e7c4f4..e993c81 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -97,7 +97,7 @@ void mem_cgroup_sockets_destroy(struct cgroup *cgrp)
 #else
 /* Validate arguments and do nothing */
 static inline __printf(2, 3)
-void SOCK_DEBUG(struct sock *sk, const char *msg, ...)
+void SOCK_DEBUG(const struct sock *sk, const char *msg, ...)
 {
 }
 #endif
@@ -372,8 +372,8 @@ struct sock {
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
 	void			(*sk_error_report)(struct sock *sk);
-  	int			(*sk_backlog_rcv)(struct sock *sk,
-						  struct sk_buff *skb);  
+	int			(*sk_backlog_rcv)(struct sock *sk,
+						  struct sk_buff *skb);
 	void                    (*sk_destruct)(struct sock *sk);
 };
 
@@ -454,40 +454,40 @@ static inline struct sock *sk_nulls_next(const struct sock *sk)
 		NULL;
 }
 
-static inline int sk_unhashed(const struct sock *sk)
+static inline bool sk_unhashed(const struct sock *sk)
 {
 	return hlist_unhashed(&sk->sk_node);
 }
 
-static inline int sk_hashed(const struct sock *sk)
+static inline bool sk_hashed(const struct sock *sk)
 {
 	return !sk_unhashed(sk);
 }
 
-static __inline__ void sk_node_init(struct hlist_node *node)
+static inline void sk_node_init(struct hlist_node *node)
 {
 	node->pprev = NULL;
 }
 
-static __inline__ void sk_nulls_node_init(struct hlist_nulls_node *node)
+static inline void sk_nulls_node_init(struct hlist_nulls_node *node)
 {
 	node->pprev = NULL;
 }
 
-static __inline__ void __sk_del_node(struct sock *sk)
+static inline void __sk_del_node(struct sock *sk)
 {
 	__hlist_del(&sk->sk_node);
 }
 
 /* NB: equivalent to hlist_del_init_rcu */
-static __inline__ int __sk_del_node_init(struct sock *sk)
+static inline bool __sk_del_node_init(struct sock *sk)
 {
 	if (sk_hashed(sk)) {
 		__sk_del_node(sk);
 		sk_node_init(&sk->sk_node);
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 /* Grab socket reference count. This operation is valid only
@@ -509,9 +509,9 @@ static inline void __sock_put(struct sock *sk)
 	atomic_dec(&sk->sk_refcnt);
 }
 
-static __inline__ int sk_del_node_init(struct sock *sk)
+static inline bool sk_del_node_init(struct sock *sk)
 {
-	int rc = __sk_del_node_init(sk);
+	bool rc = __sk_del_node_init(sk);
 
 	if (rc) {
 		/* paranoid for a while -acme */
@@ -522,18 +522,18 @@ static __inline__ int sk_del_node_init(struct sock *sk)
 }
 #define sk_del_node_init_rcu(sk)	sk_del_node_init(sk)
 
-static __inline__ int __sk_nulls_del_node_init_rcu(struct sock *sk)
+static inline bool __sk_nulls_del_node_init_rcu(struct sock *sk)
 {
 	if (sk_hashed(sk)) {
 		hlist_nulls_del_init_rcu(&sk->sk_nulls_node);
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
-static __inline__ int sk_nulls_del_node_init_rcu(struct sock *sk)
+static inline bool sk_nulls_del_node_init_rcu(struct sock *sk)
 {
-	int rc = __sk_nulls_del_node_init_rcu(sk);
+	bool rc = __sk_nulls_del_node_init_rcu(sk);
 
 	if (rc) {
 		/* paranoid for a while -acme */
@@ -543,40 +543,40 @@ static __inline__ int sk_nulls_del_node_init_rcu(struct sock *sk)
 	return rc;
 }
 
-static __inline__ void __sk_add_node(struct sock *sk, struct hlist_head *list)
+static inline void __sk_add_node(struct sock *sk, struct hlist_head *list)
 {
 	hlist_add_head(&sk->sk_node, list);
 }
 
-static __inline__ void sk_add_node(struct sock *sk, struct hlist_head *list)
+static inline void sk_add_node(struct sock *sk, struct hlist_head *list)
 {
 	sock_hold(sk);
 	__sk_add_node(sk, list);
 }
 
-static __inline__ void sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
+static inline void sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
 {
 	sock_hold(sk);
 	hlist_add_head_rcu(&sk->sk_node, list);
 }
 
-static __inline__ void __sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
+static inline void __sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
 {
 	hlist_nulls_add_head_rcu(&sk->sk_nulls_node, list);
 }
 
-static __inline__ void sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
+static inline void sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
 {
 	sock_hold(sk);
 	__sk_nulls_add_node_rcu(sk, list);
 }
 
-static __inline__ void __sk_del_bind_node(struct sock *sk)
+static inline void __sk_del_bind_node(struct sock *sk)
 {
 	__hlist_del(&sk->sk_bind_node);
 }
 
-static __inline__ void sk_add_bind_node(struct sock *sk,
+static inline void sk_add_bind_node(struct sock *sk,
 					struct hlist_head *list)
 {
 	hlist_add_head(&sk->sk_bind_node, list);
@@ -665,7 +665,7 @@ static inline void sk_acceptq_added(struct sock *sk)
 	sk->sk_ack_backlog++;
 }
 
-static inline int sk_acceptq_is_full(struct sock *sk)
+static inline bool sk_acceptq_is_full(const struct sock *sk)
 {
 	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
 }
@@ -673,19 +673,19 @@ static inline int sk_acceptq_is_full(struct sock *sk)
 /*
  * Compute minimal free write space needed to queue new packets.
  */
-static inline int sk_stream_min_wspace(struct sock *sk)
+static inline int sk_stream_min_wspace(const struct sock *sk)
 {
 	return sk->sk_wmem_queued >> 1;
 }
 
-static inline int sk_stream_wspace(struct sock *sk)
+static inline int sk_stream_wspace(const struct sock *sk)
 {
 	return sk->sk_sndbuf - sk->sk_wmem_queued;
 }
 
 extern void sk_stream_write_space(struct sock *sk);
 
-static inline int sk_stream_memory_free(struct sock *sk)
+static inline bool sk_stream_memory_free(const struct sock *sk)
 {
 	return sk->sk_wmem_queued < sk->sk_sndbuf;
 }
@@ -809,26 +809,26 @@ struct module;
  * transport -> network interface is defined by struct inet_proto
  */
 struct proto {
-	void			(*close)(struct sock *sk, 
+	void			(*close)(struct sock *sk,
 					long timeout);
 	int			(*connect)(struct sock *sk,
-				        struct sockaddr *uaddr, 
+					struct sockaddr *uaddr,
 					int addr_len);
 	int			(*disconnect)(struct sock *sk, int flags);
 
-	struct sock *		(*accept) (struct sock *sk, int flags, int *err);
+	struct sock *		(*accept)(struct sock *sk, int flags, int *err);
 
 	int			(*ioctl)(struct sock *sk, int cmd,
 					 unsigned long arg);
 	int			(*init)(struct sock *sk);
 	void			(*destroy)(struct sock *sk);
 	void			(*shutdown)(struct sock *sk, int how);
-	int			(*setsockopt)(struct sock *sk, int level, 
+	int			(*setsockopt)(struct sock *sk, int level,
 					int optname, char __user *optval,
 					unsigned int optlen);
-	int			(*getsockopt)(struct sock *sk, int level, 
-					int optname, char __user *optval, 
-					int __user *option);  	 
+	int			(*getsockopt)(struct sock *sk, int level,
+					int optname, char __user *optval,
+					int __user *option);
 #ifdef CONFIG_COMPAT
 	int			(*compat_setsockopt)(struct sock *sk,
 					int level,
@@ -845,14 +845,14 @@ struct proto {
 					   struct msghdr *msg, size_t len);
 	int			(*recvmsg)(struct kiocb *iocb, struct sock *sk,
 					   struct msghdr *msg,
-					size_t len, int noblock, int flags, 
-					int *addr_len);
+					   size_t len, int noblock, int flags,
+					   int *addr_len);
 	int			(*sendpage)(struct sock *sk, struct page *page,
 					int offset, size_t size, int flags);
-	int			(*bind)(struct sock *sk, 
+	int			(*bind)(struct sock *sk,
 					struct sockaddr *uaddr, int addr_len);
 
-	int			(*backlog_rcv) (struct sock *sk, 
+	int			(*backlog_rcv) (struct sock *sk,
 						struct sk_buff *skb);
 
 	/* Keeping track of sk's, looking them up, and port selection methods. */
@@ -1173,7 +1173,7 @@ proto_memory_pressure(struct proto *prot)
 extern void sock_prot_inuse_add(struct net *net, struct proto *prot, int inc);
 extern int sock_prot_inuse_get(struct net *net, struct proto *proto);
 #else
-static void inline sock_prot_inuse_add(struct net *net, struct proto *prot,
+static inline void sock_prot_inuse_add(struct net *net, struct proto *prot,
 		int inc)
 {
 }
@@ -1260,24 +1260,24 @@ static inline int sk_mem_pages(int amt)
 	return (amt + SK_MEM_QUANTUM - 1) >> SK_MEM_QUANTUM_SHIFT;
 }
 
-static inline int sk_has_account(struct sock *sk)
+static inline bool sk_has_account(struct sock *sk)
 {
 	/* return true if protocol supports memory accounting */
 	return !!sk->sk_prot->memory_allocated;
 }
 
-static inline int sk_wmem_schedule(struct sock *sk, int size)
+static inline bool sk_wmem_schedule(struct sock *sk, int size)
 {
 	if (!sk_has_account(sk))
-		return 1;
+		return true;
 	return size <= sk->sk_forward_alloc ||
 		__sk_mem_schedule(sk, size, SK_MEM_SEND);
 }
 
-static inline int sk_rmem_schedule(struct sock *sk, int size)
+static inline bool sk_rmem_schedule(struct sock *sk, int size)
 {
 	if (!sk_has_account(sk))
-		return 1;
+		return true;
 	return size <= sk->sk_forward_alloc ||
 		__sk_mem_schedule(sk, size, SK_MEM_RECV);
 }
@@ -1342,7 +1342,7 @@ static inline void sk_wmem_free_skb(struct sock *sk, struct sk_buff *skb)
  * Mark both the sk_lock and the sk_lock.slock as a
  * per-address-family lock class.
  */
-#define sock_lock_init_class_and_name(sk, sname, skey, name, key) 	\
+#define sock_lock_init_class_and_name(sk, sname, skey, name, key)	\
 do {									\
 	sk->sk_lock.owned = 0;						\
 	init_waitqueue_head(&sk->sk_lock.wq);				\
@@ -1350,7 +1350,7 @@ do {									\
 	debug_check_no_locks_freed((void *)&(sk)->sk_lock,		\
 			sizeof((sk)->sk_lock));				\
 	lockdep_set_class_and_name(&(sk)->sk_lock.slock,		\
-		       	(skey), (sname));				\
+				(skey), (sname));				\
 	lockdep_init_map(&(sk)->sk_lock.dep_map, (name), (key), 0);	\
 } while (0)
 
@@ -1410,13 +1410,13 @@ extern int			sock_setsockopt(struct socket *sock, int level,
 						unsigned int optlen);
 
 extern int			sock_getsockopt(struct socket *sock, int level,
-						int op, char __user *optval, 
+						int op, char __user *optval,
 						int __user *optlen);
-extern struct sk_buff 		*sock_alloc_send_skb(struct sock *sk,
+extern struct sk_buff		*sock_alloc_send_skb(struct sock *sk,
 						     unsigned long size,
 						     int noblock,
 						     int *errcode);
-extern struct sk_buff 		*sock_alloc_send_pskb(struct sock *sk,
+extern struct sk_buff		*sock_alloc_send_pskb(struct sock *sk,
 						      unsigned long header_len,
 						      unsigned long data_len,
 						      int noblock,
@@ -1438,7 +1438,7 @@ static inline void sock_update_classid(struct sock *sk)
  * Functions to fill in entries in struct proto_ops when a protocol
  * does not implement a particular function.
  */
-extern int                      sock_no_bind(struct socket *, 
+extern int                      sock_no_bind(struct socket *,
 					     struct sockaddr *, int);
 extern int                      sock_no_connect(struct socket *,
 						struct sockaddr *, int, int);
@@ -1467,7 +1467,7 @@ extern int			sock_no_mmap(struct file *file,
 					     struct vm_area_struct *vma);
 extern ssize_t			sock_no_sendpage(struct socket *sock,
 						struct page *page,
-						int offset, size_t size, 
+						int offset, size_t size,
 						int flags);
 
 /*
@@ -1490,7 +1490,7 @@ extern void sk_common_release(struct sock *sk);
 /*
  *	Default socket callbacks and setup code
  */
- 
+
 /* Initialise core socket variables */
 extern void sock_init_data(struct socket *sock, struct sock *sk);
 
@@ -1690,7 +1690,7 @@ extern struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie);
 
 extern struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie);
 
-static inline int sk_can_gso(const struct sock *sk)
+static inline bool sk_can_gso(const struct sock *sk)
 {
 	return net_gso_ok(sk->sk_route_caps, sk->sk_gso_type);
 }
@@ -1807,7 +1807,7 @@ static inline int sk_rmem_alloc_get(const struct sock *sk)
  *
  * Returns true if socket has write or read allocations
  */
-static inline int sk_has_allocations(const struct sock *sk)
+static inline bool sk_has_allocations(const struct sock *sk)
 {
 	return sk_wmem_alloc_get(sk) || sk_rmem_alloc_get(sk);
 }
@@ -1846,9 +1846,7 @@ static inline int sk_has_allocations(const struct sock *sk)
  */
 static inline bool wq_has_sleeper(struct socket_wq *wq)
 {
-
-	/*
-	 * We need to be sure we are in sync with the
+	/* We need to be sure we are in sync with the
 	 * add_wait_queue modifications to the wait queue.
 	 *
 	 * This memory barrier is paired in the sock_poll_wait.
@@ -1870,22 +1868,21 @@ static inline void sock_poll_wait(struct file *filp,
 {
 	if (!poll_does_not_wait(p) && wait_address) {
 		poll_wait(filp, wait_address, p);
-		/*
-		 * We need to be sure we are in sync with the
+		/* We need to be sure we are in sync with the
 		 * socket flags modification.
 		 *
 		 * This memory barrier is paired in the wq_has_sleeper.
-		*/
+		 */
 		smp_mb();
 	}
 }
 
 /*
- * 	Queue a received datagram if it will fit. Stream and sequenced
+ *	Queue a received datagram if it will fit. Stream and sequenced
  *	protocols can't normally use this as they need to fit buffers in
  *	and play with them.
  *
- * 	Inlined as it's very short and called for pretty much every
+ *	Inlined as it's very short and called for pretty much every
  *	packet ever received.
  */
 
@@ -1911,10 +1908,10 @@ static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 	sk_mem_charge(sk, skb->truesize);
 }
 
-extern void sk_reset_timer(struct sock *sk, struct timer_list* timer,
+extern void sk_reset_timer(struct sock *sk, struct timer_list *timer,
 			   unsigned long expires);
 
-extern void sk_stop_timer(struct sock *sk, struct timer_list* timer);
+extern void sk_stop_timer(struct sock *sk, struct timer_list *timer);
 
 extern int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 
@@ -1923,7 +1920,7 @@ extern int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb);
 /*
  *	Recover an error report and clear atomically
  */
- 
+
 static inline int sock_error(struct sock *sk)
 {
 	int err;
@@ -1939,7 +1936,7 @@ static inline unsigned long sock_wspace(struct sock *sk)
 
 	if (!(sk->sk_shutdown & SEND_SHUTDOWN)) {
 		amt = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
-		if (amt < 0) 
+		if (amt < 0)
 			amt = 0;
 	}
 	return amt;
@@ -1983,7 +1980,7 @@ static inline struct page *sk_stream_alloc_page(struct sock *sk)
 /*
  *	Default write policy as shown to user space via poll/select/SIGIO
  */
-static inline int sock_writeable(const struct sock *sk) 
+static inline bool sock_writeable(const struct sock *sk)
 {
 	return atomic_read(&sk->sk_wmem_alloc) < (sk->sk_sndbuf >> 1);
 }
@@ -1993,12 +1990,12 @@ static inline gfp_t gfp_any(void)
 	return in_softirq() ? GFP_ATOMIC : GFP_KERNEL;
 }
 
-static inline long sock_rcvtimeo(const struct sock *sk, int noblock)
+static inline long sock_rcvtimeo(const struct sock *sk, bool noblock)
 {
 	return noblock ? 0 : sk->sk_rcvtimeo;
 }
 
-static inline long sock_sndtimeo(const struct sock *sk, int noblock)
+static inline long sock_sndtimeo(const struct sock *sk, bool noblock)
 {
 	return noblock ? 0 : sk->sk_sndtimeo;
 }
@@ -2021,7 +2018,7 @@ extern void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 extern void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb);
 
-static __inline__ void
+static inline void
 sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 {
 	ktime_t kt = skb->tstamp;
@@ -2062,7 +2059,7 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 			   (1UL << SOCK_RCVTSTAMP)			| \
 			   (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE)	| \
 			   (1UL << SOCK_TIMESTAMPING_SOFTWARE)		| \
-			   (1UL << SOCK_TIMESTAMPING_RAW_HARDWARE) 	| \
+			   (1UL << SOCK_TIMESTAMPING_RAW_HARDWARE)	| \
 			   (1UL << SOCK_TIMESTAMPING_SYS_HARDWARE))
 
 	if (sk->sk_flags & FLAGS_TS_OR_DROPS)
@@ -2091,7 +2088,7 @@ extern int sock_tx_timestamp(struct sock *sk, __u8 *tx_flags);
  * locked so that the sk_buff queue operation is ok.
 */
 #ifdef CONFIG_NET_DMA
-static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_early)
+static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, bool copied_early)
 {
 	__skb_unlink(skb, &sk->sk_receive_queue);
 	if (!copied_early)
@@ -2100,7 +2097,7 @@ static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_e
 		__skb_queue_tail(&sk->sk_async_wait_queue, skb);
 }
 #else
-static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_early)
+static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, bool copied_early)
 {
 	__skb_unlink(skb, &sk->sk_receive_queue);
 	__kfree_skb(skb);
@@ -2147,8 +2144,8 @@ extern void sock_enable_timestamp(struct sock *sk, int flag);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
 extern int sock_get_timestampns(struct sock *, struct timespec __user *);
 
-/* 
- *	Enable debug/info messages 
+/*
+ *	Enable debug/info messages
  */
 extern int net_msg_warn;
 #define NETDEBUG(fmt, args...) \
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 7065c0a..6c7c78b 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -848,7 +848,7 @@ int dccp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		default:
 			dccp_pr_debug("packet_type=%s\n",
 				      dccp_packet_name(dh->dccph_type));
-			sk_eat_skb(sk, skb, 0);
+			sk_eat_skb(sk, skb, false);
 		}
 verify_sock_status:
 		if (sock_flag(sk, SOCK_DONE)) {
@@ -905,7 +905,7 @@ verify_sock_status:
 			len = skb->len;
 	found_fin_ok:
 		if (!(flags & MSG_PEEK))
-			sk_eat_skb(sk, skb, 0);
+			sk_eat_skb(sk, skb, false);
 		break;
 	} while (1);
 out:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index feb2e25..e8a80d0 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1473,11 +1473,11 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				break;
 		}
 		if (tcp_hdr(skb)->fin) {
-			sk_eat_skb(sk, skb, 0);
+			sk_eat_skb(sk, skb, false);
 			++seq;
 			break;
 		}
-		sk_eat_skb(sk, skb, 0);
+		sk_eat_skb(sk, skb, false);
 		if (!desc->count)
 			break;
 		tp->copied_seq = seq;
@@ -1513,7 +1513,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	int target;		/* Read at least this many bytes */
 	long timeo;
 	struct task_struct *user_recv = NULL;
-	int copied_early = 0;
+	bool copied_early = false;
 	struct sk_buff *skb;
 	u32 urg_hole = 0;
 
@@ -1801,7 +1801,7 @@ do_prequeue:
 				dma_async_memcpy_issue_pending(tp->ucopy.dma_chan);
 
 				if ((offset + used) == skb->len)
-					copied_early = 1;
+					copied_early = true;
 
 			} else
 #endif
@@ -1835,7 +1835,7 @@ skip_copy:
 			goto found_fin_ok;
 		if (!(flags & MSG_PEEK)) {
 			sk_eat_skb(sk, skb, copied_early);
-			copied_early = 0;
+			copied_early = false;
 		}
 		continue;
 
@@ -1844,7 +1844,7 @@ skip_copy:
 		++*seq;
 		if (!(flags & MSG_PEEK)) {
 			sk_eat_skb(sk, skb, copied_early);
-			copied_early = 0;
+			copied_early = false;
 		}
 		break;
 	} while (len > 0);
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index e944075..fe5453c 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -838,7 +838,7 @@ static int llc_ui_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 		if (!(flags & MSG_PEEK)) {
 			spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
-			sk_eat_skb(sk, skb, 0);
+			sk_eat_skb(sk, skb, false);
 			spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
 			*seq = 0;
 		}
@@ -861,7 +861,7 @@ copy_uaddr:
 
 	if (!(flags & MSG_PEEK)) {
 			spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
-			sk_eat_skb(sk, skb, 0);
+			sk_eat_skb(sk, skb, false);
 			spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
 			*seq = 0;
 	}
