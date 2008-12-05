From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: qmgr for ixp4xx
Date: Fri, 05 Dec 2008 19:29:36 +0100
Message-ID: <m3fxl2jx0v.fsf@maximus.localdomain>
References: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
	<m3zljby7jm.fsf@maximus.localdomain>
	<b0438a630812050051v6393ae1at40b3669389dd394e@mail.gmail.com>
	<m31vwmlidh.fsf@maximus.localdomain>
	<b0438a630812050859jd9fd55ah5fb3608a964f9567@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:51196 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991AbYLES3j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 13:29:39 -0500
In-Reply-To: <b0438a630812050859jd9fd55ah5fb3608a964f9567@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Fri\, 5 Dec
 2008 17\:59\:17 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

>> We also have to make sure the queues don't conflict with the Etherne=
t
>> driver and (if used) with the crypto code.
>>
> The queues are different for each NPE, aren' t they?

They have to (except one Ethernet queue (TXDONE) which is used by all
ports).

> I will check for the 64-queue support patch (thanks Karl). However, i=
f
> I am not sure they are required. I mean...
> - HSS0 uses queues 12-22.
> - HSS1 uses queues 0-10.
> - That leaves us 10 queues free, doesn't it? Couldn't we use queue 11
> for eth txreadyq, 23-26 for HSS0 txreadyq, 27-30 for HSS1 txreadyq an=
d
> 31 for crypto code (which I do not know?)

Ethernet needs 3 queues per port + 1 (465 CPUs can have 3 Ethernet
ports), the crypto code probably needs several ones.

>> /* Set the least significant 2 bits of the queue entry to the HDLC p=
ort number. */
>> qEntry |=3D (hdlcPortId & IX_HSSACC_QM_Q_CHAN_NUM_MASK);
>>
>> They want it when the packet is back in TXDONE queue.
>>
> Ummm? To know which queue should be refeeded? How could we do that?

I think so. You'd have to check with the real hardware, I remember
some NPEs set some fields in the descriptors.

>>> And reception? If I
>>> have only one reception queue how could I manage to know to which
>>> channel have I received the data?
>>
>> The descriptor will have an ID in it.
>>
> Where?

In the lower address bits (bits 0-4?), like in the line above.

> I was trying to improve your code to make it work in a 4E1. Before
> making it configurable, I have made a first implementation considerin=
g
> only my problem (which is not completely fixed yet). I will send you =
a
> patch with my development (too large to add it in the list), so that
> you could give me your oppinion if you want to. I would like to merge
> it with your code when it is working (and the clean-up is made).

Great.
--=20
Krzysztof Halasa
