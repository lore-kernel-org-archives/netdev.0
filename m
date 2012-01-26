From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/2] ipv4/ipv6: Prepare for new route gateway semantics.
Date: Fri, 27 Jan 2012 06:24:18 +0900
Message-ID: <4F21C482.4070707@linux-ipv6.org>
References: <20120126.155544.2054995753871805122.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:42958 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751301Ab2AZVYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 16:24:21 -0500
In-Reply-To: <20120126.155544.2054995753871805122.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

David Miller wrote:
>
> In the future the ipv4/ipv6 route gateway will take on two types
> of values:
>
> 1) INADDR_ANY/IN6ADDR_ANY, for local network routes, and in this case
>     the neighbour must be obtained using the destination address in
>     ipv4/ipv6 header as the lookup key.
>
> 2) Everything else, the actual nexthop route address.
>
> So if the gateway is not inaddr-any we use it, otherwise we must use
> the packet's destination address.
>
> Signed-off-by: David S. Miller<davem@davemloft.net>
> ---
>   net/ipv4/route.c |    5 +++++
>   net/ipv6/route.c |   16 +++++++++++++++-
>   2 files changed, 20 insertions(+), 1 deletions(-)
>
:
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 8c2e3ab..7d7f306 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -121,9 +121,23 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
>   	return p;
>   }
>
> +static inline const void *choose_neigh_daddr(struct rt6_info *rt, const void *daddr)
> +{
> +	struct in6_addr *p =&rt->rt6i_gateway;
> +
> +	if (p->s6_addr32[0] | p->s6_addr32[1] |
> +	    p->s6_addr32[2] | p->s6_addr32[3])
> +		return (const void *) p;
> +	return daddr;
> +}
> +

Why not use ipv6_addr_any()?

--yoshfuji
