From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/12] tcp.h: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 11:33:32 -0700
Message-ID: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/tcp.h | 424 +++++++++++++++++++++++++++---------------------------
 1 file changed, 208 insertions(+), 216 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index b1aa324..0e47551 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -50,7 +50,7 @@
 extern struct inet_hashinfo tcp_hashinfo;
 
 extern struct percpu_counter tcp_orphan_count;
-extern void tcp_time_wait(struct sock *sk, int state, int timeo);
+void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 #define MAX_TCP_HEADER	(128 + MAX_HEADER)
 #define MAX_TCP_OPTION_SPACE 40
@@ -325,7 +325,7 @@ static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
 	return false;
 }
 
-extern bool tcp_check_oom(struct sock *sk, int shift);
+bool tcp_check_oom(struct sock *sk, int shift);
 
 /* syncookies: remember time of last synqueue overflow */
 static inline void tcp_synq_overflow(struct sock *sk)
@@ -348,38 +348,38 @@ extern struct proto tcp_prot;
 #define TCP_ADD_STATS_USER(net, field, val) SNMP_ADD_STATS_USER((net)->mib.tcp_statistics, field, val)
 #define TCP_ADD_STATS(net, field, val)	SNMP_ADD_STATS((net)->mib.tcp_statistics, field, val)
 
-extern void tcp_init_mem(struct net *net);
-
-extern void tcp_tasklet_init(void);
-
-extern void tcp_v4_err(struct sk_buff *skb, u32);
-
-extern void tcp_shutdown (struct sock *sk, int how);
-
-extern void tcp_v4_early_demux(struct sk_buff *skb);
-extern int tcp_v4_rcv(struct sk_buff *skb);
-
-extern int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
-extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		       size_t size);
-extern int tcp_sendpage(struct sock *sk, struct page *page, int offset,
-			size_t size, int flags);
-extern void tcp_release_cb(struct sock *sk);
-extern void tcp_wfree(struct sk_buff *skb);
-extern void tcp_write_timer_handler(struct sock *sk);
-extern void tcp_delack_timer_handler(struct sock *sk);
-extern int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
-extern int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-				 const struct tcphdr *th, unsigned int len);
-extern void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
-				const struct tcphdr *th, unsigned int len);
-extern void tcp_rcv_space_adjust(struct sock *sk);
-extern void tcp_cleanup_rbuf(struct sock *sk, int copied);
-extern int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp);
-extern void tcp_twsk_destructor(struct sock *sk);
-extern ssize_t tcp_splice_read(struct socket *sk, loff_t *ppos,
-			       struct pipe_inode_info *pipe, size_t len,
-			       unsigned int flags);
+void tcp_init_mem(struct net *net);
+
+void tcp_tasklet_init(void);
+
+void tcp_v4_err(struct sk_buff *skb, u32);
+
+void tcp_shutdown(struct sock *sk, int how);
+
+void tcp_v4_early_demux(struct sk_buff *skb);
+int tcp_v4_rcv(struct sk_buff *skb);
+
+int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
+int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		size_t size);
+int tcp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
+		 int flags);
+void tcp_release_cb(struct sock *sk);
+void tcp_wfree(struct sk_buff *skb);
+void tcp_write_timer_handler(struct sock *sk);
+void tcp_delack_timer_handler(struct sock *sk);
+int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg);
+int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
+			  const struct tcphdr *th, unsigned int len);
+void tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
+			 const struct tcphdr *th, unsigned int len);
+void tcp_rcv_space_adjust(struct sock *sk);
+void tcp_cleanup_rbuf(struct sock *sk, int copied);
+int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp);
+void tcp_twsk_destructor(struct sock *sk);
+ssize_t tcp_splice_read(struct socket *sk, loff_t *ppos,
+			struct pipe_inode_info *pipe, size_t len,
+			unsigned int flags);
 
 static inline void tcp_dec_quickack_mode(struct sock *sk,
 					 const unsigned int pkts)
@@ -409,66 +409,65 @@ enum tcp_tw_status {
 };
 
 
