From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Assertions in latest kernels
Date: Wed, 23 Jan 2008 11:17:05 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801231043220.31652@kivilampi-30.cs.helsinki.fi>
References: <OF331AFFAC.CEF61228-ON652573D9.002CF47B-652573D9.002E0A84@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47169 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbYAWJRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 04:17:08 -0500
In-Reply-To: <OF331AFFAC.CEF61228-ON652573D9.002CF47B-652573D9.002E0A84@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Jan 2008, Krishna Kumar2 wrote:

> David Miller <davem@davemloft.net> wrote on 01/23/2008 01:27:23 PM:
> 
> > > iperf with multiple threads almost always gets these 4, *especially*
> when I
> > > do some batching :).
> > >
> > > static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int
> flag)
> > > {
> > >       ...
> > >       if (WARN_ON(!tp->sacked_out && tp->fackets_out))
> > >             tp->fackets_out = 0;
> > >       ...
> > > }
> >
> > Does this assertion show up first or do you get the other TCP
> > ones first?  It might be important, in that if you get the
> > others ones first that corrupted state might be what leads to
> > this one.
> 
> Hi Dave,
> 
> I looked at my *old* messages file and found this assert (2506) was first
> to hit (atleast in
> two messages file). It hit 5 times, then I got a different one that I had
> not reported earlier:
> 
> "KERNEL: assertion (packets <= tp->packets_out) failed at
> net/ipv4/tcp_input.c (2139)"
> 
> (though this was hidden in my report under the panic for tcp_input.c:2528.
> 
> Then another two thousand times of the 2506 asserts.
> 
> Today I installed the latest untouched kernel, rebooted system and got the
> following errors
> in sequence, but no 2506 errors (which I have always got when running
> batching in the last
> 2-3 weeks):
> 
> Jan 22 02:07:55 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:07:56 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:07:56 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:07:57 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:07:58 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:07:59 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:07:59 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:00 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:01 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:01 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:02 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:03 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:03 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:04 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:05 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:06 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:06 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:07 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
> Jan 22 02:08:07 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:08 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:09 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:10 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:10 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:11 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:12 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:12 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:13 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:14 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:15 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:15 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
> Jan 22 02:08:16 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
> Jan 22 02:08:16 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
> Jan 22 02:08:17 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:18 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:18 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> Jan 22 02:08:19 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
> Jan 22 02:08:19 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
> 
> and so on for another 700 counts.
>
> The unique asserts are:
>       1767: tcp_verify_left_out (from tcp_entry_frto)
>       2169: tcp_verify_left_out (from tcp_mark_head_lost)
>       2528: tcp_verify_left_out (from tcp_fastretrans_alert)
>       3063: tcp_verify_left_out (from tcp_process_frto)
> (where 2169 seems to preceed any other asserts)

Once you get one of these, you'll get a large number of them, maybe I 
should just change it to WARN_ON_ONCE to stop confusing people with the 
rest.

> The other two asserts that I got only with batching are:
>       2139: BUG_TRAP(packets <= tp->packets_out); (in tcp_mark_head_lost)
>       2506: WARN_ON(!tp->sacked_out && tp->fackets_out) (in
> tcp_fastretrans_alert)
> (where 2506 always seems to preceed any other asserts).

It's almost impossible to know which of these is the main cause and the 
first occuring due to reasons I'll not copy here. What a strange thing
that it has been super quiet on this front until now everybody is seeing 
it, could there be something unrelated to TCP which has broken it all 
recently?

Good thing is that you seem to be able to reproduce it were nicely.
Please try with this beauty below... Hopefully got it correctly matching 
to mainline, in contrast to version I sent Dave Y., there's some added 
candy which catches highest_sack corruption as well, at least it compiles 
already :-).

-- 
 i.

[PATCH] TCP: debug S+L (for mainline, not compatible with mm or net-2.6.25)

---
 include/net/tcp.h     |    8 +++-
 net/ipv4/tcp_input.c  |   10 ++++
 net/ipv4/tcp_ipv4.c   |  123 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c |   21 ++++++--
 4 files changed, 155 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cb5b033..9ea62f9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -272,6 +272,8 @@ DECLARE_SNMP_STAT(struct tcp_mib, tcp_statistics);
 #define TCP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(tcp_statistics, field, val)
 #define TCP_ADD_STATS_USER(field, val)	SNMP_ADD_STATS_USER(tcp_statistics, field, val)
 
