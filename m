From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v6 11/11] of: mdio: Prevent
 of_mdiobus_register from scanning mdio-mux nodes
Date: Wed, 27 Sep 2017 16:12:13 +0200
Message-ID: <20170927141213.GF13516@lunn.ch>
References: <20170927073414.17361-1-clabbe.montjoie@gmail.com>
 <20170927073414.17361-12-clabbe.montjoie@gmail.com>
Reply-To: andrew-g2DYL2Zd6BY@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDJNHL5JSEOBBRXDV3HAKGQEY456UHQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170927073414.17361-12-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 09:34:14AM +0200, Corentin Labbe wrote:
> Each child node of an MDIO node is scanned as a PHY when calling
> of_mdiobus_register() givint the following result:
> [   18.175379] mdio_bus stmmac-0: /soc/ethernet@1c30000/mdio/mdio-mux has invalid PHY address
> [   18.175408] mdio_bus stmmac-0: scan phy mdio-mux at address 0
> [   18.175450] mdio_bus stmmac-0: scan phy mdio-mux at address 1
> [...]
> [   18.176420] mdio_bus stmmac-0: scan phy mdio-mux at address 30
> [   18.176452] mdio_bus stmmac-0: scan phy mdio-mux at address 31
> 
> Since mdio-mux nodes are not PHY, this patch a way to to not scan
> them.

Hi Corentin

I still don't like this, but ...

> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/of/of_mdio.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index d94dd8b77abd..d90ddb0d90f2 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -190,6 +190,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  	struct device_node *child;
>  	bool scanphys = false;
>  	int addr, rc;
> +	static const struct of_device_id do_not_scan[] = {
> +		{ .compatible = "mdio-mux" },
> +		{}
> +	};

Please rename this to some less generic. What i don't want is other
compatible strings added here. We want to make the exception for
muxes, but nothing else. So something like compatible_muxes?

       Andrew
