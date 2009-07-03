From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Fri, 3 Jul 2009 10:06:22 -0700
Message-ID: <20090703170621.GS8943@linux.vnet.ibm.com>
References: <20090703152951.GA28837@gondor.apana.org.au> <4A4E25BB.8060408@gmail.com> <20090703154700.GD10256@Krystal>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, mingo@elte.hu,
	jolsa@redhat.com, a.p.zijlstra@chello.nl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, htejun@gmail.com, jarkao2@gmail.com,
	oleg@redhat.com, davidel@xmailserver.org, Paul.McKenney@us.ibm.com
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:54075 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754953AbZGCRGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jul 2009 13:06:12 -0400
Content-Disposition: inline
In-Reply-To: <20090703154700.GD10256@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 03, 2009 at 11:47:00AM -0400, Mathieu Desnoyers wrote:
> * Eric Dumazet (eric.dumazet@gmail.com) wrote:
> > Herbert Xu a =E9crit :
> > > Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:
> > >> Why don't we create a read_lock without acquire semantic instead=
 (e.g.
> > >> read_lock_nomb(), or something with a better name like __read_lo=
ck()) ?
> > >> On architectures where memory barriers are needed to provide the=
 acquire
> > >> semantic, it would be faster to do :
> > >>
> > >> __read_lock();
> > >> smp_mb();
> > >>
> > >> than :
> > >>
> > >> read_lock(); <- e.g. lwsync + isync or something like that
> > >> smp_mb(); <- full sync.
> > >=20
> > > Hmm, why do we even care when read_lock should just die?
> > >=20
> > > Cheers,
> >=20
> > +1 :)
> >=20
> > Do you mean using a spinlock instead or what ?
> >=20
>=20
> I think he meant RCU.
>=20
> > Also, how many arches are able to have a true __read_lock()
> > (or __spin_lock() if that matters), without acquire semantic ?
>=20
> At least PowerPC, MIPS, recent ARM, alpha.

Are you guys sure you are in agreement about what you all mean by
"acquire semantics"?

Clearly, any correct __read_lock() implementation must enforce ordering
with respect to the most recent __write_unlock(), but this does not
necesarily imply all possible definitions of "acquire semantics".

							Thanx, Paul
