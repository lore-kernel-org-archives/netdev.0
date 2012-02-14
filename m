From: Jean Delvare <jdelvare@suse.de>
Subject: Re: bonding with 3c59x driver
Date: Tue, 14 Feb 2012 13:50:57 +0100
Message-ID: <201202141350.57657.jdelvare@suse.de>
References: <201202132253.16496.jdelvare@suse.de> <20120214110604.GI32155@v3-1054> <1329218017.2336.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33103 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756506Ab2BNMu7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 07:50:59 -0500
In-Reply-To: <1329218017.2336.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric, Steffen,

On Tuesday 14 February 2012 12:13:37 pm Eric Dumazet wrote:
> Le mardi 14 f=C3=A9vrier 2012 =C3=A0 12:06 +0100, Steffen Klassert a =
=C3=A9crit :
> > On Tue, Feb 14, 2012 at 11:22:10AM +0100, Jean Delvare wrote:
> > > Well I am still curious why the 3c59x driver has such slow
> > > polling when other drivers I have been testing are able to report
> > > almost instantly when I remove a network cable. Could it be that
> > > other network chips generate an interrupt on cable removal and
> > > the 3com chips do not?
> >
> > Yes, at least some of the supported chips do not generate an
> > interrupt on cable removal, so we have to check for this with a
> > timer.

Too bad. I confirm I can't see the interrupt count increase when I=20
remove the network cable from my 3C905C (nor when I plug it back in),=20
but I was hopping this was a matter of enabling this event as an=20
interrupt source in the driver. If the hardware just can't do it then=20
this is hopeless. Back in the days I used to consider the 3C905 as the=20
best fast Ethernet cards around, apparently I was horribly wrong.

Thanks for explaining anyway.

> We could have a 5 sec timer in case device is a slave.
>=20
> diff --git a/drivers/net/ethernet/3com/3c59x.c
>  b/drivers/net/ethernet/3com/3c59x.c index 1282f04..e463d10 100644
> --- a/drivers/net/ethernet/3com/3c59x.c
> +++ b/drivers/net/ethernet/3com/3c59x.c
> @@ -1841,7 +1841,7 @@ vortex_timer(unsigned long data)
>  		ok =3D 1;
>  	}
>=20
> -	if (!netif_carrier_ok(dev))
> +	if (dev->flags & IFF_SLAVE || !netif_carrier_ok(dev))
>  		next_tick =3D 5*HZ;
>=20
>  	if (vp->medialock)

Yes I think this makes a lot of sense. If you send this upstream you ca=
n=20
add:

Acked-by: Jean Delvare <jdelvare@suse.de>

--=20
Jean Delvare
Suse L3