-extern enum tcp_tw_status tcp_timewait_state_process(struct inet_timewait_sock *tw,
-						     struct sk_buff *skb,
-						     const struct tcphdr *th);
-extern struct sock * tcp_check_req(struct sock *sk,struct sk_buff *skb,
-				   struct request_sock *req,
-				   struct request_sock **prev,
-				   bool fastopen);
-extern int tcp_child_process(struct sock *parent, struct sock *child,
-			     struct sk_buff *skb);
-extern void tcp_enter_loss(struct sock *sk, int how);
-extern void tcp_clear_retrans(struct tcp_sock *tp);
-extern void tcp_update_metrics(struct sock *sk);
-extern void tcp_init_metrics(struct sock *sk);
-extern void tcp_metrics_init(void);
-extern bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst, bool paws_check);
-extern bool tcp_remember_stamp(struct sock *sk);
-extern bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw);
-extern void tcp_fetch_timewait_stamp(struct sock *sk, struct dst_entry *dst);
-extern void tcp_disable_fack(struct tcp_sock *tp);
-extern void tcp_close(struct sock *sk, long timeout);
-extern void tcp_init_sock(struct sock *sk);
-extern unsigned int tcp_poll(struct file * file, struct socket *sock,
-			     struct poll_table_struct *wait);
-extern int tcp_getsockopt(struct sock *sk, int level, int optname,
+enum tcp_tw_status tcp_timewait_state_process(struct inet_timewait_sock *tw,
+					      struct sk_buff *skb,
+					      const struct tcphdr *th);
+struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
+			   struct request_sock *req, struct request_sock **prev,
+			   bool fastopen);
+int tcp_child_process(struct sock *parent, struct sock *child,
+		      struct sk_buff *skb);
+void tcp_enter_loss(struct sock *sk, int how);
+void tcp_clear_retrans(struct tcp_sock *tp);
+void tcp_update_metrics(struct sock *sk);
+void tcp_init_metrics(struct sock *sk);
+void tcp_metrics_init(void);
+bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst,
+			bool paws_check);
+bool tcp_remember_stamp(struct sock *sk);
+bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw);
+void tcp_fetch_timewait_stamp(struct sock *sk, struct dst_entry *dst);
+void tcp_disable_fack(struct tcp_sock *tp);
+void tcp_close(struct sock *sk, long timeout);
+void tcp_init_sock(struct sock *sk);
+unsigned int tcp_poll(struct file *file, struct socket *sock,
+		      struct poll_table_struct *wait);
+int tcp_getsockopt(struct sock *sk, int level, int optname,
+		   char __user *optval, int __user *optlen);
+int tcp_setsockopt(struct sock *sk, int level, int optname,
+		   char __user *optval, unsigned int optlen);
+int compat_tcp_getsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, int __user *optlen);
-extern int tcp_setsockopt(struct sock *sk, int level, int optname,
+int compat_tcp_setsockopt(struct sock *sk, int level, int optname,
 			  char __user *optval, unsigned int optlen);
-extern int compat_tcp_getsockopt(struct sock *sk, int level, int optname,
-				 char __user *optval, int __user *optlen);
-extern int compat_tcp_setsockopt(struct sock *sk, int level, int optname,
-				 char __user *optval, unsigned int optlen);
-extern void tcp_set_keepalive(struct sock *sk, int val);
-extern void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req);
-extern int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		       size_t len, int nonblock, int flags, int *addr_len);
-extern void tcp_parse_options(const struct sk_buff *skb,
-			      struct tcp_options_received *opt_rx,
-			      int estab, struct tcp_fastopen_cookie *foc);
-extern const u8 *tcp_parse_md5sig_option(const struct tcphdr *th);
+void tcp_set_keepalive(struct sock *sk, int val);
+void tcp_syn_ack_timeout(struct sock *sk, struct request_sock *req);
+int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		size_t len, int nonblock, int flags, int *addr_len);
+void tcp_parse_options(const struct sk_buff *skb,
+		       struct tcp_options_received *opt_rx,
+		       int estab, struct tcp_fastopen_cookie *foc);
+const u8 *tcp_parse_md5sig_option(const struct tcphdr *th);
 
 /*
  *	TCP v4 functions exported for the inet6 API
  */
 
