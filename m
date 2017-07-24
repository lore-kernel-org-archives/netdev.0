From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH 2/2] ftgmac100: Make the MDIO bus a child of the ethernet device
Date: Mon, 24 Jul 2017 22:43:43 +0930
Message-ID: <CACPK8XcHYHB128nesCLNzDkhNyuFoRgizi=WAqwr0PWcX_bOMQ@mail.gmail.com>
References: <1500879547.10674.63.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Joel Stanley <joel.stanley@au1.ibm.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:38524 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752815AbdGXNOE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:14:04 -0400
Received: by mail-yw0-f196.google.com with SMTP id p68so957455ywg.5
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 06:14:04 -0700 (PDT)
In-Reply-To: <1500879547.10674.63.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 4:29 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> Populate mii_bus->parent with our own platform device before
> registering, which makes it easier to locate the MDIO bus
> in sysfs when trying to diagnose problems.
>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Acked-by: Joel Stanley <joel@jms.id.au>

> ---
>  drivers/net/ethernet/faraday/ftgmac100.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index 2b17f7023d91..fce0aa4f78b7 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -1682,6 +1682,7 @@ static int ftgmac100_setup_mdio(struct net_device *netdev)
>         priv->mii_bus->name = "ftgmac100_mdio";
>         snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "%s-%d",
>                  pdev->name, pdev->id);
> +       priv->mii_bus->parent = priv->dev;
>         priv->mii_bus->priv = priv->netdev;
>         priv->mii_bus->read = ftgmac100_mdiobus_read;
>         priv->mii_bus->write = ftgmac100_mdiobus_write;
>
