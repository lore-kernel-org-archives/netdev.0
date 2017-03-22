From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next v2 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Wed, 22 Mar 2017 19:30:02 +0100
Message-ID: <20170322183002.GP30655@lunn.ch>
References: <1490088910-19405-1-git-send-email-sean.wang@mediatek.com>
 <1490088910-19405-6-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
        matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1490088910-19405-6-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +static int
> +core_read_mmd_indirect(struct mt7530_priv *priv, int prtad, int devad)
> +{
> +	struct mii_bus *bus = priv->bus;
> +	int value, ret;
> +
> +	/* Write the desired MMD Devad */
> +	ret = bus->write(bus, 0, MII_MMD_CTRL, devad);
> +	if (ret < 0)
> +		goto err;
> +
> +	/* Write the desired MMD register address */
> +	ret = bus->write(bus, 0, MII_MMD_DATA, prtad);
> +	if (ret < 0)
> +		goto err;
> +
> +	/* Select the Function : DATA with no post increment */
> +	ret = bus->write(bus, 0, MII_MMD_CTRL, (devad | MII_MMD_CTRL_NOINCR));
> +	if (ret < 0)
> +		goto err;

Hi Sean

This appear to be a copy of mmd_phy_indirect(). There are patches from
Russell King which made this a public function. Once Russell patches
make net-next, it would be nice to use mmd_phy_indirect(). But that
might be as a follow up patch, rather than now, depending on the order
of acceptance of the patches.

   Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
