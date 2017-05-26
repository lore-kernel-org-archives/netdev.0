From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 1/3] net: phy: Create sysfs reciprocal links
 for attached_dev/phydev
Date: Fri, 26 May 2017 23:34:33 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A9DAA2@CHN-SV-EXMX02.mchp-main.com>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
 <20170524193354.10739-2-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <andrew@lunn.ch>
To: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:49020 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948842AbdEZXeu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 19:34:50 -0400
In-Reply-To: <20170524193354.10739-2-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -960,6 +960,15 @@ int phy_attach_direct(struct net_device *dev, struct
> phy_device *phydev,
> 
>  	phydev->attached_dev = dev;
>  	dev->phydev = phydev;
> +	err = sysfs_create_link(&phydev->mdio.dev.kobj, &dev->dev.kobj,
> +				"attached_dev");
> +	if (err)
> +		goto error;
> +
> +	err = sysfs_create_link(&dev->dev.kobj, &phydev->mdio.dev.kobj,
> +				"phydev");
> +	if (err)
> +		goto error;
> 
Florian,

I knew that it is applied to net-next.
However, sysfs_create_link() fails when fixed phy (drivers/net/phy/fixed_phy.c)
Do you have a chance to test with it?

- Woojung
