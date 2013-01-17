From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 2/2] ipv4: Don't update the pmtu on mtu locked routes
Date: Thu, 17 Jan 2013 10:41:44 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1301171039500.1685@ja.ssi.bg>
References: <20130117065500.GG18940@secunet.com> <20130117065810.GH18940@secunet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	luky-37@hotmail.com, pupilla@libero.it, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43817 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753203Ab3AQIi7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 03:38:59 -0500
In-Reply-To: <20130117065810.GH18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 17 Jan 2013, Steffen Klassert wrote:

> Routes with locked mtu should not use learned pmtu informations,
> so do not update the pmtu on these routes.
> 
> Reported-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv4/route.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 6e4a89c..259cbee 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -912,6 +912,9 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
>  	struct dst_entry *dst = &rt->dst;
>  	struct fib_result res;
>  
> +	if (dst_metric_locked(dst, RTAX_MTU))
> +		return;
> +
>  	if (dst->dev->mtu < mtu)
>  		return;
>  
> -- 
> 1.7.9.5

	Thanks

--
Julian Anastasov <ja@ssi.bg>
