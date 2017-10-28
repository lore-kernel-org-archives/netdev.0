From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH] phylink: Use common error handling code in
 phylink_create()
Date: Sat, 28 Oct 2017 22:24:56 +0100
Message-ID: <20171028212456.GM20805@n2100.armlinux.org.uk>
References: <f52bdf2b-d45f-7db4-b533-d96dd3b4f6bf@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f52bdf2b-d45f-7db4-b533-d96dd3b4f6bf@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 28, 2017 at 10:00:33PM +0200, SF Markus Elfring wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 28 Oct 2017 21:48:31 +0200
> 
> * Add a jump target so that a bit of exception handling can be better
>   reused at the end of this function.
> 
> * Adjust three condition checks.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Acked-by: Russell King <rmk+kernel@armlinux.org.uk>

Thanks.

> ---
>  drivers/net/phy/phylink.c | 22 ++++++++++------------
>  1 file changed, 10 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/phy/phylink.c b/drivers/net/phy/phylink.c
> index bcb4755bcd95..67b19c13f405 100644
> --- a/drivers/net/phy/phylink.c
> +++ b/drivers/net/phy/phylink.c
> @@ -533,26 +533,24 @@ struct phylink *phylink_create(struct net_device *ndev, struct device_node *np,
>  	phylink_validate(pl, pl->supported, &pl->link_config);
>  
>  	ret = phylink_parse_mode(pl, np);
> -	if (ret < 0) {
> -		kfree(pl);
> -		return ERR_PTR(ret);
> -	}
> +	if (ret)
> +		goto free_link;
>  
>  	if (pl->link_an_mode == MLO_AN_FIXED) {
>  		ret = phylink_parse_fixedlink(pl, np);
> -		if (ret < 0) {
> -			kfree(pl);
> -			return ERR_PTR(ret);
> -		}
> +		if (ret)
> +			goto free_link;
>  	}
>  
>  	ret = phylink_register_sfp(pl, np);
> -	if (ret < 0) {
> -		kfree(pl);
> -		return ERR_PTR(ret);
> -	}
> +	if (ret)
> +		goto free_link;
>  
>  	return pl;
> +
> +free_link:
> +	kfree(pl);
> +	return ERR_PTR(ret);
>  }
>  EXPORT_SYMBOL_GPL(phylink_create);
>  
> -- 
> 2.14.3
> 

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
