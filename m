From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 1/2] ipv6: enforce flowi6_oif usage in
 ip6_dst_lookup_tail()
Date: Thu, 28 Jan 2016 14:02:23 +0100
Message-ID: <56AA115F.70606@stressinduktion.org>
References: <cover.1453830778.git.pabeni@redhat.com>
 <88bb9789390b781edd13fc4bfaf9fec868f693dd.1453830778.git.pabeni@redhat.com>
 <56A90EB7.5000702@stressinduktion.org> <1453984050.5118.37.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:60382 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966362AbcA1NC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 08:02:28 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 89E9F2014B
	for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 08:02:27 -0500 (EST)
In-Reply-To: <1453984050.5118.37.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28.01.2016 13:27, Paolo Abeni wrote:
> On Wed, 2016-01-27 at 19:38 +0100, Hannes Frederic Sowa wrote:
>> On 27.01.2016 14:45, Paolo Abeni wrote:
>>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>> index 3c8834b..973cb73 100644
>>> --- a/net/ipv6/route.c
>>> +++ b/net/ipv6/route.c
>>> @@ -1183,11 +1183,10 @@ static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table
>>>    	return ip6_pol_route(net, table, fl6->flowi6_oif, fl6, flags);
>>>    }
>>>
>>> -struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
>>> -				    struct flowi6 *fl6)
>>> +struct dst_entry *ip6_route_output_flags(struct net *net, const struct sock *sk,
>>> +					 struct flowi6 *fl6, int flags)
>>>    {
>>>    	struct dst_entry *dst;
>>> -	int flags = 0;
>>>    	bool any_src;
>>>
>>>    	dst = l3mdev_rt6_dst_by_oif(net, fl6);
>>> @@ -1208,6 +1207,13 @@ struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
>>>
>>>    	return fib6_rule_lookup(net, fl6, flags, ip6_pol_route_output);
>>>    }
>>> +EXPORT_SYMBOL_GPL(ip6_route_output_flags);
>>> +
>>> +struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
>>> +				   struct flowi6 *fl6)
>>> +{
>>> +	return ip6_route_output_flags(net, sk, fl6, 0);
>>> +}
>>>    EXPORT_SYMBOL(ip6_route_output);
>>
>> I think this can just be a static inline function.
>>
>> Is it a lot of work to introduce the flags argument globally? Most other
>> functions already have a flags parameter, maybe instead of just adding
>> another wrapper just bite the bullet and add it everywhere?
>
> There are ~20 call sites for ip6_route_output(). Replacing them with
> ip6_route_output_flags() should be trivial, but it sounds quite
> invasive. Moving the new ip6_route_output() definition into the header
> file as static inline function should be pretty much equivalent, may I
> go with the latter option ?

I am not really a fan of such static inline wrappers all over the place, 
it doesnt't really help to evolve the code base.

But as a net/stable fix, go with the static inline first, IMHO.

Thanks,
Hannes
