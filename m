From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 1/2] net: cleanups
Date: Sun, 11 Jul 2010 14:41:06 +0800
Message-ID: <1278830466-22386-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:57384 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720Ab0GKGnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 02:43:50 -0400
Received: by pwi5 with SMTP id 5so1402537pwi.19
        for <netdev@vger.kernel.org>; Sat, 10 Jul 2010 23:43:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net: cleanups

remove useless blanks.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/net/inet_common.h |   55 ++++-------
 include/net/tcp.h         |  222 +++++++++++++++++-----------------------------
 include/net/udp.h         |   38 +++----
 3 files changed, 123 insertions(+), 192 deletions(-)
diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 18c7732..140c1ec 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -1,8 +1,8 @@
 #ifndef _INET_COMMON_H
 #define _INET_COMMON_H
 
-extern const struct proto_ops		inet_stream_ops;
-extern const struct proto_ops		inet_dgram_ops;
+extern const struct proto_ops inet_stream_ops;
+extern const struct proto_ops inet_dgram_ops;
 
 /*
  *	INET4 prototypes used by INET6
@@ -13,37 +13,24 @@ struct sock;
 struct sockaddr;
 struct socket;
 
-extern int			inet_release(struct socket *sock);
-extern int			inet_stream_connect(struct socket *sock,
-						    struct sockaddr * uaddr,
-						    int addr_len, int flags);
-extern int			inet_dgram_connect(struct socket *sock, 
-						   struct sockaddr * uaddr,
-						   int addr_len, int flags);
-extern int			inet_accept(struct socket *sock, 
-					    struct socket *newsock, int flags);
-extern int			inet_sendmsg(struct kiocb *iocb,
-					     struct socket *sock, 
-					     struct msghdr *msg, 
-					     size_t size);
-extern int			inet_shutdown(struct socket *sock, int how);
-extern int			inet_listen(struct socket *sock, int backlog);
-
-extern void			inet_sock_destruct(struct sock *sk);
-
-extern int			inet_bind(struct socket *sock, 
-					  struct sockaddr *uaddr, int addr_len);
-extern int			inet_getname(struct socket *sock, 
-					     struct sockaddr *uaddr, 
-					     int *uaddr_len, int peer);
-extern int			inet_ioctl(struct socket *sock, 
-					   unsigned int cmd, unsigned long arg);
-
-extern int			inet_ctl_sock_create(struct sock **sk,
-						     unsigned short family,
-						     unsigned short type,
-						     unsigned char protocol,
-						     struct net *net);
+extern int inet_release(struct socket *sock);
+extern int inet_stream_connect(struct socket *sock, struct sockaddr * uaddr,
+			       int addr_len, int flags);
+extern int inet_dgram_connect(struct socket *sock, struct sockaddr * uaddr,
+			      int addr_len, int flags);
+extern int inet_accept(struct socket *sock, struct socket *newsock, int flags);
+extern int inet_sendmsg(struct kiocb *iocb, struct socket *sock,
+			struct msghdr *msg, size_t size);
+extern int inet_shutdown(struct socket *sock, int how);
+extern int inet_listen(struct socket *sock, int backlog);
+extern void inet_sock_destruct(struct sock *sk);
+extern int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len);
+extern int inet_getname(struct socket *sock, struct sockaddr *uaddr,
+			int *uaddr_len, int peer);
+extern int inet_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
+extern int inet_ctl_sock_create(struct sock **sk, unsigned short family,
+				unsigned short type, unsigned char protocol,
+				struct net *net);
 
 static inline void inet_ctl_sock_destroy(struct sock *sk)
 {
@@ -51,5 +38,3 @@ static inline void inet_ctl_sock_destroy(struct sock *sk)
 }
 
 #endif
-
-
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c2f96c2..33ce524 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -296,45 +296,30 @@ extern struct proto tcp_prot;
 #define TCP_ADD_STATS_USER(net, field, val) SNMP_ADD_STATS_USER((net)->mib.tcp_statistics, field, val)
 #define TCP_ADD_STATS(net, field, val)	SNMP_ADD_STATS((net)->mib.tcp_statistics, field, val)
 
-extern void			tcp_v4_err(struct sk_buff *skb, u32);
-
-extern void			tcp_shutdown (struct sock *sk, int how);
-
-extern int			tcp_v4_rcv(struct sk_buff *skb);
-
-extern int			tcp_v4_remember_stamp(struct sock *sk);
-
-extern int		    	tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
-
-extern int			tcp_sendmsg(struct kiocb *iocb, struct socket *sock,
-					    struct msghdr *msg, size_t size);
-extern ssize_t			tcp_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags);
-
-extern int			tcp_ioctl(struct sock *sk, 
-					  int cmd, 
-					  unsigned long arg);
-
-extern int			tcp_rcv_state_process(struct sock *sk, 
-						      struct sk_buff *skb,
-						      struct tcphdr *th,
-						      unsigned len);
-
-extern int			tcp_rcv_established(struct sock *sk, 
-						    struct sk_buff *skb,
-						    struct tcphdr *th, 
-						    unsigned len);
-
-extern void			tcp_rcv_space_adjust(struct sock *sk);
-
-extern void			tcp_cleanup_rbuf(struct sock *sk, int copied);
-
-extern int			tcp_twsk_unique(struct sock *sk,
-						struct sock *sktw, void *twp);
-
-extern void			tcp_twsk_destructor(struct sock *sk);
-
-extern ssize_t			tcp_splice_read(struct socket *sk, loff_t *ppos,
-					        struct pipe_inode_info *pipe, size_t len, unsigned int flags);
+extern void tcp_v4_err(struct sk_buff *skb, u32);
+
+extern void tcp_shutdown (struct sock *sk, int how);
+
+extern int tcp_v4_rcv(struct sk_buff *skb);
+
+extern int tcp_v4_remember_stamp(struct sock *sk);
+extern int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
+extern int tcp_sendmsg(struct kiocb *iocb, struct socket *sock,
+		       struct msghdr *msg, size_t size);
+extern ssize_t tcp_sendpage(struct socket *sock, struct page *page, int offset,
+			    size_t size, int flags);
+extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
+extern int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
+				 struct tcphdr *th, unsigned len);
+extern int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
+			       struct tcphdr *th, unsigned len);
+extern void tcp_rcv_space_adjust(struct sock *sk);
+extern void tcp_cleanup_rbuf(struct sock *sk, int copied);
+extern int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp);
+extern void tcp_twsk_destructor(struct sock *sk);
+extern ssize_t tcp_splice_read(struct socket *sk, loff_t *ppos,
+			       struct pipe_inode_info *pipe, size_t len,
+			       unsigned int flags);
 
 static inline void tcp_dec_quickack_mode(struct sock *sk,
 					 const unsigned int pkts)
@@ -372,88 +357,59 @@ enum tcp_tw_status {
 };
 
 
-extern enum tcp_tw_status	tcp_timewait_state_process(struct inet_timewait_sock *tw,
-							   struct sk_buff *skb,
-							   const struct tcphdr *th);
-
-extern struct sock *		tcp_check_req(struct sock *sk,struct sk_buff *skb,
-					      struct request_sock *req,
-					      struct request_sock **prev);
-extern int			tcp_child_process(struct sock *parent,
-						  struct sock *child,
-						  struct sk_buff *skb);
-extern int			tcp_use_frto(struct sock *sk);
-extern void			tcp_enter_frto(struct sock *sk);
-extern void			tcp_enter_loss(struct sock *sk, int how);
-extern void			tcp_clear_retrans(struct tcp_sock *tp);
-extern void			tcp_update_metrics(struct sock *sk);
-
-extern void			tcp_close(struct sock *sk, 
-					  long timeout);
-extern unsigned int		tcp_poll(struct file * file, struct socket *sock, struct poll_table_struct *wait);
-
-extern int			tcp_getsockopt(struct sock *sk, int level, 
-					       int optname,
-					       char __user *optval, 
-					       int __user *optlen);
-extern int			tcp_setsockopt(struct sock *sk, int level, 
-					       int optname, char __user *optval, 
-					       unsigned int optlen);
-extern int			compat_tcp_getsockopt(struct sock *sk,
-					int level, int optname,
-					char __user *optval, int __user *optlen);
-extern int			compat_tcp_setsockopt(struct sock *sk,
-					int level, int optname,
-					char __user *optval, unsigned int optlen);
-extern void			tcp_set_keepalive(struct sock *sk, int val);
-extern void			tcp_syn_ack_timeout(struct sock *sk,
-						    struct request_sock *req);
-extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
-					    struct msghdr *msg,
-					    size_t len, int nonblock, 
-					    int flags, int *addr_len);
-
-extern void			tcp_parse_options(struct sk_buff *skb,
-						  struct tcp_options_received *opt_rx,
-						  u8 **hvpp,
-						  int estab);
-
-extern u8			*tcp_parse_md5sig_option(struct tcphdr *th);
+extern enum tcp_tw_status tcp_timewait_state_process(struct inet_timewait_sock *tw,
+						     struct sk_buff *skb,
+						     const struct tcphdr *th);
+extern struct sock * tcp_check_req(struct sock *sk,struct sk_buff *skb,
+				   struct request_sock *req,
+				   struct request_sock **prev);
+extern int tcp_child_process(struct sock *parent, struct sock *child,
+			     struct sk_buff *skb);
+extern int tcp_use_frto(struct sock *sk);
+extern void tcp_enter_frto(struct sock *sk);
+extern void tcp_enter_loss(struct sock *sk, int how);
+extern void tcp_clear_retrans(struct tcp_sock *tp);
+extern void tcp_update_metrics(struct sock *sk);
+extern void tcp_close(struct sock *sk, long timeout);
+extern unsigned int tcp_poll(struct file * file, struct socket *sock,
+			     struct poll_table_struct *wait);
+extern int tcp_getsockopt(struct sock *sk, int level, int optname,
+			  char __user *optval, int __user *optlen);
+extern int tcp_setsockopt(struct sock *sk, int level, int optname,
+			  char __user *optval, unsigned int optlen);
+extern int compat_tcp_getsockopt(struct sock *sk, int level, int optname,
+				 char __user *optval, int __user *optlen);
+extern int compat_tcp_setsockopt(struct sock *sk, int level, int optname,
+				 char __user *optval, unsigned int optlen);
+extern void tcp_set_keepalive(struct sock *sk, int val);
+extern void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req);
+extern int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		       size_t len, int nonblock, int flags, int *addr_len);
+extern void tcp_parse_options(struct sk_buff *skb,
+			      struct tcp_options_received *opt_rx, u8 **hvpp,
+			      int estab);
+extern u8 *tcp_parse_md5sig_option(struct tcphdr *th);
 
 /*
  *	TCP v4 functions exported for the inet6 API
  */
 
