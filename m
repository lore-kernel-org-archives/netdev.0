From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: phy: Set the driver when registering an MDIO bus device
Date: Wed, 23 Jul 2014 11:26:31 -0700
Message-ID: <CAGVrzcb76YB-9VNu4HGC2ypa2iBs7LLjWT1m9WEw5CmZo84jXQ@mail.gmail.com>
References: <1406074570-13246-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1406074570-13246-2-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:38939 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932618AbaGWS1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 14:27:12 -0400
Received: by mail-oa0-f54.google.com with SMTP id n16so2170666oag.13
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 11:27:11 -0700 (PDT)
In-Reply-To: <1406074570-13246-2-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-07-22 17:16 GMT-07:00 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>:
> mdiobus_register() registers a device which is already bound to a driver.
> Hence, the driver pointer should be set properly in order to track down
> the driver associated to the MDIO bus.
>
> This will be used to allow ethernet driver to pin down a MDIO bus driver,
> preventing it from being unloaded while the PHY device is running.
>
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/mdio_bus.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 4eaadcf..203651e 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -255,6 +255,7 @@ int mdiobus_register(struct mii_bus *bus)
>
>         bus->dev.parent = bus->parent;
>         bus->dev.class = &mdio_bus_class;
> +       bus->dev.driver = bus->parent->driver;
>         bus->dev.groups = NULL;
>         dev_set_name(&bus->dev, "%s", bus->id);
>
> --
> 2.0.1
>



-- 
Florian
