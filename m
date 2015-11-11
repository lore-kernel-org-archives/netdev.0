From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Wed, 11 Nov 2015 19:25:46 +0000
Message-ID: <yw1x7flonxs5.fsf@unicorn.mansr.com>
References: <yw1xfv0cnyjk.fsf@unicorn.mansr.com>
	<20151111.141311.1893172622045238748.davem@davemloft.net>
	<yw1xbnb0ny6k.fsf@unicorn.mansr.com>
	<20151111.141956.1056130800039910138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, slash.tmp@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151111.141956.1056130800039910138.davem@davemloft.net> (David
	Miller's message of "Wed, 11 Nov 2015 14:19:56 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: M=E5ns Rullg=E5rd <mans@mansr.com>
> Date: Wed, 11 Nov 2015 19:17:07 +0000
>
>> David Miller <davem@davemloft.net> writes:
>>=20
>>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>>> Date: Wed, 11 Nov 2015 19:09:19 +0000
>>>
>>>> David Miller <davem@davemloft.net> writes:
>>>>=20
>>>>> From: M=E5ns Rullg=E5rd <mans@mansr.com>
>>>>> Date: Wed, 11 Nov 2015 18:25:05 +0000
>>>>>
>>>>>> If the TX DMA channel is idle when start_xmit is called, it can =
be
>>>>>> started immediately.  Checking the DMA status and starting it if
>>>>>> idle has to be done atomically somehow.
>>>>>
>>>>> ->ndo_start_xmit() is guaranteed to be invoked atomically, protec=
ted
>>>>> by the TX queue spinlock.
>>>>=20
>>>> Yes, but the DMA needs to be restarted from some other context if =
it was
>>>> busy when start_xmit checked.
>>>
>>> Then you can probably use the TXQ lock in the interrupt handler jus=
t for
>>> that.
>>=20
>> That seems a bit heavy-handed when the critical section for this is =
only
>> a tiny part of the start_xmit function.
>
> Then what synchornization primitive other than spin locks are you goi=
ng
> to use for this?
>
> My point is that there is a spinlock the core code is _already_ takin=
g,
> unconditionally, when ->ndo_start_xmit() executes.  And you can there=
fore
> take advantage of that rather than using another lock of your own.

I get that.  But that remains locked for the duration of ndo_start_xmit=
()
whereas the part that needs to be synchronised with the DMA completion
IRQ handler is tiny.  Having the IRQ handler spin for the duration of
ndo_start_xmit() seemed silly to me.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
