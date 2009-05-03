From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] powerpc: convert mace to netdev_ops
Date: Sun, 03 May 2009 14:15:24 -0700 (PDT)
Message-ID: <20090503.141524.253766195.davem@davemloft.net>
References: <20090427121633.GA29608@ime.usp.br>
	<20090427.054258.16622932.davem@davemloft.net>
	<20090503114820.GA14926@ime.usp.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, paulus@samba.org
To: rbrito@ime.usp.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49668
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754232AbZECVPa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 May 2009 17:15:30 -0400
In-Reply-To: <20090503114820.GA14926@ime.usp.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rog=E9rio Brito <rbrito@ime.usp.br>
Date: Sun, 3 May 2009 08:48:20 -0300

> I hope that this version is a slightly better fix to convert mace to
> netdev_ops.
>=20
> This is against this morning's net-2.6 tree.
>=20
> Signed-off-by: Rog=E9rio Brito <rbrito@ime.usp.br>

I'll apply this, thanks!  I made one change however.

> @@ -798,6 +807,13 @@ static irqreturn_t mace_interrupt(int irq, void =
*dev_id)
>      return IRQ_HANDLED;
>  }
> =20
> +/*
> + * In the following, the parameter "data" is treated like a pointer,
> + * which is probably OK for 32 bit arches, but not for 64.
> + *
> + * (Are mace's found on any newer machines??) -- rbrito
> + *
> + */
>  static void mace_tx_timeout(unsigned long data)
>  {
>      struct net_device *dev =3D (struct net_device *) data;

I left this new comment out, as this is a common idiom (passing opaque
data as an 'unsigned long' argument to a callback) and casting it to a
pointer.

It also works perfectly fine on all 32-bit and 64-bit platforms.
