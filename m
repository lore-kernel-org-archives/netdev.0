From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next v2 01/12] bnxt_en: Refactor rx SKB function.
Date: Thu, 2 Feb 2017 16:34:00 -0800
Message-ID: <CACKFLi=f2iv_8g_Uw+gQX7Jm=1hvUr0QNkLy7N-32V82jQxL4g@mail.gmail.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
 <1486054540-366-2-git-send-email-michael.chan@broadcom.com>
 <20170202145655.6b1ae712@cakuba.netronome.com> <CACKFLi=-=zxXQSKViU7kgappPdedBjSum=TBiwPjKTo4ZhEY1g@mail.gmail.com>
 <20170202162223.1b70e664@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:34697 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751785AbdBCAeC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 19:34:02 -0500
Received: by mail-vk0-f47.google.com with SMTP id r136so3110812vke.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 16:34:01 -0800 (PST)
In-Reply-To: <20170202162223.1b70e664@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2017 at 4:22 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Thu, 2 Feb 2017 15:40:19 -0800, Michael Chan wrote:
>> On Thu, Feb 2, 2017 at 2:56 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
>> > (b) why
>> > do you encode the two parameters in a single u32?  It's the seventh
>> > parameter so it's going on the stack anyway, no?
>>
>> Both the length and the offset come from the hardware's rx completion
>> record.  Both are u16.  The offset happens to be in the upper 16-bit
>> in the hardware record.  So it is convenient to encode it like this
>> and I chose to do it like this. Of course, using a separate parameter
>> will also work.
>
> Yes, I initially thought you read them out this way straight from the
> descriptor but you actually combine them into this form:
>
> +               unsigned int payload_len;
> +
> +               payload_len = (le32_to_cpu(rxcmp->rx_cmp_misc_v1) &
> +                              RX_CMP_PAYLOAD_OFFSET) | len;
> +               skb = bp->rx_skb_func(bp, rxr, cons, prod, data, dma_addr,
>

Yes they are combined because they come from 2 different words.  But I
don't have to do the shift for the offset because it is already in the
upper 16-bit.

> I don't mind though, I was just hoping this is some clever optimization
> technique I could learn :)
