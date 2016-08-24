From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/4] net: phy: Add MAC-IF driver for Microsemi PHYs.
Date: Wed, 24 Aug 2016 15:06:44 +0200
Message-ID: <20160824130644.GD13406@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A145336694@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43281 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752805AbcHXNIU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 09:08:20 -0400
Content-Disposition: inline
In-Reply-To: <646450A91FAED74E85C6E9C4D6E936A145336694@avsrvexchmbx1.microsemi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int vsc85xx_mac_if_set(struct phy_device *phydev,
> +                             phy_interface_t   *interface)
> +{
> +       int rc;
> +       u16 reg_val;
> +
> +       mutex_lock(&phydev->lock);
> +       reg_val = phy_read(phydev, MSCC_PHY_EXT_PHY_CNTL_1);
> +       switch (*interface) {
> +       case PHY_INTERFACE_MODE_RGMII:
> +               reg_val &= ~(MAC_IF_SELECTION_MASK);
> +               reg_val |= (MAC_IF_SELECTION_RGMII << MAC_IF_SELECTION_POS);
> +               break;
> +       case PHY_INTERFACE_MODE_RMII:
> +               reg_val &= ~(MAC_IF_SELECTION_MASK);
> +               reg_val |= (MAC_IF_SELECTION_RMII << MAC_IF_SELECTION_POS);
> +               break;
> +       case PHY_INTERFACE_MODE_MII:
> +       case PHY_INTERFACE_MODE_GMII:
> +       default:
> +               reg_val &= ~(MAC_IF_SELECTION_MASK);
> +               reg_val |= (MAC_IF_SELECTION_GMII << MAC_IF_SELECTION_POS);
> +               break;
> +       }
> +       rc = phy_write(phydev, MSCC_PHY_EXT_PHY_CNTL_1, reg_val);
> +       if (rc != 0)
> +               goto out_unlock;
> +
> +       rc = vsc85xx_soft_reset(phydev);
> +
> +out_unlock:
> +       mutex_unlock(&phydev->lock);
> +
> +       return rc;
> +}

Again, you need to justify why you are doing something completely
different to all other phy drivers. You cannot you do what
m88e1121_config_aneg(), mv88e111_config_init(), dp83867_config_init()
does?

	Andrew
