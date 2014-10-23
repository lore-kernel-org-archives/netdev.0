From: Crestez Dan Leonard <cdleonard@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Thu, 23 Oct 2014 04:00:39 +0300
Message-ID: <54485337.5040108@gmail.com>
References: <5447FDB2.2010906@gmail.com> <54483FF7.4090208@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:43995 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933545AbaJWBAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 21:00:43 -0400
Received: by mail-lb0-f180.google.com with SMTP id n15so5943lbi.39
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 18:00:42 -0700 (PDT)
In-Reply-To: <54483FF7.4090208@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2014 02:38 AM, Jonathan Toppins wrote:
> On 10/22/14, 2:55 PM, Crestez Dan Leonard wrote:
>> sg_init_one does virt_addr on the pointer which assumes it is directly accessible. But the tcp_md5sig_pool pointer comes from alloc_percpu which can return memory from the vmalloc area after the pcpu_first_chunk is exhausted. This looks wrong to me. I'm am getting crashes on mips and I believe this to be the cause.
>
> Thinking about this more if the issue really is sg_init_one assumes a
> directly accessible memory region, can we just modify the zone
> allocation to GFP_DMA using alloc_percpu_gfp()? Does this satisfy the
> assumptions made by sg_init_one?
I don't think that alloc_percpu_gfp can be used that way. Looking at the 
code it only checks for GFP_KERNEL and behaves "atomically" if it is not 
present. This means that it fails rather than vmalloc a new percpu_chunk.

The problem is not that the memory is not allocated with GFP_DMA but 
rather that the memory is allocated with vmalloc.

Regards,
Leonard
