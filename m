From: Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 12:06:51 -0400
Message-ID: <5715061A.40802@codeaurora.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418.000039.1946438541182822213.davem@davemloft.net>
 <87c17d3f979cf0167cd37077f39d0534@codeaurora.org>
 <20160418.115902.1053705461620271779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160418.115902.1053705461620271779.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/18/2016 11:59 AM, David Miller wrote:
> From: okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
> Date: Mon, 18 Apr 2016 01:06:27 -0400
> 
>> On 2016-04-18 00:00, David Miller wrote:
>>> From: Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>>> Date: Sat, 16 Apr 2016 18:23:32 -0400
>>>
>>>> Current code is assuming that the address returned by
>>>> dma_alloc_coherent
>>>> is a logical address. This is not true on ARM/ARM64 systems. This
>>>> patch
>>>> replaces dma_alloc_coherent with dma_map_page API. The address
>>>> returned
>>>> can later by virtually mapped from the CPU side with vmap API.
>>>> Signed-off-by: Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>>> You can't do this.
>>> The DMA map page API gives non-coherent mappings, and thus requires
>>> proper flushing.
>>> So a straight conversion like this is never legitimate.
>>
>> I would agree on proper dma api usage. However, the code is already
>> assuming coherent architecture by mapping the cpu pages as
>> page_kernel.
>>
>> Dma_map_page returns cached buffers and you don't need cache flushes
>> on coherent architecture to make the data visible.
> 
> All you are telling me is that there are two bugs instead of one, so now
> both need to be fixed.
> 

The removal of vmap also fixes the coherency assumption. It is one fix
for both.

I was thinking of submitting another patch to change the vmap argument
PAGE_KERNEL based on the coherency support of the architecture. I don't need
to do that anymore if the other experiment works.

-- 
Sinan Kaya
Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
