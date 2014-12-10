From: Joe Perches <joe@perches.com>
Subject: [PATCH 2] llc: Make llc_conn_ev_qfyr_t function pointer arrays const
Date: Wed, 10 Dec 2014 09:43:57 -0800
Message-ID: <1418233437.18092.7.camel@perches.com>
References: <1418228330.18092.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418228330.18092.3.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's better when function pointer arrays aren't modifiable.

Net change from original:

$ size net/llc/built-in.o.*
   text	   data	    bss	    dec	    hex	filename
  61065	  12886	   1344	  75295	  1261f	net/llc/built-in.o.new
  47113	  27030	   1344	  75487	  126df	net/llc/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---

The first patch should have specified which function pointer array type
was being updated.  Oh well.

 include/net/llc_c_st.h |   2 +-
 net/llc/llc_c_st.c     | 238 ++++++++++++++++++++++++-------------------------
 net/llc/llc_conn.c     |   2 +-
 3 files changed, 121 insertions(+), 121 deletions(-)

diff --git a/include/net/llc_c_st.h b/include/net/llc_c_st.h
index 60e2ebb..48f3f89 100644
--- a/include/net/llc_c_st.h
+++ b/include/net/llc_c_st.h
@@ -35,7 +35,7 @@
 struct llc_conn_state_trans {
 	llc_conn_ev_t	   ev;
 	u8		   next_state;
-	llc_conn_ev_qfyr_t *ev_qualifiers;
+	const llc_conn_ev_qfyr_t *ev_qualifiers;
 	const llc_conn_action_t  *ev_actions;
 };
 
