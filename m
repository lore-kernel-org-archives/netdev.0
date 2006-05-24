From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Wed, 24 May 2006 10:04:28 +0200
Message-ID: <4474138C.2050705@myri.com>
References: <20060517220218.GA13411@myri.com> <20060517220608.GD13411@myri.com> <20060523153928.GB5938@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com,
	linux-kernel@vger.kernel.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:59338 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932658AbWEXIFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 04:05:05 -0400
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20060523153928.GB5938@krispykreme>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton Blanchard wrote:
>> +/*
>> + * Set of routunes to get a new receive buffer.  Any buffer which
>> + * crosses a 4KB boundary must start on a 4KB boundary due to PCIe
>> + * wdma restrictions. We also try to align any smaller allocation to
>> + * at least a 16 byte boundary for efficiency.  We assume the linux
>> + * memory allocator works by powers of 2, and will not return memory
>> + * smaller than 2KB which crosses a 4KB boundary.  If it does, we fall
>> + * back to allocating 2x as much space as required.
>> + *
>> + * We intend to replace large (>4KB) skb allocations by using
>> + * pages directly and building a fraglist in the near future.
>> + */
>>     
>
> You go to a lot of trouble to align things. One thing on ppc64 is that
> we really want to start all DMA writes on a cacheline boundary. We
> enforce that in network drivers by making NET_IP_ALIGN = 0 and having
> the drivers do:
>
> skb_reserve(skb, NET_IP_ALIGN);
>
> It sounds like your small allocations will be only aligned to 16 bytes.
>   

We didn't get any ppc64 with PCI-E to run Linux so far. What performance
drop should we expect with our current code ?

> Id suggest using the dma API instead of the pci API. We have seen
> machines in the field that have failed large pci_alloc_consistent calls
> because it always asks for GFP_ATOMIC memory (it presumes the worst).
> The dma API allows you to pass a GFP_ flag in which will have a much
> better chance of succeeding when you dont need GFP_ATOMIC memory.
>   

Good idea, thanks,

>> +#ifdef CONFIG_MTRR
>> +	mgp->mtrr = mtrr_add(mgp->iomem_base, mgp->board_span,
>> +			     MTRR_TYPE_WRCOMB, 1);
>> +#endif
>>     
> ...
>   
>> +	mgp->sram = ioremap(mgp->iomem_base, mgp->board_span);
>>     
>
> Not sure how we are meant to specify write through in drivers. Any ideas Ben?
>   

I am not sure what you mean.
The only ppc64 with PCI-E that we have seen so far (a G5) couldn't do
write combining according to Apple.

Thanks,
Brice

