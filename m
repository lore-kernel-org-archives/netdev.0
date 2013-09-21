From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/12] inet*.h: Remove extern from function prototypes
Date: Sat, 21 Sep 2013 10:22:41 -0700
Message-ID: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0152.hostedemail.com ([216.40.44.152]:47851 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751923Ab3IURW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 13:22:57 -0400
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
 include/net/inet6_connection_sock.h | 32 +++++++--------
 include/net/inet6_hashtables.h      | 38 +++++++++---------
 include/net/inet_common.h           | 48 +++++++++++-----------
 include/net/inet_connection_sock.h  | 79 ++++++++++++++++++-------------------
 include/net/inet_hashtables.h       | 72 ++++++++++++++++-----------------
 include/net/inet_sock.h             |  4 +-
 include/net/inet_timewait_sock.h    | 37 +++++++++--------
 include/net/inetpeer.h              | 12 +++---
 8 files changed, 157 insertions(+), 165 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 04642c9..f981ba7 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -22,27 +22,25 @@ struct sk_buff;
 struct sock;
 struct sockaddr;
 
-extern int inet6_csk_bind_conflict(const struct sock *sk,
-				   const struct inet_bind_bucket *tb, bool relax);
+int inet6_csk_bind_conflict(const struct sock *sk,
+			    const struct inet_bind_bucket *tb, bool relax);
 
-extern struct dst_entry* inet6_csk_route_req(struct sock *sk,
-					     struct flowi6 *fl6,
-					     const struct request_sock *req);
+struct dst_entry *inet6_csk_route_req(struct sock *sk, struct flowi6 *fl6,
+				      const struct request_sock *req);
 
-extern struct request_sock *inet6_csk_search_req(const struct sock *sk,
-						 struct request_sock ***prevp,
-						 const __be16 rport,
-						 const struct in6_addr *raddr,
-						 const struct in6_addr *laddr,
-						 const int iif);
+struct request_sock *inet6_csk_search_req(const struct sock *sk,
+					  struct request_sock ***prevp,
+					  const __be16 rport,
+					  const struct in6_addr *raddr,
+					  const struct in6_addr *laddr,
+					  const int iif);
 
-extern void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
-					   struct request_sock *req,
-					   const unsigned long timeout);
+void inet6_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
+				    const unsigned long timeout);
 
-extern void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
+void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
 
-extern int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl);
+int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl);
 
-extern struct dst_entry *inet6_csk_update_pmtu(struct sock *sk, u32 mtu);
+struct dst_entry *inet6_csk_update_pmtu(struct sock *sk, u32 mtu);
 #endif /* _INET6_CONNECTION_SOCK_H */
diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index fd4ee01..f52fa88 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -53,7 +53,7 @@ static inline int inet6_sk_ehashfn(const struct sock *sk)
 	return inet6_ehashfn(net, laddr, lport, faddr, fport);
 }
 
-extern int __inet6_hash(struct sock *sk, struct inet_timewait_sock *twp);
+int __inet6_hash(struct sock *sk, struct inet_timewait_sock *twp);
 
 /*
  * Sockets in TCP_CLOSE state are _always_ taken out of the hash, so
@@ -61,21 +61,19 @@ extern int __inet6_hash(struct sock *sk, struct inet_timewait_sock *twp);
  *
  * The sockhash lock must be held as a reader here.
  */
-extern struct sock *__inet6_lookup_established(struct net *net,
-					   struct inet_hashinfo *hashinfo,
-					   const struct in6_addr *saddr,
-					   const __be16 sport,
-					   const struct in6_addr *daddr,
-					   const u16 hnum,
-					   const int dif);
-
-extern struct sock *inet6_lookup_listener(struct net *net,
-					  struct inet_hashinfo *hashinfo,
-					  const struct in6_addr *saddr,
-					  const __be16 sport,
-					  const struct in6_addr *daddr,
-					  const unsigned short hnum,
-					  const int dif);
+struct sock *__inet6_lookup_established(struct net *net,
+					struct inet_hashinfo *hashinfo,
+					const struct in6_addr *saddr,
+					const __be16 sport,
+					const struct in6_addr *daddr,
+					const u16 hnum, const int dif);
+
+struct sock *inet6_lookup_listener(struct net *net,
+				   struct inet_hashinfo *hashinfo,
+				   const struct in6_addr *saddr,
+				   const __be16 sport,
+				   const struct in6_addr *daddr,
+				   const unsigned short hnum, const int dif);
 
 static inline struct sock *__inet6_lookup(struct net *net,
 					  struct inet_hashinfo *hashinfo,
@@ -110,9 +108,9 @@ static inline struct sock *__inet6_lookup_skb(struct inet_hashinfo *hashinfo,
 			      inet6_iif(skb));
 }
 
