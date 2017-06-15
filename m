From: Liviu Dudau <liviu@dudau.co.uk>
Subject: Re: [PATCH net-next] of_mdio: move of_mdio_parse_addr to header file
Date: Thu, 15 Jun 2017 10:45:37 +0100
Message-ID: <20170615094537.GA24982@bart.dudau.co.uk>
References: <1497365768-17627-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        Michael Ellerman <mpe@ellerman.id.au>
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1497365768-17627-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 13, 2017 at 10:56:08AM -0400, Jon Mason wrote:
> The of_mdio_parse_addr() helper function is useful to other code, but
> the module dependency chain causes issues.  To work around this, we can
> move of_mdio_parse_addr() to be an inline function in the header file.
> This gets rid of the dependencies and still allows for the reuse of
> code.

This patch fixes the modules_install issue I was seeing with module
dependency cycle.

You can add my:

Tested-by: Liviu Dudau <liviu@dudau.co.uk>

Thanks,
Liviu

> 
> Reported-by: Liviu Dudau <liviu@dudau.co.uk>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Fixes: 342fa1964439 ("mdio: mux: make child bus walking more permissive and errors more verbose")
> ---
>  drivers/of/of_mdio.c    | 22 ----------------------
>  include/linux/of_mdio.h | 24 +++++++++++++++++++++++-
>  2 files changed, 23 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 7e4c80f9b6cd..057963f2b74f 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -119,28 +119,6 @@ static void of_mdiobus_register_device(struct mii_bus *mdio,
>  		child->name, addr);
>  }
>  
> -int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
> -{
> -	u32 addr;
> -	int ret;
> -
> -	ret = of_property_read_u32(np, "reg", &addr);
> -	if (ret < 0) {
> -		dev_err(dev, "%s has invalid PHY address\n", np->full_name);
> -		return ret;
> -	}
> -
> -	/* A PHY must have a reg property in the range [0-31] */
> -	if (addr >= PHY_MAX_ADDR) {
> -		dev_err(dev, "%s PHY address %i is too large\n",
> -			np->full_name, addr);
> -		return -EINVAL;
> -	}
> -
> -	return addr;
> -}
> -EXPORT_SYMBOL(of_mdio_parse_addr);
> -
>  /* The following is a list of PHY compatible strings which appear in
>   * some DTBs. The compatible string is never matched against a PHY
>   * driver, so is pointless. We only expect devices which are not PHYs
> diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
> index ba35ba520487..f5db93bcd069 100644
> --- a/include/linux/of_mdio.h
> +++ b/include/linux/of_mdio.h
> @@ -27,11 +27,33 @@ struct phy_device *of_phy_attach(struct net_device *dev,
>  				 phy_interface_t iface);
>  
>  extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
> -extern int of_mdio_parse_addr(struct device *dev, const struct device_node *np);
>  extern int of_phy_register_fixed_link(struct device_node *np);
>  extern void of_phy_deregister_fixed_link(struct device_node *np);
>  extern bool of_phy_is_fixed_link(struct device_node *np);
>  
> +
> +static inline int of_mdio_parse_addr(struct device *dev,
> +				     const struct device_node *np)
> +{
> +	u32 addr;
> +	int ret;
> +
> +	ret = of_property_read_u32(np, "reg", &addr);
> +	if (ret < 0) {
> +		dev_err(dev, "%s has invalid PHY address\n", np->full_name);
> +		return ret;
> +	}
> +
> +	/* A PHY must have a reg property in the range [0-31] */
> +	if (addr >= PHY_MAX_ADDR) {
> +		dev_err(dev, "%s PHY address %i is too large\n",
> +			np->full_name, addr);
> +		return -EINVAL;
> +	}
> +
> +	return addr;
> +}
> +
>  #else /* CONFIG_OF_MDIO */
>  static inline int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  {
> -- 
> 2.7.4
> 

-- 
   _
 _|_|_
 ('_')
 (⊃  )⊃
 |_|_|
