From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix TCP_MAXSEG for established IPv6 passive
 sockets
Date: Sun, 22 Apr 2012 22:14:54 +0200
Message-ID: <1335125694.2395.277.camel@edumazet-glaptop>
References: <1335123947-9906-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>, ilpo.jarvinen@helsinki.fi,
	maze@google.com, Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34167 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180Ab2DVUO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 16:14:59 -0400
Received: by wibhj6 with SMTP id hj6so2225093wib.1
        for <netdev@vger.kernel.org>; Sun, 22 Apr 2012 13:14:58 -0700 (PDT)
In-Reply-To: <1335123947-9906-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-04-22 at 15:45 -0400, Neal Cardwell wrote:
> Commit f5fff5d forgot to fix TCP_MAXSEG behavior IPv6 sockets, so IPv6
> TCP server sockets that used TCP_MAXSEG would find that the advmss of
> child sockets would be incorrect. This commit mirrors the advmss logic
> from tcp_v4_syn_recv_sock in tcp_v6_syn_recv_sock. Eventually this
> logic should probably be shared between IPv4 and IPv6, but this at
> least fixes this issue.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
>  net/ipv6/tcp_ipv6.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 86cfe60..98256cf 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1383,6 +1383,10 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>  	tcp_mtup_init(newsk);
>  	tcp_sync_mss(newsk, dst_mtu(dst));
>  	newtp->advmss = dst_metric_advmss(dst);
> +	if (tcp_sk(sk)->rx_opt.user_mss &&
> +	    tcp_sk(sk)->rx_opt.user_mss < newtp->advmss)
> +		newtp->advmss = tcp_sk(sk)->rx_opt.user_mss;
> +
>  	tcp_initialize_rcv_mss(newsk);
>  	if (tcp_rsk(req)->snt_synack)
>  		tcp_valid_rtt_meas(newsk,

Acked-by: Eric Dumazet <edumazet@google.com>
