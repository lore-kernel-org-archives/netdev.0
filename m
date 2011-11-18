From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: Use kmemdup rather than duplicating its
 implementation
Date: Fri, 18 Nov 2011 15:47:22 +0000
Message-ID: <1321631242.2885.118.camel@deadeye>
References: <1321571135.1624.313.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Thomas Meyer <thomas@m3y3r.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321571135.1624.313.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-11-18 at 00:05 +0100, Thomas Meyer wrote:
> The semantic patch that makes this change is available
> in scripts/coccinelle/api/memdup.cocci.
> 
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
> ---

The one-line description should refer to 'gianfar', not 'ethtool'.
(I expect David will fix this up.)

Ben.

> diff -u -p a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c 2011-11-07 19:37:57.036756543 +0100
> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c 2011-11-08 10:42:14.842512269 +0100
> @@ -1410,10 +1410,9 @@ static int gfar_optimize_filer_masks(str
>  
>  	/* We need a copy of the filer table because
>  	 * we want to change its order */
> -	temp_table = kmalloc(sizeof(*temp_table), GFP_KERNEL);
> +	temp_table = kmemdup(tab, sizeof(*temp_table), GFP_KERNEL);
>  	if (temp_table == NULL)
>  		return -ENOMEM;
> -	memcpy(temp_table, tab, sizeof(*temp_table));
>  
>  	mask_table = kcalloc(MAX_FILER_CACHE_IDX / 2 + 1,
>  			sizeof(struct gfar_mask_entry), GFP_KERNEL);
> 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
