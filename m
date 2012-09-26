From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH net-next] net: use bigger pages in __netdev_alloc_frag
Date: Wed, 26 Sep 2012 09:11:10 -0400
Message-ID: <20120926131110.GL10611@kvack.org>
References: <1348650402.5093.176.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:50635 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753619Ab2IZNLL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 09:11:11 -0400
Content-Disposition: inline
In-Reply-To: <1348650402.5093.176.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

On Wed, Sep 26, 2012 at 11:06:42AM +0200, Eric Dumazet wrote:
> +	int order;
...
> +		for (order = NETDEV_FRAG_PAGE_MAX_ORDER; ;) {
> +			gfp_t gfp = gfp_mask;
> +
> +			if (order)
> +				gfp |= __GFP_COMP | __GFP_NOWARN;
> +			nc->frag.page = alloc_pages(gfp, order);
> +			if (likely(nc->frag.page))
> +				break;
> +			if (--order <= 0)
> +				goto end;
> +		}

I think you probably intended the last if to be "if (--order < 0)", as 
otherwise the alloc will never be attempted with an order 0 page, which 
could harm systems suffering from extreme memory fragmentation.  Cheers,

		-ben
