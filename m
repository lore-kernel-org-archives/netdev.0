From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL pointer dereference
Date: Fri, 25 Jul 2008 19:09:07 +1000
Message-ID: <200807251909.08661.nickpiggin@yahoo.com.au>
References: <20080724060448.GA10203@elte.hu> <1216906342.12021.0.camel@penberg-laptop> <1216927309.15519.253.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	davidn@davidnewall.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>,
	Christoph Lameter <cl@linux-foundation.org>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.mail.mud.yahoo.com ([209.191.85.217]:29388 "HELO
	smtp107.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751819AbYGYJJe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 05:09:34 -0400
In-Reply-To: <1216927309.15519.253.camel@calx>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 July 2008 05:21, Matt Mackall wrote:
> On Thu, 2008-07-24 at 16:32 +0300, Pekka Enberg wrote:
> > On Thu, Jul 24, 2008 at 10:56:08PM +1000, Nick Piggin wrote:
> > > > > OTOH, skb allocation uses kmalloc don't they? So you could st=
ill
> > > > > use SLOB ksize for that I guess.
> >
> > On Thursday 24 July 2008 23:04, Herbert Xu wrote:
> > > > Yes I was referring to the data portion which is kmalloc'ed.
> > > > That is also why I'm interested in ksize because a priori we
> > > > don't know exactly how big it's going to be.  However, we do
> > > > know that statistically 1500 will dominate.
> > > >
> > > > I'm not interested in ksize for kmem_cache at all.  So in fact
> > > > we could have something simpler that's based on kmalloc's round=
ing
> > > > algorithm instead.
> >
> > =EF=BB=BFOn Thu, 2008-07-24 at 23:13 +1000, Nick Piggin wrote:
> > > Yes you could definitely have a function that returns allocated
> > > bytes for a given kmalloc size. Should be about as fast or faster
> > > than extracting the size from the kaddr...
> >
> > Yup, makes sense.
>
> On the other hand, I can imagine useful allocator changes where this
> would not be a constant of requested size. For instance, imagine we h=
ad
> a classless bucket allocator, but with a heuristic to try a larger
> bucket when it wasn't cheap/possible to allocate a right-sized object
> (because of memory pressure, etc.) and larger ones were available.
> This sort of thing is a pretty small change for SLAB/SLUB.

If that comes up, you could make the API take the pointer as well,
then just filter out the new argument in allocators that don't use
it.
