From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Wed, 20 Apr 2011 17:30:33 +0200
Message-ID: <1303313433.3186.110.camel@edumazet-laptop>
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
	 <alpine.DEB.2.00.1104201015520.9266@router.home>
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
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64262 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449Ab1DTPaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 11:30:39 -0400
Received: by wwa36 with SMTP id 36so1019148wwa.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 08:30:38 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1104201015520.9266@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 10:17 -0500, Christoph Lameter a =C3=A9=
crit :
> On Wed, 20 Apr 2011, Eric Dumazet wrote:
>=20
> > [PATCH v4] slub: dont use cmpxchg_double if KMEMCHECK or DEBUG_PAGE=
ALLOC
>=20
> Acked-by: Christoph Lameter <cl@linux.com>
>=20
> >
> > -#ifdef CONFIG_CMPXCHG_LOCAL
> > +#if defined(CONFIG_CMPXCHG_LOCAL) && !defined(CONFIG_KMEMCHECK) &&=
 \
> > +				     !defined(CONFIG_DEBUG_PAGEALLOC)
> > +#define SLUB_USE_CMPXCHG_DOUBLE
>=20
> #undef CONFIG_CMPXCHG_LOCAL instead? Would reduce patch size but its =
kind
> of hacky.
>=20

Well, its definitely hacky :)

I chose a local definition (instead of Kconfig game), referring to
cmpxchg_double()



