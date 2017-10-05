From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH net-next] ip_gre: check packet length and mtu correctly in erspan_fb_xmit
Date: Thu, 5 Oct 2017 14:20:31 -0700
Message-ID: <CALDO+SZPmF_UG9BsZKD2FzJUbx0PcUYKrOpp4Xta4Wufezhh+g@mail.gmail.com>
References: <1507162445-18540-1-git-send-email-u9012063@gmail.com> <063D6719AE5E284EB5DD2968C1650D6DD008AC42@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Xin Long <lucien.xin@gmail.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:38021 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751369AbdJEVVM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 17:21:12 -0400
Received: by mail-io0-f195.google.com with SMTP id m16so2902770iod.5
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 14:21:12 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD008AC42@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 5, 2017 at 6:59 AM, David Laight <David.Laight@aculab.com> wrote:
> From: William Tu
>> Sent: 05 October 2017 01:14
>> Similarly to early patch for erspan_xmit(), the ARPHDR_ETHER device
>> is the length of the whole ether packet.  So skb->len should subtract
>> the dev->hard_header_len.
>>
>> Fixes: 1a66a836da63 ("gre: add collect_md mode to ERSPAN tunnel")
>> Signed-off-by: William Tu <u9012063@gmail.com>
>> Cc: Xin Long <lucien.xin@gmail.com>
>> ---
>>  net/ipv4/ip_gre.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
>> index b279c325c7f6..10b21fe5b3a6 100644
>> --- a/net/ipv4/ip_gre.c
>> +++ b/net/ipv4/ip_gre.c
>> @@ -579,7 +579,7 @@ static void erspan_fb_xmit(struct sk_buff *skb, struct net_device *dev,
>>       if (gre_handle_offloads(skb, false))
>>               goto err_free_rt;
>>
>> -     if (skb->len > dev->mtu) {
>> +     if (skb->len - dev->hard_header_len > dev->mtu) {
>
> Can you guarantee that skb->len > dev_hard_header_len?
> It is probably safer to check skb->len > dev->hard_header_len + dev->mtu
> since that addition isn't going to overflow.
Sure, I will fix it.

>
>>               pskb_trim(skb, dev->mtu);
>>               truncate = true;
>
> Is that pskb_trim() now truncating to the correct size?

You're right, now I should truncate to (dev->mtu + dev_hard_header_len)
Thanks
William
