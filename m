From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Sat, 20 Sep 2008 09:19:18 -0700
Message-ID: <20080920091918.0ffaef8c@infradead.org>
References: <20080919.234824.223177211.davem@davemloft.net>
	<1221924561.1343.121.camel@localhost.localdomain>
	<20080920084512.58f7fb08@infradead.org>
	<1221926529.1343.140.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: Daniel Walker <dwalker@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57054 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbYITQTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 12:19:19 -0400
In-Reply-To: <1221926529.1343.140.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Sep 2008 09:02:09 -0700
Daniel Walker <dwalker@mvista.com> wrote:

> On Sat, 2008-09-20 at 08:45 -0700, Arjan van de Ven wrote:
> > On Sat, 20 Sep 2008 08:29:21 -0700
> > > 
> > > > Jen's, as stated, has block layer uses for this.  I intend to
> > > > use this for receive side flow seperation on non-multiqueue
> > > > network cards.  And Steffen Klassert has a set of IPSEC
> > > > parallelization changes that can very likely make use of this.
> > > 
> > > What's the benefit that you (or Jens) sees from migrating softirqs
> > > from specific cpu's to others?
> > 
> > it means you do all the processing on the CPU that submitted the IO
> > in the first place, and likely still has the various metadata
> > pieces in its CPU cache (or at least you know you won't need to
> > bounce them over)
> 
> 
> In the case of networking and block I would think a lot of the softirq
> activity is asserted from userspace.. Maybe the scheduler shouldn't be
> migrating these tasks, or could take this softirq activity into
> account ..

well a lot of it comes from completion interrupts.

and moving userspace isn't a good option; think of the case of 1 nic
but 4 apache processes doing the work...


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
