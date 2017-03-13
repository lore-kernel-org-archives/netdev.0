From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] net-next: dsa: add dsa support for Mediatek
 MT7530 switch
Date: Tue, 14 Mar 2017 00:11:17 +0100
Message-ID: <20170313231117.GF14183@lunn.ch>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
 <1489421488-300-5-git-send-email-sean.wang@mediatek.com>
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
In-Reply-To: <1489421488-300-5-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +static int
> +mt7530_setup(struct dsa_switch *ds)
> +{
> +	struct mt7530_priv *priv = ds->priv;
> +	int ret, i, phy_mode;
> +	u8  cpup_mask = 0;
> +	u32 id, val;
> +	struct regmap *regmap;
> +
> +	/* Make sure that cpu port specfied on the dt is appropriate */
> +	if (!dsa_is_cpu_port(ds, MT7530_CPU_PORT)) {
> +		dev_err(priv->dev, "port not matched with the CPU port\n");
> +		return -EINVAL;
> +	}
> +
> +	regmap = devm_regmap_init(ds->dev, NULL, priv,
> +				  &mt7530_regmap_config);
> +	if (IS_ERR(regmap))
> +		dev_warn(priv->dev, "phy regmap initialization failed");
> +
> +	phy_mode = of_get_phy_mode(ds->ports[ds->dst->cpu_port].dn);
> +	if (phy_mode < 0) {
> +		dev_err(priv->dev, "Can't find phy-mode for master device\n");
> +		return phy_mode;
> +	}
> +	dev_info(priv->dev, "phy-mode for master device = %x\n", phy_mode);

Hi Sean

It is not documented in the binding that a phy-mode is mandatory for
the cpu port.

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
