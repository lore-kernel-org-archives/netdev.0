From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: ixp4xx_hss MAX_CHAN_DEVICES
Date: Wed, 26 Nov 2008 13:08:43 +0100
Message-ID: <b0438a630811260408t6952603ei66c15d4cf1c18cca@mail.gmail.com>
References: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
	 <b0438a630811240203mdc431aev8b1bb9e8c924ac7e@mail.gmail.com>
	 <b0438a630811240415n6a1a0b23lf7ac37925d04a6b3@mail.gmail.com>
	 <m3prkl14pf.fsf@maximus.localdomain>
	 <b0438a630811240912v16db8ef8v660cb844979fe912@mail.gmail.com>
	 <m3tz9wsmut.fsf@maximus.localdomain>
	 <b0438a630811250851p18f5feabx7e744978555fa1d1@mail.gmail.com>
	 <m3bpw3ic0q.fsf@maximus.localdomain>
	 <b0438a630811260202q443d558fw1a3d8193d7f3e7d4@mail.gmail.com>
	 <m363mahgyr.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:15532 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbYKZMIq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 07:08:46 -0500
Received: by an-out-0708.google.com with SMTP id d40so210788and.1
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2008 04:08:44 -0800 (PST)
In-Reply-To: <m363mahgyr.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Again... thanks a lot for your answers.

2008/11/26 Krzysztof Halasa <khc@pm.waw.pl>:
> "Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:
>
>>> Basically MVIP divides your entire frame into 2 or 4 parts.
>>>
>> Sure. But... It is automatically activated when the frame length is
>> greater than 256 or should it be explicitelly set?
>
> You must set the number of (packetized) pipes.
> For channelized data, there is apparently no difference.
>
No problem in this.

>> OK... I understand the concept, but I am not sure about how this is
>> integrated with your driver (or the NPE). I mean... When I use your
>> driver, I obtain two interfaces hdlc0 and hdlc1 (one per HSS). If I
>> had only a packetized stream, I could open a socket to the interface
>> and send the data. No problem (I think) in it.
>> But if I want to have four streams (one per E1), is your driver
>> prepare to deal with this, or should I manage to create four
>> interfaces per HSS?
>
> The driver is currently missing the MVIP code.
>
That is what I supposed.

>> In the first case... Is it related with set_hdlc_chan function? The
>> name could suggest this, but then it does nothing for MODE_HDLC but
>> MODE_RAW and MODE_G704.
>
> That's for channelized data.
>
OK.

>> In the second case... I understand that if I have to add the new
>> interfaces, they should be network interfaces. Where do you recommen=
d
>> me to do it?
>
> I'd have to look at it.
>
OK, thanks. If we add an HSS id in the platform driver, I think we
could create up to 4 hdlc interfaces for each HSS. As all of them are
independent, all your code could be useful for each one. The main
question would be then how to map each one with the correct FIFO, not?
(What does txreadyq represent? How are their values chosen?)

>> In both cases... How can the user direct his data to one E1 or the o=
ther?
>
> Each "member" E1 is connected to its respective HDLC controller
> ("packetized pipe"), and these have "TX" and "RX-free" queues (one se=
t
> per each HDLC).
>
Sure... I suppose I have to modify queue_ids to use the correct queues
for tx and rx values. What should I do for txdone, rxfree and chan
values?

>> In my case (bad luck...) we have a legacy mode of connection, so I
>> cannot use any of the methods described. I "just" need something
>> similar to the IxHssAccPktPortConnection in the Intel Software
>> Library...
>
> Sure, you can use this raw HDLC + packet interface. One stream per
> (member) E1/T1 (or, to be precise, one stream per 1, 1/2 or 1/4 of th=
e
> physical interface).
>
Yes... I think this raw HDLC (although we are talking of raw HDLC we
are refering to MODE_HDLC with "sethdlc hdlc0 hdlc" and not MODE_RAW,
not?) is the answer if I found a way to create and interconnect
correctly 4*2 interfaces (hdlc0-hdlc7?).

Thanks a lot

Miguel =C1ngel
