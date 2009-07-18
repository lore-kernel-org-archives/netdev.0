From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] TCP: Add comments to (near) all functions in tcp_output.c
Date: Sat, 18 Jul 2009 09:38:02 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0907180919270.31457@melkinkari.cs.Helsinki.FI>
References: <20090717204004.GA516@basil.fritz.box>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243445-1627044812-1247898768=:31457"
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48822 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbZGRGiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2009 02:38:04 -0400
In-Reply-To: <20090717204004.GA516@basil.fritz.box>
Content-ID: <Pine.LNX.4.64.0907180932560.31457@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243445-1627044812-1247898768=:31457
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0907180932561.31457@melkinkari.cs.Helsinki.FI>

On Fri, 17 Jul 2009, Andi Kleen wrote:

> TCP: Add comments to (near) all functions in tcp_output.c
> 
> While looking for something else I spent some time adding
> one liner comments to the tcp_output.c functions that
> didn't have any. That makes the comments more consistent.
> 
> I hope I documented everything right.
> 
> No code changes.
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> ---
>  net/ipv4/tcp_output.c |   49 ++++++++++++++++++++++++++++++++++++++++++++-----
>  1 file changed, 44 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6.31-rc3-ak/net/ipv4/tcp_output.c
> ===================================================================
> --- linux-2.6.31-rc3-ak.orig/net/ipv4/tcp_output.c
> +++ linux-2.6.31-rc3-ak/net/ipv4/tcp_output.c
> @@ -59,6 +59,8 @@ int sysctl_tcp_base_mss __read_mostly =
>  /* By default, RFC2861 behavior.  */
>  int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
>  
> +/* Account for new data that has been sent to the network.
> + */
>  static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *skb)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> @@ -142,6 +144,8 @@ static void tcp_cwnd_restart(struct sock
>  	tp->snd_cwnd_used = 0;
>  }
>  
> +/* Congestion state accounting after a packet has been sent.
> + */
>  static void tcp_event_data_sent(struct tcp_sock *tp,
>  				struct sk_buff *skb, struct sock *sk)
>  {
> @@ -276,6 +280,8 @@ static u16 tcp_select_window(struct sock
>  	return new_win;
>  }
>  
> +/* Packet ECN state for a SYN-ACK
> + */
>  static inline void TCP_ECN_send_synack(struct tcp_sock *tp, struct sk_buff *skb)
>  {
>  	TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_CWR;
> @@ -283,6 +289,8 @@ static inline void TCP_ECN_send_synack(s
>  		TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_ECE;
>  }
>  
> +/* Packet ECN state for a SYN.
> + */
>  static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> @@ -301,6 +309,9 @@ TCP_ECN_make_synack(struct request_sock
>  		th->ece = 1;
>  }
>  
> +/* Set up ECN state for a packet on a ESTABLISHED socket that is about to
> + * be sent.
> + */
>  static inline void TCP_ECN_send(struct sock *sk, struct sk_buff *skb,
>  				int tcp_header_len)
>  {
> @@ -362,7 +373,9 @@ struct tcp_out_options {
>  	__u32 tsval, tsecr;	/* need to include OPTION_TS */
>  };
>  
> -/* Beware: Something in the Internet is very sensitive to the ordering of
> +/* Write previously computed TCP options to the packet.
> + *
> + * Beware: Something in the Internet is very sensitive to the ordering of
>   * TCP options, we learned this through the hard way, so be careful here.
>   * Luckily we can at least blame others for their non-compliance but from
>   * inter-operatibility perspective it seems that we're somewhat stuck with
> @@ -445,6 +458,8 @@ static void tcp_options_write(__be32 *pt
>  	}
>  }
>  
> +/* Compute TCP options for SYN packets and store them in the socket.
> + */

These three (this and two below) calculate stuff not into socket but into 
a tcp_out_options struct in stack, and besides that they also find out 
the space that is needed for those options (the returned int).

>  static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
>  				struct tcp_out_options *opts,
>  				struct tcp_md5sig_key **md5) {
> @@ -493,6 +508,8 @@ static unsigned tcp_syn_options(struct s
>  	return size;
>  }
>  
> +/* Set up TCP options for SYN-ACKs and store them in the socket.
> + */
>  static unsigned tcp_synack_options(struct sock *sk,
>  				   struct request_sock *req,
>  				   unsigned mss, struct sk_buff *skb,
> @@ -541,6 +558,8 @@ static unsigned tcp_synack_options(struc
>  	return size;
>  }
>  
> +/* Compute TCP options for ESTABLISHED sockets and store them in the socket.
> + */
>  static unsigned tcp_established_options(struct sock *sk, struct sk_buff *skb,
>  					struct tcp_out_options *opts,
>  					struct tcp_md5sig_key **md5) {
> @@ -705,7 +724,7 @@ static int tcp_transmit_skb(struct sock
>  	return net_xmit_eval(err);
>  }
>  
> -/* This routine just queue's the buffer
> +/* This routine just queues the buffer
>   *
>   * NOTE: probe0 timer is not checked, do not forget tcp_push_pending_frames,
>   * otherwise socket can stall.
> @@ -909,6 +928,8 @@ static void __pskb_trim_head(struct sk_b
>  	skb->len = skb->data_len;
>  }
>  
> +/* Remove acked data from a packet in the transmit queue.
> + */
>  int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
>  {
>  	if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
> @@ -937,7 +958,9 @@ int tcp_trim_head(struct sock *sk, struc
>  	return 0;
>  }
>  
> -/* Not accounting for SACKs here. */
> +/* Calculate MSS
> + * Not accounting for SACKs here.
> + */
>  int tcp_mtu_to_mss(struct sock *sk, int pmtu)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> @@ -1143,7 +1166,8 @@ static inline unsigned int tcp_cwnd_test
>  	return 0;
>  }
>  
> -/* This must be invoked the first time we consider transmitting
> +/* Intialize TSO state.

... of skb. ?

Not some some socket or whatever global state.

> + * This must be invoked the first time we consider transmitting
>   * SKB onto the wire.
>   */
>  static int tcp_init_tso_segs(struct sock *sk, struct sk_buff *skb,
> @@ -1242,6 +1266,8 @@ static unsigned int tcp_snd_test(struct
>  	return cwnd_quota;
>  }
>  
> +/* Test if sending is allowed right now.
> + */
>  int tcp_may_send_now(struct sock *sk)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> @@ -1378,6 +1404,9 @@ send_now:
>  }
>  
>  /* Create a new MTU probe if we are ready.
> + * MTU probe is trying to increase the path MTU again after PMTU
> + * discovery initially shrunk the PMTU. This discovers routing
> + * changes.

I don't particularly like that "initially shrunk" part here. Honestly I 
don't even know what that refers to :-) and mtu probe may well work from 
1500 upwards too if your path is able... I mean that no shrunking 
occurred in that scenario?!?

>   * Returns 0 if we should wait to probe (no cwnd available),
>   *         1 if a probe was sent,
>   *         -1 otherwise
> @@ -1808,6 +1837,9 @@ static int tcp_can_collapse(struct sock
>  	return 1;
>  }
>  
> +/* Collapse packets in the retransmit queue to make them
> + * fit into the MSS/MTU and minimize packets on the wire.

small packets? collapsed up to MSS/MTU?

> + */
>  static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
>  				     int space)
>  {
> @@ -1957,6 +1989,9 @@ int tcp_retransmit_skb(struct sock *sk,
>  	return err;
>  }
>  
> +/* Check if we forward retransmits are possible in the current
> + * window/congestion state.
> + */
>  static int tcp_can_forward_retransmit(struct sock *sk)
>  {
>  	const struct inet_connection_sock *icsk = inet_csk(sk);
> @@ -2145,7 +2180,8 @@ void tcp_send_active_reset(struct sock *
>  	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTRSTS);
>  }
>  
> -/* WARNING: This routine must only be called when we have already sent
> +/* Send a crossed SYN-ACK during socket establishment.
> + * WARNING: This routine must only be called when we have already sent
>   * a SYN packet that crossed the incoming SYN that caused this routine
>   * to get called. If this assumption fails then the initial rcv_wnd
>   * and rcv_wscale values will not be correct.
> @@ -2493,6 +2529,9 @@ static int tcp_xmit_probe_skb(struct soc
>  	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
>  }
>  
> +/* Initiate keepalive or window probe from timer.
> + * Retransmits the data on the head of the retransmit queue.

skb = tcp_send_head(sk)? ...That's not head of the retransmit queue but 
the first unsent segment. ...And it may send just a probe packet(s) if no 
data is available.

> + */
>  int tcp_write_wakeup(struct sock *sk)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);

Other than those mentioned,

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>


-- 
 i.
---696243445-1627044812-1247898768=:31457--
