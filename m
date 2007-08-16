From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Wed, 15 Aug 2007 19:27:37 -0700
Message-ID: <20070816022737.GB14613@linux.vnet.ibm.com>
References: <20070811042943.GA13410@linux.vnet.ibm.com> <E1IKSHQ-0007hg-00@gondolin.me.apana.org.au> <20070813060302.GF13410@linux.vnet.ibm.com> <46C13EE1.1000707@yahoo.com.au> <20070814170128.GA8243@linux.vnet.ibm.com> <46C2FFDD.5000600@yahoo.com.au> <20070815201501.GM9645@linux.vnet.ibm.com> <46C3A3C5.5020103@yahoo.com.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, csnook@redhat.com,
	dhowells@redhat.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	Arnd Bergmann <arnd@arndb.de>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:39077 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758379AbXHPC1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 22:27:41 -0400
Content-Disposition: inline
In-Reply-To: <46C3A3C5.5020103@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 11:09:25AM +1000, Nick Piggin wrote:
> Paul E. McKenney wrote:
> >On Wed, Aug 15, 2007 at 11:30:05PM +1000, Nick Piggin wrote:
> 
> >>Especially since several big architectures don't have volatile in their
> >>atomic_get and _set, I think it would be a step backwards to add them in
> >>as a "just in case" thin now (unless there is a better reason).
> >
> >Good point, except that I would expect gcc's optimization to continue
> >to improve.  I would like the kernel to be able to take advantage of
> >improved optimization, which means that we are going to have to make
> >a few changes.  Adding volatile to atomic_get() and atomic_set() is
> >IMHO one of those changes.
> 
> What optimisations? gcc already does most of the things you need a
> barrier/volatile for, like reordering non-dependant loads and stores,
> and eliminating mem ops completely by caching in registers.

Yep, most of the currently practiced optimizations.  Given that CPU clock
frequencies are not rising as quickly as they once did, I would expect
that there will be added effort on implementing the known more-aggressive
optimization techniques, and on coming up with new ones as well.

Some of these new optimizations will likely be inappropriate for kernel
code, but I expect that some will be things that we want.

> >>As to your followup question of why to use it over ACCESS_ONCE. I
> >>guess, aside from consistency with the rest of the barrier APIs, you
> >>can use it in other primitives when you don't actually know what the
> >>caller is going to do or if it even will make an access. You could
> >>also use it between calls to _other_ primitives, etc... it just
> >>seems more flexible to me, but I haven't actually used such a thing
> >>in real code...
> >>
> >>ACCESS_ONCE doesn't seem as descriptive. What it results in is the
> >>memory location being loaded or stored (presumably once exactly),
> >>but I think the more general underlying idea is a barrier point.
> >
> >OK, first, I am not arguing that ACCESS_ONCE() can replace all current
> >uses of barrier().
> 
> OK. Well I also wasn't saying that ACCESS_ONCE should not be
> implemented. But if we want something like it, then it would make
> sense to have an equivalent barrier statement as well (ie. order()).

And I am not arguing against use of asms to implement the volatility
in atomic_read() and atomic_set(), and in fact it appears that one
of the architectures will be taking this approach.

Sounds like we might be in violent agreement.  ;-)

						Thanx, Paul
