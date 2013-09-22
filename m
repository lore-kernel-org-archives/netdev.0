From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/12] sock.h: Remove extern from function prototypes
Date: Sun, 22 Sep 2013 10:32:26 -0700
Message-ID: <5732b98864cd2671b02d06e98a553114f08b85f4.1379870986.git.joe@perches.com>
References: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0147.hostedemail.com ([216.40.44.147]:41863 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752982Ab3IVRcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 13:32:47 -0400
In-Reply-To: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/sock.h | 223 ++++++++++++++++++++++++-----------------------------
 1 file changed, 99 insertions(+), 124 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 6ba2e7b..4625d2e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -746,7 +746,7 @@ static inline int sk_stream_wspace(const struct sock *sk)
 	return sk->sk_sndbuf - sk->sk_wmem_queued;
 }
 
-extern void sk_stream_write_space(struct sock *sk);
+void sk_stream_write_space(struct sock *sk);
 
 /* OOB backlog add */
 static inline void __sk_add_backlog(struct sock *sk, struct sk_buff *skb)
@@ -788,7 +788,7 @@ static inline __must_check int sk_add_backlog(struct sock *sk, struct sk_buff *s
 	return 0;
 }
 
-extern int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb);
+int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb);
 
 static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 {
@@ -853,15 +853,15 @@ static inline void sock_rps_reset_rxhash(struct sock *sk)
 		__rc;							\
 	})
 
-extern int sk_stream_wait_connect(struct sock *sk, long *timeo_p);
-extern int sk_stream_wait_memory(struct sock *sk, long *timeo_p);
-extern void sk_stream_wait_close(struct sock *sk, long timeo_p);
-extern int sk_stream_error(struct sock *sk, int flags, int err);
-extern void sk_stream_kill_queues(struct sock *sk);
-extern void sk_set_memalloc(struct sock *sk);
-extern void sk_clear_memalloc(struct sock *sk);
+int sk_stream_wait_connect(struct sock *sk, long *timeo_p);
+int sk_stream_wait_memory(struct sock *sk, long *timeo_p);
+void sk_stream_wait_close(struct sock *sk, long timeo_p);
+int sk_stream_error(struct sock *sk, int flags, int err);
+void sk_stream_kill_queues(struct sock *sk);
+void sk_set_memalloc(struct sock *sk);
+void sk_clear_memalloc(struct sock *sk);
 
-extern int sk_wait_data(struct sock *sk, long *timeo);
+int sk_wait_data(struct sock *sk, long *timeo);
 
 struct request_sock_ops;
 struct timewait_sock_ops;
@@ -1031,8 +1031,8 @@ struct cg_proto {
 	struct mem_cgroup	*memcg;
 };
 
-extern int proto_register(struct proto *prot, int alloc_slab);
-extern void proto_unregister(struct proto *prot);
+int proto_register(struct proto *prot, int alloc_slab);
+void proto_unregister(struct proto *prot);
 
 static inline bool memcg_proto_active(struct cg_proto *cg_proto)
 {
@@ -1287,8 +1287,8 @@ proto_memory_pressure(struct proto *prot)
 
 #ifdef CONFIG_PROC_FS
 /* Called with local bh disabled */
-extern void sock_prot_inuse_add(struct net *net, struct proto *prot, int inc);
-extern int sock_prot_inuse_get(struct net *net, struct proto *proto);
+void sock_prot_inuse_add(struct net *net, struct proto *prot, int inc);
+int sock_prot_inuse_get(struct net *net, struct proto *proto);
 #else
 static inline void sock_prot_inuse_add(struct net *net, struct proto *prot,
 		int inc)
@@ -1364,8 +1364,8 @@ static inline struct inode *SOCK_INODE(struct socket *socket)
 /*
  * Functions for memory accounting
  */
-extern int __sk_mem_schedule(struct sock *sk, int size, int kind);
-extern void __sk_mem_reclaim(struct sock *sk);
+int __sk_mem_schedule(struct sock *sk, int size, int kind);
+void __sk_mem_reclaim(struct sock *sk);
 
 #define SK_MEM_QUANTUM ((int)PAGE_SIZE)
 #define SK_MEM_QUANTUM_SHIFT ilog2(SK_MEM_QUANTUM)
@@ -1473,14 +1473,14 @@ do {									\
 	lockdep_init_map(&(sk)->sk_lock.dep_map, (name), (key), 0);	\
 } while (0)
 
-extern void lock_sock_nested(struct sock *sk, int subclass);
+void lock_sock_nested(struct sock *sk, int subclass);
 
 static inline void lock_sock(struct sock *sk)
 {
 	lock_sock_nested(sk, 0);
 }
 
-extern void release_sock(struct sock *sk);
+void release_sock(struct sock *sk);
 
 /* BH context may only use the following locking interface. */
 #define bh_lock_sock(__sk)	spin_lock(&((__sk)->sk_lock.slock))
@@ -1489,7 +1489,7 @@ extern void release_sock(struct sock *sk);
 				SINGLE_DEPTH_NESTING)
 #define bh_unlock_sock(__sk)	spin_unlock(&((__sk)->sk_lock.slock))
 
