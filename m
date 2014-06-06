From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp: fixing TLP's FIN recovery
Date: Fri, 06 Jun 2014 12:07:08 -0700
Message-ID: <1402081628.3645.315.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140606184626.GA13509@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anna.brunstrom@kau.se,
	mohammad.rajiullah@kau.se, Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:43560 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423AbaFFTHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 15:07:10 -0400
Received: by mail-pb0-f44.google.com with SMTP id rq2so2849418pbb.3
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 12:07:10 -0700 (PDT)
In-Reply-To: <20140606184626.GA13509@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-06-06 at 20:46 +0200, Per Hurtig wrote:
> From ab1b16ef8aba4300b1a6e965c3ab7d0cb269bb2a Mon Sep 17 00:00:00 2001
> From: Per Hurtig <per.hurtig@kau.se>
> Date: Fri, 6 Jun 2014 18:36:19 +0200
> Subject: [PATCH 1/1] tcp: fixing TLP's FIN recovery
> 
> Fix to a problem observed when losing a FIN segment that does not
> contain data.  In such situations, TLP is unable to recover from
> *any* tail loss and instead adds at least PTO ms to the
> retransmission process, i.e., RTO = RTO + PTO.



> 
> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
> ---
>  net/ipv4/tcp_output.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
> 
>   diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>   index d463c35..2c29926 100644
>   --- a/net/ipv4/tcp_output.c
>   +++ b/net/ipv4/tcp_output.c
>   @@ -2130,8 +2130,9 @@ void tcp_send_loss_probe(struct sock *sk)
>     if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
> 	    goto rearm_timer;
> 	     
> 	     -	/* Probe with zero data doesn't trigger fast recovery.
> 		*/
> 		-	if (skb->len > 0)
> 		+	/* Probe with zero data doesn't trigger fast
> 		recovery, unless
> 		+	 * FIN flag is set. */
> 		+	if ((skb->len > 0) ||
> 		(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
> 			err = __tcp_retransmit_skb(sk, skb);
> 			 
> 			    /* Record snd_nxt for loss detection. */
> 			    -- 
> 			    1.9.1
> 

Patch was mangled. Please fix and resend.

Please CC Nandita & Neal,

Thanks
