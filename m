From: jamal <hadi@cyberus.ca>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: 09 Feb 2004 10:01:15 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076338874.1026.36.camel@jzny.localdomain>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sun, 2004-02-08 at 15:44, Julian Anastasov wrote:
> 	Hello,
> 
> 	Appended is a patch that modifies proxy_arp to check
> the target's neighbour state before reporting any information
> to requestors. The benefit is that the availability of the target
> host is properly reported to the requestor, we prefer not to send
> replies when target is unreachable. 

It should probably be a sysctl example proxy_arp_validate_neigh.
I am happy with the way it is right now in the situation i use it in.

> The changes:
> 
> - now pneigh_lookup has more priority compared to arp_fwd_proxy
>
> - neigh_event_ns is called only once per request, not twice

Could the neighbor be removed while we have the packet in the proxy
queue?
It doesnt seem like theres any harm done in redoing the neigh_event_ns
twice.

> - the 'skb->pkt_type == PACKET_HOST' check has no semantic anymore,
> the requestor should have same information no matter the packet
> type. In all cases we add response delay for all requests, broadcast
> or unicast, to help other authoritative hosts to reply before us.
> 

So far we havent been delaying responses to unicast because their
state is typically sane. I should say we are taking for granted
the sender's state machine is sane and would send a valid unicast
probe. Are you protecting against insane implementations?
Other than Linux what other OS actually sends unicast probes?

> - the RTCF_DNAT case is not delayed anymore (may be it is not used
> anymore, IIRC)
> 

Looking at 2.6.1 CONFIG_IP_ROUTE_NAT RTCF_NAT is still in use. Recommend
leaving it.

> Remaining questions:
> 
> - do we need to delay the pneigh_lookup case? Now it is still delayed
> as before.

Didnt follow.

cheers,
jamal