+extern void			tcp_verify_wq(struct sock *sk);
+
 extern void			tcp_v4_err(struct sk_buff *skb, u32);
 
 extern void			tcp_shutdown (struct sock *sk, int how);
@@ -769,7 +771,11 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 }
 
 /* Use define here intentionally to get WARN_ON location shown at the caller */
-#define tcp_verify_left_out(tp)	WARN_ON(tcp_left_out(tp) > tp->packets_out)
+#define tcp_verify_left_out(tp)	\
+	do { \
+		WARN_ON(tcp_left_out(tp) > tp->packets_out); \
+		tcp_verify_wq((struct sock *)tp); \
+	} while(0)
 
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
 extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b39f0d8..1e4db05 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2529,6 +2529,10 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	if (do_lost || tcp_head_timedout(sk))
 		tcp_update_scoreboard(sk);
 	tcp_cwnd_down(sk, flag);
+
+	WARN_ON(tcp_write_queue_head(sk) == NULL);
+	WARN_ON(!tp->packets_out);
+
 	tcp_xmit_retransmit_queue(sk);
 }
 
@@ -2744,6 +2748,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 		tcp_clear_all_retrans_hints(tp);
 	}
 
+	tcp_verify_left_out(tp);
+
 	if (flag & FLAG_ACKED) {
 		u32 pkts_acked = prior_packets - tp->packets_out;
 		const struct tcp_congestion_ops *ca_ops
@@ -3070,6 +3076,8 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	prior_fackets = tp->fackets_out;
 	prior_in_flight = tcp_packets_in_flight(tp);
 
+	tcp_verify_left_out(tp);
+
 	if (!(flag&FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
 		/* Window is constant, pure forward advance.
 		 * No more checks are required.
@@ -3131,6 +3139,8 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag&FLAG_NOT_DUP))
 		dst_confirm(sk->sk_dst_cache);
 
+	tcp_verify_left_out(tp);
+
 	return 1;
 
 no_queue:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 652c323..9c56153 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -108,6 +108,129 @@ struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
 	.lhash_wait  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.lhash_wait),
 };
 
+void tcp_print_queue(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+	char s[50+1];
+	char h[50+1];
+	int idx = 0;
+	int i;
+
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+
+		for (i = 0; i < tcp_skb_pcount(skb); i++) {
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) {
+				s[idx] = 'S';
+				if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+					s[idx] = 'B';
+
+			} else if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST) {
+				s[idx] = 'L';
+			} else {
+				s[idx] = ' ';
+			}
+			if (s[idx] != ' ' && skb->len < tp->mss_cache)
+				s[idx] += 'a' - 'A';
+
+			if (i == 0) {
+				if ((TCP_SKB_CB(skb)->seq == tp->highest_sack) &&
+				    (tp->fastpath_skb_hint == skb))
+					h[idx] = 'x';
+				else if (TCP_SKB_CB(skb)->seq == tp->highest_sack)
+					h[idx] = 'h';
+				else if (tp->fastpath_skb_hint == skb)
+					h[idx] = 'f';
+				else
+					h[idx] = '+';
+			} else {
+				h[idx] = '-';
+			}
+
+			if (++idx >= 50) {
+				s[idx] = 0;
+				h[idx] = 0;
+				printk(KERN_ERR "TCP wq(s) %s\n", s);
+				printk(KERN_ERR "TCP wq(h) %s\n", h);
+				idx = 0;
+			}
+		}
+	}
+	if (idx) {
+		s[idx] = '<';
+		s[idx+1] = 0;
+		h[idx] = '<';
+		h[idx+1] = 0;
+		printk(KERN_ERR "TCP wq(s) %s\n", s);
+		printk(KERN_ERR "TCP wq(h) %s\n", h);
+	}
+	printk(KERN_ERR "l%u s%u f%u p%u seq: su%u hs%u sn%u\n",
+		tp->lost_out, tp->sacked_out, tp->fackets_out, tp->packets_out,
+		tp->snd_una, tp->highest_sack, tp->snd_nxt);
+}
+
+void tcp_verify_wq(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	u32 lost = 0;
+	u32 sacked = 0;
+	u32 packets = 0;
+	u32 fackets = 0;
+	int hint_failed_at = -1;
+	int highest_sack_corrupt = 0;
+	struct sk_buff *skb;
+
+	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
+
+		if (WARN_ON((tp->fastpath_skb_hint == skb) &&
+			    packets != tp->fastpath_cnt_hint))
+			hint_failed_at = packets;
+
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) {
+			sacked += tcp_skb_pcount(skb);
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+				printk(KERN_ERR "Sacked bitmap S+L: %u %u-%u/%u\n",
+					TCP_SKB_CB(skb)->sacked,
+					TCP_SKB_CB(skb)->end_seq - tp->snd_una,
+					TCP_SKB_CB(skb)->seq - tp->snd_una,
+					tp->snd_una);
+			fackets = sacked;
+			if (WARN_ON(after(TCP_SKB_CB(skb)->seq, tp->highest_sack)))
+				highest_sack_corrupt = 1;
+		}
+		if (TCP_SKB_CB(skb)->sacked & TCPCB_LOST)
+			lost += tcp_skb_pcount(skb);
+
+		packets += tcp_skb_pcount(skb);
+	}
+
+	WARN_ON(lost != tp->lost_out);
+	WARN_ON(tcp_is_sack(tp) && (sacked != tp->sacked_out));
+	WARN_ON(packets != tp->packets_out);
+	WARN_ON(fackets != tp->fackets_out);
+
+	if ((lost != tp->lost_out) ||
+	    (tcp_is_sack(tp) && (sacked != tp->sacked_out)) ||
+	    (packets != tp->packets_out) ||
+	    (fackets != tp->fackets_out) ||
+	    (hint_failed_at != -1) ||
+	    highest_sack_corrupt) {
+		printk(KERN_ERR "P: %u L: %u vs %u S: %u vs %u F: %u vs %u H: %u vs %u w: %u-%u (%u, %u)\n",
+			tp->packets_out,
+			lost, tp->lost_out,
+			sacked, tp->sacked_out,
+			fackets, tp->fackets_out,
+			hint_failed_at, tp->fastpath_cnt_hint,
+			tp->snd_una, tp->snd_nxt,
+			tp->rx_opt.sack_ok, highest_sack_corrupt);
+		tcp_print_queue(sk);
+	}
+}
+
 static int tcp_v4_get_port(struct sock *sk, unsigned short snum)
 {
 	return inet_csk_get_port(&tcp_hashinfo, sk, snum,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f4c1eef..cce7531 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -768,10 +768,9 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsigned int mss
 			tp->lost_out -= diff;
 
 		/* Adjust Reno SACK estimate. */
-		if (tcp_is_reno(tp) && diff > 0) {
+		if (tcp_is_reno(tp) && diff > 0)
 			tcp_dec_pcount_approx_int(&tp->sacked_out, diff);
-			tcp_verify_left_out(tp);
-		}
+
 		tcp_adjust_fackets_out(tp, skb, diff);
 	}
 
@@ -779,6 +778,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsigned int mss
 	skb_header_release(buff);
 	tcp_insert_write_queue_after(skb, buff, sk);
 
+	tcp_verify_left_out(tp);
+
 	return 0;
 }
 
@@ -1439,6 +1440,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle)
 	} else if (result > 0) {
 		sent_pkts = 1;
 	}
