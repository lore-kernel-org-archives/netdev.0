From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: qmgr for ixp4xx
Date: Wed, 10 Dec 2008 10:04:55 +0100
Message-ID: <b0438a630812100104i135f6bfawb9cff915202c39ce@mail.gmail.com>
References: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
	 <m3zljby7jm.fsf@maximus.localdomain>
	 <b0438a630812050051v6393ae1at40b3669389dd394e@mail.gmail.com>
	 <m31vwmlidh.fsf@maximus.localdomain>
	 <b0438a630812050859jd9fd55ah5fb3608a964f9567@mail.gmail.com>
	 <m3fxl2jx0v.fsf@maximus.localdomain>
	 <b0438a630812090148u4c42a193q833c913a1a27e0a9@mail.gmail.com>
	 <m3fxkwvoee.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:12088 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbYLJJE4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 04:04:56 -0500
Received: by yx-out-2324.google.com with SMTP id 8so195932yxm.1
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 01:04:55 -0800 (PST)
In-Reply-To: <m3fxkwvoee.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

2008/12/10 Krzysztof Halasa <khc@pm.waw.pl>:
> "Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:
>
>> Sure... But in case you are not using ethernet in the NPEA (most
>> likely if you are using HSS),
>
> I'm not sure but it may be true.
> The docs say things about "6 ports" but AFAIK there are 3 physical
> ports. For now I don't have anything 465-bases so I care a bit less
> than for 425.
>
ixp465 has only 3 ethernet ports I think. NPEA, NPEB and NPEC.

>> ethernet only takes one common queue
>> (TXDONE =3D 31). The rest of the queues seem to be NPE dependent.
>
> Some numbers are fixed in software (like most of the Ethernet's
> excluding "txready" which is a driver-only thing, and as Christian
> writes, a couple of queues for crypto). Some are configurable (like R=
X
> Ethernet queues, up to 8 per port with (not unused currently) QoS
> "acceleration").
>
Wouldn't it be interesting to have a list of all the fixed queues?
Let me try:
0-10 HSS1 (fixed)
12-22 HSS0 (fixed)
23 TXqueue NPEA (fixed)
24 TXqueue NPEB (fixed)
25 TXqueue NPEC (fixed)
26 RXfreequeue NPEA (fixed)
27 RXfreequeue NPEB (fixed)
28 RXfreequeue NPEC (fixed)
29,30 Criptocode (fixed)
31 Ethernet TXDONE (fixed)

Now supposing that we want to use three ethernets, two HSS and the
Criptocode, we need two additional queues for each ethernet (rxq and
txreadyq), and 2*4 additional queues for txreadyq for the possible 8
HDLC (4 per HSS) channels.

Am I right?

If we add 64 queue patch, we could give a fixed queue for each of this =
needs.

If not, in my case that I do not use ethernet in NPEA, criptocode and
HSSX_CHL_RXTRIG_QUEUEs, I have the following spare queues: 10, 11, 12,
23, 26, 29 and 30 (true?). Ummm... seven queues for eight txreadyq...
bad!!!

>> At
>> least that was what I thought, but if I change rxq and txreadyq for
>> ethernet in ixdp425-setup.c and give them the values 0x103, 0x114 fo=
r
>> NPEB and 0x203, 0x214 for NPEC they also interfere with the queues f=
or
>> HSS (for not 0 hdlcs...).
>
> The range is 0-31 (0-0x1F). There are (not yet supported) queues 32-6=
4
> (0x20-0x3F) with a bit more limited functionality. We certainly need
> them, too.
>
> And the on-chip SRAM region in which the queues exist is limited, too=
=2E
>
You are right... I was thinking the queues were different for each NPE
but they are not.

>> So... Do we have 32 queues for NPE, or some of them are common for a=
ll
>> NPEs? In the first case it could be possible to work with 32 queues =
in
>> most of the situations... if not, 64-queue patch seems to be require=
d
>> (where can I find last version of it? I just found one which is
>> heavily critizised by you, Krzysztof).
>
> It's this one. It wasn't "heavily criticized", though. I didn't like
> many tiny bits but generally it is a good work.
>
OK. Sorry for saying "heavily criticized". Just wanted to state that
it seems not good enough for you to be added in your tree.

> We have 64 queues for all ports, processes etc combined.
> You may want to see Intel's docs, for instance their IXP42X
> development manual (the queues are explained in section 21, "AHB Queu=
e
> Manager (AQM)).
>
RTFM... I was so centered in the lack of information of NPEs that I
did not realized that the queue manager had a chapter in the
developer's manual. Sorry. I have read it and things seem a bit
clearer now.

Thanks

Miguel =C1ngel
