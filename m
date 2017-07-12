From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/4] net-next: mediatek: add support for
 MediaTek MT7622 SoC
Date: Wed, 12 Jul 2017 17:00:09 +0200
Message-ID: <20170712150009.GE2557@lunn.ch>
References: <cover.1499829241.git.sean.wang@mediatek.com>
 <42912dfa706f0d1f1bbe152da71dc00c0a4e18cc.1499829241.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@phrozen.org, davem@davemloft.net, nbd@openwrt.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mediatek@lists.infradead.org
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <42912dfa706f0d1f1bbe152da71dc00c0a4e18cc.1499829241.git.sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sean

>  static void mtk_phy_link_adjust(struct net_device *dev)
>  {
>  	struct mtk_mac *mac = netdev_priv(dev);
> @@ -269,6 +311,7 @@ static int mtk_phy_connect(struct net_device *dev)
>  	if (!np)
>  		return -ENODEV;
>  
> +	mac->ge_mode = 0;
>  	switch (of_get_phy_mode(np)) {
>  	case PHY_INTERFACE_MODE_TRGMII:
>  		mac->trgmii = true;
> @@ -276,7 +319,15 @@ static int mtk_phy_connect(struct net_device *dev)
>  	case PHY_INTERFACE_MODE_RGMII_RXID:
>  	case PHY_INTERFACE_MODE_RGMII_ID:
>  	case PHY_INTERFACE_MODE_RGMII:
> -		mac->ge_mode = 0;
> +		break;
> +	case PHY_INTERFACE_MODE_SGMII:
> +		if (MTK_HAS_CAPS(eth->soc->caps, MTK_SGMII))
> +			mtk_gmac_sgmii_hw_setup(eth, mac->id);
> +		break;

> +	case PHY_INTERFACE_MODE_INTERNAL:
> +		if (MTK_HAS_CAPS(eth->soc->caps, MTK_GMAC1_ESW) && !mac->id)
> +			/* Setup the path through ESW internal switch */
> +			mtk_w32(eth, MTK_MUX_TO_ESW, MTK_MAC_MISC);

This bit is interesting. Generally, there is no PHY at all between the
MAC and the switch. So i don't think this is correct. Please can you
take this out for the moment, until you actually add support for the
switch. We can discuss it then, when we see the bigger picture.

	Andrew
