From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Tue, 14 Aug 2007 15:43:54 -0700
Message-ID: <20070814224354.GE8243@linux.vnet.ibm.com>
References: <20070811042943.GA13410@linux.vnet.ibm.com> <46C13EE1.1000707@yahoo.com.au> <20070814170128.GA8243@linux.vnet.ibm.com> <200708150001.58217.arnd@arndb.de>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>, csnook@redhat.com,
	dhowells@redhat.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:42844 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756029AbXHNWn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 18:43:59 -0400
Content-Disposition: inline
In-Reply-To: <200708150001.58217.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 12:01:54AM +0200, Arnd Bergmann wrote:
> On Tuesday 14 August 2007, Paul E. McKenney wrote:
> > > #define order(x) asm volatile("" : "+m" (x))
> >=20
> > There was something very similar discussed earlier in this thread,
> > with quite a bit of debate as to exactly what the "m" flag should
> > look like. =A0I suggested something similar named ACCESS_ONCE in th=
e
> > context of RCU (http://lkml.org/lkml/2007/7/11/664):
> >=20
> > =A0=A0=A0=A0=A0=A0=A0=A0#define ACCESS_ONCE(x) (*(volatile typeof(x=
) *)&(x))
> >=20
> > The nice thing about this is that it works for both loads and store=
s.
> > Not clear that order() above does this -- I get compiler errors whe=
n
> > I try something like "b =3D order(a)" or "order(a) =3D 1" using gcc=
 4.1.2.
>=20
> Well, it serves a different purpose: While your ACCESS_ONCE() macro i=
s
> an lvalue, the order() macro is a statement that can be used in place
> of the barrier() macro. order() is the most lightweight barrier as it
> only enforces ordering on a single variable in the compiler, but does
> not have any side-effects visible to other threads, like the cache
> line access in ACCESS_ONCE has.

ACCESS_ONCE() is indeed intended to be used when actually loading or
storing the variable.  That said, I must admit that it is not clear to =
me
why you would want to add an extra order() rather than ACCESS_ONCE()ing
one or both of the adjacent accesses to that same variable.

So, what am I missing?

						Thanx, Paul