-extern bool lock_sock_fast(struct sock *sk);
+bool lock_sock_fast(struct sock *sk);
 /**
  * unlock_sock_fast - complement of lock_sock_fast
  * @sk: socket
@@ -1507,108 +1507,84 @@ static inline void unlock_sock_fast(struct sock *sk, bool slow)
 }
 
 
-extern struct sock		*sk_alloc(struct net *net, int family,
-					  gfp_t priority,
-					  struct proto *prot);
-extern void			sk_free(struct sock *sk);
-extern void			sk_release_kernel(struct sock *sk);
-extern struct sock		*sk_clone_lock(const struct sock *sk,
-					       const gfp_t priority);
-
-extern struct sk_buff		*sock_wmalloc(struct sock *sk,
-					      unsigned long size, int force,
-					      gfp_t priority);
-extern struct sk_buff		*sock_rmalloc(struct sock *sk,
-					      unsigned long size, int force,
-					      gfp_t priority);
-extern void			sock_wfree(struct sk_buff *skb);
-extern void			skb_orphan_partial(struct sk_buff *skb);
-extern void			sock_rfree(struct sk_buff *skb);
-extern void			sock_edemux(struct sk_buff *skb);
-
-extern int			sock_setsockopt(struct socket *sock, int level,
-						int op, char __user *optval,
-						unsigned int optlen);
-
-extern int			sock_getsockopt(struct socket *sock, int level,
-						int op, char __user *optval,
-						int __user *optlen);
-extern struct sk_buff		*sock_alloc_send_skb(struct sock *sk,
-						     unsigned long size,
-						     int noblock,
-						     int *errcode);
-extern struct sk_buff		*sock_alloc_send_pskb(struct sock *sk,
-						      unsigned long header_len,
-						      unsigned long data_len,
-						      int noblock,
-						      int *errcode,
-						      int max_page_order);
-extern void *sock_kmalloc(struct sock *sk, int size,
-			  gfp_t priority);
-extern void sock_kfree_s(struct sock *sk, void *mem, int size);
-extern void sk_send_sigurg(struct sock *sk);
+struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
+		      struct proto *prot);
+void sk_free(struct sock *sk);
+void sk_release_kernel(struct sock *sk);
+struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority);
+
+struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
+			     gfp_t priority);
+struct sk_buff *sock_rmalloc(struct sock *sk, unsigned long size, int force,
+			     gfp_t priority);
+void sock_wfree(struct sk_buff *skb);
+void skb_orphan_partial(struct sk_buff *skb);
+void sock_rfree(struct sk_buff *skb);
+void sock_edemux(struct sk_buff *skb);
+
+int sock_setsockopt(struct socket *sock, int level, int op,
+		    char __user *optval, unsigned int optlen);
+
+int sock_getsockopt(struct socket *sock, int level, int op,
+		    char __user *optval, int __user *optlen);
+struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
+				    int noblock, int *errcode);
+struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
+				     unsigned long data_len, int noblock,
+				     int *errcode, int max_page_order);
+void *sock_kmalloc(struct sock *sk, int size, gfp_t priority);
+void sock_kfree_s(struct sock *sk, void *mem, int size);
+void sk_send_sigurg(struct sock *sk);
 
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
  * does not implement a particular function.
  */
