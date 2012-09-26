From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: use bigger pages in __netdev_alloc_frag
Date: Wed, 26 Sep 2012 15:57:31 +0200
Message-ID: <1348667851.5093.355.camel@edumazet-glaptop>
References: <1348650402.5093.176.camel@edumazet-glaptop>
	 <20120926131110.GL10611@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58322 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879Ab2IZN5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 09:57:36 -0400
Received: by bkcjk13 with SMTP id jk13so341125bkc.19
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2012 06:57:35 -0700 (PDT)
In-Reply-To: <20120926131110.GL10611@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-26 at 09:11 -0400, Benjamin LaHaise wrote:
> Hello Eric,
> 
> On Wed, Sep 26, 2012 at 11:06:42AM +0200, Eric Dumazet wrote:
> > +	int order;
> ...
> > +		for (order = NETDEV_FRAG_PAGE_MAX_ORDER; ;) {
> > +			gfp_t gfp = gfp_mask;
> > +
> > +			if (order)
> > +				gfp |= __GFP_COMP | __GFP_NOWARN;
> > +			nc->frag.page = alloc_pages(gfp, order);
> > +			if (likely(nc->frag.page))
> > +				break;
> > +			if (--order <= 0)
> > +				goto end;
> > +		}
> 
> I think you probably intended the last if to be "if (--order < 0)", as 
> otherwise the alloc will never be attempted with an order 0 page, which 
> could harm systems suffering from extreme memory fragmentation.  Cheers,
> 

Indeed, thanks Ben !
