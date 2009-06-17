From: Patrick McHardy <kaber@trash.net>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Wed, 17 Jun 2009 15:29:40 +0200
Message-ID: <4A38EFC4.8000907@trash.net>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <4A38D5BD.2040502@trash.net> <4A38D9BE.3020403@gmail.com> <4A38DAC4.2050902@trash.net> <4A38E2AE.3030106@gmail.com> <4A38E33E.1050006@trash.net> <4A38EF40.7040106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34236 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231AbZFQN3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 09:29:41 -0400
In-Reply-To: <4A38EF40.7040106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> Eric Dumazet wrote:
>>> Patrick McHardy a =E9crit :
>>>> Eric Dumazet wrote:
>>>>> Patrick McHardy a =E9crit :
>>>>>> Before the conntrack is confirmed, it is exclusively handled by =
a
>>>>>> single CPU. I agree that we need to make sure the IPS_CONFIRMED_=
BIT
>>>>>> is visible before we add the conntrack to the hash table since t=
he
>>>>>> lookup is lockless, but simply moving the set_bit before the has=
h
>>>>>> insertion should be fine I think.
>>>>>>
>>>>> Problem is timeout.expires is either a relative or absolute timeo=
ut,
>>>>> and changes happen
>>>>> in __nf_conntrack_confirm() or __nf_ct_refresh_acct().
>>>>>
>>>>> We must have a synchronization (an barriers), a single bit wont b=
e
>>>>> enough.
>>>> Please have a look at the second patch I just sent. It relies
>>>> on the RCU barriers to make sure all stores are visible before
>>>> other CPUs can find the conntrack.
>>>>
>>> Sorry, I dont understand how your second patch corrects the problem=
=2E
>>>
>>> This (unconfirmed) conntrack is visible by another cpu.
>> No, before it is confirmed, its only visible to the CPU handling
>> the initial packet of a connection. Confirmation is the step that
>> makes it visible to other CPUs.
>=20
> Thanks Patrick, I missed this, and your patch seems fine now :)

Thanks for your help, I'll send it to Dave later today.
