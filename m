From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH iproute2] htb: support 64bit rates
Date: Thu, 14 Nov 2013 16:03:26 +0800
Message-ID: <528483CE.6050100@huawei.com>
References: <1384295647.28458.31.camel@edumazet-glaptop2.roam.corp.google.com>	 <52834248.3040103@huawei.com> <1384352510.28458.105.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:46718 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab3KNIEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 03:04:20 -0500
In-Reply-To: <1384352510.28458.105.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/13 22:21, Eric Dumazet wrote:
> On Wed, 2013-11-13 at 17:11 +0800, Yang Yingliang wrote:
>>> -	if (!buffer) buffer = opt.rate.rate / get_hz() + mtu;
>>> -	if (!cbuffer) cbuffer = opt.ceil.rate / get_hz() + mtu;
>>> +	if (!buffer)
>>> +		buffer = rate64 / get_hz() + mtu;
>>> +	if (!cbuffer)
>>> +		cbuffer = ceil64 / get_hz() + mtu;
>>
>> Hi,
>> It may overflow here if rate64 and mtu are big enough.
> 
> Not really.
> 
> get_hz() on current kernels is really huge : 1000000000

Yeah, in normal condition, it won't happen.
If user make a wrong input, such as "rate 0x800000000Gbit",
Overflow happens. Although it has no impact on the value of the "opt.buffer".
If it's better to have a judgement of the buffer's value. :)

Regards,
Yang

> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
