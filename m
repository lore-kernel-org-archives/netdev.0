From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] net: phy: Add Speed downshift set driver
 for Microsemi PHYs.
Date: Tue, 18 Oct 2016 09:24:45 -0500
Message-ID: <20161018142445.vzpkebnmqv6y5zqa@rob-hp-laptop>
References: <1476445233-26524-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1476445233-26524-2-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org
To: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1476445233-26524-2-git-send-email-Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 14, 2016 at 05:10:32PM +0530, Raju Lakkaraju wrote:
> From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> 
> For operation in cabling environments that are incompatible with
> 1000BAST-T, VSC8531 device provides an automatic link speed
> downshift operation. When enabled, the device automatically changes
> its 1000BAST-T auto-negotiation to the next slower speed after
> a configured number of failed attempts at 1000BAST-T.
> This feature is useful in setting up in networks using older cable
> installations that include only pairs A and B, and not pairs C and D.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> Signed-off-by: Allan W. Nielsen <allan.nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> ---
>  .../devicetree/bindings/net/mscc-phy-vsc8531.txt   |  6 ++
>  drivers/net/phy/mscc.c                             | 75 +++++++++++++++++++++-
>  2 files changed, 80 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> index bdefefc6..062d115 100644
> --- a/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> +++ b/Documentation/devicetree/bindings/net/mscc-phy-vsc8531.txt
> @@ -27,6 +27,11 @@ Optional properties:
>  			  'vddmac'.
>  			  Default value is 0%.
>  			  Ref: Table:1 - Edge rate change (below).
> +- downshift-cnt		: When enabled, the device automatically changes its
> +			  1000BAST-T auto-negotiation to the next slower speed
> +			  after a 'downshift-cnt' of failed attempts at
> +			  1000BAST-T. Allowed values: 0, 2, 3, 4, 5.
> +			  0 is default and will disable downshifting.

Not sure if you are dropping this based on the discussion. Is this 
end-user controlled or a board property? Only the latter should be in 
DT.

>  
>  Table: 1 - Edge rate change
>  ----------------------------------------------------------------|
> @@ -60,4 +65,5 @@ Example:
>                  compatible = "ethernet-phy-id0007.0570";
>                  vsc8531,vddmac		= <3300>;
>                  vsc8531,edge-slowdown	= <7>;
> +                vsc8531,downshift-cnt   = <3>;

This doesn't match the above. Also, 'vsc8531' should be the vendor 
prefix, not a part number. The existing properties are fine, but fix new 
ones.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
