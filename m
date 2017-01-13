From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Thu, 12 Jan 2017 16:14:30 -0800
Message-ID: <CAM_iQpX2TipBW2Pm-OHRobfZaVoV9_D8Se8u9oKryt96SZFRkA@mail.gmail.com>
References: <1484197322-958-1-git-send-email-xiyou.wangcong@gmail.com> <20170113000700.GA1482@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        Chas Williams <3chas3@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34385 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750897AbdAMAOv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 19:14:51 -0500
Received: by mail-qt0-f195.google.com with SMTP id a29so4382326qtb.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 16:14:51 -0800 (PST)
In-Reply-To: <20170113000700.GA1482@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 4:07 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Cong Wang <xiyou.wangcong@gmail.com> :
> [...]
>> diff --git a/net/atm/common.c b/net/atm/common.c
>> index a3ca922..7ec3bbc 100644
>> --- a/net/atm/common.c
>> +++ b/net/atm/common.c
>> @@ -72,10 +72,11 @@ static struct sk_buff *alloc_tx(struct atm_vcc *vcc, unsigned int size)
>>                        sk_wmem_alloc_get(sk), size, sk->sk_sndbuf);
>>               return NULL;
>>       }
>> -     while (!(skb = alloc_skb(size, GFP_KERNEL)))
>> -             schedule();
>> -     pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
>> -     atomic_add(skb->truesize, &sk->sk_wmem_alloc);
>> +     skb = alloc_skb(size, GFP_KERNEL);
>> +     if (skb) {
>> +             pr_debug("%d += %d\n", sk_wmem_alloc_get(sk), skb->truesize);
>> +             atomic_add(skb->truesize, &sk->sk_wmem_alloc);
>> +     }
>>       return skb;
>>  }
>
> Were alloc_skb moved one level up in the call stack, there would be
> no need to use the new wait api in the subsequent page, thus easing
> pre 3.19 longterm kernel maintenance (at least those on korg page).

alloc_skb(GFP_KERNEL) itself is sleeping, so the new wait api is still
needed.
