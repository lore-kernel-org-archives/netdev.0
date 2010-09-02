From: Greg Lindahl <greg@blekko.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Wed, 1 Sep 2010 23:41:36 -0700
Message-ID: <20100902064136.GA8633@bx9.net>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com> <1283356463.2556.351.camel@edumazet-laptop> <AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com> <20100901.183251.106803238.davem@davemloft.net> <20100901185627.239ad165@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rc.bx9.net ([64.13.160.15]:36774 "EHLO rc.bx9.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753160Ab0IBHOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Sep 2010 03:14:06 -0400
Content-Disposition: inline
In-Reply-To: <20100901185627.239ad165@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 06:56:27PM -0700, Stephen Hemminger wrote:

> Just to be contrarian :-) This same idea had started before when IBM
> proposed a user-space NUMA API.  It never got any traction, the concept
> of "lets make the applications NUMA aware" never got accepted because
> it is so hard to do right and fragile that it was the wrong idea
> to start with. The only people that can manage it are the engineers
> tweeking a one off database benchmark.

As an non-database user-space example, there are many applications
which know about the typical 'first touch' locality policy for pages
and use that to be NUMA-aware. Just about every OpenMP program ever
written does that; it's even fairly portable among OSes.

A second user-level example is MPI implementations such as OpenMPI.
Those guys run 1 process per core and they don't need to move around,
so getting process locked to a core and all the pages in the right
place is a nice win without the MPI programmer doing anything.

For kernel (but non-Ethernet) networking examples, HPC interconnects
typically go out of their way to ensure locality of kernel pages
related to a given core's workload.  Examples include Myrinet's
OpenMX+MPI and the InfiniPath InfiniBand adapater, whatever QLogic
renamed it to this week (TrueScale, I suppose.) How can you get ~ 1
microsecond messages if you've got a buffer in the wrong place?  Or
achieve extremely high messaging rates when you're waiting for remote
memory all the time?

> I would rather see a "good enough" policy in the kernel that works
> for everything from a single-core embedded system to a 100 core
> server environment.

I'd like a pony. Yes, it's challenging to directly aapply the above
networking example to Ethernet networking, but there's a pony in there
somewhere.

-- greg