-extern void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb);
-extern int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
-extern struct sock * tcp_create_openreq_child(struct sock *sk,
-					      struct request_sock *req,
-					      struct sk_buff *skb);
-extern struct sock * tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
-					  struct request_sock *req,
-					  struct dst_entry *dst);
-extern int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
-extern int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr,
-			  int addr_len);
-extern int tcp_connect(struct sock *sk);
-extern struct sk_buff * tcp_make_synack(struct sock *sk, struct dst_entry *dst,
-					struct request_sock *req,
-					struct tcp_fastopen_cookie *foc);
-extern int tcp_disconnect(struct sock *sk, int flags);
+void tcp_v4_send_check(struct sock *sk, struct sk_buff *skb);
+int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
+struct sock *tcp_create_openreq_child(struct sock *sk,
+				      struct request_sock *req,
+				      struct sk_buff *skb);
+struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
+				  struct request_sock *req,
+				  struct dst_entry *dst);
+int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
+int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
+int tcp_connect(struct sock *sk);
+struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
+				struct request_sock *req,
+				struct tcp_fastopen_cookie *foc);
+int tcp_disconnect(struct sock *sk, int flags);
 
 void tcp_connect_init(struct sock *sk);
 void tcp_finish_connect(struct sock *sk, struct sk_buff *skb);
@@ -477,15 +476,14 @@ void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
 
 /* From syncookies.c */
 extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
-extern int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
-			     u32 cookie);
-extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
-				    struct ip_options *opt);
+int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
+		      u32 cookie);
+struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
+			     struct ip_options *opt);
 #ifdef CONFIG_SYN_COOKIES
