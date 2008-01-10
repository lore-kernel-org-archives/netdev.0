From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: 2.6.24-rc6-mm1
Date: Thu, 10 Jan 2008 09:54:21 +0900
Message-ID: <20080110095421R.fujita.tomonori@lab.ntt.co.jp>
References: <20080108155948.GC26114@elte.hu>
	<20080109085753O.fujita.tomonori@lab.ntt.co.jp>
	<20080109090442.GA1746@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, mingo@elte.hu,
	akpm@linux-foundation.org, just.for.lkml@googlemail.com,
	tomof@acm.org, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, neilb@suse.de, bfields@fieldses.org,
	netdev@vger.kernel.org, tom@opengridcomputing.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:38571 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753313AbYAJAzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 19:55:15 -0500
In-Reply-To: <20080109090442.GA1746@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Jan 2008 10:04:42 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Wed, Jan 09, 2008 at 08:57:53AM +0900, FUJITA Tomonori wrote:
> ...
> > diff --git a/lib/iommu-helper.c b/lib/iommu-helper.c
> > new file mode 100644
> > index 0000000..495575a
> > --- /dev/null
> > +++ b/lib/iommu-helper.c
> > @@ -0,0 +1,80 @@
> > +/*
> > + * IOMMU helper functions for the free area management
> > + */
> > +
> > +#include <linux/module.h>
> > +#include <linux/bitops.h>
> > +
> > +static unsigned long find_next_zero_area(unsigned long *map,
> > +					 unsigned long size,
> > +					 unsigned long start,
> > +					 unsigned int nr,
> > +					 unsigned long align_mask)
> > +{
> > +	unsigned long index, end, i;
> > +again:
> > +	index = find_next_zero_bit(map, size, start);
> > +
> > +	/* Align allocation */
> > +	index = (index + align_mask) & ~align_mask;
> > +
> > +	end = index + nr;
> > +	if (end >= size)
> > +		return -1;
> 
> This '>=' looks doubtful to me, e.g.:
> map points to 0s only,  size = 64, nr = 64,
> we get: index = 0; end = 64;
> and: return -1 ?!

You are right. I did it only because I didn't want to change the
original code (iommu_range_alloc in arch/powerpc/kernel/iommu.c). I
thought that there might be a mysterious reason for it so I let it
alone since it's tiny loss.

Thanks,
