From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/4] sfc: resolve tx multiqueue bug
Date: Fri, 18 Jul 2008 19:49:26 +0100
Message-ID: <20080718184925.GJ10471@solarflare.com>
References: <20080718175911.GF10471@solarflare.com> <20080718180156.GH10471@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.mbr-roch.zen.net.uk ([212.23.3.142]:50434 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755004AbYGRSt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 14:49:28 -0400
Content-Disposition: inline
In-Reply-To: <20080718180156.GH10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> With the recent changes to tx multiqueue, sfc was not calling
> netif_start_queue() before calling netif_wake_queue().
> This causes an oops when opening a device.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/tx.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
> index 5cdd082..798b06b 100644
> --- a/drivers/net/sfc/tx.c
> +++ b/drivers/net/sfc/tx.c
> @@ -53,6 +53,7 @@ inline void efx_wake_queue(struct efx_nic *efx)
>  	if (atomic_dec_and_lock(&efx->netif_stop_count,
>  				&efx->netif_stop_lock)) {
>  		EFX_TRACE(efx, "waking TX queue\n");
> +		netif_start_queue(efx->net_dev);
>  		netif_wake_queue(efx->net_dev);
>  		spin_unlock(&efx->netif_stop_lock);
>  	}

Ahem... ignore this, it's obviously not right.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
