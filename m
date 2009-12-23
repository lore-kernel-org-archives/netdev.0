From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: min_t/max_t confusion in tcp_select_initial_window()?
Date: Wed, 23 Dec 2009 13:15:26 -0800 (PST)
Message-ID: <20091223.131526.193724825.davem@davemloft.net>
References: <4B3179B8.5000403@gmail.com>
	<20091222.194747.193724694.davem@davemloft.net>
	<alpine.DEB.2.00.0912232140500.10866@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43920
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751165AbZLWVPZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 16:15:25 -0500
In-Reply-To: <alpine.DEB.2.00.0912232140500.10866@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 23 Dec 2009 21:45:57 +0200 (EET)

> On Tue, 22 Dec 2009, David Miller wrote:
>=20
>> From: Roel Kluin <roel.kluin@gmail.com>
>> Date: Wed, 23 Dec 2009 03:00:24 +0100
>>=20
>> > I could be confused, but in net/ipv4/tcp_output.c:217:
>> >=20
>> >                 space =3D max_t(u32, sysctl_tcp_rmem[2], sysctl_rm=
em_max);
>> >                 space =3D min_t(u32, space, *window_clamp);
>> > ------------------------^^^^^
 ...
>=20
> I don't understand how window_clamp line could be changed to max_t.
> ...I guess min in both would seem the most reasonable one?

Nope, the first one must be max.  Since I'm pretty sure we let the
dynamic RX buffer resizing exceed sysctl_rmem_max if necessary.

And that's what is controlled by sysctl_tcp_rmem[2]
