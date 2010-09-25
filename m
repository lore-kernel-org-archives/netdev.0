From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 -next] r8169: allocate with GFP_KERNEL flag when
 able to sleep
Date: Sat, 25 Sep 2010 11:12:25 +0200
Message-ID: <1285405945.2478.255.camel@edumazet-laptop>
References: <20100924222434.GA7743@electric-eye.fr.zoreil.com>
	 <20100924.223709.233700415.davem@davemloft.net>
	 <1285394797.2478.54.camel@edumazet-laptop>
	 <20100925.001300.193725148.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, sgruszka@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34972 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754448Ab0IYJMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 05:12:50 -0400
Received: by fxm3 with SMTP id 3so1123722fxm.19
        for <netdev@vger.kernel.org>; Sat, 25 Sep 2010 02:12:49 -0700 (PDT)
In-Reply-To: <20100925.001300.193725148.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 25 septembre 2010 =C3=A0 00:13 -0700, David Miller a =C3=A9cr=
it :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 25 Sep 2010 08:06:37 +0200
>=20
> > Patch solves the suspend/resume, probably, but as soon as we receiv=
e
> > trafic, we can hit the allocation error anyway...
>=20
> It allocates 1536 + N, where N can be NET_IP_ALIGN, or some small
> value like 8.
>=20
> This is in the same ballpark as what tg3 allocates for RX buffers.
>=20
> SLAB/SLUB/whatever just wants multi-order page allocations even
> for SKBs which are about this size.
>=20
> Furthermore, the sleeping allocations we do at ->open() time to
> allocate the entire RX ring all at once will buddy up a lot of
> pages and make 1-order allocs more likely.

Yes, I forgot this problem about SLUB (I ended using SLAB on servers
because of this order-3 problem on kmalloc(2048))

bnx2 uses GFP_KERNEL allocations at init time, but tg3 uses GFP_ATOMIC
(because tp->lock is held).

The r8169 current problem is its currently copying all incoming frames.
I guess nobody cares or noticed the performance drop.
(But commit c0cd884a is recent (2.6.34), this is not yet in
production...)




