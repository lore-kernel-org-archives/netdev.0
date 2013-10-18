From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/4] net: dccp: Remove extern from function prototypes
Date: Fri, 18 Oct 2013 13:48:23 -0700
Message-ID: <f86fc8d077282f9c331c971196ceb6b65ebcd134.1382129045.git.joe@perches.com>
References: <cover.1382129045.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1382129045.git.joe@perches.com>
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
 net/dccp/ackvec.h                   |  21 ++--
 net/dccp/ccid.h                     |  18 ++--
 net/dccp/ccids/lib/loss_interval.h  |   8 +-
 net/dccp/ccids/lib/packet_history.h |  25 +++--
 net/dccp/ccids/lib/tfrc.h           |  22 ++---
 net/dccp/dccp.h                     | 186 +++++++++++++++++-------------------
 net/dccp/feat.h                     |  26 ++---
 7 files changed, 148 insertions(+), 158 deletions(-)

diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index a269aa7..3284bfa 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -101,16 +101,16 @@ struct dccp_ackvec_record {
 	u8		 avr_ack_nonce:1;
 };
 
-extern int dccp_ackvec_init(void);
-extern void dccp_ackvec_exit(void);
+int dccp_ackvec_init(void);
+void dccp_ackvec_exit(void);
 
-extern struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority);
-extern void dccp_ackvec_free(struct dccp_ackvec *av);
+struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority);
+void dccp_ackvec_free(struct dccp_ackvec *av);
 
-extern void dccp_ackvec_input(struct dccp_ackvec *av, struct sk_buff *skb);
-extern int  dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
-extern void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno);
-extern u16  dccp_ackvec_buflen(const struct dccp_ackvec *av);
+void dccp_ackvec_input(struct dccp_ackvec *av, struct sk_buff *skb);
+int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
+void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno);
+u16 dccp_ackvec_buflen(const struct dccp_ackvec *av);
 
 static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
 {
@@ -133,7 +133,6 @@ struct dccp_ackvec_parsed {
 	struct list_head node;
 };
 
-extern int dccp_ackvec_parsed_add(struct list_head *head,
-				  u8 *vec, u8 len, u8 nonce);
-extern void dccp_ackvec_parsed_cleanup(struct list_head *parsed_chunks);
+int dccp_ackvec_parsed_add(struct list_head *head, u8 *vec, u8 len, u8 nonce);
+void dccp_ackvec_parsed_cleanup(struct list_head *parsed_chunks);
 #endif /* _ACKVEC_H */
diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index fb85d37..6eb837a 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -93,8 +93,8 @@ extern struct ccid_operations ccid2_ops;
 extern struct ccid_operations ccid3_ops;
 #endif
 
-extern int  ccid_initialize_builtins(void);
-extern void ccid_cleanup_builtins(void);
+int ccid_initialize_builtins(void);
+void ccid_cleanup_builtins(void);
 
 struct ccid {
 	struct ccid_operations *ccid_ops;
@@ -106,12 +106,12 @@ static inline void *ccid_priv(const struct ccid *ccid)
 	return (void *)ccid->ccid_priv;
 }
 
-extern bool ccid_support_check(u8 const *ccid_array, u8 array_len);
-extern int  ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len);
-extern int  ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
-					  char __user *, int __user *);
+bool ccid_support_check(u8 const *ccid_array, u8 array_len);
+int ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len);
+int ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
+				  char __user *, int __user *);
 
-extern struct ccid *ccid_new(const u8 id, struct sock *sk, bool rx);
+struct ccid *ccid_new(const u8 id, struct sock *sk, bool rx);
 
 static inline int ccid_get_current_rx_ccid(struct dccp_sock *dp)
 {
@@ -131,8 +131,8 @@ static inline int ccid_get_current_tx_ccid(struct dccp_sock *dp)
 	return ccid->ccid_ops->ccid_id;
 }
 