-extern struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
-				 const struct in6_addr *saddr, const __be16 sport,
-				 const struct in6_addr *daddr, const __be16 dport,
-				 const int dif);
+struct sock *inet6_lookup(struct net *net, struct inet_hashinfo *hashinfo,
+			  const struct in6_addr *saddr, const __be16 sport,
+			  const struct in6_addr *daddr, const __be16 dport,
+			  const int dif);
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 #endif /* _INET6_HASHTABLES_H */
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 2340087..fe7994c 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -13,30 +13,30 @@ struct sock;
 struct sockaddr;
 struct socket;
 
-extern int inet_release(struct socket *sock);
-extern int inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
-			       int addr_len, int flags);
-extern int __inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
-				 int addr_len, int flags);
-extern int inet_dgram_connect(struct socket *sock, struct sockaddr *uaddr,
-			      int addr_len, int flags);
-extern int inet_accept(struct socket *sock, struct socket *newsock, int flags);
-extern int inet_sendmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, size_t size);
-extern ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
-			     size_t size, int flags);
-extern int inet_recvmsg(struct kiocb *iocb, struct socket *sock,
-			struct msghdr *msg, size_t size, int flags);
-extern int inet_shutdown(struct socket *sock, int how);
-extern int inet_listen(struct socket *sock, int backlog);
-extern void inet_sock_destruct(struct sock *sk);
-extern int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len);
-extern int inet_getname(struct socket *sock, struct sockaddr *uaddr,
-			int *uaddr_len, int peer);
-extern int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
-extern int inet_ctl_sock_create(struct sock **sk, unsigned short family,
-				unsigned short type, unsigned char protocol,
-				struct net *net);
+int inet_release(struct socket *sock);
+int inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
+			int addr_len, int flags);
+int __inet_stream_connect(struct socket *sock, struct sockaddr *uaddr,
+			  int addr_len, int flags);
+int inet_dgram_connect(struct socket *sock, struct sockaddr *uaddr,
+		       int addr_len, int flags);
+int inet_accept(struct socket *sock, struct socket *newsock, int flags);
+int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
+		 size_t size);
+ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
+		      size_t size, int flags);
+int inet_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
+		 size_t size, int flags);
+int inet_shutdown(struct socket *sock, int how);
+int inet_listen(struct socket *sock, int backlog);
+void inet_sock_destruct(struct sock *sk);
+int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len);
+int inet_getname(struct socket *sock, struct sockaddr *uaddr, int *uaddr_len,
+		 int peer);
+int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
+int inet_ctl_sock_create(struct sock **sk, unsigned short family,
+			 unsigned short type, unsigned char protocol,
+			 struct net *net);
 
 static inline void inet_ctl_sock_destroy(struct sock *sk)
 {
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index de2c785..c55aeed 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -146,9 +146,9 @@ static inline void *inet_csk_ca(const struct sock *sk)
 	return (void *)inet_csk(sk)->icsk_ca_priv;
 }
 
