From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Fri, 3 Jul 2009 11:47:00 -0400
Message-ID: <20090703154700.GD10256@Krystal>
References: <20090703152951.GA28837@gondor.apana.org.au> <4A4E25BB.8060408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, mingo@elte.hu,
	jolsa@redhat.com, a.p.zijlstra@chello.nl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, htejun@gmail.com, jarkao2@gmail.com,
	oleg@redhat.com, davidel@xmailserver.org, Paul.McKenney@us.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts16-srv.bellnexxia.net ([209.226.175.4]:41475 "EHLO
	tomts16-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757031AbZGCPv7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jul 2009 11:51:59 -0400
Content-Disposition: inline
In-Reply-To: <4A4E25BB.8060408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet (eric.dumazet@gmail.com) wrote:
> Herbert Xu a =E9crit :
> > Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:
> >> Why don't we create a read_lock without acquire semantic instead (=
e.g.
> >> read_lock_nomb(), or something with a better name like __read_lock=
()) ?
> >> On architectures where memory barriers are needed to provide the a=
cquire
> >> semantic, it would be faster to do :
> >>
> >> __read_lock();
> >> smp_mb();
> >>
> >> than :
> >>
> >> read_lock(); <- e.g. lwsync + isync or something like that
> >> smp_mb(); <- full sync.
> >=20
> > Hmm, why do we even care when read_lock should just die?
> >=20
> > Cheers,
>=20
> +1 :)
>=20
> Do you mean using a spinlock instead or what ?
>=20

I think he meant RCU.

> Also, how many arches are able to have a true __read_lock()
> (or __spin_lock() if that matters), without acquire semantic ?

At least PowerPC, MIPS, recent ARM, alpha.

Mathieu


--=20
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE =
9A68