-extern void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk);
-extern void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk);
+void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk);
+void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk);
 
 /*
  * Congestion control of queued data packets via CCID decision.
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index d1d2f53..57f631a 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -65,9 +65,9 @@ static inline u8 tfrc_lh_length(struct tfrc_loss_hist *lh)
 
 struct tfrc_rx_hist;
 
-extern int  tfrc_lh_interval_add(struct tfrc_loss_hist *, struct tfrc_rx_hist *,
-				 u32 (*first_li)(struct sock *), struct sock *);
-extern u8   tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *);
-extern void tfrc_lh_cleanup(struct tfrc_loss_hist *lh);
+int tfrc_lh_interval_add(struct tfrc_loss_hist *, struct tfrc_rx_hist *,
+			 u32 (*first_li)(struct sock *), struct sock *);
+u8 tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *);
+void tfrc_lh_cleanup(struct tfrc_loss_hist *lh);
 
 #endif /* _DCCP_LI_HIST_ */
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 7ee4a9d..ee362b0 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -60,8 +60,8 @@ static inline struct tfrc_tx_hist_entry *
 	return head;
 }
 
-extern int  tfrc_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno);
-extern void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp);
+int tfrc_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno);
+void tfrc_tx_hist_purge(struct tfrc_tx_hist_entry **headp);
 
 /* Subtraction a-b modulo-16, respects circular wrap-around */
 #define SUB16(a, b) (((a) + 16 - (b)) & 0xF)
@@ -139,20 +139,17 @@ static inline bool tfrc_rx_hist_loss_pending(const struct tfrc_rx_hist *h)
 	return h->loss_count > 0;
 }
 
-extern void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
-				    const struct sk_buff *skb, const u64 ndp);
+void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h, const struct sk_buff *skb,
+			     const u64 ndp);
 
-extern int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb);
+int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb);
 
 struct tfrc_loss_hist;
-extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
-				struct tfrc_loss_hist *lh,
-				struct sk_buff *skb, const u64 ndp,
-				u32 (*first_li)(struct sock *sk),
-				struct sock *sk);
-extern u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h,
-				   const struct sk_buff *skb);
-extern int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h);
-extern void tfrc_rx_hist_purge(struct tfrc_rx_hist *h);
+int tfrc_rx_handle_loss(struct tfrc_rx_hist *h, struct tfrc_loss_hist *lh,
+			struct sk_buff *skb, const u64 ndp,
+			u32 (*first_li)(struct sock *sk), struct sock *sk);
+u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h, const struct sk_buff *skb);
+int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h);
+void tfrc_rx_hist_purge(struct tfrc_rx_hist *h);
 
 #endif /* _DCCP_PKT_HIST_ */
diff --git a/net/dccp/ccids/lib/tfrc.h b/net/dccp/ccids/lib/tfrc.h
index ed698c4..40ee7d6 100644
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -55,21 +55,21 @@ static inline u32 tfrc_ewma(const u32 avg, const u32 newval, const u8 weight)
 	return avg ? (weight * avg + (10 - weight) * newval) / 10 : newval;
 }
 
-extern u32  tfrc_calc_x(u16 s, u32 R, u32 p);
-extern u32  tfrc_calc_x_reverse_lookup(u32 fvalue);
-extern u32  tfrc_invert_loss_event_rate(u32 loss_event_rate);
+u32 tfrc_calc_x(u16 s, u32 R, u32 p);
+u32 tfrc_calc_x_reverse_lookup(u32 fvalue);
+u32 tfrc_invert_loss_event_rate(u32 loss_event_rate);
 
-extern int  tfrc_tx_packet_history_init(void);
-extern void tfrc_tx_packet_history_exit(void);
-extern int  tfrc_rx_packet_history_init(void);
-extern void tfrc_rx_packet_history_exit(void);
+int tfrc_tx_packet_history_init(void);
+void tfrc_tx_packet_history_exit(void);
+int tfrc_rx_packet_history_init(void);
+void tfrc_rx_packet_history_exit(void);
 
-extern int  tfrc_li_init(void);
-extern void tfrc_li_exit(void);
+int tfrc_li_init(void);
+void tfrc_li_exit(void);
 
 #ifdef CONFIG_IP_DCCP_TFRC_LIB
-extern int  tfrc_lib_init(void);
-extern void tfrc_lib_exit(void);
+int tfrc_lib_init(void);
+void tfrc_lib_exit(void);
 #else
 #define tfrc_lib_init() (0)
 #define tfrc_lib_exit()
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 708e75b..3094878 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -53,7 +53,7 @@ extern struct inet_hashinfo dccp_hashinfo;
 
 extern struct percpu_counter dccp_orphan_count;
 
