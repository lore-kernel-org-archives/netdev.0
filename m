From: Simon Horman <horms@verge.net.au>
Subject: Re: igb bandwidth allocation configuration
Date: Fri, 11 Sep 2009 10:38:38 +1000
Message-ID: <20090911003838.GA19376@verge.net.au>
References: <20090910081844.GA5421@verge.net.au>
 <4AA8E2CE.2080707@trash.net>
 <4AA8E939.6050208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:57296 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353AbZIKAig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 20:38:36 -0400
Content-Disposition: inline
In-Reply-To: <4AA8E939.6050208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2009 at 01:55:37PM +0200, Patrick McHardy wrote:
> Patrick McHardy wrote:
> > Simon Horman wrote:
> >>
> >> I have been looking into adding support the 82586's per-PF/VF
> >> bandwidth allocation to the igb driver. It seems that the trickiest
> >> part is working out how to expose things to user-space.
> >>
> >> ...
> >> Internally it seems that actually the limits are applied to HW Tx queues
> >> rather than directly VMs. There are 16 such queues. Accordingly it might
> >> be useful to design an interface to set limits per-queue using ethtool.
> >> But this would seem to also require exposing which queues are associated
> >> with which PF/VF.
> > 
> > Just an idea since I don't know much about this stuff:
> > 
> > Since we now have the mq packet scheduler, which exposes the device
> > queues as qdisc classes, how about adding driver-specific configuration
> > attributes that are passed to the driver by the mq scheduler? This
> > would allow to configure per-queue bandwidth limits using regular TC
> > commands and also use those limits without VFs for any kind of traffic.
> > Drivers not supporting this would refuse unsupported options.
> 
> Attached patch demonstrates the idea. Compile-tested only.
> 

Thanks, that seems like a pretty good idea to me.
I'll see if I can make it work.