-extern struct sock *inet_csk_clone_lock(const struct sock *sk,
-					const struct request_sock *req,
-					const gfp_t priority);
+struct sock *inet_csk_clone_lock(const struct sock *sk,
+				 const struct request_sock *req,
+				 const gfp_t priority);
 
 enum inet_csk_ack_state_t {
 	ICSK_ACK_SCHED	= 1,
@@ -157,11 +157,11 @@ enum inet_csk_ack_state_t {
 	ICSK_ACK_PUSHED2 = 8
 };
 
-extern void inet_csk_init_xmit_timers(struct sock *sk,
-				      void (*retransmit_handler)(unsigned long),
-				      void (*delack_handler)(unsigned long),
-				      void (*keepalive_handler)(unsigned long));
-extern void inet_csk_clear_xmit_timers(struct sock *sk);
+void inet_csk_init_xmit_timers(struct sock *sk,
+			       void (*retransmit_handler)(unsigned long),
+			       void (*delack_handler)(unsigned long),
+			       void (*keepalive_handler)(unsigned long));
+void inet_csk_clear_xmit_timers(struct sock *sk);
 
 static inline void inet_csk_schedule_ack(struct sock *sk)
 {
@@ -178,8 +178,8 @@ static inline void inet_csk_delack_init(struct sock *sk)
 	memset(&inet_csk(sk)->icsk_ack, 0, sizeof(inet_csk(sk)->icsk_ack));
 }
 
-extern void inet_csk_delete_keepalive_timer(struct sock *sk);
-extern void inet_csk_reset_keepalive_timer(struct sock *sk, unsigned long timeout);
+void inet_csk_delete_keepalive_timer(struct sock *sk);
+void inet_csk_reset_keepalive_timer(struct sock *sk, unsigned long timeout);
 
 #ifdef INET_CSK_DEBUG
 extern const char inet_csk_timer_bug_msg[];
@@ -241,23 +241,21 @@ static inline void inet_csk_reset_xmit_timer(struct sock *sk, const int what,
 #endif
 }
 
-extern struct sock *inet_csk_accept(struct sock *sk, int flags, int *err);
+struct sock *inet_csk_accept(struct sock *sk, int flags, int *err);
 
-extern struct request_sock *inet_csk_search_req(const struct sock *sk,
-						struct request_sock ***prevp,
-						const __be16 rport,
-						const __be32 raddr,
-						const __be32 laddr);
-extern int inet_csk_bind_conflict(const struct sock *sk,
-				  const struct inet_bind_bucket *tb, bool relax);
-extern int inet_csk_get_port(struct sock *sk, unsigned short snum);
+struct request_sock *inet_csk_search_req(const struct sock *sk,
+					 struct request_sock ***prevp,
+					 const __be16 rport,
+					 const __be32 raddr,
+					 const __be32 laddr);
+int inet_csk_bind_conflict(const struct sock *sk,
+			   const struct inet_bind_bucket *tb, bool relax);
+int inet_csk_get_port(struct sock *sk, unsigned short snum);
 
-extern struct dst_entry* inet_csk_route_req(struct sock *sk,
-					    struct flowi4 *fl4,
+struct dst_entry *inet_csk_route_req(struct sock *sk, struct flowi4 *fl4,
+				     const struct request_sock *req);
+struct dst_entry *inet_csk_route_child_sock(struct sock *sk, struct sock *newsk,
 					    const struct request_sock *req);
-extern struct dst_entry* inet_csk_route_child_sock(struct sock *sk,
-						   struct sock *newsk,
-						   const struct request_sock *req);
 
 static inline void inet_csk_reqsk_queue_add(struct sock *sk,
 					    struct request_sock *req,
@@ -266,9 +264,8 @@ static inline void inet_csk_reqsk_queue_add(struct sock *sk,
 	reqsk_queue_add(&inet_csk(sk)->icsk_accept_queue, req, sk, child);
 }
 
-extern void inet_csk_reqsk_queue_hash_add(struct sock *sk,
-					  struct request_sock *req,
-					  unsigned long timeout);
+void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
+				   unsigned long timeout);
 
 static inline void inet_csk_reqsk_queue_removed(struct sock *sk,
 						struct request_sock *req)
@@ -315,13 +312,13 @@ static inline void inet_csk_reqsk_queue_drop(struct sock *sk,
 	reqsk_free(req);
 }
 
-extern void inet_csk_reqsk_queue_prune(struct sock *parent,
-				       const unsigned long interval,
-				       const unsigned long timeout,
-				       const unsigned long max_rto);
+void inet_csk_reqsk_queue_prune(struct sock *parent,
+				const unsigned long interval,
+				const unsigned long timeout,
+				const unsigned long max_rto);
 
-extern void inet_csk_destroy_sock(struct sock *sk);
-extern void inet_csk_prepare_forced_close(struct sock *sk);
+void inet_csk_destroy_sock(struct sock *sk);
+void inet_csk_prepare_forced_close(struct sock *sk);
 
 /*
  * LISTEN is a special case for poll..
@@ -332,15 +329,15 @@ static inline unsigned int inet_csk_listen_poll(const struct sock *sk)
 			(POLLIN | POLLRDNORM) : 0;
 }
 
-extern int  inet_csk_listen_start(struct sock *sk, const int nr_table_entries);
-extern void inet_csk_listen_stop(struct sock *sk);
+int inet_csk_listen_start(struct sock *sk, const int nr_table_entries);
+void inet_csk_listen_stop(struct sock *sk);
 
-extern void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
+void inet_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
 
-extern int inet_csk_compat_getsockopt(struct sock *sk, int level, int optname,
-				      char __user *optval, int __user *optlen);
-extern int inet_csk_compat_setsockopt(struct sock *sk, int level, int optname,
-				      char __user *optval, unsigned int optlen);
+int inet_csk_compat_getsockopt(struct sock *sk, int level, int optname,
+			       char __user *optval, int __user *optlen);
+int inet_csk_compat_setsockopt(struct sock *sk, int level, int optname,
+			       char __user *optval, unsigned int optlen);
 
-extern struct dst_entry *inet_csk_update_pmtu(struct sock *sk, u32 mtu);
+struct dst_entry *inet_csk_update_pmtu(struct sock *sk, u32 mtu);
 #endif /* _INET_CONNECTION_SOCK_H */
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index ef83d9e..594dfee 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -218,22 +218,21 @@ static inline void inet_ehash_locks_free(struct inet_hashinfo *hashinfo)
 	}
 }
 
