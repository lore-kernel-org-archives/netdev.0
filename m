From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Wed, 20 Apr 2011 08:04:30 +0200
Message-ID: <1303279470.2756.17.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
	 <1303181466.4152.39.camel@edumazet-laptop>
	 <1303182557.4152.48.camel@edumazet-laptop>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61741 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab1DTGEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 02:04:36 -0400
Received: by wwa36 with SMTP id 36so477971wwa.1
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 23:04:35 -0700 (PDT)
In-Reply-To: <4DAE7579.3020400@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 08:56 +0300, Pekka Enberg a =C3=A9crit=
 :
> On 4/19/11 11:17 PM, Eric Dumazet wrote:
> > Le mardi 19 avril 2011 =C3=A0 12:10 -0500, Christoph Lameter a =C3=A9=
crit :
> >> On Tue, 19 Apr 2011, Eric Dumazet wrote:
> >>
> >>>   	}
> >>>   }
> >>>
> >>> -#ifdef CONFIG_CMPXCHG_LOCAL
> >>> +#if defined(CONFIG_CMPXCHG_LOCAL)&&  \
> >>> +	!defined(CONFIG_KMEMCHECK)&&  !defined(DEBUG_PAGEALLOC)
> >>> +#define SLUB_USE_CMPXCHG_DOUBLE
> >>> +#endif
> >>> +
> >>> +#ifdef SLUB_USE_CMPXCHG_DOUBLE
> >>>   #ifdef CONFIG_PREEMPT
> >>>   /*
> >> Ugg.. Isnt there some way to indicate to kmemcheck that a speculat=
ive
> >> access is occurring?
> > Yes, here is a totally untested patch (only compiled here), to keep
> > kmemcheck&  cmpxchg_double together.
>=20
> Looks good to me! Can we get someone to test it as well?

I tested first patch, but was not able to trigger the fault anyway
without it. I'll try a bit more today if time permits...

It would be nice if Christian can reproduce the initial problem easily
and give us the steps...



