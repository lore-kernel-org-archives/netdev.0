From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: initialize passive-side sk_pacing_rate after
 3WHS
Date: Mon, 21 Oct 2013 13:36:34 -0700
Message-ID: <1382387794.3284.87.camel@edumazet-glaptop.roam.corp.google.com>
References: <1382384419-6081-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63925 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab3JUUgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 16:36:36 -0400
Received: by mail-pb0-f46.google.com with SMTP id un1so980492pbc.5
        for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 13:36:35 -0700 (PDT)
In-Reply-To: <1382384419-6081-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-21 at 15:40 -0400, Neal Cardwell wrote:
> For passive TCP connections, upon receiving the ACK that completes the
> 3WHS, make sure we set our pacing rate after we get our first RTT
> sample.

> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_input.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 53974c7..a16b01b 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5712,6 +5712,8 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
>  		} else
>  			tcp_init_metrics(sk);
>  
> +		tcp_update_pacing_rate(sk);
> +
>  		/* Prevent spurious tcp_cwnd_restart() on first data packet */
>  		tp->lsndtime = tcp_time_stamp;
>  

Seems good to me, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
