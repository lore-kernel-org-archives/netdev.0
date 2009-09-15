From: Simon Horman <horms@verge.net.au>
Subject: Re: igb bandwidth allocation configuration
Date: Tue, 15 Sep 2009 21:32:46 +1000
Message-ID: <20090915113239.GI24194@verge.net.au>
References: <20090910081844.GA5421@verge.net.au>
 <4AA8E2CE.2080707@trash.net>
 <4AA8E939.6050208@trash.net>
 <20090911003838.GA19376@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53402 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbZIOLco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 07:32:44 -0400
Content-Disposition: inline
In-Reply-To: <20090911003838.GA19376@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2009 at 10:38:38AM +1000, Simon Horman wrote:
> On Thu, Sep 10, 2009 at 01:55:37PM +0200, Patrick McHardy wrote:
> > Patrick McHardy wrote:
> > > Simon Horman wrote:
> > >>
> > >> I have been looking into adding support the 82586's per-PF/VF
> > >> bandwidth allocation to the igb driver. It seems that the trickiest
> > >> part is working out how to expose things to user-space.
> > >>
> > >> ...
> > >> Internally it seems that actually the limits are applied to HW Tx queues
> > >> rather than directly VMs. There are 16 such queues. Accordingly it might
> > >> be useful to design an interface to set limits per-queue using ethtool.
> > >> But this would seem to also require exposing which queues are associated
> > >> with which PF/VF.
> > > 
> > > Just an idea since I don't know much about this stuff:
> > > 
> > > Since we now have the mq packet scheduler, which exposes the device
> > > queues as qdisc classes, how about adding driver-specific configuration
> > > attributes that are passed to the driver by the mq scheduler? This
> > > would allow to configure per-queue bandwidth limits using regular TC
> > > commands and also use those limits without VFs for any kind of traffic.
> > > Drivers not supporting this would refuse unsupported options.
> > 
> > Attached patch demonstrates the idea. Compile-tested only.
> > 
> 
> Thanks, that seems like a pretty good idea to me.
> I'll see if I can make it work.

I've been looking over this a little more closely. While using mq
does seem to be a good way to configure the hw bandwith allocation
for queues belonging to the PF I don't think it can be used
for queues belonging to any VFs. Primarily because the VFs will
belong be different devices, possibly in different OSes.

A further complication is that although the PF and VFs have different
devices they do share hw and the bandwidth allocation rules in the
datasheet seem to imply that they bandwidth allocations need to be
made together to ensure that the rules aren't violated. That is,
they need to be verified as a group at some point. Which is
what let to my original suggestion of using ethtool on the device
corresponding to the PF.

