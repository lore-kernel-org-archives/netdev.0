From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/3] tcp: Remove unrequired operations in tcp_push()
Date: Thu, 10 Dec 2009 10:10:51 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912101008010.23376@melkinpaasi.cs.helsinki.fi>
References: <20091209082613.19055.58864.sendpatchset@localhost.localdomain> <20091209082619.19055.10563.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57109 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760480AbZLJIKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 03:10:44 -0500
In-Reply-To: <20091209082619.19055.10563.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Dec 2009, Krishna Kumar wrote:

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Remove unrequired operations in tcp_push()
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  net/ipv4/tcp.c |   15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
> 
> diff -ruNp org/net/ipv4/tcp.c new/net/ipv4/tcp.c
> --- org/net/ipv4/tcp.c	2009-12-04 18:16:10.000000000 +0530
> +++ new/net/ipv4/tcp.c	2009-12-09 10:01:35.000000000 +0530
> @@ -536,8 +536,7 @@ static inline void skb_entail(struct soc
>  		tp->nonagle &= ~TCP_NAGLE_PUSH;
>  }
>  
> -static inline void tcp_mark_urg(struct tcp_sock *tp, int flags,
> -				struct sk_buff *skb)
> +static inline void tcp_mark_urg(struct tcp_sock *tp, int flags)
>  {
>  	if (flags & MSG_OOB)
>  		tp->snd_up = tp->write_seq;
> @@ -546,13 +545,15 @@ static inline void tcp_mark_urg(struct t
>  static inline void tcp_push(struct sock *sk, int flags, int mss_now,
>  			    int nonagle)
>  {
> -	struct tcp_sock *tp = tcp_sk(sk);
> -
>  	if (tcp_send_head(sk)) {
> -		struct sk_buff *skb = tcp_write_queue_tail(sk);
> -		if (!(flags & MSG_MORE) || forced_push(tp))
> +		struct tcp_sock *tp = tcp_sk(sk);
> +
> +		if (!(flags & MSG_MORE) || forced_push(tp)) {
> +			struct sk_buff *skb = tcp_write_queue_tail(sk);
> +
>  			tcp_mark_push(tp, skb);

I suppose one could kill the temporary variable completely then?

> -		tcp_mark_urg(tp, flags, skb);
> +		}
> +		tcp_mark_urg(tp, flags);
>  		__tcp_push_pending_frames(sk, mss_now,
>  					  (flags & MSG_MORE) ? TCP_NAGLE_CORK : nonagle);
>  	}

-- 
 i.
