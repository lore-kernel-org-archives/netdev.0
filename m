From: Andrew Vagin <avagin@parallels.com>
Subject: Re: Slow speed of tcp connections in a network namespace
Date: Sun, 30 Dec 2012 00:08:48 +0400
Message-ID: <20121229200848.GA3389@paralelels.com>
References: <20121229092417.GA4038@paralelels.com>
 <1356789203.21409.3923.camel@edumazet-glaptop>
 <20121229145030.GA7959@paralelels.com>
 <1356802828.21409.4623.camel@edumazet-glaptop>
 <1356807516.4102.4.camel@edumazet-laptop>
 <1356810062.21409.4991.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <vvs@parallels.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54736 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748Ab2L2UJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 15:09:23 -0500
Content-Disposition: inline
In-Reply-To: <1356810062.21409.4991.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 29, 2012 at 11:41:02AM -0800, Eric Dumazet wrote:
> On Sat, 2012-12-29 at 19:58 +0100, Eric Dumazet wrote:
> > Le samedi 29 d=C3=A9cembre 2012 =C3=A0 09:40 -0800, Eric Dumazet a =
=C3=A9crit :
> >=20
> > >=20
> > > Please post your new tcpdump then ;)
> > >=20
> > > also post "netstat -s" from root and test ns after your wgets
> >=20
> > Also try following bnx2 patch.
> >=20
> > It should help GRO / TCP coalesce
> >=20
> > bnx2 should be the last driver not using skb head_frag

I don't have access to the host. I'm going to test your patch tomorrow.
Thanks.

>=20
> And of course, you should make sure all your bnx2 interrupts are hand=
led
> by the same cpu.
All bnx interrupts are handled on all cpus. They are handled on the sam=
e
cpu, if a kernel is booted with msi_disable=3D1.

Is it right, that a received window will be less, if packets are not so=
rted?
Looks like a bug.

I want to say, that probably it works correctly, if packets are sorted.
But I think if packets are not sorted, it should work with the same
speed, cpu load and memory consumption may be a bit more.

>=20
> Or else, packets might be reordered because the way dev_forward_skb()
> works.
>=20
> (CPU X gets a bunch of packets from eth0, forward them via netif_rx()=
 in
> the local CPU X queue, NAPI is ended on eth0)
>=20
> CPU Y gets a bunch of packets from eth0, forward them via netif_rx() =
in
> the local CPU Y queue.
>=20
> CPU X and Y process their local queue in // -> packets are delivered =
Out
> of order to TCP stack
>=20
> Alternative is to setup RPS on your veth1 device, to force packets be=
ing
> delivered/handled by a given cpu
>=20
>=20
>=20
>=20
>=20
