From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Fri, 01 Oct 2010 10:41:09 +0200
Message-ID: <1285922469.2641.1.camel@edumazet-laptop>
References: <20100929113757.GA23755@core.hellgate.ch>
	 <AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	 <20100930080703.GA10827@core.hellgate.ch>
	 <AANLkTikrfx1T3ay0AGWkS6Ab28J4O_er2TsbRinBSGen@mail.gmail.com>
	 <1285884253.2705.25.camel@edumazet-laptop>
	 <AANLkTi=Vdcn7xzJMPxkugvEVy32N7Bp=KVtir6NESnDF@mail.gmail.com>
	 <1285909831.2705.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50585 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899Ab0JAIlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 04:41:16 -0400
Received: by fxm14 with SMTP id 14so454447fxm.19
        for <netdev@vger.kernel.org>; Fri, 01 Oct 2010 01:41:14 -0700 (PDT)
In-Reply-To: <1285909831.2705.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 01 octobre 2010 =C3=A0 07:10 +0200, Eric Dumazet a =C3=A9cr=
it :
> Le jeudi 30 septembre 2010 =C3=A0 19:37 -0700, Jesse Gross a =C3=A9cr=
it :
>=20
> > That's true.  Dropping here seems roughly equivalent to the effects=
 of
> > a hardware VLAN filter, which will also not be tracked by a counter=
,
> > so that seems not too bad to me.
> >=20
> > The thing that concerns me though is why so many drivers seem to ha=
ve
> > this problem with completely dropping the VLAN header.  I know that
> > even several of the ones that work now were broken initially and ha=
d
> > to be fixed.  Seeing as the driver drops the VLAN information befor=
e
> > it gets to the general networking code I don't see a generic fix to
> > this as it is currently setup.  However, perhaps we could make it s=
o
> > that it is harder to get wrong.  Something like this:
> >=20
> > * Allow vlan_gro_receive() to take a NULL VLAN group and a tag of 0
> > (and do the same thing for vlan_hwaccel_rx())
> > * Now that the vlan functions can deal with non-VLAN packets, merge
> > them into their non-VLAN counterparts.
> > * We can now demultiplex between the VLAN/non-VLAN case in core
> > networking.  This is done anyways, it just prevents every driver fr=
om
> > needing that code block I copied above and allows us to fix these
> > types of problems centrally.
> > * Dump the VLAN tag into the SKB and hand off the packet to the
> > various consumers: VLAN devices, libpcap, bridge hook (not currentl=
y
> > done but should be for trunking).
> >=20
> > I see a number of advantages of this:
> > * Fixes all the problems with cards dropping VLAN headers at once.
> > * Avoids having to disable VLAN acceleration when in promiscuous mo=
de
> > (good for bridging since it always puts devices in promiscuous mode=
).
> > * Keeps VLAN tag separate until given to ultimate consumer, which
> > avoids needing to do header reconstruction as in tg3 unless absolut=
ely
> > necessary.
> > * Consolidates common driver code in core networking.
>=20
> This seems very reasonable ;)

Jesse, do you plan to work on this stuff yourself in a near future ?


