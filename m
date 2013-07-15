From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [RFC PATCH 2/3] net: phy: call mdiobus_scan() after adding a
 fixed PHY
Date: Mon, 15 Jul 2013 16:46:05 +0100
Message-ID: <CAGVrzcbn0FASWBbj-zF+pYnUATm02tUurN_wM0YWrWrTBh+dJQ@mail.gmail.com>
References: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1373902450-11857-3-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	netdev <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:38445 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932339Ab3GOPqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 11:46:47 -0400
Received: by mail-pd0-f173.google.com with SMTP id v14so10840458pde.4
        for <netdev@vger.kernel.org>; Mon, 15 Jul 2013 08:46:46 -0700 (PDT)
In-Reply-To: <1373902450-11857-3-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

2013/7/15 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>:
> The fixed_phy_add() function allows to register a fixed PHY. However,
> when this function gets called *after* fixed_mdio_bus_init() (which
> gets called at the module_init stage), then the fixed PHY is not
> registered into the phylib.
>
> In order to address this, we add a call to mdiobus_scan() in
> fixed_phy_add() to ensure that the PHY indeed gets registered into the
> phylib, even if the fixed_phy_add() is called after
> fixed_mdio_bus_init().
>
> This is needed because until now, the only code that was calling the
> fixed_add_phy() function was PowerPC-specific platform code, which
> could ensure that such fixed PHYs get registered before
> fixed_mdio_bus_init() is called.

arch/mips/ar7/platform.c also calls fixed_phy_add() early enough as
well to ensure that we do not need to rescan the MDIO bus. There is
also another user: arch/m68k/platform/coldfire/m5272.c

>
> However, with the new of_phy_register_fixed_link() function, device
> drivers can parse their 'fixed-link' property and register a fixed PHY
> at ->probe() time, which may happen after fixed_mdio_bus_init() is
> called.
>
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Reviewed-by: Florian Fainelli <florian@openwrt.org>

> ---
>  drivers/net/phy/fixed.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
> index ba55adf..bd1e67a 100644
> --- a/drivers/net/phy/fixed.c
> +++ b/drivers/net/phy/fixed.c
> @@ -195,6 +195,8 @@ int fixed_phy_add(unsigned int irq, int phy_id,
>
>         list_add_tail(&fp->node, &fmb->phys);
>
> +       mdiobus_scan(fmb->mii_bus, phy_id);
> +
>         return 0;
>
>  err_regs:
> --
> 1.8.1.2
>



--
Florian
