From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 16/19] ipv6: Store route neighbour in rt6_info struct.
Date: Thu, 5 Jul 2012 15:14:13 +0200
Message-ID: <20120705131413.GD1869@secunet.com>
References: <20120703.024700.1627207600679312181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58007 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932339Ab2GENOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2012 09:14:20 -0400
Content-Disposition: inline
In-Reply-To: <20120703.024700.1627207600679312181.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 03, 2012 at 02:47:00AM -0700, David Miller wrote:
> 
> This makes for a simplified conversion away from dst_get_neighbour*().
> 
> All code outside of ipv6 will use neigh lookups via dst_neigh_lookup*().
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/net/ip6_fib.h   |    2 ++
>  net/ipv6/ip6_output.c   |    8 ++++++--
>  net/ipv6/route.c        |   42 ++++++++++++++++++++++++++----------------
>  net/ipv6/xfrm6_policy.c |    1 +
>  4 files changed, 35 insertions(+), 18 deletions(-)
> 
> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
> index a192f78..0fedbd8 100644
> --- a/include/net/ip6_fib.h
> +++ b/include/net/ip6_fib.h
> @@ -86,6 +86,8 @@ struct fib6_table;
>  struct rt6_info {
>  	struct dst_entry		dst;
>  
> +	struct neighbour		*n;
> +

This pointer needs to be initialized when we allocate the
rt6_info, otherwise all my testboxes crash during noot.

I'll send a patch to do this.
