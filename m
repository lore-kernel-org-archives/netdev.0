From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Fri, 12 Jul 2013 23:48:36 +0200
Message-ID: <20130712214836.GR12611@order.stressinduktion.org>
References: <20130710212149.GA26122@order.stressinduktion.org> <51DE671F.5050706@6wind.com> <20130711102441.GC5207@order.stressinduktion.org> <20130711144623.GA5707@order.stressinduktion.org> <51DEC7E6.8000500@6wind.com> <20130712085113.GI12611@order.stressinduktion.org> <51DFF0DD.5050601@6wind.com> <20130712161935.GB31912@order.stressinduktion.org> <51E0527D.2030205@6wind.com> <20130712192023.GP12611@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:42407 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178Ab3GLVsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 17:48:37 -0400
Content-Disposition: inline
In-Reply-To: <20130712192023.GP12611@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 12, 2013 at 09:20:23PM +0200, Hannes Frederic Sowa wrote:
> --- a/net/ipv6/ip6_fib.c
> +++ b/net/ipv6/ip6_fib.c
> @@ -682,6 +682,7 @@ static int fib6_add_rt2node(struct fib6_node *fn, struct rt6_info *rt,
>                                         rt->rt6i_nsiblings = 0;
>                                 if (!(iter->rt6i_flags & RTF_EXPIRES))
>                                         return -EEXIST;
> +                               iter->rt6i_flags |= rt->rt6i_flags & RTF_DYNAMIC;
>                                 if (!(rt->rt6i_flags & RTF_EXPIRES))
>                                         rt6_clean_expires(iter);
>                                 else
> 

This was not necessary and just complicated things because we would have to
special-case the toggling of the RTF_DYNAMIC flag to also get removed from the
ecmp route set.

Thanks,

  Hannes
