From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Sat, 18 Aug 2007 09:03:13 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708180833520.3666@enigma.security.iitk.ac.in>
References: <20070816003948.GY9645@linux.vnet.ibm.com>
 <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
 <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au>
 <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au>
 <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
 <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
 <c298f0e3f9e49c9dd2d326115d156084@kernel.crashing.org>
 <alpine.LFD.0.999.0708180002290.3666@enigma.security.iitk.ac.in>
 <a51ab88dc00f8d7fd44f79400671d259@kernel.crashing.org>
 <alpine.LFD.0.999.0708180522120.3666@enigma.security.iitk.ac.in>
 <c0115c88da5d6756502e0c0499faa71f@kernel.crashing.org> <alpine.LFD.0.999.0708!
 180556330.3666@enigma.security.iitk.ac.in>
 <67eca5ac43d3b1dbd1a04c7c36aebd5a@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	=?iso-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	ak@suse.de, cfriesen@nortel.com, rpjday@mindspring.com,
	Netdev <netdev@vger.kernel.org>, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org, zlynx@acm.org,
	Andrew Morton <akpm@linux-foundation.org>,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44891 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbXHRDUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 23:20:45 -0400
In-Reply-To: <67eca5ac43d3b1dbd1a04c7c36aebd5a@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 18 Aug 2007, Segher Boessenkool wrote:

> > > > > The "asm volatile" implementation does have exactly the same
> > > > > reordering guarantees as the "volatile cast" thing,
> > > > 
> > > > I don't think so.
> > > 
> > > "asm volatile" creates a side effect.
> > 
> > Yeah.
> > 
> > > Side effects aren't
> > > allowed to be reordered wrt sequence points.
> > 
> > Yeah.
> > 
> > > This is exactly
> > > the same reason as why "volatile accesses" cannot be reordered.
> > 
> > No, the code in that sub-thread I earlier pointed you at *WAS* written
> > such that there was a sequence point after all the uses of that volatile
> > access cast macro, and _therefore_ we were safe from re-ordering
> > (behaviour guaranteed by the C standard).
> 
> And exactly the same is true for the "asm" version.
> 
> > Now, one cannot fantasize that "volatile asms" are also sequence points.
> 
> Sure you can do that.  I don't though.
> 
> > In fact such an argument would be sadly mistaken, because "sequence
> > points" are defined by the C standard and it'd be horribly wrong to
> > even _try_ claiming that the C standard knows about "volatile asms".
> 
> That's nonsense.  GCC can extend the C standard any way they
> bloody well please -- witness the fact that they added an
> extra class of side effects...
> 
> > > > Read the relevant GCC documentation.
> > > 
> > > I did, yes.
> > 
> > No, you didn't read:
> > 
> > http://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html
> > 
> > Read the bit about the need for artificial dependencies, and the example
> > given there:
> > 
> > 	asm volatile("mtfsf 255,%0" : : "f" (fpenv));
> > 	sum = x + y;
> > 
> > The docs explicitly say the addition can be moved before the "volatile
> > asm". Hopefully, as you know, (x + y) is an C "expression" and hence
> > a "sequence point" as defined by the standard.
> 
> The _end of a full expression_ is a sequence point, not every
> expression.  And that is irrelevant here anyway.
> 
> It is perfectly fine to compute x+y any time before the
> assignment; the C compiler is allowed to compute it _after_
> the assignment even, if it could figure out how ;-)
> 
> x+y does not contain a side effect, you know.
> 
> > I know there is also stuff written about "side-effects" there which
> > _could_ give the same semantic w.r.t. sequence points as the volatile
> > access casts,
> 
> s/could/does/
> 
> > but hey, it's GCC's own documentation, you obviously can't
> > find fault with _me_ if there's wrong stuff written in there. Say that
> > to GCC ...
> 
> There's nothing wrong there.
> 
> > See, "volatile" C keyword, for all it's ill-definition and dodgy
> > semantics, is still at least given somewhat of a treatment in the C
> > standard (whose quality is ... ummm, sadly not always good and clear,
> > but unsurprisingly, still about 5,482 orders-of-magnitude times
> > better than GCC docs).
> 
> If you find any problems/shortcomings in the GCC documentation,
> please file a PR, don't go whine on some unrelated mailing lists.
> Thank you.
> 
> > Semantics of "volatile" as applies to inline
> > asm, OTOH? You're completely relying on the compiler for that ...
> 
> Yes, and?  GCC promises the behaviour it has documented.

LOTS there, which obviously isn't correct, but which I'll reply to later,
easier stuff first. (call this "handwaving" if you want, but don't worry,
I /will/ bother myself to reply)


> > > > [ of course, if the (latest) GCC documentation is *yet again*
> > > >   wrong, then alright, not much I can do about it, is there. ]
> > > 
> > > There was (and is) nothing wrong about the "+m" documentation, if
> > > that is what you are talking about.  It could be extended now, to
> > > allow "+m" -- but that takes more than just "fixing" the documentation.
> > 
> > No, there was (and is) _everything_ wrong about the "+" documentation as
> > applies to memory-constrained operands. I don't give a whit if it's
> > some workaround in their gimplifier, or the other, that makes it possible
> > to use "+m" (like the current kernel code does). The docs suggest
> > otherwise, so there's obviously a clear disconnect between the docs and
> > actual GCC behaviour.
> 
> The documentation simply doesn't say "+m" is allowed.  The code to
> allow it was added for the benefit of people who do not read the
> documentation.  Documentation for "+m" might get added later if it
> is decided this [the code, not the documentation] is a sane thing
> to have (which isn't directly obvious).

Huh?

"If the (current) documentation doesn't match up with the (current)
code, then _at least one_ of them has to be (as of current) wrong."

I wonder how could you even try to disagree with that.

And I didn't go whining about this ... you asked me. (I think I'd said
something to the effect of GCC docs are often wrong, which is true,
but probably you feel saying that is "not allowed" on non-gcc lists?)

As for the "PR" you're requesting me to file with GCC for this, that
gcc-patches@ thread did precisely that and more (submitted a patch to
said documentation -- and no, saying "documentation might get added
later" is totally bogus and nonsensical -- documentation exists to
document current behaviour, not past). But come on, this is wholly
petty. I wouldn't have replied, really, if you weren't so provoking.