-extern void dccp_time_wait(struct sock *sk, int state, int timeo);
+void dccp_time_wait(struct sock *sk, int state, int timeo);
 
 /*
  *  Set safe upper bounds for header and option length. Since Data Offset is 8
@@ -224,114 +224,108 @@ static inline void dccp_csum_outgoing(struct sk_buff *skb)
 	skb->csum = skb_checksum(skb, 0, (cov > skb->len)? skb->len : cov, 0);
 }
 
-extern void dccp_v4_send_check(struct sock *sk, struct sk_buff *skb);
+void dccp_v4_send_check(struct sock *sk, struct sk_buff *skb);
 
-extern int  dccp_retransmit_skb(struct sock *sk);
+int dccp_retransmit_skb(struct sock *sk);
 
-extern void dccp_send_ack(struct sock *sk);
-extern void dccp_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
-				struct request_sock *rsk);
+void dccp_send_ack(struct sock *sk);
+void dccp_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
+			 struct request_sock *rsk);
 
-extern void dccp_send_sync(struct sock *sk, const u64 seq,
-			   const enum dccp_pkt_type pkt_type);
+void dccp_send_sync(struct sock *sk, const u64 seq,
+		    const enum dccp_pkt_type pkt_type);
 
 /*
  * TX Packet Dequeueing Interface
  */
-extern void		dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb);
-extern bool		dccp_qpolicy_full(struct sock *sk);
-extern void		dccp_qpolicy_drop(struct sock *sk, struct sk_buff *skb);
-extern struct sk_buff	*dccp_qpolicy_top(struct sock *sk);
-extern struct sk_buff	*dccp_qpolicy_pop(struct sock *sk);
-extern bool		dccp_qpolicy_param_ok(struct sock *sk, __be32 param);
+void dccp_qpolicy_push(struct sock *sk, struct sk_buff *skb);
+bool dccp_qpolicy_full(struct sock *sk);
+void dccp_qpolicy_drop(struct sock *sk, struct sk_buff *skb);
+struct sk_buff *dccp_qpolicy_top(struct sock *sk);
+struct sk_buff *dccp_qpolicy_pop(struct sock *sk);
+bool dccp_qpolicy_param_ok(struct sock *sk, __be32 param);
 
 /*
  * TX Packet Output and TX Timers
  */
-extern void   dccp_write_xmit(struct sock *sk);
-extern void   dccp_write_space(struct sock *sk);
-extern void   dccp_flush_write_queue(struct sock *sk, long *time_budget);
+void dccp_write_xmit(struct sock *sk);
+void dccp_write_space(struct sock *sk);
+void dccp_flush_write_queue(struct sock *sk, long *time_budget);
 
-extern void dccp_init_xmit_timers(struct sock *sk);
+void dccp_init_xmit_timers(struct sock *sk);
 static inline void dccp_clear_xmit_timers(struct sock *sk)
 {
 	inet_csk_clear_xmit_timers(sk);
 }
 
-extern unsigned int dccp_sync_mss(struct sock *sk, u32 pmtu);
+unsigned int dccp_sync_mss(struct sock *sk, u32 pmtu);
 
-extern const char *dccp_packet_name(const int type);
+const char *dccp_packet_name(const int type);
 
-extern void dccp_set_state(struct sock *sk, const int state);
-extern void dccp_done(struct sock *sk);
+void dccp_set_state(struct sock *sk, const int state);
+void dccp_done(struct sock *sk);
 
-extern int  dccp_reqsk_init(struct request_sock *rq, struct dccp_sock const *dp,
-			    struct sk_buff const *skb);
+int dccp_reqsk_init(struct request_sock *rq, struct dccp_sock const *dp,
+		    struct sk_buff const *skb);
 
-extern int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
+int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
 
-extern struct sock *dccp_create_openreq_child(struct sock *sk,
-					      const struct request_sock *req,
-					      const struct sk_buff *skb);
+struct sock *dccp_create_openreq_child(struct sock *sk,
+				       const struct request_sock *req,
+				       const struct sk_buff *skb);
 
-extern int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
+int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
 
-extern struct sock *dccp_v4_request_recv_sock(struct sock *sk,
-					      struct sk_buff *skb,
-					      struct request_sock *req,
-					      struct dst_entry *dst);
-extern struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
-				   struct request_sock *req,
-				   struct request_sock **prev);
+struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
+				       struct request_sock *req,
+				       struct dst_entry *dst);
+struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
+			    struct request_sock *req,
+			    struct request_sock **prev);
 
