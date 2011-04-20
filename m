From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Wed, 20 Apr 2011 17:34:26 +0200
Message-ID: <1303313666.3186.114.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
	 <1303181466.4152.39.camel@edumazet-laptop>
	 <1303182557.4152.48.camel@edumazet-laptop>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>
	 <1303279470.2756.17.camel@edumazet-laptop>
	 <1303285519.4dae8f0fdf9b1@imp.free.fr> <4DAE901C.2090809@cs.helsinki.fi>
	 <1303286998.3186.18.camel@edumazet-laptop>
	 <1303290464.3186.32.camel@edumazet-laptop>
	 <1303293765.3186.74.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200904440.8634@router.home>
	 <1303309591.3186.84.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104200942020.9266@router.home>
	 <1303311687.3186.100.camel@edumazet-laptop>
	 <66e0b8f575075d009bdb3633837951a3@ulrik.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: vegardno@ifi.uio.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55162 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449Ab1DTPeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 11:34:31 -0400
Received: by wya21 with SMTP id 21so711523wya.19
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 08:34:30 -0700 (PDT)
In-Reply-To: <66e0b8f575075d009bdb3633837951a3@ulrik.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 17:15 +0200, Vegard Nossum a =C3=A9cri=
t :

>  Thanks, guys. I wonder: Is it possible to make a reproducible test-c=
ase=20
>  (e.g. loadable module) for this?
>=20

Not easy to code a specific test-case, but just use regular workload,
(and network trafic to get interrupts). Use CONFIG_PREEMPT to trigger
preemptions.

>  Also, pardon my ignorance, but can you explain why this is a bug wit=
h=20
>  kmemcheck/page-alloc debug and not without them?

Without them, we can read object->next without trigerring a fault.
We can read garbage data (if object is in use, it was overwritten with
user data), but this doesnt matter because cmpxchg_double() wont perfor=
m
its work (since tid will have change)



