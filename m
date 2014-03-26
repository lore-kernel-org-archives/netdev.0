From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3] ipv6: do not overwrite inetpeer metrics prematurely
Date: Wed, 26 Mar 2014 16:50:47 +0100
Message-ID: <20140326155047.GG22086@order.stressinduktion.org>
References: <20140325191155.GB22086@order.stressinduktion.org> <20140326154245.10C6CE6E05@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:32883 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754857AbaCZPut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 11:50:49 -0400
Content-Disposition: inline
In-Reply-To: <20140326154245.10C6CE6E05@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 04:42:45PM +0100, Michal Kubecek wrote:
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index fba54a4..b6dda6a 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -149,8 +149,10 @@ static u32 *ipv6_cow_metrics(struct dst_entry *dst, unsigned long old)
>  		unsigned long prev, new;
>  
>  		p = peer->metrics;
> -		if (inet_metrics_new(peer))
> +		if (inet_metrics_new(peer) || (dst->flags | DST_KEEP_METRICS)) {
>  			memcpy(p, old_p, sizeof(u32) * RTAX_MAX);
> +			dst->flags &= ~DST_KEEP_METRICS;
> +		}

The (dst->flags | DST_KEEP_METRICS) looks very suspicious. ;)

Bye,

  Hannes
