From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 2 Jun 2010 13:59:21 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1006021355040.32431@router.home>
References: <1275496439.2725.203.camel@edumazet-laptop>  <alpine.DEB.2.00.1006021140320.30182@router.home>  <20100602.101258.134121018.davem@davemloft.net>  <20100602.103102.121237521.davem@davemloft.net>  <1275500802.2519.7.camel@edumazet-laptop>
 <alpine.DEB.2.00.1006021255001.32431@router.home> <1275504070.2519.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi157.sbcis.sbc.com ([207.115.36.171]:45412 "EHLO
	nlpi157.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757951Ab0FBS70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 14:59:26 -0400
In-Reply-To: <1275504070.2519.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jun 2010, Eric Dumazet wrote:

> > In my particular case it is a weird corner case for the rp_filter.
> >
> > Two NICs are on the same subnet. Different multicast groups are joined
> > on each (Using two NICs to balance the MC load since the drivers have
> > some multicast limitations and having different interrupt lines for each
> > NIC is also beneficial).
> >
>
> yeah, I know about this problem, and am working on it too...
>
> > The rp_filter rejects all multicast traffic to the subscriptions on the
> > second NIC. I guess this is because the source address of the MC traffic
> > (on the same subnet) is also reachable via the first NIC.
> >
>
> Its clearly a case were rp_filter should be set to 2, dont you think ?

The rp_filter is rejecting traffic coming into a NIC for which the kernel
has a multicast join list that indicates that this traffic is expected on
this NIC. You could consult the MC subscription list to verify that the
traffic is coming into the right NIC.

In the MC case the user can explicitly specify through which NIC the
traffic is expected. See IP_ADD_MEMBERSHIP.