-extern u32 __cookie_v4_init_sequence(const struct iphdr *iph,
-				     const struct tcphdr *th, u16 *mssp);
-extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
-				     __u16 *mss);
+u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
+			      u16 *mssp);
+__u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mss);
 #else
 static inline __u32 cookie_v4_init_sequence(struct sock *sk,
 					    struct sk_buff *skb,
@@ -495,19 +493,19 @@ static inline __u32 cookie_v4_init_sequence(struct sock *sk,
 }
 #endif
 
-extern __u32 cookie_init_timestamp(struct request_sock *req);
-extern bool cookie_check_timestamp(struct tcp_options_received *opt,
-				struct net *net, bool *ecn_ok);
+__u32 cookie_init_timestamp(struct request_sock *req);
+bool cookie_check_timestamp(struct tcp_options_received *opt, struct net *net,
+			    bool *ecn_ok);
 
 /* From net/ipv6/syncookies.c */
-extern int __cookie_v6_check(const struct ipv6hdr *iph, const struct tcphdr *th,
-			     u32 cookie);
-extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
+int __cookie_v6_check(const struct ipv6hdr *iph, const struct tcphdr *th,
+		      u32 cookie);
+struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
 #ifdef CONFIG_SYN_COOKIES
-extern u32 __cookie_v6_init_sequence(const struct ipv6hdr *iph,
-				     const struct tcphdr *th, u16 *mssp);
-extern __u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb,
-				     __u16 *mss);
+u32 __cookie_v6_init_sequence(const struct ipv6hdr *iph,
+			      const struct tcphdr *th, u16 *mssp);
+__u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb,
+			      __u16 *mss);
 #else
 static inline __u32 cookie_v6_init_sequence(struct sock *sk,
 					    struct sk_buff *skb,
@@ -518,47 +516,46 @@ static inline __u32 cookie_v6_init_sequence(struct sock *sk,
 #endif
 /* tcp_output.c */
 
-extern void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
-				      int nonagle);
-extern bool tcp_may_send_now(struct sock *sk);
-extern int __tcp_retransmit_skb(struct sock *, struct sk_buff *);
-extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
-extern void tcp_retransmit_timer(struct sock *sk);
-extern void tcp_xmit_retransmit_queue(struct sock *);
-extern void tcp_simple_retransmit(struct sock *);
-extern int tcp_trim_head(struct sock *, struct sk_buff *, u32);
-extern int tcp_fragment(struct sock *, struct sk_buff *, u32, unsigned int);
-
-extern void tcp_send_probe0(struct sock *);
-extern void tcp_send_partial(struct sock *);
-extern int tcp_write_wakeup(struct sock *);
-extern void tcp_send_fin(struct sock *sk);
-extern void tcp_send_active_reset(struct sock *sk, gfp_t priority);
-extern int tcp_send_synack(struct sock *);
-extern bool tcp_syn_flood_action(struct sock *sk,
-				 const struct sk_buff *skb,
-				 const char *proto);
-extern void tcp_push_one(struct sock *, unsigned int mss_now);
-extern void tcp_send_ack(struct sock *sk);
-extern void tcp_send_delayed_ack(struct sock *sk);
-extern void tcp_send_loss_probe(struct sock *sk);
-extern bool tcp_schedule_loss_probe(struct sock *sk);
+void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
+			       int nonagle);
+bool tcp_may_send_now(struct sock *sk);
+int __tcp_retransmit_skb(struct sock *, struct sk_buff *);
+int tcp_retransmit_skb(struct sock *, struct sk_buff *);
+void tcp_retransmit_timer(struct sock *sk);
+void tcp_xmit_retransmit_queue(struct sock *);
+void tcp_simple_retransmit(struct sock *);
+int tcp_trim_head(struct sock *, struct sk_buff *, u32);
+int tcp_fragment(struct sock *, struct sk_buff *, u32, unsigned int);
+
+void tcp_send_probe0(struct sock *);
+void tcp_send_partial(struct sock *);
+int tcp_write_wakeup(struct sock *);
+void tcp_send_fin(struct sock *sk);
+void tcp_send_active_reset(struct sock *sk, gfp_t priority);
+int tcp_send_synack(struct sock *);
+bool tcp_syn_flood_action(struct sock *sk, const struct sk_buff *skb,
+			  const char *proto);
+void tcp_push_one(struct sock *, unsigned int mss_now);
+void tcp_send_ack(struct sock *sk);
+void tcp_send_delayed_ack(struct sock *sk);
+void tcp_send_loss_probe(struct sock *sk);
+bool tcp_schedule_loss_probe(struct sock *sk);
 
 /* tcp_input.c */
-extern void tcp_cwnd_application_limited(struct sock *sk);
-extern void tcp_resume_early_retransmit(struct sock *sk);
-extern void tcp_rearm_rto(struct sock *sk);
-extern void tcp_reset(struct sock *sk);
+void tcp_cwnd_application_limited(struct sock *sk);
+void tcp_resume_early_retransmit(struct sock *sk);
+void tcp_rearm_rto(struct sock *sk);
+void tcp_reset(struct sock *sk);
 
 /* tcp_timer.c */
-extern void tcp_init_xmit_timers(struct sock *);
+void tcp_init_xmit_timers(struct sock *);
 static inline void tcp_clear_xmit_timers(struct sock *sk)
 {
 	inet_csk_clear_xmit_timers(sk);
 }
 
-extern unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu);
-extern unsigned int tcp_current_mss(struct sock *sk);
+unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu);
+unsigned int tcp_current_mss(struct sock *sk);
 
 /* Bound MSS / TSO packet size with the half of the window */
 static inline int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsize)
@@ -584,20 +581,20 @@ static inline int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsize)
 }
 
 /* tcp.c */
-extern void tcp_get_info(const struct sock *, struct tcp_info *);
+void tcp_get_info(const struct sock *, struct tcp_info *);
 
 /* Read 'sendfile()'-style from a TCP socket */
 typedef int (*sk_read_actor_t)(read_descriptor_t *, struct sk_buff *,
 				unsigned int, size_t);
-extern int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
-			 sk_read_actor_t recv_actor);
+int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
+		  sk_read_actor_t recv_actor);
 