-extern void		       	tcp_v4_send_check(struct sock *sk,
-						  struct sk_buff *skb);
-
-extern int			tcp_v4_conn_request(struct sock *sk,
-						    struct sk_buff *skb);
-
-extern struct sock *		tcp_create_openreq_child(struct sock *sk,
-							 struct request_sock *req,
-							 struct sk_buff *skb);
-
-extern struct sock *		tcp_v4_syn_recv_sock(struct sock *sk,
-						     struct sk_buff *skb,
-						     struct request_sock *req,
-							struct dst_entry *dst);
-
-extern int			tcp_v4_do_rcv(struct sock *sk,
+extern void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb);
+extern int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
+extern struct sock * tcp_create_openreq_child(struct sock *sk,
+					      struct request_sock *req,
 					      struct sk_buff *skb);
-
-extern int			tcp_v4_connect(struct sock *sk,
-					       struct sockaddr *uaddr,
-					       int addr_len);
-
-extern int			tcp_connect(struct sock *sk);
-
-extern struct sk_buff *		tcp_make_synack(struct sock *sk,
-						struct dst_entry *dst,
-						struct request_sock *req,
-						struct request_values *rvp);
-
-extern int			tcp_disconnect(struct sock *sk, int flags);
+extern struct sock * tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
+					  struct request_sock *req,
+					  struct dst_entry *dst);
+extern int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
+extern int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr,
+			  int addr_len);
+extern int tcp_connect(struct sock *sk);
+extern struct sk_buff * tcp_make_synack(struct sock *sk, struct dst_entry *dst,
+					struct request_sock *req,
+					struct request_values *rvp);
+extern int tcp_disconnect(struct sock *sk, int flags);
 
 
 /* From syncookies.c */
