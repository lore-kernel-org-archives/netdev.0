From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 18/51] DMA-API: staging: et131x: replace
 dma_set_mask()+dma_set_coherent_mask() with new helper
Date: Fri, 20 Sep 2013 16:42:08 +0100
Message-ID: <1379691728.1681.15.camel@bwh-desktop.uk.level5networks.com>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
	 <E1VMm05-0007hG-5T@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <devel@driverdev.osuosl.org>, netdev <netdev@vger.kernel.org>
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53370 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675Ab3ITPmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 11:42:12 -0400
In-Reply-To: <E1VMm05-0007hG-5T@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Trimmed cc's]

On Thu, 2013-09-19 at 22:43 +0100, Russell King wrote:
> Replace the following sequence:
> 
> 	dma_set_mask(dev, mask);
> 	dma_set_coherent_mask(dev, mask);
> 
> with a call to the new helper dma_set_mask_and_coherent().
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>  drivers/staging/et131x/et131x.c |   17 ++---------------
>  1 files changed, 2 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
> index f73e58f..98edfa8 100644
> --- a/drivers/staging/et131x/et131x.c
> +++ b/drivers/staging/et131x/et131x.c
> @@ -4797,21 +4797,8 @@ static int et131x_pci_setup(struct pci_dev *pdev,
>  	pci_set_master(pdev);
>  
>  	/* Check the DMA addressing support of this device */
> -	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
> -		rc = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
> -		if (rc < 0) {
> -			dev_err(&pdev->dev,
> -			  "Unable to obtain 64 bit DMA for consistent allocations\n");
> -			goto err_release_res;
> -		}
> -	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
> -		rc = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
> -		if (rc < 0) {
> -			dev_err(&pdev->dev,
> -			  "Unable to obtain 32 bit DMA for consistent allocations\n");
> -			goto err_release_res;
> -		}
> -	} else {
> +	if (dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64)) ||
> +	    dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32))) {

Surely we want && here.

Ben.

>  		dev_err(&pdev->dev, "No usable DMA addressing method\n");
>  		rc = -EIO;
>  		goto err_release_res;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
