From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH]  tcp: mark tcp_congestion_ops read_mostly
Date: Wed, 9 Mar 2011 16:02:20 -0800
Message-ID: <20110309160220.1a2db73e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42319 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab1CJACY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 19:02:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/ipv4/tcp_bic.c       |    2 +-
 net/ipv4/tcp_cubic.c     |    2 +-
 net/ipv4/tcp_highspeed.c |    2 +-
 net/ipv4/tcp_htcp.c      |    2 +-
 net/ipv4/tcp_hybla.c     |    2 +-
 net/ipv4/tcp_illinois.c  |    2 +-
 net/ipv4/tcp_lp.c        |    2 +-
 net/ipv4/tcp_scalable.c  |    2 +-
 net/ipv4/tcp_vegas.c     |    2 +-
 net/ipv4/tcp_veno.c      |    2 +-
 net/ipv4/tcp_westwood.c  |    2 +-
 net/ipv4/tcp_yeah.c      |    2 +-
 12 files changed, 12 insertions(+), 12 deletions(-)

--- a/net/ipv4/tcp_bic.c	2011-03-09 14:21:25.015099639 -0800
+++ b/net/ipv4/tcp_bic.c	2011-03-09 14:21:46.291314688 -0800
@@ -209,7 +209,7 @@ static void bictcp_acked(struct sock *sk
 }
 
 
