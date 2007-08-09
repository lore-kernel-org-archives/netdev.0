From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch] ipvs: force read of atomic_t in while loop
Date: Thu, 9 Aug 2007 02:15:33 +0200
Message-ID: <20070809001533.GA17798@one.firstfloor.org>
References: <20070808093300.GA14530@osiris.boeblingen.de.ibm.com> <20070808.032131.35507346.davem@davemloft.net> <20070808102835.GC14530@osiris.boeblingen.de.ibm.com> <46BA30DC.20207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, andi@firstfloor.org,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	torvalds@osdl.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37531 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762438AbXHIAPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 20:15:35 -0400
Content-Disposition: inline
In-Reply-To: <46BA30DC.20207@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 05:08:44PM -0400, Chris Snook wrote:
> Heiko Carstens wrote:
> >On Wed, Aug 08, 2007 at 03:21:31AM -0700, David Miller wrote:
> >>From: Heiko Carstens <heiko.carstens@de.ibm.com>
> >>Date: Wed, 8 Aug 2007 11:33:00 +0200
> >>
> >>>Just saw this while grepping for atomic_reads in a while loops.
> >>>Maybe we should re-add the volatile to atomic_t. Not sure.
> >>I think whatever the choice, it should be done consistently
> >>on every architecture.
> >>
> >>It's just asking for trouble if your arch does it differently from
> >>every other.
> >
> >Well..currently it's i386/x86_64 and s390 which have no volatile
> >in atomic_t. And yes, of course I agree it should be consistent
> >across all architectures. But it isn't.
> 
> Based on recent discussion, it's pretty clear that there's a lot of 
> confusion about this.  A lot of people (myself included, until I thought 
> about it long and hard) will reasonably assume that calling 
> atomic_read() will actually read the value from memory.  Leaving out the 
> volatile declaration seems like a pessimization to me.  If you force 
> people to use barrier() everywhere they're working with atomic_t, it 
> will force re-reads of all the non-atomic data in use as well, which 
> will cause more memory fetches of things that generally don't need 
> barrier().  That and it's a bug waiting to happen.
> 
> Andi -- your thoughts on the matter?

I also think readding volatile makes sense. An alternative would be
to stick an rmb() into atomic_read() -- that would also stop speculative reads.
Disadvantage is that it clobbers all memory, not just the specific value.

But you really have to complain to Linus (cc'ed). He came up
with the volatile removale change iirc.

-Andi

