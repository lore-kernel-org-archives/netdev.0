From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 15:42:20 -0800
Message-ID: <1134603740.8855.24.camel@w-sridhar2.beaverton.ibm.com>
References: <Pine.LNX.4.58.0512140042280.31720@w-sridhar.beaverton.ibm.com>
	 <9a8748490512141216x7e25ca2cucb675f11f0c9d913@mail.gmail.com>
	 <43A08546.8040708@superbug.co.uk>
	 <1134597344.8855.1.camel@w-sridhar2.beaverton.ibm.com>
	 <43A09811.2080909@superbug.co.uk>  <43A09F08.5000507@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Courtier-Dutton <James@superbug.co.uk>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965105AbVLNXnt@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <43A09F08.5000507@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2005-12-14 at 14:39 -0800, Ben Greear wrote:
> James Courtier-Dutton wrote:
> 
> > Have you actually thought about what would happen in a real world senario?
> > There is no real world requirement for this sort of user land feature.
> > In memory pressure mode, you don't care about user applications. In 
> > fact, under memory pressure no user applications are getting scheduled.
> > All you care about is swapping out memory to achieve a net gain in free 
> > memory, so that the applications can then run ok again.
> 
> Low 'ATOMIC' memory is different from the memory that user space typically
> uses, so just because you can't allocate an SKB does not mean you are swapping
> out user-space apps.
> 
> I have an app that can have 2000+ sockets open.  I would definately like to make
> the management and other important sockets have priority over others in my app...

The scenario we are trying to address is also a management connection between the 
nodes of a cluster and a server that manages the swap devices accessible by all the 
nodes of the cluster. The critical connection is supposed to be used to exchange 
status notifications of the swap devices so that failover can happen and propagated 
to all the nodes as quickly as possible. The management apps will be pinned into
memory so that they are not swapped out.

As such the traffic that flows over the critical sockets is not high but should
not stall even if we run into a memory constrained situation. That is the reason
why we would like to have a pre-allocated critical page pool which could be used
when we run out of ATOMIC memory.

Thanks
Sridhar
