From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next-2.6] ipvs: switch to GFP_KERNEL allocations
Date: Tue, 24 Aug 2010 15:00:42 +0900
Message-ID: <20100824060039.GB21033@verge.net.au>
References: <1282629098.2378.1521.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:52504 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993Ab0HXGAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 02:00:46 -0400
Content-Disposition: inline
In-Reply-To: <1282629098.2378.1521.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 24, 2010 at 07:51:38AM +0200, Eric Dumazet wrote:
> Switch from GFP_ATOMIC allocations to GFP_KERNEL ones in
> ip_vs_add_service() and ip_vs_new_dest(), as we hold a mutex and are
> allowed to sleep in this context.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Signed-off-by: Simon Horman <horms@verge.net.au

Patrick, please consider this for nf-next.

> ---
>  net/netfilter/ipvs/ip_vs_ctl.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 0f0c079..896f34b 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -843,7 +843,7 @@ ip_vs_new_dest(struct ip_vs_service *svc, struct ip_vs_dest_user_kern *udest,
>  			return -EINVAL;
>  	}
>  
> -	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_ATOMIC);
> +	dest = kzalloc(sizeof(struct ip_vs_dest), GFP_KERNEL);
>  	if (dest == NULL) {
>  		pr_err("%s(): no memory.\n", __func__);
>  		return -ENOMEM;
> @@ -1177,7 +1177,7 @@ ip_vs_add_service(struct ip_vs_service_user_kern *u,
>  	}
>  #endif
>  
> -	svc = kzalloc(sizeof(struct ip_vs_service), GFP_ATOMIC);
> +	svc = kzalloc(sizeof(struct ip_vs_service), GFP_KERNEL);
>  	if (svc == NULL) {
>  		IP_VS_DBG(1, "%s(): no memory\n", __func__);
>  		ret = -ENOMEM;
> 
