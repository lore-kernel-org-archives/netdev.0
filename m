From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH 1/2] net: Export __netdev_alloc_frag() to allow gfp_mask
 flags
Date: Wed, 29 Jul 2015 16:22:41 -0400
Message-ID: <55B93611.7070506@ti.com>
References: <1438182653-2136-1-git-send-email-w-kwok2@ti.com> <1438187516.20182.95.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	WingMan Kwok <w-kwok2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438187516.20182.95.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric,

On 07/29/2015 12:31 PM, Eric Dumazet wrote:
> On Wed, 2015-07-29 at 11:10 -0400, WingMan Kwok wrote:
>> This patch makes the function __netdev_alloc_frag() non-static and
>> exports it so that drivers that need to specify additional flags,
>> such as __GFP_DMA, can use it. The currently exported function,
>> netdev_alloc_frag() doesn't allow passing in gfp_mask flags.
>>
>> Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
>> Signed-off-by: Reece R. Pollack <x0183204@ti.com>
>> ---
>>   include/linux/skbuff.h |    1 +
>>   net/core/skbuff.c      |    3 ++-
>>   2 files changed, 3 insertions(+), 1 deletion(-)
>
> You can not do this.
>
> __napi_alloc_frag() uses __alloc_page_frag() using a per cpu reserve.
>
Thanks for your response.

I assume you mean to say __netdev_alloc_frag() which is what the patch 
affects. Right?

> This per cpu reserve would be shared by regular GFP_ATOMIC and your
> __GFP_DMA allocations.

I am trying to understand the issue here. Is there any issue in sharing 
this per CPU reserve between DMA and ATOMIC allocations. Without this 
flag, the assumption is this function can return memory which is not 
DMA-able and this flag assures it is allocated from DMA zone.

Murali
>
>
>
>
>


-- 
Murali Karicheri
Linux Kernel, Keystone
