From: Matt Mackall <mpm@selenic.com>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
	pointer dereference
Date: Thu, 24 Jul 2008 12:47:19 -0500
Message-ID: <1216921639.15519.239.camel@calx>
References: <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>
	 <20080724.022259.113079007.davem@davemloft.net>
	 <20080724093411.GA12001@elte.hu> <20080724115625.GA23994@elte.hu>
	 <20080724115957.GA25701@elte.hu> <48886FA6.6050908@trash.net>
	 <20080724122203.GA7187@gondor.apana.org.au>
	 <84144f020807240540vbe7ef50uee2cacabe8016546@mail.gmail.com>
	 <20080724125004.GA7426@gondor.apana.org.au>
	 <1216905109.15519.200.camel@calx>
	 <20080724143706.GA8461@gondor.apana.org.au>
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
Received: from waste.org ([66.93.16.53]:55070 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751414AbYGXRvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 13:51:45 -0400
In-Reply-To: <20080724143706.GA8461@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-07-24 at 22:37 +0800, Herbert Xu wrote:
> On Thu, Jul 24, 2008 at 08:11:49AM -0500, Matt Mackall wrote:
> >
> > You don't honestly expect people to correctly code to such a standard,
> > do you? People will assume that ksize never fails, they will be wrong,
> > and computers will die.
> 
> If we follow this argument then most of our interfaces would be
> broken.

Let's try this again: did you know that ksize could fail depending on
kernel configuration? Most of us would answer no. That suggests the API
is bad. This ranks 12 on Rusty's spectrum of user-friendly APIs:

http://ozlabs.org/~rusty/ols-2003-keynote/img51.html

> > >  You're taking
> > > away an entire interface just because an underlying implementation
> > > that's used by a very small proportion of users doesn't do the
> > > right thing.
> > 
> > Umm, no. There were very few users to being with, so it was actually a
> > fairly large proportion. And that suggested the interface was a bad
> > idea.
> 
> Huh? I'm talking about users of the kernel.  A very small proportion
> of those use SLOB.

Ahh. I see what you're saying. You may be right about that, or you may
be wrong: I don't know which of the millions of mass market embedded
Linux devices out there are using it.

And of course I argue that SLOB did do the right thing, which was only
allowing ksize on kmalloced objects. It's an accident of implementation
that kmalloc and kmem_cache_alloc use the same underlying allocator. It
has not been true at all points in the past, it's not true for some
users in the present, and it may not be true for most users in the
future. Thus, it's a bad idea to try to use ksize on something that
wasn't kmalloced.

If you have an argument for reintroducing ksize based on an actual use
case, let's please move on to (or back to) it so that we can have some
substance to this discussion.

-- 
Mathematics is the supreme nostalgia of our time.

