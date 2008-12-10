From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: qmgr for ixp4xx
Date: Wed, 10 Dec 2008 01:56:25 +0100
Message-ID: <m3fxkwvoee.fsf@maximus.localdomain>
References: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
	<m3zljby7jm.fsf@maximus.localdomain>
	<b0438a630812050051v6393ae1at40b3669389dd394e@mail.gmail.com>
	<m31vwmlidh.fsf@maximus.localdomain>
	<b0438a630812050859jd9fd55ah5fb3608a964f9567@mail.gmail.com>
	<m3fxl2jx0v.fsf@maximus.localdomain>
	<b0438a630812090148u4c42a193q833c913a1a27e0a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:46707 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752006AbYLJA42 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 19:56:28 -0500
In-Reply-To: <b0438a630812090148u4c42a193q833c913a1a27e0a9@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Tue\, 9 Dec
 2008 10\:48\:03 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> Sure... But in case you are not using ethernet in the NPEA (most
> likely if you are using HSS),

I'm not sure but it may be true.
The docs say things about "6 ports" but AFAIK there are 3 physical
ports. For now I don't have anything 465-bases so I care a bit less
than for 425.

> ethernet only takes one common queue
> (TXDONE =3D 31). The rest of the queues seem to be NPE dependent.

Some numbers are fixed in software (like most of the Ethernet's
excluding "txready" which is a driver-only thing, and as Christian
writes, a couple of queues for crypto). Some are configurable (like RX
Ethernet queues, up to 8 per port with (not unused currently) QoS
"acceleration").

> At
> least that was what I thought, but if I change rxq and txreadyq for
> ethernet in ixdp425-setup.c and give them the values 0x103, 0x114 for
> NPEB and 0x203, 0x214 for NPEC they also interfere with the queues fo=
r
> HSS (for not 0 hdlcs...).

The range is 0-31 (0-0x1F). There are (not yet supported) queues 32-64
(0x20-0x3F) with a bit more limited functionality. We certainly need
them, too.

And the on-chip SRAM region in which the queues exist is limited, too.

> So... Do we have 32 queues for NPE, or some of them are common for al=
l
> NPEs? In the first case it could be possible to work with 32 queues i=
n
> most of the situations... if not, 64-queue patch seems to be required
> (where can I find last version of it? I just found one which is
> heavily critizised by you, Krzysztof).

It's this one. It wasn't "heavily criticized", though. I didn't like
many tiny bits but generally it is a good work.

We have 64 queues for all ports, processes etc combined.
You may want to see Intel's docs, for instance their IXP42X
development manual (the queues are explained in section 21, "AHB Queue
Manager (AQM)).
--=20
Krzysztof Halasa
