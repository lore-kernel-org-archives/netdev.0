From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] sfc: refactor debug-or-warnings printks
Date: Thu, 26 Jan 2017 14:36:29 -0500 (EST)
Message-ID: <20170126.143629.337763461510725581.davem@davemloft.net>
References: <39d8923f-4400-506c-dd50-250636ff83fa@solarflare.com>
        <15f3ecb9-1785-8688-93b9-51d400ee12bc@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752397AbdAZThG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 14:37:06 -0500
In-Reply-To: <15f3ecb9-1785-8688-93b9-51d400ee12bc@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Thu, 26 Jan 2017 17:53:48 +0000

> diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
> index 5927c20..c640955 100644
> --- a/drivers/net/ethernet/sfc/net_driver.h
> +++ b/drivers/net/ethernet/sfc/net_driver.h
> @@ -51,6 +51,15 @@
>  #define EFX_WARN_ON_PARANOID(x) do {} while (0)
>  #endif
>  
> +/* if @cond then downgrade to debug, else print at @level */
> +#define netif_cond_dbg(priv, type, netdev, cond, level, fmt, args...)     \
> +	do {                                                              \
> +		if (cond)                                                 \
> +			netif_dbg(priv, type, netdev, fmt, ##args);       \
> +		else                                                      \
> +			netif_ ## level(priv, type, netdev, fmt, ##args); \
> +	} while (0)
> +
>  /**************************************************************************
>   *
>   * Efx data structures
> 

Please do not define locally in a driver an interface that looks like a generic
one and might be useful to code outside of your driver.

Thanks.
