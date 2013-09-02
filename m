From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch] sfc: check for allocation failure
Date: Mon, 2 Sep 2013 18:00:54 +0100
Message-ID: <1378141254.1552.0.camel@bwh-desktop.uk.level5networks.com>
References: <20130902082828.GA30037@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	<netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30196 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756557Ab3IBRBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 13:01:03 -0400
In-Reply-To: <20130902082828.GA30037@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-02 at 12:04 +0300, Dan Carpenter wrote:
> It upsets static analyzers when we don't check for allocation failure.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Thanks Dan.

Ben.

> diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
> index ba6c87a..aac6897 100644
> --- a/drivers/net/ethernet/sfc/mtd.c
> +++ b/drivers/net/ethernet/sfc/mtd.c
> @@ -384,6 +384,8 @@ static int falcon_mtd_probe(struct efx_nic *efx)
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
