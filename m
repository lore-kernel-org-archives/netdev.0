From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] fs/select: add vmalloc fallback for select(2)
Date: Thu, 22 Sep 2016 18:40:30 +0200
Message-ID: <3097822d-231b-8406-17bc-631aea4f82e7@suse.cz>
References: <20160922152831.24165-1-vbabka@suse.cz>
 <1474561478.23058.127.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51946 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752681AbcIVQkd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 12:40:33 -0400
In-Reply-To: <1474561478.23058.127.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2016 06:24 PM, Eric Dumazet wrote:

>> +		bits = kmalloc(alloc_size, GFP_KERNEL|__GFP_NOWARN);
>> +		if (!bits && alloc_size > PAGE_SIZE) {
>> +			bits = vmalloc(alloc_size);
>> +
>> +			if (!bits)
>> +				goto out_nofds;
>
> Test should happen if alloc_size <= PAGE_SIZE
>
>> +		}
>
> if (!bits && alloc_size > PAGE_SIZE)
>     bits = vmalloc(alloc_size);
>
> if (!bits)
>       goto out_nofds;
>

Thanks... stupid last-minute changes.
