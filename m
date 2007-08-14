From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/24] make atomic_read() behave consistently on frv
Date: Wed, 15 Aug 2007 00:01:54 +0200
Message-ID: <200708150001.58217.arnd@arndb.de>
References: <20070811042943.GA13410@linux.vnet.ibm.com> <46C13EE1.1000707@yahoo.com.au> <20070814170128.GA8243@linux.vnet.ibm.com>
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
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:55247 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936464AbXHNWD4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 18:03:56 -0400
In-Reply-To: <20070814170128.GA8243@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 August 2007, Paul E. McKenney wrote:
> > #define order(x) asm volatile("" : "+m" (x))
>=20
> There was something very similar discussed earlier in this thread,
> with quite a bit of debate as to exactly what the "m" flag should
> look like. =A0I suggested something similar named ACCESS_ONCE in the
> context of RCU (http://lkml.org/lkml/2007/7/11/664):
>=20
> =A0=A0=A0=A0=A0=A0=A0=A0#define ACCESS_ONCE(x) (*(volatile typeof(x) =
*)&(x))
>=20
> The nice thing about this is that it works for both loads and stores.
> Not clear that order() above does this -- I get compiler errors when
> I try something like "b =3D order(a)" or "order(a) =3D 1" using gcc 4=
=2E1.2.

Well, it serves a different purpose: While your ACCESS_ONCE() macro is
an lvalue, the order() macro is a statement that can be used in place
of the barrier() macro. order() is the most lightweight barrier as it
only enforces ordering on a single variable in the compiler, but does
not have any side-effects visible to other threads, like the cache
line access in ACCESS_ONCE has.

	Arnd <><
