From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Wed, 20 Apr 2011 16:26:31 +0200
Message-ID: <1303309591.3186.84.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
	 <1303181466.4152.39.camel@edumazet-laptop>
	 <1303182557.4152.48.camel@edumazet-laptop>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>
	 <1303279470.2756.17.camel@edumazet-laptop>
	 <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>
	 <1303286998.3186.18.camel@edumazet-laptop>
	 <1303290464.3186.32.camel@edumazet-laptop>
	 <1303293765.3186.74.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200904440.8634@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:47792 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944Ab1DTO0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 10:26:36 -0400
Received: by wwk4 with SMTP id 4so4126556wwk.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 07:26:35 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1104200904440.8634@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 09:05 -0500, Christoph Lameter a =C3=A9=
crit :
> On Wed, 20 Apr 2011, Eric Dumazet wrote:
>=20
> > > Then, just disable SLUB_CMPXCHG_DOUBLE if KMEMCHECK is defined, a=
s I did in my first patch.
>=20
> Ok your first patch seems to be the sanest approach.
>=20
> >  {
> > @@ -1889,16 +1895,18 @@ static __always_inline void *slab_alloc(str=
uct kmem_cache *s,
> >  	struct kmem_cache_cpu *c;
> >  #ifdef CONFIG_CMPXCHG_LOCAL
> >  	unsigned long tid;
> > -#else
> > +#endif
> > +#ifdef MASK_IRQ_IN_SLAB_ALLOC
> >  	unsigned long flags;
> >  #endif
> >
>=20
> Yea well that does not bring us much.

Well, we keep the fast free path ?

only slab_alloc() would have to disable irqs for ~20 instructions.



