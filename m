From: Vegard Nossum <vegardno@ifi.uio.no>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in =?UTF-8?Q?=5F=5Falloc=5Fskb?=
Date: Wed, 20 Apr 2011 17:15:02 +0200
Message-ID: <66e0b8f575075d009bdb3633837951a3@ulrik.uio.no>
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
Reply-To: vegardno@ifi.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	<casteyde.christian@free.fr>,
	Andrew Morton <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, <bugzilla-daemon@bugzilla.kernel.org>,
	<bugme-daemon@bugzilla.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:53060 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754174Ab1DTPqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 11:46:55 -0400
In-Reply-To: <1303311687.3186.100.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Wed, 20 Apr 2011 17:01:27 +0200, Eric Dumazet=20
 <eric.dumazet@gmail.com> wrote:
> Le mercredi 20 avril 2011 =C3=A0 09:42 -0500, Christoph Lameter a =C3=
=A9crit :
>
>> Avoiding the irq handling yields the savings that improve the=20
>> fastpath. if
>> you do both then there is only a regression left. So lets go with
>> disabling the CMPXCHG_LOCAL.
>
> OK, let's do that then.
>
> Thanks
>
> [PATCH v4] slub: dont use cmpxchg_double if KMEMCHECK or=20
> DEBUG_PAGEALLOC
>
> Christian Casteyde reported a KMEMCHECK splat in slub code.
>
> Problem is now we are lockless and allow IRQ in slab_alloc(), the=20
> object
> we manipulate from freelist can be allocated and freed right before=20
> we
> try to read object->next.
>
> Same problem can happen with DEBUG_PAGEALLOC
>
> Just dont use cmpxchg_double() if either CONFIG_KMEMCHECK or
> CONFIG_DEBUG_PAGEALLOC is defined.
>
> Reported-by: Christian Casteyde <casteyde.christian@free.fr>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Vegard Nossum <vegardno@ifi.uio.no>
> Cc: Christoph Lameter <cl@linux.com>

 Thanks, guys. I wonder: Is it possible to make a reproducible test-cas=
e=20
 (e.g. loadable module) for this?

 Also, pardon my ignorance, but can you explain why this is a bug with=20
 kmemcheck/page-alloc debug and not without them?

 Thanks,


 Vegard
