From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH net] Altera TSE: Fix sparse errors and warnings
Date: Fri, 9 May 2014 17:27:52 +0200
Message-ID: <20140509152752.GN6455@distanz.ch>
References: <1399572940-32233-1-git-send-email-vbridgers2013@gmail.com>
 <1399572940-32233-2-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:33084 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987AbaEIP1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 11:27:54 -0400
Content-Disposition: inline
In-Reply-To: <1399572940-32233-2-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-05-08 at 20:15:40 +0200, Vince Bridgers <vbridgers2013@gmail.com> wrote:
[...]
> diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
> index e44a4ae..d1d35f5 100644
> --- a/drivers/net/ethernet/altera/altera_tse_main.c
> +++ b/drivers/net/ethernet/altera/altera_tse_main.c
[...]
> @@ -1362,6 +1376,11 @@ static int altera_tse_probe(struct platform_device *pdev)
>  		of_property_read_bool(pdev->dev.of_node,
>  				      "altr,has-hash-multicast-filter");
>  
> +	/* Set hash filter to not set for now until the
> +	 * multicast filter receive issue is debugged
> +	 */
> +	priv->hash_filter = 0;
> +

This doesn't seem to be related to the sparse/cppcheck cleanup.
Shouldn't this be an own patch?

>  	/* get supplemental address settings for this instance */
>  	priv->added_unicast =
>  		of_property_read_bool(pdev->dev.of_node,
> @@ -1493,7 +1512,7 @@ static int altera_tse_remove(struct platform_device *pdev)
>  	return 0;
>  }
>  
> -struct altera_dmaops altera_dtype_sgdma = {
> +static struct altera_dmaops altera_dtype_sgdma = {

This can probably also be made const.

>  	.altera_dtype = ALTERA_DTYPE_SGDMA,
>  	.dmamask = 32,
>  	.reset_dma = sgdma_reset,
> @@ -1512,7 +1531,7 @@ struct altera_dmaops altera_dtype_sgdma = {
>  	.start_rxdma = sgdma_start_rxdma,
>  };
>  
> -struct altera_dmaops altera_dtype_msgdma = {
> +static struct altera_dmaops altera_dtype_msgdma = {

Ditto.

Cheers
Tobias
