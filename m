From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 4/6] [TULIP]  Quiet down tulip_stop_rxtx
Date: Thu, 15 Mar 2007 11:25:10 -0400
Message-ID: <45F96556.10205@garzik.org>
References: <20070312093128.577087000@linux.intel.com> <20070312184218.317747000@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org,
	Grant Grundler <grundler@parisc-linux.org>
To: Valerie Henson <val_henson@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50402 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422897AbXCOPZO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 11:25:14 -0400
In-Reply-To: <20070312184218.317747000@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valerie Henson wrote:
> Only print out debugging info for tulip_stop_rxtx if debug is on.
> Many cards (including at least two of my own) fail to stop properly
> during initialization according to this test with no apparent ill
> effects.  Worse, it tends to spam logs when the driver doesn't work.
> 
> Signed-off-by: Val Henson <val_henson@linux.intel.com>
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> 
> ---
>  drivers/net/tulip/tulip.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- pristine-linux.orig/drivers/net/tulip/tulip.h
> +++ pristine-linux/drivers/net/tulip/tulip.h
> @@ -481,7 +481,7 @@ static inline void tulip_stop_rxtx(struc
>  		while (--i && (ioread32(ioaddr + CSR5) & (CSR5_TS|CSR5_RS)))
>  			udelay(10);
>  
> -		if (!i)
> +		if (!i && (tulip_debug > 1))
>  			printk(KERN_DEBUG "%s: tulip_stop_rxtx() failed"
>  					" (CSR5 0x%x CSR6 0x%x)\n",
>  					pci_name(tp->pdev),

Here's the problem with this:  this printk is signalling that the DMA 
engines have not yet stopped, which is an event of which we should be wary.

While it makes sense to do this patch, since the complaining cards 
appear to work anyway, we also need to take into account the times when 
this is not a spurious warning.

Thus, I would consider maybe adding a warning somewhere in the 
DMA-engine-start region of code, that complains if the DMA engines are 
already active, or somesuch.

	Jeff



