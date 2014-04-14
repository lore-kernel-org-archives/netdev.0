From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net] sfc:On MCDI timeout, issue an FLR (and mark MCDI
 to fail-fast)
Date: Mon, 14 Apr 2014 16:02:54 +0100
Message-ID: <534BF89E.5020603@solarflare.com>
References: <534BF37F.6020604@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>,
	Robert Stonehouse <rstonehouse@solarflare.com>
To: Shradha Shah <sshah@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36913 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbaDNPDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 11:03:00 -0400
In-Reply-To: <534BF37F.6020604@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/04/14 15:41, Shradha Shah wrote:
> diff --git a/drivers/net/ethernet/sfc/enum.h b/drivers/net/ethernet/sfc/enum.h
> index 75ef7ef..70c2473 100644
> --- a/drivers/net/ethernet/sfc/enum.h
> +++ b/drivers/net/ethernet/sfc/enum.h
> @@ -165,7 +168,14 @@ enum reset_type {
>  	RESET_TYPE_DMA_ERROR,
>  	RESET_TYPE_TX_SKIP,
>  	RESET_TYPE_MC_FAILURE,
> -	RESET_TYPE_MC_BIST,
> +	/* RESET_TYPE_MC_BIST and RESET_TYPE_MCDI_TIMEOUT are actually methods,
> +	 * not just reasons, but they don't fit the scope hierarchy (they're
> +	 * not well-ordered by inclusion)
> +	 * We encode this by having their enum values be greater than
> +	 * RESET_TYPE_MAX_METHOD.  This also prevents issuing them with
> +	 * efx_ioctl_reset
> +	 */
> +	RESET_TYPE_MCDI_TIMEOUT,
>  	RESET_TYPE_MAX,
>  };
>  
Looks like I messed up this comment; this is only true of
RESET_TYPE_MCDI_TIMEOUT, not RESET_TYPE_MC_BIST.
So should be something like:

    /* RESET_TYPE_MCDI_TIMEOUT is actually a method, not just a reason, but
    * it doesn't fit the scope hierarchy (not well-ordered by inclusion).
    * We encode this by having its enum value be greater than
    * RESET_TYPE_MAX_METHOD. This also prevents issuing it with
    * efx_ioctl_reset.
    */

-Edward
