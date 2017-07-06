From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 11/12] net: Remove all references to SKB_GSO_UDP.
Date: Thu, 6 Jul 2017 13:57:20 -0400
Message-ID: <CAF=yD-+xYoQtP2=jS17tZwJWCWcN3M0WXC1qUGKiDpM-aOqWLw@mail.gmail.com>
References: <20170705.160632.1021185732937441107.davem@davemloft.net>
 <CAF=yD-LnGPF=jBWLFRppqAjMwvgm34xUeRKsh+rLjX2ZOuun8g@mail.gmail.com>
 <CAF=yD-KtJCyYqLDWv0pa7dcaJ=W8HM4eUnnwz8LJj_+S4U3-ZA@mail.gmail.com> <20170706.154321.389823872198215636.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34154 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751734AbdGFR6B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 13:58:01 -0400
Received: by mail-oi0-f66.google.com with SMTP id d77so1205241oig.1
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 10:58:01 -0700 (PDT)
In-Reply-To: <20170706.154321.389823872198215636.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 6, 2017 at 10:43 AM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Wed, 5 Jul 2017 12:27:11 -0400
>
>>>> --- a/net/ipv4/udp_offload.c
>>>> +++ b/net/ipv4/udp_offload.c
>>>> @@ -21,7 +21,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>>>>         __be16 new_protocol, bool is_ipv6)
>>>
>>> In this file, can now remove all of udp4_ufo_fragment, and
>>> udp6_ufo_fragment in net/ipv6.
>>
>> I had missed that this is used for tunneling with skb_udp_tunnel_segment.
>> But the core codepath should no longer be hit once SKB_GSO_UDP
>> is removed.
>
> Are you sure?  I'm pretty sure all of the code remaining after my
> patch series is needed in order to handle doing TCP GRO through
> UDP tunneling encapsulation.
>
> Although the word "fragment" is in the function name, it's not doing
> IP fragmentation.  Instead, it is "fragmenting" the batched UDP
> encapsulated frame into a series of individual UDP encapsulated ones.

Isn't that case handled in the branch

        if (skb->encapsulation &&
            (skb_shinfo(skb)->gso_type &
             (SKB_GSO_UDP_TUNNEL|SKB_GSO_UDP_TUNNEL_CSUM))) {
                segs = skb_udp_tunnel_segment(skb, features, false);
                goto out;
        }

It appears to be in a quick test I ran with FOU.
