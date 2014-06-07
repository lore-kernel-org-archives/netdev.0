From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Sat, 07 Jun 2014 17:56:06 +0400
Message-ID: <539319F6.2090907@cogentembedded.com>
References: <1402081628.3645.315.camel@edumazet-glaptop2.roam.corp.google.com> <1402139419-9118-1-git-send-email-per.hurtig@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, anna.brunstrom@kau.se,
	mohammad.rajiullah@kau.se, ncardwell@google.com,
	nanditad@google.com
To: Per Hurtig <per.hurtig@kau.se>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:42247 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650AbaFGN4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 09:56:05 -0400
Received: by mail-lb0-f178.google.com with SMTP id w7so2155494lbi.9
        for <netdev@vger.kernel.org>; Sat, 07 Jun 2014 06:56:03 -0700 (PDT)
In-Reply-To: <1402139419-9118-1-git-send-email-per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07-06-2014 15:10, Per Hurtig wrote:

> Fix to a problem observed when losing a FIN segment that does not
> contain data.  In such situations, TLP is unable to recover from
> *any* tail loss and instead adds at least PTO ms to the
> retransmission process, i.e., RTO = RTO + PTO.

     You should provide your signoff.

[...]

> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index d463c35..6573765 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2130,8 +2130,10 @@ void tcp_send_loss_probe(struct sock *sk)
>   	if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
>   		goto rearm_timer;
>
> -	/* Probe with zero data doesn't trigger fast recovery. */
> -	if (skb->len > 0)
> +	/* Probe with zero data doesn't trigger fast recovery, if not

    s/not/no/?
    Or rather "if FIN flag is not set"?

> +	 * FIN flag is set.
> +	 */
> +	if ((skb->len > 0) || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
>   		err = __tcp_retransmit_skb(sk, skb);

WBR, Sergei
