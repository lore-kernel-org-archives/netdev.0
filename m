From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: ingress policying for realtime protocol
Date: Thu, 21 May 2015 09:07:12 +0200
Message-ID: <20150521070712.GY24769@pengutronix.de>
References: <20150519211145.GA23134@pengutronix.de>
 <CAHA+R7N8wFKPzOR0EshWzcaTUd+ChMW0zb0=1go4oV_gxoAyiA@mail.gmail.com>
 <1432168240.4060.63.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48019 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643AbbEUHHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 03:07:16 -0400
Content-Disposition: inline
In-Reply-To: <1432168240.4060.63.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 05:30:40PM -0700, Eric Dumazet wrote:
> On Wed, 2015-05-20 at 16:46 -0700, Cong Wang wrote:
>=20
> > There is very little to do on ingress side since there is no queue =
at all,
> > not to mention priority, you could try ifb to see if it fits your n=
eed.
>=20
> Note that if the need is to police traffic, ifb is not really needed =
:
>=20
> TC=3D"tc"
> DEV=3D"dev eth0"
> IP=3D10.246.11.51/32
> $TC qdisc del $DEV ingress 2>/dev/null
> $TC qdisc add $DEV ingress
> $TC filter add $DEV parent ffff: protocol ip u32 match ip src $IP \
> 	police rate 1Mbit burst 10Mbit mtu 66000 action drop/continue
>=20
> $TC -s filter ls $DEV parent ffff: protocol ip
I have something like that (matching on dst mac addresses instead of sr=
c ip):

	tc qdisc add dev eth0 handle ffff: ingress
	tc filter add dev eth0 parent ffff: protocol all prio 10 u32 match eth=
er dst 01:15:4E:00:00:01 police pass
	tc filter add dev eth0 parent ffff: protocol all prio 50 u32 match u32=
 0 0 at 0 police rate 100kbit burst 10k drop

=2E So Cong interpreted my question right and probably I just used the
wrong keywords to make you understand the same. I try again to put my
idea in words to make it explicit:

I imagine that it could help in my case if I could assert that MRP
packets are handled priorized over other traffic without throwing away
so many unrelated packets. For egress that works by e.g. using a prio
qdisc. For ingress however only shaping is available.

So the question essentially is: Why doesn't this work for ingress? Cong
wrote "there is no queue at all [for ingress]". Is this by design? Or i=
s
it just not implemented because noone spend the effort to work on that?
Do you think it would help me?

Maybe there is another bottleneck in the application that currently
forces us to use this tight limit on ingress shaping. I will try to wor=
k
on that, maybe shaping is good enough then?! I will report back.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
