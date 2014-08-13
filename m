From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Wed, 13 Aug 2014 23:19:42 +0200
Message-ID: <20140813211941.GB4840@netboy>
References: <1407905705-27984-1-git-send-email-b38611@freescale.com>
 <1407905705-27984-2-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shawn.guo@linaro.org, davem@davemloft.net, netdev@vger.kernel.org
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:42257 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132AbaHMVTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 17:19:55 -0400
Received: by mail-we0-f178.google.com with SMTP id w61so290189wes.37
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 14:19:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1407905705-27984-2-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2014 at 12:55:05PM +0800, Fugang Duan wrote:

> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 66fe1f6..8befa2c 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -2198,6 +2198,8 @@ fec_enet_open(struct net_device *ndev)
>  	napi_enable(&fep->napi);
>  	phy_start(fep->phy_dev);
>  	netif_start_queue(ndev);
> +	if (fep->hwts_tx_en)
> +		schedule_delayed_work(&fep->time_keep, HZ);
>  	return 0;
>  }
>  
> @@ -2206,6 +2208,9 @@ fec_enet_close(struct net_device *ndev)
>  {
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  
> +	if (fep->hwts_tx_en)
> +		cancel_delayed_work_sync(&fep->time_keep);

You make the clock logic depend on whether time stamping is enabled or
not. Why do you do that?

The clock should keep ticking, even if time stamping is disabled.

Thanks,
Richard
