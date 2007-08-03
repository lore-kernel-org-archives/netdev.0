From: Tejun Heo <htejun@gmail.com>
Subject: Re: [patch 5/5][RFC] Update e1000 driver to use devres.
Date: Fri, 3 Aug 2007 18:35:21 +0900
Message-ID: <20070803093521.GN13674@htj.dyndns.org>
References: <20070802224552.GG5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, teheo@suse.de,
	Brandon Philips <bphilips@suse.de>
To: Brandon Philips <brandon@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:29817 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757331AbXHCJf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 05:35:29 -0400
Received: by rv-out-0910.google.com with SMTP id k20so633707rvb
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2007 02:35:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070802224552.GG5181@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 03:45:52PM -0700, Brandon Philips wrote:
>  	if ((err = pci_request_regions(pdev, e1000_driver_name)))
> -		goto err_pci_reg;
> +		goto err_dma;

Why not just return?  Ditto for all goto err_dma's.

>  	err = -EIO;
> -	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
> +	adapter->hw.hw_addr = devm_ioremap(&pdev->dev, mmio_start, mmio_len);

This is correct conversion but I have no idea why the origical code
did manual ioremap instead of using pci_iomap().

> -		adapter->hw.flash_address = ioremap(flash_start, flash_len);
> +		adapter->hw.flash_address = devm_ioremap(&pdev->dev,
> +							flash_start,
> +							flash_len);

Ditto.

>  err_dma:
>  	pci_disable_device(pdev);
>  	return err;

err_dma can be killed.

Thanks.

-- 
tejun
