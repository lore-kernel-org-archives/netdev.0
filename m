From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] sky2: don't request unused i/o region
Date: Wed, 13 Feb 2008 23:40:48 -0500
Message-ID: <47B3C650.9040008@pobox.com>
References: <20080213190237.7cd49d60@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39927 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752446AbYBNEkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 23:40:52 -0500
In-Reply-To: <20080213190237.7cd49d60@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> The sky2 driver only uses the PCI memory region (0) not the 
> available I/O region.  Some users want to use lots of boards, and the
> I/O space gets exhausted.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> --- a/drivers/net/sky2.c	2008-02-13 18:58:21.000000000 -0800
> +++ b/drivers/net/sky2.c	2008-02-13 18:58:55.000000000 -0800
> @@ -4135,9 +4135,9 @@ static int __devinit sky2_probe(struct p
>  		goto err_out;
>  	}
>  
> -	err = pci_request_regions(pdev, DRV_NAME);
> +	err = pci_request_region(pdev, 0, DRV_NAME);
>  	if (err) {
> -		dev_err(&pdev->dev, "cannot obtain PCI resources\n");
> +		dev_err(&pdev->dev, "cannot obtain PCI resource\n");

Your description of the problem does not match the fix.

PCI resources are already allocated to the device (or not) by this point 
in the code.  pci_request_region/regions is purely internal kernel 
software resource reservation -- protecting drivers from themselves, and 
arguably not really needed anymore on modern buses.

Thus, I cannot see how this patch can possibly "exhaust I/O space" -- 
the relevant PCI resources are allocated to the device, or not, 
regardless of these function calls.

As long as there is no resource conflict, you can have 1 million boards 
and still use pci_request_regions().

	Jeff



