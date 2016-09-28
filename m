From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: phy: Add Wake-on-LAN driver for
 Microsemi PHYs.
Date: Wed, 28 Sep 2016 18:27:05 +0200
Message-ID: <20160928162705.GB25553@lunn.ch>
References: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1475064078-22310-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35259 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932724AbcI1Q1J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 12:27:09 -0400
Content-Disposition: inline
In-Reply-To: <1475064078-22310-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#define MSCC_PHY_WOL_MAC_CONTROL	  27
> +#define EDGE_RATE_CNTL_POS		  5
> +#define EDGE_RATE_CNTL_MASK		  0x00E0

This patch does not require these two #defines.

Please indicate in the cover note if the patches depends on other
patches in order to cleanly apply. Or if these patches are going to
conflict with some other patches.

> +	reg_val = phy_read(phydev, MSCC_PHY_WOL_MAC_CONTROL);
> +	if (wol_conf->wolopts & WAKE_MAGICSECURE)
> +		reg_val |= SECURE_ON_ENABLE;
> +	else
> +		reg_val &= ~SECURE_ON_ENABLE;
> +	phy_write(phydev, MSCC_PHY_WOL_MAC_CONTROL, reg_val);
> +
> +	if (wol_conf->wolopts & WAKE_MAGICSECURE) {
> +		reg_val = wol_conf->sopass[4] << 8;
> +		reg_val |= wol_conf->sopass[5];
> +		phy_write(phydev, MSCC_PHY_WOL_LOWER_PASSWD, reg_val);
> +		reg_val = wol_conf->sopass[2] << 8;
> +		reg_val |= wol_conf->sopass[3];
> +		phy_write(phydev, MSCC_PHY_WOL_MID_PASSWD, reg_val);
> +		reg_val = wol_conf->sopass[0] << 8;
> +		reg_val |= wol_conf->sopass[1];
> +		phy_write(phydev, MSCC_PHY_WOL_UPPER_PASSWD, reg_val);
> +	} else {
> +		phy_write(phydev, MSCC_PHY_WOL_LOWER_PASSWD, 0);
> +		phy_write(phydev, MSCC_PHY_WOL_MID_PASSWD, 0);
> +		phy_write(phydev, MSCC_PHY_WOL_UPPER_PASSWD, 0);
> +	}

Wouldn't it be better to set the password, and then enable the
password feature?

I don't know much about WOL. Hopefully Florian will add further
comments.

	 Andrew
