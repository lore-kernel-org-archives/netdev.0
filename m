From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: fix headroom expansion code
Date: Fri, 27 Mar 2009 01:11:00 -0700 (PDT)
Message-ID: <20090327.011100.27558565.davem@davemloft.net>
References: <2a27d3730903262126v1a0282a5u6c8ee234dff8708d@mail.gmail.com>
	<20090327.003926.134928961.davem@davemloft.net>
	<2a27d3730903270106k71f01c12mf468d768f660baf7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42574
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751373AbZC0ILN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2009 04:11:13 -0400
In-Reply-To: <2a27d3730903270106k71f01c12mf468d768f660baf7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Li Yang <leoli@freescale.com>
Date: Fri, 27 Mar 2009 16:06:27 +0800

> On Fri, Mar 27, 2009 at 3:39 PM, David Miller <davem@davemloft.net> w=
rote:
> > From: Li Yang <leoli@freescale.com>
> > Date: Fri, 27 Mar 2009 12:26:33 +0800
> >
> >> We have legacy devices without the offloading feature. =A0And we c=
an
> >> even turn off the IP checksum offloading at runtime. =A0Your code =
will
> >> cause unnecessary realloc for these cases.
> >>
> >> I can propose a new patch to fix the pointer problem and add more
> >> error handling.
> >
> > I'm applying Stephen's patch for now, please send any improvements
> > relative to that.
>=20
> Ok.
>=20
> However is it ok to use kfree() instead of kfree_skb() in Stephen's p=
atch?
>=20
> +               skb_new =3D skb_realloc_headroom(skb, GMAC_FCB_LEN);
> +               if (!skb_new) {
> +                       dev->stats.tx_errors++;
> +                       kfree(skb);
> +                       return NETDEV_TX_OK;
> +               }

I'll fix this, thanks for noticing.