-extern int                      sock_no_bind(struct socket *,
-					     struct sockaddr *, int);
-extern int                      sock_no_connect(struct socket *,
-						struct sockaddr *, int, int);
-extern int                      sock_no_socketpair(struct socket *,
-						   struct socket *);
-extern int                      sock_no_accept(struct socket *,
-					       struct socket *, int);
-extern int                      sock_no_getname(struct socket *,
-						struct sockaddr *, int *, int);
-extern unsigned int             sock_no_poll(struct file *, struct socket *,
-					     struct poll_table_struct *);
-extern int                      sock_no_ioctl(struct socket *, unsigned int,
-					      unsigned long);
-extern int			sock_no_listen(struct socket *, int);
-extern int                      sock_no_shutdown(struct socket *, int);
-extern int			sock_no_getsockopt(struct socket *, int , int,
-						   char __user *, int __user *);
-extern int			sock_no_setsockopt(struct socket *, int, int,
-						   char __user *, unsigned int);
-extern int                      sock_no_sendmsg(struct kiocb *, struct socket *,
-						struct msghdr *, size_t);
-extern int                      sock_no_recvmsg(struct kiocb *, struct socket *,
-						struct msghdr *, size_t, int);
-extern int			sock_no_mmap(struct file *file,
-					     struct socket *sock,
-					     struct vm_area_struct *vma);
-extern ssize_t			sock_no_sendpage(struct socket *sock,
-						struct page *page,
-						int offset, size_t size,
-						int flags);
+int sock_no_bind(struct socket *, struct sockaddr *, int);
+int sock_no_connect(struct socket *, struct sockaddr *, int, int);
+int sock_no_socketpair(struct socket *, struct socket *);
+int sock_no_accept(struct socket *, struct socket *, int);
+int sock_no_getname(struct socket *, struct sockaddr *, int *, int);
+unsigned int sock_no_poll(struct file *, struct socket *,
+			  struct poll_table_struct *);
+int sock_no_ioctl(struct socket *, unsigned int, unsigned long);
+int sock_no_listen(struct socket *, int);
+int sock_no_shutdown(struct socket *, int);
+int sock_no_getsockopt(struct socket *, int , int, char __user *, int __user *);
+int sock_no_setsockopt(struct socket *, int, int, char __user *, unsigned int);
+int sock_no_sendmsg(struct kiocb *, struct socket *, struct msghdr *, size_t);
+int sock_no_recvmsg(struct kiocb *, struct socket *, struct msghdr *, size_t,
+		    int);
+int sock_no_mmap(struct file *file, struct socket *sock,
+		 struct vm_area_struct *vma);
+ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset,
+			 size_t size, int flags);
 
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
  * uses the inet style.
  */
