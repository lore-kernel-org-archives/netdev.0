From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] [IPv4] Reply net unreachable ICMP message
Date: Thu, 6 Dec 2007 08:49:47 +0100
Message-ID: <20071206074946.GA2164@ff.dom.local>
References: <20071206153105.df7d112f.mitch@linux.vnet.ibm.com>
Reply-To: Jarek Poplawski <jarkao2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:55295 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753325AbXLFHo4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 02:44:56 -0500
Content-Disposition: inline
In-Reply-To: <20071206153105.df7d112f.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06-12-2007 07:31, Mitsuru Chinen wrote:
> IPv4 stack doesn't reply any ICMP destination unreachable message
> with net unreachable code when IP detagrams are being discarded
> because of no route could be found in the forwarding path.
> Incidentally, IPv6 stack replies such ICMPv6 message in the similar
> situation.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
> ---
>  net/ipv4/route.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 6714bbc..ba85ec9 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1375,6 +1375,7 @@ static int ip_error(struct sk_buff *skb)
>  			break;
>  		case ENETUNREACH:
>  			code = ICMP_NET_UNREACH;
> +			IP_INC_STATS_BH(IPSTATS_MIB_INNOROUTES);
>  			break;
>  		case EACCES:
>  			code = ICMP_PKT_FILTERED;
> @@ -2004,6 +2005,7 @@ no_route:
>  	RT_CACHE_STAT_INC(in_no_route);
>  	spec_dst = inet_select_addr(dev, 0, RT_SCOPE_UNIVERSE);
>  	res.type = RTN_UNREACHABLE;
> +	err = -ENETUNREACH;
>  	goto local_input;
>  
>  	/*

This patch seems to be wrong. It overrides err codes from
fib_lookup, where such decisions should be made.

Regards,
Jarek P.
