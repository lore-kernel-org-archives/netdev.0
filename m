From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next] of: of_mdio: Check if MDIO bus controller is
 available
Date: Fri, 29 Apr 2016 00:07:40 +0200
Message-ID: <20160428220740.GD12753@lunn.ch>
References: <1461880510-27132-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	nathan.sullivan-acOepvfBmUk@public.gmane.org, nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE"
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1461880510-27132-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2016 at 02:55:10PM -0700, Florian Fainelli wrote:
> Add a check whether the 'struct device_node' pointer passed to
> of_mdiobus_register() is an available (aka enabled) node in the Device
> Tree.
> 
> Rationale for doing this are cases where an Ethernet MAC provides a MDIO
> bus controller and node, and an additional Ethernet MAC might be
> connecting its PHY/switches to that first MDIO bus controller, while
> still embedding one internally which is therefore marked as "disabled".
> 
> Instead of sprinkling checks like these in callers of
> of_mdiobus_register(), do this in a central location.
> 
> Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> ---
>  drivers/of/of_mdio.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index b622b33dbf93..2f497790be1b 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -209,6 +209,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  	bool scanphys = false;
>  	int addr, rc;
>  
> +	/* Do not continue if the node is disabled */
> +	if (!of_device_is_available(np))
> +		return -EINVAL;

Could be bike shedding, but would ENODEV be better?

Some callers are going to have to look at the return value and decide
if it is a fatal error, and fail the whole probe, or a non-fatal error
and they should keep going. ENODEV seems less fatal...

Other than that,

Reviewed-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
