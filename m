From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next 2/3] ipv6: use newly introduced __ipv6_addr_needs_scope_id
 and ipv6_iface_scope_id
Date: Thu, 14 Feb 2013 14:31:06 -0500
Message-ID: <511D3B7A.8040802@hp.com>
References: <20130212221634.GA7212@order.stressinduktion.org> <20130213001357.GB1096@order.stressinduktion.org> <511AFF9A.8040506@hp.com> <511BC3B3.3070405@linux-ipv6.org> <20130214042543.GB24534@order.stressinduktion.org> <511D01FA.8080506@hp.com> <20130214185326.GB8611@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:45073 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934846Ab3BNTbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 14:31:09 -0500
In-Reply-To: <20130214185326.GB8611@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2013 01:53 PM, Hannes Frederic Sowa wrote:
> On Thu, Feb 14, 2013 at 10:25:46AM -0500, Brian Haley wrote:
>>> [PATCH net-next RFC] ipv6: introduce new type ipv6_addr_props to hold type and scope
>>>
>>> ---
>>>  include/net/ipv6.h       | 16 +++++---
>>>  net/ipv6/addrconf.c      | 27 +++++++-------
>>>  net/ipv6/addrconf_core.c | 97 +++++++++++++++++++++++++++++++-----------------
>>>  net/ipv6/datagram.c      | 12 +++---
>>>  4 files changed, 95 insertions(+), 57 deletions(-)
>>>
>>> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
>>> index 851d541..3a3ec1cc 100644
>>> --- a/include/net/ipv6.h
>>> +++ b/include/net/ipv6.h
>>> @@ -298,20 +298,26 @@ static inline int ip6_frag_mem(struct net *net)
>>>  #define IPV6_FRAG_LOW_THRESH	(3 * 1024*1024)	/* 3145728 */
>>>  #define IPV6_FRAG_TIMEOUT	(60 * HZ)	/* 60 seconds */
>>>  
>>> -extern int __ipv6_addr_type(const struct in6_addr *addr);
>>> +struct ipv6_addr_props {
>>> +	u16 type;
>>> +	s16 scope;
>>> +};
>>
>> Seeing this makes me think we should unify the flags and scope members of
>> inet6_ifaddr to something like this, moving to a single set of values for IPv6
>> addresses.  Then ipv6_dev_get_saddr() wouldn't have to use __ipv6_adr_type() as
>> much since the address struct would already have the values.  Possible future
>> work...
> 
> Thanks for your feedback. I will incooperate it in my patch.

Ok, just don't worry about this above one right now, once you dig into it you
will realize it's not straightforward.  I'd just fix any existing bugs first.
I'll see if I can find the time to send out an RFC patch of what I mean...

-Brian
