From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/ipv6/udp: Fix ipv6 multicast socket filter
 regression
Date: Mon, 18 May 2015 13:22:45 -0700
Message-ID: <1431980565.621.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431976129-28032-1-git-send-email-hrogge@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	David Held <drheld@google.com>
To: Henning Rogge <hrogge@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35127 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932380AbbERUWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 16:22:48 -0400
Received: by iesa3 with SMTP id a3so93083953ies.2
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 13:22:47 -0700 (PDT)
In-Reply-To: <1431976129-28032-1-git-send-email-hrogge@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-18 at 21:08 +0200, Henning Rogge wrote:
> Commit <5cf3d46192fc> ("udp: Simplify__udp*_lib_mcast_deliver")
> simplified the filter for incoming IPv6 multicast but removed
> the check of the local socket address and the UDP destination
> address.
> 
> This patch restores the filter to prevent sockets bound to a IPv6
> multicast IP to receive other UDP traffic link unicast.
> 
> Signed-off-by: Henning Rogge <hrogge@gmail.com>
> Fixes: 5cf3d46192fc ("udp: Simplify__udp*_lib_mcast_deliver")
> Cc: "David S. Miller" <davem@davemloft.net>
> ---
> The commit above was found by me with a git bisect. I think the
> patch should be included into the stable kernel trees.
> ---
>  net/ipv6/udp.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 3477c919fcc8..c2ec41617a35 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -731,7 +731,9 @@ static bool __udp_v6_is_mcast_sock(struct net *net, struct sock *sk,
>  	    (inet->inet_dport && inet->inet_dport != rmt_port) ||
>  	    (!ipv6_addr_any(&sk->sk_v6_daddr) &&
>  		    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr)) ||
> -	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
> +	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif) ||
> +	    (!ipv6_addr_any(&sk->sk_v6_rcv_saddr) &&
> +		    !ipv6_addr_equal(&sk->sk_v6_rcv_saddr, loc_addr)))
>  		return false;
>  	if (!inet6_mc_check(sk, loc_addr, rmt_addr))
>  		return false;


Nice catch. I've CC faulty commit author.

Acked-by: Eric Dumazet <edumazet@google.com>
