From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Tue, 10 May 2011 10:43:08 +0200
Message-ID: <1305016988.2614.6.camel@edumazet-laptop>
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
	 <1303309591.3186.84.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200942020.9266@router.home>
	 <1303311687.3186.100.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1105092241390.6784@tiger>
	 <alpine.DEB.2.00.1105091502260.26839@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Enberg <penberg@kernel.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39861 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094Ab1EJInP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 04:43:15 -0400
Received: by wya21 with SMTP id 21so4485315wya.19
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 01:43:13 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1105091502260.26839@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 09 mai 2011 =C3=A0 15:04 -0500, Christoph Lameter a =C3=A9crit=
 :
> On Mon, 9 May 2011, Pekka Enberg wrote:
>=20
> > On Wed, 20 Apr 2011, Eric Dumazet wrote:
> > > [PATCH v4] slub: dont use cmpxchg_double if KMEMCHECK or DEBUG_PA=
GEALLOC
> > >
> > > Christian Casteyde reported a KMEMCHECK splat in slub code.
> > >
> > > Problem is now we are lockless and allow IRQ in slab_alloc(), the=
 object
> > > we manipulate from freelist can be allocated and freed right befo=
re we
> > > try to read object->next.
> > >
> > > Same problem can happen with DEBUG_PAGEALLOC
> > >
> > > Just dont use cmpxchg_double() if either CONFIG_KMEMCHECK or
> > > CONFIG_DEBUG_PAGEALLOC is defined.
> >
> > Christoph, Eric, is this still relevant after commit 1759415 ("slub=
: Remove
> > CONFIG_CMPXCHG_LOCAL ifdeffery") in slab/next of slab.git?
>=20
> There is still an issue and now you can no longer fix the thing throu=
gh
> CONFIG_CMPXCHG_LOCAL.
>=20
> It needs to be legal for slub to deref the counter even if the object=
 has
> been freed.
>=20

I am trying to follow things but honestly I am lost.

Isnt commit 1759415e63 planned for 2.6.40 ?
( ref :
http://git.kernel.org/?p=3Dlinux/kernel/git/penberg/slab-2.6.git;a=3Dco=
mmitdiff;h=3D1759415e630e5db0dd2390df9f94892cbfb9a8a2 )

How shall we fix things for 2.6.39 ? I thought my patch was OK for that=
=2E


Its a bit hard to work with you on this stuff, for a report I made ages
ago, I find it incredible its not yet fixed in linux-2.6.

Christoph, is your plan to make SLUB not compatable with
CONFIG_DEBUG_PAGEALLOC ? Luckily we still have SLAB ;)

I am a bit surprised of 1759415e63 commit. Its obviously wrong for
DEBUG_PAGEALLOG. Sure KMEMCHECK could be handled differently (since we
are !SMP in this case)

???



