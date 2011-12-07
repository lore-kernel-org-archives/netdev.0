From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: don't
 munge MAC address from platform data
Date: Wed, 7 Dec 2011 16:57:03 +0800
Message-ID: <20111207085702.GE5550@S2100-06.ap.freescale.net>
References: <cover.1323163127.git.LW@KARO-electronics.de>
 <55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323163127.git.LW@KARO-electronics.de>
 <20111206124857.GB14048@sapphire.tkos.co.il>
 <20190.7244.156557.313315@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Baruch Siach <baruch@tkos.co.il>, <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20190.7244.156557.313315@ipc1.ka-ro>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 06, 2011 at 02:44:44PM +0100, Lothar Wa=DFmann wrote:
> Hi,
>=20
> Baruch Siach writes:
> > Hi Lothar,
> >=20
> > On Tue, Dec 06, 2011 at 11:27:13AM +0100, Lothar Wa=DFmann wrote:
> > > When the MAC address is supplied via platform_data it should be O=
K as
> > > it is and should not be modified in case of a dual FEC setup.
> > > Also copying the MAC from platform_data to the single 'macaddr'
> > > variable will overwrite the MAC for the first interface in case o=
f a
> > > dual FEC setup.
> > >=20
> > > Signed-off-by: Lothar Wa=DFmann <LW@KARO-electronics.de>
> > > ---
> > >  drivers/net/ethernet/freescale/fec.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > >=20
> > > diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/e=
thernet/freescale/fec.c
> > > index e2b5ce6..11534b9 100644
> > > --- a/drivers/net/ethernet/freescale/fec.c
> > > +++ b/drivers/net/ethernet/freescale/fec.c
> > > @@ -818,7 +818,7 @@ static void __inline__ fec_get_mac(struct net=
_device *ndev)
> > >  			iap =3D (unsigned char *)FEC_FLASHMAC;
> > >  #else
> > >  		if (pdata)
> > > -			memcpy(iap, pdata->mac, ETH_ALEN);
> > > +			iap =3D (unsigned char *)&pdata->mac;
> >=20
> > Since pdata might point to __initdata struct, you must hold a copy =
of its=20
> > content.
> >=20

As iap will anyway be copied to ndev->dev_addr after that, it may still
be fine to take this patch, for obviously for different reason.

> No. platform_data must be present during the life time of a driver
> using it and thus must never be __initdata!
>=20
Then we need to fix a lot of imx/mxc platform codes, mach-mx28evk.c
is the one for this case.

--=20
Regards,
Shawn
