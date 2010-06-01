From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH 1/2] tulip: explicity set to D0 power state during init
Date: Mon, 31 May 2010 19:00:52 -0600
Message-ID: <20100601010052.GA616@lackof.org>
References: <1275345283-10650-1-git-send-email-stevenrwalter@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@parisc-linux.org, kyle@mcmartin.ca, netdev@vger.kernel.org
To: Steven Walter <stevenrwalter@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:52419 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431Ab0FABBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 21:01:01 -0400
Content-Disposition: inline
In-Reply-To: <1275345283-10650-1-git-send-email-stevenrwalter@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 31, 2010 at 06:34:42PM -0400, Steven Walter wrote:
> During the first suspend the chip would refuse to enter D3.  Subsequent
> suspends worked okay.  During resume the chip is commanded into D0.
> Doing so during initialization fixes the initial suspend.
> 
> Signed-off-by: Steven Walter <stevenrwalter@gmail.com>

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

> ---
>  drivers/net/tulip/tulip_core.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
> index 3810db9..bb8c0ee 100644
> --- a/drivers/net/tulip/tulip_core.c
> +++ b/drivers/net/tulip/tulip_core.c
> @@ -1380,6 +1380,13 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
>  		return i;
>  	}
>  
> +	/* The chip will fail to enter a low-power state later unless
> +	 * first explicitly commanded into D0 */
> +	if (pci_set_power_state(pdev, PCI_D0)) {
> +		printk (KERN_ERR PFX

My only quibble is this message really isn't "KERN_ERR" worthy.
Can you explain why you think this should be ERR and not say, KERN_NOTICE?

(I'm looking at the definitions in include/linux/kernel.h of 2.6 source tree.)

If you want to repost with KERN_NOTICE, please include my S-O-B: line above.

thanks,
grant

> +			"Failed to set power state to D0\n");
> +	}
> +
>  	irq = pdev->irq;
>  
>  	/* alloc_etherdev ensures aligned and zeroed private structures */
> -- 
> 1.6.3.3
