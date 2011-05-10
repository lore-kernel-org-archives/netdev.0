From: Vegard Nossum <vegardno@ifi.uio.no>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in =?UTF-8?Q?=5F=5Falloc=5Fskb?=
Date: Tue, 10 May 2011 14:24:40 +0200
Message-ID: <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
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
 <alpine.DEB.2.00.1105092241390.6784@tiger>
 <alpine.DEB.2.00.1105091502260.26839@router.home>
 <1305016988.2614.6.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>
 <1305022632.2614.18.camel@edumazet-laptop> <4DC91137.4030109@cs.helsinki.fi>
Reply-To: vegardno@ifi.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Lameter <cl@linux.com>, <casteyde.christian@free.fr>,
	Andrew Morton <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, <bugzilla-daemon@bugzilla.kernel.org>,
	<bugme-daemon@bugzilla.kernel.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:37336 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755980Ab1EJMYw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 08:24:52 -0400
In-Reply-To: <4DC91137.4030109@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Tue, 10 May 2011 13:19:35 +0300, Pekka Enberg=20
 <penberg@cs.helsinki.fi> wrote:
> On 5/10/11 1:17 PM, Eric Dumazet wrote:
>> Le mardi 10 mai 2011 =C3=A0 13:03 +0300, Pekka Enberg a =C3=A9crit :
>>
>>> Can't we fix the issue by putting kmemcheck_mark_initialized() to
>>> set_freepointer()?
>>
>> This would solve kmemcheck problem, not DEBUG_PAGEALLOC
>
> Oh, right. Christoph? We need to support DEBUG_PAGEALLOC with SLUB.

 Hi,

 Disclaimer: I don't know how the algorithm is supposed to work, so=20
 please excuse me if this makes no sense at all. But here goes:

 Presumably the problem is that the page can get freed, and that with=20
 DEBUG_PAGEALLOC, the page will therefore not be present and subsequent=
ly=20
 trigger a page fault when doing this cmpxchg() on the possibly freed=20
 object.

 Regardless of DEBUG_PAGEALLOC or kmemcheck, what happens if the page=20
 gets freed, then allocated again for a completely different purpose in=
=20
 another part of the kernel, and new user of the page by chance writes=20
 the same "tid" number that the cmpxchg() is expecting?

 I guess I'm asking: Are we relying on the fact that this has a=20
 negligible probability of happening? Or did I just misunderstand what=20
 the algorithm does, and it is in fact provable (in theory) that nothin=
g=20
 wrong can happen?

 Thanks,


 Vegard
