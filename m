From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: 2.6.24-rc6-mm1
Date: Wed, 09 Jan 2008 09:54:45 +0900
Message-ID: <20080109095445N.fujita.tomonori@lab.ntt.co.jp>
References: <20080108155948.GC26114@elte.hu>
	<20080109085753O.fujita.tomonori@lab.ntt.co.jp>
	<20080108162739.f2f577ce.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, mingo@elte.hu,
	just.for.lkml@googlemail.com, tomof@acm.org, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, netdev@vger.kernel.org,
	tom@opengridcomputing.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama555.ecl.ntt.co.jp ([129.60.39.106]:46784 "EHLO
	tama555.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757050AbYAIAzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 19:55:49 -0500
In-Reply-To: <20080108162739.f2f577ce.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Jan 2008 16:27:39 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 09 Jan 2008 08:57:53 +0900
> FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> 
> > Andrew, can you replace
> > 
> > iommu-sg-add-iommu-helper-functions-for-the-free-area-management.patch
> > 
> > with the updated patch:
> > 
> > http://ozlabs.org/pipermail/linuxppc-dev/2007-December/048997.html
> > 
> > For your convenience I've attached the updated patch too.
> 
> <generates the incremental>

Thanks for putting the fix to -mm.


> > --- a/lib/iommu-helper.c~a
> > +++ a/lib/iommu-helper.c
> > @@ -8,15 +8,20 @@
> >  static unsigned long find_next_zero_area(unsigned long *map,
> >  					 unsigned long size,
> >  					 unsigned long start,
> > -					 unsigned int nr)
> > +					 unsigned int nr,
> > +					 unsigned long align_mask)
> >  {
> >  	unsigned long index, end, i;
> >  again:
> >  	index = find_next_zero_bit(map, size, start);
> > +
> > +	/* Align allocation */
> > +	index = (index + align_mask) & ~align_mask;
> 
> The ALIGN() macro is the approved way of doing this.
> 
> (I don't think ALIGN adds much value really, especially given that you've
> commented what's going on, but I guess it does make reviewing and reading a
> little easier).

Would be better to use __ALIGN_MASK? I can find only one user who
directly use __ALIGN_MASK. The POWER IOMMU calculates align_mask by
itself so it's easier to pass align_mask as an argument.
