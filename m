From: Greg KH <greg@kroah.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Mon, 30 Jan 2012 13:56:00 -0800
Message-ID: <20120130215600.GA14656@kroah.com>
References: <20120130171215.GA11508@kroah.com>
 <20120130.130717.348683183628737352.davem@davemloft.net>
 <4F26E72E.2020007@profihost.ag>
 <20120130.164828.1695146432151008554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: s.priebe@profihost.ag, eric.dumazet@gmail.com, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:38380 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752291Ab2A3V4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 16:56:17 -0500
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 1DB1621084
	for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 16:56:17 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <20120130.164828.1695146432151008554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2012 at 04:48:28PM -0500, David Miller wrote:
> From: Stefan Priebe <s.priebe@profihost.ag>
> Date: Mon, 30 Jan 2012 19:53:34 +0100
> 
> > So we're talking AT LEAST about these ones:
> >>Linus tree :
> >>
> >>commit 580da35a31f91a594f3090b7a2c39b85cb051a12
> >>IB: Fix RCU lockdep splats
> 
> Doesn't even come close to applying to v3.0.18
> 
> That patch would only apply properly if the IB code is using the
> dst_get_neighbour() interface, which doesn't even exist in v3.0.18
> 
> >>David tree :
> >>
> >>commit 218fa90f072e4aeff9003d57e390857f4f35513e
> >>ipv4: fix lockdep splat in rt_cache_seq_show
> 
> Patch also does not apply, and for the same reason as the IB patch.
> 
> dst_get_neighbour() doesn't exist in v3.0.18, and therefore this code
> being patched doesn't make use of it.
> 
> >>commit f7e57044eeb1841847c24aa06766c8290c202583
> >>sch_teql: fix lockdep splat
> 
> I'm not even going to try applying this one, it's going to have the
> same issue as the previous two.
> 
> The patch mentioned by commit 218fa90f072e4aeff9003d57e390857f4f35513e
> ("ipv4: fix lockdep splat in rt_cache_seq_show") is not in the v3.0.x
> tree, and it's a prerequisite for the rt_cache_seq_show() change
> being even necessary.
> 
> In all, I think this request is invalid.
> 
> You're asking me to submit patches to -stable which don't apply
> even remotely, and whose dependencies haven't even been applied
> to the tree.

Which makes me believe this really isn't a problem at all for 3.0.y...

David, thanks for going through this.

Stefan, you owe David a bunch of beer.
