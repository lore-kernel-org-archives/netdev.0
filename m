From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix incorrect route 'expires' value passed to
 userspace.
Date: Mon, 16 Jul 2012 22:26:21 -0700 (PDT)
Message-ID: <20120716.222621.1971297012045485414.davem@davemloft.net>
References: <5003CC41.9080204@cn.fujitsu.com>
	<20120716094124.0040561f@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lw@cn.fujitsu.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257Ab2GQF0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:26:22 -0400
In-Reply-To: <20120716094124.0040561f@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 16 Jul 2012 09:41:24 -0700

> On Mon, 16 Jul 2012 16:09:37 +0800
> Li Wei <lw@cn.fujitsu.com> wrote:
> 
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index becb048..a7fec9d 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -2516,7 +2516,7 @@ static int rt6_fill_node(struct net *net,
>>  		goto nla_put_failure;
>>  	if (!(rt->rt6i_flags & RTF_EXPIRES))
>>  		expires = 0;
>> -	else if (rt->dst.expires - jiffies < INT_MAX)
>> +	else if ((int)(rt->dst.expires - jiffies) < INT_MAX)
>>  		expires = rt->dst.expires - jiffies;
>>  	else
>>  		expires = INT_MAX;
> 
> Why not use time_is_after_jiffies() macro?

This test has a wider window of acceptance.
