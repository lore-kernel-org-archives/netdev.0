From: Matt Mackall <mpm@selenic.com>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
	pointer dereference
Date: Thu, 24 Jul 2008 21:59:33 -0500
Message-ID: <1216954773.15519.261.camel@calx>
References: <20080724093411.GA12001@elte.hu>
	 <20080724115625.GA23994@elte.hu> <20080724115957.GA25701@elte.hu>
	 <48886FA6.6050908@trash.net> <20080724122203.GA7187@gondor.apana.org.au>
	 <84144f020807240540vbe7ef50uee2cacabe8016546@mail.gmail.com>
	 <20080724125004.GA7426@gondor.apana.org.au>
	 <1216905109.15519.200.camel@calx>
	 <20080724143706.GA8461@gondor.apana.org.au>
	 <1216921639.15519.239.camel@calx>
	 <20080725013958.GA14200@gondor.apana.org.au>
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
Received: from waste.org ([66.93.16.53]:52965 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbYGYDD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 23:03:29 -0400
In-Reply-To: <20080725013958.GA14200@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-07-25 at 09:39 +0800, Herbert Xu wrote:
> On Thu, Jul 24, 2008 at 12:47:19PM -0500, Matt Mackall wrote:
> >
> > Let's try this again: did you know that ksize could fail depending on
> > kernel configuration? Most of us would answer no. That suggests the API
> > is bad. This ranks 12 on Rusty's spectrum of user-friendly APIs:
> 
> I think you misunderstood my argument.  I never suggested changing
> the existing ksize interface to return an error onto unsuspecting
> users.  I suggested creating a new interface that is explicitly
> designed to return an error if the underlying implementation
> is unable to support this.

I think that could probably be made to work. Perhaps something like:

size_t kmalloc_extra(void *); /* how many extra bytes in this kmalloc?
*/

Which, if it didn't work, could return a nice safe 0. We could argue
about signedness a bit, but I think this would always be safe.

This will also work with all our current kmalloc implementations. The
trouble was calling ksize() on kmem_cache_alloc objects, which happens
to work with SLAB and SLOB.

-- 
Mathematics is the supreme nostalgia of our time.

