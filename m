From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Wed, 27 Feb 2008 11:44:42 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0802271140470.1790@schroedinger.engr.sgi.com>
References: <47BDBC23.10605@cosmosbay.com> <1203632765.6112.20.camel@lappy>
 <200802232023.52352.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Eric Dumazet <dada1@cosmosbay.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:44233 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756746AbYB0Ton (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 14:44:43 -0500
In-Reply-To: <200802232023.52352.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Feb 2008, Nick Piggin wrote:

> What I don't understand is why the slab allocators have something like
> this in it:
> 
>         if ((flags & SLAB_HWCACHE_ALIGN) &&
>                         size > cache_line_size() / 2)
>                 return max_t(unsigned long, align, cache_line_size());
> 
> If you ask for HWCACHE_ALIGN, then you should get it. I don't
> understand, why do they think they knows better than the caller?

Tradition.... Its irks me as well.

> Things like this are just going to lead to very difficult to track
> performance problems. Possibly correctness problems in rare cases.
> 
> There could be another flag for "maybe align".

SLAB_HWCACHE_ALIGN *is* effectively a maybe align flag given the above 
code. 

If we all agree then we could change this to have must have semantics? It 
has the potential of enlarging objects for small caches. 

SLAB_HWCACHE_ALIGN has an effect that varies according to the alignment 
requirements of the architecture that the kernel is build on. We may be in 
for some surprises if we change this.

