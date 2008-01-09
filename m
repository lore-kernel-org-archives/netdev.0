From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24-rc6-mm1
Date: Wed, 9 Jan 2008 10:04:42 +0100
Message-ID: <20080109090442.GA1746@ff.dom.local>
References: <64bb37e0801061203l503f29f0hd922a1347f8169ac@mail.gmail.com> <20080107151639P.fujita.tomonori@lab.ntt.co.jp> <20080108155948.GC26114@elte.hu> <20080109085753O.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, akpm@linux-foundation.org,
	just.for.lkml@googlemail.com, tomof@acm.org,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	neilb@suse.de, bfields@fieldses.org, netdev@vger.kernel.org,
	tom@opengridcomputing.com
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:64205 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbYAII6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 03:58:35 -0500
Received: by ug-out-1314.google.com with SMTP id z38so51360ugc.16
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2008 00:58:34 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080109085753O.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 08:57:53AM +0900, FUJITA Tomonori wrote:
...
> diff --git a/lib/iommu-helper.c b/lib/iommu-helper.c
> new file mode 100644
> index 0000000..495575a
> --- /dev/null
> +++ b/lib/iommu-helper.c
> @@ -0,0 +1,80 @@
> +/*
> + * IOMMU helper functions for the free area management
> + */
> +
> +#include <linux/module.h>
> +#include <linux/bitops.h>
> +
> +static unsigned long find_next_zero_area(unsigned long *map,
> +					 unsigned long size,
> +					 unsigned long start,
> +					 unsigned int nr,
> +					 unsigned long align_mask)
> +{
> +	unsigned long index, end, i;
> +again:
> +	index = find_next_zero_bit(map, size, start);
> +
> +	/* Align allocation */
> +	index = (index + align_mask) & ~align_mask;
> +
> +	end = index + nr;
> +	if (end >= size)
> +		return -1;

This '>=' looks doubtful to me, e.g.:
map points to 0s only,  size = 64, nr = 64,
we get: index = 0; end = 64;
and: return -1 ?!

Regards,
Jarek P.
