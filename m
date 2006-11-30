From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 5/6] slab: kmem_cache_objs_to_pages()
Date: Thu, 30 Nov 2006 10:55:51 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611301053340.23820@schroedinger.engr.sgi.com>
References: <20061130101451.495412000@chello.nl>> <20061130101922.175620000@chello.nl>>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omx1-ext.sgi.com ([192.48.179.11]:45262 "EHLO omx1.sgi.com")
	by vger.kernel.org with ESMTP id S967866AbWK3S4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 13:56:00 -0500
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20061130101922.175620000@chello.nl>>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Nov 2006, Peter Zijlstra wrote:

> +unsigned int kmem_cache_objs_to_pages(struct kmem_cache *cachep, int nr)
> +{
> +	return ((nr + cachep->num - 1) / cachep->num) << cachep->gfporder;

cachep->num refers to the number of objects in a slab of gfporder.

thus

return (nr + cachep->num - 1) / cachep->num;

But then this is very optimistic estimate that assumes a single node and 
no free objects in between.
