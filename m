From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/3] mlx4_en: TX ring size default to 1024
Date: Sat, 25 Feb 2012 09:22:40 +0100
Message-ID: <1330158160.2462.37.camel@edumazet-laptop>
References: <4F46404D.10509@mellanox.co.il>
	 <20120223.144541.1354349294973443529.davem@davemloft.net>
	 <953B660C027164448AE903364AC447D2618B8768@MTLDAG02.mtl.com>
	 <1330114654.2596.3.camel@edumazet-laptop>
	 <20120225015122.a7419f74.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49685 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754607Ab2BYIWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Feb 2012 03:22:45 -0500
Received: by wgbdr13 with SMTP id dr13so339425wgb.1
        for <netdev@vger.kernel.org>; Sat, 25 Feb 2012 00:22:44 -0800 (PST)
In-Reply-To: <20120225015122.a7419f74.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 25 f=C3=A9vrier 2012 =C3=A0 01:51 -0500, Bill Fink a =C3=A9cr=
it :

> For a GigE NIC with a typical ring size of 256, the serialization del=
ay
> for 256 1500 byte packets is:
>=20
> 	1500*8*256/10^9 =3D ~3.1 msec
>=20
> For a 10-GigE NIC with a ring size of 1024, the serialization delay
> for 1024 1500 byte packets is:
>=20
> 	1500*8*1024/10^10 =3D ~1.2 msec
>=20
> So it's not immediately clear that a ring size of 1024 is unreasonabl=
e
> for 10-GigE.
>=20

Its clear when you take into account packets of 64Kbytes (TSO)

With current hardware and state of linux software, you dont need anymor=
e
very big NIC queues since they bring known drawbacks.

It was true in the past with UP and some timer handlers that could hog
cpu for long periods of time, and when TSO didnt exist.

Hopefully all these cpu hogs are not running in softirq handlers
anymore.

If your workload needs more than ~500 slots, then something is wrong
elsewhere and should be fixed. No more workarounds please.

Now BQL (Byte Queue Limits) is available, a driver should implement it
first before considering big TX rings. Thats a 20 minutes change.
