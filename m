From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] TCP: Add comments to (near) all functions in tcp_output.c
	v3
Date: Wed, 22 Jul 2009 11:00:40 +0200
Message-ID: <20090722090040.GA17474@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49636 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755898AbZGVJAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2009 05:00:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP: Add comments to (near) all functions in tcp_output.c v3

While looking for something else I spent some time adding
one liner comments to the tcp_output.c functions that
didn't have any. That makes the comments more consistent.

I hope I documented everything right.

No code changes.

v2: Incorporated feedback from Ilpo.
v3: Change style of one liner comments, add a few more comments.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

---
 net/ipv4/tcp_output.c |   58 +++++++++++++++++++++++++++++++++++++----=
---------
 1 file changed, 44 insertions(+), 14 deletions(-)

Index: linux-2.6.31-rc3-ak/net/ipv4/tcp_output.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.31-rc3-ak.orig/net/ipv4/tcp_output.c
+++ linux-2.6.31-rc3-ak/net/ipv4/tcp_output.c
@@ -59,6 +59,7 @@ int sysctl_tcp_base_mss __read_mostly =3D
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly =3D 1;
=20
+/* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *s=
kb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -142,6 +143,7 @@ static void tcp_cwnd_restart(struct sock
 	tp->snd_cwnd_used =3D 0;
 }
=20
+/* Congestion state accounting after a packet has been sent. */
 static void tcp_event_data_sent(struct tcp_sock *tp,
 				struct sk_buff *skb, struct sock *sk)
 {
@@ -161,6 +163,7 @@ static void tcp_event_data_sent(struct t
 		icsk->icsk_ack.pingpong =3D 1;
 }
=20
+/* Account for an ACK we sent. */
 static inline void tcp_event_ack_sent(struct sock *sk, unsigned int pk=
ts)
 {
 	tcp_dec_quickack_mode(sk, pkts);
@@ -276,6 +279,7 @@ static u16 tcp_select_window(struct sock
 	return new_win;
 }
=20
+/* Packet ECN state for a SYN-ACK */
 static inline void TCP_ECN_send_synack(struct tcp_sock *tp, struct sk_=
buff *skb)
 {
 	TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG_CWR;
@@ -283,6 +287,7 @@ static inline void TCP_ECN_send_synack(s
 		TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG_ECE;
 }
=20
+/* Packet ECN state for a SYN.  */
 static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *s=
kb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -301,6 +306,9 @@ TCP_ECN_make_synack(struct request_sock
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
@@ -362,7 +370,9 @@ struct tcp_out_options {
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
@@ -445,6 +455,9 @@ static void tcp_options_write(__be32 *pt
 	}
 }
=20
+/* Compute TCP options for SYN packets. This is not the final
+ * network wire format yet.
+ */
 static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_out_options *opts,
 				struct tcp_md5sig_key **md5) {
@@ -493,6 +506,7 @@ static unsigned tcp_syn_options(struct s
 	return size;
 }
=20
+/* Set up TCP options for SYN-ACKs. */
 static unsigned tcp_synack_options(struct sock *sk,
 				   struct request_sock *req,
 				   unsigned mss, struct sk_buff *skb,
@@ -541,6 +555,9 @@ static unsigned tcp_synack_options(struc
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
@@ -705,7 +722,7 @@ static int tcp_transmit_skb(struct sock
 	return net_xmit_eval(err);
 }
=20
-/* This routine just queue's the buffer
+/* This routine just queues the buffer for sending.
  *
  * NOTE: probe0 timer is not checked, do not forget tcp_push_pending_f=
rames,
  * otherwise socket can stall.
@@ -722,6 +739,7 @@ static void tcp_queue_skb(struct sock *s
 	sk_mem_charge(sk, skb->truesize);
 }
=20
+/* Initialize TSO segments for a packet. */
 static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb,
 				 unsigned int mss_now)
 {
@@ -909,6 +927,7 @@ static void __pskb_trim_head(struct sk_b
 	skb->len =3D skb->data_len;
 }
=20
+/* Remove acked data from a packet in the transmit queue. */
 int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 {
 	if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
@@ -937,7 +956,7 @@ int tcp_trim_head(struct sock *sk, struc
 	return 0;
 }
=20
-/* Not accounting for SACKs here. */
+/* Calculate MSS. Not accounting for SACKs here.  */
 int tcp_mtu_to_mss(struct sock *sk, int pmtu)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -981,6 +1000,7 @@ int tcp_mss_to_mtu(struct sock *sk, int
 	return mtu;
 }
=20
+/* MTU probing init per socket */
 void tcp_mtup_init(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -1143,7 +1163,8 @@ static inline unsigned int tcp_cwnd_test
 	return 0;
 }
=20
-/* This must be invoked the first time we consider transmitting
+/* Intialize TSO state of a skb.
+ * This must be invoked the first time we consider transmitting
  * SKB onto the wire.
  */
 static int tcp_init_tso_segs(struct sock *sk, struct sk_buff *skb,
@@ -1158,6 +1179,7 @@ static int tcp_init_tso_segs(struct sock
 	return tso_segs;
 }
=20
+/* Minshall's variant of the Nagle send check. */
 static inline int tcp_minshall_check(const struct tcp_sock *tp)
 {
 	return after(tp->snd_sml, tp->snd_una) &&
@@ -1242,6 +1264,7 @@ static unsigned int tcp_snd_test(struct
 	return cwnd_quota;
 }
=20
+/* Test if sending is allowed right now. */
 int tcp_may_send_now(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -1378,6 +1401,10 @@ send_now:
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
@@ -1790,6 +1817,7 @@ static void tcp_collapse_retrans(struct
 	sk_wmem_free_skb(sk, next_skb);
 }
=20
+/* Check if coalescing SKBs is legal. */
 static int tcp_can_collapse(struct sock *sk, struct sk_buff *skb)
 {
 	if (tcp_skb_pcount(skb) > 1)
@@ -1808,6 +1836,9 @@ static int tcp_can_collapse(struct sock
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
@@ -1957,6 +1988,9 @@ int tcp_retransmit_skb(struct sock *sk,
 	return err;
 }
=20
+/* Check if we forward retransmits are possible in the current
+ * window/congestion state.
+ */
 static int tcp_can_forward_retransmit(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
@@ -2145,7 +2179,8 @@ void tcp_send_active_reset(struct sock *
 	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTRSTS);
 }
=20
-/* WARNING: This routine must only be called when we have already sent
+/* Send a crossed SYN-ACK during socket establishment.
+ * WARNING: This routine must only be called when we have already sent
  * a SYN packet that crossed the incoming SYN that caused this routine
  * to get called. If this assumption fails then the initial rcv_wnd
  * and rcv_wscale values will not be correct.
@@ -2180,9 +2215,7 @@ int tcp_send_synack(struct sock *sk)
 	return tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 }
=20
-/*
- * Prepare a SYN-ACK.
- */
+/* Prepare a SYN-ACK. */
 struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst=
,
 				struct request_sock *req)
 {
@@ -2269,9 +2302,7 @@ struct sk_buff *tcp_make_synack(struct s
 	return skb;
 }
=20
-/*
- * Do all connect socket setups that can be done AF independent.
- */
+/* Do all connect socket setups that can be done AF independent. */
 static void tcp_connect_init(struct sock *sk)
 {
 	struct dst_entry *dst =3D __sk_dst_get(sk);
@@ -2330,9 +2361,7 @@ static void tcp_connect_init(struct sock
 	tcp_clear_retrans(tp);
 }
=20
-/*
- * Build a SYN and send it off.
- */
+/* Build a SYN and send it off. */
 int tcp_connect(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
@@ -2493,6 +2522,7 @@ static int tcp_xmit_probe_skb(struct soc
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
=20
+/* Initiate keepalive or window probe from timer. */
 int tcp_write_wakeup(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