@@ -485,10 +441,10 @@ extern int tcp_fragment(struct sock *, struct sk_buff *, u32, unsigned int);
 
 extern void tcp_send_probe0(struct sock *);
 extern void tcp_send_partial(struct sock *);
-extern int  tcp_write_wakeup(struct sock *);
+extern int tcp_write_wakeup(struct sock *);
 extern void tcp_send_fin(struct sock *sk);
 extern void tcp_send_active_reset(struct sock *sk, gfp_t priority);
-extern int  tcp_send_synack(struct sock *);
+extern int tcp_send_synack(struct sock *);
 extern void tcp_push_one(struct sock *, unsigned int mss_now);
 extern void tcp_send_ack(struct sock *sk);
 extern void tcp_send_delayed_ack(struct sock *sk);
@@ -592,7 +548,7 @@ static inline u32 tcp_receive_window(const struct tcp_sock *tp)
  * scaling applied to the result.  The caller does these things
  * if necessary.  This is a "raw" window selection.
  */
-extern u32	__tcp_select_window(struct sock *sk);
+extern u32 __tcp_select_window(struct sock *sk);
 
 /* TCP timestamps are only 32-bits, this causes a slight
  * complication on 64-bit systems since we store a snapshot
@@ -1174,22 +1130,14 @@ struct tcp_md5sig_pool {
 #define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */
 
 /* - functions */
