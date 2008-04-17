From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 06/13] sis190: use netdev_alloc_skb
Date: Thu, 17 Apr 2008 08:50:24 +0200
Message-ID: <20080417065024.GA30293@electric-eye.fr.zoreil.com>
References: <20080416233727.732025083@vyatta.com> <20080416233757.391517921@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60133 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753409AbYDQHId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 03:08:33 -0400
Content-Disposition: inline
In-Reply-To: <20080416233757.391517921@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> :
> Use netdev_alloc_skb. This sets skb->dev and allows arch specific
> allocation. 
> 
> Compile tested only.
[...]
> -static int sis190_alloc_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
> -			       struct RxDesc *desc, u32 rx_buf_sz)
> +static struct sk_buff *sis190_alloc_rx_skb(struct pci_dev *pdev,
> +					   struct net_device *dev,
> +					   struct RxDesc *desc, u32 rx_buf_sz)
>  {
>  	struct sk_buff *skb;
>  	dma_addr_t mapping;
>  	int ret = 0;

'ret' is now an unused variable.

>  
> -	skb = dev_alloc_skb(rx_buf_sz);
> +	skb = netdev_alloc_skb(dev, rx_buf_sz);
>  	if (!skb)
>  		goto err_out;
>  
> -	*sk_buff = skb;
> -
>  	mapping = pci_map_single(pdev, skb->data, rx_buf_sz,
>  				 PCI_DMA_FROMDEVICE);
>  
>  	sis190_map_to_asic(desc, mapping, rx_buf_sz);
> -out:
> -	return ret;
> +	return skb;
>  
>  err_out:
>  	ret = -ENOMEM;
>  	sis190_make_unusable_by_asic(desc);
> -	goto out;
> +	return NULL;
>  }

-- 
Ueimor
