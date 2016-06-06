From: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] ethernet: add sun8i-emac driver
Date: Mon, 6 Jun 2016 15:34:32 +0200
Message-ID: <20160606133432.GA29281@Red>
References: <1464947790-22991-1-git-send-email-clabbe.montjoie@gmail.com>
 <1464947790-22991-2-git-send-email-clabbe.montjoie@gmail.com>
 <5754A86B.6050607@arm.com>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: =?iso-8859-1?Q?Andr=E9?= Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-sunxi+bncBD7YLCN32UNBB3HX2W5AKGQEW5BZRNA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <5754A86B.6050607-5wv7dgnIgG8@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Sun, Jun 05, 2016 at 11:32:11PM +0100, Andr=C3=A9 Przywara wrote:
> On 03/06/16 10:56, LABBE Corentin wrote:
>=20
> Hi,
>=20
> first: thanks for posting this and the time and work that you spent on
> it. With the respective DT nodes this works for me on the Pine64 and
> turns this board eventually into something useful.
>=20
> Some comments below:
>=20
> > This patch add support for sun8i-emac ethernet MAC hardware.
> > It could be found in Allwinner H3/A83T/A64 SoCs.
> >=20
> > It supports 10/100/1000 Mbit/s speed with half/full duplex.
> > It can use an internal PHY (MII 10/100) or an external PHY
> > via RGMII/RMII.
> >=20
> > Signed-off-by: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  drivers/net/ethernet/allwinner/Kconfig      |   13 +
> >  drivers/net/ethernet/allwinner/Makefile     |    1 +
> >  drivers/net/ethernet/allwinner/sun8i-emac.c | 1943 +++++++++++++++++++=
++++++++
> >  3 files changed, 1957 insertions(+)
> >  create mode 100644 drivers/net/ethernet/allwinner/sun8i-emac.c
> >=20
> > diff --git a/drivers/net/ethernet/allwinner/Kconfig b/drivers/net/ether=
net/allwinner/Kconfig
> > index 47da7e7..226499d 100644
> > --- a/drivers/net/ethernet/allwinner/Kconfig
> > +++ b/drivers/net/ethernet/allwinner/Kconfig
> > @@ -33,4 +33,17 @@ config SUN4I_EMAC
> >            To compile this driver as a module, choose M here.  The modu=
le
> >            will be called sun4i-emac.
> > =20
> > +config SUN8I_EMAC
> > +        tristate "Allwinner sun8i EMAC support"
>=20
> nit: w/s error
>=20
ok

> > +
> > +#define SUN8I_EMAC_BASIC_CTL0 0x00
> > +#define SUN8I_EMAC_BASIC_CTL1 0x04
> > +
> > +#define SUN8I_EMAC_MDIO_CMD 0x48
> > +#define SUN8I_EMAC_MDIO_DATA 0x4C
>=20
> Can you align all these register offsets with tabs, so that the actual
> offset values are below each other?
> Also ordering them by address seems useful to me.
>=20

ok

> > +/* Structure of DMA descriptor used by the hardware  */
> > +struct dma_desc {
> > +	u32 status; /* status of the descriptor */
> > +	u32 st; /* Information on the frame */
> > +	u32 buf_addr; /* physical address of the frame data */
> > +	u32 next; /* physical address of next dma_desc */
> > +} __packed __aligned(4);
>=20
> I don't think we need this alignment attribute here:
> 1) The structure will be 4-byte aligned anyway, because the first member
> is naturally 4 bytes aligned.
> 2) The alignment requirement is on the physical DMA side. I don't see
> how the compiler should be able to guarantee this. So technically you
> have to tell the DMA allocation code about your alignment requirement.
> But due to 1), I think this is a moot discussion.
>=20

ok, I have removed all __aligned

>=20
> ....
>=20
> > +
> > +
> > +	priv->rx_sk =3D kcalloc(nbdesc_rx, sizeof(struct sk_buff *), GFP_KERN=
EL);
> > +	if (!priv->rx_sk) {
> > +		err =3D -ENOMEM;
> > +		goto rx_sk_error;
> > +	}
> > +	priv->tx_sk =3D kcalloc(nbdesc_tx, sizeof(struct sk_buff *), GFP_KERN=
EL);
> > +	if (!priv->tx_sk) {
> > +		err =3D -ENOMEM;
> > +		goto tx_sk_error;
> > +	}
> > +	priv->tx_map =3D kcalloc(nbdesc_tx, sizeof(int), GFP_KERNEL);
> > +	if (!priv->tx_map) {
> > +		err =3D -ENOMEM;
> > +		goto tx_map_error;
> > +	}
> > +
> > +	priv->dd_rx =3D dma_alloc_coherent(priv->dev,
> > +			nbdesc_rx * sizeof(struct dma_desc),
> > +			&priv->dd_rx_phy,
> > +			GFP_KERNEL);
>=20
> You need to be sure here to allocate 32-bit DMA memory only, since the
> hardware holds only 32 bits worth of addresses. If I am not mistaken,
> the following snippet (preferrably in the probe function below) should
> take care of this:
>=20
> 	if (dma_set_mask_and_coherent(&priv->dev, DMA_BIT_MASK(32))) {
> 		dev_err(&priv->dev, "No suitable DMA available\n");
> 		return -ENOMEM;
> 	}
>=20
> This isn't an issue for the SoCs we know of (they have a 32-bit bus
> anyway), but future SoCs could support more memory (the A80 does
> already!), so you have to allocate it from the low 4GB. This is a
> limitation of that particular _device_ (and not the platform), since it
> does the DMA itself and this engine is limited to 32-bit physical address=
es.
>=20

ok

> > +	if (!priv->dd_rx) {
> > +		dev_err(priv->dev, "ERROR: cannot DMA RX");
> > +		err =3D -ENOMEM;
> > +		goto dma_rx_error;
> > +	}
>=20
> ....
>=20
> > +
> > +static const struct of_device_id sun8i_emac_of_match_table[] =3D {
> > +	{ .compatible =3D "allwinner,sun8i-a83t-emac",
> > +	  .data =3D (void *)A83T_EMAC },
> > +	{ .compatible =3D "allwinner,sun8i-h3-emac",
> > +	  .data =3D (void *)H3_EMAC },
> > +	{ .compatible =3D "allwinner,sun50i-a64-emac",
> > +	  .data =3D (void *)A64_EMAC },
> > +	{}
> > +};
>=20
> I am not sure this is the proper way to model the different variants of
> the device. I see two differing features here:
> 1) the H3 has an internal PHY
> 2) the A83T does not support RMII
>=20
> So wouldn't it be wiser to put those two options as properties into the
> DT node? This way any future EMAC version could pick the matching
> features and we wouldn't need to add a new compatible string for each
> and every new SoC which carries this device and thus hardcode it's
> properties in this driver.
>=20

Since Wens already have answered that, I have nothing more to say

Thanks for your review.

Regards
LABBE Corentin

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
