From: Code Soldier1 <codesoldier1@gmail.com>
Subject: Re: question about size of sk_buff and skb_shared_info
Date: Tue, 18 Apr 2017 16:26:31 -0700
Message-ID: <CABGNecz7oRk8PZS_YzG2QzpMXi78rQX4zPpt_28ZgJYYZS-ytg@mail.gmail.com>
References: <CABGNecyP8tpBtbOPL_4fyhqnkTYEa80sHCuDrUJdm9gxihFX6w@mail.gmail.com>
 <1492542021.10587.137.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:37828 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757908AbdDRX0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 19:26:32 -0400
Received: by mail-it0-f46.google.com with SMTP id a140so3919812ita.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 16:26:32 -0700 (PDT)
In-Reply-To: <1492542021.10587.137.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

This alignment flag is passed to the cache constructor and the
allocation is indeed cache aligned. However, since the allocated size
is not a multiple of the alignment, wont memory be wasted ?. We can
get 40 extra bytes without any side effects since they are on the same
cache line ?

kmem_cache_create() code does an ALIGN() to round up the size.

        kasan_cache_create(cachep, &size, &flags);

        size = ALIGN(size, cachep->align);

This is the size used in calculate_slab_order() to calculate num. I am
assuming that in the non debug case gfp_order will be 0.

Perhaps I am missing something.


On Tue, Apr 18, 2017 at 12:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-04-18 at 10:34 -0700, Code Soldier1 wrote:
>> Hi Folks,
>>
>> I am sure there is a reason for the current sizes of these structures,
>> However the reason is not obvious to me. So please help me understand.
>>
>> Currently the size of sk_buff on an x86_64 system is 232 bytes -- Why
>> is that. I expected it to be a multiple of 32/64 as they are the most
>> common cache lines. Since the alignment calculation will align the
>> structure with the hw cache line, it seems like we might be wasting
>> space ?
>>
>> skb_shared_info on the other hand is perfectly aligned with a size of 320 bytes.
>>
>> Thanks,
>>
>
> The alignment is there.
> Look at skb_init() code, using SLAB_HWCACHE_ALIGN
>
>
>
>
>



-- 
CS1
