From: Joe Perches <joe@perches.com>
Subject: [PATCH] llc: Make function pointer arrays const
Date: Wed, 10 Dec 2014 08:18:50 -0800
Message-ID: <1418228330.18092.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's better when function pointer arrays aren't modifiable.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/llc_c_st.h |   2 +-
 net/llc/llc_c_st.c     | 470 ++++++++++++++++++++++++-------------------------
 net/llc/llc_conn.c     |   2 +-
 3 files changed, 237 insertions(+), 237 deletions(-)

diff --git a/include/net/llc_c_st.h b/include/net/llc_c_st.h
index 0e79cfb..60e2ebb 100644
--- a/include/net/llc_c_st.h
+++ b/include/net/llc_c_st.h
@@ -36,7 +36,7 @@ struct llc_conn_state_trans {
 	llc_conn_ev_t	   ev;
 	u8		   next_state;
 	llc_conn_ev_qfyr_t *ev_qualifiers;
-	llc_conn_action_t  *ev_actions;
+	const llc_conn_action_t  *ev_actions;
 };
 
 struct llc_conn_state {
diff --git a/net/llc/llc_c_st.c b/net/llc/llc_c_st.c
index 818a942..3ae257d 100644
--- a/net/llc/llc_c_st.c
+++ b/net/llc/llc_c_st.c
@@ -33,7 +33,7 @@
  * LLC_CONN_STATE_AWAIT_REJ states
  */
 /* State transitions for LLC_CONN_EV_DISC_REQ event */
-static llc_conn_action_t llc_common_actions_1[] = {
+static const llc_conn_action_t llc_common_actions_1[] = {
 	[0] = llc_conn_ac_send_disc_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -50,7 +50,7 @@ static struct llc_conn_state_trans llc_common_state_trans_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_RESET_REQ event */
-static llc_conn_action_t llc_common_actions_2[] = {
+static const llc_conn_action_t llc_common_actions_2[] = {
 	[0] = llc_conn_ac_send_sabme_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -67,7 +67,7 @@ static struct llc_conn_state_trans llc_common_state_trans_2 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_SABME_CMD_Pbit_SET_X event */
-static llc_conn_action_t llc_common_actions_3[] = {
+static const llc_conn_action_t llc_common_actions_3[] = {
 	[0] = llc_conn_ac_stop_all_timers,
 	[1] = llc_conn_ac_set_vs_0,
 	[2] = llc_conn_ac_set_vr_0,
@@ -87,7 +87,7 @@ static struct llc_conn_state_trans llc_common_state_trans_3 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_DISC_CMD_Pbit_SET_X event */
-static llc_conn_action_t llc_common_actions_4[] = {
+static const llc_conn_action_t llc_common_actions_4[] = {
 	[0] = llc_conn_ac_stop_all_timers,
 	[1] = llc_conn_ac_send_ua_rsp_f_set_p,
 	[2] = llc_conn_ac_disc_ind,
@@ -103,7 +103,7 @@ static struct llc_conn_state_trans llc_common_state_trans_4 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_FRMR_RSP_Fbit_SET_X event */
-static llc_conn_action_t llc_common_actions_5[] = {
+static const llc_conn_action_t llc_common_actions_5[] = {
 	[0] = llc_conn_ac_send_sabme_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -122,7 +122,7 @@ static struct llc_conn_state_trans llc_common_state_trans_5 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_DM_RSP_Fbit_SET_X event */
-static llc_conn_action_t llc_common_actions_6[] = {
+static const llc_conn_action_t llc_common_actions_6[] = {
 	[0] = llc_conn_ac_disc_ind,
 	[1] = llc_conn_ac_stop_all_timers,
 	[2] = llc_conn_disc,
@@ -137,7 +137,7 @@ static struct llc_conn_state_trans llc_common_state_trans_6 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_ZZZ_CMD_Pbit_SET_X_INVAL_Nr event */
-static llc_conn_action_t llc_common_actions_7a[] = {
+static const llc_conn_action_t llc_common_actions_7a[] = {
 	[0] = llc_conn_ac_send_frmr_rsp_f_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -153,7 +153,7 @@ static struct llc_conn_state_trans llc_common_state_trans_7a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_X_INVAL_Ns event */
-static llc_conn_action_t llc_common_actions_7b[] = {
+static const llc_conn_action_t llc_common_actions_7b[] = {
 	[0] = llc_conn_ac_send_frmr_rsp_f_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -169,7 +169,7 @@ static struct llc_conn_state_trans llc_common_state_trans_7b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_ZZZ_RSP_Fbit_SET_X_INVAL_Nr event */
-static llc_conn_action_t llc_common_actions_8a[] = {
+static const llc_conn_action_t llc_common_actions_8a[] = {
 	[0] = llc_conn_ac_send_frmr_rsp_f_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -185,7 +185,7 @@ static struct llc_conn_state_trans llc_common_state_trans_8a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_X_INVAL_Ns event */
-static llc_conn_action_t llc_common_actions_8b[] = {
+static const llc_conn_action_t llc_common_actions_8b[] = {
 	[0] = llc_conn_ac_send_frmr_rsp_f_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -201,7 +201,7 @@ static struct llc_conn_state_trans llc_common_state_trans_8b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_BAD_PDU event */
-static llc_conn_action_t llc_common_actions_8c[] = {
+static const llc_conn_action_t llc_common_actions_8c[] = {
 	[0] = llc_conn_ac_send_frmr_rsp_f_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -217,7 +217,7 @@ static struct llc_conn_state_trans llc_common_state_trans_8c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_UA_RSP_Fbit_SET_X event */
-static llc_conn_action_t llc_common_actions_9[] = {
+static const llc_conn_action_t llc_common_actions_9[] = {
 	[0] = llc_conn_ac_send_frmr_rsp_f_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -239,7 +239,7 @@ static llc_conn_ev_qfyr_t llc_common_ev_qfyrs_10[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_common_actions_10[] = {
+static const llc_conn_action_t llc_common_actions_10[] = {
 	[0] = llc_conn_ac_send_frmr_rsp_f_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -261,7 +261,7 @@ static llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_common_actions_11a[] = {
+static const llc_conn_action_t llc_common_actions_11a[] = {
 	[0] = llc_conn_ac_send_sabme_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -283,7 +283,7 @@ static llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_common_actions_11b[] = {
+static const llc_conn_action_t llc_common_actions_11b[] = {
 	[0] = llc_conn_ac_send_sabme_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -305,7 +305,7 @@ static llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11c[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_common_actions_11c[] = {
+static const llc_conn_action_t llc_common_actions_11c[] = {
 	[0] = llc_conn_ac_send_sabme_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -327,7 +327,7 @@ static llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11d[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_common_actions_11d[] = {
+static const llc_conn_action_t llc_common_actions_11d[] = {
 	[0] = llc_conn_ac_send_sabme_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_stop_other_timers,
@@ -351,7 +351,7 @@ static struct llc_conn_state_trans llc_common_state_trans_end;
 
 /* LLC_CONN_STATE_ADM transitions */
 /* State transitions for LLC_CONN_EV_CONN_REQ event */
-static llc_conn_action_t llc_adm_actions_1[] = {
+static const llc_conn_action_t llc_adm_actions_1[] = {
 	[0] = llc_conn_ac_send_sabme_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_set_retry_cnt_0,
@@ -367,7 +367,7 @@ static struct llc_conn_state_trans llc_adm_state_trans_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_SABME_CMD_Pbit_SET_X event */
-static llc_conn_action_t llc_adm_actions_2[] = {
+static const llc_conn_action_t llc_adm_actions_2[] = {
 	[0] = llc_conn_ac_send_ua_rsp_f_set_p,
 	[1] = llc_conn_ac_set_vs_0,
 	[2] = llc_conn_ac_set_vr_0,
@@ -386,7 +386,7 @@ static struct llc_conn_state_trans llc_adm_state_trans_2 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_DISC_CMD_Pbit_SET_X event */
-static llc_conn_action_t llc_adm_actions_3[] = {
+static const llc_conn_action_t llc_adm_actions_3[] = {
 	[0] = llc_conn_ac_send_dm_rsp_f_set_p,
 	[1] = llc_conn_disc,
 	[2] = NULL,
@@ -400,7 +400,7 @@ static struct llc_conn_state_trans llc_adm_state_trans_3 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_XXX_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_adm_actions_4[] = {
+static const llc_conn_action_t llc_adm_actions_4[] = {
 	[0] = llc_conn_ac_send_dm_rsp_f_set_1,
 	[1] = llc_conn_disc,
 	[2] = NULL,
@@ -414,7 +414,7 @@ static struct llc_conn_state_trans llc_adm_state_trans_4 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_XXX_YYY event */
-static llc_conn_action_t llc_adm_actions_5[] = {
+static const llc_conn_action_t llc_adm_actions_5[] = {
 	[0] = llc_conn_disc,
 	[1] = NULL,
 };
@@ -445,7 +445,7 @@ static struct llc_conn_state_trans *llc_adm_state_transitions[] = {
 
 /* LLC_CONN_STATE_SETUP transitions */
 /* State transitions for LLC_CONN_EV_RX_SABME_CMD_Pbit_SET_X event */
-static llc_conn_action_t llc_setup_actions_1[] = {
+static const llc_conn_action_t llc_setup_actions_1[] = {
 	[0] = llc_conn_ac_send_ua_rsp_f_set_p,
 	[1] = llc_conn_ac_set_vs_0,
 	[2] = llc_conn_ac_set_vr_0,
@@ -467,7 +467,7 @@ static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_2[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_setup_actions_2[] = {
+static const llc_conn_action_t llc_setup_actions_2[] = {
 	[0] = llc_conn_ac_stop_ack_timer,
 	[1] = llc_conn_ac_set_vs_0,
 	[2] = llc_conn_ac_set_vr_0,
@@ -491,7 +491,7 @@ static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_3[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_setup_actions_3[] = {
+static const llc_conn_action_t llc_setup_actions_3[] = {
 	[0] = llc_conn_ac_set_p_flag_0,
 	[1] = llc_conn_ac_set_remote_busy_0,
 	[2] = llc_conn_ac_conn_confirm,
@@ -511,7 +511,7 @@ static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_4[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_setup_actions_4[] = {
+static const llc_conn_action_t llc_setup_actions_4[] = {
 	[0] = llc_conn_ac_send_dm_rsp_f_set_p,
 	[1] = llc_conn_ac_stop_ack_timer,
 	[2] = llc_conn_ac_conn_confirm,
@@ -532,7 +532,7 @@ static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_5[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_setup_actions_5[] = {
+static const llc_conn_action_t llc_setup_actions_5[] = {
 	[0] = llc_conn_ac_stop_ack_timer,
 	[1] = llc_conn_ac_conn_confirm,
 	[2] = llc_conn_disc,
@@ -553,7 +553,7 @@ static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_7[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_setup_actions_7[] = {
+static const llc_conn_action_t llc_setup_actions_7[] = {
 	[0] = llc_conn_ac_send_sabme_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_inc_retry_cnt_by_1,
@@ -575,7 +575,7 @@ static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_8[] = {
 	[3] = NULL,
 };
 
-static llc_conn_action_t llc_setup_actions_8[] = {
+static const llc_conn_action_t llc_setup_actions_8[] = {
 	[0] = llc_conn_ac_conn_confirm,
 	[1] = llc_conn_disc,
 	[2] = NULL,
@@ -616,7 +616,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_1[] = {
 	[3] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_1[] = {
+static const llc_conn_action_t llc_normal_actions_1[] = {
 	[0] = llc_conn_ac_send_i_as_ack,
 	[1] = llc_conn_ac_start_ack_tmr_if_not_running,
 	[2] = NULL,
@@ -637,7 +637,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_2[] = {
 	[3] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_2[] = {
+static const llc_conn_action_t llc_normal_actions_2[] = {
 	[0] = llc_conn_ac_send_i_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = NULL,
@@ -658,7 +658,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_2_1[] = {
 };
 
 /* just one member, NULL, .bss zeroes it */
-static llc_conn_action_t llc_normal_actions_2_1[1];
+static const llc_conn_action_t llc_normal_actions_2_1[1];
 
 static struct llc_conn_state_trans llc_normal_state_trans_2_1 = {
 	.ev	       = llc_conn_ev_data_req,
@@ -673,7 +673,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_3[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_3[] = {
+static const llc_conn_action_t llc_normal_actions_3[] = {
 	[0] = llc_conn_ac_rst_sendack_flag,
 	[1] = llc_conn_ac_send_rnr_xxx_x_set_0,
 	[2] = llc_conn_ac_set_data_flag_0,
@@ -693,7 +693,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_4[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_4[] = {
+static const llc_conn_action_t llc_normal_actions_4[] = {
 	[0] = llc_conn_ac_rst_sendack_flag,
 	[1] = llc_conn_ac_send_rnr_xxx_x_set_0,
 	[2] = llc_conn_ac_set_data_flag_0,
@@ -713,7 +713,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_5a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_5a[] = {
+static const llc_conn_action_t llc_normal_actions_5a[] = {
 	[0] = llc_conn_ac_rst_sendack_flag,
 	[1] = llc_conn_ac_send_rej_xxx_x_set_0,
 	[2] = llc_conn_ac_upd_nr_received,
@@ -736,7 +736,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_5b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_5b[] = {
+static const llc_conn_action_t llc_normal_actions_5b[] = {
 	[0] = llc_conn_ac_rst_sendack_flag,
 	[1] = llc_conn_ac_send_rej_xxx_x_set_0,
 	[2] = llc_conn_ac_upd_nr_received,
@@ -759,7 +759,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_5c[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_5c[] = {
+static const llc_conn_action_t llc_normal_actions_5c[] = {
 	[0] = llc_conn_ac_rst_sendack_flag,
 	[1] = llc_conn_ac_send_rej_xxx_x_set_0,
 	[2] = llc_conn_ac_upd_nr_received,
@@ -782,7 +782,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_6a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_6a[] = {
+static const llc_conn_action_t llc_normal_actions_6a[] = {
 	[0] = llc_conn_ac_rst_sendack_flag,
 	[1] = llc_conn_ac_send_rej_xxx_x_set_0,
 	[2] = llc_conn_ac_upd_nr_received,
@@ -803,7 +803,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_6b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_6b[] = {
+static const llc_conn_action_t llc_normal_actions_6b[] = {
 	[0] = llc_conn_ac_rst_sendack_flag,
 	[1] = llc_conn_ac_send_rej_xxx_x_set_0,
 	[2] = llc_conn_ac_upd_nr_received,
@@ -819,7 +819,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_6b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1_UNEXPD_Ns event */
-static llc_conn_action_t llc_normal_actions_7[] = {
+static const llc_conn_action_t llc_normal_actions_7[] = {
 	[0] = llc_conn_ac_rst_sendack_flag,
 	[1] = llc_conn_ac_send_rej_rsp_f_set_1,
 	[2] = llc_conn_ac_upd_nr_received,
@@ -840,7 +840,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_8a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_8[] = {
+static const llc_conn_action_t llc_normal_actions_8[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_upd_p_flag,
@@ -876,7 +876,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_9a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_9a[] = {
+static const llc_conn_action_t llc_normal_actions_9a[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_data_ind,
@@ -897,7 +897,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_9b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_9b[] = {
+static const llc_conn_action_t llc_normal_actions_9b[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_data_ind,
@@ -913,7 +913,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_9b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_normal_actions_10[] = {
+static const llc_conn_action_t llc_normal_actions_10[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_send_ack_rsp_f_set_1,
 	[2] = llc_conn_ac_rst_sendack_flag,
@@ -930,7 +930,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_10 = {
 };
 
 /* State transitions for * LLC_CONN_EV_RX_RR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_normal_actions_11a[] = {
+static const llc_conn_action_t llc_normal_actions_11a[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -945,7 +945,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_11a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_normal_actions_11b[] = {
+static const llc_conn_action_t llc_normal_actions_11b[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -965,7 +965,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_11c[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_11c[] = {
+static const llc_conn_action_t llc_normal_actions_11c[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_inc_tx_win_size,
@@ -981,7 +981,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_11c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_normal_actions_12[] = {
+static const llc_conn_action_t llc_normal_actions_12[] = {
 	[0] = llc_conn_ac_send_ack_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_adjust_npta_by_rr,
@@ -998,7 +998,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_12 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_normal_actions_13a[] = {
+static const llc_conn_action_t llc_normal_actions_13a[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -1013,7 +1013,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_13a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_normal_actions_13b[] = {
+static const llc_conn_action_t llc_normal_actions_13b[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -1033,7 +1033,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_13c[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_13c[] = {
+static const llc_conn_action_t llc_normal_actions_13c[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -1048,7 +1048,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_13c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_normal_actions_14[] = {
+static const llc_conn_action_t llc_normal_actions_14[] = {
 	[0] = llc_conn_ac_send_rr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_adjust_npta_by_rnr,
@@ -1070,7 +1070,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_15a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_15a[] = {
+static const llc_conn_action_t llc_normal_actions_15a[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_p_flag,
@@ -1093,7 +1093,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_15b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_15b[] = {
+static const llc_conn_action_t llc_normal_actions_15b[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_p_flag,
@@ -1116,7 +1116,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_16a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_16a[] = {
+static const llc_conn_action_t llc_normal_actions_16a[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_dec_tx_win_size,
@@ -1138,7 +1138,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_16b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_16b[] = {
+static const llc_conn_action_t llc_normal_actions_16b[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_dec_tx_win_size,
@@ -1155,7 +1155,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_16b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_normal_actions_17[] = {
+static const llc_conn_action_t llc_normal_actions_17[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_dec_tx_win_size,
@@ -1177,7 +1177,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_18[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_18[] = {
+static const llc_conn_action_t llc_normal_actions_18[] = {
 	[0] = llc_conn_ac_send_rr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = NULL,
@@ -1196,7 +1196,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_19[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_19[] = {
+static const llc_conn_action_t llc_normal_actions_19[] = {
 	[0] = llc_conn_ac_rst_sendack_flag,
 	[1] = llc_conn_ac_send_rr_cmd_p_set_1,
 	[2] = llc_conn_ac_rst_vs,
@@ -1219,7 +1219,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_20a[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_20a[] = {
+static const llc_conn_action_t llc_normal_actions_20a[] = {
 	[0] = llc_conn_ac_rst_sendack_flag,
 	[1] = llc_conn_ac_send_rr_cmd_p_set_1,
 	[2] = llc_conn_ac_rst_vs,
@@ -1242,7 +1242,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_20b[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_20b[] = {
+static const llc_conn_action_t llc_normal_actions_20b[] = {
 	[0] = llc_conn_ac_rst_sendack_flag,
 	[1] = llc_conn_ac_send_rr_cmd_p_set_1,
 	[2] = llc_conn_ac_rst_vs,
@@ -1264,7 +1264,7 @@ static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_21[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_normal_actions_21[] = {
+static const llc_conn_action_t llc_normal_actions_21[] = {
 	[0] = llc_conn_ac_send_rr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = NULL,
@@ -1348,7 +1348,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_1[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_1[] = {
+static const llc_conn_action_t llc_busy_actions_1[] = {
 	[0] = llc_conn_ac_send_i_xxx_x_set_0,
 	[1] = llc_conn_ac_start_ack_tmr_if_not_running,
 	[2] = NULL,
@@ -1368,7 +1368,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_2[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_2[] = {
+static const llc_conn_action_t llc_busy_actions_2[] = {
 	[0] = llc_conn_ac_send_i_xxx_x_set_0,
 	[1] = llc_conn_ac_start_ack_tmr_if_not_running,
 	[2] = NULL,
@@ -1389,7 +1389,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_2_1[] = {
 };
 
 /* just one member, NULL, .bss zeroes it */
-static llc_conn_action_t llc_busy_actions_2_1[1];
+static const llc_conn_action_t llc_busy_actions_2_1[1];
 
 static struct llc_conn_state_trans llc_busy_state_trans_2_1 = {
 	.ev	       = llc_conn_ev_data_req,
@@ -1405,7 +1405,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_3[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_3[] = {
+static const llc_conn_action_t llc_busy_actions_3[] = {
 	[0] = llc_conn_ac_send_rej_xxx_x_set_0,
 	[1] = llc_conn_ac_start_rej_timer,
 	[2] = NULL,
@@ -1425,7 +1425,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_4[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_4[] = {
+static const llc_conn_action_t llc_busy_actions_4[] = {
 	[0] = llc_conn_ac_send_rej_xxx_x_set_0,
 	[1] = llc_conn_ac_start_rej_timer,
 	[2] = NULL,
@@ -1445,7 +1445,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_5[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_5[] = {
+static const llc_conn_action_t llc_busy_actions_5[] = {
 	[0] = llc_conn_ac_send_rr_xxx_x_set_0,
 	[1] = NULL,
 };
@@ -1464,7 +1464,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_6[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_6[] = {
+static const llc_conn_action_t llc_busy_actions_6[] = {
 	[0] = llc_conn_ac_send_rr_xxx_x_set_0,
 	[1] = NULL,
 };
@@ -1483,7 +1483,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_7[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_7[] = {
+static const llc_conn_action_t llc_busy_actions_7[] = {
 	[0] = llc_conn_ac_send_rr_xxx_x_set_0,
 	[1] = NULL,
 };
@@ -1502,7 +1502,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_8[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_8[] = {
+static const llc_conn_action_t llc_busy_actions_8[] = {
 	[0] = llc_conn_ac_send_rr_xxx_x_set_0,
 	[1] = NULL,
 };
@@ -1520,7 +1520,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_9a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_9a[] = {
+static const llc_conn_action_t llc_busy_actions_9a[] = {
 	[0] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_upd_p_flag,
 	[2] = llc_conn_ac_upd_nr_received,
@@ -1542,7 +1542,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_9b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_9b[] = {
+static const llc_conn_action_t llc_busy_actions_9b[] = {
 	[0] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_upd_p_flag,
 	[2] = llc_conn_ac_upd_nr_received,
@@ -1564,7 +1564,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_10a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_10a[] = {
+static const llc_conn_action_t llc_busy_actions_10a[] = {
 	[0] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_data_flag_1_if_data_flag_eq_0,
@@ -1584,7 +1584,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_10b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_10b[] = {
+static const llc_conn_action_t llc_busy_actions_10b[] = {
 	[0] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_data_flag_1_if_data_flag_eq_0,
@@ -1599,7 +1599,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_10b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1_UNEXPD_Ns event */
-static llc_conn_action_t llc_busy_actions_11[] = {
+static const llc_conn_action_t llc_busy_actions_11[] = {
 	[0] = llc_conn_ac_send_rnr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_data_flag_1_if_data_flag_eq_0,
@@ -1614,7 +1614,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_11 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_busy_actions_12[] = {
+static const llc_conn_action_t llc_busy_actions_12[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_send_rnr_rsp_f_set_1,
@@ -1637,7 +1637,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_13a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_13a[] = {
+static const llc_conn_action_t llc_busy_actions_13a[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_upd_p_flag,
@@ -1662,7 +1662,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_13b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_13b[] = {
+static const llc_conn_action_t llc_busy_actions_13b[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_upd_p_flag,
@@ -1687,7 +1687,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_14a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_14a[] = {
+static const llc_conn_action_t llc_busy_actions_14a[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
@@ -1710,7 +1710,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_14b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_14b[] = {
+static const llc_conn_action_t llc_busy_actions_14b[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
@@ -1728,7 +1728,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_14b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_busy_actions_15a[] = {
+static const llc_conn_action_t llc_busy_actions_15a[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -1743,7 +1743,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_15a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_busy_actions_15b[] = {
+static const llc_conn_action_t llc_busy_actions_15b[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -1763,7 +1763,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_15c[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_15c[] = {
+static const llc_conn_action_t llc_busy_actions_15c[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -1778,7 +1778,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_15c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_busy_actions_16[] = {
+static const llc_conn_action_t llc_busy_actions_16[] = {
 	[0] = llc_conn_ac_send_rnr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -1793,7 +1793,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_16 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_busy_actions_17a[] = {
+static const llc_conn_action_t llc_busy_actions_17a[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -1808,7 +1808,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_17a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_busy_actions_17b[] = {
+static const llc_conn_action_t llc_busy_actions_17b[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -1828,7 +1828,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_17c[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_17c[] = {
+static const llc_conn_action_t llc_busy_actions_17c[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -1843,7 +1843,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_17c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_busy_actions_18[] = {
+static const llc_conn_action_t llc_busy_actions_18[] = {
 	[0] = llc_conn_ac_send_rnr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -1863,7 +1863,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_19a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_19a[] = {
+static const llc_conn_action_t llc_busy_actions_19a[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_p_flag,
@@ -1885,7 +1885,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_19b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_19b[] = {
+static const llc_conn_action_t llc_busy_actions_19b[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_p_flag,
@@ -1907,7 +1907,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_20a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_20a[] = {
+static const llc_conn_action_t llc_busy_actions_20a[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_resend_i_xxx_x_set_0,
@@ -1928,7 +1928,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_20b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_20b[] = {
+static const llc_conn_action_t llc_busy_actions_20b[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_resend_i_xxx_x_set_0,
@@ -1944,7 +1944,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_20b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_busy_actions_21[] = {
+static const llc_conn_action_t llc_busy_actions_21[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_send_rnr_rsp_f_set_1,
@@ -1966,7 +1966,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_22[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_22[] = {
+static const llc_conn_action_t llc_busy_actions_22[] = {
 	[0] = llc_conn_ac_send_rnr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = NULL,
@@ -1985,7 +1985,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_23[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_23[] = {
+static const llc_conn_action_t llc_busy_actions_23[] = {
 	[0] = llc_conn_ac_send_rnr_cmd_p_set_1,
 	[1] = llc_conn_ac_rst_vs,
 	[2] = llc_conn_ac_start_p_timer,
@@ -2007,7 +2007,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_24a[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_24a[] = {
+static const llc_conn_action_t llc_busy_actions_24a[] = {
 	[0] = llc_conn_ac_send_rnr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = llc_conn_ac_inc_retry_cnt_by_1,
@@ -2029,7 +2029,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_24b[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_24b[] = {
+static const llc_conn_action_t llc_busy_actions_24b[] = {
 	[0] = llc_conn_ac_send_rnr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = llc_conn_ac_inc_retry_cnt_by_1,
@@ -2051,7 +2051,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_25[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_25[] = {
+static const llc_conn_action_t llc_busy_actions_25[] = {
 	[0] = llc_conn_ac_send_rnr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = llc_conn_ac_inc_retry_cnt_by_1,
@@ -2074,7 +2074,7 @@ static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_26[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_busy_actions_26[] = {
+static const llc_conn_action_t llc_busy_actions_26[] = {
 	[0] = llc_conn_ac_set_data_flag_1,
 	[1] = NULL,
 };
@@ -2161,7 +2161,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_1[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_1[] = {
+static const llc_conn_action_t llc_reject_actions_1[] = {
 	[0] = llc_conn_ac_send_i_xxx_x_set_0,
 	[1] = NULL,
 };
@@ -2180,7 +2180,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_2[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_2[] = {
+static const llc_conn_action_t llc_reject_actions_2[] = {
 	[0] = llc_conn_ac_send_i_xxx_x_set_0,
 	[1] = NULL,
 };
@@ -2200,7 +2200,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_2_1[] = {
 };
 
 /* just one member, NULL, .bss zeroes it */
-static llc_conn_action_t llc_reject_actions_2_1[1];
+static const llc_conn_action_t llc_reject_actions_2_1[1];
 
 static struct llc_conn_state_trans llc_reject_state_trans_2_1 = {
 	.ev	       = llc_conn_ev_data_req,
@@ -2216,7 +2216,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_3[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_3[] = {
+static const llc_conn_action_t llc_reject_actions_3[] = {
 	[0] = llc_conn_ac_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_set_data_flag_2,
 	[2] = NULL,
@@ -2235,7 +2235,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_4[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_4[] = {
+static const llc_conn_action_t llc_reject_actions_4[] = {
 	[0] = llc_conn_ac_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_set_data_flag_2,
 	[2] = NULL,
@@ -2249,7 +2249,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_4 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0_UNEXPD_Ns event */
-static llc_conn_action_t llc_reject_actions_5a[] = {
+static const llc_conn_action_t llc_reject_actions_5a[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_p_flag,
 	[2] = llc_conn_ac_clear_remote_busy_if_f_eq_1,
@@ -2264,7 +2264,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_5a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0_UNEXPD_Ns event */
-static llc_conn_action_t llc_reject_actions_5b[] = {
+static const llc_conn_action_t llc_reject_actions_5b[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_p_flag,
 	[2] = llc_conn_ac_clear_remote_busy_if_f_eq_1,
@@ -2284,7 +2284,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_5c[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_5c[] = {
+static const llc_conn_action_t llc_reject_actions_5c[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_p_flag,
 	[2] = llc_conn_ac_clear_remote_busy_if_f_eq_1,
@@ -2299,7 +2299,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_5c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1_UNEXPD_Ns event */
-static llc_conn_action_t llc_reject_actions_6[] = {
+static const llc_conn_action_t llc_reject_actions_6[] = {
 	[0] = llc_conn_ac_send_rr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = NULL,
@@ -2318,7 +2318,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_7a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_7a[] = {
+static const llc_conn_action_t llc_reject_actions_7a[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_upd_p_flag,
@@ -2343,7 +2343,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_7b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_7b[] = {
+static const llc_conn_action_t llc_reject_actions_7b[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_upd_p_flag,
@@ -2367,7 +2367,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_8a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_8a[] = {
+static const llc_conn_action_t llc_reject_actions_8a[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_send_ack_xxx_x_set_0,
@@ -2389,7 +2389,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_8b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_8b[] = {
+static const llc_conn_action_t llc_reject_actions_8b[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_send_ack_xxx_x_set_0,
@@ -2406,7 +2406,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_8b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_reject_actions_9[] = {
+static const llc_conn_action_t llc_reject_actions_9[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_send_ack_rsp_f_set_1,
@@ -2423,7 +2423,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_9 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_reject_actions_10a[] = {
+static const llc_conn_action_t llc_reject_actions_10a[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -2438,7 +2438,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_10a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_reject_actions_10b[] = {
+static const llc_conn_action_t llc_reject_actions_10b[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -2458,7 +2458,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_10c[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_10c[] = {
+static const llc_conn_action_t llc_reject_actions_10c[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -2473,7 +2473,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_10c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_reject_actions_11[] = {
+static const llc_conn_action_t llc_reject_actions_11[] = {
 	[0] = llc_conn_ac_send_ack_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -2488,7 +2488,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_11 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_reject_actions_12a[] = {
+static const llc_conn_action_t llc_reject_actions_12a[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -2503,7 +2503,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_12a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_reject_actions_12b[] = {
+static const llc_conn_action_t llc_reject_actions_12b[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -2523,7 +2523,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_12c[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_12c[] = {
+static const llc_conn_action_t llc_reject_actions_12c[] = {
 	[0] = llc_conn_ac_upd_p_flag,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -2538,7 +2538,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_12c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_reject_actions_13[] = {
+static const llc_conn_action_t llc_reject_actions_13[] = {
 	[0] = llc_conn_ac_send_rr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -2558,7 +2558,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_14a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_14a[] = {
+static const llc_conn_action_t llc_reject_actions_14a[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_p_flag,
@@ -2580,7 +2580,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_14b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_14b[] = {
+static const llc_conn_action_t llc_reject_actions_14b[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_p_flag,
@@ -2602,7 +2602,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_15a[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_15a[] = {
+static const llc_conn_action_t llc_reject_actions_15a[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_resend_i_xxx_x_set_0,
@@ -2623,7 +2623,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_15b[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_15b[] = {
+static const llc_conn_action_t llc_reject_actions_15b[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_resend_i_xxx_x_set_0,
@@ -2639,7 +2639,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_15b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_reject_actions_16[] = {
+static const llc_conn_action_t llc_reject_actions_16[] = {
 	[0] = llc_conn_ac_set_vs_nr,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_resend_i_rsp_f_set_1,
@@ -2660,7 +2660,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_17[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_17[] = {
+static const llc_conn_action_t llc_reject_actions_17[] = {
 	[0] = llc_conn_ac_send_rr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = NULL,
@@ -2680,7 +2680,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_18[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_18[] = {
+static const llc_conn_action_t llc_reject_actions_18[] = {
 	[0] = llc_conn_ac_send_rej_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = llc_conn_ac_start_rej_timer,
@@ -2701,7 +2701,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_19[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_19[] = {
+static const llc_conn_action_t llc_reject_actions_19[] = {
 	[0] = llc_conn_ac_send_rr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = llc_conn_ac_start_rej_timer,
@@ -2724,7 +2724,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_20a[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_20a[] = {
+static const llc_conn_action_t llc_reject_actions_20a[] = {
 	[0] = llc_conn_ac_send_rr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = llc_conn_ac_start_rej_timer,
@@ -2747,7 +2747,7 @@ static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_20b[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_reject_actions_20b[] = {
+static const llc_conn_action_t llc_reject_actions_20b[] = {
 	[0] = llc_conn_ac_send_rr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = llc_conn_ac_start_rej_timer,
@@ -2832,7 +2832,7 @@ static llc_conn_ev_qfyr_t llc_await_ev_qfyrs_1_0[] = {
 };
 
 /* just one member, NULL, .bss zeroes it */
-static llc_conn_action_t llc_await_actions_1_0[1];
+static const llc_conn_action_t llc_await_actions_1_0[1];
 
 static struct llc_conn_state_trans llc_await_state_trans_1_0 = {
 	.ev	       = llc_conn_ev_data_req,
@@ -2842,7 +2842,7 @@ static struct llc_conn_state_trans llc_await_state_trans_1_0 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_DETECTED event */
-static llc_conn_action_t llc_await_actions_1[] = {
+static const llc_conn_action_t llc_await_actions_1[] = {
 	[0] = llc_conn_ac_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_set_data_flag_0,
 	[2] = NULL,
@@ -2856,7 +2856,7 @@ static struct llc_conn_state_trans llc_await_state_trans_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_1_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_actions_2[] = {
+static const llc_conn_action_t llc_await_actions_2[] = {
 	[0] = llc_conn_ac_send_rej_xxx_x_set_0,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -2875,7 +2875,7 @@ static struct llc_conn_state_trans llc_await_state_trans_2 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_actions_3a[] = {
+static const llc_conn_action_t llc_await_actions_3a[] = {
 	[0] = llc_conn_ac_send_rej_xxx_x_set_0,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -2891,7 +2891,7 @@ static struct llc_conn_state_trans llc_await_state_trans_3a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_actions_3b[] = {
+static const llc_conn_action_t llc_await_actions_3b[] = {
 	[0] = llc_conn_ac_send_rej_xxx_x_set_0,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -2907,7 +2907,7 @@ static struct llc_conn_state_trans llc_await_state_trans_3b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_actions_4[] = {
+static const llc_conn_action_t llc_await_actions_4[] = {
 	[0] = llc_conn_ac_send_rej_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -2924,7 +2924,7 @@ static struct llc_conn_state_trans llc_await_state_trans_4 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_actions_5[] = {
+static const llc_conn_action_t llc_await_actions_5[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -2943,7 +2943,7 @@ static struct llc_conn_state_trans llc_await_state_trans_5 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_actions_6a[] = {
+static const llc_conn_action_t llc_await_actions_6a[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_send_rr_xxx_x_set_0,
@@ -2960,7 +2960,7 @@ static struct llc_conn_state_trans llc_await_state_trans_6a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_actions_6b[] = {
+static const llc_conn_action_t llc_await_actions_6b[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_send_rr_xxx_x_set_0,
@@ -2977,7 +2977,7 @@ static struct llc_conn_state_trans llc_await_state_trans_6b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_actions_7[] = {
+static const llc_conn_action_t llc_await_actions_7[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_send_rr_rsp_f_set_1,
@@ -2994,7 +2994,7 @@ static struct llc_conn_state_trans llc_await_state_trans_7 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_actions_8a[] = {
+static const llc_conn_action_t llc_await_actions_8a[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -3011,7 +3011,7 @@ static struct llc_conn_state_trans llc_await_state_trans_8a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_actions_8b[] = {
+static const llc_conn_action_t llc_await_actions_8b[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -3028,7 +3028,7 @@ static struct llc_conn_state_trans llc_await_state_trans_8b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_actions_9a[] = {
+static const llc_conn_action_t llc_await_actions_9a[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3043,7 +3043,7 @@ static struct llc_conn_state_trans llc_await_state_trans_9a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_actions_9b[] = {
+static const llc_conn_action_t llc_await_actions_9b[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3058,7 +3058,7 @@ static struct llc_conn_state_trans llc_await_state_trans_9b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_actions_9c[] = {
+static const llc_conn_action_t llc_await_actions_9c[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3073,7 +3073,7 @@ static struct llc_conn_state_trans llc_await_state_trans_9c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_actions_9d[] = {
+static const llc_conn_action_t llc_await_actions_9d[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3088,7 +3088,7 @@ static struct llc_conn_state_trans llc_await_state_trans_9d = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_actions_10a[] = {
+static const llc_conn_action_t llc_await_actions_10a[] = {
 	[0] = llc_conn_ac_send_rr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -3104,7 +3104,7 @@ static struct llc_conn_state_trans llc_await_state_trans_10a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_actions_10b[] = {
+static const llc_conn_action_t llc_await_actions_10b[] = {
 	[0] = llc_conn_ac_send_rr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -3120,7 +3120,7 @@ static struct llc_conn_state_trans llc_await_state_trans_10b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_actions_11[] = {
+static const llc_conn_action_t llc_await_actions_11[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -3136,7 +3136,7 @@ static struct llc_conn_state_trans llc_await_state_trans_11 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_actions_12a[] = {
+static const llc_conn_action_t llc_await_actions_12a[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -3151,7 +3151,7 @@ static struct llc_conn_state_trans llc_await_state_trans_12a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_actions_12b[] = {
+static const llc_conn_action_t llc_await_actions_12b[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -3166,7 +3166,7 @@ static struct llc_conn_state_trans llc_await_state_trans_12b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_actions_13[] = {
+static const llc_conn_action_t llc_await_actions_13[] = {
 	[0] = llc_conn_ac_send_rr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -3187,7 +3187,7 @@ static llc_conn_ev_qfyr_t llc_await_ev_qfyrs_14[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_await_actions_14[] = {
+static const llc_conn_action_t llc_await_actions_14[] = {
 	[0] = llc_conn_ac_send_rr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = llc_conn_ac_inc_retry_cnt_by_1,
@@ -3261,7 +3261,7 @@ static llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_1_0[] = {
 };
 
 /* just one member, NULL, .bss zeroes it */
-static llc_conn_action_t llc_await_busy_actions_1_0[1];
+static const llc_conn_action_t llc_await_busy_actions_1_0[1];
 
 static struct llc_conn_state_trans llc_await_busy_state_trans_1_0 = {
 	.ev	       = llc_conn_ev_data_req,
@@ -3276,7 +3276,7 @@ static llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_1[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_await_busy_actions_1[] = {
+static const llc_conn_action_t llc_await_busy_actions_1[] = {
 	[0] = llc_conn_ac_send_rej_xxx_x_set_0,
 	[1] = llc_conn_ac_start_rej_timer,
 	[2] = NULL,
@@ -3295,7 +3295,7 @@ static llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_2[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_await_busy_actions_2[] = {
+static const llc_conn_action_t llc_await_busy_actions_2[] = {
 	[0] = llc_conn_ac_send_rr_xxx_x_set_0,
 	[1] = NULL,
 };
@@ -3313,7 +3313,7 @@ static llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_3[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_await_busy_actions_3[] = {
+static const llc_conn_action_t llc_await_busy_actions_3[] = {
 	[0] = llc_conn_ac_send_rr_xxx_x_set_0,
 	[1] = NULL,
 };
@@ -3326,7 +3326,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_3 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_1_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_busy_actions_4[] = {
+static const llc_conn_action_t llc_await_busy_actions_4[] = {
 	[0] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -3345,7 +3345,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_4 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_busy_actions_5a[] = {
+static const llc_conn_action_t llc_await_busy_actions_5a[] = {
 	[0] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -3361,7 +3361,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_5a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_busy_actions_5b[] = {
+static const llc_conn_action_t llc_await_busy_actions_5b[] = {
 	[0] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -3377,7 +3377,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_5b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_busy_actions_6[] = {
+static const llc_conn_action_t llc_await_busy_actions_6[] = {
 	[0] = llc_conn_ac_send_rnr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -3393,7 +3393,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_6 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_busy_actions_7[] = {
+static const llc_conn_action_t llc_await_busy_actions_7[] = {
 	[0] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_inc_vr_by_1,
 	[2] = llc_conn_ac_data_ind,
@@ -3414,7 +3414,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_7 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_busy_actions_8a[] = {
+static const llc_conn_action_t llc_await_busy_actions_8a[] = {
 	[0] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_inc_vr_by_1,
 	[2] = llc_conn_ac_data_ind,
@@ -3432,7 +3432,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_8a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_busy_actions_8b[] = {
+static const llc_conn_action_t llc_await_busy_actions_8b[] = {
 	[0] = llc_conn_ac_opt_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_inc_vr_by_1,
 	[2] = llc_conn_ac_data_ind,
@@ -3450,7 +3450,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_8b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_busy_actions_9[] = {
+static const llc_conn_action_t llc_await_busy_actions_9[] = {
 	[0] = llc_conn_ac_send_rnr_rsp_f_set_1,
 	[1] = llc_conn_ac_inc_vr_by_1,
 	[2] = llc_conn_ac_data_ind,
@@ -3468,7 +3468,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_9 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_busy_actions_10a[] = {
+static const llc_conn_action_t llc_await_busy_actions_10a[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -3485,7 +3485,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_10a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_busy_actions_10b[] = {
+static const llc_conn_action_t llc_await_busy_actions_10b[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -3502,7 +3502,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_10b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_busy_actions_11a[] = {
+static const llc_conn_action_t llc_await_busy_actions_11a[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3517,7 +3517,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_11a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_busy_actions_11b[] = {
+static const llc_conn_action_t llc_await_busy_actions_11b[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3532,7 +3532,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_11b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_busy_actions_11c[] = {
+static const llc_conn_action_t llc_await_busy_actions_11c[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3547,7 +3547,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_11c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_busy_actions_11d[] = {
+static const llc_conn_action_t llc_await_busy_actions_11d[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3562,7 +3562,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_11d = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_busy_actions_12a[] = {
+static const llc_conn_action_t llc_await_busy_actions_12a[] = {
 	[0] = llc_conn_ac_send_rnr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -3578,7 +3578,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_12a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_busy_actions_12b[] = {
+static const llc_conn_action_t llc_await_busy_actions_12b[] = {
 	[0] = llc_conn_ac_send_rnr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -3594,7 +3594,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_12b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_busy_actions_13[] = {
+static const llc_conn_action_t llc_await_busy_actions_13[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -3610,7 +3610,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_13 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_busy_actions_14a[] = {
+static const llc_conn_action_t llc_await_busy_actions_14a[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -3625,7 +3625,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_14a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_busy_actions_14b[] = {
+static const llc_conn_action_t llc_await_busy_actions_14b[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -3640,7 +3640,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_14b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_busy_actions_15[] = {
+static const llc_conn_action_t llc_await_busy_actions_15[] = {
 	[0] = llc_conn_ac_send_rnr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -3661,7 +3661,7 @@ static llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_16[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_await_busy_actions_16[] = {
+static const llc_conn_action_t llc_await_busy_actions_16[] = {
 	[0] = llc_conn_ac_send_rnr_cmd_p_set_1,
 	[1] = llc_conn_ac_start_p_timer,
 	[2] = llc_conn_ac_inc_retry_cnt_by_1,
@@ -3737,7 +3737,7 @@ static llc_conn_ev_qfyr_t llc_await_reject_ev_qfyrs_1_0[] = {
 };
 
 /* just one member, NULL, .bss zeroes it */
-static llc_conn_action_t llc_await_reject_actions_1_0[1];
+static const llc_conn_action_t llc_await_reject_actions_1_0[1];
 
 static struct llc_conn_state_trans llc_await_reject_state_trans_1_0 = {
 	.ev	       = llc_conn_ev_data_req,
@@ -3747,7 +3747,7 @@ static struct llc_conn_state_trans llc_await_reject_state_trans_1_0 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_DETECTED event */
-static llc_conn_action_t llc_await_rejct_actions_1[] = {
+static const llc_conn_action_t llc_await_rejct_actions_1[] = {
 	[0] = llc_conn_ac_send_rnr_xxx_x_set_0,
 	[1] = llc_conn_ac_set_data_flag_2,
 	[2] = NULL
@@ -3761,7 +3761,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_rejct_actions_2a[] = {
+static const llc_conn_action_t llc_await_rejct_actions_2a[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = NULL
@@ -3775,7 +3775,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_2a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_rejct_actions_2b[] = {
+static const llc_conn_action_t llc_await_rejct_actions_2b[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = NULL
@@ -3789,7 +3789,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_2b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_rejct_actions_3[] = {
+static const llc_conn_action_t llc_await_rejct_actions_3[] = {
 	[0] = llc_conn_ac_send_rr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -3804,7 +3804,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_3 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_rejct_actions_4[] = {
+static const llc_conn_action_t llc_await_rejct_actions_4[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -3824,7 +3824,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_4 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_rejct_actions_5a[] = {
+static const llc_conn_action_t llc_await_rejct_actions_5a[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_send_rr_xxx_x_set_0,
@@ -3842,7 +3842,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_5a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_rejct_actions_5b[] = {
+static const llc_conn_action_t llc_await_rejct_actions_5b[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_send_rr_xxx_x_set_0,
@@ -3860,7 +3860,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_5b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_rejct_actions_6[] = {
+static const llc_conn_action_t llc_await_rejct_actions_6[] = {
 	[0] = llc_conn_ac_inc_vr_by_1,
 	[1] = llc_conn_ac_data_ind,
 	[2] = llc_conn_ac_send_rr_rsp_f_set_1,
@@ -3878,7 +3878,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_6 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_rejct_actions_7a[] = {
+static const llc_conn_action_t llc_await_rejct_actions_7a[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -3895,7 +3895,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_7a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_rejct_actions_7b[] = {
+static const llc_conn_action_t llc_await_rejct_actions_7b[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -3912,7 +3912,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_7b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_1_UNEXPD_Ns event */
-static llc_conn_action_t llc_await_rejct_actions_7c[] = {
+static const llc_conn_action_t llc_await_rejct_actions_7c[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -3929,7 +3929,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_7c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_rejct_actions_8a[] = {
+static const llc_conn_action_t llc_await_rejct_actions_8a[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3944,7 +3944,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_8a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_rejct_actions_8b[] = {
+static const llc_conn_action_t llc_await_rejct_actions_8b[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3959,7 +3959,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_8b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_rejct_actions_8c[] = {
+static const llc_conn_action_t llc_await_rejct_actions_8c[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3974,7 +3974,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_8c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_rejct_actions_8d[] = {
+static const llc_conn_action_t llc_await_rejct_actions_8d[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_clear_remote_busy,
@@ -3989,7 +3989,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_8d = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_rejct_actions_9a[] = {
+static const llc_conn_action_t llc_await_rejct_actions_9a[] = {
 	[0] = llc_conn_ac_send_rr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -4005,7 +4005,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_9a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_rejct_actions_9b[] = {
+static const llc_conn_action_t llc_await_rejct_actions_9b[] = {
 	[0] = llc_conn_ac_send_rr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -4021,7 +4021,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_9b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_1 event */
-static llc_conn_action_t llc_await_rejct_actions_10[] = {
+static const llc_conn_action_t llc_await_rejct_actions_10[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_stop_p_timer,
@@ -4037,7 +4037,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_10 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_0 event */
-static llc_conn_action_t llc_await_rejct_actions_11a[] = {
+static const llc_conn_action_t llc_await_rejct_actions_11a[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -4052,7 +4052,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_11a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_0 event */
-static llc_conn_action_t llc_await_rejct_actions_11b[] = {
+static const llc_conn_action_t llc_await_rejct_actions_11b[] = {
 	[0] = llc_conn_ac_upd_nr_received,
 	[1] = llc_conn_ac_upd_vs,
 	[2] = llc_conn_ac_set_remote_busy,
@@ -4067,7 +4067,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_11b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_CMD_Pbit_SET_1 event */
-static llc_conn_action_t llc_await_rejct_actions_12[] = {
+static const llc_conn_action_t llc_await_rejct_actions_12[] = {
 	[0] = llc_conn_ac_send_rr_rsp_f_set_1,
 	[1] = llc_conn_ac_upd_nr_received,
 	[2] = llc_conn_ac_upd_vs,
@@ -4088,7 +4088,7 @@ static llc_conn_ev_qfyr_t llc_await_rejct_ev_qfyrs_13[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_await_rejct_actions_13[] = {
+static const llc_conn_action_t llc_await_rejct_actions_13[] = {
 	[0] = llc_conn_ac_send_rej_cmd_p_set_1,
 	[1] = llc_conn_ac_stop_p_timer,
 	[2] = llc_conn_ac_inc_retry_cnt_by_1,
@@ -4163,7 +4163,7 @@ static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_1[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_d_conn_actions_1[] = {
+static const llc_conn_action_t llc_d_conn_actions_1[] = {
 	[0] = llc_conn_ac_send_dm_rsp_f_set_p,
 	[1] = llc_conn_ac_stop_ack_timer,
 	[2] = llc_conn_ac_disc_confirm,
@@ -4187,7 +4187,7 @@ static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_1_1[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_d_conn_actions_1_1[] = {
+static const llc_conn_action_t llc_d_conn_actions_1_1[] = {
 	[0] = llc_conn_ac_send_dm_rsp_f_set_p,
 	[1] = llc_conn_ac_stop_ack_timer,
 	[2] = llc_conn_disc,
@@ -4211,7 +4211,7 @@ static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_2[] = {
 	[3] = NULL,
 };
 
-static llc_conn_action_t llc_d_conn_actions_2[] = {
+static const llc_conn_action_t llc_d_conn_actions_2[] = {
 	[0] = llc_conn_ac_stop_ack_timer,
 	[1] = llc_conn_ac_disc_confirm,
 	[2] = llc_conn_disc,
@@ -4235,7 +4235,7 @@ static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_2_1[] = {
 	[3] = NULL,
 };
 
-static llc_conn_action_t llc_d_conn_actions_2_1[] = {
+static const llc_conn_action_t llc_d_conn_actions_2_1[] = {
 	[0] = llc_conn_ac_stop_ack_timer,
 	[1] = llc_conn_disc,
 	[2] = NULL,
@@ -4249,7 +4249,7 @@ static struct llc_conn_state_trans llc_d_conn_state_trans_2_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_DISC_CMD_Pbit_SET_X event */
-static llc_conn_action_t llc_d_conn_actions_3[] = {
+static const llc_conn_action_t llc_d_conn_actions_3[] = {
 	[0] = llc_conn_ac_send_ua_rsp_f_set_p,
 	[1] = NULL,
 };
@@ -4270,7 +4270,7 @@ static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_4[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_d_conn_actions_4[] = {
+static const llc_conn_action_t llc_d_conn_actions_4[] = {
 	[0] = llc_conn_ac_stop_ack_timer,
 	[1] = llc_conn_ac_disc_confirm,
 	[2] = llc_conn_disc,
@@ -4293,7 +4293,7 @@ static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_4_1[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_d_conn_actions_4_1[] = {
+static const llc_conn_action_t llc_d_conn_actions_4_1[] = {
 	[0] = llc_conn_ac_stop_ack_timer,
 	[1] = llc_conn_disc,
 	[2] = NULL,
@@ -4316,7 +4316,7 @@ static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_5[] = {
 };
 
 /* just one member, NULL, .bss zeroes it */
-static llc_conn_action_t llc_d_conn_actions_5[1];
+static const llc_conn_action_t llc_d_conn_actions_5[1];
 
 static struct llc_conn_state_trans llc_d_conn_state_trans_5 = {
 	.ev	       = llc_conn_ev_data_req,
@@ -4331,7 +4331,7 @@ static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_6[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_d_conn_actions_6[] = {
+static const llc_conn_action_t llc_d_conn_actions_6[] = {
 	[0] = llc_conn_ac_send_disc_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_inc_retry_cnt_by_1,
@@ -4353,7 +4353,7 @@ static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_7[] = {
 	[3] = NULL,
 };
 
-static llc_conn_action_t llc_d_conn_actions_7[] = {
+static const llc_conn_action_t llc_d_conn_actions_7[] = {
 	[0] = llc_conn_ac_disc_confirm,
 	[1] = llc_conn_disc,
 	[2] = NULL,
@@ -4374,7 +4374,7 @@ static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_8[] = {
 	[3] = NULL,
 };
 
-static llc_conn_action_t llc_d_conn_actions_8[] = {
+static const llc_conn_action_t llc_d_conn_actions_8[] = {
 	[0] = llc_conn_disc,
 	[1] = NULL,
 };
@@ -4411,7 +4411,7 @@ static struct llc_conn_state_trans *llc_d_conn_state_transitions[] = {
 
 /* LLC_CONN_STATE_RESET transitions */
 /* State transitions for LLC_CONN_EV_RX_SABME_CMD_Pbit_SET_X event */
-static llc_conn_action_t llc_rst_actions_1[] = {
+static const llc_conn_action_t llc_rst_actions_1[] = {
 	[0] = llc_conn_ac_set_vs_0,
 	[1] = llc_conn_ac_set_vr_0,
 	[2] = llc_conn_ac_set_s_flag_1,
@@ -4436,7 +4436,7 @@ static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_2[] = {
 	[3] = NULL,
 };
 
-static llc_conn_action_t llc_rst_actions_2[] = {
+static const llc_conn_action_t llc_rst_actions_2[] = {
 	[0] = llc_conn_ac_stop_ack_timer,
 	[1] = llc_conn_ac_set_vs_0,
 	[2] = llc_conn_ac_set_vr_0,
@@ -4464,7 +4464,7 @@ static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_2_1[] = {
 	[3] = NULL,
 };
 
-static llc_conn_action_t llc_rst_actions_2_1[] = {
+static const llc_conn_action_t llc_rst_actions_2_1[] = {
 	[0] = llc_conn_ac_stop_ack_timer,
 	[1] = llc_conn_ac_set_vs_0,
 	[2] = llc_conn_ac_set_vr_0,
@@ -4489,7 +4489,7 @@ static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_3[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_rst_actions_3[] = {
+static const llc_conn_action_t llc_rst_actions_3[] = {
 	[0] = llc_conn_ac_set_p_flag_0,
 	[1] = llc_conn_ac_set_remote_busy_0,
 	[2] = NULL,
@@ -4510,7 +4510,7 @@ static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_4[] = {
 	[1] = llc_conn_ev_qlfy_set_status_disc,
 	[2] = NULL,
 };
-static llc_conn_action_t llc_rst_actions_4[] = {
+static const llc_conn_action_t llc_rst_actions_4[] = {
 	[0] = llc_conn_ac_send_dm_rsp_f_set_p,
 	[1] = llc_conn_ac_disc_ind,
 	[2] = llc_conn_ac_stop_ack_timer,
@@ -4534,7 +4534,7 @@ static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_4_1[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_rst_actions_4_1[] = {
+static const llc_conn_action_t llc_rst_actions_4_1[] = {
 	[0] = llc_conn_ac_send_dm_rsp_f_set_p,
 	[1] = llc_conn_ac_stop_ack_timer,
 	[2] = llc_conn_disc,
@@ -4557,7 +4557,7 @@ static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_5[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_rst_actions_5[] = {
+static const llc_conn_action_t llc_rst_actions_5[] = {
 	[0] = llc_conn_ac_disc_ind,
 	[1] = llc_conn_ac_stop_ack_timer,
 	[2] = llc_conn_disc,
@@ -4580,7 +4580,7 @@ static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_5_1[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_rst_actions_5_1[] = {
+static const llc_conn_action_t llc_rst_actions_5_1[] = {
 	[0] = llc_conn_ac_stop_ack_timer,
 	[1] = llc_conn_disc,
 	[2] = NULL,
@@ -4600,7 +4600,7 @@ static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_6[] = {
 };
 
 /* just one member, NULL, .bss zeroes it */
-static llc_conn_action_t llc_rst_actions_6[1];
+static const llc_conn_action_t llc_rst_actions_6[1];
 
 static struct llc_conn_state_trans llc_rst_state_trans_6 = {
 	.ev	       = llc_conn_ev_data_req,
@@ -4616,7 +4616,7 @@ static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_7[] = {
 	[2] = NULL,
 };
 
-static llc_conn_action_t llc_rst_actions_7[] = {
+static const llc_conn_action_t llc_rst_actions_7[] = {
 	[0] = llc_conn_ac_send_sabme_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_inc_retry_cnt_by_1,
@@ -4638,7 +4638,7 @@ static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_8[] = {
 	[3] = llc_conn_ev_qlfy_set_status_failed,
 	[4] = NULL,
 };
-static llc_conn_action_t llc_rst_actions_8[] = {
+static const llc_conn_action_t llc_rst_actions_8[] = {
 	[0] = llc_conn_ac_disc_ind,
 	[1] = llc_conn_disc,
 	[2] = NULL,
@@ -4659,7 +4659,7 @@ static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_8_1[] = {
 	[3] = llc_conn_ev_qlfy_set_status_failed,
 	[4] = NULL,
 };
-static llc_conn_action_t llc_rst_actions_8_1[] = {
+static const llc_conn_action_t llc_rst_actions_8_1[] = {
 	[0] = llc_conn_ac_disc_ind,
 	[1] = llc_conn_disc,
 	[2] = NULL,
@@ -4698,7 +4698,7 @@ static struct llc_conn_state_trans *llc_rst_state_transitions[] = {
 
 /* LLC_CONN_STATE_ERROR transitions */
 /* State transitions for LLC_CONN_EV_RX_SABME_CMD_Pbit_SET_X event */
-static llc_conn_action_t llc_error_actions_1[] = {
+static const llc_conn_action_t llc_error_actions_1[] = {
 	[0] = llc_conn_ac_set_vs_0,
 	[1] = llc_conn_ac_set_vr_0,
 	[2] = llc_conn_ac_send_ua_rsp_f_set_p,
@@ -4718,7 +4718,7 @@ static struct llc_conn_state_trans llc_error_state_trans_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_DISC_CMD_Pbit_SET_X event */
-static llc_conn_action_t llc_error_actions_2[] = {
+static const llc_conn_action_t llc_error_actions_2[] = {
 	[0] = llc_conn_ac_send_ua_rsp_f_set_p,
 	[1] = llc_conn_ac_disc_ind,
 	[2] = llc_conn_ac_stop_ack_timer,
@@ -4734,7 +4734,7 @@ static struct llc_conn_state_trans llc_error_state_trans_2 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_DM_RSP_Fbit_SET_X event */
-static llc_conn_action_t llc_error_actions_3[] = {
+static const llc_conn_action_t llc_error_actions_3[] = {
 	[0] = llc_conn_ac_disc_ind,
 	[1] = llc_conn_ac_stop_ack_timer,
 	[2] = llc_conn_disc,
@@ -4749,7 +4749,7 @@ static struct llc_conn_state_trans llc_error_state_trans_3 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_FRMR_RSP_Fbit_SET_X event */
-static llc_conn_action_t llc_error_actions_4[] = {
+static const llc_conn_action_t llc_error_actions_4[] = {
 	[0] = llc_conn_ac_send_sabme_cmd_p_set_x,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_set_retry_cnt_0,
@@ -4765,7 +4765,7 @@ static struct llc_conn_state_trans llc_error_state_trans_4 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_XXX_CMD_Pbit_SET_X event */
-static llc_conn_action_t llc_error_actions_5[] = {
+static const llc_conn_action_t llc_error_actions_5[] = {
 	[0] = llc_conn_ac_resend_frmr_rsp_f_set_p,
 	[1] = NULL,
 };
@@ -4791,7 +4791,7 @@ static llc_conn_ev_qfyr_t llc_error_ev_qfyrs_7[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_error_actions_7[] = {
+static const llc_conn_action_t llc_error_actions_7[] = {
 	[0] = llc_conn_ac_resend_frmr_rsp_f_set_0,
 	[1] = llc_conn_ac_start_ack_timer,
 	[2] = llc_conn_ac_inc_retry_cnt_by_1,
@@ -4811,7 +4811,7 @@ static llc_conn_ev_qfyr_t llc_error_ev_qfyrs_8[] = {
 	[1] = NULL,
 };
 
-static llc_conn_action_t llc_error_actions_8[] = {
+static const llc_conn_action_t llc_error_actions_8[] = {
 	[0] = llc_conn_ac_send_sabme_cmd_p_set_x,
 	[1] = llc_conn_ac_set_s_flag_0,
 	[2] = llc_conn_ac_start_ack_timer,
@@ -4834,7 +4834,7 @@ static llc_conn_ev_qfyr_t llc_error_ev_qfyrs_9[] = {
 };
 
 /* just one member, NULL, .bss zeroes it */
-static llc_conn_action_t llc_error_actions_9[1];
+static const llc_conn_action_t llc_error_actions_9[1];
 
 static struct llc_conn_state_trans llc_error_state_trans_9 = {
 	.ev	       = llc_conn_ev_data_req,
@@ -4866,7 +4866,7 @@ static struct llc_conn_state_trans *llc_error_state_transitions[] = {
 
 /* LLC_CONN_STATE_TEMP transitions */
 /* State transitions for LLC_CONN_EV_DISC_REQ event */
-static llc_conn_action_t llc_temp_actions_1[] = {
+static const llc_conn_action_t llc_temp_actions_1[] = {
 	[0] = llc_conn_ac_stop_all_timers,
 	[1] = llc_conn_ac_send_disc_cmd_p_set_x,
 	[2] = llc_conn_disc,
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 42dc2e4..75baa2b 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -454,7 +454,7 @@ static int llc_exec_conn_trans_actions(struct sock *sk,
 				       struct sk_buff *skb)
 {
 	int rc = 0;
-	llc_conn_action_t *next_action;
+	const llc_conn_action_t *next_action;
 
 	for (next_action = trans->ev_actions;
 	     next_action && *next_action; next_action++) {
