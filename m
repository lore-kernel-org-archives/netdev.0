From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: qmgr for ixp4xx
Date: Tue, 9 Dec 2008 10:48:03 +0100
Message-ID: <b0438a630812090148u4c42a193q833c913a1a27e0a9@mail.gmail.com>
References: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
	 <m3zljby7jm.fsf@maximus.localdomain>
	 <b0438a630812050051v6393ae1at40b3669389dd394e@mail.gmail.com>
	 <m31vwmlidh.fsf@maximus.localdomain>
	 <b0438a630812050859jd9fd55ah5fb3608a964f9567@mail.gmail.com>
	 <m3fxl2jx0v.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:18363 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040AbYLIJsF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 04:48:05 -0500
Received: by an-out-0708.google.com with SMTP id d40so655167and.1
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 01:48:04 -0800 (PST)
In-Reply-To: <m3fxl2jx0v.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

2008/12/5 Krzysztof Halasa <khc@pm.waw.pl>:
> "Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:
>
>>> We also have to make sure the queues don't conflict with the Ethern=
et
>>> driver and (if used) with the crypto code.
>>>
>> The queues are different for each NPE, aren' t they?
>
> They have to (except one Ethernet queue (TXDONE) which is used by all
> ports).
>
OK.

>> I will check for the 64-queue support patch (thanks Karl). However, =
if
>> I am not sure they are required. I mean...
>> - HSS0 uses queues 12-22.
>> - HSS1 uses queues 0-10.
>> - That leaves us 10 queues free, doesn't it? Couldn't we use queue 1=
1
>> for eth txreadyq, 23-26 for HSS0 txreadyq, 27-30 for HSS1 txreadyq a=
nd
>> 31 for crypto code (which I do not know?)
>
> Ethernet needs 3 queues per port + 1 (465 CPUs can have 3 Ethernet
> ports), the crypto code probably needs several ones.
>
Sure... But in case you are not using ethernet in the NPEA (most
likely if you are using HSS), ethernet only takes one common queue
(TXDONE =3D 31). The rest of the queues seem to be NPE dependent. At
least that was what I thought, but if I change rxq and txreadyq for
ethernet in ixdp425-setup.c and give them the values 0x103, 0x114 for
NPEB and 0x203, 0x214 for NPEC they also interfere with the queues for
HSS (for not 0 hdlcs...).

So... Do we have 32 queues for NPE, or some of them are common for all
NPEs? In the first case it could be possible to work with 32 queues in
most of the situations... if not, 64-queue patch seems to be required
(where can I find last version of it? I just found one which is
heavily critizised by you, Krzysztof).

>>> /* Set the least significant 2 bits of the queue entry to the HDLC =
port number. */
>>> qEntry |=3D (hdlcPortId & IX_HSSACC_QM_Q_CHAN_NUM_MASK);
>>>
>>> They want it when the packet is back in TXDONE queue.
>>>
>> Ummm? To know which queue should be refeeded? How could we do that?
>
> I think so. You'd have to check with the real hardware, I remember
> some NPEs set some fields in the descriptors.
>
How can I check it?

>>>> And reception? If I
>>>> have only one reception queue how could I manage to know to which
>>>> channel have I received the data?
>>>
>>> The descriptor will have an ID in it.
>>>
>> Where?
>
> In the lower address bits (bits 0-4?), like in the line above.
>
OK.

Thanks

Miguel =C1ngel
