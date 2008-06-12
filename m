From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] ssb: Partial revert of 4ac5846 to fix coherent DMA mask setting
Date: Thu, 12 Jun 2008 14:52:24 +0200
Message-ID: <200806121452.24592.mb@bu3sch.de>
References: <1213274522-7059-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Glauber Costa <gcosta@redhat.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:37674 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755731AbYFLMws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 08:52:48 -0400
In-Reply-To: <1213274522-7059-1-git-send-email-kirill@shutemov.name>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 12 June 2008 14:42:02 Kirill A. Shutemov wrote:
> dma_set_mask() doesn't set coherent_dma_mask, this can cause
> strange error like "powering down PHY" in b44(bz #10473).
> 
> At x86_64 this error had been hidden until aa99b16.

This patch is wrong. I will send the right patch soon.


> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
>  drivers/ssb/main.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
> index 7cf8851..b7fbbc4 100644
> --- a/drivers/ssb/main.c
> +++ b/drivers/ssb/main.c
> @@ -1170,8 +1170,9 @@ int ssb_dma_set_mask(struct ssb_device *ssb_dev, u64 mask)
>  	struct device *dma_dev = ssb_dev->dma_dev;
>  
>  #ifdef CONFIG_SSB_PCIHOST
> -	if (ssb_dev->bus->bustype == SSB_BUSTYPE_PCI)
> -		return dma_set_mask(dma_dev, mask);
> +	if (ssb_dev->bus->bustype == SSB_BUSTYPE_PCI &&
> +	    !dma_supported(dma_dev, mask))
> +		return -EIO;
>  #endif
>  	dma_dev->coherent_dma_mask = mask;
>  	dma_dev->dma_mask = &dma_dev->coherent_dma_mask;



-- 
Greetings Michael.
