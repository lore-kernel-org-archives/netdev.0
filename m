From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net/mlx4: Mellanox driver update 01-01-2014
Date: Sun, 23 Feb 2014 11:01:44 +0200
Message-ID: <20140223090142.GA24010@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
 <20140219.165049.1684072721398326970.davem@davemloft.net>
 <1393032798.15717.85.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com, yuvala@mellanox.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:54352 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbaBWJBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 04:01:48 -0500
Received: by mail-wi0-f180.google.com with SMTP id hm4so2078184wib.7
        for <netdev@vger.kernel.org>; Sun, 23 Feb 2014 01:01:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1393032798.15717.85.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/02/14 01:33 +0000, Ben Hutchings wrote:
> On Wed, 2014-02-19 at 16:50 -0500, David Miller wrote:
> > From: Amir Vadai <amirv@mellanox.com>
> > Date: Wed, 19 Feb 2014 14:58:01 +0200
> > 
> > > V0 of this patch was sent before previous net-next got closed, and
> > > now we would like to resume it.
> > > 
> > > Yuval has reworked the affinity hint patch, according to Ben's comments. The
> > > patch was actually rewritten.
> > > After a discussion with Yuval Mintz, use of netif_get_num_default_rss_queues()
> > > is not reverted, but done in the right place. Instead of limiting the number of
> > > IRQ's for the driver it will limit the number of queues in RSS.
> > > 
> > > Patchset was applied and tested against commit: cb6e926 "ipv6:fix checkpatch
> > > errors with assignment in if condition"
> > 
> > Influencing IRQs to be allocated on the same NUMA code as the one where
> > the card resides doesn't sound like an mlx4 specific desire to me.
> > 
> > Other devices, both networking and non-networking, probably might like
> > that as well.
> > 
> > Therefore doing this by hand in a specific driver doesn't seem
> > appropriate at all.
> 
> Handling network traffic only on the local node can be really good on
> recent Intel processors, where DMA writes will usually go into cache on
> the local node.  But on other architectures, AMD processors, older Intel
> processors... I don't think there's such a big difference.  Also, where
> the system and device implement PCIe Transaction Processing Hints, DMA
> writes to cache should work on all nodes (following interrupt
> affinity)... in theory.
> 
> So this sort of policy not only shouldn't be implemented in specific
> drivers, but also ought to be configurable.
> 
> Ben.

Hi,

The idea here is to prefer a local node than a remote one - and not to
*always* use local nodes - kind of best effort approach.
The patch is relevant when number of rings is smaller (or bigger) than
number of CPU's - in this case the idea is to try to put the majority
of rx queues on the local node, and not to spread it evenly on the
numa nodes.
So, for Intel architecture you will get better performance in average,
and on other architectures, things will stay the same.

Therefore, I don't think it is needed to have a tunable for that.

If a user wants to use a more aggressive mode: to handle all incoming
traffic only by local nodes, he'll be able to do it by changing number
of rx channels to number of local cores - so we actually have the
tunable you had in mind.

Amir

> 
> -- 
> Ben Hutchings
> I haven't lost my mind; it's backed up on tape somewhere.
