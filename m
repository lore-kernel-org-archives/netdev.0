From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 5/6] slab: kmem_cache_objs_to_pages()
Date: Thu, 30 Nov 2006 19:55:17 +0100
Message-ID: <1164912917.6588.155.camel@twins>
References: <20061130101451.495412000@chello.nl> >
	 <20061130101922.175620000@chello.nl> >
	  <Pine.LNX.4.64.0611301053340.23820@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:50553 "EHLO
	amsfep13-int.chello.nl") by vger.kernel.org with ESMTP
	id S967882AbWK3TBl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 14:01:41 -0500
To: Christoph Lameter <clameter@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0611301053340.23820@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-30 at 10:55 -0800, Christoph Lameter wrote:
> On Thu, 30 Nov 2006, Peter Zijlstra wrote:
> 
> > +unsigned int kmem_cache_objs_to_pages(struct kmem_cache *cachep, int nr)
> > +{
> > +	return ((nr + cachep->num - 1) / cachep->num) << cachep->gfporder;
> 
> cachep->num refers to the number of objects in a slab of gfporder.

Ah, my bad, thanks!

> thus
> 
> return (nr + cachep->num - 1) / cachep->num;
> 
> But then this is very optimistic estimate that assumes a single node and 
> no free objects in between.

Right, perhaps my bad in wording the intent; the needed information is
how many more pages would I need to grow the slab with in order to store
so many new object.

