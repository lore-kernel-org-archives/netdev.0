From: David Miller <davem@davemloft.net>
Subject: Re: ARP table question
Date: Thu, 20 Nov 2008 00:33:06 -0800 (PST)
Message-ID: <20081120.003306.213001819.davem@davemloft.net>
References: <49221929.7060504@candelatech.com>
	<49221CE1.9000807@hp.com>
	<49221F7A.8030706@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org, kaber@trash.net
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753214AbYKTIdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 03:33:08 -0500
In-Reply-To: <49221F7A.8030706@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Mon, 17 Nov 2008 17:50:50 -0800

> Rick Jones wrote:
> > Ben Greear wrote:
> >> Rick Jones wrote:
> >>
> >>>> +static unsigned long neigh_rand_retry(struct neighbour* neigh) {
> >>>> +    if (neigh->parms->retrans_rand_backoff) {
> >>>> +        return net_random() % neigh->parms->retrans_rand_backoff;
> >>>> +    }
> >>>> +    return 0;
> >>>> +}
> >>>> +
> >>>>  /* Called when a timer expires for a neighbour entry. */
> >>>
> >>>
> >>> I thought that mod was something we tried to avoid?  Could you instead use something that isn't random but perhaps varies among all the requests?  Say some of the low-order bits of the IP being resolved?
> >>
> >>
> >> This is only called when we are going to retransmit an ARP, which shouldn't
> >> be in any sort of hot path, so I figured MOD was fine.
> >>
> >> The net_random is a very cheap method (last I checked), as well.
> >>
> >> So, I think that part is OK as it is, but I'm open to
> >> persuasion :)
> > Perhaps I'm confused, or simply channeling Emily Litella again, but if you only do this on the 1st through Nth retransmissions (ie after the first retransmission timer has popped) don't you still have a thundering herd problem on the first transmission and the first retransmission of ARP requests?
> 
> You'd certainly have it on the first transmission, but I think from there on
> the randomness should kick in.  This is a pretty rare case, and I'd rather
> not slow down the initial ARP.  If we *are* in the overload situation, then
> the network can just purge/drop/whatever the initial flood and then the
> retransmits should start doing their random thing.  On my system, it still
> takes maybe 30 seconds for all the ARPs to resolve since a good deal of
> the requests and/or responses are being lost.
> 
> After some more testing, I can still get it into a bad
> state if I have a retrans timer of 1 sec and a randomness of 5 secs
> and manage to cause all 1000 arp entries to go stale at once (by
> yanking a cable, for instance).
> 
> It seems I have to bump up the base timer to 3-5 seconds (I'm
> leaving the random backoff at 5 secs as well).

This scheme still seems hackish to me, so I'm going to defer on this
for now.
