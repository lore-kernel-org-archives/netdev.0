From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 11/12] net: Remove all references to SKB_GSO_UDP.
Date: Thu, 06 Jul 2017 15:43:21 +0100 (WEST)
Message-ID: <20170706.154321.389823872198215636.davem@davemloft.net>
References: <20170705.160632.1021185732937441107.davem@davemloft.net>
        <CAF=yD-LnGPF=jBWLFRppqAjMwvgm34xUeRKsh+rLjX2ZOuun8g@mail.gmail.com>
        <CAF=yD-KtJCyYqLDWv0pa7dcaJ=W8HM4eUnnwz8LJj_+S4U3-ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33428 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752448AbdGFOn3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 10:43:29 -0400
In-Reply-To: <CAF=yD-KtJCyYqLDWv0pa7dcaJ=W8HM4eUnnwz8LJj_+S4U3-ZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Wed, 5 Jul 2017 12:27:11 -0400

>>> --- a/net/ipv4/udp_offload.c
>>> +++ b/net/ipv4/udp_offload.c
>>> @@ -21,7 +21,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>>>         __be16 new_protocol, bool is_ipv6)
>>
>> In this file, can now remove all of udp4_ufo_fragment, and
>> udp6_ufo_fragment in net/ipv6.
> 
> I had missed that this is used for tunneling with skb_udp_tunnel_segment.
> But the core codepath should no longer be hit once SKB_GSO_UDP
> is removed.

Are you sure?  I'm pretty sure all of the code remaining after my
patch series is needed in order to handle doing TCP GRO through
UDP tunneling encapsulation.

Although the word "fragment" is in the function name, it's not doing
IP fragmentation.  Instead, it is "fragmenting" the batched UDP
encapsulated frame into a series of individual UDP encapsulated ones.
