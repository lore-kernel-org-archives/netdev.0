From: Jesse Gross <jesse@nicira.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Mon, 4 Oct 2010 13:21:44 -0700
Message-ID: <AANLkTiku7A01cROWezyrcSNaLA=hh8hNoW-D2c=fq_qU@mail.gmail.com>
References: <20100929113757.GA23755@core.hellgate.ch>
	<AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	<20100930080703.GA10827@core.hellgate.ch>
	<AANLkTikrfx1T3ay0AGWkS6Ab28J4O_er2TsbRinBSGen@mail.gmail.com>
	<1285884253.2705.25.camel@edumazet-laptop>
	<AANLkTi=Vdcn7xzJMPxkugvEVy32N7Bp=KVtir6NESnDF@mail.gmail.com>
	<1285909831.2705.41.camel@edumazet-laptop>
	<1285922469.2641.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:35213 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932232Ab0JDUVp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 16:21:45 -0400
Received: by gye5 with SMTP id 5so1685130gye.19
        for <netdev@vger.kernel.org>; Mon, 04 Oct 2010 13:21:45 -0700 (PDT)
In-Reply-To: <1285922469.2641.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 1, 2010 at 1:41 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le vendredi 01 octobre 2010 =E0 07:10 +0200, Eric Dumazet a =E9crit :
>> Le jeudi 30 septembre 2010 =E0 19:37 -0700, Jesse Gross a =E9crit :
>>
>> > That's true. =A0Dropping here seems roughly equivalent to the effe=
cts of
>> > a hardware VLAN filter, which will also not be tracked by a counte=
r,
>> > so that seems not too bad to me.
>> >
>> > The thing that concerns me though is why so many drivers seem to h=
ave
>> > this problem with completely dropping the VLAN header. =A0I know t=
hat
>> > even several of the ones that work now were broken initially and h=
ad
>> > to be fixed. =A0Seeing as the driver drops the VLAN information be=
fore
>> > it gets to the general networking code I don't see a generic fix t=
o
>> > this as it is currently setup. =A0However, perhaps we could make i=
t so
>> > that it is harder to get wrong. =A0Something like this:
>> >
>> > * Allow vlan_gro_receive() to take a NULL VLAN group and a tag of =
0
>> > (and do the same thing for vlan_hwaccel_rx())
>> > * Now that the vlan functions can deal with non-VLAN packets, merg=
e
>> > them into their non-VLAN counterparts.
>> > * We can now demultiplex between the VLAN/non-VLAN case in core
>> > networking. =A0This is done anyways, it just prevents every driver=
 from
>> > needing that code block I copied above and allows us to fix these
>> > types of problems centrally.
>> > * Dump the VLAN tag into the SKB and hand off the packet to the
>> > various consumers: VLAN devices, libpcap, bridge hook (not current=
ly
>> > done but should be for trunking).
>> >
>> > I see a number of advantages of this:
>> > * Fixes all the problems with cards dropping VLAN headers at once.
>> > * Avoids having to disable VLAN acceleration when in promiscuous m=
ode
>> > (good for bridging since it always puts devices in promiscuous mod=
e).
>> > * Keeps VLAN tag separate until given to ultimate consumer, which
>> > avoids needing to do header reconstruction as in tg3 unless absolu=
tely
>> > necessary.
>> > * Consolidates common driver code in core networking.
>>
>> This seems very reasonable ;)
>
> Jesse, do you plan to work on this stuff yourself in a near future ?

I'm a little bit busy at the moment but I'm hoping to have some time
to work on it towards the end of this week/beginning of next week.

Thanks for looking over the idea.
