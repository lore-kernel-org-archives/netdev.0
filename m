From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: question about size of sk_buff and skb_shared_info
Date: Tue, 18 Apr 2017 16:55:21 -0700
Message-ID: <1492559721.10587.150.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CABGNecyP8tpBtbOPL_4fyhqnkTYEa80sHCuDrUJdm9gxihFX6w@mail.gmail.com>
         <1492542021.10587.137.camel@edumazet-glaptop3.roam.corp.google.com>
         <CABGNecz7oRk8PZS_YzG2QzpMXi78rQX4zPpt_28ZgJYYZS-ytg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Code Soldier1 <codesoldier1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34073 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755868AbdDRXzY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 19:55:24 -0400
Received: by mail-pf0-f170.google.com with SMTP id c198so3726396pfc.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 16:55:24 -0700 (PDT)
In-Reply-To: <CABGNecz7oRk8PZS_YzG2QzpMXi78rQX4zPpt_28ZgJYYZS-ytg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please do not top post on netdev

On Tue, 2017-04-18 at 16:26 -0700, Code Soldier1 wrote:
> Eric,
> 
> This alignment flag is passed to the cache constructor and the
> allocation is indeed cache aligned. However, since the allocated size
> is not a multiple of the alignment, wont memory be wasted ?. We can
> get 40 extra bytes without any side effects since they are on the same
> cache line ?

We _want_ to align skb to cache lines.

Fact that few bytes might be wasted is unfortunate, but negligible. 

BTW, if you do kmalloc(1025), kmalloc() wastes 1023 bytes.


> 
> kmem_cache_create() code does an ALIGN() to round up the size.
> 
>         kasan_cache_create(cachep, &size, &flags);
> 
>         size = ALIGN(size, cachep->align);
> 
> This is the size used in calculate_slab_order() to calculate num. I am
> assuming that in the non debug case gfp_order will be 0.
> 
> Perhaps I am missing something.
> 
> 
> On Tue, Apr 18, 2017 at 12:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2017-04-18 at 10:34 -0700, Code Soldier1 wrote:
> >> Hi Folks,
> >>
> >> I am sure there is a reason for the current sizes of these structures,
> >> However the reason is not obvious to me. So please help me understand.
> >>
> >> Currently the size of sk_buff on an x86_64 system is 232 bytes -- Why
> >> is that. I expected it to be a multiple of 32/64 as they are the most
> >> common cache lines. Since the alignment calculation will align the
> >> structure with the hw cache line, it seems like we might be wasting
> >> space ?
> >>
> >> skb_shared_info on the other hand is perfectly aligned with a size of 320 bytes.
> >>
> >> Thanks,
> >>
> >
> > The alignment is there.
> > Look at skb_init() code, using SLAB_HWCACHE_ALIGN
> >
> >
> >
> >
> >
> 
> 
> 
