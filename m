From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH 2/6] nets: clean up net/ipv4/ipip.c raw.c tcp.c
	tcp_minisocks.c tcp_yeah.c xfrm4_policy.c
Date: Mon, 3 Nov 2008 16:19:21 +0800
Message-ID: <20081103081921.GC14553@ubuntu>
References: <20081102074446.GA12140@ubuntu> <490DEAD3.3030202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:51718 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754760AbYKCITO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 03:19:14 -0500
Content-Disposition: inline
In-Reply-To: <490DEAD3.3030202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
 [PATCH 2/6] clean up net/ipv4/
 ipip.c raw.c tcp.c tcp_minisocks.c tcp_yeah.c xfrm4_policy.c

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/ipv4/ipip.c          |    2 +-
 net/ipv4/raw.c           |    8 ++++----
 net/ipv4/tcp.c           |    6 +++---
 net/ipv4/tcp_minisocks.c |    2 +-
 net/ipv4/tcp_yeah.c      |    4 ++--
 net/ipv4/xfrm4_policy.c  |    2 +-
 6 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 29609d2..b3c3d7b 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -281,7 +281,7 @@ static int ipip_err(struct sk_buff *skb, u32 info)
    8 bytes of packet payload. It means, that precise relaying of
    ICMP in the real Internet is absolutely infeasible.
  */
-	struct iphdr *iph = (struct iphdr*)skb->data;
+	struct iphdr *iph = (struct iphdr *)skb->data;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct ip_tunnel *t;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index cd97574..998fcff 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -247,7 +247,7 @@ static void raw_err(struct sock *sk, struct sk_buff *skb, u32 info)
 	}
 
 	if (inet->recverr) {
-		struct iphdr *iph = (struct iphdr*)skb->data;
+		struct iphdr *iph = (struct iphdr *)skb->data;
 		u8 *payload = skb->data + (iph->ihl << 2);
 
 		if (inet->hdrincl)
@@ -465,7 +465,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	 */
 
 	if (msg->msg_namelen) {
-		struct sockaddr_in *usin = (struct sockaddr_in*)msg->msg_name;
+		struct sockaddr_in *usin = (struct sockaddr_in *)msg->msg_name;
 		err = -EINVAL;
 		if (msg->msg_namelen < sizeof(*usin))
 			goto out;
@@ -851,7 +851,7 @@ struct proto raw_prot = {
 static struct sock *raw_get_first(struct seq_file *seq)
 {
 	struct sock *sk;
-	struct raw_iter_state* state = raw_seq_private(seq);
+	struct raw_iter_state *state = raw_seq_private(seq);
 
 	for (state->bucket = 0; state->bucket < RAW_HTABLE_SIZE;
 			++state->bucket) {
@@ -868,7 +868,7 @@ found:
 
 static struct sock *raw_get_next(struct seq_file *seq, struct sock *sk)
 {
-	struct raw_iter_state* state = raw_seq_private(seq);
+	struct raw_iter_state *state = raw_seq_private(seq);
 
 	do {
 		sk = sk_next(sk);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index eccb716..60c28ad 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1681,7 +1681,7 @@ void tcp_set_state(struct sock *sk, int state)
 			inet_put_port(sk);
 		/* fall through */
 	default:
-		if (oldstate==TCP_ESTABLISHED)
+		if (oldstate == TCP_ESTABLISHED)
 			TCP_DEC_STATS(sock_net(sk), TCP_MIB_CURRESTAB);
 	}
 
@@ -1691,7 +1691,7 @@ void tcp_set_state(struct sock *sk, int state)
 	sk->sk_state = state;
 
 #ifdef STATE_TRACE
-	SOCK_DEBUG(sk, "TCP sk=%p, State %s -> %s\n",sk, statename[oldstate],statename[state]);
+	SOCK_DEBUG(sk, "TCP sk=%p, State %s -> %s\n", sk, statename[oldstate], statename[state]);
 #endif
 }
 EXPORT_SYMBOL_GPL(tcp_set_state);
@@ -2651,7 +2651,7 @@ EXPORT_SYMBOL(tcp_md5_hash_key);
 
 void tcp_done(struct sock *sk)
 {
-	if(sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
+	if (sk->sk_state == TCP_SYN_SENT || sk->sk_state == TCP_SYN_RECV)
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_ATTEMPTFAILS);
 
 	tcp_set_state(sk, TCP_CLOSE);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 779f2e9..f67effb 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -491,7 +491,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
  *	as a request_sock.
  */
 
-struct sock *tcp_check_req(struct sock *sk,struct sk_buff *skb,
+struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			   struct request_sock *req,
 			   struct request_sock **prev)
 {
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index e03b101..9ec843a 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -83,7 +83,7 @@ static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 	else if (!yeah->doing_reno_now) {
 		/* Scalable */
 
-		tp->snd_cwnd_cnt+=yeah->pkts_acked;
+		tp->snd_cwnd_cnt += yeah->pkts_acked;
 		if (tp->snd_cwnd_cnt > min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT)){
 			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
 				tp->snd_cwnd++;
@@ -224,7 +224,7 @@ static u32 tcp_yeah_ssthresh(struct sock *sk) {
 
 		reduction = max( reduction, tp->snd_cwnd >> TCP_YEAH_DELTA);
 	} else
-		reduction = max(tp->snd_cwnd>>1,2U);
+		reduction = max(tp->snd_cwnd>>1, 2U);
 
 	yeah->fast_count = 0;
 	yeah->reno_count = max(yeah->reno_count>>1, 2U);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index c63de0a..f9a775b 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -65,7 +65,7 @@ __xfrm4_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 
 	read_lock_bh(&policy->lock);
 	for (dst = policy->bundles; dst; dst = dst->next) {
-		struct xfrm_dst *xdst = (struct xfrm_dst*)dst;
+		struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
 		if (xdst->u.rt.fl.oif == fl->oif &&	/*XXX*/
 		    xdst->u.rt.fl.fl4_dst == fl->fl4_dst &&
 		    xdst->u.rt.fl.fl4_src == fl->fl4_src &&
-- 
1.5.6.3

