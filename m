From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 14:26:50 -0500 (EST)
Message-ID: <20151111.142650.1297832998846138251.davem@davemloft.net>
References: <yw1xbnb0ny6k.fsf@unicorn.mansr.com>
	<20151111.141956.1056130800039910138.davem@davemloft.net>
	<yw1x7flonxs5.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: mans@mansr.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1x7flonxs5.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: M=E5ns Rullg=E5rd <mans@mansr.com>
Date: Wed, 11 Nov 2015 19:25:46 +0000

> David Miller <davem@davemloft.net> writes:
>=20
>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>> Date: Wed, 11 Nov 2015 19:17:07 +0000
>>
>>> David Miller <davem@davemloft.net> writes:
>>>=20
>>>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>>>> Date: Wed, 11 Nov 2015 19:09:19 +0000
>>>>
>>>>> David Miller <davem@davemloft.net> writes:
>>>>>=20
>>>>>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>>>>>> Date: Wed, 11 Nov 2015 18:25:05 +0000
>>>>>>
>>>>>>> If the TX DMA channel is idle when start_xmit is called, it can=
 be
>>>>>>> started immediately.  Checking the DMA status and starting it i=
f
>>>>>>> idle has to be done atomically somehow.
>>>>>>
>>>>>> ->ndo_start_xmit() is guaranteed to be invoked atomically, prote=
cted
>>>>>> by the TX queue spinlock.
>>>>>=20
>>>>> Yes, but the DMA needs to be restarted from some other context if=
 it was
>>>>> busy when start_xmit checked.
>>>>
>>>> Then you can probably use the TXQ lock in the interrupt handler ju=
st for
>>>> that.
>>>=20
>>> That seems a bit heavy-handed when the critical section for this is=
 only
>>> a tiny part of the start_xmit function.
>>
>> Then what synchornization primitive other than spin locks are you go=
ing
>> to use for this?
>>
>> My point is that there is a spinlock the core code is _already_ taki=
ng,
>> unconditionally, when ->ndo_start_xmit() executes.  And you can ther=
efore
>> take advantage of that rather than using another lock of your own.
>=20
> I get that.  But that remains locked for the duration of ndo_start_xm=
it()
> whereas the part that needs to be synchronised with the DMA completio=
n
> IRQ handler is tiny.  Having the IRQ handler spin for the duration of
> ndo_start_xmit() seemed silly to me.

I don't think it's silly at all.

And unless you can measure it making a difference, don't knock the idea=
=2E
