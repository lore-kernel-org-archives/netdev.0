From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Slow speed of tcp connections in a network namespace
Date: Sat, 29 Dec 2012 11:41:02 -0800
Message-ID: <1356810062.21409.4991.camel@edumazet-glaptop>
References: <20121229092417.GA4038@paralelels.com>
	 <1356789203.21409.3923.camel@edumazet-glaptop>
	 <20121229145030.GA7959@paralelels.com>
	 <1356802828.21409.4623.camel@edumazet-glaptop>
	 <1356807516.4102.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vvs@parallels.com,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:57237 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472Ab2L2TlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 14:41:05 -0500
Received: by mail-pa0-f50.google.com with SMTP id hz10so6575172pad.9
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 11:41:04 -0800 (PST)
In-Reply-To: <1356807516.4102.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-29 at 19:58 +0100, Eric Dumazet wrote:
> Le samedi 29 d=C3=A9cembre 2012 =C3=A0 09:40 -0800, Eric Dumazet a =C3=
=A9crit :
>=20
> >=20
> > Please post your new tcpdump then ;)
> >=20
> > also post "netstat -s" from root and test ns after your wgets
>=20
> Also try following bnx2 patch.
>=20
> It should help GRO / TCP coalesce
>=20
> bnx2 should be the last driver not using skb head_frag

And of course, you should make sure all your bnx2 interrupts are handle=
d
by the same cpu.

Or else, packets might be reordered because the way dev_forward_skb()
works.

(CPU X gets a bunch of packets from eth0, forward them via netif_rx() i=
n
the local CPU X queue, NAPI is ended on eth0)

CPU Y gets a bunch of packets from eth0, forward them via netif_rx() in
the local CPU Y queue.

CPU X and Y process their local queue in // -> packets are delivered Ou=
t
of order to TCP stack

Alternative is to setup RPS on your veth1 device, to force packets bein=
g
delivered/handled by a given cpu
