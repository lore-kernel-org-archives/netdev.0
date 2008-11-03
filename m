From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH 5/6] nets: clean up net/ipv4/ip_sockglue.c tcp_output.c
Date: Mon, 3 Nov 2008 16:19:56 +0800
Message-ID: <20081103081956.GF14553@ubuntu>
References: <20081102074446.GA12140@ubuntu> <490DEAD3.3030202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:59217 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668AbYKCITs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 03:19:48 -0500
Content-Disposition: inline
In-Reply-To: <490DEAD3.3030202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[PATCH 5/6] clean up net/ipv4/ip_sockglue.c tcp_output.c

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/ipv4/ip_sockglue.c |   32 ++++++++++++++++----------------
 net/ipv4/tcp_output.c  |    8 ++++----
 2 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 465abf0..e976efe 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -94,7 +94,7 @@ static void ip_cmsg_recv_opts(struct msghdr *msg, struct sk_buff *skb)
 static void ip_cmsg_recv_retopts(struct msghdr *msg, struct sk_buff *skb)
 {
 	unsigned char optbuf[sizeof(struct ip_options) + 40];
-	struct ip_options * opt = (struct ip_options*)optbuf;
+	struct ip_options * opt = (struct ip_options *)optbuf;
 
 	if (IPCB(skb)->opt.optlen == 0)
 		return;
@@ -411,7 +411,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			    int optname, char __user *optval, int optlen)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	int val=0,err;
+	int val = 0, err;
 
 	if (((1<<optname) & ((1<<IP_PKTINFO) | (1<<IP_RECVTTL) |
 			     (1<<IP_RECVOPTS) | (1<<IP_RECVTOS) |
@@ -437,7 +437,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	/* If optlen==0, it is equivalent to val == 0 */
 
 	if (ip_mroute_opt(optname))
-		return ip_mroute_setsockopt(sk,optname,optval,optlen);
+		return ip_mroute_setsockopt(sk, optname, optval, optlen);
 
 	err = 0;
 	lock_sock(sk);
@@ -549,7 +549,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			goto e_inval;
 		if (optlen<1)
 			goto e_inval;
-		if (val==-1)
+		if (val == -1)
 			val = 1;
 		if (val < 0 || val > 255)
 			goto e_inval;
@@ -573,12 +573,12 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 
 		err = -EFAULT;
 		if (optlen >= sizeof(struct ip_mreqn)) {
-			if (copy_from_user(&mreq,optval,sizeof(mreq)))
+			if (copy_from_user(&mreq, optval, sizeof(mreq)))
 				break;
 		} else {
 			memset(&mreq, 0, sizeof(mreq));
 			if (optlen >= sizeof(struct in_addr) &&
-			    copy_from_user(&mreq.imr_address,optval,sizeof(struct in_addr)))
+			    copy_from_user(&mreq.imr_address, optval, sizeof(struct in_addr)))
 				break;
 		}
 
@@ -626,11 +626,11 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			goto e_inval;
 		err = -EFAULT;
 		if (optlen >= sizeof(struct ip_mreqn)) {
-			if (copy_from_user(&mreq,optval,sizeof(mreq)))
+			if (copy_from_user(&mreq, optval, sizeof(mreq)))
 				break;
 		} else {
 			memset(&mreq, 0, sizeof(mreq));
-			if (copy_from_user(&mreq,optval,sizeof(struct ip_mreq)))
+			if (copy_from_user(&mreq, optval, sizeof(struct ip_mreq)))
 				break;
 		}
 
@@ -808,7 +808,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			err = -ENOBUFS;
 			break;
 		}
-		gsf = kmalloc(optlen,GFP_KERNEL);
+		gsf = kmalloc(optlen, GFP_KERNEL);
 		if (!gsf) {
 			err = -ENOBUFS;
 			break;
@@ -828,7 +828,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			goto mc_msf_out;
 		}
 		msize = IP_MSFILTER_SIZE(gsf->gf_numsrc);
-		msf = kmalloc(msize,GFP_KERNEL);
+		msf = kmalloc(msize, GFP_KERNEL);
 		if (!msf) {
 			err = -ENOBUFS;
 			goto mc_msf_out;
@@ -971,9 +971,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 		return -EOPNOTSUPP;
 
 	if (ip_mroute_opt(optname))
-		return ip_mroute_getsockopt(sk,optname,optval,optlen);
+		return ip_mroute_getsockopt(sk, optname, optval, optlen);
 
-	if (get_user(len,optlen))
+	if (get_user(len, optlen))
 		return -EFAULT;
 	if (len < 0)
 		return -EINVAL;
@@ -984,7 +984,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_OPTIONS:
 	{
 		unsigned char optbuf[sizeof(struct ip_options)+40];
-		struct ip_options * opt = (struct ip_options*)optbuf;
+		struct ip_options * opt = (struct ip_options *)optbuf;
 		opt->optlen = 0;
 		if (inet->opt)
 			memcpy(optbuf, inet->opt,
@@ -1154,13 +1154,13 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 		len = 1;
 		if (put_user(len, optlen))
 			return -EFAULT;
-		if (copy_to_user(optval,&ucval,1))
+		if (copy_to_user(optval, &ucval, 1))
 			return -EFAULT;
 	} else {
 		len = min_t(unsigned int, sizeof(int), len);
 		if (put_user(len, optlen))
 			return -EFAULT;
-		if (copy_to_user(optval,&val,len))
+		if (copy_to_user(optval, &val, len))
 			return -EFAULT;
 	}
 	return 0;
@@ -1178,7 +1178,7 @@ int ip_getsockopt(struct sock *sk, int level,
 			!ip_mroute_opt(optname)) {
 		int len;
 
-		if (get_user(len,optlen))
+		if (get_user(len, optlen))
 			return -EFAULT;
 
 		lock_sock(sk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ba85d88..a524627 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -42,7 +42,7 @@
 /* People can turn this off for buggy TCP's found in printers etc. */
 int sysctl_tcp_retrans_collapse __read_mostly = 1;
 
-/* People can turn this on to  work with those rare, broken TCPs that
+/* People can turn this on to work with those rare, broken TCPs that
  * interpret the window field as a signed quantity.
  */
 int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
@@ -484,7 +484,7 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 	}
 	if (likely(sysctl_tcp_window_scaling)) {
 		opts->ws = tp->rx_opt.rcv_wscale;
-		if(likely(opts->ws))
+		if (likely(opts->ws))
 			size += TCPOLEN_WSCALE_ALIGNED;
 	}
 	if (likely(sysctl_tcp_sack)) {
@@ -526,7 +526,7 @@ static unsigned tcp_synack_options(struct sock *sk,
 
 	if (likely(ireq->wscale_ok)) {
 		opts->ws = ireq->rcv_wscale;
-		if(likely(opts->ws))
+		if (likely(opts->ws))
 			size += TCPOLEN_WSCALE_ALIGNED;
 	}
 	if (likely(doing_ts)) {
@@ -1172,7 +1172,7 @@ static int tcp_init_tso_segs(struct sock *sk, struct sk_buff *skb,
 
 static inline int tcp_minshall_check(const struct tcp_sock *tp)
 {
-	return after(tp->snd_sml,tp->snd_una) &&
+	return after(tp->snd_sml, tp->snd_una) &&
 		!after(tp->snd_sml, tp->snd_nxt);
 }
 
-- 
1.5.6.3

