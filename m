From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Crazy TCP bug (keepalive flood?) in 2.6.32?
Date: Mon, 11 Jan 2010 15:02:34 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1001111459340.14108@wel-95.cs.helsinki.fi>
References: <200912261703.49067.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59235 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026Ab0AKNCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 08:02:36 -0500
In-Reply-To: <200912261703.49067.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Dec 2009, Denys Fedoryshchenko wrote:

> Few more dumps. I notice:
> 1)Ack always equal 1
> 2)It is usually first segment of data sent (?)
> 
> Maybe some value not initialised properly?
> 
> 
> 17:03:50.406118 IP (tos 0x0, ttl 64, id 57958, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.199.39.1472: Flags [.], seq 0:1452, ack 1, 
> win 7479, length 1452
> 17:03:50.407413 IP (tos 0x0, ttl 64, id 57959, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.199.39.1472: Flags [.], seq 0:1452, ack 1, 
> win 7479, length 1452
> 17:03:50.408516 IP (tos 0x0, ttl 64, id 57960, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.199.39.1472: Flags [.], seq 0:1452, ack 1, 
> win 7479, length 1452
> 17:03:50.409553 IP (tos 0x0, ttl 64, id 57961, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.199.39.1472: Flags [.], seq 0:1452, ack 1, 
> win 7479, length 1452
> 17:03:50.410424 IP (tos 0x0, ttl 64, id 57962, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.199.39.1472: Flags [.], seq 0:1452, ack 1, 
> win 7479, length 1452
> 
> 
> 
> 17:04:39.801149 IP (tos 0x0, ttl 64, id 19431, offset 0, flags [DF], proto TCP 
> (6), length 517)
>     194.146.153.114.8080 > 172.16.107.14.1405: Flags [P.], cksum 0x51c6 
> (correct), seq 0:477, ack 1, win 8730, length 477
> 17:04:39.802538 IP (tos 0x0, ttl 64, id 19432, offset 0, flags [DF], proto TCP 
> (6), length 517)
>     194.146.153.114.8080 > 172.16.107.14.1405: Flags [P.], cksum 0x51c6 
> (correct), seq 0:477, ack 1, win 8730, length 477
> 17:04:39.803438 IP (tos 0x0, ttl 64, id 19433, offset 0, flags [DF], proto TCP 
> (6), length 517)
>     194.146.153.114.8080 > 172.16.107.14.1405: Flags [P.], cksum 0x51c6 
> (correct), seq 0:477, ack 1, win 8730, length 477
> 17:04:39.804251 IP (tos 0x0, ttl 64, id 19434, offset 0, flags [DF], proto TCP 
> (6), length 517)
>     194.146.153.114.8080 > 172.16.107.14.1405: Flags [P.], cksum 0x51c6 
> (correct), seq 0:477, ack 1, win 8730, length 477
> 17:04:39.805050 IP (tos 0x0, ttl 64, id 19435, offset 0, flags [DF], proto TCP 
> (6), length 517)
>     194.146.153.114.8080 > 172.16.107.14.1405: Flags [P.], cksum 0x51c6 
> (correct), seq 0:477, ack 1, win 8730, length 477
> 
> 17:06:22.123862 IP (tos 0x0, ttl 64, id 25912, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.180.148.50101: Flags [.], seq 0:1452, ack 1, 
> win 108, length 1452
> 17:06:22.124440 IP (tos 0x0, ttl 64, id 25913, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.180.148.50101: Flags [.], seq 0:1452, ack 1, 
> win 108, length 1452
> 17:06:22.125600 IP (tos 0x0, ttl 64, id 25914, offset 0, flags [DF], proto TCP 
> (6), length 1492)
>     194.146.153.114.8080 > 172.16.180.148.50101: Flags [.], seq 0:1452, ack 1, 
> win 108, length 1452
> ^C17:06:22.126243 IP (tos 0x0, ttl 64, id 25915, offset 0, flags [DF], proto 
> TCP (6), length 1492)
>     194.146.153.114.8080 > 172.16.180.148.50101: Flags [.], seq 0:1452, ack 1, 
> win 108, length 1452
> 
> 
> 
> 17:06:43.404279 IP (tos 0x0, ttl 64, id 10279, offset 0, flags [DF], proto TCP 
> (6), length 768)
>     194.146.153.114.8080 > 172.16.199.151.49404: Flags [FP.], cksum 0x4ac3 
> (correct), seq 0:728, ack 1, win 9816, length 728
> 17:06:43.405819 IP (tos 0x0, ttl 64, id 10281, offset 0, flags [DF], proto TCP 
> (6), length 768)
>     194.146.153.114.8080 > 172.16.199.151.49404: Flags [FP.], cksum 0x4ac3 
> (correct), seq 0:728, ack 1, win 9816, length 728
> 17:06:43.406670 IP (tos 0x0, ttl 64, id 10282, offset 0, flags [DF], proto TCP 
> (6), length 768)
>     194.146.153.114.8080 > 172.16.199.151.49404: Flags [FP.], cksum 0x4ac3 
> (correct), seq 0:728, ack 1, win 9816, length 728
> 17:06:43.407821 IP (tos 0x0, ttl 64, id 10283, offset 0, flags [DF], proto TCP 
> (6), length 768)
>     194.146.153.114.8080 > 172.16.199.151.49404: Flags [FP.], cksum 0x4ac3 
> (correct), seq 0:728, ack 1, win 9816, length 728
> 
> 
> 17:07:09.933303 IP (tos 0x0, ttl 64, id 41731, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 17:07:09.934305 IP (tos 0x0, ttl 64, id 41732, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 17:07:09.935076 IP (tos 0x0, ttl 64, id 41733, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 17:07:09.935887 IP (tos 0x0, ttl 64, id 41734, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 17:07:09.937096 IP (tos 0x0, ttl 64, id 41735, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 17:07:09.938083 IP (tos 0x0, ttl 64, id 41736, offset 0, flags [DF], proto TCP 
> (6), length 555)
>     194.146.153.114.8080 > 172.16.175.130.1692: Flags [P.], cksum 0x7d98 
> (correct), seq 0:515, ack 1, win 6432, length 515
> 
> 17:09:21.672761 IP (tos 0x0, ttl 64, id 48515, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 17:09:21.673756 IP (tos 0x0, ttl 64, id 48516, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 17:09:21.674574 IP (tos 0x0, ttl 64, id 48517, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 17:09:21.675440 IP (tos 0x0, ttl 64, id 48518, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 17:09:21.676625 IP (tos 0x0, ttl 64, id 48519, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 17:09:21.678963 IP (tos 0x0, ttl 64, id 48521, offset 0, flags [DF], proto TCP 
> (6), length 412)
>     194.146.153.114.8080 > 172.16.163.219.47653: Flags [P.], cksum 0x584c 
> (correct), seq 0:372, ack 1, win 181, length 372
> 
> 17:11:12.032679 IP (tos 0x0, ttl 64, id 39699, offset 0, flags [DF], proto TCP 
> (6), length 552)
>     194.146.153.114.8080 > 172.16.15.13.63145: Flags [P.], cksum 0x1559 
> (correct), seq 0:512, ack 1, win 6432, length 512
> 17:11:12.033882 IP (tos 0x0, ttl 64, id 39700, offset 0, flags [DF], proto TCP 
> (6), length 552)
>     194.146.153.114.8080 > 172.16.15.13.63145: Flags [P.], cksum 0x1559 
> (correct), seq 0:512, ack 1, win 6432, length 512
> 17:11:12.034835 IP (tos 0x0, ttl 64, id 39701, offset 0, flags [DF], proto TCP 
> (6), length 552)
>     194.146.153.114.8080 > 172.16.15.13.63145: Flags [P.], cksum 0x1559 
> (correct), seq 0:512, ack 1, win 6432, length 512
> 17:11:12.035720 IP (tos 0x0, ttl 64, id 39702, offset 0, flags [DF], proto TCP 
> (6), length 552)
>     194.146.153.114.8080 > 172.16.15.13.63145: Flags [P.], cksum 0x1559 
> (correct), seq 0:512, ack 1, win 6432, length 512
> 

Can you see if the RTO lower bound is violated (I added some printing of 
vars there too already now if it turns out to be something):

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 65b8ebf..d84469f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -327,6 +327,22 @@ static void do_pmtu_discovery(struct sock *sk, struct iphdr *iph, u32 mtu)
  * is probably better.
  *
  */
+static int prints = 0;
+
+static void tcp_debug_rto(struct sock *sk, struct sk_buff *skb, u32 remaining, int locked)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (prints++ < 1000) {
+		printk("rto: %u (%u >> 3 + %u, %u) time: %u sent: %u pen: %u %lu rem: %u %s\n",
+		       icsk->icsk_rto, tp->srtt, tp->rttvar,
+		       (u32)icsk->icsk_backoff,
+		       tcp_time_stamp, TCP_SKB_CB(skb)->when,
+		       (u32)icsk->icsk_pending, icsk->icsk_timeout, remaining,
+		       locked ? "locked" : "");
+	}
+}
 
 void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 {
@@ -409,6 +425,11 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		inet_csk(sk)->icsk_rto = __tcp_set_rto(tp) <<
 					 icsk->icsk_backoff;
 		tcp_bound_rto(sk);
+		if (icsk->icsk_rto < TCP_RTO_MIN) {
+			if (net_ratelimit())
+				printk("lower bound violation: %u\n", icsk->icsk_rto);
+			icsk->icsk_rto = TCP_RTO_MIN;
+		}
 
 		skb = tcp_write_queue_head(sk);
 		BUG_ON(!skb);
@@ -417,14 +438,17 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 				tcp_time_stamp - TCP_SKB_CB(skb)->when);
 
 		if (remaining) {
+			tcp_debug_rto(sk, skb, remaining, 0);
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 						  remaining, TCP_RTO_MAX);
 		} else if (sock_owned_by_user(sk)) {
+			tcp_debug_rto(sk, skb, remaining, 1);
 			/* RTO revert clocked out retransmission,
 			 * but socket is locked. Will defer. */
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 						  HZ/20, TCP_RTO_MAX);
 		} else {
+			tcp_debug_rto(sk, skb, remaining, 0);
 			/* RTO revert clocked out retransmission.
 			 * Will retransmit now */
 			tcp_retransmit_timer(sk);
