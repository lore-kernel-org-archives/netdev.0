From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/3] netdev/phy/of: Handle IEEE802.3 clause 45 Ethernet
 PHYs in of_mdiobus_register()
Date: Wed, 12 Oct 2011 18:23:25 -0600
Message-ID: <20111013002325.GB14042@ponder.secretlab.ca>
References: <1318442783-29058-1-git-send-email-david.daney@cavium.com>
 <1318442783-29058-3-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, afleming@gmail.com
To: David Daney <david.daney@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1318442783-29058-3-git-send-email-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 12, 2011 at 11:06:22AM -0700, David Daney wrote:
> Define two new "compatible" values for Ethernet
> PHYs. "ethernet-phy-ieee802.3-c22" and "ethernet-phy-ieee802.3-c45"
> are used to indicate a PHY uses the corresponding protocol.
> 
> If a PHY is "compatible" with "ethernet-phy-ieee802.3-c45", we
> indicate this so that get_phy_device() can properly probe the device.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

I'm okay with this binding.  I'd like to get opinions from other
developers before it is committed to though.

Acked-by: Grant Likely <grant.likely@secretlab.ca>

g.

> ---
>  Documentation/devicetree/bindings/net/phy.txt |   12 +++++++++++-
>  drivers/of/of_mdio.c                          |    4 ++++
>  2 files changed, 15 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
> index bb8c742..de9cb32 100644
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -16,8 +16,18 @@ Required properties:
>  
>  Example:
>  
> +Optional Properties:
> +
> +- compatible: Compatible list, may contain "ethernet-phy-ieee802.3-c22" or
> +              "ethernet-phy-ieee802.3-c45" for PHYs that implement
> +              IEEE802.3 clause 22 or IEEE802.3 clause 45
> +              specifications.  If neither of these are specified, the
> +              default is to assume clause 22.  The compatible list may
> +              also contain other elements.
> +
>  ethernet-phy@0 {
> -	linux,phandle = <2452000>
> +	compatible = "ethernet-phy-ieee802.3-c22";
> +	linux,phandle = <2452000>;
>  	interrupt-parent = <40000>;
>  	interrupts = <35 1>;
>  	reg = <0>;
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 7c28e8c..f837a7f 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -79,6 +79,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  				mdio->irq[addr] = PHY_POLL;
>  		}
>  
> +		if (of_device_is_compatible(child,
> +					    "ethernet-phy-ieee802.3-c45"))
> +			addr |= MII_ADDR_C45;
> +
>  		phy = get_phy_device(mdio, addr);
>  		if (!phy || IS_ERR(phy)) {
>  			dev_err(&mdio->dev, "error probing PHY at address %i\n",
> -- 
> 1.7.2.3
> 
