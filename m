From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bug] __nf_ct_refresh_acct(): WARNING: at lib/list_debug.c:30
 __list_add+0x7d/0xad()
Date: Wed, 17 Jun 2009 15:27:28 +0200
Message-ID: <4A38EF40.7040106@gmail.com>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.034752.226811527.davem@davemloft.net> <20090616105304.GA3579@elte.hu> <20090616122415.GA16630@elte.hu> <20090617092152.GA17449@elte.hu> <4A38C2F3.3000009@gmail.com> <4A38D5BD.2040502@trash.net> <4A38D9BE.3020403@gmail.com> <4A38DAC4.2050902@trash.net> <4A38E2AE.3030106@gmail.com> <4A38E33E.1050006@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52016 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756679AbZFQN1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 09:27:52 -0400
In-Reply-To: <4A38E33E.1050006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> Patrick McHardy a =E9crit :
>>> Eric Dumazet wrote:
>>>> Patrick McHardy a =E9crit :
>>>>> Before the conntrack is confirmed, it is exclusively handled by a
>>>>> single CPU. I agree that we need to make sure the IPS_CONFIRMED_B=
IT
>>>>> is visible before we add the conntrack to the hash table since th=
e
>>>>> lookup is lockless, but simply moving the set_bit before the hash
>>>>> insertion should be fine I think.
>>>>>
>>>>
>>>> Problem is timeout.expires is either a relative or absolute timeou=
t,
>>>> and changes happen
>>>> in __nf_conntrack_confirm() or __nf_ct_refresh_acct().
>>>>
>>>> We must have a synchronization (an barriers), a single bit wont be
>>>> enough.
>>> Please have a look at the second patch I just sent. It relies
>>> on the RCU barriers to make sure all stores are visible before
>>> other CPUs can find the conntrack.
>>>
>>
>> Sorry, I dont understand how your second patch corrects the problem.
>>
>> This (unconfirmed) conntrack is visible by another cpu.
>=20
> No, before it is confirmed, its only visible to the CPU handling
> the initial packet of a connection. Confirmation is the step that
> makes it visible to other CPUs.

Thanks Patrick, I missed this, and your patch seems fine now :)

>=20
>> This other
>> cpu can call __nf_ct_refresh_acct() while this cpu runs
>> in __nf_conntrack_confirm()
>=20
> Not for the same conntrack, that would be a seperate bug.
>=20
> Does that explain what I'm trying to do? :)


Yes sure, thanks again.
