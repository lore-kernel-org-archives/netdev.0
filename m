From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tuntap: Overload handling
Date: Thu, 14 Feb 2013 18:42:42 +0200
Message-ID: <20130214164053.GB18721@redhat.com>
References: <CAGUzgdK9U3hreLxtc6eP3CSpLsfhkn2ZKpFp9_VJhWr2gz0uCQ@mail.gmail.com>
 <CAGUzgdJOLmOyd9dd=Ht-qgZ9B-or59pDwaUY28DrbnL4BKFPcw@mail.gmail.com>
 <1360859547.6884.51.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian =?iso-8859-1?Q?P=F6hn?=
	<sebastian.poehn@googlemail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49344 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758033Ab3BNQms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 11:42:48 -0500
Content-Disposition: inline
In-Reply-To: <1360859547.6884.51.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2013 at 08:32:27AM -0800, Eric Dumazet wrote:
> On Thu, 2013-02-14 at 12:50 +0100, Sebastian P=F6hn wrote:
> > I am having a look on the tun driver to realize an userspace networ=
k
> > driver ( TAP + UIO ). Maybe that's not the use-case tun is intended
> > for.
> >=20
> > What I've noticed is that in tun.c Line 741
> >=20
> > static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_dev=
ice *dev)
> >=20
> > /* Limit the number of packets queued by dividing txq length with t=
he
> >  * number of queues.
> >  */
> > if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
> >  >=3D dev->tx_queue_len / tun->numqueues)
> > goto drop;
> >=20
> > If a frame can not be tx it is dropped by the driver.
> > Wouldn't it be more correct to netif_tx_stop_queue() so that packet
> > drops are performed by the overlying traffic control code?
> >=20
> > Of course this is not very likely in virtual environments but as so=
on
> > as any real network hop is involved it could be important.
> >=20
> > (I also had a look on some two year old version of tun.c. There
> > queue/tx stopping was done correctly.)

Hmm so ~1000 packets in the tun queue is not enough?
You always have the option to increase it some more ...

> You should ask Michael S. Tsirkin, as he removed the flow control
> in commit 5d097109257c03a71845729f8db6b5770c4bbedc
> (tun: only queue packets on device)
>=20

Eric in the past you said the following things
(http://lkml.indiana.edu/hypermail/linux/kernel/1204.1/00784.html)
> > In your case I would just not use qdisc at all, like other virtual
> > devices.
=2E..
> > Anyway, with a 500 packet limit in TUN queue itself, qdisc layer sh=
ould
> > be always empty. Whats the point storing more than 500 packets for =
a
> > device ? Thats a latency killer.
you don't think this applies, anymore?

--=20
MST
