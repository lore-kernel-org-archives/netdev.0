From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 3/9] ARM: sun8i: dt: Add DT bindings documentation for
 Allwinner sun8i-emac
Date: Mon, 12 Sep 2016 17:15:16 +0200
Message-ID: <20160912151516.GJ11400@lunn.ch>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-4-git-send-email-clabbe.montjoie@gmail.com>
 <20160909140413.GD30871@lunn.ch>
 <20160912150125.GA15570@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        devicetree@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41735 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759530AbcILPPc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 11:15:32 -0400
Content-Disposition: inline
In-Reply-To: <20160912150125.GA15570@Red>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hello
> 

> Since the MDIO bus is a part of the sun8i-emac, does I really need
> to create such a mdio node ?

It is good practice. Part of the issue is that there are no written
guidelines, so different drivers do different things. I'm trying to
push all new drivers to have an MDIO node.

> Anyway I try the following patch to solve your comments, but it
> breaks the PHY finding(Could not attach to PHY).

> --- a/drivers/net/ethernet/allwinner/sun8i-emac.c
> +++ b/drivers/net/ethernet/allwinner/sun8i-emac.c
> @@ -2122,7 +2122,7 @@ static int sun8i_emac_probe(struct platform_device *pdev)
>                 return -EINVAL;
>         }
>  
> -       priv->phy_node = of_parse_phandle(node, "phy", 0);
> +       priv->phy_node = of_parse_phandle(node, "phy-handle", 0);
>         if (!priv->phy_node) {
>                 netdev_err(ndev, "No associated PHY\n");
>                 return -ENODEV;
> 
>  
>  &crypto {
> 


I don't see a change here for of_mdiobus_register(). You need to pass
the mdio node.

    Andrew
