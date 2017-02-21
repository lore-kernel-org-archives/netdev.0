From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 05/21] net-next: stmmac: Add dwmac-sun8i
Date: Tue, 21 Feb 2017 14:22:17 -0800
Message-ID: <20170221222217.62barcu445stewvr@lukather>
References: <20170216124859.14346-1-clabbe.montjoie@gmail.com>
 <20170216124859.14346-6-clabbe.montjoie@gmail.com>
 <20170216190524.l2ddzhwabzdpdphx@lukather>
 <20170217131802.GB24993@Red>
Reply-To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="zzcjb24ogs6xglso"
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDSJBYGBRIMBBHH3WLCQKGQERQ3JUVA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170217131802.GB24993@Red>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


--zzcjb24ogs6xglso
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline

On Fri, Feb 17, 2017 at 02:18:02PM +0100, Corentin Labbe wrote:
> On Thu, Feb 16, 2017 at 08:05:24PM +0100, Maxime Ripard wrote:
> > Hi,
> > 
> 
> [...]
> > > +
> > > +struct emac_variant {
> > > +	u32 default_syscon_value;
> > 
> > Why do you need a default value? Can't you read it from the syscon
> > directly?
> > 
> 
> Why not, but you can see the default value as "value for disabled
> state".

i'm not sure what you mean here, sorry.

> My fear is that something (uboot) modify it (keep it activated)
> before driver load.

You could have the same argument there then for the board that require
reading it. What if U-boot modified it to some non-functional state?

Either you trust the value there, and you read it, or you don't, and
then you never read it. But being stuck in between doesn't seem that
great.

> > > +static void sun8i_dwmac_dma_start_tx(void __iomem *ioaddr)
> > > +{
> > > +	u32 v;
> > > +
> > > +	v = readl(ioaddr + EMAC_TX_CTL0);
> > > +	v |= EMAC_TX_TRANSMITTER_EN;
> > > +	writel(v, ioaddr + EMAC_TX_CTL0);
> > > +
> > > +	v = readl(ioaddr + EMAC_TX_CTL1);
> > > +	v |= EMAC_TX_DMA_START;
> > > +	v |= EMAC_TX_DMA_EN;
> > > +	writel(v, ioaddr + EMAC_TX_CTL1);
> > 
> > This is a bit worrying. There's not a single lock in your driver,
> > while you have a significant number of read / modify / write.
> > 
> > Where is the locking handled?
> 
> All thoses function are handled by the "stmmac_ops framework", all
> other glue drivers does not lock anything.

Most of them seem to use regmap though, that has an internal lock.

> The few functions that need locking already got it on the calling
> stmmac side.

Ok.

> > > +
> > > +			if (of_property_read_bool(priv->plat->phy_node,
> > > +						  "allwinner,leds-active-low"))
> > > +				reg |= H3_EPHY_LED_POL;
> > > +			else
> > > +				reg &= ~H3_EPHY_LED_POL;
> > > +
> > > +			ret = of_mdio_parse_addr(priv->device,
> > > +						 priv->plat->phy_node);
> > > +			if (ret < 0) {
> > > +				dev_err(priv->device, "Could not parse MDIO addr\n");
> > > +				return ret;
> > > +			}
> > > +			/* of_mdio_parse_addr returns a valid (0 ~ 31) PHY
> > > +			 * address. No need to mask it again.
> > > +			 */
> > > +			reg |= ret << H3_EPHY_ADDR_SHIFT;
> > > +		}
> > > +	}
> > > +
> > > +	if (!of_property_read_u32(node, "allwinner,tx-delay", &val)) {
> > 
> > How do you compute it? Can't this be done through auto-training?
> 
> The value is the same as used in vendor BSP kernel.

This is not really usable though. I've had already three boards that
never got any BSP kernel. You need to be able at least to document
some way to compute it (even if it's based on manual, trial and error
process).

> I do not understand what you mean by auto-training.

Being able to automatically detect the optimal settings at boot time.

Thanks!
Maxime

-- 
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
--zzcjb24ogs6xglso--
