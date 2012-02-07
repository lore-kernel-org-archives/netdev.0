From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v4 1/2] Implement IP_UNICAST_IF socket option.
Date: Tue, 07 Feb 2012 10:24:45 -0500
Message-ID: <4F31423D.5060905@hp.com>
References: <1328590876-15980-1-git-send-email-ehoover@mines.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:2761 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab2BGPYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 10:24:47 -0500
In-Reply-To: <1328590876-15980-1-git-send-email-ehoover@mines.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2012 12:01 AM, Erich E. Hoover wrote:
> 
> The IP_UNICAST_IF feature is needed by the Wine project.  This patch implements the feature by setting the outgoing interface in a similar fashion to that of IP_MULTICAST_IF.  A separate option is needed to handle this feature since the existing options do not provide all of the characteristics required by IP_UNICAST_IF, a summary is provided below.
> 
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -375,6 +375,7 @@ lookup_protocol:
>  	sk->sk_protocol	   = protocol;
>  	sk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
>  
> +	inet->uc_index  = 0;
>  	inet->uc_ttl	= -1;
>  	inet->mc_loop	= 1;
>  	inet->mc_ttl	= 1;

sk_alloc() will zero the struct, so this is unnecessary.

> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -917,6 +917,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  		if (!saddr)
>  			saddr = inet->mc_addr;
>  		connected = 0;
> +	} else if (!ipc.oif) {
> +		ipc.oif = inet->uc_index;
> +		connected = 0;
>  	}

I don't think you want to clear 'connected' here.

-Brian
