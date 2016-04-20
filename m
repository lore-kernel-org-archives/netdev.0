From: Eran Ben Elisha <eranlinuxmellanox@gmail.com>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Wed, 20 Apr 2016 14:08:22 +0300
Message-ID: <CAKHjkj=dBd1Ax4=n5UDig6RNDpkrXzCievS1hJfYvhk_ZTwAww@mail.gmail.com>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
	<20160419182212.GA8441@infradead.org>
	<57167AF6.9090507@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Christoph Hellwig <hch@infradead.org>, linux-rdma@vger.kernel.org,
	timur@codeaurora.org, cov@codeaurora.org,
	Yishai Hadas <yishaih@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Sinan Kaya <okaya@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57167AF6.9090507@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sinan,

We are working in Mellanox for a solution which
removes the vmap call and allocate contiguous memory (using dma_alloc_coherent).

Thanks,
Eran


On Tue, Apr 19, 2016 at 9:37 PM, Sinan Kaya <okaya@codeaurora.org> wrote:
> On 4/19/2016 2:22 PM, Christoph Hellwig wrote:
>> What I think we need is something like the patch below.  In the long
>> ru nwe should also kill the mlx4_buf structure which now is pretty
>> pointless.
>
> Maybe; this could be the correct approach if we can guarantee that the
> architecture can allocate the requested amount of memory with
> dma_alloc_coherent.
>
> When I brought this issue a year ago, the objection was that my code
> doesn't compile on intel (dma_to_phys) and also some arches run out of
> DMA memory with existing customer base.
>
> If there is a real need to maintain compatibility with the existing
> architectures due to limited amount of DMA memory, we need to correct this
> code to make proper use of vmap via alloc_pages and also insert the
> dma_sync in proper places for DMA API conformance.
>
> Also, the tx descriptors always has to be allocated from a single DMA region
> or the tx code needs to be corrected to support page_list.
>
> If we can live with just using dma_alloc_coherent, your solution is
> better. I was trying to put this support for 64bit arches only while
> maintaining support for the existing code base.
>
>>
>> ---
>> From a493881d2a6c90152d3daabb7b6b3afd1d254d78 Mon Sep 17 00:00:00 2001
>> From: Christoph Hellwig <hch@lst.de>
>> Date: Tue, 19 Apr 2016 14:12:14 -0400
>> Subject: mlx4_en: don't try to split and vmap dma coherent allocations
>>
>> The memory returned by dma_alloc_coherent is not suitable for calling
>> virt_to_page on it, as it might for example come from vmap allocator.
>>
>> Remove the code that calls virt_to_page and vmap on dma coherent
>> allocations from the mlx4 drivers, and replace them with a single
>> high-order dma_alloc_coherent call.
>>
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>> Reported-by: Sinan Kaya <okaya@codeaurora.org>
>
>
> --
> Sinan Kaya
> Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
