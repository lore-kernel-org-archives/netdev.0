From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH V2 resend] ipv6: fix incorrect route 'expires' value passed
 to userspace
Date: Mon, 23 Jul 2012 09:05:05 +0800
Message-ID: <500CA341.3070901@cn.fujitsu.com>
References: <20120719.104906.38765587582698093.davem@davemloft.net> <5008B794.7010904@cn.fujitsu.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6F9C@saturn3.aculab.com> <20120720.112241.2111041227435292899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:42255 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752618Ab2GWBFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2012 21:05:55 -0400
In-Reply-To: <20120720.112241.2111041227435292899.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2012 02:22 AM, David Miller wrote:
> From: "David Laight" <David.Laight@ACULAB.COM>
> Date: Fri, 20 Jul 2012 11:32:05 +0100
> 
>>> -	else if (rt->dst.expires - jiffies < INT_MAX)
>>> -		expires = rt->dst.expires - jiffies;
>>> +	else if ((long)rt->dst.expires - (long)jiffies > INT_MIN
>>> +			&& (long)rt->dst.expires - (long)jiffies <
>> INT_MAX)
>>> +		expires = (long)rt->dst.expires - (long)jiffies;
>>>  	else
>>> -		expires = INT_MAX;
>>> +		expires = time_is_after_jiffies(rt->dst.expires) ?
>> INT_MAX : INT_MIN;
>>
>> I can't help feeling there is a better way to do this.
>> Maybe:
>> 	long expires = rt->dst.expires - jiffies;
>> 	if (expires != (int)expires)
>> 		expires = expires > 0 ? INT_MAX : INT_MIN;
>> Although maybe -INT_MAX instead of INT_MIN.
> 
> This patch also does not apply at all to net-next, so needs to be
> redone regardless.

I'll redone this patch base on 'net-next'.

Thanks

> 
> 
