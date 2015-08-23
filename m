From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/9] dsa: mv88e6xxx: Set the RGMII delay based
 on phy interface
Date: Sun, 23 Aug 2015 23:10:14 +0200
Message-ID: <20150823211014.GC20710@lunn.ch>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
 <1440323220-20438-7-git-send-email-andrew@lunn.ch>
 <55DA1471.2080905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38237 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752759AbbHWVRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 17:17:39 -0400
Content-Disposition: inline
In-Reply-To: <55DA1471.2080905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 23, 2015 at 11:44:01AM -0700, Florian Fainelli wrote:
> Le 08/23/15 02:46, Andrew Lunn a =E9crit :
> > Some Marvell switches allow the RGMII Rx and Tx clock to be delayed
> > when the port is using RGMII. Have the adjust_link function look at
> > the phy interface type and enable this delay as requested.
> >=20
> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> > ---
> >  drivers/net/dsa/mv88e6xxx.c | 10 ++++++++++
> >  drivers/net/dsa/mv88e6xxx.h |  2 ++
> >  2 files changed, 12 insertions(+)
> >=20
> > diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xx=
x.c
> > index 7901db6503b4..f5af368751b2 100644
> > --- a/drivers/net/dsa/mv88e6xxx.c
> > +++ b/drivers/net/dsa/mv88e6xxx.c
> > @@ -612,6 +612,16 @@ void mv88e6xxx_adjust_link(struct dsa_switch *=
ds, int port,
> >  	if (phydev->duplex =3D=3D DUPLEX_FULL)
> >  		reg |=3D PORT_PCS_CTRL_DUPLEX_FULL;
> > =20
> > +	if ((mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds)) &&
> > +	    (port >=3D ps->num_ports - 2)) {
>=20
> Are we positive that the last two ports of a switch are going to be
> RGMII capable or is this something that should be moved to Device Tre=
e /
> platform data to account for different switch families? Maybe having =
a
> bitmask of RGMII capable ports stored in "ps" would be good enough?

Hi Florian

=46or these two families, this is correct. And it is a property of the
switch, not the board, so should not be in DT. Other families are
different. Older ones are Fast Ethernet only. Some don't have any
RGMII ports, etc. It could be with time, this condition gets messy, at
which point, a bitmask in ps would make sense. But is it justified
now?

Thanks
      Andrew
