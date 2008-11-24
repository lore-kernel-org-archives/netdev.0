From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: ixp4xx_hss MAX_CHAN_DEVICES
Date: Tue, 25 Nov 2008 00:52:42 +0100
Message-ID: <m3tz9wsmut.fsf@maximus.localdomain>
References: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
	<m3fxlksncm.fsf@maximus.localdomain>
	<b0438a630811240203mdc431aev8b1bb9e8c924ac7e@mail.gmail.com>
	<b0438a630811240415n6a1a0b23lf7ac37925d04a6b3@mail.gmail.com>
	<m3prkl14pf.fsf@maximus.localdomain>
	<b0438a630811240912v16db8ef8v660cb844979fe912@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:46403 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988AbYKXXwp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 18:52:45 -0500
In-Reply-To: <b0438a630811240912v16db8ef8v660cb844979fe912@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Mon\, 24 Nov
 2008 18\:12\:47 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> I am not quite sure about this. If we do not set the clock_rate as
> part of the "physical_mode"... where should it be set? As a separate
> variable?

I think so. In most cases the external clock will be used anyway.

> Is this what you are stating? a separate variable for clock_rate in
> the platform structure?
>
>>> +static const struct physical_modes phmodes[] =3D {
>>> +     {IXP4XX_HSS_T1, 193, 1544000, CLK42X_SPEED_1544KHZ},
>>> +     {IXP4XX_HSS_E1, 256, 2048000, CLK42X_SPEED_2048KHZ},
>>> +     {IXP4XX_HSS_2_E1, 512, 4096000, CLK42X_SPEED_4096KHZ},
>>> +     {IXP4XX_HSS_4_E1, 1024, 8192000, CLK42X_SPEED_8192KHZ},
>>> +     {0, 256, 2048000, CLK42X_SPEED_2048KHZ}
>>> +};

No. The HSS driver already has code for the clock rate. Unfortunately
it doesn't yet know how to set the register.

There is IMHO one thing missing from the platform struct: the
physical mode, aka topology; a single integer. Possible values:
a) direct connection to HSS, b) HSS connected to a 4 * E1 MVIP framer,
c) 4 * T1 MVIP, d+) other similar variants (perhaps 2 * E1, 2 * T1).

>> T1 and E1 are the same WRT hardware connection to the port.
>>
> I have done the difference for the clock_rates and the needing of a
> framing bit in the case of T1.

Sure, but: clock rate is independent anyway, and the framing bit can be
requested by using 193 bits of frame (IIRC this is how the code
currently works but I'd have to check for sure).

> OK. Thanks... However... shouldn't they be the same value... I mean..=
=2E
> It could be possible to have a device for each channel in the frame,
> not? So, for example if I had 128 channels (4*E1), it could be
> required to deal with 128 devices, not? (In channelized mode).

Sure (though I don't know how efficient would that be).

The truth is the HSS channelized code is quite experimental. It works,
and I actually use it, but I haven't yet decided about the API and
this is why it isn't still upstream.

HDLC HSS code is IMHO stable and could be submitted upstream, I will
do it sometime.

> Sure... Let me re-do the question. Do you know how MVIP is set if I
> detect it is needed? And... good idea with the registering of four
> devices.

The platform code should provide the "mode" (aka topology) =3D "4 * E1"=
=2E
There is nothing to detect. The driver has to handle 4E1, that's all.
--=20
Krzysztof Halasa
