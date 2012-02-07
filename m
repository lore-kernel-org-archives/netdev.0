From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v4 2/2] Implement IPV6_UNICAST_IF socket option.
Date: Tue, 07 Feb 2012 10:24:48 -0500
Message-ID: <4F314240.7050306@hp.com>
References: <1328590876-15980-2-git-send-email-ehoover@mines.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:28634 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab2BGPY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 10:24:56 -0500
In-Reply-To: <1328590876-15980-2-git-send-email-ehoover@mines.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2012 12:01 AM, Erich E. Hoover wrote:
> 
> The IPV6_UNICAST_IF feature is the IPv6 compliment to IP_UNICAST_IF.

> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -199,6 +199,7 @@ lookup_protocol:
>  	sk->sk_backlog_rcv	= answer->prot->backlog_rcv;
>  
>  	inet_sk(sk)->pinet6 = np = inet6_sk_generic(sk);
> +	np->ucast_oif	= 0;
>  	np->hop_limit	= -1;
>  	np->mcast_hops	= IPV6_DEFAULT_MCASTHOPS;
>  	np->mc_loop	= 1;

sk_alloc() will zero the struct, so this is unnecessary.

> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -1130,6 +1130,9 @@ do_udp_sendmsg:
>  	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr)) {
>  		fl6.flowi6_oif = np->mcast_oif;
>  		connected = 0;
> +	} else if (!fl6.flowi6_oif) {
> +		fl6.flowi6_oif = np->ucast_oif;
> +		connected = 0;
>  	}

I don't think you want to clear 'connected' here.

-Brian
