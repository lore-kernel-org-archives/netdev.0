From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc6-mm1
Date: Tue, 8 Jan 2008 17:07:21 -0800
Message-ID: <20080108170721.8f4c7412.akpm@linux-foundation.org>
References: <20080108155948.GC26114@elte.hu>
	<20080109085753O.fujita.tomonori@lab.ntt.co.jp>
	<20080108162739.f2f577ce.akpm@linux-foundation.org>
	<20080109095445N.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, mingo@elte.hu,
	just.for.lkml@googlemail.com, tomof@acm.org, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, netdev@vger.kernel.org,
	tom@opengridcomputing.com
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39158 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751084AbYAIBIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 20:08:32 -0500
In-Reply-To: <20080109095445N.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 Jan 2008 09:54:45 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> > > --- a/lib/iommu-helper.c~a
> > > +++ a/lib/iommu-helper.c
> > > @@ -8,15 +8,20 @@
> > >  static unsigned long find_next_zero_area(unsigned long *map,
> > >  					 unsigned long size,
> > >  					 unsigned long start,
> > > -					 unsigned int nr)
> > > +					 unsigned int nr,
> > > +					 unsigned long align_mask)
> > >  {
> > >  	unsigned long index, end, i;
> > >  again:
> > >  	index = find_next_zero_bit(map, size, start);
> > > +
> > > +	/* Align allocation */
> > > +	index = (index + align_mask) & ~align_mask;
> > 
> > The ALIGN() macro is the approved way of doing this.
> > 
> > (I don't think ALIGN adds much value really, especially given that you've
> > commented what's going on, but I guess it does make reviewing and reading a
> > little easier).
> 
> Would be better to use __ALIGN_MASK? I can find only one user who
> directly use __ALIGN_MASK. The POWER IOMMU calculates align_mask by
> itself so it's easier to pass align_mask as an argument.

ALIGN() should be OK - its aditional type coercion isn't useful in this
case but ALIGN() is the official interface.

I don't see any reason why vermilion.c had to reach for __ALIGN_MASK.  I'll
switch it to ALIGN().