-extern void tcp_initialize_rcv_mss(struct sock *sk);
+void tcp_initialize_rcv_mss(struct sock *sk);
 
-extern int tcp_mtu_to_mss(struct sock *sk, int pmtu);
-extern int tcp_mss_to_mtu(struct sock *sk, int mss);
-extern void tcp_mtup_init(struct sock *sk);
-extern void tcp_init_buffer_space(struct sock *sk);
+int tcp_mtu_to_mss(struct sock *sk, int pmtu);
+int tcp_mss_to_mtu(struct sock *sk, int mss);
+void tcp_mtup_init(struct sock *sk);
+void tcp_init_buffer_space(struct sock *sk);
 
 static inline void tcp_bound_rto(const struct sock *sk)
 {
@@ -610,7 +607,7 @@ static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
 	return (tp->srtt >> 3) + tp->rttvar;
 }
 
-extern void tcp_set_rto(struct sock *sk);
+void tcp_set_rto(struct sock *sk);
 
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
 {
@@ -663,7 +660,7 @@ static inline u32 tcp_receive_window(const struct tcp_sock *tp)
  * scaling applied to the result.  The caller does these things
  * if necessary.  This is a "raw" window selection.
  */
-extern u32 __tcp_select_window(struct sock *sk);
+u32 __tcp_select_window(struct sock *sk);
 
 void tcp_send_window_probe(struct sock *sk);
 
@@ -800,24 +797,24 @@ struct tcp_congestion_ops {
 	struct module 	*owner;
 };
 
-extern int tcp_register_congestion_control(struct tcp_congestion_ops *type);
-extern void tcp_unregister_congestion_control(struct tcp_congestion_ops *type);
+int tcp_register_congestion_control(struct tcp_congestion_ops *type);
+void tcp_unregister_congestion_control(struct tcp_congestion_ops *type);
 
-extern void tcp_init_congestion_control(struct sock *sk);
-extern void tcp_cleanup_congestion_control(struct sock *sk);
-extern int tcp_set_default_congestion_control(const char *name);
-extern void tcp_get_default_congestion_control(char *name);
-extern void tcp_get_available_congestion_control(char *buf, size_t len);
-extern void tcp_get_allowed_congestion_control(char *buf, size_t len);
-extern int tcp_set_allowed_congestion_control(char *allowed);
-extern int tcp_set_congestion_control(struct sock *sk, const char *name);
-extern void tcp_slow_start(struct tcp_sock *tp);
-extern void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w);
+void tcp_init_congestion_control(struct sock *sk);
+void tcp_cleanup_congestion_control(struct sock *sk);
+int tcp_set_default_congestion_control(const char *name);
+void tcp_get_default_congestion_control(char *name);
+void tcp_get_available_congestion_control(char *buf, size_t len);
+void tcp_get_allowed_congestion_control(char *buf, size_t len);
+int tcp_set_allowed_congestion_control(char *allowed);
+int tcp_set_congestion_control(struct sock *sk, const char *name);
+void tcp_slow_start(struct tcp_sock *tp);
+void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w);
 
 extern struct tcp_congestion_ops tcp_init_congestion_ops;
-extern u32 tcp_reno_ssthresh(struct sock *sk);
-extern void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 in_flight);
-extern u32 tcp_reno_min_cwnd(const struct sock *sk);
+u32 tcp_reno_ssthresh(struct sock *sk);
+void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 in_flight);
+u32 tcp_reno_min_cwnd(const struct sock *sk);
 extern struct tcp_congestion_ops tcp_reno;
 
 static inline void tcp_set_ca_state(struct sock *sk, const u8 ca_state)
@@ -936,8 +933,8 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 /* Use define here intentionally to get WARN_ON location shown at the caller */
 #define tcp_verify_left_out(tp)	WARN_ON(tcp_left_out(tp) > tp->packets_out)
 
-extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
-extern __u32 tcp_init_cwnd(const struct tcp_sock *tp, const struct dst_entry *dst);
+void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
+__u32 tcp_init_cwnd(const struct tcp_sock *tp, const struct dst_entry *dst);
 
 /* The maximum number of MSS of available cwnd for which TSO defers
  * sending if not using sysctl_tcp_tso_win_divisor.
@@ -963,7 +960,7 @@ static inline u32 tcp_wnd_end(const struct tcp_sock *tp)
 {
 	return tp->snd_una + tp->snd_wnd;
 }
-extern bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight);
+bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight);
 
 static inline void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss,
 				       const struct sk_buff *skb)
@@ -1028,7 +1025,7 @@ static inline void tcp_prequeue_init(struct tcp_sock *tp)
 #endif
 }
 
-extern bool tcp_prequeue(struct sock *sk, struct sk_buff *skb);
+bool tcp_prequeue(struct sock *sk, struct sk_buff *skb);
 
 #undef STATE_TRACE
 
@@ -1039,9 +1036,9 @@ static const char *statename[]={
 	"Close Wait","Last ACK","Listen","Closing"
 };
 #endif
-extern void tcp_set_state(struct sock *sk, int state);
+void tcp_set_state(struct sock *sk, int state);
 
-extern void tcp_done(struct sock *sk);
+void tcp_done(struct sock *sk);
 
 static inline void tcp_sack_reset(struct tcp_options_received *rx_opt)
 {
@@ -1049,13 +1046,12 @@ static inline void tcp_sack_reset(struct tcp_options_received *rx_opt)
 	rx_opt->num_sacks = 0;
 }
 
-extern u32 tcp_default_init_rwnd(u32 mss);
+u32 tcp_default_init_rwnd(u32 mss);
 
 /* Determine a window scaling and initial window to offer. */
-extern void tcp_select_initial_window(int __space, __u32 mss,
-				      __u32 *rcv_wnd, __u32 *window_clamp,
-				      int wscale_ok, __u8 *rcv_wscale,
-				      __u32 init_rcv_wnd);
+void tcp_select_initial_window(int __space, __u32 mss, __u32 *rcv_wnd,
+			       __u32 *window_clamp, int wscale_ok,
+			       __u8 *rcv_wscale, __u32 init_rcv_wnd);
 
 static inline int tcp_win_from_space(int space)
 {
@@ -1099,7 +1095,7 @@ static inline void tcp_openreq_init(struct request_sock *req,
 	ireq->loc_port = tcp_hdr(skb)->dest;
 }
 
-extern void tcp_enter_memory_pressure(struct sock *sk);
+void tcp_enter_memory_pressure(struct sock *sk);
 
 static inline int keepalive_intvl_when(const struct tcp_sock *tp)
 {
@@ -1252,21 +1248,20 @@ struct tcp_md5sig_pool {
 };
 
 /* - functions */
-extern int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
-			       const struct sock *sk,
-			       const struct request_sock *req,
-			       const struct sk_buff *skb);
-extern int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
-			  int family, const u8 *newkey,
-			  u8 newkeylen, gfp_t gfp);
-extern int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr,
-			  int family);
-extern struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
+int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
+			const struct sock *sk, const struct request_sock *req,
+			const struct sk_buff *skb);
+int tcp_md5_do_add(struct sock *sk, const union tcp_md5_addr *addr,
+		   int family, const u8 *newkey, u8 newkeylen, gfp_t gfp);
+int tcp_md5_do_del(struct sock *sk, const union tcp_md5_addr *addr,
+		   int family);
+struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
 					 struct sock *addr_sk);
 
 #ifdef CONFIG_TCP_MD5SIG
-extern struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
-			const union tcp_md5_addr *addr, int family);
+struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
+					 const union tcp_md5_addr *addr,
+					 int family);
 #define tcp_twsk_md5_key(twsk)	((twsk)->tw_md5_key)
 #else
 static inline struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
