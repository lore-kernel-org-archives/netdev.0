From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring access
 in user space
Date: Tue, 13 Jan 2015 14:21:48 +0100
Message-ID: <54B51BEC.2040809@redhat.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32> <1421152510.13626.22.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org,
	danny.zhou@intel.com, nhorman@tuxdriver.com,
	john.ronciak@intel.com, brouer@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37335 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004AbbAMNWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 08:22:41 -0500
In-Reply-To: <1421152510.13626.22.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2015 01:35 PM, Hannes Frederic Sowa wrote:
> On Mo, 2015-01-12 at 20:35 -0800, John Fastabend wrote:
...
>> +/* setsockopt takes addr, size ,direction parametner, getsockopt takes
>> + * iova, size, direction.
>> + * */
>> +struct tpacket_dma_mem_region {
>> +	void *addr;		/* userspace virtual address */
>> +	__u64 phys_addr;	/* physical address */
>> +	__u64 iova;		/* IO virtual address used for DMA */
>> +	unsigned long size;	/* size of region */
>> +	int direction;		/* dma data direction */
>> +};
>
> Have you tested this with with 32 bit user space and 32 bit kernel, too?
> I don't have any problem with only supporting 64 bit kernels for this
> feature, but looking through the code I wonder if we handle the __u64
> addresses correctly in all situations.

Given this is placed into uapi and transferred via setsockopt(2), this
would also need some form of compat handling, also for the case of mixed
environments (e.g. 64 bit kernel, 32 bit user space).
