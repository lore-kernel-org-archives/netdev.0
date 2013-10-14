From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: [PATCH] staging: octeon-ethernet: trivial: Avoid OOPS if phydev
 is not set
Date: Mon, 14 Oct 2013 21:39:06 +0300
Message-ID: <20131014183906.GA4260@blackmetal.musicnaut.iki.fi>
References: <1381690794.2848.11.camel@alpha.Speedport_W723_V_Typ_A_1_00_098>
 <20131013212810.GA15167@kroah.com>
 <20131014101051.GH6192@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@linuxfoundation.org>, support@caviumnetworks.com,
	netdev@vger.kernel.org, driverdev-devel@linuxdriverproject.org,
	Sebastian =?iso-8859-1?Q?P=F6hn?= <sebastian.poehn@gmail.com>,
	David Daney <david.daney@cavium.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from filtteri6.pp.htv.fi ([213.243.153.189]:37884 "EHLO
	filtteri6.pp.htv.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab3JNSjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 14:39:15 -0400
Content-Disposition: inline
In-Reply-To: <20131014101051.GH6192@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Oct 14, 2013 at 01:10:51PM +0300, Dan Carpenter wrote:
> On Sun, Oct 13, 2013 at 02:28:10PM -0700, Greg KH wrote:
> > On Sun, Oct 13, 2013 at 08:59:54PM +0200, Sebastian P=F6hn wrote:
> > > A zero pointer deref on priv->phydev->link was causing oops on ou=
r systems.
> > > Might be related to improper configuration but we should fail gra=
cefully here ;-)
> > >=20
> > > Signed-off-by: Sebastian Poehn <sebastian.poehn@googlemail.com>
> > >=20
> > > ---
> > >=20
> > > diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/sta=
ging/octeon/ethernet-mdio.c
> > > index 83b1030..bc8c503 100644
> > > --- a/drivers/staging/octeon/ethernet-mdio.c
> > > +++ b/drivers/staging/octeon/ethernet-mdio.c
> > > @@ -121,6 +121,9 @@ static void cvm_oct_adjust_link(struct net_de=
vice *dev)
> > >         struct octeon_ethernet *priv =3D netdev_priv(dev);
> > >         cvmx_helper_link_info_t link_info;
> > > =20
> > > +       if(!priv->phydev)
> > > +               return ;
> >=20
> > Please always run your patches through the scripts/checkpatch.pl to=
ol so
> > that maintainers don't have to point out the obvious coding syle er=
rors
> > by hand each time :)
>=20
> Also it's whitespace damaged and doesn't apply.
>=20
> >=20
> > Care to try again?
> >=20
> > Also, how was phydev NULL?  What was causing that?
>=20
> To me it looks like phydev is always NULL.

It's initialized in cvm_oct_phy_setup_device():

	priv->phydev =3D of_phy_connect(dev, phy_node, cvm_oct_adjust_link, 0,
				      PHY_INTERFACE_MODE_GMII);

So maybe there is a chance that cvm_oct_adjust_link() callback gets cal=
led
already before the function returns? Getting a copy of the original OOP=
S
report/crash dump could help to confirm this.

A.
