From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/2 net-next] r6040: invoke phy_{start,stop} when appropriate
Date: Fri, 7 Oct 2011 14:13:51 +0200
Message-ID: <201110071413.51328.florian@openwrt.org>
References: <201110071136.22107.florian@openwrt.org> <1317983087.3207.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44430 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288Ab1JGMN5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 08:13:57 -0400
Received: by wwf22 with SMTP id 22so5823220wwf.1
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 05:13:56 -0700 (PDT)
In-Reply-To: <1317983087.3207.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 October 2011 12:24:47 Eric Dumazet wrote:
> Le vendredi 07 octobre 2011 =C3=A0 11:36 +0200, Florian Fainelli a =C3=
=A9crit :
> > Joe reported to me that right after a bring up of a r6040 interface
> > the ethtool output had no consistent output with respect to link du=
plex
> > and speed. Fix this by adding a missing phy_start call in r6040_up =
and
> > conversely a phy_stop call in r6040_down to properly initialize phy
> > states.
> >=20
> > Reported-by: Joe Chou <Joe.Chou@rdc.com.tw>
> > Signed-off-by: Florian Fainelli <florian@openwrt.org>
> > ---
> > diff --git a/drivers/net/ethernet/rdc/r6040.c
> > b/drivers/net/ethernet/rdc/r6040.c index 2bbadc0..a128c3d 100644
> > --- a/drivers/net/ethernet/rdc/r6040.c
> > +++ b/drivers/net/ethernet/rdc/r6040.c
> > @@ -470,6 +470,8 @@ static void r6040_down(struct net_device *dev)
> >=20
> >  	iowrite16(adrp[0], ioaddr + MID_0L);
> >  	iowrite16(adrp[1], ioaddr + MID_0M);
> >  	iowrite16(adrp[2], ioaddr + MID_0H);
> >=20
> > +
> > +	phy_stop(lp->phydev);
> >=20
> >  }
> > =20
> >  static int r6040_close(struct net_device *dev)
> >=20
> > @@ -727,6 +729,8 @@ static int r6040_up(struct net_device *dev)
> >=20
> >  	/* Initialize all MAC registers */
> >  	r6040_init_mac_regs(dev);
> >=20
> > +	phy_start(lp->phydev);
> > +
> >=20
> >  	return 0;
> > =20
> >  }
>=20
> You dont need to submit your patches twice (net and net-next)
>=20
> If its a bug fix, base your patch against net tree
>=20
> If its a new feature, against net-next

Allright, thanks for the tip. I just thought that would make it easier =
for=20
David to get this applied (especially after the drivers reorganization)=
=2E
--=20
=46lorian
