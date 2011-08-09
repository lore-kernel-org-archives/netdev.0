From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gianfar.c null pointer deref in gfar_start_xmit().
Date: Tue, 09 Aug 2011 09:10:13 +0200
Message-ID: <1312873813.2531.54.camel@edumazet-laptop>
References: <20110803024438.GH4926@sgi.com>  <20110809065407.GF3709@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43142 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801Ab1HIHKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 03:10:20 -0400
Received: by wyg24 with SMTP id 24so148677wyg.19
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 00:10:19 -0700 (PDT)
In-Reply-To: <20110809065407.GF3709@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 ao=C3=BBt 2011 =C3=A0 01:54 -0500, Robin Holt a =C3=A9crit =
:
> On Tue, Aug 02, 2011 at 09:44:38PM -0500, Robin Holt wrote:
> >=20
> > While using the v3.0 kernel on a Freescale P1010RDB with 3 minor pa=
tches
> > (None which affect gianfar.c), I get a NULL pointer deref at:
> >=20
> > static int gfar_start_xmit(struct sk_buff *skb, struct net_device *=
dev)
> > {
> > ...
> > 	regs =3D tx_queue->grp->regs;
> >=20
> > I put a BUG_ON(tx_queue->grp) just before this line and it did trip=
=2E
> > I have not looked at this any more than that.
> >=20
> > Any suggestions would be welcome.   To reproduce, all I need to do =
is
> > a few sequences of pings.
>=20
> I was able to reproduce this with the net-next-2.6 kernel as well.
>=20

This driver incorrectly assumes a non dense txqueue array is possible
for a netdev, but its not true.

In the meantime, you could force it to use one tx_queue only.

tx_queues =3D (u32 *)of_get_property(np, "fsl,num_tx_queues", NULL);
num_tx_qs =3D tx_queues ? *tx_queues : 1;




