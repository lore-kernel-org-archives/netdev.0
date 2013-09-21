From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/12] llc*.h: Remove extern from function prototypes
Date: Sat, 21 Sep 2013 10:22:45 -0700
Message-ID: <551881e2fdce29d82c00e317fb3fbab4eba680bc.1379783995.git.joe@perches.com>
References: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
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
 include/net/llc.h      |  50 ++++++------
 include/net/llc_c_ac.h | 190 ++++++++++++++++++++-------------------------
 include/net/llc_c_ev.h | 207 +++++++++++++++++++------------------------------
 include/net/llc_conn.h |  36 ++++-----
 include/net/llc_if.h   |   7 +-
 include/net/llc_pdu.h  |  33 ++++----
 include/net/llc_s_ac.h |  20 +++--
 include/net/llc_s_ev.h |  21 +++--
 include/net/llc_sap.h  |  22 +++---
 9 files changed, 253 insertions(+), 333 deletions(-)

diff --git a/include/net/llc.h b/include/net/llc.h
index 9e7d7f0..68490cb 100644
--- a/include/net/llc.h
+++ b/include/net/llc.h
@@ -95,29 +95,29 @@ struct hlist_nulls_head *llc_sk_laddr_hash(struct llc_sap *sap,
 extern struct list_head llc_sap_list;
 extern spinlock_t llc_sap_list_lock;
 
-extern int llc_rcv(struct sk_buff *skb, struct net_device *dev,
-		   struct packet_type *pt, struct net_device *orig_dev);
+int llc_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
+	    struct net_device *orig_dev);
 
-extern int llc_mac_hdr_init(struct sk_buff *skb,
-			    const unsigned char *sa, const unsigned char *da);
+int llc_mac_hdr_init(struct sk_buff *skb, const unsigned char *sa,
+		     const unsigned char *da);
 
-extern void llc_add_pack(int type, void (*handler)(struct llc_sap *sap,
-						   struct sk_buff *skb));
-extern void llc_remove_pack(int type);
+void llc_add_pack(int type,
+		  void (*handler)(struct llc_sap *sap, struct sk_buff *skb));
+void llc_remove_pack(int type);
 
-extern void llc_set_station_handler(void (*handler)(struct sk_buff *skb));
+void llc_set_station_handler(void (*handler)(struct sk_buff *skb));
 
-extern struct llc_sap *llc_sap_open(unsigned char lsap,
-				    int (*rcv)(struct sk_buff *skb,
-					       struct net_device *dev,
-					       struct packet_type *pt,
-					       struct net_device *orig_dev));
+struct llc_sap *llc_sap_open(unsigned char lsap,
+			     int (*rcv)(struct sk_buff *skb,
+					struct net_device *dev,
+					struct packet_type *pt,
+					struct net_device *orig_dev));
 static inline void llc_sap_hold(struct llc_sap *sap)
 {
 	atomic_inc(&sap->refcnt);
 }
 
-extern void llc_sap_close(struct llc_sap *sap);
+void llc_sap_close(struct llc_sap *sap);
 
 static inline void llc_sap_put(struct llc_sap *sap)
 {
@@ -125,27 +125,27 @@ static inline void llc_sap_put(struct llc_sap *sap)
 		llc_sap_close(sap);
 }
 
-extern struct llc_sap *llc_sap_find(unsigned char sap_value);
+struct llc_sap *llc_sap_find(unsigned char sap_value);
 
-extern int llc_build_and_send_ui_pkt(struct llc_sap *sap, struct sk_buff *skb,
-				     unsigned char *dmac, unsigned char dsap);
+int llc_build_and_send_ui_pkt(struct llc_sap *sap, struct sk_buff *skb,
+			      unsigned char *dmac, unsigned char dsap);
 
-extern void llc_sap_handler(struct llc_sap *sap, struct sk_buff *skb);
-extern void llc_conn_handler(struct llc_sap *sap, struct sk_buff *skb);
+void llc_sap_handler(struct llc_sap *sap, struct sk_buff *skb);
+void llc_conn_handler(struct llc_sap *sap, struct sk_buff *skb);
 
