From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/15] ipv4: Kill routes during PMTU/redirect updates.
Date: Wed, 18 Jul 2012 12:30:15 -0700 (PDT)
Message-ID: <20120718.123015.476222169838022819.davem@davemloft.net>
References: <20120718.112356.1409220904008377845.davem@davemloft.net>
	<1342638944.2013.10.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37547 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348Ab2GRTaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 15:30:24 -0400
In-Reply-To: <1342638944.2013.10.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 18 Jul 2012 12:15:44 -0700

> On Wed, 2012-07-18 at 11:23 -0700, David Miller wrote:
>> Mark them obsolete so there will be a re-lookup to fetch the
>> FIB nexthop exception info.
> []
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> []
>> @@ -716,8 +717,8 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
>>  					fnhe->fnhe_gw = new_gw;
>>  				spin_unlock_bh(&fnhe_lock);
>>  			}
>> -			rt->rt_gateway = new_gw;
>> -			rt->rt_flags |= RTCF_REDIRECTED;
>> +			if (kill_route)
>> +				rt->dst.obsolete = -2;
> 
> Perhaps -2 should be a #define?
> 
> Perhaps struct dst_entry.obsolete could be a char instead of
> a short and a pad byte could added for some future use.

First thing, char is not signed by default on all systems :-)

But yes, this should be cleaned up.  Also with a big fat comment above
the struct member detailing it's usage.

I'll put this on my TODO list, thanks a lot Joe.