-extern struct inet_bind_bucket *
-		    inet_bind_bucket_create(struct kmem_cache *cachep,
-					    struct net *net,
-					    struct inet_bind_hashbucket *head,
-					    const unsigned short snum);
-extern void inet_bind_bucket_destroy(struct kmem_cache *cachep,
-				     struct inet_bind_bucket *tb);
-
-static inline int inet_bhashfn(struct net *net,
-		const __u16 lport, const int bhash_size)
+struct inet_bind_bucket *
+inet_bind_bucket_create(struct kmem_cache *cachep, struct net *net,
+			struct inet_bind_hashbucket *head,
+			const unsigned short snum);
+void inet_bind_bucket_destroy(struct kmem_cache *cachep,
+			      struct inet_bind_bucket *tb);
+
+static inline int inet_bhashfn(struct net *net, const __u16 lport,
+			       const int bhash_size)
 {
 	return (lport + net_hash_mix(net)) & (bhash_size - 1);
 }
 
-extern void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
-			   const unsigned short snum);
+void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
+		    const unsigned short snum);
 
 /* These can have wildcards, don't try too hard. */
 static inline int inet_lhashfn(struct net *net, const unsigned short num)
@@ -247,23 +246,22 @@ static inline int inet_sk_listen_hashfn(const struct sock *sk)
 }
 
 /* Caller must disable local BH processing. */
-extern int __inet_inherit_port(struct sock *sk, struct sock *child);
+int __inet_inherit_port(struct sock *sk, struct sock *child);
 
-extern void inet_put_port(struct sock *sk);
+void inet_put_port(struct sock *sk);
 
 void inet_hashinfo_init(struct inet_hashinfo *h);
 
-extern int __inet_hash_nolisten(struct sock *sk, struct inet_timewait_sock *tw);
-extern void inet_hash(struct sock *sk);
-extern void inet_unhash(struct sock *sk);
+int __inet_hash_nolisten(struct sock *sk, struct inet_timewait_sock *tw);
+void inet_hash(struct sock *sk);
+void inet_unhash(struct sock *sk);
 
