From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring access
 in user space
Date: Tue, 13 Jan 2015 07:24:49 -0800
Message-ID: <54B538C1.6000500@gmail.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32> <1421152510.13626.22.camel@stressinduktion.org> <54B51BEC.2040809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, danny.zhou@intel.com,
	nhorman@tuxdriver.com, john.ronciak@intel.com, brouer@redhat.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:51780 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039AbbAMPZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 10:25:07 -0500
Received: by mail-ob0-f182.google.com with SMTP id wo20so2965419obc.13
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 07:25:06 -0800 (PST)
In-Reply-To: <54B51BEC.2040809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2015 05:21 AM, Daniel Borkmann wrote:
> On 01/13/2015 01:35 PM, Hannes Frederic Sowa wrote:
>> On Mo, 2015-01-12 at 20:35 -0800, John Fastabend wrote:
> ...
>>> +/* setsockopt takes addr, size ,direction parametner, getsockopt takes
>>> + * iova, size, direction.
>>> + * */
>>> +struct tpacket_dma_mem_region {
>>> +    void *addr;        /* userspace virtual address */
>>> +    __u64 phys_addr;    /* physical address */
>>> +    __u64 iova;        /* IO virtual address used for DMA */
>>> +    unsigned long size;    /* size of region */
>>> +    int direction;        /* dma data direction */
>>> +};
>>
>> Have you tested this with with 32 bit user space and 32 bit kernel, too?
>> I don't have any problem with only supporting 64 bit kernels for this
>> feature, but looking through the code I wonder if we handle the __u64
>> addresses correctly in all situations.

We still need to test/implement this I'm going to guess there is some
more work needed for this to work correctly.

>
> Given this is placed into uapi and transferred via setsockopt(2), this
> would also need some form of compat handling, also for the case of mixed
> environments (e.g. 64 bit kernel, 32 bit user space).

noted, thanks!

-- 
John Fastabend         Intel Corporation
