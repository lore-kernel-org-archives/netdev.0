From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 08/40] mm: kmem_cache_objsize
Date: Fri, 04 May 2007 19:59:05 +0200
Message-ID: <1178301545.24217.56.camel@twins>
References: <20070504102651.923946304@chello.nl>
	 <20070504103157.215424767@chello.nl>
	 <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:9225 "EHLO
	amsfep18-int.chello.nl" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1031451AbXEDR7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 13:59:09 -0400
In-Reply-To: <Pine.LNX.4.64.0705040932200.22033@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-05-04 at 09:36 -0700, Christoph Lameter wrote:
> On Fri, 4 May 2007, Peter Zijlstra wrote:
> 
> > Expost buffer_size in order to allow fair estimates on the actual space 
> > used/needed.
> 
> If its just an estimate that you are after then I think ksize is 
> sufficient.
> 
> The buffer size does not include the other per slab overhead that SLAB 
> needs nor the alignment overhead or the padding. For SLUB you'd be more 
> lucky but there it does not include the per slab padding that exist.
> 
> Need to check how this is going to be used. It is difficult to estimate 
> slab use because this depends on the availability of object slots in 
> partial slabs.
> 
> I could add a function that tells you how many object you could allocate 
> from a slab without the page allocator becoming involved? It would count 
> the object slots available on the partial slabs.

I need to know how many pages to reserve to allocate a given number of
items from a given slab; assuming the partial slabs are empty. That is,
I need a worst case upper bound.

