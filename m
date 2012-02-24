From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next 1/3] mlx4_en: TX ring size default to 1024
Date: Fri, 24 Feb 2012 21:17:34 +0100
Message-ID: <1330114654.2596.3.camel@edumazet-laptop>
References: <4F46404D.10509@mellanox.co.il>
	 <20120223.144541.1354349294973443529.davem@davemloft.net>
	 <953B660C027164448AE903364AC447D2618B8768@MTLDAG02.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:33211 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757986Ab2BXURj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 15:17:39 -0500
Received: by werb13 with SMTP id b13so1705470wer.19
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2012 12:17:38 -0800 (PST)
In-Reply-To: <953B660C027164448AE903364AC447D2618B8768@MTLDAG02.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 f=C3=A9vrier 2012 =C3=A0 19:35 +0000, Yevgeny Petrilin a=
 =C3=A9crit :
> > > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> >=20
> > This is rediculious as a default, yes even for 10Gb.
> >=20
> > Do you have any idea how high latency is going to be for packets
> > trying to get into the transmit queue if there are already a
> > thousand other frames in there?
>=20
> On the other hand, when having smaller queue with 1000 in-flight pack=
ets would mean queue would be stopped,
> how is it better?

Its better because you can have any kind of Qdisc setup to properly
classify packets, with 100.000 total packets in queues if you wish.

TX ring is a single FIFO, and that is just horrible, especially with bi=
g packets...

> Having bigger TX ring helps dealing better with bursts of TX packets,=
 without the overhead of stopping and starting the queue,
> It also makes sense to have same size TX and RX queues, for example i=
n case of traffic being forwarded from TX to RX.
>=20

Really I doubt people using forwarding setups use default qdiscs.

Instead of bigger TX rings, they need appropriate Qdiscs.

> I did find number of 10Gb vendors that have 1024 or more as the defau=
lt size for TX queue.

Thats a shame.