diff --git a/net/llc/llc_c_st.c b/net/llc/llc_c_st.c
index 3ae257d..2467573 100644
--- a/net/llc/llc_c_st.c
+++ b/net/llc/llc_c_st.c
@@ -234,7 +234,7 @@ static struct llc_conn_state_trans llc_common_state_trans_9 = {
 
 /* State transitions for LLC_CONN_EV_RX_XXX_RSP_Fbit_SET_1 event */
 #if 0
-static llc_conn_ev_qfyr_t llc_common_ev_qfyrs_10[] = {
+static const llc_conn_ev_qfyr_t llc_common_ev_qfyrs_10[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -256,7 +256,7 @@ static struct llc_conn_state_trans llc_common_state_trans_10 = {
 #endif
 
 /* State transitions for LLC_CONN_EV_P_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11a[] = {
+static const llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11a[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_gte_n2,
 	[1] = NULL,
 };
@@ -278,7 +278,7 @@ static struct llc_conn_state_trans llc_common_state_trans_11a = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11b[] = {
+static const llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11b[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_gte_n2,
 	[1] = NULL,
 };
@@ -300,7 +300,7 @@ static struct llc_conn_state_trans llc_common_state_trans_11b = {
 };
 
 /* State transitions for LLC_CONN_EV_REJ_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11c[] = {
+static const llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11c[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_gte_n2,
 	[1] = NULL,
 };
@@ -322,7 +322,7 @@ static struct llc_conn_state_trans llc_common_state_trans_11c = {
 };
 
 /* State transitions for LLC_CONN_EV_BUSY_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11d[] = {
+static const llc_conn_ev_qfyr_t llc_common_ev_qfyrs_11d[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_gte_n2,
 	[1] = NULL,
 };
@@ -461,7 +461,7 @@ static struct llc_conn_state_trans llc_setup_state_trans_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_UA_RSP_Fbit_SET_X event */
-static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_2[] = {
+static const llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_2[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = llc_conn_ev_qlfy_set_status_conn,
 	[2] = NULL,
@@ -485,7 +485,7 @@ static struct llc_conn_state_trans llc_setup_state_trans_2 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_3[] = {
+static const llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_3[] = {
 	[0] = llc_conn_ev_qlfy_s_flag_eq_1,
 	[1] = llc_conn_ev_qlfy_set_status_conn,
 	[2] = NULL,
@@ -506,7 +506,7 @@ static struct llc_conn_state_trans llc_setup_state_trans_3 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_DISC_CMD_Pbit_SET_X event */
-static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_4[] = {
+static const llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_4[] = {
 	[0] = llc_conn_ev_qlfy_set_status_disc,
 	[1] = NULL,
 };
@@ -527,7 +527,7 @@ static struct llc_conn_state_trans llc_setup_state_trans_4 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_DM_RSP_Fbit_SET_X event */
-static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_5[] = {
+static const llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_5[] = {
 	[0] = llc_conn_ev_qlfy_set_status_disc,
 	[1] = NULL,
 };
@@ -547,7 +547,7 @@ static struct llc_conn_state_trans llc_setup_state_trans_5 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_7[] = {
+static const llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_7[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[1] = llc_conn_ev_qlfy_s_flag_eq_0,
 	[2] = NULL,
@@ -568,7 +568,7 @@ static struct llc_conn_state_trans llc_setup_state_trans_7 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_8[] = {
+static const llc_conn_ev_qfyr_t llc_setup_ev_qfyrs_8[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_gte_n2,
 	[1] = llc_conn_ev_qlfy_s_flag_eq_0,
 	[2] = llc_conn_ev_qlfy_set_status_failed,
@@ -609,7 +609,7 @@ static struct llc_conn_state_trans *llc_setup_state_transitions[] = {
 
 /* LLC_CONN_STATE_NORMAL transitions */
 /* State transitions for LLC_CONN_EV_DATA_REQ event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_1[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_1[] = {
 	[0] = llc_conn_ev_qlfy_remote_busy_eq_0,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[2] = llc_conn_ev_qlfy_last_frame_eq_0,
@@ -630,7 +630,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_DATA_REQ event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_2[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_2[] = {
 	[0] = llc_conn_ev_qlfy_remote_busy_eq_0,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[2] = llc_conn_ev_qlfy_last_frame_eq_1,
@@ -651,7 +651,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_2 = {
 };
 
 /* State transitions for LLC_CONN_EV_DATA_REQ event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_2_1[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_2_1[] = {
 	[0] = llc_conn_ev_qlfy_remote_busy_eq_1,
 	[1] = llc_conn_ev_qlfy_set_status_remote_busy,
 	[2] = NULL,
@@ -668,7 +668,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_2_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_DETECTED event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_3[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_3[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -688,7 +688,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_3 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_DETECTED event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_4[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_4[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -708,7 +708,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_4 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0_UNEXPD_Ns event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_5a[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_5a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -731,7 +731,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_5a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0_UNEXPD_Ns event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_5b[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_5b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -754,7 +754,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_5b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_1_UNEXPD_Ns event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_5c[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_5c[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -777,7 +777,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_5c = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0_UNEXPD_Ns event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_6a[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_6a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -798,7 +798,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_6a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0_UNEXPD_Ns event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_6b[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_6b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -835,7 +835,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_7 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_X event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_8a[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_8a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = NULL,
 };
@@ -858,7 +858,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_8a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_8b[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_8b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -871,7 +871,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_8b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_9a[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_9a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -892,7 +892,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_9a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_9b[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_9b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -960,7 +960,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_11b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_1 event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_11c[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_11c[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1028,7 +1028,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_13b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_1 event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_13c[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_13c[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1065,7 +1065,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_14 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_15a[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_15a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -1088,7 +1088,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_15a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_X event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_15b[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_15b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = NULL,
 };
@@ -1111,7 +1111,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_15b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_16a[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_16a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1133,7 +1133,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_16a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_16b[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_16b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1172,7 +1172,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_17 = {
 };
 
 /* State transitions for LLC_CONN_EV_INIT_P_F_CYCLE event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_18[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_18[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -1191,7 +1191,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_18 = {
 };
 
 /* State transitions for LLC_CONN_EV_P_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_19[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_19[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[1] = NULL,
 };
@@ -1213,7 +1213,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_19 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_20a[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_20a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[2] = NULL,
@@ -1236,7 +1236,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_20a = {
 };
 
 /* State transitions for LLC_CONN_EV_BUSY_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_20b[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_20b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[2] = NULL,
@@ -1259,7 +1259,7 @@ static struct llc_conn_state_trans llc_normal_state_trans_20b = {
 };
 
 /* State transitions for LLC_CONN_EV_TX_BUFF_FULL event */
-static llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_21[] = {
+static const llc_conn_ev_qfyr_t llc_normal_ev_qfyrs_21[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -1342,7 +1342,7 @@ static struct llc_conn_state_trans *llc_normal_state_transitions[] = {
 
 /* LLC_CONN_STATE_BUSY transitions */
 /* State transitions for LLC_CONN_EV_DATA_REQ event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_1[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_1[] = {
 	[0] = llc_conn_ev_qlfy_remote_busy_eq_0,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[2] = NULL,
@@ -1362,7 +1362,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_DATA_REQ event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_2[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_2[] = {
 	[0] = llc_conn_ev_qlfy_remote_busy_eq_0,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[2] = NULL,
@@ -1382,7 +1382,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_2 = {
 };
 
 /* State transitions for LLC_CONN_EV_DATA_REQ event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_2_1[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_2_1[] = {
 	[0] = llc_conn_ev_qlfy_remote_busy_eq_1,
 	[1] = llc_conn_ev_qlfy_set_status_remote_busy,
 	[2] = NULL,
@@ -1399,7 +1399,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_2_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_CLEARED event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_3[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_3[] = {
 	[0] = llc_conn_ev_qlfy_data_flag_eq_1,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[2] = NULL,
@@ -1419,7 +1419,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_3 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_CLEARED event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_4[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_4[] = {
 	[0] = llc_conn_ev_qlfy_data_flag_eq_1,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[2] = NULL,
@@ -1439,7 +1439,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_4 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_CLEARED event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_5[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_5[] = {
 	[0] = llc_conn_ev_qlfy_data_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[2] = NULL,
@@ -1458,7 +1458,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_5 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_CLEARED event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_6[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_6[] = {
 	[0] = llc_conn_ev_qlfy_data_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[2] = NULL,
@@ -1477,7 +1477,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_6 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_CLEARED event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_7[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_7[] = {
 	[0] = llc_conn_ev_qlfy_data_flag_eq_2,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[2] = NULL,
@@ -1496,7 +1496,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_7 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_CLEARED event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_8[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_8[] = {
 	[0] = llc_conn_ev_qlfy_data_flag_eq_2,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[2] = NULL,
@@ -1515,7 +1515,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_8 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_X_UNEXPD_Ns event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_9a[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_9a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = NULL,
 };
@@ -1537,7 +1537,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_9a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0_UNEXPD_Ns event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_9b[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_9b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -1559,7 +1559,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_9b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0_UNEXPD_Ns event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_10a[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_10a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1579,7 +1579,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_10a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0_UNEXPD_Ns event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_10b[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_10b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1632,7 +1632,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_12 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_X event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_13a[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_13a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = NULL,
 };
@@ -1657,7 +1657,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_13a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_13b[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_13b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -1682,7 +1682,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_13b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_14a[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_14a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1705,7 +1705,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_14a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_14b[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_14b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1758,7 +1758,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_15b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_1 event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_15c[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_15c[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1823,7 +1823,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_17b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_1 event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_17c[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_17c[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1858,7 +1858,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_18 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_19a[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_19a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -1880,7 +1880,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_19a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_X event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_19b[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_19b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = NULL,
 };
@@ -1902,7 +1902,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_19b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_20a[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_20a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1923,7 +1923,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_20a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_20b[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_20b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -1961,7 +1961,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_21 = {
 };
 
 /* State transitions for LLC_CONN_EV_INIT_P_F_CYCLE event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_22[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_22[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -1980,7 +1980,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_22 = {
 };
 
 /* State transitions for LLC_CONN_EV_P_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_23[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_23[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[1] = NULL,
 };
@@ -2001,7 +2001,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_23 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_24a[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_24a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[2] = NULL,
@@ -2023,7 +2023,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_24a = {
 };
 
 /* State transitions for LLC_CONN_EV_BUSY_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_24b[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_24b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[2] = NULL,
@@ -2045,7 +2045,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_24b = {
 };
 
 /* State transitions for LLC_CONN_EV_REJ_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_25[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_25[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[2] = NULL,
@@ -2068,7 +2068,7 @@ static struct llc_conn_state_trans llc_busy_state_trans_25 = {
 };
 
 /* State transitions for LLC_CONN_EV_REJ_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_26[] = {
+static const llc_conn_ev_qfyr_t llc_busy_ev_qfyrs_26[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[2] = NULL,
@@ -2155,7 +2155,7 @@ static struct llc_conn_state_trans *llc_busy_state_transitions[] = {
 
 /* LLC_CONN_STATE_REJ transitions */
 /* State transitions for LLC_CONN_EV_DATA_REQ event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_1[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_1[] = {
 	[0] = llc_conn_ev_qlfy_remote_busy_eq_0,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[2] = NULL,
@@ -2174,7 +2174,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_DATA_REQ event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_2[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_2[] = {
 	[0] = llc_conn_ev_qlfy_remote_busy_eq_0,
 	[1] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[2] = NULL,
@@ -2193,7 +2193,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_2 = {
 };
 
 /* State transitions for LLC_CONN_EV_DATA_REQ event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_2_1[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_2_1[] = {
 	[0] = llc_conn_ev_qlfy_remote_busy_eq_1,
 	[1] = llc_conn_ev_qlfy_set_status_remote_busy,
 	[2] = NULL,
@@ -2211,7 +2211,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_2_1 = {
 
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_DETECTED event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_3[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_3[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -2230,7 +2230,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_3 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_DETECTED event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_4[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_4[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -2279,7 +2279,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_5b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_1_UNEXPD_Ns event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_5c[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_5c[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -2313,7 +2313,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_6 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_X event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_7a[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_7a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = NULL,
 };
@@ -2338,7 +2338,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_7a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_7b[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_7b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -2362,7 +2362,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_7b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_RSP_Fbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_8a[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_8a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -2384,7 +2384,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_8a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_I_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_8b[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_8b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -2453,7 +2453,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_10b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RR_RSP_Fbit_SET_1 event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_10c[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_10c[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -2518,7 +2518,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_12b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_RNR_RSP_Fbit_SET_1 event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_12c[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_12c[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -2553,7 +2553,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_13 = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_14a[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_14a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -2575,7 +2575,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_14a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_X event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_14b[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_14b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = NULL,
 };
@@ -2597,7 +2597,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_14b = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_CMD_Pbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_15a[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_15a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -2618,7 +2618,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_15a = {
 };
 
 /* State transitions for LLC_CONN_EV_RX_REJ_RSP_Fbit_SET_0 event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_15b[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_15b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_1,
 	[1] = NULL,
 };
@@ -2655,7 +2655,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_16 = {
 };
 
 /* State transitions for LLC_CONN_EV_INIT_P_F_CYCLE event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_17[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_17[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = NULL,
 };
@@ -2674,7 +2674,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_17 = {
 };
 
 /* State transitions for LLC_CONN_EV_REJ_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_18[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_18[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[2] = NULL,
@@ -2696,7 +2696,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_18 = {
 };
 
 /* State transitions for LLC_CONN_EV_P_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_19[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_19[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[1] = NULL,
 };
@@ -2718,7 +2718,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_19 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_20a[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_20a[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[2] = NULL,
@@ -2741,7 +2741,7 @@ static struct llc_conn_state_trans llc_reject_state_trans_20a = {
 };
 
 /* State transitions for LLC_CONN_EV_BUSY_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_20b[] = {
+static const llc_conn_ev_qfyr_t llc_reject_ev_qfyrs_20b[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[2] = NULL,
@@ -2826,7 +2826,7 @@ static struct llc_conn_state_trans *llc_reject_state_transitions[] = {
 
 /* LLC_CONN_STATE_AWAIT transitions */
 /* State transitions for LLC_CONN_EV_DATA_REQ event */
-static llc_conn_ev_qfyr_t llc_await_ev_qfyrs_1_0[] = {
+static const llc_conn_ev_qfyr_t llc_await_ev_qfyrs_1_0[] = {
 	[0] = llc_conn_ev_qlfy_set_status_refuse,
 	[1] = NULL,
 };
@@ -3182,7 +3182,7 @@ static struct llc_conn_state_trans llc_await_state_trans_13 = {
 };
 
 /* State transitions for LLC_CONN_EV_P_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_await_ev_qfyrs_14[] = {
+static const llc_conn_ev_qfyr_t llc_await_ev_qfyrs_14[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[1] = NULL,
 };
@@ -3255,7 +3255,7 @@ static struct llc_conn_state_trans *llc_await_state_transitions[] = {
 
 /* LLC_CONN_STATE_AWAIT_BUSY transitions */
 /* State transitions for LLC_CONN_EV_DATA_CONN_REQ event */
-static llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_1_0[] = {
+static const llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_1_0[] = {
 	[0] = llc_conn_ev_qlfy_set_status_refuse,
 	[1] = NULL,
 };
@@ -3271,7 +3271,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_1_0 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_CLEARED event */
-static llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_1[] = {
+static const llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_1[] = {
 	[0] = llc_conn_ev_qlfy_data_flag_eq_1,
 	[1] = NULL,
 };
@@ -3290,7 +3290,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_CLEARED event */
-static llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_2[] = {
+static const llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_2[] = {
 	[0] = llc_conn_ev_qlfy_data_flag_eq_0,
 	[1] = NULL,
 };
@@ -3308,7 +3308,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_2 = {
 };
 
 /* State transitions for LLC_CONN_EV_LOCAL_BUSY_CLEARED event */
-static llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_3[] = {
+static const llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_3[] = {
 	[0] = llc_conn_ev_qlfy_data_flag_eq_2,
 	[1] = NULL,
 };
@@ -3656,7 +3656,7 @@ static struct llc_conn_state_trans llc_await_busy_state_trans_15 = {
 };
 
 /* State transitions for LLC_CONN_EV_P_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_16[] = {
+static const llc_conn_ev_qfyr_t llc_await_busy_ev_qfyrs_16[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[1] = NULL,
 };
@@ -3731,7 +3731,7 @@ static struct llc_conn_state_trans *llc_await_busy_state_transitions[] = {
 
 /* ----------------- LLC_CONN_STATE_AWAIT_REJ transitions --------------- */
 /* State transitions for LLC_CONN_EV_DATA_CONN_REQ event */
-static llc_conn_ev_qfyr_t llc_await_reject_ev_qfyrs_1_0[] = {
+static const llc_conn_ev_qfyr_t llc_await_reject_ev_qfyrs_1_0[] = {
 	[0] = llc_conn_ev_qlfy_set_status_refuse,
 	[1] = NULL,
 };
@@ -4083,7 +4083,7 @@ static struct llc_conn_state_trans llc_await_rejct_state_trans_12 = {
 };
 
 /* State transitions for LLC_CONN_EV_P_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_await_rejct_ev_qfyrs_13[] = {
+static const llc_conn_ev_qfyr_t llc_await_rejct_ev_qfyrs_13[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[1] = NULL,
 };
@@ -4157,7 +4157,7 @@ static struct llc_conn_state_trans *llc_await_rejct_state_transitions[] = {
 /* LLC_CONN_STATE_D_CONN transitions */
 /* State transitions for LLC_CONN_EV_RX_SABME_CMD_Pbit_SET_X event,
  * cause_flag = 1 */
-static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_1[] = {
+static const llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_1[] = {
 	[0] = llc_conn_ev_qlfy_cause_flag_eq_1,
 	[1] = llc_conn_ev_qlfy_set_status_conflict,
 	[2] = NULL,
@@ -4181,7 +4181,7 @@ static struct llc_conn_state_trans llc_d_conn_state_trans_1 = {
 /* State transitions for LLC_CONN_EV_RX_SABME_CMD_Pbit_SET_X event,
  * cause_flag = 0
  */
-static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_1_1[] = {
+static const llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_1_1[] = {
 	[0] = llc_conn_ev_qlfy_cause_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_set_status_conflict,
 	[2] = NULL,
@@ -4204,7 +4204,7 @@ static struct llc_conn_state_trans llc_d_conn_state_trans_1_1 = {
 /* State transitions for LLC_CONN_EV_RX_UA_RSP_Fbit_SET_X event,
  * cause_flag = 1
  */
-static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_2[] = {
+static const llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_2[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = llc_conn_ev_qlfy_cause_flag_eq_1,
 	[2] = llc_conn_ev_qlfy_set_status_disc,
@@ -4228,7 +4228,7 @@ static struct llc_conn_state_trans llc_d_conn_state_trans_2 = {
 /* State transitions for LLC_CONN_EV_RX_UA_RSP_Fbit_SET_X event,
  * cause_flag = 0
  */
-static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_2_1[] = {
+static const llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_2_1[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = llc_conn_ev_qlfy_cause_flag_eq_0,
 	[2] = llc_conn_ev_qlfy_set_status_disc,
@@ -4264,7 +4264,7 @@ static struct llc_conn_state_trans llc_d_conn_state_trans_3 = {
 /* State transitions for LLC_CONN_EV_RX_DM_RSP_Fbit_SET_X event,
  * cause_flag = 1
  */
-static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_4[] = {
+static const llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_4[] = {
 	[0] = llc_conn_ev_qlfy_cause_flag_eq_1,
 	[1] = llc_conn_ev_qlfy_set_status_disc,
 	[2] = NULL,
@@ -4287,7 +4287,7 @@ static struct llc_conn_state_trans llc_d_conn_state_trans_4 = {
 /* State transitions for LLC_CONN_EV_RX_DM_RSP_Fbit_SET_X event,
  * cause_flag = 0
  */
-static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_4_1[] = {
+static const llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_4_1[] = {
 	[0] = llc_conn_ev_qlfy_cause_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_set_status_disc,
 	[2] = NULL,
@@ -4310,7 +4310,7 @@ static struct llc_conn_state_trans llc_d_conn_state_trans_4_1 = {
  * State transition for
  * LLC_CONN_EV_DATA_CONN_REQ event
  */
-static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_5[] = {
+static const llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_5[] = {
 	[0] = llc_conn_ev_qlfy_set_status_refuse,
 	[1] = NULL,
 };
@@ -4326,7 +4326,7 @@ static struct llc_conn_state_trans llc_d_conn_state_trans_5 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_6[] = {
+static const llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_6[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[1] = NULL,
 };
@@ -4346,7 +4346,7 @@ static struct llc_conn_state_trans llc_d_conn_state_trans_6 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event, cause_flag = 1 */
-static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_7[] = {
+static const llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_7[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_gte_n2,
 	[1] = llc_conn_ev_qlfy_cause_flag_eq_1,
 	[2] = llc_conn_ev_qlfy_set_status_failed,
@@ -4367,7 +4367,7 @@ static struct llc_conn_state_trans llc_d_conn_state_trans_7 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event, cause_flag = 0 */
-static llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_8[] = {
+static const llc_conn_ev_qfyr_t llc_d_conn_ev_qfyrs_8[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_gte_n2,
 	[1] = llc_conn_ev_qlfy_cause_flag_eq_0,
 	[2] = llc_conn_ev_qlfy_set_status_failed,
@@ -4429,7 +4429,7 @@ static struct llc_conn_state_trans llc_rst_state_trans_1 = {
 /* State transitions for LLC_CONN_EV_RX_UA_RSP_Fbit_SET_X event,
  * cause_flag = 1
  */
-static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_2[] = {
+static const llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_2[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = llc_conn_ev_qlfy_cause_flag_eq_1,
 	[2] = llc_conn_ev_qlfy_set_status_conn,
@@ -4457,7 +4457,7 @@ static struct llc_conn_state_trans llc_rst_state_trans_2 = {
 /* State transitions for LLC_CONN_EV_RX_UA_RSP_Fbit_SET_X event,
  * cause_flag = 0
  */
-static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_2_1[] = {
+static const llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_2_1[] = {
 	[0] = llc_conn_ev_qlfy_p_flag_eq_f,
 	[1] = llc_conn_ev_qlfy_cause_flag_eq_0,
 	[2] = llc_conn_ev_qlfy_set_status_rst_done,
@@ -4483,7 +4483,7 @@ static struct llc_conn_state_trans llc_rst_state_trans_2_1 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_3[] = {
+static const llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_3[] = {
 	[0] = llc_conn_ev_qlfy_s_flag_eq_1,
 	[1] = llc_conn_ev_qlfy_set_status_rst_done,
 	[2] = NULL,
@@ -4505,7 +4505,7 @@ static struct llc_conn_state_trans llc_rst_state_trans_3 = {
 /* State transitions for LLC_CONN_EV_RX_DISC_CMD_Pbit_SET_X event,
  * cause_flag = 1
  */
-static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_4[] = {
+static const llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_4[] = {
 	[0] = llc_conn_ev_qlfy_cause_flag_eq_1,
 	[1] = llc_conn_ev_qlfy_set_status_disc,
 	[2] = NULL,
@@ -4528,7 +4528,7 @@ static struct llc_conn_state_trans llc_rst_state_trans_4 = {
 /* State transitions for LLC_CONN_EV_RX_DISC_CMD_Pbit_SET_X event,
  * cause_flag = 0
  */
-static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_4_1[] = {
+static const llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_4_1[] = {
 	[0] = llc_conn_ev_qlfy_cause_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_set_status_refuse,
 	[2] = NULL,
@@ -4551,7 +4551,7 @@ static struct llc_conn_state_trans llc_rst_state_trans_4_1 = {
 /* State transitions for LLC_CONN_EV_RX_DM_RSP_Fbit_SET_X event,
  * cause_flag = 1
  */
-static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_5[] = {
+static const llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_5[] = {
 	[0] = llc_conn_ev_qlfy_cause_flag_eq_1,
 	[1] = llc_conn_ev_qlfy_set_status_disc,
 	[2] = NULL,
@@ -4574,7 +4574,7 @@ static struct llc_conn_state_trans llc_rst_state_trans_5 = {
 /* State transitions for LLC_CONN_EV_RX_DM_RSP_Fbit_SET_X event,
  * cause_flag = 0
  */
-static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_5_1[] = {
+static const llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_5_1[] = {
 	[0] = llc_conn_ev_qlfy_cause_flag_eq_0,
 	[1] = llc_conn_ev_qlfy_set_status_refuse,
 	[2] = NULL,
@@ -4594,7 +4594,7 @@ static struct llc_conn_state_trans llc_rst_state_trans_5_1 = {
 };
 
 /* State transitions for DATA_CONN_REQ event */
-static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_6[] = {
+static const llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_6[] = {
 	[0] = llc_conn_ev_qlfy_set_status_refuse,
 	[1] = NULL,
 };
@@ -4610,7 +4610,7 @@ static struct llc_conn_state_trans llc_rst_state_trans_6 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_7[] = {
+static const llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_7[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[1] = llc_conn_ev_qlfy_s_flag_eq_0,
 	[2] = NULL,
@@ -4631,7 +4631,7 @@ static struct llc_conn_state_trans llc_rst_state_trans_7 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_8[] = {
+static const llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_8[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_gte_n2,
 	[1] = llc_conn_ev_qlfy_s_flag_eq_0,
 	[2] = llc_conn_ev_qlfy_cause_flag_eq_1,
@@ -4652,7 +4652,7 @@ static struct llc_conn_state_trans llc_rst_state_trans_8 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_8_1[] = {
+static const llc_conn_ev_qfyr_t llc_rst_ev_qfyrs_8_1[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_gte_n2,
 	[1] = llc_conn_ev_qlfy_s_flag_eq_0,
 	[2] = llc_conn_ev_qlfy_cause_flag_eq_0,
@@ -4786,7 +4786,7 @@ static struct llc_conn_state_trans llc_error_state_trans_6 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_error_ev_qfyrs_7[] = {
+static const llc_conn_ev_qfyr_t llc_error_ev_qfyrs_7[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_lt_n2,
 	[1] = NULL,
 };
@@ -4806,7 +4806,7 @@ static struct llc_conn_state_trans llc_error_state_trans_7 = {
 };
 
 /* State transitions for LLC_CONN_EV_ACK_TMR_EXP event */
-static llc_conn_ev_qfyr_t llc_error_ev_qfyrs_8[] = {
+static const llc_conn_ev_qfyr_t llc_error_ev_qfyrs_8[] = {
 	[0] = llc_conn_ev_qlfy_retry_cnt_gte_n2,
 	[1] = NULL,
 };
@@ -4828,7 +4828,7 @@ static struct llc_conn_state_trans llc_error_state_trans_8 = {
 };
 
 /* State transitions for LLC_CONN_EV_DATA_CONN_REQ event */
-static llc_conn_ev_qfyr_t llc_error_ev_qfyrs_9[] = {
+static const llc_conn_ev_qfyr_t llc_error_ev_qfyrs_9[] = {
 	[0] = llc_conn_ev_qlfy_set_status_refuse,
 	[1] = NULL,
 };
diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
index 75baa2b..81a61fc 100644
--- a/net/llc/llc_conn.c
+++ b/net/llc/llc_conn.c
@@ -406,7 +406,7 @@ static struct llc_conn_state_trans *llc_qualify_conn_ev(struct sock *sk,
 							struct sk_buff *skb)
 {
 	struct llc_conn_state_trans **next_trans;
-	llc_conn_ev_qfyr_t *next_qualifier;
+	const llc_conn_ev_qfyr_t *next_qualifier;
 	struct llc_conn_state_ev *ev = llc_conn_ev(skb);
 	struct llc_sock *llc = llc_sk(sk);
 	struct llc_conn_state *curr_state =
