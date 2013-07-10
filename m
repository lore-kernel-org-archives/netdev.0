From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 13:15:04 +0200
Message-ID: <20130710111504.GA15411@order.stressinduktion.org>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:36569 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676Ab3GJLPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 07:15:06 -0400
Content-Disposition: inline
In-Reply-To: <51DD1352.8000705@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 09:54:58AM +0200, Nicolas Dichtel wrote:
> Le 09/07/2013 23:57, Hannes Frederic Sowa a =C3=A9crit :
> >Are we sure we decrement all sibling's rt6i_nsiblings? Shouldn't we
> >start iterating from fn->leaf? But this does not seem to cause it,
> >because my trace does not report any calls to fib6_del_route.
> Note sure to follow you, but all siblings are listed in rt6i_siblings=
, so=20
> it must be enough.

My hunch was to iterate over fn->leaf->rt_next and compare the metrics =
like we
do when adding a new route. Then take that rt6_info->rt6i_siblings list=
_head
to iterate over the remaining siblings. But I did not review that part
carefully, need to check later.

> >You could try reproduce it by having an interface autoconfigured wit=
h
> >a default router with NUD_VALID neighbour. I then added an unused vl=
an
> >interface (vid 100 in my case) and added the following ip addresses:
> >
> >ip -6 a a 2001:ffff::1/64 dev eth0.100
> >ip -6 r a 2000::/3 nexthop via 2001:ffff::30 nexthop via 2001:ffff::=
31=20
> >nexthop via 2001:ffff::32 nexthop via 2001:ffff::33
> >
> >(all nexthops should not be reachable)
> >
> >After starting a ping6 2000::1 the box should panic soon, after the
> >first nexthop entry times out.
> >
> >Perhaps you could give me a hint?
> I will run some tests with your patch. Will see.
>=20
> I assume you didn't reproduce this without your patch.

Current kernel does not correctly select more specific routes, so these=
 routes
are not even tried and the logic should not be excercised.

Ah, sorry, you should also compile your kernel without
CONFIG_IPV6_ROUTER_PREF, too, if you try to reproduce it.

Thanks for looking into this,

  Hannes
