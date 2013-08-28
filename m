From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Source routing without rules?
Date: Wed, 28 Aug 2013 03:51:58 +0200
Message-ID: <20130828015158.GA1741@order.stressinduktion.org>
References: <CALCETrVRZF0XLtH9o37Y=ZVMyyExBs7dLYFLOgJ-=vFqy+a_ig@mail.gmail.com> <20130828011437.GA30092@order.stressinduktion.org> <CALCETrWSgSnMdARZPGii5G1Yf43JjEPpeNgL2_yfDBd7W9650A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50458 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab3H1BwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 21:52:00 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrWSgSnMdARZPGii5G1Yf43JjEPpeNgL2_yfDBd7W9650A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 06:46:35PM -0700, Andy Lutomirski wrote:
> On Tue, Aug 27, 2013 at 6:14 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Tue, Aug 27, 2013 at 05:16:21PM -0700, Andy Lutomirski wrote:
> >> I'm about to implement a trivial source routing policy for the third
> >> time, and this is IMO stupid.  I want to have two routes to a network.
> >>  Each route should specify a src, and, if the flow matches the src,
> >> then that route should win.
> >>
> >> The rules that don't work are:
> >>
> >> ip route add <net> via <gw1> dev <dev1> metric 0
> >> ip route add <net> via <gw2> dev <dev2> src <dev2addr> metric 10
> >
> > src is actually the preferred src address. In ipv6 land there is a RTA_SRC
> > (look for ip route *from* parameter) route attribute settable to only
> > select routes if the from-source matches the route. If you implement
> > such a feature I would go with the same design (IPV6_SUBTREES).
> 
> Interesting.  The Kconfig help text for IPV6_SUBTREES is incredibly
> confusing.  What are the actual semantics?  I'm guessing that only
> routes that match the source address in their "from" clause are
> considered and ties are broken in favor of the longest from prefix.

At first normal longest-prefix lookup is done with the destination
address. The resulting fib6_node can now hold a subtree where a source
lookup will be done. If a node matches, this is the result. Otherwise
backtracking takes place in the "main" fib6_table.

Greetings,

  Hannes