-extern int sock_common_getsockopt(struct socket *sock, int level, int optname,
+int sock_common_getsockopt(struct socket *sock, int level, int optname,
 				  char __user *optval, int __user *optlen);
-extern int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
+int sock_common_recvmsg(struct kiocb *iocb, struct socket *sock,
 			       struct msghdr *msg, size_t size, int flags);
-extern int sock_common_setsockopt(struct socket *sock, int level, int optname,
+int sock_common_setsockopt(struct socket *sock, int level, int optname,
 				  char __user *optval, unsigned int optlen);
-extern int compat_sock_common_getsockopt(struct socket *sock, int level,
+int compat_sock_common_getsockopt(struct socket *sock, int level,
 		int optname, char __user *optval, int __user *optlen);
-extern int compat_sock_common_setsockopt(struct socket *sock, int level,
+int compat_sock_common_setsockopt(struct socket *sock, int level,
 		int optname, char __user *optval, unsigned int optlen);
 
-extern void sk_common_release(struct sock *sk);
+void sk_common_release(struct sock *sk);
 
 /*
  *	Default socket callbacks and setup code
  */
 
 /* Initialise core socket variables */
-extern void sock_init_data(struct socket *sock, struct sock *sk);
+void sock_init_data(struct socket *sock, struct sock *sk);
 
-extern void sk_filter_release_rcu(struct rcu_head *rcu);
+void sk_filter_release_rcu(struct rcu_head *rcu);
 
 /**
  *	sk_filter_release - release a socket filter
@@ -1669,8 +1645,7 @@ static inline void sock_put(struct sock *sk)
 		sk_free(sk);
 }
 
-extern int sk_receive_skb(struct sock *sk, struct sk_buff *skb,
-			  const int nested);
+int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested);
 
 static inline void sk_tx_queue_set(struct sock *sk, int tx_queue)
 {
@@ -1724,8 +1699,8 @@ static inline void sock_graft(struct sock *sk, struct socket *parent)
 	write_unlock_bh(&sk->sk_callback_lock);
 }
 
-extern kuid_t sock_i_uid(struct sock *sk);
-extern unsigned long sock_i_ino(struct sock *sk);
+kuid_t sock_i_uid(struct sock *sk);
+unsigned long sock_i_ino(struct sock *sk);
 
 static inline struct dst_entry *
 __sk_dst_get(struct sock *sk)
@@ -1747,7 +1722,7 @@ sk_dst_get(struct sock *sk)
 	return dst;
 }
 
-extern void sk_reset_txq(struct sock *sk);
+void sk_reset_txq(struct sock *sk);
 
 static inline void dst_negative_advice(struct sock *sk)
 {
@@ -1800,16 +1775,16 @@ sk_dst_reset(struct sock *sk)
 	spin_unlock(&sk->sk_dst_lock);
 }
 
-extern struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie);
+struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie);
 
-extern struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie);
+struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie);
 
 static inline bool sk_can_gso(const struct sock *sk)
 {
 	return net_gso_ok(sk->sk_route_caps, sk->sk_gso_type);
 }
 
-extern void sk_setup_caps(struct sock *sk, struct dst_entry *dst);
+void sk_setup_caps(struct sock *sk, struct dst_entry *dst);
 
 static inline void sk_nocaps_add(struct sock *sk, netdev_features_t flags)
 {
@@ -2022,14 +1997,14 @@ static inline void skb_set_owner_r(struct sk_buff *skb, struct sock *sk)
 	sk_mem_charge(sk, skb->truesize);
 }
 
-extern void sk_reset_timer(struct sock *sk, struct timer_list *timer,
-			   unsigned long expires);
+void sk_reset_timer(struct sock *sk, struct timer_list *timer,
+		    unsigned long expires);
 
-extern void sk_stop_timer(struct sock *sk, struct timer_list *timer);
+void sk_stop_timer(struct sock *sk, struct timer_list *timer);
 
-extern int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
+int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
 
-extern int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb);
+int sock_queue_err_skb(struct sock *sk, struct sk_buff *skb);
 
 /*
  *	Recover an error report and clear atomically
@@ -2097,7 +2072,7 @@ static inline struct page_frag *sk_page_frag(struct sock *sk)
 	return &sk->sk_frag;
 }
 
-extern bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag);
+bool sk_page_frag_refill(struct sock *sk, struct page_frag *pfrag);
 
 /*
  *	Default write policy as shown to user space via poll/select/SIGIO
@@ -2135,10 +2110,10 @@ static inline int sock_intr_errno(long timeo)
 	return timeo == MAX_SCHEDULE_TIMEOUT ? -ERESTARTSYS : -EINTR;
 }
 
-extern void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
-	struct sk_buff *skb);
-extern void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
-	struct sk_buff *skb);
+void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
+			   struct sk_buff *skb);
+void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
+			     struct sk_buff *skb);
 
 static inline void
 sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
@@ -2171,8 +2146,8 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 		__sock_recv_wifi_status(msg, sk, skb);
 }
 
-extern void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
-				     struct sk_buff *skb);
+void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
+			      struct sk_buff *skb);
 
 static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
 					  struct sk_buff *skb)
@@ -2197,7 +2172,7 @@ static inline void sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
  *
  * Currently only depends on SOCK_TIMESTAMPING* flags.
  */
-extern void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags);
+void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags);
 
 /**
  * sk_eat_skb - Release a skb if it is no longer needed
@@ -2261,11 +2236,11 @@ static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 	return NULL;
 }
 
-extern void sock_enable_timestamp(struct sock *sk, int flag);
-extern int sock_get_timestamp(struct sock *, struct timeval __user *);
-extern int sock_get_timestampns(struct sock *, struct timespec __user *);
-extern int sock_recv_errqueue(struct sock *sk, struct msghdr *msg, int len,
-			      int level, int type);
+void sock_enable_timestamp(struct sock *sk, int flag);
+int sock_get_timestamp(struct sock *, struct timeval __user *);
+int sock_get_timestampns(struct sock *, struct timespec __user *);
+int sock_recv_errqueue(struct sock *sk, struct msghdr *msg, int len, int level,
+		       int type);
 
 /*
  *	Enable debug/info messages
-- 
1.8.1.2.459.gbcd45b4.dirty
