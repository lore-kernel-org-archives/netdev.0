From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next v2 01/12] bnxt_en: Refactor rx SKB function.
Date: Thu, 2 Feb 2017 15:40:19 -0800
Message-ID: <CACKFLi=-=zxXQSKViU7kgappPdedBjSum=TBiwPjKTo4ZhEY1g@mail.gmail.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
 <1486054540-366-2-git-send-email-michael.chan@broadcom.com> <20170202145655.6b1ae712@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:34809 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdBBXkU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 18:40:20 -0500
Received: by mail-vk0-f50.google.com with SMTP id r136so2424407vke.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 15:40:20 -0800 (PST)
In-Reply-To: <20170202145655.6b1ae712@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2017 at 2:56 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Thu,  2 Feb 2017 11:55:29 -0500, Michael Chan wrote:
>> @@ -755,8 +757,8 @@ static void bnxt_reuse_rx_agg_bufs(struct bnxt_napi *bnapi, u16 cp_cons,
>>
>>  static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
>>                                  struct bnxt_rx_ring_info *rxr, u16 cons,
>> -                                u16 prod, u8 *data, dma_addr_t dma_addr,
>> -                                unsigned int len)
>> +                                u16 prod, void *data, dma_addr_t dma_addr,
>> +                                unsigned int offset_and_len)
>>  {
>>       int err;
>>       struct sk_buff *skb;
>> @@ -776,7 +778,7 @@ static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
>>       }
>>
>>       skb_reserve(skb, BNXT_RX_OFFSET);
>> -     skb_put(skb, len);
>> +     skb_put(skb, offset_and_len & 0xffff);
>>       return skb;
>>  }
>>
>
> Sorry to be a pain but I still don't understand (a) why you make this
> change in the first patch if it's only needed from patch 5 on;

Because I'm thinking ahead.  The function is now a function pointer
and I want to make the parameter change now.

> (b) why
> do you encode the two parameters in a single u32?  It's the seventh
> parameter so it's going on the stack anyway, no?

Both the length and the offset come from the hardware's rx completion
record.  Both are u16.  The offset happens to be in the upper 16-bit
in the hardware record.  So it is convenient to encode it like this
and I chose to do it like this. Of course, using a separate parameter
will also work.
