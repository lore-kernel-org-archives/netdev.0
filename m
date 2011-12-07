From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: fix the
 .remove code
Date: Wed, 7 Dec 2011 21:43:36 +0800
Message-ID: <20111207134336.GS5550@S2100-06.ap.freescale.net>
References: <cover.1323163127.git.LW@KARO-electronics.de>
 <04c11563fee748562d7b53d5e5b3c5cf37fef200.1323163127.git.LW@KARO-electronics.de>
 <20111207132828.GQ5550@S2100-06.ap.freescale.net>
 <20191.27018.478290.890636@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Shawn Guo <shawn.guo@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20191.27018.478290.890636@ipc1.ka-ro>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2011 at 02:26:34PM +0100, Lothar Wa=DFmann wrote:
> Hi,
>=20
> Shawn Guo writes:
> > On Tue, Dec 06, 2011 at 11:27:15AM +0100, Lothar Wa=DFmann wrote:
> > > The .remove code is broken in several ways.
> > >  - mdiobus_unregister() is called twice for the same object in ca=
se of dual FEC
> > >  - phy_disconnect() is being called when the PHY is already disco=
nnected
> > >  - the requested IRQ(s) are not freed
> > >  - fec_stop() is being called with the inteface already stopped
> > >=20
> > >  All of those lead to kernel crashes if the remove function is ac=
tually used.
> > >=20
> > > Signed-off-by: Lothar Wa=DFmann <LW@KARO-electronics.de>
> > > ---
> > >  drivers/net/ethernet/freescale/fec.c |   30 ++++++++++++++++++++=
+---------
> > >  1 files changed, 21 insertions(+), 9 deletions(-)
> > >=20
> > > diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/e=
thernet/freescale/fec.c
> > > index ab0afb5..70ec7ec 100644
> > > --- a/drivers/net/ethernet/freescale/fec.c
> > > +++ b/drivers/net/ethernet/freescale/fec.c
> > > @@ -235,6 +235,7 @@ struct fec_enet_private {
> > > =20
> > >  	/* Phylib and MDIO interface */
> > >  	struct	mii_bus *mii_bus;
> > > +	int	mii_cnt;
> > >  	struct	phy_device *phy_dev;
> > >  	int	mii_timeout;
> > >  	uint	phy_speed;
> > > @@ -1040,8 +1041,12 @@ static int fec_enet_mii_init(struct platfo=
rm_device *pdev)
> > >  	 */
> > >  	if ((id_entry->driver_data & FEC_QUIRK_ENET_MAC) && pdev->id > =
0) {
> > >  		/* fec1 uses fec0 mii_bus */
> > > -		fep->mii_bus =3D fec0_mii_bus;
> > > -		return 0;
> > > +		if (fep->mii_cnt && fec0_mii_bus) {
> >=20
> > This seems broken.  The second fec has its own fep and fep->mii_cnt=
 is
> > always 0 here.
> >=20
> I already noticed that myself.
>=20
With a quick fix here, the last two patches:=20

Tested-by: Shawn Guo <shawn.guo@linaro.org>

--=20
Regards,
Shawn
