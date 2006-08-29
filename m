From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 5/10]: [XFRM]: Dynamic xfrm_state hash table sizing.
Date: Tue, 29 Aug 2006 11:15:56 +0200
Message-ID: <200608291115.56865.dada1@cosmosbay.com>
References: <20060815.043905.79069789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:35050 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S932217AbWH2JPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 05:15:53 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060815.043905.79069789.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 15 August 2006 13:39, David Miller wrote:
> [XFRM]: Dynamic xfrm_state hash table sizing.

> +static struct hlist_head *xfrm_state_hash_alloc(unsigned int sz)
> +{
> +	struct hlist_head *n;
> +
> +	if (sz <= PAGE_SIZE)
> +		n = kmalloc(sz, GFP_KERNEL);
> +	else if (hashdist)
> +		n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
> +	else
> +		n = (struct hlist_head *)
> +			__get_free_pages(GFP_KERNEL, get_order(sz));
> +
> +	if (n)
> +		memset(n, 0, sz);
> +
> +	return n;
> +}

This kind of functions are becoming very common and duplicated... maybe we can 
factorize it ?

Also, it would be cool to be able to vmalloc()/free_pages hugetlb pages for 
very large hash tables...

> +
> +static void xfrm_state_hash_free(struct hlist_head *n, unsigned int sz)
> +{
> +	if (sz <= PAGE_SIZE)
> +		kfree(n);
> +	else if (hashdist)
> +		vfree(n);
> +	else
> +		free_pages((unsigned long)n, get_order(sz));
> +}
> +

Eric