+	tcp_verify_left_out(tp);
 
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
@@ -1760,6 +1762,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int m
 
 		sk_stream_free_skb(sk, next_skb);
 	}
+	tcp_verify_left_out(tp);
 }
 
 /* Do a simple retransmit without using the backoff mechanisms in
@@ -1791,13 +1794,13 @@ void tcp_simple_retransmit(struct sock *sk)
 		}
 	}
 
+	tcp_verify_left_out(tp);
+
 	tcp_clear_all_retrans_hints(tp);
 
 	if (!lost)
 		return;
 
-	tcp_verify_left_out(tp);
-
 	/* Don't muck with the congestion window here.
 	 * Reason is that we do not increase amount of _data_
 	 * in network, but units changed and effective
@@ -1966,8 +1969,10 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 			 * packet to be MSS sized and all the
 			 * packet counting works out.
 			 */
-			if (tcp_packets_in_flight(tp) >= tp->snd_cwnd)
+			if (tcp_packets_in_flight(tp) >= tp->snd_cwnd) {
+				tcp_verify_left_out(tp);
 				return;
+			}
 
 			if (sacked & TCPCB_LOST) {
 				if (!(sacked&(TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS))) {
@@ -1993,6 +1998,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		}
 	}
 
+	tcp_verify_left_out(tp);
+
 	/* OK, demanded retransmission is finished. */
 
 	/* Forward retransmissions are possible only during Recovery. */
@@ -2050,6 +2057,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 
 		NET_INC_STATS_BH(LINUX_MIB_TCPFORWARDRETRANS);
 	}
+
+	tcp_verify_left_out(tp);
 }
 
 
-- 
1.5.2.2

