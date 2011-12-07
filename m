From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: preserve
 MII/RMII setting in fec_stop()
Date: Wed, 7 Dec 2011 11:49:09 +0100
Message-ID: <20191.17573.87285.411253@ipc1.ka-ro>
References: <cover.1323163127.git.LW@KARO-electronics.de>
	<d6f4de9e4cfb393754b42815a2ef1a59c96eab83.1323163127.git.LW@KARO-electronics.de>
	<20111207094146.GG5550@S2100-06.ap.freescale.net>
	<20191.17172.493079.722098@ipc1.ka-ro>
	<20111207105816.GH5550@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Shawn Guo <shawn.guo@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111207105816.GH5550@S2100-06.ap.freescale.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Shawn Guo writes:
> On Wed, Dec 07, 2011 at 11:42:28AM +0100, Lothar Wa=C3=9Fmann wrote:
> > Hi,
> >=20
> > Shawn Guo writes:
> > > On Tue, Dec 06, 2011 at 11:27:14AM +0100, Lothar Wa=C3=9Fmann wro=
te:
> > > > Additionally to setting the ETHER_EN bit in FEC_ECNTRL the MII/=
RMII
> > > > setting in FEC_R_CNTRL needs to be preserved to keep the MII in=
terface
> > >=20
> > > s/MII/RMII?  From what I see from imx28 and imx6q RM, the reset s=
tate
> > > for this setting is MII mode.
> > >=20
> > > > functional.
> > > >=20
> > > > Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> > > > ---
> > > >  drivers/net/ethernet/freescale/fec.c |    5 ++++-
> > > >  1 files changed, 4 insertions(+), 1 deletions(-)
> > >=20
> > > I assume this is fixing a problem you are seeing on imx28 only.
> > > Do you see the problem on imx53/51?
> > >=20
> > No. i.MX53 uses the RMII gasket which is not affected by resetting =
the
> > controller. And imMX51 does not support RMII at all.
> >=20
> > > >=20
> > > > diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net=
/ethernet/freescale/fec.c
> > > > index 11534b9..ab0afb5 100644
> > > > --- a/drivers/net/ethernet/freescale/fec.c
> > > > +++ b/drivers/net/ethernet/freescale/fec.c
> > > > @@ -515,6 +515,7 @@ fec_stop(struct net_device *ndev)
> > > >  	struct fec_enet_private *fep =3D netdev_priv(ndev);
> > > >  	const struct platform_device_id *id_entry =3D
> > > >  				platform_get_device_id(fep->pdev);
> > > > +	u32 rmii_mode =3D readl(fep->hwp + FEC_R_CNTRL) & (1 << 8);
> > >=20
> > > This bit is only available on ENET (imx28 and imx6q).  Do we want=
 to
> > > do the same thing for FEC (imx25/27/35/51/53)?
> > >=20
> > No. AFAICT that's not necessary there.
> >=20
> So you need to check it's actually running on ENET before accessing
> the bit.
>=20
That's done in the place where the register is being written:
|	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
|		writel(2, fep->hwp + FEC_ECNTRL);
|		writel(rmii_mode, fep->hwp + FEC_R_CNTRL);
|	}

We could save one register read by doing the check also for the read,
but that would further complicate the code.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
