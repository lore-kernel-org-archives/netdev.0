From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Wed, 09 Aug 2006 09:00:19 +0200
Message-ID: <1155106820.23134.37.camel@lappy>
References: <20060808193345.1396.16773.sendpatchset@lappy>
	 <20060808.151020.94555184.davem@davemloft.net>
	 <44D93BEE.4000001@google.com>
	 <20060808.184144.71088399.davem@davemloft.net>  <44D97645.90104@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:49702 "EHLO
	amsfep14-int.chello.nl") by vger.kernel.org with ESMTP
	id S965091AbWHIHBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 03:01:07 -0400
To: Daniel Phillips <phillips@google.com>
In-Reply-To: <44D97645.90104@google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 22:44 -0700, Daniel Phillips wrote:
> David Miller wrote:
> >From: Daniel Phillips <phillips@google.com>
> >>David Miller wrote:
> >>>I think the new atomic operation that will seemingly occur on every
> >>>device SKB free is unacceptable.
> >>
> >>Alternate suggestion?
> > 
> > Sorry, I have none.  But you're unlikely to get your changes
> > considered seriously unless you can avoid any new overhead your patch
> > has which is of this level.
> 
> We just skip anything new unless the socket is actively carrying block
> IO traffic, in which case we pay a miniscule price to avoid severe
> performance artifacts or in the worst case, deadlock.  So in this design
> the new atomic operation does not occur on every device SKP free.
> 
> All atomic ops sit behind the cheap test:
> 
>     (dev->flags & IFF_MEMALLOC)
> 
> or if any have escaped that is just an oversight.   Peter?

That should be so indeed. Except on the allocation path ofcourse, there
it only occurs when the first allocation fails.

> > We're busy trying to make these data structures smaller, and eliminate
> > atomic operations, as much as possible.  Therefore anything which adds
> > new datastructure elements and new atomic operations will be met with
> > fierce resistence unless it results an equal or greater shrink of
> > datastructures elsewhere or removes atomic operations elsewhere in
> > the critical path.
> 
> Right now we have a problem because our network stack cannot support
> block IO reliably.  Without that, Linux is no enterprise storage
> platform.

Indeed, surely not all wanted new features come with zero cost. If its a
hard condition that all new features remove data and operations progress
is going to be challenging.

