From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: softirqs are invoked while bottom halves are masked
Date: Wed, 13 Jul 2011 09:38:53 +0200
Message-ID: <1310542733.2634.17.camel@edumazet-laptop>
References: <1310465411.3314.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAMJ=MEeC1hoqufs7AfFRn3yJoC8mdw7v+14N+7e=wQuJefm4_w@mail.gmail.com>
	 <20110712.050817.1253941735409335652.davem@davemloft.net>
	 <20110712.051316.1963034055315982365.davem@davemloft.net>
	 <CAAXf6LXddZUHEz738DDTi-XqENRYT7dTODw+1C4RTYsCdyro7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ronny.meeus@gmail.com,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com
To: Thomas De Schampheleire <patrickdepinguin+linuxppc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41125 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965002Ab1GMHi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 03:38:59 -0400
Received: by wwe5 with SMTP id 5so5700274wwe.1
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 00:38:58 -0700 (PDT)
In-Reply-To: <CAAXf6LXddZUHEz738DDTi-XqENRYT7dTODw+1C4RTYsCdyro7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 juillet 2011 =C3=A0 09:20 +0200, Thomas De Schampheleire=
 a
=C3=A9crit :

> I just want to mention that, although you seem to think that we
> shouldn't have created this thread in the first place, your and Eric'=
s
> remarks have actually helped us in identifying the problem and
> increasing our understanding.
>=20

Thread was fine IMHO, but should have mentioned the context of "non
standard linux-2.6 or net-next-2.6 trees"

I would like to mention NETIF_F_LLTX existence.

While being marked deprecated, it allows a lockless tx path :

The device transmit handler can then perform custom actions, including
its own locking if needed.

If the user wants a specific Qdisc setup (instead of a no qdisc one), i=
t
still can.

veth, loopback, dummy, macvlan & bond devices use NETIF_F_LLTX for
example.

But ndo_start_xmit() must always be called with BH disabled.



