From: wangyufen <wangyufen@huawei.com>
Subject: Re: [PATCH net-next v5 2/3] ipv6: reuse rt6_need_strict
Date: Sat, 29 Mar 2014 09:25:09 +0800
Message-ID: <533620F5.6050103@huawei.com>
References: <1395998427-7532-1-git-send-email-wangyufen@huawei.com> <1395998427-7532-3-git-send-email-wangyufen@huawei.com> <53357BD3.1060105@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kuznet@ms2.inr.ac.ru>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:42323 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbaC2BZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 21:25:39 -0400
In-Reply-To: <53357BD3.1060105@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/28 21:40, Sergei Shtylyov wrote:
> Hello.
> 
> On 28-03-2014 13:20, Wangyufen wrote:
> 
>> From: Wang Yufen <wangyufen@huawei.com>
> 
>> Move the whole rt6_need_strict as static inline into ip6_route.h,
>> so that it can be reused
> 
>> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
>> ---
>>   include/net/ip6_route.h | 5 +++++
>>   net/ipv6/route.c        | 6 ------
>>   2 files changed, 5 insertions(+), 6 deletions(-)
> 
>> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
>> index 00e3f12..33e8694 100644
>> --- a/include/net/ip6_route.h
>> +++ b/include/net/ip6_route.h
>> @@ -51,6 +51,11 @@ static inline unsigned int rt6_flags2srcprefs(int flags)
>>       return (flags >> 3) & 7;
>>   }
>>
>> +static inline bool rt6_need_strict(const struct in6_addr *daddr)
>> +{
>> +    return ipv6_addr_type(daddr) &
>> +        IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
> 
>    I don't think removing parens was correct here: & should have more priority than |.

Oh, fogive me for my carelessness, there missed a '('
sorry for that, and thanks

> 
>> +}
>>
>>   void ip6_route_input(struct sk_buff *skb);
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index b93ae6a..5015c50 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -374,12 +374,6 @@ static bool rt6_check_expired(const struct rt6_info *rt)
>>       return false;
>>   }
>>
>> -static bool rt6_need_strict(const struct in6_addr *daddr)
>> -{
>> -    return ipv6_addr_type(daddr) &
>> -        (IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
>> -}
>> -
>>   /* Multipath route selection:
>>    *   Hash based function using packet header and flowlabel.
>>    * Adapted from fib_info_hashfn()
> 
> WBR, Sergei
> 
> 
> 
