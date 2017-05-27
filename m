From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 1/3] net: phy: Create sysfs reciprocal links
 for attached_dev/phydev
Date: Sat, 27 May 2017 01:31:36 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A9DB6A@CHN-SV-EXMX02.mchp-main.com>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
 <20170524193354.10739-2-f.fainelli@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DAA2@CHN-SV-EXMX02.mchp-main.com>
 <d2d97683-3fcc-6603-09e1-13818464de18@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DACE@CHN-SV-EXMX02.mchp-main.com>
 <44f24fbd-5093-faa2-02cd-f8d4d835b59d@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DAF6@CHN-SV-EXMX02.mchp-main.com>
 <05a159af-6689-70db-9506-09059a09f1a5@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DB14@CHN-SV-EXMX02.mchp-main.com>
 <0413eb98-61cc-2fca-a4d6-7f4ef91843ba@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DB32@CHN-SV-EXMX02.mchp-main.com>
 <dc4a3f50-3ff3-e690-9893-0575ddea42f6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <andrew@lunn.ch>
To: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:5506 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932375AbdE0Bbi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 21:31:38 -0400
In-Reply-To: <dc4a3f50-3ff3-e690-9893-0575ddea42f6@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Yes, that's a very valid point, how about we even do this:
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index f84414b8f2ee..dc666ec13651 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -960,15 +960,21 @@ int phy_attach_direct(struct net_device *dev,
> struct phy_device *phydev,
> 
>         phydev->attached_dev = dev;
>         dev->phydev = phydev;
> +
> +       /* Some Ethernet drivers try to connect to a PHY device before
> +        * calling register_netdevice() -> netdev_register_kobject() and
> +        * does the dev->dev.kobj initialization. Here we only check for
> +        * success which indicates that the network device kobject is
> +        * ready.
> +        */
>         err = sysfs_create_link(&phydev->mdio.dev.kobj, &dev->dev.kobj,
>                                 "attached_dev");
> -       if (err)
> -               goto error;
> -
> -       err = sysfs_create_link(&dev->dev.kobj, &phydev->mdio.dev.kobj,
> -                               "phydev");
> -       if (err)
> -               goto error;
> +       if (!err) {
> +               err = sysfs_create_link(&dev->dev.kobj,
> &phydev->mdio.dev.kobj,
> +                                       "phydev");
> +               if (err)
> +                       goto error;
> +       }
> 
>         phydev->dev_flags = flags;
> 
Looks better and clean.

How about sysfs_remove_link() in phy_detach()?

- Woojung
