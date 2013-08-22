From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: sctp_probe: simplify code by using %pISc
 format specifier
Date: Thu, 22 Aug 2013 11:26:23 -0400
Message-ID: <20130822152623.GB16781@hmsreliant.think-freely.org>
References: <1377184370-13721-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49097 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327Ab3HVP0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 11:26:44 -0400
Content-Disposition: inline
In-Reply-To: <1377184370-13721-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 22, 2013 at 05:12:50PM +0200, Daniel Borkmann wrote:
> We can simply use the %pISc format specifier that was recently added
> and thus remove some code that distinguishes between IPv4 and IPv6.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/sctp/probe.c | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
> 
> diff --git a/net/sctp/probe.c b/net/sctp/probe.c
> index e62c225..cd72ae5 100644
> --- a/net/sctp/probe.c
> +++ b/net/sctp/probe.c
> @@ -155,13 +155,8 @@ static sctp_disposition_t jsctp_sf_eat_sack(struct net *net,
>  			if (sp == asoc->peer.primary_path)
>  				printl("*");
>  
> -			if (sp->ipaddr.sa.sa_family == AF_INET)
> -				printl("%pI4 ", &sp->ipaddr.v4.sin_addr);
> -			else
> -				printl("%pI6 ", &sp->ipaddr.v6.sin6_addr);
> -
> -			printl("%2u %8u %8u %8u %8u %8u ",
> -			       sp->state, sp->cwnd, sp->ssthresh,
> +			printl("%pISc %2u %8u %8u %8u %8u %8u ",
> +			       &sp->ipaddr, sp->state, sp->cwnd, sp->ssthresh,
>  			       sp->flight_size, sp->partial_bytes_acked,
>  			       sp->pathmtu);
>  		}
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
