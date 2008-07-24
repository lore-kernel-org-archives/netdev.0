From: Matt Mackall <mpm@selenic.com>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
	pointer dereference
Date: Thu, 24 Jul 2008 14:21:49 -0500
Message-ID: <1216927309.15519.253.camel@calx>
References: <20080724060448.GA10203@elte.hu>
	 <200807242256.09107.nickpiggin@yahoo.com.au>
	 <20080724130422.GB7426@gondor.apana.org.au>
	 <200807242313.47041.nickpiggin@yahoo.com.au>
	 <1216906342.12021.0.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	davidn@davidnewall.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>,
	Christoph Lameter <cl@linux-foundation.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:49674 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754830AbYGXT0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 15:26:07 -0400
In-Reply-To: <1216906342.12021.0.camel@penberg-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-07-24 at 16:32 +0300, Pekka Enberg wrote:
> On Thu, Jul 24, 2008 at 10:56:08PM +1000, Nick Piggin wrote:
> > > > OTOH, skb allocation uses kmalloc don't they? So you could stil=
l use
> > > > SLOB ksize for that I guess.
>=20
> On Thursday 24 July 2008 23:04, Herbert Xu wrote:
> > > Yes I was referring to the data portion which is kmalloc'ed.
> > > That is also why I'm interested in ksize because a priori we
> > > don't know exactly how big it's going to be.  However, we do
> > > know that statistically 1500 will dominate.
> > >
> > > I'm not interested in ksize for kmem_cache at all.  So in fact
> > > we could have something simpler that's based on kmalloc's roundin=
g
> > > algorithm instead.
>=20
> =EF=BB=BFOn Thu, 2008-07-24 at 23:13 +1000, Nick Piggin wrote:
> > Yes you could definitely have a function that returns allocated
> > bytes for a given kmalloc size. Should be about as fast or faster
> > than extracting the size from the kaddr...
>=20
> Yup, makes sense.

On the other hand, I can imagine useful allocator changes where this
would not be a constant of requested size. For instance, imagine we had
a classless bucket allocator, but with a heuristic to try a larger
bucket when it wasn't cheap/possible to allocate a right-sized object
(because of memory pressure, etc.) and larger ones were available.
This sort of thing is a pretty small change for SLAB/SLUB.

--=20
Mathematics is the supreme nostalgia of our time.

