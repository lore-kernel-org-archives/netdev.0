From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [RFC PATCH] net, gro: fix the truesize of all fragments
Date: Fri, 20 Dec 2013 22:34:33 +0800
Message-ID: <CAEH94Lj8LRazHF+uMeEh0RXvyDfWfRTMC-YM8sc_QEZ1a1S-Vw@mail.gmail.com>
References: <1387539943-25521-1-git-send-email-zwu.kernel@gmail.com>
	<52B44B97.4060400@cogentembedded.com>
	<CAEH94LhiQGG-_Ad-5KYKt20CBYkQ6YR+s93zPeELzR-fGZ4yTA@mail.gmail.com>
	<52B45256.3010602@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:50589 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab3LTOed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:34:33 -0500
Received: by mail-oa0-f54.google.com with SMTP id h16so2892503oag.41
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 06:34:33 -0800 (PST)
In-Reply-To: <52B45256.3010602@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 10:21 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
>
> On 20-12-2013 17:59, Zhi Yong Wu wrote:
>
>>>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
>
>>>> When the truesize of all fragments was calculated, it didn't take
>>>> the first small piece of data into account.
>
>
>>>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>>> ---
>>>>    net/core/skbuff.c |   10 +++++++---
>>>>    1 files changed, 7 insertions(+), 3 deletions(-)
>
>
>>>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>>>> index 2b6b863..0665bd6 100644
>>>> --- a/net/core/skbuff.c
>>>> +++ b/net/core/skbuff.c
>>>> @@ -3027,9 +3027,12 @@ int skb_gro_receive(struct sk_buff **head, struct
>>>> sk_buff *skb)
>>>>                  frag->page_offset += offset;
>>>>                  skb_frag_size_sub(frag, offset);
>>>>
>>>> -               /* all fragments truesize : remove (head size + sk_buff)
>>>> */
>>>> +               /**
>
>
>>>     Why kernel-doc style comment here? Networking code uses the following
>>> comment style:
>
>
>>> /* bla
>>>   * bla
>>>   */
>
>
>> No, If you check other comments in networking code,
>
>
>    I suggest you do this, and not only comments before functions but also
> inside them. I also suggest that you read chapter 8 of
> Documentation/CodingStyle.
>
>
>> you will see why i
>> did as that.
>
>
>    I repeat, this is kernel-doc style comment, that is used to comment on a
> functions/structures, and then can be automatically processed to create
> kernel documentation. Your case does not fit for /** comment.
Your explanation is very clear, i accept your advice, thanks.
>
>
>> /**
>>   *    skb_segment - Perform protocol segmentation on skb.
>>   *    @skb: buffer to segment
>>   *    @features: features for the output path (see dev->features)
>>   *
>>   *    This function performs segmentation on the given skb.  It returns
>>   *    a pointer to the first in a list of new skbs for the segments.
>>   *    In case of error it returns ERR_PTR(err).
>>   */
>> struct sk_buff *skb_segment
>
>
>>>> +                * all fragments truesize :
>>>> +                * remove (head size + sk_buff + offset)
>>>> +                */
>>>>                  delta_truesize = skb->truesize -
>>>> -                                SKB_TRUESIZE(skb_end_offset(skb));
>>>> +                                SKB_TRUESIZE(skb_end_offset(skb) +
>>>> offset);
>>>>
>>>>                  skb->truesize -= skb->data_len;
>>>>                  skb->len -= skb->data_len;
>>>
>>>
>>>
>>> WBR, Sergei
>
>
>> Sorry, what is WBR?
>
>
>    With best regards. Nothing offensive. :-)
>
> WBR, Sergei
>



-- 
Regards,

Zhi Yong Wu
