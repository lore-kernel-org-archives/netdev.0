From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/7] net: stmmac: Parse FIFO sizes from feature registers
Date: Thu, 9 Mar 2017 20:41:04 +0100
Message-ID: <20170309194104.GC5554@ulmo.ba.sec>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-5-thierry.reding@gmail.com>
 <b74f9b19-4315-1349-88c0-b549a2f8ef5d@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="B4IIlcmfBL/1gGOG"
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <b74f9b19-4315-1349-88c0-b549a2f8ef5d-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--B4IIlcmfBL/1gGOG
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 02, 2017 at 03:09:11PM +0000, Joao Pinto wrote:
> Hi Thierry,
>=20
> =C3=80s 5:24 PM de 2/23/2017, Thierry Reding escreveu:
> > From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> >=20
> > New version of this core encode the FIFO sizes in one of the feature
> > registers. Use these sizes as default, but still allow device tree to
> > override them for backwards compatibility.
> >=20
> > Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> > ---
> >  drivers/net/ethernet/stmicro/stmmac/common.h      | 3 +++
> >  drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c  | 2 ++
> >  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 +++
> >  3 files changed, 8 insertions(+)
> >=20
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net=
/ethernet/stmicro/stmmac/common.h
> > index 144fe84e8a53..6ac653845d82 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> > +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> > @@ -324,6 +324,9 @@ struct dma_features {
> >  	unsigned int number_tx_queues;
> >  	/* Alternate (enhanced) DESC mode */
> >  	unsigned int enh_desc;
> > +	/* TX and RX FIFO sizes */
> > +	unsigned int tx_fifo_size;
> > +	unsigned int rx_fifo_size;
> >  };
> > =20
> >  /* GMAC TX FIFO is 8K, Rx FIFO is 16K */
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers=
/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> > index 377d1b44d4f2..8d249f3b34c8 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
> > @@ -296,6 +296,8 @@ static void dwmac4_get_hw_feature(void __iomem *ioa=
ddr,
> >  	hw_cap =3D readl(ioaddr + GMAC_HW_FEATURE1);
> >  	dma_cap->av =3D (hw_cap & GMAC_HW_FEAT_AVSEL) >> 20;
> >  	dma_cap->tsoen =3D (hw_cap & GMAC_HW_TSOEN) >> 18;
> > +	dma_cap->tx_fifo_size =3D 128 << ((hw_cap >> 6) & 0x1f);
> > +	dma_cap->rx_fifo_size =3D 128 << ((hw_cap >> 0) & 0x1f);
>=20
> I suggest you follow the way that has been done for other parameters:
>=20
> dma_cap->rx_fifo_size =3D (hw_cap & GMAC_HW_RXFIFOSIZE) >> 0; where
> GMAC_HW_RXFIFOSIZE is GENMASK(4, 0)
> dma_cap->tx_fifo_size =3D (hw_cap & GMAC_HW_TXFIFOSIZE) >> 6; where
> GMAC_HW_TXFIFOSIZE is GENMASK(10, 6)

Okay, can do.

> >  	/* MAC HW feature2 */
> >  	hw_cap =3D readl(ioaddr + GMAC_HW_FEATURE2);
> >  	/* TX and RX number of channels */
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
> > index d7387919bdb6..291e34f0ca94 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> > @@ -1281,6 +1281,9 @@ static void stmmac_dma_operation_mode(struct stmm=
ac_priv *priv)
> >  {
> >  	int rxfifosz =3D priv->plat->rx_fifo_size;
> > =20
> > +	if (rxfifosz =3D=3D 0)
> > +		rxfifosz =3D priv->dma_cap.rx_fifo_size;
> > +
> >  	if (priv->plat->force_thresh_dma_mode)
> >  		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc, rxfifosz);
> >  	else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
> >=20
>=20
> In my current patch for adding support for MTL in stmmac, I also had this
> approach (sizes comming from feature register and platform data) so nice =
to see
> it here, because I will be able to reutilize it in my future versions.
>=20
> There is only a slight twist that we have to pay attention to it. The RX =
and TX
> queue size configuration needs to be one the following values:
>=20
> FIFO_256 =3D 0x0,
> FIFO_512 =3D 0x1,
> FIFO_1k =3D 0x3,
> FIFO_2k =3D 0x7,
> FIFO_4k =3D 0xf,
> FIFO_8k =3D 0x1f,
> FIFO_16k =3D 0x3f,
> FIFO_32k =3D 0x7f
>=20
> These are the values you get from the features register, but are these the
> values that users will configure in "plat->rx_fifo_size"? From a quick gr=
ep you
> can see that users use real units:
>=20
> arch/arm/boot/dts/socfpga.dtsi:			rx-fifo-depth =3D <4096>;
> arch/arm/boot/dts/socfpga.dtsi:			rx-fifo-depth =3D <4096>;
> arch/arm/boot/dts/socfpga_arria10.dtsi:			rx-fifo-depth =3D <16384>;
> arch/arm/boot/dts/socfpga_arria10.dtsi:			rx-fifo-depth =3D <16384>;
> arch/arm/boot/dts/socfpga_arria10.dtsi:			rx-fifo-depth =3D <16384>;
> arch/arm/boot/dts/lpc18xx.dtsi:			rx-fifo-depth =3D <256>;
> arch/nios2/boot/dts/3c120_devboard.dts:				rx-fifo-depth =3D <8192>;
> arch/nios2/boot/dts/10m50_devboard.dts:			rx-fifo-depth =3D <8192>;
>=20
> So in order to have it configurable from platform and features register y=
ou need
> to convert the features values to "real" units and then in the end when y=
ou
> write to the DMA Op Mode you need to convert it back to the required valu=
es.

That's what the "128 << " part in dwmac4_get_hw_feature() does. As far
as I can tell, that's equivalent to dwmac4_get_real_fifo_sz() function
=66rom your patch, but it's more compact.

> You can check my patch here that already has this done:
> http://patchwork.ozlabs.org/patch/728566/

I see that there's a bit of overlap between that patch and this series.
How do you want to handle this? Do you want me to rebase on top of your
patch, or would you prefer this series to get merged first and rework
your patch on top of it?

Thanks,
Thierry

--B4IIlcmfBL/1gGOG
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljBr84ACgkQ3SOs138+
s6GZaw/+M4fyAb8wxdnN6UcLxhITOTUhpC+wQP3vvuWd9mJnHr5rbF51TEIWpZLb
S4JLHt3w90ymjDd5hrw2izwoQqzBicAk9embjN7c8I7ANIuntdVVnBHOL/z/pspD
hm69DCyW3ORk33st7bURrrCLkJfAnhnrfOj2FQfTzA7A3vjwtP0Or/a+KzWpBsDG
KPkheKK6YnrKZkhAIQrrsX2gBlHPgMtTrLkuQQB+izuvCxlm3N78NJ/JCT22PTH2
YotO3amk1D69jwTW+2gNWuG6BmgjTkj+foIPTyYMzhEJ3TPa3nZvX1UySs8ljCTm
y/QbH2Vjk8Tadm523r49oBCkdk0LFgQ+mcNpStAeM7OS296bfwoEpdectxlu1mDG
nQhCY5YtlNkZeX+ZW7rDlccLKug8dij+A0xK1i/bT84YEr/pD2zaCdV2I8SbUn4Y
A6Iy3roIGyD1FcJoei/vzGVXeo7i4BU3iMwn3qz8jrYlAu5Q7jjIsaaIMeM6NPnt
NdcAIIAiq3etbT2LSo3jLZR4fl6NMcJJ5lutdaJeLomgw1JY6r8EnE+CjNgEgoqX
qv7ZX2p5Izgn9xqSxOfVPGySGiSt7l5ADSN4L4xBHWlriXEI/0TAYL1DT1+YfnSY
t1W1hbcaZedqiEUDJwsQQ3pKxMNYKhOuJCqWjmcpMCjWVU4u20Y=
=0b5b
-----END PGP SIGNATURE-----

--B4IIlcmfBL/1gGOG--
