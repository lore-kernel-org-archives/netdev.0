From: Simon Horman <horms@verge.net.au>
Subject: Re: Bonding, GRO and tcp_reordering
Date: Wed, 1 Dec 2010 13:34:45 +0900
Message-ID: <20101201043445.GC3485@verge.net.au>
References: <20101130135549.GA22688@verge.net.au>
 <1291131776.21077.27.camel@bwh-desktop>
 <1291133073.2904.128.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:42418 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513Ab0LAEes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 23:34:48 -0500
Content-Disposition: inline
In-Reply-To: <1291133073.2904.128.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 05:04:33PM +0100, Eric Dumazet wrote:
> Le mardi 30 novembre 2010 =C3=A0 15:42 +0000, Ben Hutchings a =C3=A9c=
rit :
> > On Tue, 2010-11-30 at 22:55 +0900, Simon Horman wrote:
>=20
> > > The only other parameter that seemed to have significant effect w=
as to
> > > increase the mtu.  In the case of MTU=3D9000, GRO seemed to have =
a negative
> > > impact on throughput, though a significant positive effect on CPU
> > > utilisation.
> > [...]
> >=20
> > Increasing MTU also increases the interval between packets on a TCP=
 flow
> > using maximum segment size so that it is more likely to exceed the
> > difference in delay.
> >=20
>=20
> GRO really is operational _if_ we receive in same NAPI run several
> packets for the same flow.
>=20
> As soon as we exit NAPI mode, GRO packets are flushed.
>=20
> Big MTU --> bigger delays between packets, so big chance that GRO can=
not
> trigger at all, since NAPI runs for one packet only.
>=20
> One possibility with big MTU is to tweak "ethtool -c eth0" params
> rx-usecs: 20
> rx-frames: 5
> rx-usecs-irq: 0
> rx-frames-irq: 5
> so that "rx-usecs" is bigger than the delay between two MTU full size=
d
> packets.
>=20
> Gigabit speed means 1 nano second per bit, and MTU=3D9000 means 72 us
> delay between packets.
>=20
> So try :
>=20
> ethtool -C eth0 rx-usecs 100
>=20
> to get chance that several packets are delivered at once by NIC.
>=20
> Unfortunately, this also add some latency, so it helps bulk transfert=
s,
> and slowdown interactive traffic=20

Thanks Eric,

I was tweaking those values recently for some latency tuning
but I didn't think of them in relation to last night's tests.

In terms of my measurements, its just benchmarking at this stage.
So a trade-off between throughput and latency is acceptable, so long
as I remember to measure what it is.

