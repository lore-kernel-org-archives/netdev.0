From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA
 affinity
Date: Tue, 30 Nov 2010 20:07:27 +0100
Message-ID: <1291144047.2904.224.camel@edumazet-laptop>
References: <1290705163.4274.12.camel@localhost>
	 <1291054477.3435.1302.camel@edumazet-laptop>
	 <AANLkTimU+7aY0DZrnBtL=BsP_qGpCsBw0d4TCKOJSzRL@mail.gmail.com>
	 <20101130.104834.112604433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62415 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939Ab0K3THc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 14:07:32 -0500
Received: by wyb28 with SMTP id 28so6020801wyb.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 11:07:31 -0800 (PST)
In-Reply-To: <20101130.104834.112604433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 10:48 -0800, David Miller a =C3=A9crit=
 :

> Most drivers do, and all drivers ought to, allocate DMA queues and
> whatnot when the interface is brought up.
>=20
> That solves this particular issue.
>=20
> For example, drivers/net/niu.c does this by calling
> niu_alloc_channels() via niu_open().
>=20
> The only thing we really can't handle currently is the netdev
> itself (and the associated driver private).  Jesse Brandeburg
> has been reminding me about this over and over :-)
>=20
> There might be some things we can even do about that part.  For
> example, we can put all of the things the driver touches in the
> RX and TX fast paths via indirect pointers and therefore be able
> to allocate and reallocate those portions as we want long after
> device registry.
>=20
> Doing the core netdev struct itself is too hard because it sits
> in so many tables.

netdev struct itself is shared by all cpus, so there is no real choice,
unless you know one netdev will be used by a restricted set of
cpus/nodes... Probably very unlikely in practice.

This can probably be done right now with=20
numactl .... modprobe ...


We could change (only on NUMA setups maybe)

struct netdev_queue *_tx;

to a

struct netdev_queue **_tx;

and allocate each "struct netdev_queue" on appropriate node, but adding
one indirection level might be overkill...

=46or very hot small structures, (one or two cache lines), I am not sur=
e
its worth the pain.


Ben, could you remind us what was your ethtool interface ?

Something to setup a NUMA map for RX queues, TX queues ?

I can probably play with bnx2x and custom module param to test how it
can help raw performance...



