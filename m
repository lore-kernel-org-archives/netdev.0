From: Brent Cook <bcook@bpointsys.com>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 13:41:41 -0500
Message-ID: <200605251341.42204.bcook@bpointsys.com>
References: <20060523.182217.59656237.davem@davemloft.net> <200605250805.38241.bcook@bpointsys.com> <20060525175947.GA29024@ipom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>, Jeff Garzik <jeff@garzik.org>,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:46762 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S1030326AbWEYSln
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 14:41:43 -0400
To: Phil Dibowitz <phil@ipom.com>
In-Reply-To: <20060525175947.GA29024@ipom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 25 May 2006 12:59, Phil Dibowitz wrote:
> On Thu, May 25, 2006 at 08:05:37AM -0500, Brent Cook wrote:
> > > I'll admit to not knowing all the intricacies of the kernel coding
> > > involved, but I don't offhand see how zeroing the stats would be
> > > significantly more complex than updating the stats during normal usage.
> > > But I'll have to leave that argument to the experts.
> >
> > What it boils down to is that currently, a single CPU or thread ever
> > touches the stats concurrently, so it doesn't have to lock them or do
> > anything special to ensure that the continue incrementing. If you want to
> > make sure that the statistics actually reset when you want them to, you
> > have to account for this case:
> >
> >   CPU0 reads current value from memory (increment)
> >   CPU1 writes 0 to current value in memory (reset)
> >   CPU0 writes incremented value to memory (increment complete)
>
> Perhaps I'm missing something here, but these counters are only incrimented
> in hardware... i.e. attomically.
>

No, you're right - I'm just thinking that once one driver has this ability, 
users are going to want it for all network devices, and implementation on 
some devices (namely virtual ones - lo, tun, tap, br, vlan) is trickier than 
just setting a register. Some hardware devices too - mv643xx_eth.c just 
increments the network stats in software, for instance. Lockless software 
reset is fine though as long as people understand the consequences - it's 
absolutely fine, given the way I would use reset in my environment, MMV.
