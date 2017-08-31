From: Jassi Brar <jassisinghbrar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCHv6 2/2] net: socionext: Add NetSec driver
Date: Thu, 31 Aug 2017 12:03:06 +0530
Message-ID: <CABb+yY2TJhRFEh806ODZkxUYQNik8zjR8dVK6PR1mO=bT1KeGg@mail.gmail.com>
References: <1504088657-6102-1-git-send-email-jaswinder.singh@linaro.org>
 <1504088771-6255-1-git-send-email-jaswinder.singh@linaro.org> <20170830171759.GC22289@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Devicetree List <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "arnd-r2nGTMty4D4@public.gmane.org" <arnd-r2nGTMty4D4@public.gmane.org>,
        "patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andy Green <andy-/Zus8d0mwwtBDgjK7y7TUQ@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170830171759.GC22289-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2017 at 10:47 PM, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:
>> +static int netsec_mac_update_to_phy_state(struct netsec_priv *priv)
>> +{
>> +     struct phy_device *phydev = priv->ndev->phydev;
>> +     u32 value = 0;
>> +
>> +     value = phydev->duplex ? NETSEC_GMAC_MCR_REG_FULL_DUPLEX_COMMON :
>> +                                    NETSEC_GMAC_MCR_REG_HALF_DUPLEX_COMMON;
>> +
>> +     if (phydev->speed != SPEED_1000)
>> +             value |= NETSEC_MCR_PS;
>> +
>> +     if ((priv->phy_interface != PHY_INTERFACE_MODE_GMII) &&
>> +         (phydev->speed == SPEED_100))
>> +             value |= NETSEC_GMAC_MCR_REG_FES;
>> +
>> +     value |= NETSEC_GMAC_MCR_REG_CST | NETSEC_GMAC_MCR_REG_JE;
>> +
>> +     if (priv->phy_interface == PHY_INTERFACE_MODE_RGMII)
>> +             value |= NETSEC_GMAC_MCR_REG_IBN;
>> +
>> +     if (netsec_mac_write(priv, GMAC_REG_MCR, value))
>> +             return -ETIMEDOUT;
>> +
>> +     priv->actual_link_speed = phydev->speed;
>> +     priv->actual_duplex = phydev->duplex;
>> +     netif_info(priv, drv, priv->ndev, "%s: %uMbps, duplex:%d\n",
>> +                __func__, phydev->speed, phydev->duplex);
>
> phy_print_status()
>
>> +     mac = of_get_mac_address(pdev->dev.of_node);
>> +     if (mac)
>> +             ether_addr_copy(ndev->dev_addr, mac);
>> +
>> +     if (!is_valid_ether_addr(ndev->dev_addr)) {
>> +             eth_hw_addr_random(ndev);
>> +             dev_warn(&pdev->dev, "No MAC address found, using random\n");
>> +     }
>
> So the mac address is optional, unlike what the binding document says.
>
>> +     priv->phy_np = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
>> +     if (!priv->phy_np) {
>> +             netif_err(priv, probe, ndev, "missing phy in DT\n");
>
> It is the phy-handle which is missing, not the phy.
>
>> +
>> +     /* MTU range */
>> +     ndev->min_mtu = ETH_MIN_MTU;
>
> No need to set this, it is the default.
>
> Otherwise, this looks good, in terms of phy and mdio.
>
Will fix these.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
