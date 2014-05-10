From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/3] net: of_mdio: factor out code to parse a phy's 'reg'
 property
Date: Sun, 11 May 2014 00:29:02 +0400
Message-ID: <536E8C0E.3040407@cogentembedded.com>
References: <1399739875-16434-1-git-send-email-zonque@gmail.com> <1399739875-16434-2-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com
To: Daniel Mack <zonque@gmail.com>, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:46209 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038AbaEJU2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 16:28:47 -0400
Received: by mail-la0-f44.google.com with SMTP id hr17so846830lab.31
        for <netdev@vger.kernel.org>; Sat, 10 May 2014 13:28:45 -0700 (PDT)
In-Reply-To: <1399739875-16434-2-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/10/2014 08:37 PM, Daniel Mack wrote:

> Factor out some logic into of_mdio_parse_addr() so it can be reused
> later.

> Signed-off-by: Daniel Mack <zonque@gmail.com>
> ---
>   drivers/of/of_mdio.c | 37 +++++++++++++++++++++++++------------
>   1 file changed, 25 insertions(+), 12 deletions(-)

> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 9a95831..171f9d5 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -114,6 +114,29 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>   	return 0;
>   }
>
> +static int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
> +{
> +	const __be32 *paddr;
> +	u32 addr;
> +	int len;
> +
> +	/* A PHY must have a reg property in the range [0-31] */
> +	paddr = of_get_property(np, "reg", &len);
> +	if (!paddr || len < sizeof(*paddr)) {
> +		dev_err(dev, "%s has invalid PHY address\n", np->full_name);
> +		return -EINVAL;
> +	}
> +
> +	addr = be32_to_cpup(paddr);

    Why not just use of_property_read_u32() instead of the above? At least 
that's a material for a follow-up patch...

> +	if (addr >= PHY_MAX_ADDR) {
> +		dev_err(dev, "%s PHY address %i is too large\n",
> +			np->full_name, addr);
> +		return -EINVAL;
> +	}
> +
> +	return addr;
> +}
> +
>   /**
>    * of_mdiobus_register - Register mii_bus and create PHYs from the device tree
>    * @mdio: pointer to mii_bus structure
[...]

WBR, Sergei
