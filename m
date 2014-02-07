From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: Cascading Bond devices
Date: Fri, 7 Feb 2014 09:19:27 +0100
Message-ID: <20140207081927.GC17815@glanzmann.de>
References: <20140207074149.GA17815@glanzmann.de>
 <2905.1391759849@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Development <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from infra.glanzmann.de ([88.198.249.254]:59140 "EHLO
	infra.glanzmann.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaBGIT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 03:19:29 -0500
Content-Disposition: inline
In-Reply-To: <2905.1391759849@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jay,

> For this specific case, it is unnecessary to nest the bonds, as one
> feature of 802.3ad is that it will group the ports correctly into
> multiple aggregators, and fail over from one to the other under
> certain circumstances selected by the ad_select parameter.  It is not
> possible to select different hash algorithms on a per-aggregator
> basis, though.

perfect. Thank you a lot for clarifying. I'll reconfigure my system
tongiht accordingly.

> Generally speaking, nesting of bonds does not function correctly.  It
> is possible to configure, but various parts do not function as
> expected from the nesting (when last I checked, transmit generally
> functioned, but receive generally did not).

I see.

> > Trouble with tlb with IPv4 and IPv6.

> With a nesting, or just in general?

In general. To be precise I had the following scenario:

switch-1 port-1 \
switch-1 port-2 \
switch-2 port-1 - bond0 (tlb)
switch-2 port-2 /

But at the same time I had tagged and untagged vlans on the bond
Interface. What always for me happened is that I was unable to set an
IPv6 address on the bond. This was on 3.2.0-4 which ships with Debian
Wheezy (7). So what I did is I started the bond with one interface, set
the IPv6 interface and enslaved another interface.

This worked perfectly fine for weeks until one morning at 05:00 am my
provider took my interface down because of broadcast storms. There were
two systems on that particular broadcast domain. The otherone had just
one network card and nothing was going on there, so I assume it was the
system with the bonding, but I never actually verified it.

The second problem I had is in order to avoid not be able to set the
IPv6 address on the bond I tried to disable 'dad', so I did that and it
worked perfectly fine, until I rebooted. And immediately my provider
took down the interface again because of broadcast storms. So I disabled
it and never looked back.

The Juniper router of my provider was complaining about:

storm control in effect on the port

So what I will do is in a lab system which has not access to the
upstream switch, I'll configure tlb with IPv6 as described as above and
let you know the results and provide you with pcaps if necessary.
Hopefully we can figure out what is going wrong and fix it.

> I have not tested alb/tlb modes much with IPv6, but the remote peer
> load balancing scheme for alb mode in particular is only implemented
> for IPv4.  I do recall that both of them should balance outgoing
> traffic for IPv6.

I see. TLB would fit my scenario perfectly: The system in question is an
install server for 60 servers which are installed concurrently on a
weekly basis over Gbit. So having four 1 GBIT links help especially as
the system in question is the default gateway so that it actually can
use the bandwidth and is not limited by router in between.

> As far as storms go, normally for tlb/alb, one slave is the "active"
> slave, and for both alb and tlb should be the only slave that receives
> broadcasts or multicasts. For tlb mode, the active slave is the only
> slave that receives anything at all, the others are transmit-only. For
> alb mode, the other slaves receive unicast traffic from network peers
> according to the balance algorithm issuing special ARP frames to those
> peers to direct their traffic (this is the IPv4-only part).

I see.

> I have not tested tlb/alb with very recent kernels, so it's possible
> that something has been broken in some of the substantial changes over
> the last few months.

I'll do some more testing and as soon as I have something substantial,
I'll report back with a problem or with a good to go. :-)

Thanks again for the clarification.

Cheers,
        Thomas
