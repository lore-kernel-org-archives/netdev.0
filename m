From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Wed, 3 Dec 2003 03:43:02 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312030251410.1237-100000@u.domain.uli>
References: <20031202163902.2deb43a7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: herbert@gondor.apana.org.au, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031202163902.2deb43a7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 2 Dec 2003, David S. Miller wrote:

> > - ip_rt_frag_needed now provides interface index
>
> I disagree with this.
>
> There is no connection between the route (and thus output
> device) we used to send a packet and the interface on which
> an ICMP for that packet comes back upon.  Think assymetric
> routes.

	Agreed. This is a very bad case for PMTUD. It can be
even a multipath route with different PMTUs.

> You changes mean that for routes with specific output interfaces,
> we will ignore ICMPs for those routes that arrive on other interfaces
> due to assymetric routing.

	They are already ignored because the oif is a hash key.
With the current code I do not think we can find other oif
values in the current row when the oif hash key is 0. With the
changes, we are trying to walk the rows for oif=IIF and oif=0. We
can not learn how many paths and oifs we have before the smallest
pmtu that generates ICMPs. We are even not sure when the ICMP
comes if the originating packet was routed with oif 0 or not 0.
So, may be it is better to set the smallest pmtu for all these
paths, for oif 0 as before and now for oif=IIF.

        About CONFIG_IP_ROUTE_TOS, why it is not propagated
to the routing cache? Then for the fl4_tos value we will have
only two cases, onlink or not onlink. In essence, I see it
as defining IPTOS_RT_MASK to 0 when CONFIG_IP_ROUTE_TOS is not
defined. If this is working it solves so many problems: cache size,
PMTUD. Is it really so easy?

	CONFIG_IP_ROUTE_TOS disables tos match in rules and routes,
so why we have to waste memory for the route cache when all these
routes receive same path no matter the tos value?

> Why don't you create a seperate patch that just has the TOS masking
> changes?  That's much less controversial and thus something I'm likely
> to apply.

	ok, may be after some days for rethinking :) let me
know for the final thoughts and I can create patch(es) after
reading some standards.

Regards

--
Julian Anastasov <ja@ssi.bg>
