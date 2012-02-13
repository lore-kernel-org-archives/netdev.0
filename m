From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: mtd: Use MTD_FAIL_ADDR_UNKNOWN instead of
 0xffffffff
Date: Mon, 13 Feb 2012 16:15:39 +0000
Message-ID: <1329149739.2697.0.camel@bwh-desktop>
References: <20120212111308.0267f200@pixies.home.jungo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	<linux-mtd@lists.infradead.org>, <netdev@vger.kernel.org>,
	Artem Bityutskiy <dedekind1@gmail.com>,
	David Miller <davem@davemloft.net>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12119 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757085Ab2BMQPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 11:15:47 -0500
In-Reply-To: <20120212111308.0267f200@pixies.home.jungo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-02-12 at 11:13 +0200, Shmulik Ladkani wrote:
> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
> As of bb0eb217, MTD_FAIL_ADDR_UNKNOWN should be used to indicate mtd
> erase failure not specific to any particular block.
> 
> Use MTD_FAIL_ADDR_UNKNOWN instead of 0xffffffff when setting
> 'erase->fail_addr' in 'efx_mtd_erase()'.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Acked-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
> diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
> index 6622eca..c44a03e 100644
> --- a/drivers/net/ethernet/sfc/mtd.c
> +++ b/drivers/net/ethernet/sfc/mtd.c
> @@ -193,7 +193,7 @@ static int efx_mtd_erase(struct mtd_info *mtd, struct erase_info *erase)
>  		erase->state = MTD_ERASE_DONE;
>  	} else {
>  		erase->state = MTD_ERASE_FAILED;
> -		erase->fail_addr = 0xffffffff;
> +		erase->fail_addr = MTD_FAIL_ADDR_UNKNOWN;
>  	}
>  	mtd_erase_callback(erase);
>  	return rc;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
