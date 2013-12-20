From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [RFC PATCH] net, gro: fix the truesize of all fragments
Date: Fri, 20 Dec 2013 22:37:05 +0800
Message-ID: <CAEH94LhaDy5TC38jNYEif3TYXy4VCBKQ0GrBuu8PUXrNNDhC1Q@mail.gmail.com>
References: <1387539943-25521-1-git-send-email-zwu.kernel@gmail.com>
	<1387549695.19078.430.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:53340 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab3LTOhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:37:05 -0500
Received: by mail-ob0-f170.google.com with SMTP id wp18so2780342obc.1
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 06:37:05 -0800 (PST)
In-Reply-To: <1387549695.19078.430.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 10:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-12-20 at 19:45 +0800, Zhi Yong Wu wrote:
>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>
>> When the truesize of all fragments was calculated, it didn't take
>> the first small piece of data into account.
>>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>> ---
>>  net/core/skbuff.c |   10 +++++++---
>>  1 files changed, 7 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 2b6b863..0665bd6 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3027,9 +3027,12 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>>               frag->page_offset += offset;
>>               skb_frag_size_sub(frag, offset);
>>
>> -             /* all fragments truesize : remove (head size + sk_buff) */
>> +             /**
>> +              * all fragments truesize :
>> +              * remove (head size + sk_buff + offset)
>> +              */
>>               delta_truesize = skb->truesize -
>> -                              SKB_TRUESIZE(skb_end_offset(skb));
>> +                              SKB_TRUESIZE(skb_end_offset(skb) + offset);
>>
>>               skb->truesize -= skb->data_len;
>>               skb->len -= skb->data_len;
>> @@ -3060,7 +3063,8 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
>>               memcpy(frag + 1, skbinfo->frags, sizeof(*frag) * skbinfo->nr_frags);
>>               /* We dont need to clear skbinfo->nr_frags here */
>>
>> -             delta_truesize = skb->truesize - SKB_DATA_ALIGN(sizeof(struct sk_buff));
>> +             delta_truesize = skb->truesize -
>> +                     SKB_DATA_ALIGN(sizeof(struct sk_buff)) - offset;
>>               NAPI_GRO_CB(skb)->free = NAPI_GRO_FREE_STOLEN_HEAD;
>>               goto done;
>>       }
>
>
> Nope, this patch is not needed.
>
> truesize is about tracking the memory we allocated, not the memory we
> really use.
wow, i forgot this, thanks for yor reminder.
>
> What exact issue do you have ? I suspect a bug in a driver.
I didn't hit any issue, but found this when i read gro related code. a
but in a driver? sorry, i don't know, look forward to seeing your fix.
>
>
>



-- 
Regards,

Zhi Yong Wu
