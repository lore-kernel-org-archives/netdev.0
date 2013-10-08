From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] net: Add layer 2 hardware acceleration operations
 for macvlan devices
Date: Mon, 7 Oct 2013 20:52:00 -0400
Message-ID: <20131008005200.GA7791@neilslaptop.think-freely.org>
References: <20131007.155214.2232375975382665567.davem@davemloft.net>
 <20131007212000.GA1596@hmsreliant.think-freely.org>
 <20131007.173433.163556658910279518.davem@davemloft.net>
 <52533805.2010607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59398 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530Ab3JHAwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 20:52:22 -0400
Content-Disposition: inline
In-Reply-To: <52533805.2010607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 07, 2013 at 03:39:01PM -0700, John Fastabend wrote:
> On 10/07/2013 02:34 PM, David Miller wrote:
> >From: Neil Horman <nhorman@tuxdriver.com>
> >Date: Mon, 7 Oct 2013 17:20:00 -0400
> >
> >>Thats me experimenting.  I was thinking that origionally this functionality
> >>might be grouped separately, so that we could handle it independently of the
> >>standard network device operations (you might have noticed in v1 of my patch I
> >>had a size_t variable in there, so I thought the separation might be
> >>organizationally nice).  It was also something I was tinkering with for
> >>potential future work to support other data plane accelerators (like the FM6000
> >>switch chip from intel) in a manner that didn't pollute the more typical host network
> >>devices.  Like I said though, just experimenting at the moment....
> >
> 
> We can do something like the dcbnl ops and add another pointer off
> the net device structure and then use the skb->dev field to find the
> correct set of ops? This seems like the simplest option to me and
> isolates the ops structure.
> 
We certainly could do that, or perhaps, for what we're trying to do here, just
using standard netdev_ops is sufficient.  I kind of like the separation (like
the dcbnl_ops), but like I said, experimenting.  I'll try the next version with
the accel methods added to the netdev structure for comparison.

> Is there some information loss from hanging it off the netdevice
> structure vs the skb? I can't see any.
> 
No, not that I'm aware of.  The only reason I added it to the skb in this
version was that, by doing so, I was able to make dual use of the netdev's
standard tx path.

> >Can these dataplane devices still act like a normal networking port and
> >send and receive packets at the host level?
> >
> 
> Yes they act like normal networking ports except for there is a
> switching component in the hardware. These patches are not looking at
> virtual or multiple physical functions at the moment.
> 
To be clear, as John says, these patches aren't addressing any dataplane
acceleration devices beyond the internal switching capabilities of the ixgbe
cards.  That said, other chips will have varying degrees of capabilities, from
simple L2 switching, to full content addressable memories that allow for l2/l3
forwarding, as well as higher level routing functions.  Again however, these
patches are just to integrate macvlans with johns virtual station interface
work.

> >If yes, that would be an extremely strong argument for netdev_ops.
> 
> I agree.
In this specific case, that may well be the case, yes.  I'm not so sure of that
for more advanced switching/routing accelerators, but we probably should do what
makes sense now, and worry about future bridges when we forward over them
(pardon the pun :) ).

Neil

> 
> 
> -- 
> John Fastabend         Intel Corporation
> 
