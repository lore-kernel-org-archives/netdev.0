From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net v2] ipv6: enforce egress device match in per table
 nexthop lookups
Date: Thu, 23 Jun 2016 08:29:15 -0600
Message-ID: <14311cf1-0b8e-cde2-54c0-c49a1b39b0c6@cumulusnetworks.com>
References: <5257997d95ca10b106fd44bcb754233d18587f63.1466687942.git.pabeni@redhat.com>
 <786d9687-922f-6e89-c281-ddacae8f83b2@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Beniamino Galvani <bgalvani@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:35874 "EHLO
	mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926AbcFWO3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 10:29:18 -0400
Received: by mail-it0-f51.google.com with SMTP id a5so127951046ita.1
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 07:29:17 -0700 (PDT)
In-Reply-To: <786d9687-922f-6e89-c281-ddacae8f83b2@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/23/16 8:20 AM, David Ahern wrote:
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 969913d..520b788 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1782,7 +1782,7 @@ static struct rt6_info
>> *ip6_nh_lookup_table(struct net *net,
>>      };
>>      struct fib6_table *table;
>>      struct rt6_info *rt;
>> -    int flags = 0;
>> +    int flags = RT6_LOOKUP_F_IFACE;
>>
>>      table = fib6_get_table(net, cfg->fc_table);
>>      if (!table)
>>
>
> Acked-by: David Ahern <dsa@cumulusnetworks.com>

I take that back.

I think RT6_LOOKUP_F_IFACE should only be set if cfg->fc_ifindex is set.
