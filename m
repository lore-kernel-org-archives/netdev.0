From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: ixp4xx_hss MAX_CHAN_DEVICES
Date: Wed, 26 Nov 2008 11:02:20 +0100
Message-ID: <b0438a630811260202q443d558fw1a3d8193d7f3e7d4@mail.gmail.com>
References: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
	 <m3fxlksncm.fsf@maximus.localdomain>
	 <b0438a630811240203mdc431aev8b1bb9e8c924ac7e@mail.gmail.com>
	 <b0438a630811240415n6a1a0b23lf7ac37925d04a6b3@mail.gmail.com>
	 <m3prkl14pf.fsf@maximus.localdomain>
	 <b0438a630811240912v16db8ef8v660cb844979fe912@mail.gmail.com>
	 <m3tz9wsmut.fsf@maximus.localdomain>
	 <b0438a630811250851p18f5feabx7e744978555fa1d1@mail.gmail.com>
	 <m3bpw3ic0q.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:36974 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbYKZKCW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 05:02:22 -0500
Received: by yx-out-2324.google.com with SMTP id 8so194226yxm.1
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2008 02:02:20 -0800 (PST)
In-Reply-To: <m3bpw3ic0q.fsf@maximus.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, and thanks a lot for all your help.

2008/11/26 Krzysztof Halasa <khc@pm.waw.pl>:
> "Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:
>
>> I think I do not make me understand myself... The question is: Do yo=
u
>> know which message should I send to the NPE to configure it for MVIP
>> mode?
>
> You mean the low-level messages to NPE-A?
>
Yes... That is one of the main problems... I do not find the
information about the low-level so I am not sure of what must I change
in your driver to fit my needs.

> First you need to set the frame length (max is 1024 bits)
> and fill the LUT (the slot mapping table) correctly (max 128 slots).
>
> If I understand and remember this correctly, for HDLC you need to sen=
d
> PKT_NUM_PIPES_WRITE =3D 4 (or 2 for 2E1), and I think
> PKT_PIPE_FIFO_SIZEW_WRITE must be reduced (to 1 for 4 HDLC pipes and
> 2 for 2 pipes?).
>
Yes... I think all these values are correct.

> For channelized mode you need CHAN_NUM_CHANS_WRITE (0 - 128, number o=
f
> active channels only).
>
Not my case.

> Basically MVIP divides your entire frame into 2 or 4 parts.
>
Sure. But... It is automatically activated when the frame length is
greater than 256 or should it be explicitelly set?

>> - If you have just one source of data, you can use packetized mode
>> (and it does not care which clock rate you are using...).
>> - If you have more than one sources of data and are working (for
>> example) with an E1, you create a channel for each source, and the
>> driver manages it.
>> - But... If I want four sources of unstructured data (one for each
>> "E1" in a 4E1), must I use a channelized mode, or a packetized mode?
>
> These are unrelated.
>
You are true... I was being quite simplistic again.

> a) all four E1s in 4E1 are completely independent. Their packetized
> streams are, thus, independent as well. You may think about them as o=
f
> four (almost) separate physical interfaces. I think the NPE can do a
> single HDLC stream over a 1024-bit frame, but this isn't technically
> MVIP, it's a single logical interface with data rate up to 8 Mb/s.
>
OK... I understand the concept, but I am not sure about how this is
integrated with your driver (or the NPE). I mean... When I use your
driver, I obtain two interfaces hdlc0 and hdlc1 (one per HSS). If I
had only a packetized stream, I could open a socket to the interface
and send the data. No problem (I think) in it.
But if I want to have four streams (one per E1), is your driver
prepare to deal with this, or should I manage to create four
interfaces per HSS?
In the first case... Is it related with set_hdlc_chan function? The
name could suggest this, but then it does nothing for MODE_HDLC but
MODE_RAW and MODE_G704.
In the second case... I understand that if I have to add the new
interfaces, they should be network interfaces. Where do you recommend
me to do it?
In both cases... How can the user direct his data to one E1 or the othe=
r?

> b) packetized mode is mostly for HDLC. You need it if you want to hav=
e
> Frame-Relay, X.25, Cisco HDLC, synchronous PPP etc. over some
> channels (timeslots) (partial E1/T1 etc) or over the full frame (all
> channels). The chip has only one HDLC controller per logical interfac=
e
> (E1 etc) so you can only have one HDLC stream per (member of MVIP) E1=
=2E
>
> If you need multiple streams of packets (per logical interface), you
> can use Frame-Relay with multiple PVCs, or, for example,
> Ethernet-alike VLANs.
>
In my case (bad luck...) we have a legacy mode of connection, so I
cannot use any of the methods described. I "just" need something
similar to the IxHssAccPktPortConnection in the Intel Software
Library... (I rather prefer to use your library by far... but this is
a point I understand in their library but not quite sure of how to use
it in yours).

> c) Channelized mode is for bit-transparent data - mainly voice
> communications (circuit-switched, e.g. ISDN with 64 kb/s per channel)=
,
> or when you don't care what's being transmitted because you are only
> forwarding the traffic (and not terminating it with e.g. HDLC).
>
I agree.
>
> You can have both channelized and packetized timeslots on your
> interfaces (logical and physical). For purely packetized data ("full"
> physical interface used by a single HDLC stream) you don't even need =
a
> framer, because you don't care when the frame starts, or if there is
> frame at all. Otherwise, you need a framer (for a single E1/(T1) ther=
e
> is an experimental software framer, for MVIP you need a hardware
> chip).
>
We have one framer, thanks.

>
> The clock is yet another thing independent of the above. If you
> connect a DCE to the HSS, the DCE will usually provide the clock. The
> (hardware) framers and/or E1/T1 transceivers will do as well.
> The internal clock is usually needed when the HSS acts as DCE itself,
> usually when you connect two similar devices together (two DTEs).
> That's why it's currently fixed at 2 Mb/s, it's mostly for tests.

We are in that case... (more or less...), so we should act on the
clock. (No problem in that...)

Miguel =C1ngel
