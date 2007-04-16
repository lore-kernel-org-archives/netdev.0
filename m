From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6.22 1/3] [TCP]: Sed magic converts func(sk, tp,
 ...) -> func(sk, ...)
Date: Mon, 16 Apr 2007 18:15:54 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704161758020.28337@kivilampi-30.cs.helsinki.fi>
References: <1176727728729-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070416134818.GA15915@infradead.org> <Pine.LNX.4.64.0704161703170.28337@kivilampi-30.cs.helsinki.fi>
 <46238B13.5070201@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-31181762-1176736554=:28337"
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54684 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030727AbXDPPPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 11:15:55 -0400
In-Reply-To: <46238B13.5070201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-31181762-1176736554=:28337
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 16 Apr 2007, Patrick McHardy wrote:

> Ilpo Järvinen wrote:
> > Tweaked newlines manually & fixed four warnings that were
> > introduced.
> 
> Not all of them it seems:
> 
> > -static inline void tcp_fast_path_check(struct sock *sk, struct tcp_sock *tp)
> > +static inline void tcp_fast_path_check(struct sock *sk)
> >  {
> > +	struct tcp_sock *tp = tcp_sk(sk);
> 
> ^ missing newline

...in the other (original) patch description that is not copied fully here 
I had a sort of disclaimer for these missing ones but in case they should 
all be changed so that if the added tcp_sock is the only local variable I 
can do that of course... It's not clear to me what is really the preferred 
style considering all the variants... E.g., tcp_check_probe_timer (below) 
does not have the newline before this patch either?!? :-) ...tried to look 
from CodingStyle too but it didn't give any light to this thing...

> >  	if (skb_queue_empty(&tp->out_of_order_queue) &&
> >  	    tp->rcv_wnd &&
> >  	    atomic_read(&sk->sk_rmem_alloc) < sk->sk_rcvbuf &&
> > @@ -778,18 +779,19 @@ static inline void tcp_minshall_update(s
> >  		tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
> >  }
> >  
> > -static inline void tcp_check_probe_timer(struct sock *sk, struct tcp_sock *tp)
> > +static inline void tcp_check_probe_timer(struct sock *sk)
> >  {
> > +	struct tcp_sock *tp = tcp_sk(sk);
> 
> ^ same here .. quite a few follow
> 
> >  	const struct inet_connection_sock *icsk = inet_csk(sk);

...No newline should be place here, since it's being followed by 
another local variable defination.

> >  	if (!tp->packets_out && !icsk->icsk_pending)
> >  		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
> >  					  icsk->icsk_rto, TCP_RTO_MAX);
> >  }
> 

-- 
 i.
---696243703-31181762-1176736554=:28337--
