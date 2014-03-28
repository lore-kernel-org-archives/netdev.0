From: wangyufen <wangyufen@huawei.com>
Subject: Re: [PATCH net-next v4 2/3] ipv6: reuse rt6_need_strict
Date: Fri, 28 Mar 2014 17:04:52 +0800
Message-ID: <53353B34.1040700@huawei.com>
References: <1395979303-7668-1-git-send-email-wangyufen@huawei.com> <1395979303-7668-3-git-send-email-wangyufen@huawei.com> <20140328074110.GC11063@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:19141 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbaC1JF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 05:05:27 -0400
In-Reply-To: <20140328074110.GC11063@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/28 15:41, Hannes Frederic Sowa wrote:
> On Fri, Mar 28, 2014 at 12:01:42PM +0800, Wangyufen wrote:
>> From: Wang Yufen <wangyufen@huawei.com>
>>
>> Modify the rt6_need_strict, so that it can be reused
>>
>> Signed-off-by: Wang Yufen <wangyufen@huawei.com>
>> ---
>>  include/net/ip6_route.h | 1 +
>>  net/ipv6/route.c        | 2 +-
>>  2 files changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
>> index 00e3f12..d9c316e 100644
>> --- a/include/net/ip6_route.h
>> +++ b/include/net/ip6_route.h
>> @@ -51,6 +51,7 @@ static inline unsigned int rt6_flags2srcprefs(int flags)
>>  	return (flags >> 3) & 7;
>>  }
>>  
>> +bool rt6_need_strict(const struct in6_addr *daddr);
>>  
>>  void ip6_route_input(struct sk_buff *skb);
>>  
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index fba54a4..f5fdccc 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -373,7 +373,7 @@ static bool rt6_check_expired(const struct rt6_info *rt)
>>  	return false;
>>  }
>>  
>> -static bool rt6_need_strict(const struct in6_addr *daddr)
>> +bool rt6_need_strict(const struct in6_addr *daddr)
>>  {
>>  	return ipv6_addr_type(daddr) &
>>  		(IPV6_ADDR_MULTICAST | IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
> 
> Just a small suggestion:
> I think we can move the whole function as static inline into the header.
> 

Yes, thanks a lot!
I'll modify the patch.

> Thanks,
> 
>   Hannes
> 
> 
> 
