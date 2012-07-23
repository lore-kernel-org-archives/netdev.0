From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH V2 resend] ipv6: fix incorrect route 'expires' value passed
 to userspace
Date: Mon, 23 Jul 2012 09:02:48 +0800
Message-ID: <500CA2B8.4050305@cn.fujitsu.com>
References: <5003CC41.9080204@cn.fujitsu.com> <20120716.025649.1070277404591664104.davem@davemloft.net> <50076AD3.1060604@cn.fujitsu.com> <20120719.104906.38765587582698093.davem@davemloft.net> <5008B794.7010904@cn.fujitsu.com> <AE90C24D6B3A694183C094C60CF0A2F6026B6F9C@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:13270 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752618Ab2GWBDj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2012 21:03:39 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F9C@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2012 06:32 PM, David Laight wrote:
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
> 
> 	David
> 

Thanks David, your code looks much cleaner and can archieve the same
function except we should use
	long expires = (long)rt->dst.expires - (long)jiffies;
to avoid the wrapping of jiffies.

Thanks, 
Wei
