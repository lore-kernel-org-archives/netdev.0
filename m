From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tuntap: Overload handling
Date: Thu, 14 Feb 2013 08:32:27 -0800
Message-ID: <1360859547.6884.51.camel@edumazet-glaptop>
References: <CAGUzgdK9U3hreLxtc6eP3CSpLsfhkn2ZKpFp9_VJhWr2gz0uCQ@mail.gmail.com>
	 <CAGUzgdJOLmOyd9dd=Ht-qgZ9B-or59pDwaUY28DrbnL4BKFPcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:34038 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934752Ab3BNQcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 11:32:36 -0500
Received: by mail-pb0-f52.google.com with SMTP id ma3so224482pbc.39
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 08:32:35 -0800 (PST)
In-Reply-To: <CAGUzgdJOLmOyd9dd=Ht-qgZ9B-or59pDwaUY28DrbnL4BKFPcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 12:50 +0100, Sebastian P=C3=B6hn wrote:
> I am having a look on the tun driver to realize an userspace network
> driver ( TAP + UIO ). Maybe that's not the use-case tun is intended
> for.
>=20
> What I've noticed is that in tun.c Line 741
>=20
> static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_devic=
e *dev)
>=20
> /* Limit the number of packets queued by dividing txq length with the
>  * number of queues.
>  */
> if (skb_queue_len(&tfile->socket.sk->sk_receive_queue)
>  >=3D dev->tx_queue_len / tun->numqueues)
> goto drop;
>=20
> If a frame can not be tx it is dropped by the driver.
> Wouldn't it be more correct to netif_tx_stop_queue() so that packet
> drops are performed by the overlying traffic control code?
>=20
> Of course this is not very likely in virtual environments but as soon
> as any real network hop is involved it could be important.
>=20
> (I also had a look on some two year old version of tun.c. There
> queue/tx stopping was done correctly.)

You should ask Michael S. Tsirkin, as he removed the flow control
in commit 5d097109257c03a71845729f8db6b5770c4bbedc
(tun: only queue packets on device)
