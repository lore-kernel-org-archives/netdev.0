From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 resend] ipv6: fix incorrect route 'expires' value
 passed to userspace
Date: Fri, 20 Jul 2012 11:22:41 -0700 (PDT)
Message-ID: <20120720.112241.2111041227435292899.davem@davemloft.net>
References: <20120719.104906.38765587582698093.davem@davemloft.net>
	<5008B794.7010904@cn.fujitsu.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6F9C@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lw@cn.fujitsu.com, netdev@vger.kernel.org, shemminger@vyatta.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255Ab2GTSWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:22:42 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F9C@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Fri, 20 Jul 2012 11:32:05 +0100

>> -	else if (rt->dst.expires - jiffies < INT_MAX)
>> -		expires = rt->dst.expires - jiffies;
>> +	else if ((long)rt->dst.expires - (long)jiffies > INT_MIN
>> +			&& (long)rt->dst.expires - (long)jiffies <
> INT_MAX)
>> +		expires = (long)rt->dst.expires - (long)jiffies;
>>  	else
>> -		expires = INT_MAX;
>> +		expires = time_is_after_jiffies(rt->dst.expires) ?
> INT_MAX : INT_MIN;
> 
> I can't help feeling there is a better way to do this.
> Maybe:
> 	long expires = rt->dst.expires - jiffies;
> 	if (expires != (int)expires)
> 		expires = expires > 0 ? INT_MAX : INT_MIN;
> Although maybe -INT_MAX instead of INT_MIN.

This patch also does not apply at all to net-next, so needs to be
redone regardless.
