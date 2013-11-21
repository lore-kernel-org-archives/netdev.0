From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Issue with gratuitous arps when new addr is different from cached addr
Date: Thu, 21 Nov 2013 07:26:35 +0100
Message-ID: <20131121062635.GD4347@order.stressinduktion.org>
References: <CAO7SqHAVz2D53u141Za01DvBFnLky2imkYNvBV-2UuALpC3w6w@mail.gmail.com> <20131121044048.GB4347@order.stressinduktion.org> <CAO7SqHC4astdejH6wVAyjsVeuh96T8P3ao3bCDNs=opfv5bbUg@mail.gmail.com> <20131121062349.GC4347@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Salam Noureddine <noureddine@aristanetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Phil Sutter <phil@nwl.cc>, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56367 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab3KUG0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:26:36 -0500
Content-Disposition: inline
In-Reply-To: <20131121062349.GC4347@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 21, 2013 at 07:23:49AM +0100, Hannes Frederic Sowa wrote:
> On Wed, Nov 20, 2013 at 10:06:34PM -0800, Salam Noureddine wrote:
> > Isn't locktime useful in that case for limiting the rate of garp
> > changes to the arp cache?
> 
> Yes, as I said, it would be nice to have rate-limiting for those, too.
> 
> GARP is used in cluster setups to make the switch-over as fast as possible and
> I don't think they accept those lock-down delays, so I guess it would be nice
> to forceful override the lladdr if (sip == tip) && ACCEPT_ARP(dev) is true in
> every case.
> 
> I guess you are not testing with ACCEPT_ARP?
> 
> In that case I am not sure what to do.
> 
> override = (...timing...) || sip == tip; could work but does relax the
> protection of the neigh cache.
> 
> In IPv6 we have a flag in the packet if we should overwrite the entry.
> 
> I'll have to think about that a bit more. Could well be the case that we need
> your proposal, too. But then we would have to validate the change with IPv6,
> too and neighbour cache states are really complex.

Hmm, could it help to bring the neighbor to suspect state (== WEAK_OVERRIDE)?
