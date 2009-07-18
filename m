From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] TCP: Add comments to (near) all functions in tcp_output.c
	v2
Date: Sat, 18 Jul 2009 12:31:59 +0200
Message-ID: <20090718103159.GB2682@basil.fritz.box>
References: <20090717204004.GA516@basil.fritz.box> <Pine.LNX.4.64.0907180919270.31457@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>, Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40700 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753447AbZGRKcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2009 06:32:04 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0907180919270.31457@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here's a updated version incorporating feedback.
-Andi

---

TCP: Add comments to (near) all functions in tcp_output.c v2

While looking for something else I spent some time adding
one liner comments to the tcp_output.c functions that
didn't have any. That makes the comments more consistent.

I hope I documented everything right.

No code changes.

v2: Incorporated feedback from Ilpo.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

---
 net/ipv4/tcp_output.c |   51 +++++++++++++++++++++++++++++++++++++++++=
++++-----
 1 file changed, 46 insertions(+), 5 deletions(-)

Index: linux-2.6.31-rc3-ak/net/ipv4/tcp_output.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.31-rc3-ak.orig/net/ipv4/tcp_output.c
+++ linux-2.6.31-rc3-ak/net/ipv4/tcp_output.c
@@ -59,6 +59,8 @@ int sysctl_tcp_base_mss __read_mostly =3D
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly =3D 1;
=20
+/* Account for new data that has been sent to the network.
+ */
 static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *s=
kb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -142,6 +144,8 @@ static void tcp_cwnd_restart(struct sock
 	tp->snd_cwnd_used =3D 0;
 }
=20
+/* Congestion state accounting after a packet has been sent.
+ */
 static void tcp_event_data_sent(struct tcp_sock *tp,
 				struct sk_buff *skb, struct sock *sk)
 {
@@ -276,6 +280,8 @@ static u16 tcp_select_window(struct sock
 	return new_win;
 }
=20
+/* Packet ECN state for a SYN-ACK
+ */
 static inline void TCP_ECN_send_synack(struct tcp_sock *tp, struct sk_=
buff *skb)
 {
 	TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG_CWR;
@@ -283,6 +289,8 @@ static inline void TCP_ECN_send_synack(s
 		TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG_ECE;
 }
=20
+/* Packet ECN state for a SYN.
+ */
 static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *s=
kb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -301,6 +309,9 @@ TCP_ECN_make_synack(struct request_sock
 		th->ece =3D 1;
 }
=20
+/* Set up ECN state for a packet on a ESTABLISHED socket that is about=
 to
+ * be sent.
+ */
 static inline void TCP_ECN_send(struct sock *sk, struct sk_buff *skb,
 				int tcp_header_len)
 {
@@ -362,7 +373,9 @@ struct tcp_out_options {
 	__u32 tsval, tsecr;	/* need to include OPTION_TS */
 };
=20
-/* Beware: Something in the Internet is very sensitive to the ordering=
 of
+/* Write previously computed TCP options to the packet.
+ *
+ * Beware: Something in the Internet is very sensitive to the ordering=
 of
  * TCP options, we learned this through the hard way, so be careful he=
re.
  * Luckily we can at least blame others for their non-compliance but f=
rom
  * inter-operatibility perspective it seems that we're somewhat stuck =
with
@@ -445,6 +458,9 @@ static void tcp_options_write(__be32 *pt
 	}
 }
=20
+/* Compute TCP options for SYN packets. This is not the final
+ * network wire format yet.
+ */
 static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_out_options *opts,
 				struct tcp_md5sig_key **md5) {
@@ -493,6 +509,8 @@ static unsigned tcp_syn_options(struct s
 	return size;
 }
=20
+/* Set up TCP options for SYN-ACKs.
+ */
 static unsigned tcp_synack_options(struct sock *sk,
 				   struct request_sock *req,
 				   unsigned mss, struct sk_buff *skb,
@@ -541,6 +559,9 @@ static unsigned tcp_synack_options(struc
 	return size;
 }
=20
+/* Compute TCP options for ESTABLISHED sockets. This is not the
+ * final wire format yet.
+ */
 static unsigned tcp_established_options(struct sock *sk, struct sk_buf=
f *skb,
 					struct tcp_out_options *opts,
 					struct tcp_md5sig_key **md5) {
@@ -705,7 +726,7 @@ static int tcp_transmit_skb(struct sock
 	return net_xmit_eval(err);
 }
=20
-/* This routine just queue's the buffer
+/* This routine just queues the buffer
  *
  * NOTE: probe0 timer is not checked, do not forget tcp_push_pending_f=
rames,
  * otherwise socket can stall.
@@ -909,6 +930,8 @@ static void __pskb_trim_head(struct sk_b
 	skb->len =3D skb->data_len;
 }
=20
+/* Remove acked data from a packet in the transmit queue.
+ */
 int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 {
 	if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
@@ -937,7 +960,9 @@ int tcp_trim_head(struct sock *sk, struc
 	return 0;
 }
=20
-/* Not accounting for SACKs here. */
+/* Calculate MSS
+ * Not accounting for SACKs here.
+ */
 int tcp_mtu_to_mss(struct sock *sk, int pmtu)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -1143,7 +1168,8 @@ static inline unsigned int tcp_cwnd_test
 	return 0;
 }
=20
-/* This must be invoked the first time we consider transmitting
+/* Intialize TSO state of a skb.
+ * This must be invoked the first time we consider transmitting
  * SKB onto the wire.
  */
 static int tcp_init_tso_segs(struct sock *sk, struct sk_buff *skb,
@@ -1242,6 +1268,8 @@ static unsigned int tcp_snd_test(struct
 	return cwnd_quota;
 }
=20
+/* Test if sending is allowed right now.
+ */
 int tcp_may_send_now(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -1378,6 +1406,10 @@ send_now:
 }
=20
 /* Create a new MTU probe if we are ready.
+ * MTU probe is regularly attempting to increase the path MTU by
+ * deliberately sending larger packets.  This discovers routing
+ * changes resulting in larger path MTUs.
+ *
  * Returns 0 if we should wait to probe (no cwnd available),
  *         1 if a probe was sent,
  *         -1 otherwise
@@ -1808,6 +1840,9 @@ static int tcp_can_collapse(struct sock
 	return 1;
 }
=20
+/* Collapse packets in the retransmit queue to make to create
+ * less packets on the wire. This is only done on retransmission.
+ */
 static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *=
to,
 				     int space)
 {
@@ -1957,6 +1992,9 @@ int tcp_retransmit_skb(struct sock *sk,
 	return err;
 }
=20
+/* Check if we forward retransmits are possible in the current
+ * window/congestion state.
+ */
 static int tcp_can_forward_retransmit(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
@@ -2145,7 +2183,8 @@ void tcp_send_active_reset(struct sock *
 	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTRSTS);
 }
=20
-/* WARNING: This routine must only be called when we have already sent
+/* Send a crossed SYN-ACK during socket establishment.
+ * WARNING: This routine must only be called when we have already sent
  * a SYN packet that crossed the incoming SYN that caused this routine
  * to get called. If this assumption fails then the initial rcv_wnd
  * and rcv_wscale values will not be correct.
@@ -2493,6 +2532,8 @@ static int tcp_xmit_probe_skb(struct soc
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
=20
+/* Initiate keepalive or window probe from timer.
+ */
 int tcp_write_wakeup(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
