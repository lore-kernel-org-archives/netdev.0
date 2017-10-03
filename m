From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH] net: phy: DP83822 initial driver submission
Date: Tue, 3 Oct 2017 17:43:16 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B3C801@CHN-SV-EXMX02.mchp-main.com>
References: <20171003155316.12312-1-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <dmurphy@ti.com>, <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:4697 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdJCRnS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 13:43:18 -0400
In-Reply-To: <20171003155316.12312-1-dmurphy@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int dp83822_suspend(struct phy_device *phydev)
> +{
> +	int value;
> +
> +	mutex_lock(&phydev->lock);
> +
> +	value = phy_read_mmd(phydev, DP83822_DEVADDR,
> MII_DP83822_WOL_CFG);
> +	if (~value & DP83822_WOL_EN) {
Same result, but how about " if (!(value & DP83822_WOL_EN))" ?

> +		value = phy_read(phydev, MII_BMCR);
> +		phy_write(phydev, MII_BMCR, value | BMCR_PDOWN);
> +	}
> +
> +	mutex_unlock(&phydev->lock);
> +
> +	return 0;
> +}
