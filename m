From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Tue, 10 Feb 2004 00:23:20 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402100008580.1251@u.domain.uli>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
 <1076338874.1026.36.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1076338874.1026.36.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Mon, 9 Feb 2004, jamal wrote:

> It should probably be a sysctl example proxy_arp_validate_neigh.
> I am happy with the way it is right now in the situation i use it in.

	I assume you need to probe with ARP request whether for some
IP we have:

- proxy entry

or

- we can respond for this target IP due to indev/proxy_arp set to 1

	Then where is better such flag to exist, for indev or
for outdev?

> > The changes:
> >
> > - now pneigh_lookup has more priority compared to arp_fwd_proxy
> >
> > - neigh_event_ns is called only once per request, not twice
>
> Could the neighbor be removed while we have the packet in the proxy
> queue?
> It doesnt seem like theres any harm done in redoing the neigh_event_ns
> twice.

	You are right, if proxy_delay is large the requestor can
disappear from our cache but it is not fatal for us to send reply,
we do not need cache entry for this. I'm not sure what is better, is
it right to confirm the requestor without receiving recent event
from it? If will be visible for too large proxy_delay values.

> > - the 'skb->pkt_type == PACKET_HOST' check has no semantic anymore,
> > the requestor should have same information no matter the packet
> > type. In all cases we add response delay for all requests, broadcast
> > or unicast, to help other authoritative hosts to reply before us.
> >
>
> So far we havent been delaying responses to unicast because their
> state is typically sane. I should say we are taking for granted
> the sender's state machine is sane and would send a valid unicast
> probe. Are you protecting against insane implementations?
> Other than Linux what other OS actually sends unicast probes?

	I already fixed that, if we have valid answer there is no good
reason to delay it if the probe was unicast.

> > - the RTCF_DNAT case is not delayed anymore (may be it is not used
> > anymore, IIRC)
> >
>
> Looking at 2.6.1 CONFIG_IP_ROUTE_NAT RTCF_NAT is still in use. Recommend
> leaving it.

	But there is no need to apply delay in this case.

> cheers,
> jamal

Regards

--
Julian Anastasov <ja@ssi.bg>
