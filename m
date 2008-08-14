From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 2/2] netns: Add network namespace argument in rt6_fill_node()
 and ipv6_dev_get_saddr()
Date: Thu, 14 Aug 2008 16:04:25 -0400
Message-ID: <48A48FC9.4020805@hp.com>
References: <48A48722.3050509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	containers <containers@lists.osdl.org>,
	linux-sctp@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:8697 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752947AbYHNUE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 16:04:28 -0400
In-Reply-To: <48A48722.3050509@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brian

Brian Haley wrote:
> ---
> 
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index 483a01d..e0945d4 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -319,7 +319,8 @@ static void sctp_v6_get_saddr(struct sctp_sock *sk,
>  			  __func__, asoc, dst, NIP6(daddr->v6.sin6_addr));
>  
>  	if (!asoc) {
> -		ipv6_dev_get_saddr(dst ? ip6_dst_idev(dst)->dev : NULL,
> +		ipv6_dev_get_saddr(NULL,
> +				   dst ? ip6_dst_idev(dst)->dev : NULL,
>  				   &daddr->v6.sin6_addr,
>  				   inet6_sk(&sk->inet.sk)->srcprefs,
>  				   &saddr->v6.sin6_addr);


I think this needs to use sock_net(sctp_opt2s(sk)) instead of NULL.

-vlad
