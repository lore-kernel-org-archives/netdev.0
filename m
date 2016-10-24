From: Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>
Subject: Re: [net-next PATCH RFC 05/26] arch/avr32: Add option to skip sync
 on DMA map
Date: Mon, 24 Oct 2016 20:27:40 +0200
Message-ID: <20161024182739.GA19445@samfundet.no>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
 <20161024120452.16276.9594.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, brouer@redhat.com,
        Haavard Skinnemoen <hskinnemoen@gmail.com>, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161024120452.16276.9594.stgit@ahduyck-blue-test.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Around Mon 24 Oct 2016 08:04:53 -0400 or thereabout, Alexander Duyck wrote:
> The use of DMA_ATTR_SKIP_CPU_SYNC was not consistent across all of the DMA
> APIs in the arch/arm folder.  This change is meant to correct that so that
> we get consistent behavior.

Looks good (-:

> Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
> Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Acked-by: Hans-Christian Noren Egtvedt <egtvedt@samfundet.no>

> ---
>  arch/avr32/mm/dma-coherent.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/avr32/mm/dma-coherent.c b/arch/avr32/mm/dma-coherent.c
> index 58610d0..54534e5 100644
> --- a/arch/avr32/mm/dma-coherent.c
> +++ b/arch/avr32/mm/dma-coherent.c
> @@ -146,7 +146,8 @@ static dma_addr_t avr32_dma_map_page(struct device *dev, struct page *page,
>  {
>  	void *cpu_addr = page_address(page) + offset;
>  
> -	dma_cache_sync(dev, cpu_addr, size, direction);
> +	if (!(attrs & DMA_ATTR_SKIP_CPU_SYNC))
> +		dma_cache_sync(dev, cpu_addr, size, direction);
>  	return virt_to_bus(cpu_addr);
>  }
>  
> @@ -162,6 +163,10 @@ static int avr32_dma_map_sg(struct device *dev, struct scatterlist *sglist,
>  
>  		sg->dma_address = page_to_bus(sg_page(sg)) + sg->offset;
>  		virt = sg_virt(sg);
> +
> +		if (attrs & DMA_ATTR_SKIP_CPU_SYNC)
> +			continue;
> +
>  		dma_cache_sync(dev, virt, sg->length, direction);
>  	}
>  
-- 
mvh
Hans-Christian Noren Egtvedt
