From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: 14 Aug 2006 13:40:21 +0200
Message-ID: <p73k65ba6l6.fsf@verdi.suse.de>
References: <20060814110359.GA27704@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:35250 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1752007AbWHNLkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 07:40:23 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060814110359.GA27704@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:

> Design notes.
> Original idea was to store meta information used for allocation in an
> AVL tree [1], but since I found a way to use some "unused" fields in struct page,
> tree is unused in the allocator.

But there seems to be still an AVL tree in there?


> Benchmarks with trivial epoll based web server showed noticeble (more
> than 40%) imrovements of the request rates (1600-1800 requests per
> second vs. more than 2300 ones). It can be described by more
> cache-friendly freeing algorithm, by tighter objects packing and thus
> reduced cache line ping-pongs, reduced lookups into higher-layer caches
> and so on.

So what are its drawbacks compared to slab/kmalloc? 

Also if it really performs that much better it might be a good
idea to replace all of kmalloc() with it, but doing that
would require a lot more benchmarks with various workloads
and small and big machines first.

-Andi

