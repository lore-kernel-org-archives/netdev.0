From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net v2] ipv6: enforce egress device match in per table
 nexthop lookups
Date: Thu, 23 Jun 2016 14:33:29 -0600
Message-ID: <a359d93e-c7dd-9558-c7ad-c6a9ca6d4c20@cumulusnetworks.com>
References: <5257997d95ca10b106fd44bcb754233d18587f63.1466687942.git.pabeni@redhat.com>
 <786d9687-922f-6e89-c281-ddacae8f83b2@cumulusnetworks.com>
 <14311cf1-0b8e-cde2-54c0-c49a1b39b0c6@cumulusnetworks.com>
 <1466692762.4910.48.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Beniamino Galvani <bgalvani@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35658 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbcFWUdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 16:33:45 -0400
Received: by mail-pa0-f45.google.com with SMTP id hl6so30400930pac.2
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 13:33:44 -0700 (PDT)
In-Reply-To: <1466692762.4910.48.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/23/16 8:39 AM, Paolo Abeni wrote:
> On Thu, 2016-06-23 at 08:29 -0600, David Ahern wrote:
>> On 6/23/16 8:20 AM, David Ahern wrote:
>>>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>>> index 969913d..520b788 100644
>>>> --- a/net/ipv6/route.c
>>>> +++ b/net/ipv6/route.c
>>>> @@ -1782,7 +1782,7 @@ static struct rt6_info
>>>> *ip6_nh_lookup_table(struct net *net,
>>>>      };
>>>>      struct fib6_table *table;
>>>>      struct rt6_info *rt;
>>>> -    int flags = 0;
>>>> +    int flags = RT6_LOOKUP_F_IFACE;
>>>>
>>>>      table = fib6_get_table(net, cfg->fc_table);
>>>>      if (!table)
>>>>
>>>
>>> Acked-by: David Ahern <dsa@cumulusnetworks.com>
>>
>> I take that back.
>>
>> I think RT6_LOOKUP_F_IFACE should only be set if cfg->fc_ifindex is set.
>
> AFAICS the latter condition should not be needed. The related
> information is passed all way down to rt6_score_route(), where it's
> really used:
>
> 	m = rt6_check_dev(rt, oif);
>         if (!m && (strict & RT6_LOOKUP_F_IFACE))
>                 return RT6_NUD_FAIL_HARD;
>
> and 'm' can be 0 only if oif is set: RT6_LOOKUP_F_IFACE has no effect
> ifindex is set.
>

For the simplified lookup yes that is true. Lookups that go through 
ip6_pol_route it is not and for my comment above I was thinking about 
this latter case.

Anyways, your change is fine for the ip6_nh_lookup_table case.