-extern struct sock *__inet_lookup_listener(struct net *net,
-					   struct inet_hashinfo *hashinfo,
-					   const __be32 saddr,
-					   const __be16 sport,
-					   const __be32 daddr,
-					   const unsigned short hnum,
-					   const int dif);
+struct sock *__inet_lookup_listener(struct net *net,
+				    struct inet_hashinfo *hashinfo,
+				    const __be32 saddr, const __be16 sport,
+				    const __be32 daddr,
+				    const unsigned short hnum,
+				    const int dif);
 
 static inline struct sock *inet_lookup_listener(struct net *net,
 		struct inet_hashinfo *hashinfo,
@@ -339,10 +337,11 @@ static inline struct sock *inet_lookup_listener(struct net *net,
  *
  * Local BH must be disabled here.
  */
-extern struct sock * __inet_lookup_established(struct net *net,
-		struct inet_hashinfo *hashinfo,
-		const __be32 saddr, const __be16 sport,
-		const __be32 daddr, const u16 hnum, const int dif);
+struct sock *__inet_lookup_established(struct net *net,
+				       struct inet_hashinfo *hashinfo,
+				       const __be32 saddr, const __be16 sport,
+				       const __be32 daddr, const u16 hnum,
+				       const int dif);
 
 static inline struct sock *
 	inet_lookup_established(struct net *net, struct inet_hashinfo *hashinfo,
@@ -399,13 +398,14 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 				     iph->daddr, dport, inet_iif(skb));
 }
 
-extern int __inet_hash_connect(struct inet_timewait_death_row *death_row,
-		struct sock *sk,
-		u32 port_offset,
-		int (*check_established)(struct inet_timewait_death_row *,
-			struct sock *, __u16, struct inet_timewait_sock **),
-		int (*hash)(struct sock *sk, struct inet_timewait_sock *twp));
+int __inet_hash_connect(struct inet_timewait_death_row *death_row,
+			struct sock *sk, u32 port_offset,
+			int (*check_established)(struct inet_timewait_death_row *,
+						 struct sock *, __u16,
+						 struct inet_timewait_sock **),
+			int (*hash)(struct sock *sk,
+				    struct inet_timewait_sock *twp));
 
-extern int inet_hash_connect(struct inet_timewait_death_row *death_row,
-			     struct sock *sk);
+int inet_hash_connect(struct inet_timewait_death_row *death_row,
+		      struct sock *sk);
 #endif /* _INET_HASHTABLES_H */
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index b21a7f0..636d203 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -199,11 +199,11 @@ static inline void inet_sk_copy_descendant(struct sock *sk_to,
 }
 #endif
 
-extern int inet_sk_rebuild_header(struct sock *sk);
+int inet_sk_rebuild_header(struct sock *sk);
 
 extern u32 inet_ehash_secret;
 extern u32 ipv6_hash_secret;
-extern void build_ehash_secret(void);
+void build_ehash_secret(void);
 
 static inline unsigned int inet_ehashfn(struct net *net,
 					const __be32 laddr, const __u16 lport,
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index f908dfc..828200a 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -83,9 +83,9 @@ struct inet_timewait_death_row {
 	int			sysctl_max_tw_buckets;
 };
 
-extern void inet_twdr_hangman(unsigned long data);
-extern void inet_twdr_twkill_work(struct work_struct *work);
-extern void inet_twdr_twcal_tick(unsigned long data);
+void inet_twdr_hangman(unsigned long data);
+void inet_twdr_twkill_work(struct work_struct *work);
+void inet_twdr_twcal_tick(unsigned long data);
 
 struct inet_bind_bucket;
 
@@ -195,28 +195,27 @@ static inline __be32 sk_rcv_saddr(const struct sock *sk)
 	return sk->__sk_common.skc_rcv_saddr;
 }
 
-extern void inet_twsk_put(struct inet_timewait_sock *tw);
+void inet_twsk_put(struct inet_timewait_sock *tw);
 
-extern int inet_twsk_unhash(struct inet_timewait_sock *tw);
+int inet_twsk_unhash(struct inet_timewait_sock *tw);
 
-extern int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
-				 struct inet_hashinfo *hashinfo);
+int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
+			  struct inet_hashinfo *hashinfo);
 
-extern struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
-						  const int state);
+struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
+					   const int state);
 
-extern void __inet_twsk_hashdance(struct inet_timewait_sock *tw,
-				  struct sock *sk,
-				  struct inet_hashinfo *hashinfo);
+void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
+			   struct inet_hashinfo *hashinfo);
 
-extern void inet_twsk_schedule(struct inet_timewait_sock *tw,
-			       struct inet_timewait_death_row *twdr,
-			       const int timeo, const int timewait_len);
-extern void inet_twsk_deschedule(struct inet_timewait_sock *tw,
-				 struct inet_timewait_death_row *twdr);
+void inet_twsk_schedule(struct inet_timewait_sock *tw,
+			struct inet_timewait_death_row *twdr,
+			const int timeo, const int timewait_len);
+void inet_twsk_deschedule(struct inet_timewait_sock *tw,
+			  struct inet_timewait_death_row *twdr);
 
-extern void inet_twsk_purge(struct inet_hashinfo *hashinfo,
-			    struct inet_timewait_death_row *twdr, int family);
+void inet_twsk_purge(struct inet_hashinfo *hashinfo,
+		     struct inet_timewait_death_row *twdr, int family);
 
 static inline
 struct net *twsk_net(const struct inet_timewait_sock *twsk)
diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 53f464d..f4e127a 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -120,9 +120,9 @@ static inline void inetpeer_transfer_peer(unsigned long *to, unsigned long *from
 	}
 }
 
-extern void inet_peer_base_init(struct inet_peer_base *);
+void inet_peer_base_init(struct inet_peer_base *);
 
-void			inet_initpeers(void) __init;
+void inet_initpeers(void) __init;
 
 #define INETPEER_METRICS_NEW	(~(u32) 0)
 
@@ -159,11 +159,11 @@ static inline struct inet_peer *inet_getpeer_v6(struct inet_peer_base *base,
 }
 
 /* can be called from BH context or outside */
-extern void inet_putpeer(struct inet_peer *p);
-extern bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
+void inet_putpeer(struct inet_peer *p);
+bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
 
-extern void inetpeer_invalidate_tree(struct inet_peer_base *);
-extern void inetpeer_invalidate_family(int family);
+void inetpeer_invalidate_tree(struct inet_peer_base *);
+void inetpeer_invalidate_family(int family);
 
 /*
  * temporary check to make sure we dont access rid, ip_id_count, tcp_ts,
-- 
1.8.1.2.459.gbcd45b4.dirty
