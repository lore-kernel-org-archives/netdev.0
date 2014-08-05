From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH v2 1/2] net: phy: Set the driver when registering an MDIO
 bus device
Date: Tue, 5 Aug 2014 07:43:32 -0300
Message-ID: <20140805104332.GA2704@arch.cereza>
References: <1406144852-7379-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1406144852-7379-2-git-send-email-ezequiel.garcia@free-electrons.com>
 <CAOMZO5CH0VystNR+qpXQFB_1f9=0DZzm7xxD5Fxy+uxFmAa-0Q@mail.gmail.com>
 <20140805032257.GD2167@dragon>
 <53E05702.9000007@gmail.com>
 <20140805044137.GE2167@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Fabio Estevam <festevam@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Marek =?utf-8?B?VmHFoXV0?= <marex@denx.de>,
	Sascha Hauer <kernel@pengutronix.de>,
	Russell King <linux@arm.linux.org.uk>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:60033 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754366AbaHEKor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 06:44:47 -0400
Content-Disposition: inline
In-Reply-To: <20140805044137.GE2167@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Shawn,

On 05 Aug 12:41 PM, Shawn Guo wrote:
> On Mon, Aug 04, 2014 at 09:01:06PM -0700, Florian Fainelli wrote:
> > On 08/04/14 20:22, Shawn Guo wrote:
> > >On Mon, Aug 04, 2014 at 11:55:22PM -0300, Fabio Estevam wrote:
> > >>Hi Ezequiel,
> > >>
> > >>On Wed, Jul 23, 2014 at 4:47 PM, Ezequiel Garcia
> > >><ezequiel.garcia@free-electrons.com> wrote:
> > >>>mdiobus_register() registers a device which is already bound to =
a driver.
> > >>>Hence, the driver pointer should be set properly in order to tra=
ck down
> > >>>the driver associated to the MDIO bus.
> > >>>
> > >>>This will be used to allow ethernet driver to pin down a MDIO bu=
s driver,
> > >>>preventing it from being unloaded while the PHY device is runnin=
g.
> > >>>
> > >>>Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> > >>>Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> > >>>Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.c=
om>
> > >>>---
> > >>>  drivers/net/phy/mdio_bus.c | 1 +
> > >>>  1 file changed, 1 insertion(+)
> > >>>
> > >>>diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_b=
us.c
> > >>>index 4eaadcf..203651e 100644
> > >>>--- a/drivers/net/phy/mdio_bus.c
> > >>>+++ b/drivers/net/phy/mdio_bus.c
> > >>>@@ -255,6 +255,7 @@ int mdiobus_register(struct mii_bus *bus)
> > >>>
> > >>>         bus->dev.parent =3D bus->parent;
> > >>>         bus->dev.class =3D &mdio_bus_class;
> > >>>+       bus->dev.driver =3D bus->parent->driver;
> > >>>         bus->dev.groups =3D NULL;
> > >>>         dev_set_name(&bus->dev, "%s", bus->id);
> > >>
> > >>This patches causes the following regression in 3.16 (tested on m=
x5/mx6):
> > >
> > >The change will trigger a device_suspend() call on mii_bus device =
with
> > >the pm suspend/resume callbacks being fec driver ones, since
> > >bus->parent->driver points to fec driver.
> > >
> > >So net result is fec_suspend() will be called twice during suspend=
, once
> > >in mii_bus device context and the other in fec device context.  In=
 fec
> > >context, it works just fine.  And the issue we're seeing is from m=
ii_bus
> > >device context, where the driver_data of the device is invalid.
> > >
> > >I do not think fec_suspend() should be called in mii_bus device co=
ntext.
> >=20
> > Right, that does not sound like a good thing to do. Does it work if
> > you call pm_suspend_ignore_children() either in the FEC driver or i=
n
> > mdiobus_register()?
>=20
> No, it doesn't stop fec_suspend() being called from mii_bus device
> context.
>=20
> >=20
> > I am not exactly sure what the best solution looks like at this poi=
nt
>=20
> Let's see if Ezequiel has any idea, but otherwise we should probably
> revert the patch for 3.16 stable.
>=20

Indeed, this commit should be reverted.

Sorry for the crap,
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
