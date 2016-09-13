From: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 1/9] ethernet: add sun8i-emac driver
Date: Tue, 13 Sep 2016 15:33:01 +0200
Message-ID: <20160913133301.GB31990@Red>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-2-git-send-email-clabbe.montjoie@gmail.com>
 <20160909141527.GE30871@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160909141527.GE30871-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 09, 2016 at 04:15:27PM +0200, Andrew Lunn wrote:
> Hi Corentin
> 
> > +static int sun8i_emac_mdio_register(struct net_device *ndev)
> > +{
> > +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> > +	struct mii_bus *bus;
> > +	int ret;
> > +
> > +	bus = mdiobus_alloc();
> 
> You can use devm_mdiobus_alloc() which will simplify your error
> handling and unregister code.
> 
> 	 Andrew

Hello

Since the mdio bus is allocated on ndev/open, it need to be removed when ndev/stop is called.
So devm_mdiobus_alloc cannot be used.

Regards

Corentin Labbe
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
