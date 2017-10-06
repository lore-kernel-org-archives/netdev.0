From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH net-next] ip_gre: check packet length and mtu correctly in erspan_fb_xmit
Date: Fri, 6 Oct 2017 15:09:29 -0700
Message-ID: <CALDO+SYDGtipnsXOmcFmCRB2QcgjjzoWVB=T71=r7U834ivPjg@mail.gmail.com>
References: <1507162445-18540-1-git-send-email-u9012063@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD008AC42@AcuExch.aculab.com>
 <CALDO+SZPmF_UG9BsZKD2FzJUbx0PcUYKrOpp4Xta4Wufezhh+g@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6DD008B9C8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Xin Long <lucien.xin@gmail.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:46680 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdJFWKK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 18:10:10 -0400
Received: by mail-it0-f48.google.com with SMTP id f187so721589itb.1
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 15:10:10 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD008B9C8@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 6, 2017 at 2:38 AM, David Laight <David.Laight@aculab.com> wrote:
> From: William Tu
>> Sent: 05 October 2017 22:21
> ...
>> >> -     if (skb->len > dev->mtu) {
>> >> +     if (skb->len - dev->hard_header_len > dev->mtu) {
>> >
>> > Can you guarantee that skb->len > dev_hard_header_len?
>> > It is probably safer to check skb->len > dev->hard_header_len + dev->mtu
>> > since that addition isn't going to overflow.
>> Sure, I will fix it.
>>
>> >
>> >>               pskb_trim(skb, dev->mtu);
>> >>               truncate = true;
>> >
>> > Is that pskb_trim() now truncating to the correct size?
>>
>> You're right, now I should truncate to (dev->mtu + dev_hard_header_len)
>
> It might be worth caching that length in the dev structure
> to avoid the arithmetic on every packet.
>
>         David
>
Thanks for the advise.
Yes, adding another field in the struct net_device can avoid the
arithmetic operation. I'm not sure it's a good idea to add new field
since there are already a lot in net_device.  Let's wait to see how
others think.

William
