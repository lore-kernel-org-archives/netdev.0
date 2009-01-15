From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 16 Jan 2009 10:32:05 +1100
Message-ID: <20090115233205.GA8474@gondor.apana.org.au>
References: <20090114.012919.117682429.davem@davemloft.net> <20090115230331.GB1123@1wt.eu> <20090115231934.GA8328@gondor.apana.org.au> <20090115.152608.89323697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: w@1wt.eu, jarkao2@gmail.com, zbr@ioremap.net, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55104 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761318AbZAOXce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 18:32:34 -0500
Content-Disposition: inline
In-Reply-To: <20090115.152608.89323697.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 15, 2009 at 03:26:08PM -0800, David Miller wrote:
>
> New patch, this has the SKB clone removal as well:

Thanks Dave!

Something else just came to mind though.

> +static inline struct page *linear_to_page(struct page *page, unsigned int len,
> +					  unsigned int offset)
> +{
> +	struct page *p = alloc_pages(GFP_KERNEL, 0);
> +
> +	if (!p)
> +		return NULL;
> +	memcpy(page_address(p) + offset, page_address(page) + offset, len);

This won't work very well if skb->head is longer than a page.

We'll need to divide it up into individual pages.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
