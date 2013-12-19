From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect forwarding path against pmtu spoofing
Date: Fri, 20 Dec 2013 00:53:38 +0100
Message-ID: <20131219235338.GA32129@order.stressinduktion.org>
References: <20131219000759.GF3505@order.stressinduktion.org> <20131219.001203.1942468169345523058.davem@davemloft.net> <20131219121757.GD14429@order.stressinduktion.org> <20131219.143012.205185984019527730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:41236 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756264Ab3LSXxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 18:53:39 -0500
Content-Disposition: inline
In-Reply-To: <20131219.143012.205185984019527730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 02:30:12PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Thu, 19 Dec 2013 13:17:57 +0100
> 
> > Networking software on the end system which wants to guard against
> > that kind of fragmentation can do so by using the various knobs to
> > limit pmtu notification processing or use IP_PMTUDISC_INTERFACE to
> > protect itself from sending fragments.
> 
> And that's part of where my irritation is coming from.
> 
> Applications have to opt-in to this new socket option based behavior,
> but you're making the routing thing default to on.
>
> And even if we default it to off, someone is going to cry and tell all
> the distributions to turn it on in /etc/sysctl.conf, just like they
> did for rp_filter.  And they will.  I don't have the strength and time
> to fight every person who makes these decisions at all the major
> distributions to explain to each and every one of them how foolish it
> would be.
> 
> No end host should have rp_filter on.  It unnecessarily makes our
> routing lookups much more expensive for zero gain on an end host.  But
> people convinced the distributions that turning it on everywhere by
> default was a good idea and it stuck.

Ack.

> I don't want to create a carrot for that kind of situation again.

I see your point. How should we proceed? I definitely see this as a problem.
I just want to point to RFC 1191 "4. Router specification", where it clearly
states that the MTU that should be considered is that of the next-hop network.
And the MTU carried in a fragmentation-needed notification should denote the
size so that the packet is not going to be fragmented at *this* router.

I am fine dropping the knob and just unconditionally ignoring the pmtu data in
the forwarding path? Is that what you wanted to suggest?

Greetings,

  Hannes
