From: Dong Aisheng <aisheng.dong@freescale.com>
Subject: Re: [PATCH 1/1] net: phylib: add error checking if no phy found
Date: Wed, 21 Mar 2012 19:45:17 +0800
Message-ID: <20120321114516.GC4905@shlinux2.ap.freescale.net>
References: <1331636302-18256-1-git-send-email-b29396@freescale.com>
 <4F5F5ABF.5030103@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dong Aisheng-B29396 <B29396@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Tabi Timur-B04825 <B04825@freescale.com>,
	"rdunlap@xenotime.net" <rdunlap@xenotime.net>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F5F5ABF.5030103@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 13, 2012 at 10:33:35PM +0800, Florian Fainelli wrote:
> Hi,
>=20
> Le 03/13/12 11:58, Dong Aisheng a =E9crit :
> > From: Dong Aisheng<dong.aisheng@linaro.org>
> >
> > Signed-off-by: Dong Aisheng<dong.aisheng@linaro.org>
> > ---
> >   drivers/net/phy/mdio_bus.c |   11 ++++++++++-
> >   1 files changed, 10 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.=
c
> > index 88cc5db..d8e044d 100644
> > --- a/drivers/net/phy/mdio_bus.c
> > +++ b/drivers/net/phy/mdio_bus.c
> > @@ -101,6 +101,7 @@ static struct class mdio_bus_class =3D {
> >   int mdiobus_register(struct mii_bus *bus)
> >   {
> >   	int i, err;
> > +	u32 phynum =3D 0;
> >
> >   	if (NULL =3D=3D bus || NULL =3D=3D bus->name ||
> >   			NULL =3D=3D bus->read ||
> > @@ -134,12 +135,20 @@ int mdiobus_register(struct mii_bus *bus)
> >   			if (IS_ERR(phydev)) {
> >   				err =3D PTR_ERR(phydev);
> >   				goto error;
> > +			} else if (phydev !=3D NULL) {
> > +				phynum++;
> >   			}
> >   		}
> >   	}
> >
> > +	if (!phynum) {
> > +		err =3D -ENODEV;
> > +		printk(KERN_ERR "%s: no phys found\n", bus->name);
> > +		goto error;
> > +	}
>=20
> I am not sure if this is a good idea to change it, especially if:
> - the MII bus probing is also done later (quite some drivers do this)
> - if we want to attach a fixed PHY because we could not probe one at=20
> registration time
>=20
You're correct.
It seems keep it as before is the right solution right now.
Thanks for the info.

Regards
Dong Aisheng
