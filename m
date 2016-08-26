From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v2 1/5] ethernet: add sun8i-emac driver
Date: Fri, 26 Aug 2016 22:49:14 +0200
Message-ID: <20160826204914.GD3165@lukather>
References: <1469001800-11615-1-git-send-email-clabbe.montjoie@gmail.com>
 <1469001800-11615-2-git-send-email-clabbe.montjoie@gmail.com>
 <20160725195455.GQ7419@lukather>
 <20160824120221.GB29212@Red>
Reply-To: maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BI5RvnYi6R4T2M87"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDSJBYGBRIMBBS6WQK7AKGQE4SHZRSY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20160824120221.GB29212@Red>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org


--BI5RvnYi6R4T2M87
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline

Hi,

On Wed, Aug 24, 2016 at 02:02:21PM +0200, LABBE Corentin wrote:
> > > +/* Set Management Data Clock, must be call after device reset */
> > > +static void sun8i_emac_set_mdc(struct net_device *ndev)
> > > +{
> > > +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> > > +	unsigned long rate;
> > > +	u32 reg;
> > > +
> > > +	rate = clk_get_rate(priv->ahb_clk);
> > > +	if (rate > 160000000)
> > > +		reg = 0x3 << 20; /* AHB / 128 */
> > > +	else if (rate > 80000000)
> > > +		reg = 0x2 << 20; /* AHB / 64 */
> > > +	else if (rate > 40000000)
> > > +		reg = 0x1 << 20; /* AHB / 32 */
> > > +	else
> > > +		reg = 0x0 << 20; /* AHB / 16 */
> > > +	netif_dbg(priv, link, ndev, "MDC auto : %x\n", reg);
> > > +	writel(reg, priv->base + SUN8I_EMAC_MDIO_CMD);
> > 
> > You could also expose that as a clock.
> > 
> 
> For which purpose ?
> No ethernet driver expose the MDC as clock and I dont see any interest:
> - I dont think that tuning it give any gain
> - Knowing it's value is of little interest

You don't have to implement anything, you can just register a clk_div
driver, and everything works, and you would use the proper clock APIs
(ie. clk_set_rate, and that's it).

That would be exposed just like any other clock, including in debugfs,
which would remove the need for the debug call.

But this really was just a suggestion.

Maxime

-- 
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
--BI5RvnYi6R4T2M87--
