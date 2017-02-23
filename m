From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC v2 02/12] sock: skb_copy_ubufs support for compound pages
Date: Wed, 22 Feb 2017 20:51:57 -0500
Message-ID: <CAF=yD-KDH+pMjrbhP+nkD=JGwFNXL8EOHrxAGJYH=iQeLibOyw@mail.gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
 <20170222163901.90834-3-willemdebruijn.kernel@gmail.com> <1487795636.9415.91.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35515 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932306AbdBWBwj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 20:52:39 -0500
Received: by mail-wm0-f50.google.com with SMTP id v186so157653593wmd.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 17:52:38 -0800 (PST)
In-Reply-To: <1487795636.9415.91.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> -             page = alloc_page(gfp_mask);
>> +             page = skb_frag_page(f);
>> +             if (page_count(page) == 1) {
>> +                     skb_frag_ref(skb, i);
>
> This could be : get_page(page);

Ah, indeed. Thanks.

>
>> +                     goto copy_done;
>> +             }
>> +
>> +             if (f->size > PAGE_SIZE) {
>> +                     order = get_order(f->size);
>> +                     mask |= __GFP_COMP;
>
> Note that this would probably fail under memory pressure.
>
> We could instead try to explode the few segments into order-0 only
> pages.

Good point. I'll revise to use only order-0 here.
