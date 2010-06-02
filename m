From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 2 Jun 2010 13:01:45 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1006021255001.32431@router.home>
References: <1275496439.2725.203.camel@edumazet-laptop>  <alpine.DEB.2.00.1006021140320.30182@router.home>  <20100602.101258.134121018.davem@davemloft.net>  <20100602.103102.121237521.davem@davemloft.net> <1275500802.2519.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi129.sbcis.sbc.com ([207.115.36.143]:35186 "EHLO
	nlpi129.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932299Ab0FBSBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 14:01:48 -0400
In-Reply-To: <1275500802.2519.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jun 2010, Eric Dumazet wrote:

> Here is the patch I cooked to account for RP_FILTER errors in multicast
> path.
>
> I will complete it to also do the unicast part before official
> submission.
>
> Christoph, the official counter would be IPSTATS_MIB_INNOROUTES

Great. Thanks.

> ipSystemStatsInNoRoutes OBJECT-TYPE
>     SYNTAX     Counter32
>     MAX-ACCESS read-only
>     STATUS     current
>     DESCRIPTION
>            "The number of input IP datagrams discarded because no route
>             could be found to transmit them to their destination.

add "or because the rp_filter rejected the packet"? In the case of MC
traffic you dont really need a route.

In my particular case it is a weird corner case for the rp_filter.

Two NICs are on the same subnet. Different multicast groups are joined
on each (Using two NICs to balance the MC load since the drivers have
some multicast limitations and having different interrupt lines for each
NIC is also beneficial).

The rp_filter rejects all multicast traffic to the subscriptions on the
second NIC. I guess this is because the source address of the MC traffic
(on the same subnet) is also reachable via the first NIC.

So you could add also "because of breakage in the rp_filter (rp_filter
ignores the multicast subscription tables when determining the correct
reverse path of the packet)"

