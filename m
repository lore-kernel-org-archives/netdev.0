From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH 2/3 v2] net: phy: DP83822 initial driver submission
Date: Wed, 4 Oct 2017 22:44:36 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B3F9A9@CHN-SV-EXMX02.mchp-main.com>
References: <20171004182031.13794-1-dmurphy@ti.com>
 <20171004182031.13794-2-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <afd@ti.com>
To: <dmurphy@ti.com>, <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:6330 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751171AbdJDWoh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 18:44:37 -0400
In-Reply-To: <20171004182031.13794-2-dmurphy@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int dp83822_suspend(struct phy_device *phydev)
> +{
> +	int value;
> +
> +	mutex_lock(&phydev->lock);
> +	value = phy_read_mmd(phydev, DP83822_DEVADDR,
> MII_DP83822_WOL_CFG);
> +	mutex_unlock(&phydev->lock);
Would we need mutex to access phy_read_mmd()?
phy_read_mmd() has mdio_lock for indirect access.

> +	if (!(value & DP83822_WOL_EN))
> +		genphy_suspend(phydev);
> +
> +	return 0;
> +}
> +
> +static int dp83822_resume(struct phy_device *phydev)
> +{
> +	int value;
> +
> +	genphy_resume(phydev);
> +
> +	mutex_lock(&phydev->lock);
> +	value = phy_read_mmd(phydev, DP83822_DEVADDR,
> MII_DP83822_WOL_CFG);
> +
> +	phy_write_mmd(phydev, DP83822_DEVADDR,
> MII_DP83822_WOL_CFG, value |
> +		      DP83822_WOL_CLR_INDICATION);
> +
> +	mutex_unlock(&phydev->lock);
Same here.

Woojung
