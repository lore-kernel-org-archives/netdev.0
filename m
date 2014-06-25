From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ipv6: Fix MLD Query message check
Date: Wed, 25 Jun 2014 09:29:16 +0800
Message-ID: <CAPwn2JTqGH_iBVxXYY4m4x4b2LiOtvO4y0-9YH-aq3T2SidVwQ@mail.gmail.com>
References: <1403610628-19676-1-git-send-email-liuhangbin@gmail.com>
	<53A98AC1.3010107@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:60821 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857AbaFYB3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 21:29:17 -0400
Received: by mail-wi0-f179.google.com with SMTP id cc10so1615441wib.0
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 18:29:16 -0700 (PDT)
In-Reply-To: <53A98AC1.3010107@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-24 22:27 GMT+08:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
>
> On 06/24/2014 03:50 PM, Hangbin Liu wrote:
>
>> Based on RFC3810 6.2, we also need to check the hop limit and router alert
>> option besides source address.
>
>
>> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
>> ---
>>   net/ipv6/mcast.c | 14 ++++++++++++--
>>   1 file changed, 12 insertions(+), 2 deletions(-)
>
>
>> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
>> index 08b367c..fdf7455 100644
>> --- a/net/ipv6/mcast.c
>> +++ b/net/ipv6/mcast.c
>> @@ -1301,8 +1301,18 @@ int igmp6_event_query(struct sk_buff *skb)
>>         len = ntohs(ipv6_hdr(skb)->payload_len) + sizeof(struct ipv6hdr);
>>         len -= skb_network_header_len(skb);
>>
>> -       /* Drop queries with not link local source */
>> -       if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) &
>> IPV6_ADDR_LINKLOCAL))
>> +       /* RFC3810 6.2
>> +        * Upon reception of an MLD message that contains a Query, the
>> node
>> +        * checks if the source address of the message is a valid
>> link-local
>> +        * address, if the Hop Limit is set to 1, and if the Router Alert
>> +        * option is present in the Hop-By-Hop Options header of the IPv6
>> +        * packet.  If any of these checks fails, the packet is dropped.
>> +        */
>> +       if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL)
>> ||
>> +                       ipv6_hdr(skb)->hop_limit != 1 ||
>> +                       ipv6_hdr(skb)->nexthdr != NEXTHDR_HOP ||
>> +                       !(IP6CB(skb)->flags & IP6SKB_ROUTERALERT) ||
>> +                       IP6CB(skb)->ra != htons(IPV6_OPT_ROUTERALERT_MLD))
>
>
>    The continuation lines should start exactly under '!' on the broken up
> line.

Ah, thanks for the reminder. I will send a patch v2 later.

Best Regards
Hangbin Liu
>
> WBR, Sergei
>
