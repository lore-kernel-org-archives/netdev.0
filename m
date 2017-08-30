From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [net-next PATCHv6 2/2] net: socionext: Add NetSec driver
Date: Wed, 30 Aug 2017 19:17:59 +0200
Message-ID: <20170830171759.GC22289@lunn.ch>
References: <1504088657-6102-1-git-send-email-jaswinder.singh@linaro.org>
 <1504088771-6255-1-git-send-email-jaswinder.singh@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, davem@davemloft.net,
        mark.rutland@arm.com, arnd@arndb.de, patches@linaro.org,
        Jassi Brar <jaswinder.singh@linaro.org>, robh+dt@kernel.org,
        andy@warmcat.com
To: Jassi Brar <jassisinghbrar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45296 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751984AbdH3RSF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 13:18:05 -0400
Content-Disposition: inline
In-Reply-To: <1504088771-6255-1-git-send-email-jaswinder.singh@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int netsec_mac_update_to_phy_state(struct netsec_priv *priv)
> +{
> +	struct phy_device *phydev = priv->ndev->phydev;
> +	u32 value = 0;
> +
> +	value = phydev->duplex ? NETSEC_GMAC_MCR_REG_FULL_DUPLEX_COMMON :
> +				       NETSEC_GMAC_MCR_REG_HALF_DUPLEX_COMMON;
> +
> +	if (phydev->speed != SPEED_1000)
> +		value |= NETSEC_MCR_PS;
> +
> +	if ((priv->phy_interface != PHY_INTERFACE_MODE_GMII) &&
> +	    (phydev->speed == SPEED_100))
> +		value |= NETSEC_GMAC_MCR_REG_FES;
> +
> +	value |= NETSEC_GMAC_MCR_REG_CST | NETSEC_GMAC_MCR_REG_JE;
> +
> +	if (priv->phy_interface == PHY_INTERFACE_MODE_RGMII)
> +		value |= NETSEC_GMAC_MCR_REG_IBN;
> +
> +	if (netsec_mac_write(priv, GMAC_REG_MCR, value))
> +		return -ETIMEDOUT;
> +
> +	priv->actual_link_speed = phydev->speed;
> +	priv->actual_duplex = phydev->duplex;
> +	netif_info(priv, drv, priv->ndev, "%s: %uMbps, duplex:%d\n",
> +		   __func__, phydev->speed, phydev->duplex);

phy_print_status()

> +	mac = of_get_mac_address(pdev->dev.of_node);
> +	if (mac)
> +		ether_addr_copy(ndev->dev_addr, mac);
> +
> +	if (!is_valid_ether_addr(ndev->dev_addr)) {
> +		eth_hw_addr_random(ndev);
> +		dev_warn(&pdev->dev, "No MAC address found, using random\n");
> +	}

So the mac address is optional, unlike what the binding document says.

> +	priv->phy_np = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
> +	if (!priv->phy_np) {
> +		netif_err(priv, probe, ndev, "missing phy in DT\n");

It is the phy-handle which is missing, not the phy.

> +
> +	/* MTU range */
> +	ndev->min_mtu = ETH_MIN_MTU;

No need to set this, it is the default.

Otherwise, this looks good, in terms of phy and mdio.

	   Andrew
