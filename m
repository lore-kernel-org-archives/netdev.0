From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Thu, 18 Mar 2010 07:20:32 +0100
Message-ID: <1268893232.2894.65.camel@edumazet-laptop>
References: <65634d661003121508m3d348973k63a6ae9ca1f12f9f@mail.gmail.com>
	 <4B9FC7F1.5010507@google.com>	 <1268773227.2932.34.camel@edumazet-laptop>
	 <20100316.141311.262178287.davem@davemloft.net>
	 <412e6f7f1003161854w32ed4516w2e52003097051fc7@mail.gmail.com>
	 <1268809673.2932.62.camel@edumazet-laptop>
	 <412e6f7f1003170059r1f0fa4cfrbe8b3f22102ee9d9@mail.gmail.com>
	 <1268834957.2899.352.camel@edumazet-laptop>
	 <65634d661003170801x1042a6am563c9d937ba672a4@mail.gmail.com>
	 <4BA16AB8.3090800@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:54695 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab0CRGUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 02:20:37 -0400
Received: by bwz4 with SMTP id 4so1831215bwz.39
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 23:20:36 -0700 (PDT)
In-Reply-To: <4BA16AB8.3090800@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 mars 2010 =C3=A0 16:50 -0700, Tom Herbert a =C3=A9crit :
> >>
> >> # echo "0 1 0 1 0 1 1 1 1 1" >/sys/class/net/eth0/queues/rx-0/rps_=
map
> >> # cat /sys/class/net/eth0/queues/rx-0/rps_cpus
> >> 3
> >> # cat /sys/class/net/eth0/queues/rx-0/rps_map
> >> 0 1 0 1 0 1 1 1 1 1
> >> # echo 3 >/sys/class/net/eth0/queues/rx-0/rps_cpus
> >> # cat /sys/class/net/eth0/queues/rx-0/rps_map
> >> 0 1
> >=20
> > Alternatively, the rps_map could be specified explicitly, which wil=
l
> > allow weighting.  For example "0 0 0 0 2 10 10 10"  would select CP=
Us
> > 0, 2, 10 for the map with weights four, one, and three respectively=
=2E
> > This would go back to have sysfs files with multiple values in them=
,
> > so it might not be the right interface.
>=20
> Here is a patch for this...
>=20
> Allow specification of CPUs in rps to be done with a vector instead o=
f a bit map.  This allows relative weighting of CPUs in the map by repe=
ating ones to give higher weight.
>=20
> For example "echo 0 0 0 3 4 4 4 4 > /sys/class/net/eth0/queues/rx-0/r=
ps_cpus"
>=20
> assigns CPUs 0, 3, and 4 to the RPS mask with relative weights 3, 1, =
and 4 respectively.
>=20

Hmm...

I believe we should keep existing sysfs cpumask interface, because its
the only workable thing on a PAGE_SIZE=3D4096 machine with 4096 cpus.

strlen("0 1 2 3 4 ... 4095") =3D 19369

Using base 16 instead of base 10 -> 16111



