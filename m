From: okaya@codeaurora.org
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 01:06:27 -0400
Message-ID: <87c17d3f979cf0167cd37077f39d0534@codeaurora.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418.000039.1946438541182822213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, timur@codeaurora.org,
	cov@codeaurora.org, yishaih@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160418.000039.1946438541182822213.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-04-18 00:00, David Miller wrote:
> From: Sinan Kaya <okaya@codeaurora.org>
> Date: Sat, 16 Apr 2016 18:23:32 -0400
> 
>> Current code is assuming that the address returned by 
>> dma_alloc_coherent
>> is a logical address. This is not true on ARM/ARM64 systems. This 
>> patch
>> replaces dma_alloc_coherent with dma_map_page API. The address 
>> returned
>> can later by virtually mapped from the CPU side with vmap API.
>> 
>> Signed-off-by: Sinan Kaya <okaya@codeaurora.org>
> 
> You can't do this.
> 
> The DMA map page API gives non-coherent mappings, and thus requires
> proper flushing.
> 
> So a straight conversion like this is never legitimate.

I would agree on proper dma api usage. However, the code is already 
assuming coherent architecture by mapping the cpu pages as page_kernel.

Dma_map_page returns cached buffers and you don't need cache flushes on 
coherent architecture to make the data visible.
