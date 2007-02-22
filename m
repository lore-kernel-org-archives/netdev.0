From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 08/29] mm: kmem_cache_objs_to_pages()
Date: Thu, 22 Feb 2007 10:28:28 +0100
Message-ID: <1172136508.6374.41.camel@twins>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
	 <20070221144842.299190000@taijtu.programming.kicks-ass.net>
	 <84144f020702210747t50d7d92ei1a2f5da8bf117d40@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep16-int.chello.nl ([62.179.120.11]:40558 "EHLO
	amsfep16-int.chello.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbXBVJdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 04:33:52 -0500
In-Reply-To: <84144f020702210747t50d7d92ei1a2f5da8bf117d40@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-02-21 at 17:47 +0200, Pekka Enberg wrote:
> Hi Peter,
> 
> On 2/21/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > Provide a method to calculate the number of pages needed to store a given
> > number of slab objects (upper bound when considering possible partial and
> > free slabs).
> 
> So how does this work? You ask the slab allocator how many pages you
> need for a given number of objects and then those pages are available
> to it via the page allocator? Can other users also dip into those
> reserves?

Everybody (ab)using PF_MEMALLOC or the new __GFP_EMERGENCY.

> I would prefer we simply have an API for telling the slab allocator to
> keep certain number of pages in a reserve for a cache rather than
> exposing internals such as object size to rest of the world.

Keeping the free pages in the page allocator is good for the buddy
system. Although you could probably implement a reserve interface
without actually claiming the pages.

However, doing it like so separates the making of the reserve from the
actual kmem_cache object, I can just carry a sum of pages around instead
of a list of kmem_cache pointers.

I calculate a potential reserve, I might never actually commit to making
(and using) the reserve.

Also, I don't see what internals are exposed, kmem_cache is still
private to slab.c.

