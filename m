From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 05/18] net: mvpp2: initialize the GMAC when
 using a port
Date: Wed, 26 Jul 2017 18:14:13 +0200
Message-ID: <20170726161413.GH12049@lunn.ch>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-6-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40976 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750893AbdGZQOU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 12:14:20 -0400
Content-Disposition: inline
In-Reply-To: <20170724134848.19330-6-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	} else if (port->phy_interface == PHY_INTERFACE_MODE_RGMII) {

Don't forget:
   PHY_INTERFACE_MODE_RGMII_ID,
   PHY_INTERFACE_MODE_RGMII_RXID,
   PHY_INTERFACE_MODE_RGMII_TXID,

> +		val = readl(port->base + MVPP22_GMAC_CTRL_4_REG);
> +		val |= MVPP22_CTRL4_EXT_PIN_GMII_SEL |
> +		       MVPP22_CTRL4_SYNC_BYPASS_DIS |
> +		       MVPP22_CTRL4_QSGMII_BYPASS_ACTIVE;
> +		val &= ~MVPP22_CTRL4_DP_CLK_SEL;
> +		writel(val, port->base + MVPP22_GMAC_CTRL_4_REG);
> +
> +		val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
> +		val &= ~MVPP2_GMAC_DISABLE_PADDING;
> +		writel(val, port->base + MVPP2_GMAC_CTRL_2_REG);
> +	}
> +
> +	/* The port is connected to a copper PHY */
> +	val = readl(port->base + MVPP2_GMAC_CTRL_0_REG);
> +	val &= ~MVPP2_GMAC_PORT_TYPE_MASK;
> +	writel(val, port->base + MVPP2_GMAC_CTRL_0_REG);
> +
> +	val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +	val |= MVPP2_GMAC_IN_BAND_AUTONEG |
> +	       MVPP2_GMAC_IN_BAND_AUTONEG_BYPASS |
> +	       MVPP2_GMAC_AN_SPEED_EN | MVPP2_GMAC_FLOW_CTRL_AUTONEG |
> +	       MVPP2_GMAC_AN_DUPLEX_EN;
> +	writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +}
> +
> +static void mvpp2_port_mii_gmac_configure(struct mvpp2_port *port)
> +{
> +	u32 val;
> +
> +	/* Force link down */
> +	val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +	val |= MVPP2_GMAC_FORCE_LINK_DOWN;
> +	writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +
> +	/* Set the GMAC in a reset state */
> +	val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
> +	val |= MVPP2_GMAC_PORT_RESET_MASK;
> +	writel(val, port->base + MVPP2_GMAC_CTRL_2_REG);
> +
> +	/* Configure the PCS and in-band AN */
> +	val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
> +	if (port->phy_interface == PHY_INTERFACE_MODE_SGMII) {
> +	        val |= MVPP2_GMAC_INBAND_AN_MASK | MVPP2_GMAC_PCS_ENABLE_MASK;
> +	} else if (port->phy_interface == PHY_INTERFACE_MODE_RGMII) {

phy_interface_is_rgmii()

	Andrew
