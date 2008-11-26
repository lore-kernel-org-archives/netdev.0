From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: ixp4xx_hss MAX_CHAN_DEVICES
Date: Wed, 26 Nov 2008 12:19:56 +0100
Message-ID: <m363mahgyr.fsf@maximus.localdomain>
References: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
	<m3fxlksncm.fsf@maximus.localdomain>
	<b0438a630811240203mdc431aev8b1bb9e8c924ac7e@mail.gmail.com>
	<b0438a630811240415n6a1a0b23lf7ac37925d04a6b3@mail.gmail.com>
	<m3prkl14pf.fsf@maximus.localdomain>
	<b0438a630811240912v16db8ef8v660cb844979fe912@mail.gmail.com>
	<m3tz9wsmut.fsf@maximus.localdomain>
	<b0438a630811250851p18f5feabx7e744978555fa1d1@mail.gmail.com>
	<m3bpw3ic0q.fsf@maximus.localdomain>
	<b0438a630811260202q443d558fw1a3d8193d7f3e7d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:36669 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751706AbYKZLT7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 06:19:59 -0500
In-Reply-To: <b0438a630811260202q443d558fw1a3d8193d7f3e7d4@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Wed\, 26 Nov
 2008 11\:02\:20 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

>> Basically MVIP divides your entire frame into 2 or 4 parts.
>>
> Sure. But... It is automatically activated when the frame length is
> greater than 256 or should it be explicitelly set?

You must set the number of (packetized) pipes.
=46or channelized data, there is apparently no difference.

> OK... I understand the concept, but I am not sure about how this is
> integrated with your driver (or the NPE). I mean... When I use your
> driver, I obtain two interfaces hdlc0 and hdlc1 (one per HSS). If I
> had only a packetized stream, I could open a socket to the interface
> and send the data. No problem (I think) in it.
> But if I want to have four streams (one per E1), is your driver
> prepare to deal with this, or should I manage to create four
> interfaces per HSS?

The driver is currently missing the MVIP code.

> In the first case... Is it related with set_hdlc_chan function? The
> name could suggest this, but then it does nothing for MODE_HDLC but
> MODE_RAW and MODE_G704.

That's for channelized data.

> In the second case... I understand that if I have to add the new
> interfaces, they should be network interfaces. Where do you recommend
> me to do it?

I'd have to look at it.

> In both cases... How can the user direct his data to one E1 or the ot=
her?

Each "member" E1 is connected to its respective HDLC controller
("packetized pipe"), and these have "TX" and "RX-free" queues (one set
per each HDLC).

> In my case (bad luck...) we have a legacy mode of connection, so I
> cannot use any of the methods described. I "just" need something
> similar to the IxHssAccPktPortConnection in the Intel Software
> Library...

Sure, you can use this raw HDLC + packet interface. One stream per
(member) E1/T1 (or, to be precise, one stream per 1, 1/2 or 1/4 of the
physical interface).
--=20
Krzysztof Halasa
