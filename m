From: Tejun Heo <htejun@gmail.com>
Subject: Re: [patch 3/5][RFC] Update e100 driver to use devres.
Date: Fri, 3 Aug 2007 18:18:51 +0900
Message-ID: <20070803091851.GL13674@htj.dyndns.org>
References: <20070802224537.GE5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, teheo@suse.de,
	Brandon Philips <bphilips@suse.de>
To: Brandon Philips <brandon@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:5411 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756823AbXHCJTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 05:19:00 -0400
Received: by rv-out-0910.google.com with SMTP id k20so630802rvb
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2007 02:18:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070802224537.GE5181@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 02, 2007 at 03:45:37PM -0700, Brandon Philips wrote:
>  	if((err = pci_request_regions(pdev, DRV_NAME))) {
>  		DPRINTK(PROBE, ERR, "Cannot obtain PCI resources, aborting.\n");
> -		goto err_out_disable_pdev;
> +		return err;
>  	}
>  
>  	if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
>  		DPRINTK(PROBE, ERR, "No usable DMA configuration, aborting.\n");
> -		goto err_out_free_res;
> +		return err;
>  	}
>  
>  	SET_MODULE_OWNER(netdev);
> @@ -2613,11 +2606,11 @@ static int __devinit e100_probe(struct p
>  	if (use_io)
>  		DPRINTK(PROBE, INFO, "using i/o access mode\n");
>  
> -	nic->csr = pci_iomap(pdev, (use_io ? 1 : 0), sizeof(struct csr));
> +	nic->csr = pcim_iomap(pdev, (use_io ? 1 : 0), sizeof(struct csr));
>  	if(!nic->csr) {
>  		DPRINTK(PROBE, ERR, "Cannot map device registers, aborting.\n");
>  		err = -ENOMEM;
> -		goto err_out_free_res;
> +		return err;

Calls to pci_request_regions() and pcim_iomap() can be merged into
pcim_iomap_regions().

Other than that, Acked-by: Tejun Heo <htejun@gmail.com>

-- 
tejun
