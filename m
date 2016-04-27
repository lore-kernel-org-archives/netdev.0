From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/5] phylib: don't return NULL from get_phy_device()
Date: Thu, 28 Apr 2016 00:07:22 +0200
Message-ID: <6742276.xmgnFOC4z8@wuerfel>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com> <20160427194932.GF29024@lunn.ch> <57213371.1020905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, kernel@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:55956 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbcD0WHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 18:07:43 -0400
In-Reply-To: <57213371.1020905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 27 April 2016 14:47:29 Florian Fainelli wrote:
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 499003ee8055..94a27b028dd8 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -333,7 +333,7 @@ int __mdiobus_register(struct mii_bus *bus, struct
> module *owner)
>                         struct phy_device *phydev;
> 
>                         phydev = mdiobus_scan(bus, i);
> -                       if (IS_ERR(phydev)) {
> +                       if (IS_ERR(phydev) && PTR_ERR(phydev) != -ENODEV) {
>                                 err = PTR_ERR(phydev);
>                                 goto error;
>                         }
> 
> 

I think that is an improvement over the original code, and better than
reverting the series. Out of the three callers of mdiobus_scan, I already
commented on drivers/net/ethernet/marvell/pxa168_eth.c being wrong to
start with, and drivers/net/ethernet/cadence/macb.c seems to require
the same fix that you did here for mdio_bus.c

	Arnd