-extern void llc_station_init(void);
-extern void llc_station_exit(void);
+void llc_station_init(void);
+void llc_station_exit(void);
 
 #ifdef CONFIG_PROC_FS
-extern int llc_proc_init(void);
-extern void llc_proc_exit(void);
+int llc_proc_init(void);
+void llc_proc_exit(void);
 #else
 #define llc_proc_init()	(0)
 #define llc_proc_exit()	do { } while(0)
 #endif /* CONFIG_PROC_FS */
 #ifdef CONFIG_SYSCTL
-extern int llc_sysctl_init(void);
-extern void llc_sysctl_exit(void);
+int llc_sysctl_init(void);
+void llc_sysctl_exit(void);
 
 extern int sysctl_llc2_ack_timeout;
 extern int sysctl_llc2_busy_timeout;
diff --git a/include/net/llc_c_ac.h b/include/net/llc_c_ac.h
index df83f69..f3be818 100644
--- a/include/net/llc_c_ac.h
+++ b/include/net/llc_c_ac.h
@@ -89,114 +89,92 @@
 
 typedef int (*llc_conn_action_t)(struct sock *sk, struct sk_buff *skb);
 
-extern int llc_conn_ac_clear_remote_busy(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ac_conn_ind(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ac_conn_confirm(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_data_ind(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_disc_ind(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_rst_ind(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_rst_confirm(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_clear_remote_busy_if_f_eq_1(struct sock* sk,
-						   struct sk_buff *skb);
-extern int llc_conn_ac_stop_rej_tmr_if_data_flag_eq_2(struct sock* sk,
-						      struct sk_buff *skb);
-extern int llc_conn_ac_send_disc_cmd_p_set_x(struct sock* sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ac_send_dm_rsp_f_set_p(struct sock* sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ac_send_dm_rsp_f_set_1(struct sock* sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ac_send_frmr_rsp_f_set_x(struct sock* sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ac_resend_frmr_rsp_f_set_0(struct sock* sk,
-					       struct sk_buff *skb);
-extern int llc_conn_ac_resend_frmr_rsp_f_set_p(struct sock* sk,
-					       struct sk_buff *skb);
-extern int llc_conn_ac_send_i_cmd_p_set_1(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_send_i_xxx_x_set_0(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_resend_i_xxx_x_set_0(struct sock* sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ac_resend_i_xxx_x_set_0_or_send_rr(struct sock* sk,
-						       struct sk_buff *skb);
-extern int llc_conn_ac_resend_i_rsp_f_set_1(struct sock* sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ac_send_rej_cmd_p_set_1(struct sock* sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ac_send_rej_rsp_f_set_1(struct sock* sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ac_send_rej_xxx_x_set_0(struct sock* sk,
+int llc_conn_ac_clear_remote_busy(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_conn_ind(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_conn_confirm(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_data_ind(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_disc_ind(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_rst_ind(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_rst_confirm(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_clear_remote_busy_if_f_eq_1(struct sock *sk,
 					    struct sk_buff *skb);
-extern int llc_conn_ac_send_rnr_cmd_p_set_1(struct sock* sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ac_send_rnr_rsp_f_set_1(struct sock* sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ac_send_rnr_xxx_x_set_0(struct sock* sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ac_set_remote_busy(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_opt_send_rnr_xxx_x_set_0(struct sock* sk,
+int llc_conn_ac_stop_rej_tmr_if_data_flag_eq_2(struct sock *sk,
+					       struct sk_buff *skb);
+int llc_conn_ac_send_disc_cmd_p_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_dm_rsp_f_set_p(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_dm_rsp_f_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_frmr_rsp_f_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_resend_frmr_rsp_f_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_resend_frmr_rsp_f_set_p(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_i_cmd_p_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_i_xxx_x_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_resend_i_xxx_x_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_resend_i_xxx_x_set_0_or_send_rr(struct sock *sk,
 						struct sk_buff *skb);
-extern int llc_conn_ac_send_rr_cmd_p_set_1(struct sock* sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ac_send_rr_rsp_f_set_1(struct sock* sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ac_send_ack_rsp_f_set_1(struct sock* sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ac_send_rr_xxx_x_set_0(struct sock* sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ac_send_ack_xxx_x_set_0(struct sock* sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ac_send_sabme_cmd_p_set_x(struct sock* sk,
-					      struct sk_buff *skb);
-extern int llc_conn_ac_send_ua_rsp_f_set_p(struct sock* sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ac_set_s_flag_0(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_s_flag_1(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_start_p_timer(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_start_ack_timer(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_start_rej_timer(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_start_ack_tmr_if_not_running(struct sock* sk,
-						    struct sk_buff *skb);
-extern int llc_conn_ac_stop_ack_timer(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_stop_p_timer(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_stop_rej_timer(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_stop_all_timers(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_stop_other_timers(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_upd_nr_received(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_inc_tx_win_size(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_dec_tx_win_size(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_upd_p_flag(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_data_flag_2(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_data_flag_0(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_data_flag_1(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_data_flag_1_if_data_flag_eq_0(struct sock* sk,
-							 struct sk_buff *skb);
-extern int llc_conn_ac_set_p_flag_0(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_remote_busy_0(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_retry_cnt_0(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_cause_flag_0(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_cause_flag_1(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_inc_retry_cnt_by_1(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_vr_0(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_inc_vr_by_1(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_vs_0(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_set_vs_nr(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_rst_vs(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_upd_vs(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_disc(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_reset(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_disc_confirm(struct sock* sk, struct sk_buff *skb);
-extern u8 llc_circular_between(u8 a, u8 b, u8 c);
-extern int llc_conn_ac_send_ack_if_needed(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_adjust_npta_by_rr(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_adjust_npta_by_rnr(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_rst_sendack_flag(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_send_i_rsp_as_ack(struct sock* sk, struct sk_buff *skb);
-extern int llc_conn_ac_send_i_as_ack(struct sock* sk, struct sk_buff *skb);
+int llc_conn_ac_resend_i_rsp_f_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_rej_cmd_p_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_rej_rsp_f_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_rej_xxx_x_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_rnr_cmd_p_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_rnr_rsp_f_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_rnr_xxx_x_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_remote_busy(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_opt_send_rnr_xxx_x_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_rr_cmd_p_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_rr_rsp_f_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_ack_rsp_f_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_rr_xxx_x_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_ack_xxx_x_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_sabme_cmd_p_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_ua_rsp_f_set_p(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_s_flag_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_s_flag_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_start_p_timer(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_start_ack_timer(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_start_rej_timer(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_start_ack_tmr_if_not_running(struct sock *sk,
+					     struct sk_buff *skb);
+int llc_conn_ac_stop_ack_timer(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_stop_p_timer(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_stop_rej_timer(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_stop_all_timers(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_stop_other_timers(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_upd_nr_received(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_inc_tx_win_size(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_dec_tx_win_size(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_upd_p_flag(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_data_flag_2(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_data_flag_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_data_flag_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_data_flag_1_if_data_flag_eq_0(struct sock *sk,
+						  struct sk_buff *skb);
+int llc_conn_ac_set_p_flag_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_remote_busy_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_retry_cnt_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_cause_flag_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_cause_flag_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_inc_retry_cnt_by_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_vr_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_inc_vr_by_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_vs_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_set_vs_nr(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_rst_vs(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_upd_vs(struct sock *sk, struct sk_buff *skb);
+int llc_conn_disc(struct sock *sk, struct sk_buff *skb);
+int llc_conn_reset(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_disc_confirm(struct sock *sk, struct sk_buff *skb);
+u8 llc_circular_between(u8 a, u8 b, u8 c);
+int llc_conn_ac_send_ack_if_needed(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_adjust_npta_by_rr(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_adjust_npta_by_rnr(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_rst_sendack_flag(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_i_rsp_as_ack(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ac_send_i_as_ack(struct sock *sk, struct sk_buff *skb);
 
-extern void llc_conn_busy_tmr_cb(unsigned long timeout_data);
-extern void llc_conn_pf_cycle_tmr_cb(unsigned long timeout_data);
-extern void llc_conn_ack_tmr_cb(unsigned long timeout_data);
-extern void llc_conn_rej_tmr_cb(unsigned long timeout_data);
+void llc_conn_busy_tmr_cb(unsigned long timeout_data);
+void llc_conn_pf_cycle_tmr_cb(unsigned long timeout_data);
+void llc_conn_ack_tmr_cb(unsigned long timeout_data);
+void llc_conn_rej_tmr_cb(unsigned long timeout_data);
 
-extern void llc_conn_set_p_flag(struct sock *sk, u8 value);
+void llc_conn_set_p_flag(struct sock *sk, u8 value);
 #endif /* LLC_C_AC_H */
diff --git a/include/net/llc_c_ev.h b/include/net/llc_c_ev.h
index 6ca3113..3948cf1 100644
--- a/include/net/llc_c_ev.h
+++ b/include/net/llc_c_ev.h
@@ -128,138 +128,93 @@ static __inline__ struct llc_conn_state_ev *llc_conn_ev(struct sk_buff *skb)
 typedef int (*llc_conn_ev_t)(struct sock *sk, struct sk_buff *skb);
 typedef int (*llc_conn_ev_qfyr_t)(struct sock *sk, struct sk_buff *skb);
 
-extern int llc_conn_ev_conn_req(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_data_req(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_disc_req(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_rst_req(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_local_busy_detected(struct sock *sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ev_local_busy_cleared(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_rx_bad_pdu(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_rx_disc_cmd_pbit_set_x(struct sock *sk,
+int llc_conn_ev_conn_req(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_data_req(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_disc_req(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rst_req(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_local_busy_detected(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_local_busy_cleared(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_bad_pdu(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_disc_cmd_pbit_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_dm_rsp_fbit_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_frmr_rsp_fbit_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_i_cmd_pbit_set_x_inval_ns(struct sock *sk,
+					     struct sk_buff *skb);
+int llc_conn_ev_rx_i_rsp_fbit_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_i_rsp_fbit_set_x_unexpd_ns(struct sock *sk,
 					      struct sk_buff *skb);
-extern int llc_conn_ev_rx_dm_rsp_fbit_set_x(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_rx_frmr_rsp_fbit_set_x(struct sock *sk,
-					      struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_cmd_pbit_set_x_inval_ns(struct sock *sk,
-						    struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_rsp_fbit_set_x(struct sock *sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_rsp_fbit_set_x_unexpd_ns(struct sock *sk,
-						  struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_rsp_fbit_set_x_inval_ns(struct sock *sk,
-						  struct sk_buff *skb);
-extern int llc_conn_ev_rx_rej_rsp_fbit_set_x(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_sabme_cmd_pbit_set_x(struct sock *sk,
+int llc_conn_ev_rx_i_rsp_fbit_set_x_inval_ns(struct sock *sk,
+					     struct sk_buff *skb);
+int llc_conn_ev_rx_rej_rsp_fbit_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_sabme_cmd_pbit_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_ua_rsp_fbit_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_xxx_cmd_pbit_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_xxx_rsp_fbit_set_x(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_zzz_cmd_pbit_set_x_inval_nr(struct sock *sk,
 					       struct sk_buff *skb);
-extern int llc_conn_ev_rx_ua_rsp_fbit_set_x(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_rx_xxx_cmd_pbit_set_x(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_xxx_rsp_fbit_set_x(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_zzz_cmd_pbit_set_x_inval_nr(struct sock *sk,
-						      struct sk_buff *skb);
-extern int llc_conn_ev_rx_zzz_rsp_fbit_set_x_inval_nr(struct sock *sk,
-						      struct sk_buff *skb);
-extern int llc_conn_ev_p_tmr_exp(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_ack_tmr_exp(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_rej_tmr_exp(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_busy_tmr_exp(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_sendack_tmr_exp(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_zzz_rsp_fbit_set_x_inval_nr(struct sock *sk,
+					       struct sk_buff *skb);
+int llc_conn_ev_p_tmr_exp(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_ack_tmr_exp(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rej_tmr_exp(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_busy_tmr_exp(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_sendack_tmr_exp(struct sock *sk, struct sk_buff *skb);
 /* NOT_USED functions and their variations */
-extern int llc_conn_ev_rx_xxx_cmd_pbit_set_1(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_xxx_rsp_fbit_set_1(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_cmd_pbit_set_0_unexpd_ns(struct sock *sk,
-						  struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_cmd_pbit_set_1_unexpd_ns(struct sock *sk,
-						  struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_cmd_pbit_set_0(struct sock *sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_cmd_pbit_set_1(struct sock *sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_rsp_fbit_set_0_unexpd_ns(struct sock *sk,
-						  struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_rsp_fbit_set_1_unexpd_ns(struct sock *sk,
-						  struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_rsp_fbit_set_0(struct sock *sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ev_rx_i_rsp_fbit_set_1(struct sock *sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ev_rx_rr_cmd_pbit_set_0(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_rx_rr_cmd_pbit_set_1(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_rx_rr_rsp_fbit_set_0(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_rx_rr_rsp_fbit_set_1(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_rx_rnr_cmd_pbit_set_0(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_rnr_cmd_pbit_set_1(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_rnr_rsp_fbit_set_0(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_rnr_rsp_fbit_set_1(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_rej_cmd_pbit_set_0(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_rej_cmd_pbit_set_1(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_rej_rsp_fbit_set_0(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_rej_rsp_fbit_set_1(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_rx_any_frame(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_tx_buffer_full(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_init_p_f_cycle(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_xxx_cmd_pbit_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_xxx_rsp_fbit_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_i_cmd_pbit_set_0_unexpd_ns(struct sock *sk,
+					      struct sk_buff *skb);
+int llc_conn_ev_rx_i_cmd_pbit_set_1_unexpd_ns(struct sock *sk,
+					      struct sk_buff *skb);
+int llc_conn_ev_rx_i_cmd_pbit_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_i_cmd_pbit_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_i_rsp_fbit_set_0_unexpd_ns(struct sock *sk,
+					      struct sk_buff *skb);
+int llc_conn_ev_rx_i_rsp_fbit_set_1_unexpd_ns(struct sock *sk,
+					      struct sk_buff *skb);
+int llc_conn_ev_rx_i_rsp_fbit_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_i_rsp_fbit_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rr_cmd_pbit_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rr_cmd_pbit_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rr_rsp_fbit_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rr_rsp_fbit_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rnr_cmd_pbit_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rnr_cmd_pbit_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rnr_rsp_fbit_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rnr_rsp_fbit_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rej_cmd_pbit_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rej_cmd_pbit_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rej_rsp_fbit_set_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_rej_rsp_fbit_set_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_rx_any_frame(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_tx_buffer_full(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_init_p_f_cycle(struct sock *sk, struct sk_buff *skb);
 
 /* Available connection action qualifiers */
-extern int llc_conn_ev_qlfy_data_flag_eq_1(struct sock *sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_data_flag_eq_0(struct sock *sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_data_flag_eq_2(struct sock *sk,
-					   struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_p_flag_eq_1(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_last_frame_eq_1(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_last_frame_eq_0(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_p_flag_eq_0(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_p_flag_eq_f(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_remote_busy_eq_0(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_remote_busy_eq_1(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_retry_cnt_lt_n2(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_retry_cnt_gte_n2(struct sock *sk,
-					     struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_s_flag_eq_1(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_s_flag_eq_0(struct sock *sk, struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_cause_flag_eq_1(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_cause_flag_eq_0(struct sock *sk,
+int llc_conn_ev_qlfy_data_flag_eq_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_data_flag_eq_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_data_flag_eq_2(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_p_flag_eq_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_last_frame_eq_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_last_frame_eq_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_p_flag_eq_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_p_flag_eq_f(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_remote_busy_eq_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_remote_busy_eq_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_retry_cnt_lt_n2(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_retry_cnt_gte_n2(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_s_flag_eq_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_s_flag_eq_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_cause_flag_eq_1(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_cause_flag_eq_0(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_set_status_conn(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_set_status_disc(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_set_status_failed(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_set_status_remote_busy(struct sock *sk,
 					    struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_set_status_conn(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_set_status_disc(struct sock *sk,
-					    struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_set_status_failed(struct sock *sk,
-					      struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_set_status_remote_busy(struct sock *sk,
-						  struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_set_status_refuse(struct sock *sk,
-					      struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_set_status_conflict(struct sock *sk,
-						struct sk_buff *skb);
-extern int llc_conn_ev_qlfy_set_status_rst_done(struct sock *sk,
-						struct sk_buff *skb);
+int llc_conn_ev_qlfy_set_status_refuse(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_set_status_conflict(struct sock *sk, struct sk_buff *skb);
+int llc_conn_ev_qlfy_set_status_rst_done(struct sock *sk, struct sk_buff *skb);
 
 static __inline__ int llc_conn_space(struct sock *sk, struct sk_buff *skb)
 {
diff --git a/include/net/llc_conn.h b/include/net/llc_conn.h
index 2f97d8d..0134681 100644
--- a/include/net/llc_conn.h
+++ b/include/net/llc_conn.h
@@ -95,28 +95,24 @@ static __inline__ char llc_backlog_type(struct sk_buff *skb)
 	return skb->cb[sizeof(skb->cb) - 1];
 }
 
-extern struct sock *llc_sk_alloc(struct net *net, int family, gfp_t priority,
-				 struct proto *prot);
-extern void llc_sk_free(struct sock *sk);
+struct sock *llc_sk_alloc(struct net *net, int family, gfp_t priority,
+			  struct proto *prot);
+void llc_sk_free(struct sock *sk);
 
-extern void llc_sk_reset(struct sock *sk);
+void llc_sk_reset(struct sock *sk);
 
 /* Access to a connection */
-extern int llc_conn_state_process(struct sock *sk, struct sk_buff *skb);
-extern void llc_conn_send_pdu(struct sock *sk, struct sk_buff *skb);
-extern void llc_conn_rtn_pdu(struct sock *sk, struct sk_buff *skb);
-extern void llc_conn_resend_i_pdu_as_cmd(struct sock *sk, u8 nr,
-					 u8 first_p_bit);
-extern void llc_conn_resend_i_pdu_as_rsp(struct sock *sk, u8 nr,
-					 u8 first_f_bit);
-extern int llc_conn_remove_acked_pdus(struct sock *conn, u8 nr,
-				      u16 *how_many_unacked);
-extern struct sock *llc_lookup_established(struct llc_sap *sap,
-					   struct llc_addr *daddr,
-					   struct llc_addr *laddr);
-extern void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk);
-extern void llc_sap_remove_socket(struct llc_sap *sap, struct sock *sk);
+int llc_conn_state_process(struct sock *sk, struct sk_buff *skb);
+void llc_conn_send_pdu(struct sock *sk, struct sk_buff *skb);
+void llc_conn_rtn_pdu(struct sock *sk, struct sk_buff *skb);
+void llc_conn_resend_i_pdu_as_cmd(struct sock *sk, u8 nr, u8 first_p_bit);
+void llc_conn_resend_i_pdu_as_rsp(struct sock *sk, u8 nr, u8 first_f_bit);
+int llc_conn_remove_acked_pdus(struct sock *conn, u8 nr, u16 *how_many_unacked);
+struct sock *llc_lookup_established(struct llc_sap *sap, struct llc_addr *daddr,
+				    struct llc_addr *laddr);
+void llc_sap_add_socket(struct llc_sap *sap, struct sock *sk);
+void llc_sap_remove_socket(struct llc_sap *sap, struct sock *sk);
 
-extern u8 llc_data_accept_state(u8 state);
-extern void llc_build_offset_table(void);
+u8 llc_data_accept_state(u8 state);
+void llc_build_offset_table(void);
 #endif /* LLC_CONN_H */
diff --git a/include/net/llc_if.h b/include/net/llc_if.h
index f0cb909..8d5c543 100644
--- a/include/net/llc_if.h
+++ b/include/net/llc_if.h
@@ -62,8 +62,7 @@
 #define LLC_STATUS_CONFLICT	7 /* disconnect conn */
 #define LLC_STATUS_RESET_DONE	8 /*  */
 
-extern int llc_establish_connection(struct sock *sk, u8 *lmac,
-				    u8 *dmac, u8 dsap);
-extern int llc_build_and_send_pkt(struct sock *sk, struct sk_buff *skb);
-extern int llc_send_disc(struct sock *sk);
+int llc_establish_connection(struct sock *sk, u8 *lmac, u8 *dmac, u8 dsap);
+int llc_build_and_send_pkt(struct sock *sk, struct sk_buff *skb);
+int llc_send_disc(struct sock *sk);
 #endif /* LLC_IF_H */
diff --git a/include/net/llc_pdu.h b/include/net/llc_pdu.h
index 5a93d13..31e2de7 100644
--- a/include/net/llc_pdu.h
+++ b/include/net/llc_pdu.h
@@ -410,21 +410,20 @@ struct llc_frmr_info {
 	u8  ind_bits;		/* indicator bits set with macro */
 } __packed;
 
-extern void llc_pdu_set_cmd_rsp(struct sk_buff *skb, u8 type);
-extern void llc_pdu_set_pf_bit(struct sk_buff *skb, u8 bit_value);
-extern void llc_pdu_decode_pf_bit(struct sk_buff *skb, u8 *pf_bit);
-extern void llc_pdu_init_as_disc_cmd(struct sk_buff *skb, u8 p_bit);
-extern void llc_pdu_init_as_i_cmd(struct sk_buff *skb, u8 p_bit, u8 ns, u8 nr);
-extern void llc_pdu_init_as_rej_cmd(struct sk_buff *skb, u8 p_bit, u8 nr);
-extern void llc_pdu_init_as_rnr_cmd(struct sk_buff *skb, u8 p_bit, u8 nr);
-extern void llc_pdu_init_as_rr_cmd(struct sk_buff *skb, u8 p_bit, u8 nr);
-extern void llc_pdu_init_as_sabme_cmd(struct sk_buff *skb, u8 p_bit);
-extern void llc_pdu_init_as_dm_rsp(struct sk_buff *skb, u8 f_bit);
-extern void llc_pdu_init_as_frmr_rsp(struct sk_buff *skb,
-				     struct llc_pdu_sn *prev_pdu,
-				     u8 f_bit, u8 vs, u8 vr, u8 vzyxw);
-extern void llc_pdu_init_as_rr_rsp(struct sk_buff *skb, u8 f_bit, u8 nr);
-extern void llc_pdu_init_as_rej_rsp(struct sk_buff *skb, u8 f_bit, u8 nr);
-extern void llc_pdu_init_as_rnr_rsp(struct sk_buff *skb, u8 f_bit, u8 nr);
-extern void llc_pdu_init_as_ua_rsp(struct sk_buff *skb, u8 f_bit);
+void llc_pdu_set_cmd_rsp(struct sk_buff *skb, u8 type);
+void llc_pdu_set_pf_bit(struct sk_buff *skb, u8 bit_value);
+void llc_pdu_decode_pf_bit(struct sk_buff *skb, u8 *pf_bit);
+void llc_pdu_init_as_disc_cmd(struct sk_buff *skb, u8 p_bit);
+void llc_pdu_init_as_i_cmd(struct sk_buff *skb, u8 p_bit, u8 ns, u8 nr);
+void llc_pdu_init_as_rej_cmd(struct sk_buff *skb, u8 p_bit, u8 nr);
+void llc_pdu_init_as_rnr_cmd(struct sk_buff *skb, u8 p_bit, u8 nr);
+void llc_pdu_init_as_rr_cmd(struct sk_buff *skb, u8 p_bit, u8 nr);
+void llc_pdu_init_as_sabme_cmd(struct sk_buff *skb, u8 p_bit);
+void llc_pdu_init_as_dm_rsp(struct sk_buff *skb, u8 f_bit);
+void llc_pdu_init_as_frmr_rsp(struct sk_buff *skb, struct llc_pdu_sn *prev_pdu,
+			      u8 f_bit, u8 vs, u8 vr, u8 vzyxw);
+void llc_pdu_init_as_rr_rsp(struct sk_buff *skb, u8 f_bit, u8 nr);
+void llc_pdu_init_as_rej_rsp(struct sk_buff *skb, u8 f_bit, u8 nr);
+void llc_pdu_init_as_rnr_rsp(struct sk_buff *skb, u8 f_bit, u8 nr);
+void llc_pdu_init_as_ua_rsp(struct sk_buff *skb, u8 f_bit);
 #endif /* LLC_PDU_H */
diff --git a/include/net/llc_s_ac.h b/include/net/llc_s_ac.h
index 37a3bbd..a61b98c 100644
--- a/include/net/llc_s_ac.h
+++ b/include/net/llc_s_ac.h
@@ -25,15 +25,13 @@
 /* All action functions must look like this */
 typedef int (*llc_sap_action_t)(struct llc_sap *sap, struct sk_buff *skb);
 
-extern int llc_sap_action_unitdata_ind(struct llc_sap *sap,
-				       struct sk_buff *skb);
-extern int llc_sap_action_send_ui(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_action_send_xid_c(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_action_send_xid_r(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_action_send_test_c(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_action_send_test_r(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_action_report_status(struct llc_sap *sap,
-					struct sk_buff *skb);
-extern int llc_sap_action_xid_ind(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_action_test_ind(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_action_unitdata_ind(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_action_send_ui(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_action_send_xid_c(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_action_send_xid_r(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_action_send_test_c(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_action_send_test_r(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_action_report_status(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_action_xid_ind(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_action_test_ind(struct llc_sap *sap, struct sk_buff *skb);
 #endif /* LLC_S_AC_H */
diff --git a/include/net/llc_s_ev.h b/include/net/llc_s_ev.h
index e3acb93..84db3a5 100644
--- a/include/net/llc_s_ev.h
+++ b/include/net/llc_s_ev.h
@@ -53,15 +53,14 @@ struct llc_sap;
 
 typedef int (*llc_sap_ev_t)(struct llc_sap *sap, struct sk_buff *skb);
 
-extern int llc_sap_ev_activation_req(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_ev_rx_ui(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_ev_unitdata_req(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_ev_xid_req(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_ev_rx_xid_c(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_ev_rx_xid_r(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_ev_test_req(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_ev_rx_test_c(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_ev_rx_test_r(struct llc_sap *sap, struct sk_buff *skb);
-extern int llc_sap_ev_deactivation_req(struct llc_sap *sap,
-				       struct sk_buff *skb);
+int llc_sap_ev_activation_req(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_ev_rx_ui(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_ev_unitdata_req(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_ev_xid_req(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_ev_rx_xid_c(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_ev_rx_xid_r(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_ev_test_req(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_ev_rx_test_c(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_ev_rx_test_r(struct llc_sap *sap, struct sk_buff *skb);
+int llc_sap_ev_deactivation_req(struct llc_sap *sap, struct sk_buff *skb);
 #endif /* LLC_S_EV_H */
diff --git a/include/net/llc_sap.h b/include/net/llc_sap.h
index ed25bec..1e4df9f 100644
--- a/include/net/llc_sap.h
+++ b/include/net/llc_sap.h
@@ -19,18 +19,14 @@ struct net_device;
 struct sk_buff;
 struct sock;
 
-extern void llc_sap_rtn_pdu(struct llc_sap *sap, struct sk_buff *skb);
-extern void llc_save_primitive(struct sock *sk, struct sk_buff* skb,
-			       unsigned char prim);
-extern struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev,
-				       u8 type, u32 data_size);
+void llc_sap_rtn_pdu(struct llc_sap *sap, struct sk_buff *skb);
+void llc_save_primitive(struct sock *sk, struct sk_buff *skb,
+			unsigned char prim);
+struct sk_buff *llc_alloc_frame(struct sock *sk, struct net_device *dev,
+				u8 type, u32 data_size);
 
-extern void llc_build_and_send_test_pkt(struct llc_sap *sap,
-				        struct sk_buff *skb,
-					unsigned char *dmac,
-					unsigned char dsap);
-extern void llc_build_and_send_xid_pkt(struct llc_sap *sap,
-				       struct sk_buff *skb,
-				       unsigned char *dmac,
-				       unsigned char dsap);
+void llc_build_and_send_test_pkt(struct llc_sap *sap, struct sk_buff *skb,
+				 unsigned char *dmac, unsigned char dsap);
+void llc_build_and_send_xid_pkt(struct llc_sap *sap, struct sk_buff *skb,
+				unsigned char *dmac, unsigned char dsap);
 #endif /* LLC_SAP_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
