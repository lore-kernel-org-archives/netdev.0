From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Wed, 27 Jan 2010 13:08:40 -0500
Message-ID: <4B608128.7090607@majjas.com>
References: <20100120094103.GA6225@ff.dom.local> <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local> <4B59E7EB.3050605@majjas.com>
 <20100122215304.GA3105@del.dom.local> <4B5A2362.6000306@majjas.com>
 <20100122230605.GB3105@del.dom.local> <4B5A33D8.90501@majjas.com>
 <20100122234656.GC3105@del.dom.local> <4B5A39BD.8020305@majjas.com>
 <20100123232133.GA3487@del.dom.local> <4B605D1B.60402@majjas.com>
 <20100127085049.5b5048e9@nehalam> <4B60707F.1000608@majjas.com>
 <20100127095614.14313677@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta4.srv.hcvlny.cv.net ([167.206.4.199]:36352 "EHLO
	mta4.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755205Ab0A0SI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 13:08:58 -0500
In-reply-to: <20100127095614.14313677@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2010 12:56 PM, Stephen Hemminger wrote:
> --- a/drivers/net/sky2.c	2010-01-27 09:46:10.940005248 -0800
> +++ b/drivers/net/sky2.c	2010-01-27 09:53:47.141267850 -0800
> @@ -2257,13 +2257,16 @@ static struct sk_buff *receive_copy(stru
>
>   	skb = netdev_alloc_skb_ip_align(sky2->netdev, length);
>   	if (likely(skb)) {
> +		unsigned dma_align = dma_get_cache_alignment();
> +		unsigned dma_size = ALIGN(length+1, dma_align);
> +
>   		pci_dma_sync_single_for_cpu(sky2->hw->pdev, re->data_addr,
> -					    length, PCI_DMA_FROMDEVICE);
> +					    dma_size, PCI_DMA_FROMDEVICE);
>   		skb_copy_from_linear_data(re->skb, skb->data, length);
>   		skb->ip_summed = re->skb->ip_summed;
>   		skb->csum = re->skb->csum;
>   		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
> -					       length, PCI_DMA_FROMDEVICE);
> +					       dma_size, PCI_DMA_FROMDEVICE);
>   		re->skb->ip_summed = CHECKSUM_NONE;
>   		skb_put(skb, length);
>   	}
>    
This doesn't apply - I'm missing some intermediate patch.

I've got (both in 2.6.32.4 and 2.6.33-rc5: pci_unmap_len(re, data_size) 
vs., "length." I assume that I can just replace the pci_unmap_len with 
dma_size... but perhaps the intermediate change may have affected this 
as well?
