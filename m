From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 11:50:24 +0200
Message-ID: <1309859424.2271.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110704.212014.236340473910292460.davem@davemloft.net>
	 <1309846875.2720.43.camel@edumazet-laptop>
	 <20110705.004640.2280047904273455681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37759 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764Ab1GEJuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 05:50:39 -0400
Received: by wyg8 with SMTP id 8so3865530wyg.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 02:50:38 -0700 (PDT)
In-Reply-To: <20110705.004640.2280047904273455681.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 00:46 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 05 Jul 2011 08:21:15 +0200
>=20
> > rxhash is 0 unless skb_get_rxhash() was called, or some NIC set it =
in RX
> > path.
>=20
> CONFIG_RPS is effectively on all the time for SMP builds.
>=20
> If you want to make it a hard enable in that situation,
> I fully support such a change. :-)
>=20

CONFIG_RPS can be on, but skb->rxhash still 0 by default on tg3 for
example.

get_rps_cpu() wont call skb_get_rxhash() if RPS/RFS is not setup on
rxqueue (rps_map =3D=3D NULL and rps_flow_table =3D NULL)

You really have to call skb_get_rxhash() yourself to make sure rxhash i=
s
set (if not already done)

Just replace   skb->rxhash by skb_get_rxhash(skb)



