From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: ipw2200: firmware DMA loading rework
Date: Tue, 8 Sep 2009 12:00:41 +0100
Message-ID: <20090908110041.GE28127__25189.6113194109$1252407676$gmane$org@csn.ul.ie>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <1251430951.3704.181.camel@debian> <200908301437.42133.bzolnier@gmail.com> <200909021948.13262.bzolnier@gmail.com> <43e72e890909021102g7f844c79xefccf305f5f5c5b6@mail.gmail.com> <20090903124913.GA26110@csn.ul.ie> <20090905142837.GI16217@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
To: Theodore Tso <tytso@mit.edu>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Zhu Yi <yi
Return-path: <netdev-owner@vger.kernel.org>
Received: from gir.skynet.ie ([193.1.99.77]:41830 "EHLO gir.skynet.ie"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754029AbZIHLAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2009 07:00:38 -0400
Content-Disposition: inline
In-Reply-To: <20090905142837.GI16217@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 05, 2009 at 10:28:37AM -0400, Theodore Tso wrote:
> On Thu, Sep 03, 2009 at 01:49:14PM +0100, Mel Gorman wrote:
> > > 
> > > This looks very similar to the kmemleak ext4 reports upon a mount. If
> > > it is the same issue, which from the trace it seems it is, then this
> > > is due to an extra kmalloc() allocation and this apparently will not
> > > get fixed on 2.6.31 due to the closeness of the merge window and the
> > > non-criticalness this issue has been deemed.
> 
> No, it's a different problem.
> 
> > I suspect the more pressing concern is why is this kmalloc() resulting in
> > an order-5 allocation request? What size is the buffer being requested?
> > Was that expected?  What is the contents of /proc/slabinfo in case a buffer
> > that should have required order-1 or order-2 is using a higher order for
> > some reason.
> 
> It's allocating 68,000 bytes for the mb_history structure, which is
> used for debugging purposes.  That's why it's optional and we continue
> if it's not allocated.  We should fix it to use vmalloc()

You could call with kmalloc(FLAGS|GFP_NOWARN) with a fallback to
vmalloc() and a disable if vmalloc() fails as well.  Maybe check out what
kernel/profile.c#profile_init() to allocate a large buffer and do something
similar?

> and I'm
> inclined to turn it off by default since it's not worth the overhead,
> and most ext4 users won't find it useful or interesting.
> 

I can't comment as I don't know what sort of debugging it's useful for.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
