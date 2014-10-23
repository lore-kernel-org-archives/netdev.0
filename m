From: Crestez Dan Leonard <cdleonard@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Thu, 23 Oct 2014 19:17:47 +0300
Message-ID: <54492A2B.2090209@gmail.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>	 <5448A72D.1050806@cumulusnetworks.com>	 <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com> <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:63484 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbaJWQRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 12:17:51 -0400
Received: by mail-wi0-f181.google.com with SMTP id n3so2455655wiv.8
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 09:17:50 -0700 (PDT)
In-Reply-To: <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2014 05:43 PM, Eric Dumazet wrote:
> On Thu, 2014-10-23 at 06:21 -0700, Eric Dumazet wrote:
>> On Thu, 2014-10-23 at 02:58 -0400, Jonathan Toppins wrote:
>>
>>>> +		if (!pool) {
>>>> +			pool = kzalloc_node(sizeof(*pool), GFP_KERNEL,
>>> GFP_DMA | GFP_KERNEL
>>> This memory will possibly be used in a DMA correct? (thinking crypto
>>> hardware offload)
>>
>> I am not sure this is the case, but this certainly can be added.
>>
> 
> Yes, this is not the case.
> 
> 
> The real problem is because sg_set_buf() does the following :
> sg_set_page(sg, virt_to_page(buf), buflen, offset_in_page(buf));
> 
> So it assumes a memory range is not spanning multiple pages.
Doesn't virt_to_page also assume that the memory is not from vmalloc?

Making this portable would require checking if is_vmalloc_addr and doing
vmalloc_to_page instead. Easier to just kmalloc instead.

Regards,
Leonard
