From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: don't
 munge MAC address from platform data
Date: Tue, 6 Dec 2011 14:44:44 +0100
Message-ID: <20190.7244.156557.313315@ipc1.ka-ro>
References: <cover.1323163127.git.LW@KARO-electronics.de>
	<55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323163127.git.LW@KARO-electronics.de>
	<20111206124857.GB14048@sapphire.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Shawn Guo <shawn.guo@linaro.org>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111206124857.GB14048@sapphire.tkos.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Baruch Siach writes:
> Hi Lothar,
>=20
> On Tue, Dec 06, 2011 at 11:27:13AM +0100, Lothar Wa=C3=9Fmann wrote:
> > When the MAC address is supplied via platform_data it should be OK =
as
> > it is and should not be modified in case of a dual FEC setup.
> > Also copying the MAC from platform_data to the single 'macaddr'
> > variable will overwrite the MAC for the first interface in case of =
a
> > dual FEC setup.
> >=20
> > Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
> > ---
> >  drivers/net/ethernet/freescale/fec.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/eth=
ernet/freescale/fec.c
> > index e2b5ce6..11534b9 100644
> > --- a/drivers/net/ethernet/freescale/fec.c
> > +++ b/drivers/net/ethernet/freescale/fec.c
> > @@ -818,7 +818,7 @@ static void __inline__ fec_get_mac(struct net_d=
evice *ndev)
> >  			iap =3D (unsigned char *)FEC_FLASHMAC;
> >  #else
> >  		if (pdata)
> > -			memcpy(iap, pdata->mac, ETH_ALEN);
> > +			iap =3D (unsigned char *)&pdata->mac;
>=20
> Since pdata might point to __initdata struct, you must hold a copy of=
 its=20
> content.
>=20
No. platform_data must be present during the life time of a driver
using it and thus must never be __initdata!


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
