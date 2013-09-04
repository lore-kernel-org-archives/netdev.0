From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch v2] sfc: check for allocation failure
Date: Wed, 4 Sep 2013 16:51:07 +0100
Message-ID: <1378309867.3133.10.camel@bwh-desktop.uk.level5networks.com>
References: <20130904150727.GA32327@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	<netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8086 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab3IENwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 09:52:49 -0400
In-Reply-To: <20130904150727.GA32327@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-04 at 18:07 +0300, Dan Carpenter wrote:
> It upsets static analyzers when we don't check for allocation failure.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
> v2: rebased on latest linux-next
> 
> diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
> index 38d179c..75799f8 100644
> --- a/drivers/net/ethernet/sfc/falcon.c
> +++ b/drivers/net/ethernet/sfc/falcon.c
> @@ -894,6 +894,8 @@ static int falcon_mtd_probe(struct efx_nic *efx)
>  
>  	/* Allocate space for maximum number of partitions */
>  	parts = kcalloc(2, sizeof(*parts), GFP_KERNEL);
> +	if (!parts)
> +		return -ENOMEM;
>  	n_parts = 0;
>  
>  	spi = &nic_data->spi_flash;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
