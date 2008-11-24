From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: ixp4xx_hss MAX_CHAN_DEVICES
Date: Mon, 24 Nov 2008 18:12:47 +0100
Message-ID: <b0438a630811240912v16db8ef8v660cb844979fe912@mail.gmail.com>
References: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
	 <m3fxlksncm.fsf@maximus.localdomain>
	 <b0438a630811240203mdc431aev8b1bb9e8c924ac7e@mail.gmail.com>
	 <b0438a630811240415n6a1a0b23lf7ac37925d04a6b3@mail.gmail.com>
	 <m3prkl14pf.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.189]:44131 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbYKXRMt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 12:12:49 -0500
Received: by rn-out-0910.google.com with SMTP id k40so1748787rnd.17
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 09:12:47 -0800 (PST)
In-Reply-To: <m3prkl14pf.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

2008/11/24 Krzysztof Halasa <khc@pm.waw.pl>:
> "Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:
>
>> +++ linux-2.6.26.7/drivers/net/wan/ixp4xx_hss.c       2008-11-24
>
>> +struct physical_modes {
>> +     u8 id;
>> +     unsigned int frame_size;
>> +     unsigned int clock_rate;
>> +     u32 clock_config;
>> +};
>
> I think the clock rate shouldn't be a part of the fixed port config.
> I don't know much about 4E1 configs, but in the usual case (single
> physical port connected directly to the HSS) you can use many clock
> and frame size configurations.
>
I am not quite sure about this. If we do not set the clock_rate as
part of the "physical_mode"... where should it be set? As a separate
variable? I do not have problems with that neither.

> IOW I think physical mode =3D only signal/timeslot routing topology.
> The platform code could also optionally check if the specified clock
> type and rate is valid.
>
Is this what you are stating? a separate variable for clock_rate in
the platform structure?

>> +static const struct physical_modes phmodes[] =3D {
>> +     {IXP4XX_HSS_T1, 193, 1544000, CLK42X_SPEED_1544KHZ},
>> +     {IXP4XX_HSS_E1, 256, 2048000, CLK42X_SPEED_2048KHZ},
>> +     {IXP4XX_HSS_2_E1, 512, 4096000, CLK42X_SPEED_4096KHZ},
>> +     {IXP4XX_HSS_4_E1, 1024, 8192000, CLK42X_SPEED_8192KHZ},
>> +     {0, 256, 2048000, CLK42X_SPEED_2048KHZ}
>> +};
>
> If we need different internal clock rates (most framers/multiplexers
> provide their own, don't they?) then I guess we need to calculate the
> required settings ourselves. I don't exactly know how do they
> calculate the register but it should be easy to find out. There was n=
o
> need yet.
>
I agree... I think the precalculated values are enough for now.

>> +#define IXP4XX_HSS_T1     0x10
>> +#define IXP4XX_HSS_E1     0x11
>
> T1 and E1 are the same WRT hardware connection to the port.
>
I have done the difference for the clock_rates and the needing of a
framing bit in the case of T1.

>> - How should all these changes interact with show_frame_size and
>> set_frame_size?
>
> Perhaps the platform code should initialize the value and then check
> changes for validity. Only matters with G.704 framers I think.
> Otherwise the user should be able to select anything.
>
Yes... but the dynamic allocation makes it more difficult.

>> - I am a bit lost with MAX_CHANNELS and MAX_CHAN_DEVICES... Which ar=
e
>> the differences between both?
>
> MAX_CHANNELS =3D (currenly) 32 =3D max for single channel (32 E1
> channels).
> MAX_CHAN_DEVICES =3D limit of /dev/hssXchY nodes (for one port).
>
OK. Thanks... However... shouldn't they be the same value... I mean...
It could be possible to have a device for each channel in the frame,
not? So, for example if I had 128 channels (4*E1), it could be
required to deal with 128 devices, not? (In channelized mode).

>> - As MAX_CHANNELS and MAX_CHAN_DEVICES should not be set by defines,=
 I
>> am going to alloc memory for chan_devices... I am going to do it in
>> init_one... Is it OK?.
>
> MAX_CHANNELS, I think so.
> MAX_CHAN_DEVICES isn't directly related.
>
I do not understand why are not they directly related.

>> My first intention for all this is to set HSS into MVIP mode and hav=
e
>> 4 HDLC channels in a packetized mode.
>> - How could I set this MVIP mode?
>> - How could I interface with generic HDLC so that hss_hdlc_xmit send=
s
>> the data for each stream to a different FIFO?
>
> The HSS driver should initialize MVIP based on platform's
> physical_config value, then it would have to register 4 HDLC devices.
>
Sure... Let me re-do the question. Do you know how MVIP is set if I
detect it is needed? And... good idea with the registering of four
devices.

> The HDLC part (not the channelized one) should be quite trivial.
> I think we now need the HSS HDLC driver upstream, will look at this.
> --
Sorry... I have not understood this.

Miguel =C1ngel
