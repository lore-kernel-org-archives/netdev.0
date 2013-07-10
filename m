From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 23:21:49 +0200
Message-ID: <20130710212149.GA26122@order.stressinduktion.org>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <51DD2959.9060206@6wind.com> <20130710105316.GA5735@order.stressinduktion.org> <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org> <51DD6B72.1050700@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:37805 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295Ab3GJVVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 17:21:50 -0400
Content-Disposition: inline
In-Reply-To: <51DD6B72.1050700@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 04:10:58PM +0200, Nicolas Dichtel wrote:
> I wonder why expires is 0. Even if this route is cached, the flag 
> RTF_EXPIRES should be set. Am I wrong?

rt6_set_from deliberately clears the RTF_EXPIRES when creating a cached copy
of the route if the route is an autoconfigured default route.

Maybe the criterion for exclusion of which routes can get into an ecmp route
set should be revisited? This could result in strange effects for users
working with two interfaces, both receiving a RA with default routes.

Thanks,

  Hannes