-extern int dccp_child_process(struct sock *parent, struct sock *child,
-			      struct sk_buff *skb);
-extern int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-				  struct dccp_hdr *dh, unsigned int len);
-extern int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
-				const struct dccp_hdr *dh, const unsigned int len);
+int dccp_child_process(struct sock *parent, struct sock *child,
+		       struct sk_buff *skb);
+int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
+			   struct dccp_hdr *dh, unsigned int len);
+int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
+			 const struct dccp_hdr *dh, const unsigned int len);
 
-extern int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized);
-extern void dccp_destroy_sock(struct sock *sk);
+int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized);
+void dccp_destroy_sock(struct sock *sk);
 
-extern void		dccp_close(struct sock *sk, long timeout);
-extern struct sk_buff	*dccp_make_response(struct sock *sk,
-					    struct dst_entry *dst,
-					    struct request_sock *req);
+void dccp_close(struct sock *sk, long timeout);
+struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
+				   struct request_sock *req);
 
-extern int	   dccp_connect(struct sock *sk);
-extern int	   dccp_disconnect(struct sock *sk, int flags);
-extern int	   dccp_getsockopt(struct sock *sk, int level, int optname,
-				   char __user *optval, int __user *optlen);
-extern int	   dccp_setsockopt(struct sock *sk, int level, int optname,
-				   char __user *optval, unsigned int optlen);
+int dccp_connect(struct sock *sk);
+int dccp_disconnect(struct sock *sk, int flags);
+int dccp_getsockopt(struct sock *sk, int level, int optname,
+		    char __user *optval, int __user *optlen);
+int dccp_setsockopt(struct sock *sk, int level, int optname,
+		    char __user *optval, unsigned int optlen);
 #ifdef CONFIG_COMPAT
-extern int	   compat_dccp_getsockopt(struct sock *sk,
-				int level, int optname,
-				char __user *optval, int __user *optlen);
-extern int	   compat_dccp_setsockopt(struct sock *sk,
-				int level, int optname,
-				char __user *optval, unsigned int optlen);
+int compat_dccp_getsockopt(struct sock *sk, int level, int optname,
+			   char __user *optval, int __user *optlen);
+int compat_dccp_setsockopt(struct sock *sk, int level, int optname,
+			   char __user *optval, unsigned int optlen);
 #endif
-extern int	   dccp_ioctl(struct sock *sk, int cmd, unsigned long arg);
-extern int	   dccp_sendmsg(struct kiocb *iocb, struct sock *sk,
-				struct msghdr *msg, size_t size);
-extern int	   dccp_recvmsg(struct kiocb *iocb, struct sock *sk,
-				struct msghdr *msg, size_t len, int nonblock,
-				int flags, int *addr_len);
-extern void	   dccp_shutdown(struct sock *sk, int how);
-extern int	   inet_dccp_listen(struct socket *sock, int backlog);
-extern unsigned int dccp_poll(struct file *file, struct socket *sock,
-			     poll_table *wait);
-extern int	   dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr,
-				   int addr_len);
-
-extern struct sk_buff *dccp_ctl_make_reset(struct sock *sk,
-					   struct sk_buff *skb);
-extern int	   dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
-extern void	   dccp_send_close(struct sock *sk, const int active);
-extern int	   dccp_invalid_packet(struct sk_buff *skb);
-extern u32	   dccp_sample_rtt(struct sock *sk, long delta);
+int dccp_ioctl(struct sock *sk, int cmd, unsigned long arg);
+int dccp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		 size_t size);
+int dccp_recvmsg(struct kiocb *iocb, struct sock *sk,
+		 struct msghdr *msg, size_t len, int nonblock, int flags,
+		 int *addr_len);
+void dccp_shutdown(struct sock *sk, int how);
+int inet_dccp_listen(struct socket *sock, int backlog);
+unsigned int dccp_poll(struct file *file, struct socket *sock,
+		       poll_table *wait);
+int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
+
+struct sk_buff *dccp_ctl_make_reset(struct sock *sk, struct sk_buff *skb);
+int dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
+void dccp_send_close(struct sock *sk, const int active);
+int dccp_invalid_packet(struct sk_buff *skb);
+u32 dccp_sample_rtt(struct sock *sk, long delta);
 
 static inline int dccp_bad_service_code(const struct sock *sk,
 					const __be32 service)
@@ -475,25 +469,25 @@ static inline int dccp_ack_pending(const struct sock *sk)
 	return dccp_ackvec_pending(sk) || inet_csk_ack_scheduled(sk);
 }
 
