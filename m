From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
	input_pkt_queue
Date: Sat, 1 May 2010 13:00:00 +0200
Message-ID: <20100501110000.GB9434@gargoyle.fritz.box>
References: <20100429182347.GA8512@gargoyle.fritz.box> <1272568347.2209.11.camel@edumazet-laptop> <20100429214144.GA10663@gargoyle.fritz.box> <20100430.163857.180417789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, hadi@cyberus.ca, xiaosuo@gmail.com,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	lenb@kernel.org, arjan@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:38465 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020Ab0EAK5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 06:57:25 -0400
Content-Disposition: inline
In-Reply-To: <20100430.163857.180417789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 30, 2010 at 04:38:57PM -0700, David Miller wrote:
> From: Andi Kleen <ak@gargoyle.fritz.box>
> Date: Thu, 29 Apr 2010 23:41:44 +0200
> 
> >     Use io_schedule() in network stack to tell cpuidle governour to guarantee lower latencies
> > 
> >     XXX: probably too aggressive, some of these sleeps are not under high load.
> > 
> >     Based on a bug report from Eric Dumazet.
> >     
> >     Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> I like this, except that we probably don't want the delayacct_blkio_*() calls
> these things do.

Yes.

It needs more work, please don't apply it yet, to handle the "long sleep" case.

Still curious if it fixes Eric's test case.

> 
> Probably the rest of what these things do should remain in the io_schedule*()
> functions and the block layer can call it's own versions which add in the
> delayacct_blkio_*() bits.

Good point.

> 
> Or, if the delacct stuff is useful for socket I/O too, then it's interfaces
> names should have the "blk" stripped from them :-)

Good question. I suspect it's actually useful for some cases, but just adding
sockets might confuse some users.

-Andi
