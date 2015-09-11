From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC v2 net-next 1/4] phylib: Add phy_set_max_speed helper
Date: Fri, 11 Sep 2015 13:30:11 +0900
Message-ID: <20150911043011.GA20882@verge.net.au>
References: <1441936878-18290-1-git-send-email-horms+renesas@verge.net.au>
 <1441936878-18290-2-git-send-email-horms+renesas@verge.net.au>
 <55F2552A.1010509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55F2552A.1010509@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 10, 2015 at 09:14:34PM -0700, Florian Fainelli wrote:
> Le 09/10/15 19:01, Simon Horman a =C3=A9crit :
> > Add a helper to allow ethernet drivers to limit the speed of a phy
> > (that they are attached to).
> >=20
> > This mainly involves factoring out the business-end of
> > of_set_phy_supported() and exporting a new symbol.
> >=20
> > This code seems to be open coded in several places, in several diff=
erent
> > variants.
> >=20
> > This code is envisaged this will be used in situations where settin=
g
> > the "max-speed" property is not appropriate, e.g. because the maxim=
um
> > speed is not a property of the phy hardware.
>=20
> This looks good to me, one minor comment, see below:
>=20
> >=20
> > Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> >=20
> > ---
> >=20
> > v2
> > * First post
> > ---
> >  drivers/net/phy/phy_device.c | 52 ++++++++++++++++++++++++++++----=
------------
> >  include/linux/phy.h          |  1 +
> >  2 files changed, 34 insertions(+), 19 deletions(-)
> >=20
> > diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_dev=
ice.c
> > index c0f211127274..d9a020095972 100644
> > --- a/drivers/net/phy/phy_device.c
> > +++ b/drivers/net/phy/phy_device.c
> > @@ -1205,6 +1205,37 @@ static int gen10g_resume(struct phy_device *=
phydev)
> >  	return 0;
> >  }
> > =20
> > +static void __set_phy_supported(struct phy_device *phydev, u32 max=
_speed)
> > +{
> > +	if (!IS_ENABLED(CONFIG_OF_MDIO))
> > +		return;
>=20
> I think that part should be moved to of_set_phy_supported(), since yo=
ur
> are exporting phy_set_max_speed() which should therefore be available
> regardless of whether Device Tree is used.

Yes of course, silly me.

> While you are it, it might be nice to either warn or return -ENOTSUPP=
 if
> the speed does not match 10, 100 or 1000, but that might be worth a
> second patch.

Sure, that sounds reasonable.
