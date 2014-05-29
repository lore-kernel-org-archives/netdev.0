From: Tushar Behera <trblinux@gmail.com>
Subject: Re: [PATCH net-next v1] mrf24j40: add managed API's provided by
 device layer
Date: Thu, 29 May 2014 12:02:37 +0530
Message-ID: <20140529063236.GA9679@linaro.org>
References: <1401338421-15394-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@signal11.us, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, alex.aing@gmail.com,
	Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:54734 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbaE2Gcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 02:32:45 -0400
Content-Disposition: inline
In-Reply-To: <1401338421-15394-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2014 at 10:10:21AM +0530, Varka Bhadram wrote:
> Hi,
> 	Previous patch having bug in using managed API's. I fixed that.
> 
> Regards,
> Varka Bhadram.

Only add relevant commit message here, no need to add 'Hi' and
'Regards'.

Something like ...

"Added devres managed APIs"

> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>  drivers/net/ieee802154/mrf24j40.c |   21 +++++++++------------
>  1 file changed, 9 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
> index 78a6552..f701cdb 100644
> --- a/drivers/net/ieee802154/mrf24j40.c
> +++ b/drivers/net/ieee802154/mrf24j40.c
> @@ -618,10 +618,10 @@ static int mrf24j40_probe(struct spi_device *spi)
>  
>  	printk(KERN_INFO "mrf24j40: probe(). IRQ: %d\n", spi->irq);
>  
> -	devrec = kzalloc(sizeof(struct mrf24j40), GFP_KERNEL);
> +	devrec = devm_kzalloc(&spi->dev, sizeof(struct mrf24j40), GFP_KERNEL);
>  	if (!devrec)
>  		goto err_devrec;
> -	devrec->buf = kzalloc(3, GFP_KERNEL);
> +	devrec->buf = kzalloc(&spi->dev, 3, GFP_KERNEL);

devm_kzalloc()

Without this, it should not build at all. So remember to compile test
before sending the patches.

--
Warm regards,
Tushar
