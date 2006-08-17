From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/6] IP100A Remove CONFIG_SUNDANCE_MMIO, mask of mapping
 address
Date: Thu, 17 Aug 2006 10:46:58 -0400
Message-ID: <44E48162.1050104@pobox.com>
References: <1155841561.4532.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:13746 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965082AbWHQOrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 10:47:09 -0400
To: Jesse Huang <jesse@icplus.com.tw>
In-Reply-To: <1155841561.4532.13.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Huang wrote:
> -/* Work-around for Kendin chip bugs. */
> -#ifndef CONFIG_SUNDANCE_MMIO
> -#define USE_IO_OPS 1
> -#endif

Why?  This simply eliminates the ability of the user to set the driver 
configuration at Kconfig time, requiring them to edit the driver to 
achieve the same functionality.


> @@ -491,10 +487,13 @@ #endif
>  	if (pci_request_regions(pdev, DRV_NAME))
>  		goto err_out_netdev;
>  
> -	ioaddr = pci_iomap(pdev, bar, netdev_io_size);
> +	ioaddr =(void __iomem *)
> +		 ((unsigned long)pci_iomap(pdev, bar, netdev_io_size) & 
> +	          0xffffff80);

NAK, this is very wrong.  pci_iomap() returns a "cookie", which you are 
not allowed to modify in any way.

	Jeff


