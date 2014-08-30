From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2] tcp: whitespace fixes
Date: Fri, 29 Aug 2014 23:32:05 -0700
Message-ID: <20140829233205.2bfa469c@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:38079 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946AbaH3GcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2014 02:32:09 -0400
Received: by mail-pd0-f177.google.com with SMTP id r10so1892828pdi.36
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 23:32:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix places where there is space before tab, long lines, and
awkward if(){, double spacing etc. Add blank line after declaration/initialization.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
v2 get rid of unnecessary double spacing

 net/ipv4/tcp_bic.c       |   11 +--
 net/ipv4/tcp_cong.c      |    5 -
 net/ipv4/tcp_cubic.c     |   18 +++--
 net/ipv4/tcp_diag.c      |    5 -
 net/ipv4/tcp_highspeed.c |  145 +++++++++++++++++++++++------------------------
 net/ipv4/tcp_htcp.c      |    6 +
 net/ipv4/tcp_hybla.c     |    1 
 net/ipv4/tcp_illinois.c  |    3 
 net/ipv4/tcp_ipv4.c      |    5 -
 net/ipv4/tcp_probe.c     |    6 -
 net/ipv4/tcp_scalable.c  |    2 
 net/ipv4/tcp_vegas.c     |    3 
 net/ipv4/tcp_veno.c      |    1 
 net/ipv4/tcp_westwood.c  |    7 --
 net/ipv4/tcp_yeah.c      |    9 --
 15 files changed, 104 insertions(+), 123 deletions(-)

--- a/net/ipv4/tcp_bic.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_bic.c	2014-08-29 09:29:20.251831932 -0700
@@ -17,7 +17,6 @@
 #include <linux/module.h>
 #include <net/tcp.h>
 
-
 #define BICTCP_BETA_SCALE    1024	/* Scale factor beta calculation
 					 * max_cwnd = snd_cwnd * beta
 					 */
@@ -46,11 +45,10 @@ MODULE_PARM_DESC(initial_ssthresh, "init
 module_param(smooth_part, int, 0644);
 MODULE_PARM_DESC(smooth_part, "log(B/(B*Smin))/log(B/(B-1))+B, # of RTT from Wmax-B to Wmax");
 
-
 /* BIC TCP Parameters */
 struct bictcp {
 	u32	cnt;		/* increase cwnd by 1 after ACKs */
-	u32 	last_max_cwnd;	/* last maximum snd_cwnd */
+	u32	last_max_cwnd;	/* last maximum snd_cwnd */
 	u32	loss_cwnd;	/* congestion window at last loss */
 	u32	last_cwnd;	/* the last snd_cwnd */
 	u32	last_time;	/* time when updated last_cwnd */
@@ -103,7 +101,7 @@ static inline void bictcp_update(struct
 
 	/* binary increase */
 	if (cwnd < ca->last_max_cwnd) {
-		__u32 	dist = (ca->last_max_cwnd - cwnd)
+		__u32	dist = (ca->last_max_cwnd - cwnd)
 			/ BICTCP_B;
 
 		if (dist > max_increment)
@@ -154,7 +152,6 @@ static void bictcp_cong_avoid(struct soc
 		bictcp_update(ca, tp->snd_cwnd);
 		tcp_cong_avoid_ai(tp, ca->cnt);
 	}
-
 }
 
 /*
@@ -177,7 +174,6 @@ static u32 bictcp_recalc_ssthresh(struct
 
 	ca->loss_cwnd = tp->snd_cwnd;
 
-
 	if (tp->snd_cwnd <= low_window)
 		return max(tp->snd_cwnd >> 1U, 2U);
 	else
@@ -188,6 +184,7 @@ static u32 bictcp_undo_cwnd(struct sock
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct bictcp *ca = inet_csk_ca(sk);
+
 	return max(tp->snd_cwnd, ca->loss_cwnd);
 }
 
@@ -206,12 +203,12 @@ static void bictcp_acked(struct sock *sk
 
 	if (icsk->icsk_ca_state == TCP_CA_Open) {
 		struct bictcp *ca = inet_csk_ca(sk);
+
 		cnt -= ca->delayed_ack >> ACK_RATIO_SHIFT;
 		ca->delayed_ack += cnt;
 	}
 }
 
-
 static struct tcp_congestion_ops bictcp __read_mostly = {
 	.init		= bictcp_init,
 	.ssthresh	= bictcp_recalc_ssthresh,
--- a/net/ipv4/tcp_cubic.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_cubic.c	2014-08-29 09:29:20.251831932 -0700
@@ -82,12 +82,13 @@ MODULE_PARM_DESC(hystart_ack_delta, "spa
 /* BIC TCP Parameters */
 struct bictcp {
 	u32	cnt;		/* increase cwnd by 1 after ACKs */
-	u32 	last_max_cwnd;	/* last maximum snd_cwnd */
+	u32	last_max_cwnd;	/* last maximum snd_cwnd */
 	u32	loss_cwnd;	/* congestion window at last loss */
 	u32	last_cwnd;	/* the last snd_cwnd */
 	u32	last_time;	/* time when updated last_cwnd */
 	u32	bic_origin_point;/* origin point of bic function */
-	u32	bic_K;		/* time to origin point from the beginning of the current epoch */
+	u32	bic_K;		/* time to origin point
+				   from the beginning of the current epoch */
 	u32	delay_min;	/* min delay (msec << 3) */
 	u32	epoch_start;	/* beginning of an epoch */
 	u32	ack_cnt;	/* number of acks */
@@ -219,7 +220,7 @@ static inline void bictcp_update(struct
 	ca->last_time = tcp_time_stamp;
 
 	if (ca->epoch_start == 0) {
-		ca->epoch_start = tcp_time_stamp;	/* record the beginning of an epoch */
+		ca->epoch_start = tcp_time_stamp;	/* record beginning */
 		ca->ack_cnt = 1;			/* start counting */
 		ca->tcp_cwnd = cwnd;			/* syn with cubic */
 
@@ -263,9 +264,9 @@ static inline void bictcp_update(struct
 
 	/* c/rtt * (t-K)^3 */
 	delta = (cube_rtt_scale * offs * offs * offs) >> (10+3*BICTCP_HZ);
-	if (t < ca->bic_K)                                	/* below origin*/
+	if (t < ca->bic_K)                            /* below origin*/
 		bic_target = ca->bic_origin_point - delta;
-	else                                                	/* above origin*/
+	else                                          /* above origin*/
 		bic_target = ca->bic_origin_point + delta;
 
 	/* cubic function - calc bictcp_cnt*/
@@ -285,13 +286,14 @@ static inline void bictcp_update(struct
 	/* TCP Friendly */
 	if (tcp_friendliness) {
 		u32 scale = beta_scale;
+
 		delta = (cwnd * scale) >> 3;
 		while (ca->ack_cnt > delta) {		/* update tcp cwnd */
 			ca->ack_cnt -= delta;
 			ca->tcp_cwnd++;
 		}
 
-		if (ca->tcp_cwnd > cwnd){	/* if bic is slower than tcp */
+		if (ca->tcp_cwnd > cwnd) {	/* if bic is slower than tcp */
 			delta = ca->tcp_cwnd - cwnd;
 			max_cnt = cwnd / delta;
 			if (ca->cnt > max_cnt)
@@ -320,7 +322,6 @@ static void bictcp_cong_avoid(struct soc
 		bictcp_update(ca, tp->snd_cwnd);
 		tcp_cong_avoid_ai(tp, ca->cnt);
 	}
-
 }
 
 static u32 bictcp_recalc_ssthresh(struct sock *sk)
@@ -452,7 +453,8 @@ static int __init cubictcp_register(void
 	 * based on SRTT of 100ms
 	 */
 
-	beta_scale = 8*(BICTCP_BETA_SCALE+beta)/ 3 / (BICTCP_BETA_SCALE - beta);
+	beta_scale = 8*(BICTCP_BETA_SCALE+beta) / 3
+		/ (BICTCP_BETA_SCALE - beta);
 
 	cube_rtt_scale = (bic_scale * 10);	/* 1024*c/rtt */
 
--- a/net/ipv4/tcp_yeah.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_yeah.c	2014-08-29 09:35:34.201681542 -0700
@@ -54,10 +54,8 @@ static void tcp_yeah_init(struct sock *s
 	/* Ensure the MD arithmetic works.  This is somewhat pedantic,
 	 * since I don't think we will see a cwnd this large. :) */
 	tp->snd_cwnd_clamp = min_t(u32, tp->snd_cwnd_clamp, 0xffffffff/128);
-
 }
 
-
 static void tcp_yeah_pkts_acked(struct sock *sk, u32 pkts_acked, s32 rtt_us)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -84,7 +82,7 @@ static void tcp_yeah_cong_avoid(struct s
 		/* Scalable */
 
 		tp->snd_cwnd_cnt += yeah->pkts_acked;
-		if (tp->snd_cwnd_cnt > min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT)){
+		if (tp->snd_cwnd_cnt > min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT)) {
 			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
 				tp->snd_cwnd++;
 			tp->snd_cwnd_cnt = 0;
@@ -120,7 +118,6 @@ static void tcp_yeah_cong_avoid(struct s
 	 */
 
 	if (after(ack, yeah->vegas.beg_snd_nxt)) {
-
 		/* We do the Vegas calculations only if we got enough RTT
 		 * samples that we can be reasonably sure that we got
 		 * at least one RTT sample that wasn't from a delayed ACK.
@@ -189,7 +186,6 @@ static void tcp_yeah_cong_avoid(struct s
 			}
 
 			yeah->lastQ = queue;
-
 		}
 
 		/* Save the extent of the current window so we can use this
@@ -205,7 +201,8 @@ static void tcp_yeah_cong_avoid(struct s
 	}
 }
 
-static u32 tcp_yeah_ssthresh(struct sock *sk) {
+static u32 tcp_yeah_ssthresh(struct sock *sk)
+{
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct yeah *yeah = inet_csk_ca(sk);
 	u32 reduction;
--- a/net/ipv4/tcp_cong.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_cong.c	2014-08-29 09:29:20.251831932 -0700
@@ -142,7 +142,6 @@ static int __init tcp_congestion_default
 }
 late_initcall(tcp_congestion_default);
 
-
 /* Build string with list of available congestion control values */
 void tcp_get_available_congestion_control(char *buf, size_t maxlen)
 {
@@ -154,7 +153,6 @@ void tcp_get_available_congestion_contro
 		offs += snprintf(buf + offs, maxlen - offs,
 				 "%s%s",
 				 offs == 0 ? "" : " ", ca->name);
-
 	}
 	rcu_read_unlock();
 }
@@ -186,7 +184,6 @@ void tcp_get_allowed_congestion_control(
 		offs += snprintf(buf + offs, maxlen - offs,
 				 "%s%s",
 				 offs == 0 ? "" : " ", ca->name);
-
 	}
 	rcu_read_unlock();
 }
@@ -230,7 +227,6 @@ out:
 	return ret;
 }
 
-
 /* Change congestion control for socket */
 int tcp_set_congestion_control(struct sock *sk, const char *name)
 {
@@ -337,6 +333,7 @@ EXPORT_SYMBOL_GPL(tcp_reno_cong_avoid);
 u32 tcp_reno_ssthresh(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
+
 	return max(tp->snd_cwnd >> 1U, 2U);
 }
 EXPORT_SYMBOL_GPL(tcp_reno_ssthresh);
--- a/net/ipv4/tcp_diag.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_diag.c	2014-08-29 09:30:57.584301235 -0700
@@ -9,7 +9,6 @@
  *      2 of the License, or (at your option) any later version.
  */
 
-
 #include <linux/module.h>
 #include <linux/inet_diag.h>
 
@@ -35,13 +34,13 @@ static void tcp_diag_get_info(struct soc
 }
 
 static void tcp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct inet_diag_req_v2 *r, struct nlattr *bc)
+			  struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	inet_diag_dump_icsk(&tcp_hashinfo, skb, cb, r, bc);
 }
 
 static int tcp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
-		struct inet_diag_req_v2 *req)
+			     struct inet_diag_req_v2 *req)
 {
 	return inet_diag_dump_one_icsk(&tcp_hashinfo, in_skb, nlh, req);
 }
--- a/net/ipv4/tcp_highspeed.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_highspeed.c	2014-08-29 09:31:16.184392165 -0700
@@ -9,7 +9,6 @@
 #include <linux/module.h>
 #include <net/tcp.h>
 
-
 /* From AIMD tables from RFC 3649 appendix B,
  * with fixed-point MD scaled <<8.
  */
@@ -17,78 +16,78 @@ static const struct hstcp_aimd_val {
 	unsigned int cwnd;
 	unsigned int md;
 } hstcp_aimd_vals[] = {
- {     38,  128, /*  0.50 */ },
- {    118,  112, /*  0.44 */ },
- {    221,  104, /*  0.41 */ },
- {    347,   98, /*  0.38 */ },
- {    495,   93, /*  0.37 */ },
- {    663,   89, /*  0.35 */ },
- {    851,   86, /*  0.34 */ },
- {   1058,   83, /*  0.33 */ },
- {   1284,   81, /*  0.32 */ },
- {   1529,   78, /*  0.31 */ },
- {   1793,   76, /*  0.30 */ },
- {   2076,   74, /*  0.29 */ },
- {   2378,   72, /*  0.28 */ },
- {   2699,   71, /*  0.28 */ },
- {   3039,   69, /*  0.27 */ },
- {   3399,   68, /*  0.27 */ },
- {   3778,   66, /*  0.26 */ },
- {   4177,   65, /*  0.26 */ },
- {   4596,   64, /*  0.25 */ },
- {   5036,   62, /*  0.25 */ },
- {   5497,   61, /*  0.24 */ },
- {   5979,   60, /*  0.24 */ },
- {   6483,   59, /*  0.23 */ },
- {   7009,   58, /*  0.23 */ },
- {   7558,   57, /*  0.22 */ },
- {   8130,   56, /*  0.22 */ },
- {   8726,   55, /*  0.22 */ },
- {   9346,   54, /*  0.21 */ },
- {   9991,   53, /*  0.21 */ },
- {  10661,   52, /*  0.21 */ },
- {  11358,   52, /*  0.20 */ },
- {  12082,   51, /*  0.20 */ },
- {  12834,   50, /*  0.20 */ },
- {  13614,   49, /*  0.19 */ },
- {  14424,   48, /*  0.19 */ },
- {  15265,   48, /*  0.19 */ },
- {  16137,   47, /*  0.19 */ },
- {  17042,   46, /*  0.18 */ },
- {  17981,   45, /*  0.18 */ },
- {  18955,   45, /*  0.18 */ },
- {  19965,   44, /*  0.17 */ },
- {  21013,   43, /*  0.17 */ },
- {  22101,   43, /*  0.17 */ },
- {  23230,   42, /*  0.17 */ },
- {  24402,   41, /*  0.16 */ },
- {  25618,   41, /*  0.16 */ },
- {  26881,   40, /*  0.16 */ },
- {  28193,   39, /*  0.16 */ },
- {  29557,   39, /*  0.15 */ },
- {  30975,   38, /*  0.15 */ },
- {  32450,   38, /*  0.15 */ },
- {  33986,   37, /*  0.15 */ },
- {  35586,   36, /*  0.14 */ },
- {  37253,   36, /*  0.14 */ },
- {  38992,   35, /*  0.14 */ },
- {  40808,   35, /*  0.14 */ },
- {  42707,   34, /*  0.13 */ },
- {  44694,   33, /*  0.13 */ },
- {  46776,   33, /*  0.13 */ },
- {  48961,   32, /*  0.13 */ },
- {  51258,   32, /*  0.13 */ },
- {  53677,   31, /*  0.12 */ },
- {  56230,   30, /*  0.12 */ },
- {  58932,   30, /*  0.12 */ },
- {  61799,   29, /*  0.12 */ },
- {  64851,   28, /*  0.11 */ },
- {  68113,   28, /*  0.11 */ },
- {  71617,   27, /*  0.11 */ },
- {  75401,   26, /*  0.10 */ },
- {  79517,   26, /*  0.10 */ },
- {  84035,   25, /*  0.10 */ },
- {  89053,   24, /*  0.10 */ },
+	{     38,  128, /*  0.50 */ },
+	{    118,  112, /*  0.44 */ },
+	{    221,  104, /*  0.41 */ },
+	{    347,   98, /*  0.38 */ },
+	{    495,   93, /*  0.37 */ },
+	{    663,   89, /*  0.35 */ },
+	{    851,   86, /*  0.34 */ },
+	{   1058,   83, /*  0.33 */ },
+	{   1284,   81, /*  0.32 */ },
+	{   1529,   78, /*  0.31 */ },
+	{   1793,   76, /*  0.30 */ },
+	{   2076,   74, /*  0.29 */ },
+	{   2378,   72, /*  0.28 */ },
+	{   2699,   71, /*  0.28 */ },
+	{   3039,   69, /*  0.27 */ },
+	{   3399,   68, /*  0.27 */ },
+	{   3778,   66, /*  0.26 */ },
+	{   4177,   65, /*  0.26 */ },
+	{   4596,   64, /*  0.25 */ },
+	{   5036,   62, /*  0.25 */ },
+	{   5497,   61, /*  0.24 */ },
+	{   5979,   60, /*  0.24 */ },
+	{   6483,   59, /*  0.23 */ },
+	{   7009,   58, /*  0.23 */ },
+	{   7558,   57, /*  0.22 */ },
+	{   8130,   56, /*  0.22 */ },
+	{   8726,   55, /*  0.22 */ },
+	{   9346,   54, /*  0.21 */ },
+	{   9991,   53, /*  0.21 */ },
+	{  10661,   52, /*  0.21 */ },
+	{  11358,   52, /*  0.20 */ },
+	{  12082,   51, /*  0.20 */ },
+	{  12834,   50, /*  0.20 */ },
+	{  13614,   49, /*  0.19 */ },
+	{  14424,   48, /*  0.19 */ },
+	{  15265,   48, /*  0.19 */ },
+	{  16137,   47, /*  0.19 */ },
+	{  17042,   46, /*  0.18 */ },
+	{  17981,   45, /*  0.18 */ },
+	{  18955,   45, /*  0.18 */ },
+	{  19965,   44, /*  0.17 */ },
+	{  21013,   43, /*  0.17 */ },
+	{  22101,   43, /*  0.17 */ },
+	{  23230,   42, /*  0.17 */ },
+	{  24402,   41, /*  0.16 */ },
+	{  25618,   41, /*  0.16 */ },
+	{  26881,   40, /*  0.16 */ },
+	{  28193,   39, /*  0.16 */ },
+	{  29557,   39, /*  0.15 */ },
+	{  30975,   38, /*  0.15 */ },
+	{  32450,   38, /*  0.15 */ },
+	{  33986,   37, /*  0.15 */ },
+	{  35586,   36, /*  0.14 */ },
+	{  37253,   36, /*  0.14 */ },
+	{  38992,   35, /*  0.14 */ },
+	{  40808,   35, /*  0.14 */ },
+	{  42707,   34, /*  0.13 */ },
+	{  44694,   33, /*  0.13 */ },
+	{  46776,   33, /*  0.13 */ },
+	{  48961,   32, /*  0.13 */ },
+	{  51258,   32, /*  0.13 */ },
+	{  53677,   31, /*  0.12 */ },
+	{  56230,   30, /*  0.12 */ },
+	{  58932,   30, /*  0.12 */ },
+	{  61799,   29, /*  0.12 */ },
+	{  64851,   28, /*  0.11 */ },
+	{  68113,   28, /*  0.11 */ },
+	{  71617,   27, /*  0.11 */ },
+	{  75401,   26, /*  0.10 */ },
+	{  79517,   26, /*  0.10 */ },
+	{  84035,   25, /*  0.10 */ },
+	{  89053,   24, /*  0.10 */ },
 };
 
 #define HSTCP_AIMD_MAX	ARRAY_SIZE(hstcp_aimd_vals)
--- a/net/ipv4/tcp_htcp.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_htcp.c	2014-08-29 09:29:20.251831932 -0700
@@ -98,7 +98,8 @@ static inline void measure_rtt(struct so
 	}
 }
 
-static void measure_achieved_throughput(struct sock *sk, u32 pkts_acked, s32 rtt)
+static void measure_achieved_throughput(struct sock *sk,
+					u32 pkts_acked, s32 rtt)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
@@ -148,8 +149,8 @@ static inline void htcp_beta_update(stru
 	if (use_bandwidth_switch) {
 		u32 maxB = ca->maxB;
 		u32 old_maxB = ca->old_maxB;
-		ca->old_maxB = ca->maxB;
 
+		ca->old_maxB = ca->maxB;
 		if (!between(5 * maxB, 4 * old_maxB, 6 * old_maxB)) {
 			ca->beta = BETA_MIN;
 			ca->modeswitch = 0;
@@ -270,6 +271,7 @@ static void htcp_state(struct sock *sk,
 	case TCP_CA_Open:
 		{
 			struct htcp *ca = inet_csk_ca(sk);
+
 			if (ca->undo_last_cong) {
 				ca->last_cong = jiffies;
 				ca->undo_last_cong = 0;
--- a/net/ipv4/tcp_hybla.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_hybla.c	2014-08-29 09:29:20.251831932 -0700
@@ -29,7 +29,6 @@ static int rtt0 = 25;
 module_param(rtt0, int, 0644);
 MODULE_PARM_DESC(rtt0, "reference rout trip time (ms)");
 
-
 /* This is called to refresh values for hybla parameters */
 static inline void hybla_recalc_param (struct sock *sk)
 {
--- a/net/ipv4/tcp_illinois.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_illinois.c	2014-08-29 09:29:20.251831932 -0700
@@ -284,7 +284,7 @@ static void tcp_illinois_cong_avoid(stru
 		delta = (tp->snd_cwnd_cnt * ca->alpha) >> ALPHA_SHIFT;
 		if (delta >= tp->snd_cwnd) {
 			tp->snd_cwnd = min(tp->snd_cwnd + delta / tp->snd_cwnd,
-					   (u32) tp->snd_cwnd_clamp);
+					   (u32)tp->snd_cwnd_clamp);
 			tp->snd_cwnd_cnt = 0;
 		}
 	}
@@ -299,7 +299,6 @@ static u32 tcp_illinois_ssthresh(struct
 	return max(tp->snd_cwnd - ((tp->snd_cwnd * ca->beta) >> BETA_SHIFT), 2U);
 }
 
-
 /* Extract info for Tcp socket info provided via netlink. */
 static void tcp_illinois_info(struct sock *sk, u32 ext,
 			      struct sk_buff *skb)
--- a/net/ipv4/tcp_ipv4.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_ipv4.c	2014-08-29 09:29:20.251831932 -0700
@@ -90,7 +90,6 @@ int sysctl_tcp_tw_reuse __read_mostly;
 int sysctl_tcp_low_latency __read_mostly;
 EXPORT_SYMBOL(sysctl_tcp_low_latency);
 
-
 #ifdef CONFIG_TCP_MD5SIG
 static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 			       __be32 daddr, __be32 saddr, const struct tcphdr *th);
@@ -1269,7 +1268,7 @@ struct request_sock_ops tcp_request_sock
 	.send_ack	=	tcp_v4_reqsk_send_ack,
 	.destructor	=	tcp_v4_reqsk_destructor,
 	.send_reset	=	tcp_v4_send_reset,
-	.syn_ack_timeout = 	tcp_syn_ack_timeout,
+	.syn_ack_timeout =	tcp_syn_ack_timeout,
 };
 
 static const struct tcp_request_sock_ops tcp_request_sock_ipv4_ops = {
@@ -2183,7 +2182,7 @@ int tcp_seq_open(struct inode *inode, st
 
 	s = ((struct seq_file *)file->private_data)->private;
 	s->family		= afinfo->family;
-	s->last_pos 		= 0;
+	s->last_pos		= 0;
 	return 0;
 }
 EXPORT_SYMBOL(tcp_seq_open);
--- a/net/ipv4/tcp_probe.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_probe.c	2014-08-29 09:32:30.264759160 -0700
@@ -83,7 +83,6 @@ static struct {
 	struct tcp_log	*log;
 } tcp_probe;
 
-
 static inline int tcp_probe_used(void)
 {
 	return (tcp_probe.head - tcp_probe.tail) & (bufsize - 1);
@@ -101,7 +100,6 @@ static inline int tcp_probe_avail(void)
 		si4.sin_addr.s_addr = inet->inet_##mem##addr;	\
 	} while (0)						\
 
-
 /*
  * Hook inserted to be called before each receive packet.
  * Note: arguments must match tcp_rcv_established()!
@@ -194,8 +192,8 @@ static int tcpprobe_sprint(char *tbuf, i
 
 	return scnprintf(tbuf, n,
 			"%lu.%09lu %pISpc %pISpc %d %#x %#x %u %u %u %u %u\n",
-			(unsigned long) tv.tv_sec,
-			(unsigned long) tv.tv_nsec,
+			(unsigned long)tv.tv_sec,
+			(unsigned long)tv.tv_nsec,
 			&p->src, &p->dst, p->length, p->snd_nxt, p->snd_una,
 			p->snd_cwnd, p->ssthresh, p->snd_wnd, p->srtt, p->rcv_wnd);
 }
--- a/net/ipv4/tcp_scalable.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_scalable.c	2014-08-29 09:29:20.251831932 -0700
@@ -31,10 +31,10 @@ static void tcp_scalable_cong_avoid(stru
 static u32 tcp_scalable_ssthresh(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
+
 	return max(tp->snd_cwnd - (tp->snd_cwnd>>TCP_SCALABLE_MD_SCALE), 2U);
 }
 
-
 static struct tcp_congestion_ops tcp_scalable __read_mostly = {
 	.ssthresh	= tcp_scalable_ssthresh,
 	.cong_avoid	= tcp_scalable_cong_avoid,
--- a/net/ipv4/tcp_westwood.c	2014-08-29 09:29:20.255831952 -0700
+++ b/net/ipv4/tcp_westwood.c	2014-08-29 09:35:02.017519189 -0700
@@ -42,7 +42,6 @@ struct westwood {
 	u8     reset_rtt_min;    /* Reset RTT min to next RTT sample*/
 };
 
-
 /* TCP Westwood functions and constants */
 #define TCP_WESTWOOD_RTT_MIN   (HZ/20)	/* 50ms */
 #define TCP_WESTWOOD_INIT_RTT  (20*HZ)	/* maybe too conservative?! */
@@ -153,7 +152,6 @@ static inline void update_rtt_min(struct
 		w->rtt_min = min(w->rtt, w->rtt_min);
 }
 
-
 /*
  * @westwood_fast_bw
  * It is called when we are in fast path. In particular it is called when
@@ -208,7 +206,6 @@ static inline u32 westwood_acked_count(s
 	return w->cumul_ack;
 }
 
-
 /*
  * TCP Westwood
  * Here limit is evaluated as Bw estimation*RTTmin (for obtaining it
@@ -219,6 +216,7 @@ static u32 tcp_westwood_bw_rttmin(const
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct westwood *w = inet_csk_ca(sk);
+
 	return max_t(u32, (w->bw_est * w->rtt_min) / tp->mss_cache, 2);
 }
 
@@ -254,12 +252,12 @@ static void tcp_westwood_event(struct so
 	}
 }
 
-
 /* Extract info for Tcp socket info provided via netlink. */
 static void tcp_westwood_info(struct sock *sk, u32 ext,
 			      struct sk_buff *skb)
 {
 	const struct westwood *ca = inet_csk_ca(sk);
+
 	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
 		struct tcpvegas_info info = {
 			.tcpv_enabled = 1,
@@ -271,7 +269,6 @@ static void tcp_westwood_info(struct soc
 	}
 }
 
-
 static struct tcp_congestion_ops tcp_westwood __read_mostly = {
 	.init		= tcp_westwood_init,
 	.ssthresh	= tcp_reno_ssthresh,
--- a/net/ipv4/tcp_vegas.c	2014-08-29 00:01:28.735653084 -0700
+++ b/net/ipv4/tcp_vegas.c	2014-08-29 09:34:14.009277744 -0700
@@ -51,7 +51,6 @@ MODULE_PARM_DESC(beta, "upper bound of p
 module_param(gamma, int, 0644);
 MODULE_PARM_DESC(gamma, "limit on increase (scale by 2)");
 
-
 /* There are several situations when we must "re-start" Vegas:
  *
  *  o when a connection is established
@@ -133,7 +132,6 @@ EXPORT_SYMBOL_GPL(tcp_vegas_pkts_acked);
 
 void tcp_vegas_state(struct sock *sk, u8 ca_state)
 {
-
 	if (ca_state == TCP_CA_Open)
 		vegas_enable(sk);
 	else
@@ -285,7 +283,6 @@ static void tcp_vegas_cong_avoid(struct
 	/* Use normal slow start */
 	else if (tp->snd_cwnd <= tp->snd_ssthresh)
 		tcp_slow_start(tp, acked);
-
 }
 
 /* Extract info for Tcp socket info provided via netlink. */
--- a/net/ipv4/tcp_veno.c	2014-08-09 08:39:57.752179443 -0700
+++ b/net/ipv4/tcp_veno.c	2014-08-29 09:35:39.841710031 -0700
@@ -175,7 +175,6 @@ static void tcp_veno_cong_avoid(struct s
 				} else
 					tp->snd_cwnd_cnt++;
 			}
-
 		}
 		if (tp->snd_cwnd < 2)
 			tp->snd_cwnd = 2;
