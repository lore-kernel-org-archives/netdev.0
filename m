From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Fri, 24 Mar 2017 15:02:15 +0100
Message-ID: <20170324140215.GG28518@lunn.ch>
References: <1490088910-19405-1-git-send-email-sean.wang@mediatek.com>
 <1490088910-19405-6-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        matthias.bgg@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        davem@davemloft.net, Landen.Chao@mediatek.com, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59834 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935191AbdCXOCg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 10:02:36 -0400
Content-Disposition: inline
In-Reply-To: <1490088910-19405-6-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sean

> +	regmap = devm_regmap_init(ds->dev, NULL, priv,
> +				  &mt7530_regmap_config);
> +	if (IS_ERR(regmap))
> +		dev_warn(priv->dev, "phy regmap initialization failed");
> +

Shouldn't this be a fatal error? If you keep going when there is an
error, what happens when you actually try to use the regmap?

> +	phy_mode = of_get_phy_mode(ds->ports[ds->dst->cpu_port].dn);
> +	if (phy_mode < 0) {
> +		dev_err(priv->dev, "Can't find phy-mode for master device\n");
> +		return phy_mode;
> +	}
> +	dev_info(priv->dev, "phy-mode for master device = %x\n", phy_mode);

dev_dbg? 

> +
> +	id = mt7530_read(priv, MT7530_CREV);
> +	id >>= CHIP_NAME_SHIFT;
> +	if (id != MT7530_ID)
> +		return -ENODEV;

It might be helpful to say what ID has been found, if it is not the
supported ID.

	Andrew
