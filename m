From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: fix comment above build_skb()
Date: Tue, 23 Jul 2013 19:04:06 +0100
Message-ID: <CAGVrzcZ6=591=sY6kVVrwy4BHN_0LoMZ=u2yz88QyBUvtSOydA@mail.gmail.com>
References: <1374593943-31642-1-git-send-email-f.fainelli@gmail.com> <1374594559.3449.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:64373 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933808Ab3GWSEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 14:04:48 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so8425914pde.37
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 11:04:47 -0700 (PDT)
In-Reply-To: <1374594559.3449.17.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/7/23 Eric Dumazet <eric.dumazet@gmail.com>:
> On Tue, 2013-07-23 at 16:39 +0100, Florian Fainelli wrote:
>> build_skb() specifies that the data parameter must come from a kmalloc'd
>> area, this is only true if frag_size equals 0, because then build_skb()
>> will use kzsize(data) to figure out the actual data size. Update the
>> comment to reflect that special condition.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  net/core/skbuff.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index 20e02d2..d3174db 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -309,7 +309,8 @@ EXPORT_SYMBOL(__alloc_skb);
>>   * @frag_size: size of fragment, or 0 if head was kmalloced
>>   *
>>   * Allocate a new &sk_buff. Caller provides space holding head and
>> - * skb_shared_info. @data must have been allocated by kmalloc()
>> + * skb_shared_info. @data must have been allocated by kmalloc() only if
>> + * @frag_size is 0.
>>   * The return is the new skb buffer.
>>   * On a failure the return is %NULL, and @data is not freed.
>>   * Notes :
>
> Hmm, why not explaining the other case ? (frag_size > 0)

Sure, would something like:

"@data must have been allocated by kmalloc() if frag_size is 0,
otherwise any data buffer (vmalloc, DMA..) is suitable"

work for you?
--
Florian
