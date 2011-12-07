From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: don't
 munge MAC address from platform data
Date: Wed, 7 Dec 2011 09:47:38 +0100
Message-ID: <20191.10282.826634.821906@ipc1.ka-ro>
References: <cover.1323163127.git.LW@KARO-electronics.de>
	<55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323163127.git.LW@KARO-electronics.de>
	<20111206124857.GB14048@sapphire.tkos.co.il>
	<20190.7244.156557.313315@ipc1.ka-ro>
	<20111207085702.GE5550@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Baruch Siach <baruch@tkos.co.il>, <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111207085702.GE5550@S2100-06.ap.freescale.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Shawn Guo writes:
> On Tue, Dec 06, 2011 at 02:44:44PM +0100, Lothar Wa=C3=9Fmann wrote:
> > Hi,
> >=20
> > Baruch Siach writes:
> > > Hi Lothar,
> > >=20
> > > On Tue, Dec 06, 2011 at 11:27:13AM +0100, Lothar Wa=C3=9Fmann wro=
te:
> > > > When the MAC address is supplied via platform_data it should be=
 OK as
> > > > it is and should not be modified in case of a dual FEC setup.
> > > > Also copying the MAC from platform_data to the single 'macaddr'
> > > > variable will overwrite the MAC for the first interface in case=
 of a
> > > > dual FEC setup.
> > > >=20
> > > > Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> > > > ---
> > > >  drivers/net/ethernet/freescale/fec.c |    2 +-
> > > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > >=20
> > > > diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net=
/ethernet/freescale/fec.c
> > > > index e2b5ce6..11534b9 100644
> > > > --- a/drivers/net/ethernet/freescale/fec.c
> > > > +++ b/drivers/net/ethernet/freescale/fec.c
> > > > @@ -818,7 +818,7 @@ static void __inline__ fec_get_mac(struct n=
et_device *ndev)
> > > >  			iap =3D (unsigned char *)FEC_FLASHMAC;
> > > >  #else
> > > >  		if (pdata)
> > > > -			memcpy(iap, pdata->mac, ETH_ALEN);
> > > > +			iap =3D (unsigned char *)&pdata->mac;
> > >=20
> > > Since pdata might point to __initdata struct, you must hold a cop=
y of its=20
> > > content.
> > >=20
>=20
> As iap will anyway be copied to ndev->dev_addr after that, it may sti=
ll
> be fine to take this patch, for obviously for different reason.
>=20
> > No. platform_data must be present during the life time of a driver
> > using it and thus must never be __initdata!
> >=20
> Then we need to fix a lot of imx/mxc platform codes, mach-mx28evk.c
> is the one for this case.
>=20
Nope. The platform_data provided there is only a template that is
copied to kmalloc'ed memory by the mxs_add...() functions.

With actual platform_data in init memory no driver built as module
would work.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