-static struct tcp_congestion_ops bictcp = {
+static struct tcp_congestion_ops bictcp __read_mostly = {
 	.init		= bictcp_init,
 	.ssthresh	= bictcp_recalc_ssthresh,
 	.cong_avoid	= bictcp_cong_avoid,
--- a/net/ipv4/tcp_cubic.c	2011-03-09 14:20:30.818552460 -0800
+++ b/net/ipv4/tcp_cubic.c	2011-03-09 14:23:24.524309323 -0800
@@ -405,7 +405,7 @@ static void bictcp_acked(struct sock *sk
 		hystart_update(sk, delay);
 }
 
-static struct tcp_congestion_ops cubictcp = {
+static struct tcp_congestion_ops cubictcp __read_mostly = {
 	.init		= bictcp_init,
 	.ssthresh	= bictcp_recalc_ssthresh,
 	.cong_avoid	= bictcp_cong_avoid,
--- a/net/ipv4/tcp_highspeed.c	2011-03-09 14:21:25.055100042 -0800
+++ b/net/ipv4/tcp_highspeed.c	2011-03-09 14:22:00.187455217 -0800
@@ -158,7 +158,7 @@ static u32 hstcp_ssthresh(struct sock *s
 }
 
 
-static struct tcp_congestion_ops tcp_highspeed = {
+static struct tcp_congestion_ops tcp_highspeed __read_mostly = {
 	.init		= hstcp_init,
 	.ssthresh	= hstcp_ssthresh,
 	.cong_avoid	= hstcp_cong_avoid,
--- a/net/ipv4/tcp_htcp.c	2011-03-09 14:21:25.075100244 -0800
+++ b/net/ipv4/tcp_htcp.c	2011-03-09 14:22:07.451528700 -0800
@@ -284,7 +284,7 @@ static void htcp_state(struct sock *sk,
 	}
 }
 
-static struct tcp_congestion_ops htcp = {
+static struct tcp_congestion_ops htcp __read_mostly = {
 	.init		= htcp_init,
 	.ssthresh	= htcp_recalc_ssthresh,
 	.cong_avoid	= htcp_cong_avoid,
--- a/net/ipv4/tcp_hybla.c	2011-03-09 14:21:25.095100447 -0800
+++ b/net/ipv4/tcp_hybla.c	2011-03-09 14:22:20.603661788 -0800
@@ -162,7 +162,7 @@ static void hybla_cong_avoid(struct sock
 	tp->snd_cwnd = min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp);
 }
 
-static struct tcp_congestion_ops tcp_hybla = {
+static struct tcp_congestion_ops tcp_hybla __read_mostly = {
 	.init		= hybla_init,
 	.ssthresh	= tcp_reno_ssthresh,
 	.min_cwnd	= tcp_reno_min_cwnd,
--- a/net/ipv4/tcp_illinois.c	2011-03-09 14:21:25.115100649 -0800
+++ b/net/ipv4/tcp_illinois.c	2011-03-09 14:22:24.823704499 -0800
@@ -322,7 +322,7 @@ static void tcp_illinois_info(struct soc
 	}
 }
 
-static struct tcp_congestion_ops tcp_illinois = {
+static struct tcp_congestion_ops tcp_illinois __read_mostly = {
 	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_illinois_init,
 	.ssthresh	= tcp_illinois_ssthresh,
--- a/net/ipv4/tcp_lp.c	2011-03-09 14:21:25.155101052 -0800
+++ b/net/ipv4/tcp_lp.c	2011-03-09 14:22:32.879786056 -0800
@@ -313,7 +313,7 @@ static void tcp_lp_pkts_acked(struct soc
 	lp->last_drop = tcp_time_stamp;
 }
 
-static struct tcp_congestion_ops tcp_lp = {
+static struct tcp_congestion_ops tcp_lp __read_mostly = {
 	.flags = TCP_CONG_RTT_STAMP,
 	.init = tcp_lp_init,
 	.ssthresh = tcp_reno_ssthresh,
--- a/net/ipv4/tcp_scalable.c	2011-03-09 14:21:25.175101255 -0800
+++ b/net/ipv4/tcp_scalable.c	2011-03-09 14:22:37.179829592 -0800
@@ -35,7 +35,7 @@ static u32 tcp_scalable_ssthresh(struct
 }
 
 
-static struct tcp_congestion_ops tcp_scalable = {
+static struct tcp_congestion_ops tcp_scalable __read_mostly = {
 	.ssthresh	= tcp_scalable_ssthresh,
 	.cong_avoid	= tcp_scalable_cong_avoid,
 	.min_cwnd	= tcp_reno_min_cwnd,
--- a/net/ipv4/tcp_vegas.c	2011-03-09 14:21:25.195101458 -0800
+++ b/net/ipv4/tcp_vegas.c	2011-03-09 14:22:40.999868286 -0800
@@ -304,7 +304,7 @@ void tcp_vegas_get_info(struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(tcp_vegas_get_info);
 
-static struct tcp_congestion_ops tcp_vegas = {
+static struct tcp_congestion_ops tcp_vegas __read_mostly = {
 	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_vegas_init,
 	.ssthresh	= tcp_reno_ssthresh,
--- a/net/ipv4/tcp_veno.c	2011-03-09 14:21:25.215101658 -0800
+++ b/net/ipv4/tcp_veno.c	2011-03-09 14:22:45.163910441 -0800
@@ -201,7 +201,7 @@ static u32 tcp_veno_ssthresh(struct sock
 		return max(tp->snd_cwnd >> 1U, 2U);
 }
 
-static struct tcp_congestion_ops tcp_veno = {
+static struct tcp_congestion_ops tcp_veno __read_mostly = {
 	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_veno_init,
 	.ssthresh	= tcp_veno_ssthresh,
--- a/net/ipv4/tcp_westwood.c	2011-03-09 14:21:25.235101861 -0800
+++ b/net/ipv4/tcp_westwood.c	2011-03-09 14:22:48.999949301 -0800
@@ -272,7 +272,7 @@ static void tcp_westwood_info(struct soc
 }
 
 
-static struct tcp_congestion_ops tcp_westwood = {
+static struct tcp_congestion_ops tcp_westwood __read_mostly = {
 	.init		= tcp_westwood_init,
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
--- a/net/ipv4/tcp_yeah.c	2011-03-09 14:21:25.255102064 -0800
+++ b/net/ipv4/tcp_yeah.c	2011-03-09 14:22:54.108001044 -0800
@@ -225,7 +225,7 @@ static u32 tcp_yeah_ssthresh(struct sock
 	return tp->snd_cwnd - reduction;
 }
 
-static struct tcp_congestion_ops tcp_yeah = {
+static struct tcp_congestion_ops tcp_yeah __read_mostly = {
 	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_yeah_init,
 	.ssthresh	= tcp_yeah_ssthresh,