-extern int  dccp_feat_signal_nn_change(struct sock *sk, u8 feat, u64 nn_val);
-extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
-extern int  dccp_feat_server_ccid_dependencies(struct dccp_request_sock *dreq);
-extern int  dccp_feat_insert_opts(struct dccp_sock*, struct dccp_request_sock*,
-				  struct sk_buff *skb);
-extern int  dccp_feat_activate_values(struct sock *sk, struct list_head *fn);
-extern void dccp_feat_list_purge(struct list_head *fn_list);
-
-extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
-extern int dccp_insert_options_rsk(struct dccp_request_sock*, struct sk_buff*);
-extern int dccp_insert_option_elapsed_time(struct sk_buff *skb, u32 elapsed);
-extern u32 dccp_timestamp(void);
-extern void dccp_timestamping_init(void);
-extern int dccp_insert_option(struct sk_buff *skb, unsigned char option,
-			      const void *value, unsigned char len);
+int dccp_feat_signal_nn_change(struct sock *sk, u8 feat, u64 nn_val);
+int dccp_feat_finalise_settings(struct dccp_sock *dp);
+int dccp_feat_server_ccid_dependencies(struct dccp_request_sock *dreq);
+int dccp_feat_insert_opts(struct dccp_sock*, struct dccp_request_sock*,
+			  struct sk_buff *skb);
+int dccp_feat_activate_values(struct sock *sk, struct list_head *fn);
+void dccp_feat_list_purge(struct list_head *fn_list);
+
+int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
+int dccp_insert_options_rsk(struct dccp_request_sock *, struct sk_buff *);
+int dccp_insert_option_elapsed_time(struct sk_buff *skb, u32 elapsed);
+u32 dccp_timestamp(void);
+void dccp_timestamping_init(void);
+int dccp_insert_option(struct sk_buff *skb, unsigned char option,
+		       const void *value, unsigned char len);
 
 #ifdef CONFIG_SYSCTL
-extern int dccp_sysctl_init(void);
-extern void dccp_sysctl_exit(void);
+int dccp_sysctl_init(void);
+void dccp_sysctl_exit(void);
 #else
 static inline int dccp_sysctl_init(void)
 {
diff --git a/net/dccp/feat.h b/net/dccp/feat.h
index 90b957d..0e75ceb 100644
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -107,13 +107,13 @@ extern unsigned long sysctl_dccp_sequence_window;
 extern int	     sysctl_dccp_rx_ccid;
 extern int	     sysctl_dccp_tx_ccid;
 
-extern int  dccp_feat_init(struct sock *sk);
-extern void dccp_feat_initialise_sysctls(void);
-extern int  dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
-				  u8 const *list, u8 len);
-extern int  dccp_feat_parse_options(struct sock *, struct dccp_request_sock *,
-				    u8 mand, u8 opt, u8 feat, u8 *val, u8 len);
-extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
+int dccp_feat_init(struct sock *sk);
+void dccp_feat_initialise_sysctls(void);
+int dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
+			  u8 const *list, u8 len);
+int dccp_feat_parse_options(struct sock *, struct dccp_request_sock *,
+			    u8 mand, u8 opt, u8 feat, u8 *val, u8 len);
+int dccp_feat_clone_list(struct list_head const *, struct list_head *);
 
 /*
  * Encoding variable-length options and their maximum length.
@@ -127,11 +127,11 @@ extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
  */
 #define DCCP_OPTVAL_MAXLEN	6
 
-extern void dccp_encode_value_var(const u64 value, u8 *to, const u8 len);
-extern u64  dccp_decode_value_var(const u8 *bf, const u8 len);
-extern u64  dccp_feat_nn_get(struct sock *sk, u8 feat);
+void dccp_encode_value_var(const u64 value, u8 *to, const u8 len);
+u64 dccp_decode_value_var(const u8 *bf, const u8 len);
+u64 dccp_feat_nn_get(struct sock *sk, u8 feat);
 
-extern int  dccp_insert_option_mandatory(struct sk_buff *skb);
-extern int  dccp_insert_fn_opt(struct sk_buff *skb, u8 type, u8 feat,
-			       u8 *val, u8 len, bool repeat_first);
+int dccp_insert_option_mandatory(struct sk_buff *skb);
+int dccp_insert_fn_opt(struct sk_buff *skb, u8 type, u8 feat, u8 *val, u8 len,
+		       bool repeat_first);
 #endif /* _DCCP_FEAT_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
