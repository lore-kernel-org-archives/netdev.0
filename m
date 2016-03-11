From: Vladimir Zapolskiy <vz-ChpfBGZJDbMAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] of_mdio: use IS_ERR_OR_NULL()
Date: Sat, 12 Mar 2016 00:53:10 +0200
Message-ID: <56E34C56.10300@mleia.com>
References: <4882738.uyje2ICxKW@wasted.cogentembedded.com>
 <3305414.rAFdOb57tB@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3305414.rAFdOb57tB-gHKXc3Y1Z8zGSmamagVegGFoWSdPRAKMAL8bYrjMMd8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Sergei,

On 12.03.2016 00:12, Sergei Shtylyov wrote:
> IS_ERR_OR_NULL() is open coded in of_mdiobus_register_{phy|device}(), so
> just call it directly...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
> 
> ---
>  drivers/of/of_mdio.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> Index: net-next/drivers/of/of_mdio.c
> ===================================================================
> --- net-next.orig/drivers/of/of_mdio.c
> +++ net-next/drivers/of/of_mdio.c
> @@ -56,7 +56,7 @@ static int of_mdiobus_register_phy(struc
>  		phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
>  	else
>  		phy = get_phy_device(mdio, addr, is_c45);
> -	if (!phy || IS_ERR(phy))
> +	if (IS_ERR_OR_NULL(phy))
>  		return 1;
>  
>  	rc = irq_of_parse_and_map(child, 0);
> @@ -98,7 +98,7 @@ static int of_mdiobus_register_device(st
>  	int rc;
>  
>  	mdiodev = mdio_device_create(mdio, addr);
> -	if (!mdiodev || IS_ERR(mdiodev))
> +	if (IS_ERR_OR_NULL(mdiodev))
>  		return 1;
>  

I don't see how it is possible for mdio_device_create() to return NULL,
instead of this change consider to remove if (!mdiodev) check.

>  	/* Associate the OF node with the device structure so it
> 

--
With best wishes,
Vladimir
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
