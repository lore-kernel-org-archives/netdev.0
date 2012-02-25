From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH net-next 1/3] mlx4_en: TX ring size default to 1024
Date: Sat, 25 Feb 2012 01:51:22 -0500
Message-ID: <20120225015122.a7419f74.billfink@mindspring.com>
References: <4F46404D.10509@mellanox.co.il>
	<20120223.144541.1354349294973443529.davem@davemloft.net>
	<953B660C027164448AE903364AC447D2618B8768@MTLDAG02.mtl.com>
	<1330114654.2596.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:42728 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751187Ab2BYGv1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Feb 2012 01:51:27 -0500
In-Reply-To: <1330114654.2596.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Feb 2012, Eric Dumazet wrote:

> Le vendredi 24 f=E9vrier 2012 =E0 19:35 +0000, Yevgeny Petrilin a =E9=
crit :
> > > > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> > >=20
> > > This is rediculious as a default, yes even for 10Gb.
> > >=20
> > > Do you have any idea how high latency is going to be for packets
> > > trying to get into the transmit queue if there are already a
> > > thousand other frames in there?

=46or a GigE NIC with a typical ring size of 256, the serialization del=
ay
for 256 1500 byte packets is:

	1500*8*256/10^9 =3D ~3.1 msec

=46or a 10-GigE NIC with a ring size of 1024, the serialization delay
for 1024 1500 byte packets is:

	1500*8*1024/10^10 =3D ~1.2 msec

So it's not immediately clear that a ring size of 1024 is unreasonable
for 10-GigE.

It probably boils down to whether the default setting should
be biased more toward low latency applications or high throughput
bulk data applications.  Determining the best happy medium is
best decided by appropriate benchmark testing.  Of course,
anyone can change the settings to suit their purpose, so it's
really just a question of what's best for the "usual" case.

> > On the other hand, when having smaller queue with 1000 in-flight pa=
ckets would mean queue would be stopped,
> > how is it better?
>=20
> Its better because you can have any kind of Qdisc setup to properly
> classify packets, with 100.000 total packets in queues if you wish.

Not everyone wants to deal with the convoluted, arcane, and poorly
documented qdisc machinery, especially with its current limitations
at 10-GigE (or faster) line rates.

> TX ring is a single FIFO, and that is just horrible, especially with =
big packets...
>=20
> > Having bigger TX ring helps dealing better with bursts of TX packet=
s, without the overhead of stopping and starting the queue,
> > It also makes sense to have same size TX and RX queues, for example=
 in case of traffic being forwarded from TX to RX.
>=20
> Really I doubt people using forwarding setups use default qdiscs.

I don't think it's necessarily that uncommon, such as a simple
10-GigE firewall setup.

> Instead of bigger TX rings, they need appropriate Qdiscs.
>=20
> > I did find number of 10Gb vendors that have 1024 or more as the def=
ault size for TX queue.
>=20
> Thats a shame.

						-Bill
