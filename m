From: Matt Mackall <mpm@selenic.com>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
	pointer dereference
Date: Thu, 24 Jul 2008 08:11:49 -0500
Message-ID: <1216905109.15519.200.camel@calx>
References: <20080724060448.GA10203@elte.hu>
	 <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>
	 <20080724.022259.113079007.davem@davemloft.net>
	 <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu>
	 <20080724115957.GA25701@elte.hu> <48886FA6.6050908@trash.net>
	 <20080724122203.GA7187@gondor.apana.org.au>
	 <84144f020807240540vbe7ef50uee2cacabe8016546@mail.gmail.com>
	 <20080724125004.GA7426@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	davidn@davidnewall.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>,
	Christoph Lameter <cl@linux-foundation.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:41725 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379AbYGXNPy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 09:15:54 -0400
In-Reply-To: <20080724125004.GA7426@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-07-24 at 20:50 +0800, Herbert Xu wrote:
> On Thu, Jul 24, 2008 at 03:40:40PM +0300, Pekka Enberg wrote:
> >
> > Using ksize() for skbs will crash your kernel for some configurations
> > because calling that function for memory allocated with
> > kmem_cache_alloc() is not supported by all the allocators (well,
> > SLOB).
> 
> So how about fixing the interface so that it can return an error
> to indicate that the allocator doesn't support it?

You don't honestly expect people to correctly code to such a standard,
do you? People will assume that ksize never fails, they will be wrong,
and computers will die.

>  You're taking
> away an entire interface just because an underlying implementation
> that's used by a very small proportion of users doesn't do the
> right thing.

Umm, no. There were very few users to being with, so it was actually a
fairly large proportion. And that suggested the interface was a bad
idea.

-- 
Mathematics is the supreme nostalgia of our time.

