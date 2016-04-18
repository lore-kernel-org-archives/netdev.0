From: Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Mon, 18 Apr 2016 11:22:05 -0400
Message-ID: <5714FB9D.4000405@codeaurora.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
 <20160418121247.GA25387@infradead.org>
 <0c6a430c5f0ec64f51d7c594ef9751dd@codeaurora.org>
 <20160418131058.GA25421@infradead.org> <5714E5D6.7050600@codeaurora.org>
 <5714FA2C.4030209@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5714FA2C.4030209-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/18/2016 11:15 AM, Timur Tabi wrote:
> Sinan Kaya wrote:
>>
>> VMAP allows you to make several pages look contiguous to the CPU.
>> It can only be used against logical addresses returned from kmalloc
>> or alloc_page.
>>
>> You cannot take several virtually mapped addresses returned by dma_alloc_coherent
>> and try to make them virtually contiguous again.
>>
>> The code happens to work on other architectures by pure luck. AFAIK, dma_alloc_coherent
>> returns logical addresses on Intel systems until it runs out of DMA memory. After
>> that intel arch will also start returning virtually mapped addresses and this code
>> will also fail. ARM64 on the other hand always returns a virtually mapped address.
>>
>> The goal of this code is to allocate a bunch of page sized memory and make it look
>> contiguous. It is just using the wrong API. The correct API is either kmalloc or
>> alloc_page map it with dma_map_page not dma_alloc_coherent.
>>
>> The proper usage of dma_map_page requires code to call dma_sync API in correct
>> places to be compatible with noncoherent systems. This code is already assuming
>> coherency. It would be a nice to have dma_sync APIs in right places. There is no
>> harm in calling dma_sync API for coherent systems as they are no-ops in DMA mapping
>> layer whereas it is a cache flush for non-coherent systems.
> 
> The text would be a great addition to the patch description.
> 

I can do that on the next version.

-- 
Sinan Kaya
Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
