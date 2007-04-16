From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.22 1/3] [TCP]: Sed magic converts func(sk, tp,
 ...) -> func(sk, ...)
Date: Mon, 16 Apr 2007 16:41:23 +0200
Message-ID: <46238B13.5070201@trash.net>
References: <1176727728729-git-send-email-ilpo.jarvinen@helsinki.fi> <20070416134818.GA15915@infradead.org> <Pine.LNX.4.64.0704161703170.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41819 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030682AbXDPOl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 10:41:28 -0400
In-Reply-To: <Pine.LNX.4.64.0704161703170.28337@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> Tweaked newlines manually & fixed four warnings that were
> introduced.

Not all of them it seems:

> -static inline void tcp_fast_path_check(struct sock *sk, struct tcp_s=
ock *tp)
> +static inline void tcp_fast_path_check(struct sock *sk)
>  {
> +	struct tcp_sock *tp =3D tcp_sk(sk);

^ missing newline

>  	if (skb_queue_empty(&tp->out_of_order_queue) &&
>  	    tp->rcv_wnd &&
>  	    atomic_read(&sk->sk_rmem_alloc) < sk->sk_rcvbuf &&
> @@ -778,18 +779,19 @@ static inline void tcp_minshall_update(s
>  		tp->snd_sml =3D TCP_SKB_CB(skb)->end_seq;
>  }
> =20
> -static inline void tcp_check_probe_timer(struct sock *sk, struct tcp=
_sock *tp)
> +static inline void tcp_check_probe_timer(struct sock *sk)
>  {
> +	struct tcp_sock *tp =3D tcp_sk(sk);

^ same here .. quite a few follow

>  	const struct inet_connection_sock *icsk =3D inet_csk(sk);
>  	if (!tp->packets_out && !icsk->icsk_pending)
>  		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
>  					  icsk->icsk_rto, TCP_RTO_MAX);
>  }
