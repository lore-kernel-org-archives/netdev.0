From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] mdio_bus: Fix MDIO bus scanning in
 __mdiobus_register()
Date: Sun, 01 May 2016 20:50:31 -0400 (EDT)
Message-ID: <20160501.205031.116469285201732756.davem@davemloft.net>
References: <1462150051-6308-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de,
	dinguyen@opensource.altera.com, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com
To: marex@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436AbcEBAue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 20:50:34 -0400
In-Reply-To: <1462150051-6308-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Vasut <marex@denx.de>
Date: Mon,  2 May 2016 02:47:31 +0200

> Since commit b74766a0a0fe ("phylib: don't return NULL
> from get_phy_device()") in linux-next, phy_get_device() will return
> ERR_PTR(-ENODEV) instead of NULL if the PHY device ID is all ones.
> 
> This causes problem with stmmac driver and likely some other drivers
> which call mdiobus_register(). I triggered this bug on SoCFPGA MCVEVK
> board with linux-next 20160427 and 20160428. In case of the stmmac, if
> there is no PHY node specified in the DT for the stmmac block, the stmmac
> driver ( drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c function
> stmmac_mdio_register() ) will call mdiobus_register() , which will
> register the MDIO bus and probe for the PHY.
> 
> The mdiobus_register() resp. __mdiobus_register() iterates over all of
> the addresses on the MDIO bus and calls mdiobus_scan() for each of them,
> which invokes get_phy_device(). Before the aforementioned patch, the
> mdiobus_scan() would return NULL if no PHY was found on a given address
> and mdiobus_register() would continue and try the next PHY address. Now,
> mdiobus_scan() returns ERR_PTR(-ENODEV), which is caught by the
> 'if (IS_ERR(phydev))' condition and the loop exits immediately if the
> PHY address does not contain PHY.
> 
> Repair this by explicitly checking for the ERR_PTR(-ENODEV) and if this
> error comes around, continue with the next PHY address.
> 
> Signed-off-by: Marek Vasut <marex@denx.de>
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
