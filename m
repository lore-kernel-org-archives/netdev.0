From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v2 2/3] of_mdio: use IS_ERR_OR_NULL()
Date: Sun, 13 Mar 2016 23:22:54 +0100
Message-ID: <4173235.nHpIx7Ti2k@wuerfel>
References: <2682275.WNlbxTfNal@wasted.cogentembedded.com> <2638820.ej0i0xi4Er@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2638820.ej0i0xi4Er-gHKXc3Y1Z8zGSmamagVegGFoWSdPRAKMAL8bYrjMMd8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 13 March 2016 00:34:02 Sergei Shtylyov wrote:
> IS_ERR_OR_NULL() is open coded in of_mdiobus_register_phy(), so just call
> it directly...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
> Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> ---
> Changes in version 2:
> - removed the of_mdiobus_register_device() hunk;
> - added the "Reviewed-by:" tag.
> 
>  drivers/of/of_mdio.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: net-next/drivers/of/of_mdio.c
> ===================================================================
> --- net-next.orig/drivers/of/of_mdio.c
> +++ net-next/drivers/of/of_mdio.c
> @@ -56,7 +56,7 @@ static int of_mdiobus_register_phy(struc
>                 phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
>         else
>                 phy = get_phy_device(mdio, addr, is_c45);
> -       if (!phy || IS_ERR(phy))
> +       if (IS_ERR_OR_NULL(phy))
>                 return 1;
>  
>         rc = irq_of_parse_and_map(child, 0);
> 
> 

IS_ERR_OR_NULL() usually indicates that the code is wrong, or that
an API has been misdesigned.

Can you clarify in the changelog which one it is, or (better) change
it so that 'phy' in this function is either NULL or IS_ERR() in case
of an error but not both?

I think moving the 'if (problem) return 1' into the two if/else
is a correct transformation that also makes it very clear what
is going on here.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
