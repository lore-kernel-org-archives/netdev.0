From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: question about size of sk_buff and skb_shared_info
Date: Tue, 18 Apr 2017 17:47:23 -0700
Message-ID: <1492562843.10587.153.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CABGNecyP8tpBtbOPL_4fyhqnkTYEa80sHCuDrUJdm9gxihFX6w@mail.gmail.com>
         <1492542021.10587.137.camel@edumazet-glaptop3.roam.corp.google.com>
         <CABGNecz7oRk8PZS_YzG2QzpMXi78rQX4zPpt_28ZgJYYZS-ytg@mail.gmail.com>
         <1492559721.10587.150.camel@edumazet-glaptop3.roam.corp.google.com>
         <CABGNeczXNPkWnhkviHhXv5OpVope_0BGNoB-nsGwALOptrwWdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Code Soldier1 <codesoldier1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33010 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756410AbdDSArZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 20:47:25 -0400
Received: by mail-pg0-f67.google.com with SMTP id 63so1466897pgh.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 17:47:25 -0700 (PDT)
In-Reply-To: <CABGNeczXNPkWnhkviHhXv5OpVope_0BGNoB-nsGwALOptrwWdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For the last time, do not top post on netdev.

On Tue, 2017-04-18 at 17:15 -0700, Code Soldier1 wrote:
> I am not suggesting that we do not do cache alignment. That is
> required for performance. I have gone through this exercise because I
> need to add a field to sk_buff and I want to do that without causing
> any adverse effects.
> 
> Now that we have discovered that there are 40 bytes that can be used
> without any adverse effect, may I increase skb->cb by 8 bytes ?
> 

skb->cb is already 48 bytes, not 40.

> If not then may I increase skb_shared_info -- However that would have
> to be by 64bytes.


You will have a very hard time to convince us that this 8 byte field is
needed on all skbs, regardless of current sk_buff size.



> 
> 
> On Tue, Apr 18, 2017 at 4:55 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Please do not top post on netdev
> >
> > On Tue, 2017-04-18 at 16:26 -0700, Code Soldier1 wrote:
> >> Eric,
> >>
> >> This alignment flag is passed to the cache constructor and the
> >> allocation is indeed cache aligned. However, since the allocated size
> >> is not a multiple of the alignment, wont memory be wasted ?. We can
> >> get 40 extra bytes without any side effects since they are on the same
> >> cache line ?
> >
> > We _want_ to align skb to cache lines.
> >
> > Fact that few bytes might be wasted is unfortunate, but negligible.
> >
> > BTW, if you do kmalloc(1025), kmalloc() wastes 1023 bytes.
> >
> >
> >>
> >> kmem_cache_create() code does an ALIGN() to round up the size.
> >>
> >>         kasan_cache_create(cachep, &size, &flags);
> >>
> >>         size = ALIGN(size, cachep->align);
> >>
> >> This is the size used in calculate_slab_order() to calculate num. I am
> >> assuming that in the non debug case gfp_order will be 0.
> >>
> >> Perhaps I am missing something.
> >>
> >>
> >> On Tue, Apr 18, 2017 at 12:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> > On Tue, 2017-04-18 at 10:34 -0700, Code Soldier1 wrote:
> >> >> Hi Folks,
> >> >>
> >> >> I am sure there is a reason for the current sizes of these structures,
> >> >> However the reason is not obvious to me. So please help me understand.
> >> >>
> >> >> Currently the size of sk_buff on an x86_64 system is 232 bytes -- Why
> >> >> is that. I expected it to be a multiple of 32/64 as they are the most
> >> >> common cache lines. Since the alignment calculation will align the
> >> >> structure with the hw cache line, it seems like we might be wasting
> >> >> space ?
> >> >>
> >> >> skb_shared_info on the other hand is perfectly aligned with a size of 320 bytes.
> >> >>
> >> >> Thanks,
> >> >>
> >> >
> >> > The alignment is there.
> >> > Look at skb_init() code, using SLAB_HWCACHE_ALIGN
> >> >
> >> >
> >> >
> >> >
> >> >
> >>
> >>
> >>
> >
> >
> 
> 
> 
