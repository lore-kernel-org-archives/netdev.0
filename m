From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 2/2] tcp: cleanup tcp_try_coalesce
Date: Wed, 02 May 2012 22:41:36 -0700
Message-ID: <4FA21A90.3010008@gmail.com>
References: <20120503033018.5482.89902.stgit@gitlad.jf.intel.com>	 <20120503033901.5482.27183.stgit@gitlad.jf.intel.com>	 <1336017985.12425.9.camel@edumazet-glaptop>  <4FA21087.1080801@gmail.com> <1336022373.12425.24.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:44047 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752286Ab2ECFlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 01:41:47 -0400
Received: by ghrr11 with SMTP id r11so1452194ghr.19
        for <netdev@vger.kernel.org>; Wed, 02 May 2012 22:41:46 -0700 (PDT)
In-Reply-To: <1336022373.12425.24.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/2012 10:19 PM, Eric Dumazet wrote:
> On Wed, 2012-05-02 at 21:58 -0700, Alexander Duyck wrote:
>> The question I have is how can you get into a case where the ksize is
>> different from the end offset plus the aligned size of skb_shared_info?
>>  From what I can tell it looks like the only place we can lie is if we
>> use build_skb with the frag_size option, and in that case we are using a
>> page, not kmalloc memory.  Otherwise in all other cases __alloc_skb or
>> build_skb is using ksize(skb->head) - SKB_DATA_ALIGN(struct
>> skb_shared_info) to set the end pointer, so reversing that should give
>> us the same value as ksize(skb->head).
>
> Right after skb is allocated (build_skb() or other skb_alloc...
> variants), truesize is correct by construction.
>
> Then drivers add fragments and can make truesize smaller than reality.
>
> And Intel drivers are known to abuse truesize.
>
> My last patch against iwlwifi is still waiting to make its way into
> official tree.
>
> http://www.spinics.net/lists/netdev/msg192629.html
I think the part that has me confused is how being more precise about 
removing from truesize gets in the way of detecting abuses of truesize.  
It seems like it should be more as good as or better then the original 
approach of just using skb->len.

Then again we might just be talking in circles again.  I have things 
broken out into 3 patches now that are much more readable.  I will email 
them out in an hour or so once I do some quick tests to verify they are 
building and don't break anything.

Thanks,

Alex