-extern int			tcp_v4_md5_hash_skb(char *md5_hash,
-						    struct tcp_md5sig_key *key,
-						    struct sock *sk,
-						    struct request_sock *req,
-						    struct sk_buff *skb);
-
-extern struct tcp_md5sig_key	*tcp_v4_md5_lookup(struct sock *sk,
-						   struct sock *addr_sk);
-
-extern int			tcp_v4_md5_do_add(struct sock *sk,
-						  __be32 addr,
-						  u8 *newkey,
-						  u8 newkeylen);
-
-extern int			tcp_v4_md5_do_del(struct sock *sk,
-						  __be32 addr);
+extern int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
+			       struct sock *sk, struct request_sock *req,
+			       struct sk_buff *skb);
+extern struct tcp_md5sig_key * tcp_v4_md5_lookup(struct sock *sk,
+						 struct sock *addr_sk);
+extern int tcp_v4_md5_do_add(struct sock *sk, __be32 addr, u8 *newkey,
+			     u8 newkeylen);
+extern int tcp_v4_md5_do_del(struct sock *sk, __be32 addr);
 
 #ifdef CONFIG_TCP_MD5SIG
 #define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5_keylen ? 		 \
@@ -1202,10 +1150,10 @@ extern int			tcp_v4_md5_do_del(struct sock *sk,
 #endif
 
 extern struct tcp_md5sig_pool * __percpu *tcp_alloc_md5sig_pool(struct sock *);
-extern void			tcp_free_md5sig_pool(void);
+extern void tcp_free_md5sig_pool(void);
 
 extern struct tcp_md5sig_pool	*tcp_get_md5sig_pool(void);
-extern void			tcp_put_md5sig_pool(void);
+extern void tcp_put_md5sig_pool(void);
 
 extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, struct tcphdr *);
 extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, struct sk_buff *,
@@ -1433,7 +1381,7 @@ extern int tcp_gro_complete(struct sk_buff *skb);
 extern int tcp4_gro_complete(struct sk_buff *skb);
 
 #ifdef CONFIG_PROC_FS
-extern int  tcp4_proc_init(void);
+extern int tcp4_proc_init(void);
 extern void tcp4_proc_exit(void);
 #endif
 
diff --git a/include/net/udp.h b/include/net/udp.h
index 5348d80..7abdf30 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -157,30 +157,28 @@ static inline void udp_lib_close(struct sock *sk, long timeout)
 	sk_common_release(sk);
 }
 
-extern int	udp_lib_get_port(struct sock *sk, unsigned short snum,
-		int (*)(const struct sock *,const struct sock *),
-		unsigned int hash2_nulladdr);
+extern int udp_lib_get_port(struct sock *sk, unsigned short snum,
+			    int (*)(const struct sock *,const struct sock *),
+			    unsigned int hash2_nulladdr);
 
 /* net/ipv4/udp.c */
-extern int	udp_get_port(struct sock *sk, unsigned short snum,
-			     int (*saddr_cmp)(const struct sock *, const struct sock *));
-extern void	udp_err(struct sk_buff *, u32);
-
-extern int	udp_sendmsg(struct kiocb *iocb, struct sock *sk,
+extern int udp_get_port(struct sock *sk, unsigned short snum,
+			int (*saddr_cmp)(const struct sock *,
+					 const struct sock *));
+extern void udp_err(struct sk_buff *, u32);
+extern int udp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			    struct msghdr *msg, size_t len);
-extern void	udp_flush_pending_frames(struct sock *sk);
-
-extern int	udp_rcv(struct sk_buff *skb);
-extern int	udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
-extern int	udp_disconnect(struct sock *sk, int flags);
+extern void udp_flush_pending_frames(struct sock *sk);
+extern int udp_rcv(struct sk_buff *skb);
+extern int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
+extern int udp_disconnect(struct sock *sk, int flags);
 extern unsigned int udp_poll(struct file *file, struct socket *sock,
 			     poll_table *wait);
-extern int 	udp_lib_getsockopt(struct sock *sk, int level, int optname,
-			           char __user *optval, int __user *optlen);
-extern int 	udp_lib_setsockopt(struct sock *sk, int level, int optname,
-				   char __user *optval, unsigned int optlen,
-				   int (*push_pending_frames)(struct sock *));
-
+extern int udp_lib_getsockopt(struct sock *sk, int level, int optname,
+			      char __user *optval, int __user *optlen);
+extern int udp_lib_setsockopt(struct sock *sk, int level, int optname,
+			      char __user *optval, unsigned int optlen,
+			      int (*push_pending_frames)(struct sock *));
 extern struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 				    __be32 daddr, __be16 dport,
 				    int dif);
@@ -236,7 +234,7 @@ struct udp_iter_state {
 extern int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo);
 extern void udp_proc_unregister(struct net *net, struct udp_seq_afinfo *afinfo);
 
-extern int  udp4_proc_init(void);
+extern int udp4_proc_init(void);
 extern void udp4_proc_exit(void);
 #endif
 
