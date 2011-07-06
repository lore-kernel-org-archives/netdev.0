From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/2] AF_PACKET fanout support
Date: Wed, 06 Jul 2011 06:07:46 +0200
Message-ID: <1309925266.2545.48.camel@edumazet-laptop>
References: <CA+mtBx_MtQGqNT6iungW7eyStpvLEGYsgXQ8=mYq_JR8jw3=DQ@mail.gmail.com>
	 <20110705.182041.1392492274453963565.davem@davemloft.net>
	 <CA+mtBx8www2eNp38EDuagYMQGSYivG7SN4ffozz4QtZPZqubSQ@mail.gmail.com>
	 <20110705.201950.199250194399828543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, victor@inliniac.net, netdev@vger.kernel.org,
	willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51566 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750Ab1GFEHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 00:07:52 -0400
Received: by wwe5 with SMTP id 5so6536401wwe.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 21:07:51 -0700 (PDT)
In-Reply-To: <20110705.201950.199250194399828543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 20:19 -0700, David Miller a =C3=A9crit =
:
> From: Tom Herbert <therbert@google.com>
> Date: Tue, 5 Jul 2011 20:13:27 -0700
>=20
> >>> Also, another useful mode of steering would be to steer packets t=
o a
> >>> socket which was recently processed by a thread running on the sa=
me
> >>> CPU; somewhat analogous to RFS (cc'ed WIllem Bruijn who is alread=
y
> >>> working on this I believe).
> >>
> >> This sounds like a good way to overload a local socket and prevent
> >> pushing the work to lesser used sockets on other cpus.
> >>
> > Sure, it you're not using RPS or RSS!  These should already be
> > distributing the RX work amongst CPUs.
>=20
> One idea I did have while working on the PACKET_FANOUT bits was
> to allow a packet socket to be bound to a particular cpu.  And
> to implement this we'd have a per-cpu list of packet_type taps.
>=20
> But in order for the user to make sure he gets all the traffic,
> he'd have to make sure he bound one AF_PACKET socket to every
> online cpu and then listened for all cpu hotplug events.
>=20
> It doesn't really work.

It is working right now if you dont have too many cpus, adding as many
sockets as possible cpus, and convenient BPF filter (matching CPU X) pe=
r
packet socket. Of course, if a cpu is offlined, the corresponding socke=
t
wont receive any packet.

Currently, with a multiqueue NIC, the two policies you have might be in
conflict with NIC flow distribution among its queues.

In the end, lot of different cpus will access all the sockets.

I suspect this can be solved adding a third policy : hash by CPU only




