From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/1] tcp: fixing TLP's FIN recovery
Date: Thu, 12 Jun 2014 08:28:36 -0700
Message-ID: <1402586916.3645.485.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1402583577.3645.477.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402585712-12103-1-git-send-email-per.hurtig@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: panweiping3@gmail.com, nanditad@google.com, netdev@vger.kernel.org,
	anna.brunstrom@kau.se, mohammad.rajiullah@kau.se,
	ncardwell@google.com, sergei.shtylyov@cogentembedded.com
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:38072 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756083AbaFLP2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 11:28:41 -0400
Received: by mail-pa0-f41.google.com with SMTP id kq14so1134355pab.0
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 08:28:40 -0700 (PDT)
In-Reply-To: <1402585712-12103-1-git-send-email-per.hurtig@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-06-12 at 17:08 +0200, Per Hurtig wrote:
> Fix to a problem observed when losing a FIN segment that does not
> contain data.  In such situations, TLP is unable to recover from
> *any* tail loss and instead adds at least PTO ms to the
> retransmission process, i.e., RTO = RTO + PTO.
> 
> Signed-off-by: Per Hurtig <per.hurtig@kau.se>
> ---
>  net/ipv4/tcp_output.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index ad7549f..819bf0c 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2131,9 +2131,7 @@ void tcp_send_loss_probe(struct sock *sk)
>  	if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
>  		goto rearm_timer;
>  
> -	/* Probe with zero data doesn't trigger fast recovery. */
> -	if (skb->len > 0)
> -		err = __tcp_retransmit_skb(sk, skb);
> +	err = __tcp_retransmit_skb(sk, skb);
>  
>  	/* Record snd_nxt for loss detection. */
>  	if (likely(!err))

Thanks a lot Per

Signed-off-by: Eric Dumazet <edumazet@google.com>
