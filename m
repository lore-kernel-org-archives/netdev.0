From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: remove parentheses in return statement
Date: Fri, 03 Aug 2012 02:22:40 -0700 (PDT)
Message-ID: <20120803.022240.1997423719431165575.davem@davemloft.net>
References: <1343979790-17408-1-git-send-email-sakiwit@gmail.com>
	<1343985584.9299.873.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sakiwit@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788Ab2HCJWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 05:22:41 -0400
In-Reply-To: <1343985584.9299.873.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Aug 2012 11:19:44 +0200

> On Fri, 2012-08-03 at 01:43 -0600, Jean Sacren wrote:
> 
>> @@ -106,8 +106,8 @@ static inline unsigned int inet_addr_hash(struct net *net, __be32 addr)
>>  {
>>  	u32 val = (__force u32) addr ^ hash_ptr(net, 8);
>>  
>> -	return ((val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
>> -		(IN4_ADDR_HSIZE - 1));
>> +	return (val ^ (val >> 8) ^ (val >> 16) ^ (val >> 24)) &
>> +	       (IN4_ADDR_HSIZE - 1);
>>  }
> 
> BTW This should use a faster implementation, I'll send a patch when
> net-next is opened.

There seems to be a few spots where we want the pointer "as a 32-bit
integer" for hashing.  We were discussing arp_hashfn() and ndisc_hashfn()
the other day.

It should basically do something like:

	(u32) ((u64)ptr >> 32 | ((u32) ptr))

on 64-bit and simply (u32)(ptr) on 32-bit.
