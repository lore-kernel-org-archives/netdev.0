From: Vladimir Zapolskiy <vz@mleia.com>
Subject: Re: [PATCH 2/2] of_mdio: use PTR_ERR_OR_ZERO()
Date: Sat, 12 Mar 2016 01:02:00 +0200
Message-ID: <56E34E68.4070502@mleia.com>
References: <4882738.uyje2ICxKW@wasted.cogentembedded.com>
 <11956015.EKV4zhDQJ5@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mleia.com ([178.79.152.223]:58846 "EHLO mail.mleia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932683AbcCKXCD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 18:02:03 -0500
In-Reply-To: <11956015.EKV4zhDQJ5@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Sergei,

On 12.03.2016 00:13, Sergei Shtylyov wrote:
> PTR_ERR_OR_ZERO() is open coded in of_phy_register_fixed_link(), so just
> call it directly...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
>  drivers/of/of_mdio.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> Index: net-next/drivers/of/of_mdio.c
> ===================================================================
> --- net-next.orig/drivers/of/of_mdio.c
> +++ net-next/drivers/of/of_mdio.c
> @@ -412,7 +412,7 @@ int of_phy_register_fixed_link(struct de
>  		if (strcmp(managed, "in-band-status") == 0) {
>  			/* status is zeroed, namely its .link member */
>  			phy = fixed_phy_register(PHY_POLL, &status, -1, np);
> -			return IS_ERR(phy) ? PTR_ERR(phy) : 0;
> +			return PTR_ERR_OR_ZERO(phy);
>  		}
>  	}
>  
> @@ -434,7 +434,7 @@ int of_phy_register_fixed_link(struct de
>  			return -EPROBE_DEFER;
>  
>  		phy = fixed_phy_register(PHY_POLL, &status, link_gpio, np);
> -		return IS_ERR(phy) ? PTR_ERR(phy) : 0;
> +		return PTR_ERR_OR_ZERO(phy);
>  	}
>  
>  	/* Old binding */
> @@ -446,7 +446,7 @@ int of_phy_register_fixed_link(struct de
>  		status.pause = be32_to_cpu(fixed_link_prop[3]);
>  		status.asym_pause = be32_to_cpu(fixed_link_prop[4]);
>  		phy = fixed_phy_register(PHY_POLL, &status, -1, np);
> -		return IS_ERR(phy) ? PTR_ERR(phy) : 0;
> +		return PTR_ERR_OR_ZERO(phy);
>  	}
>  
>  	return -ENODEV;
> 

Reviewed-by: Vladimir Zapolskiy <vz@mleia.com>