@@ -1278,27 +1273,26 @@ static inline struct tcp_md5sig_key *tcp_md5_do_lookup(struct sock *sk,
 #define tcp_twsk_md5_key(twsk)	NULL
 #endif
 
-extern bool tcp_alloc_md5sig_pool(void);
+bool tcp_alloc_md5sig_pool(void);
 
-extern struct tcp_md5sig_pool	*tcp_get_md5sig_pool(void);
+struct tcp_md5sig_pool *tcp_get_md5sig_pool(void);
 static inline void tcp_put_md5sig_pool(void)
 {
 	local_bh_enable();
 }
 
-extern int tcp_md5_hash_header(struct tcp_md5sig_pool *, const struct tcphdr *);
-extern int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, const struct sk_buff *,
-				 unsigned int header_len);
-extern int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
-			    const struct tcp_md5sig_key *key);
+int tcp_md5_hash_header(struct tcp_md5sig_pool *, const struct tcphdr *);
+int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *, const struct sk_buff *,
+			  unsigned int header_len);
+int tcp_md5_hash_key(struct tcp_md5sig_pool *hp,
+		     const struct tcp_md5sig_key *key);
 
 /* From tcp_fastopen.c */
-extern void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
-				   struct tcp_fastopen_cookie *cookie,
-				   int *syn_loss, unsigned long *last_syn_loss);
-extern void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
-				   struct tcp_fastopen_cookie *cookie,
-				   bool syn_lost);
+void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
+			    struct tcp_fastopen_cookie *cookie, int *syn_loss,
+			    unsigned long *last_syn_loss);
+void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
+			    struct tcp_fastopen_cookie *cookie, bool syn_lost);
 struct tcp_fastopen_request {
 	/* Fast Open cookie. Size 0 means a cookie request */
 	struct tcp_fastopen_cookie	cookie;
@@ -1309,8 +1303,8 @@ void tcp_free_fastopen_req(struct tcp_sock *tp);
 
 extern struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 int tcp_fastopen_reset_cipher(void *key, unsigned int len);
-extern void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
-				    struct tcp_fastopen_cookie *foc);
+void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
+			     struct tcp_fastopen_cookie *foc);
 
 #define TCP_FASTOPEN_KEY_LENGTH 16
 
@@ -1529,22 +1523,20 @@ struct tcp_iter_state {
 	loff_t			last_pos;
 };
 
-extern int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo);
-extern void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo);
+int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo);
+void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo);
 
 extern struct request_sock_ops tcp_request_sock_ops;
 extern struct request_sock_ops tcp6_request_sock_ops;
 
-extern void tcp_v4_destroy_sock(struct sock *sk);
+void tcp_v4_destroy_sock(struct sock *sk);
 
-extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
-				       netdev_features_t features);
-extern struct sk_buff **tcp_gro_receive(struct sk_buff **head,
-					struct sk_buff *skb);
-extern int tcp_gro_complete(struct sk_buff *skb);
+struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
+				netdev_features_t features);
+struct sk_buff **tcp_gro_receive(struct sk_buff **head, struct sk_buff *skb);
+int tcp_gro_complete(struct sk_buff *skb);
 
-extern void __tcp_v4_send_check(struct sk_buff *skb, __be32 saddr,
-				__be32 daddr);
+void __tcp_v4_send_check(struct sk_buff *skb, __be32 saddr, __be32 daddr);
 
 static inline u32 tcp_notsent_lowat(const struct tcp_sock *tp)
 {
@@ -1560,8 +1552,8 @@ static inline bool tcp_stream_memory_free(const struct sock *sk)
 }
 
 #ifdef CONFIG_PROC_FS
-extern int tcp4_proc_init(void);
-extern void tcp4_proc_exit(void);
+int tcp4_proc_init(void);
+void tcp4_proc_exit(void);
 #endif
 
 /* TCP af-specific functions */
@@ -1592,9 +1584,9 @@ struct tcp_request_sock_ops {
 #endif
 };
 
-extern int tcpv4_offload_init(void);
+int tcpv4_offload_init(void);
 
-extern void tcp_v4_init(void);
-extern void tcp_init(void);
+void tcp_v4_init(void);
+void tcp_init(void);
 
 #endif	/* _TCP_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
