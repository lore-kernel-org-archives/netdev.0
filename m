From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [RESEND] iproute2 : invalid burst/cburst calculation
 with hrtimers
Date: Wed, 04 Feb 2009 22:20:25 +0100
Message-ID: <498A0699.6020103@gmail.com>
References: <200902021926.17768.denys@visp.net.lb> <20090202100742.690e0c8d@extreme> <200902022021.55849.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:3649 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755150AbZBDVTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 16:19:00 -0500
Received: by fk-out-0910.google.com with SMTP id f33so2245873fkf.5
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2009 13:18:58 -0800 (PST)
In-Reply-To: <200902022021.55849.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryschenko wrote, On 02/02/2009 07:21 PM:

> Why floating point?


Yes, floating point is not enough. get_hz() == 1000000000 could be
a theoretical resolution, but I guess we don't expect to use this,
even if it were possible. Since high resolution can schedule more
often than 1000HZ, it seems these buffers could be set lower (10x,
100x?), but there should be some reasonable limit.

Jarek P.

> It seems get_hz (and burst in result) just cannot be too low.
> Still seems some code in HTB rely on jiffies, so get_hz() probably just wrong.
> 
> Already i'm tried to increase burst/cburst calculation precision, but it will 
> fail still with such high get_hz variable.
> 
> Ii dont know way to get real HZ variable from userspace.
> 
> Here is Martin Devera answer
>> but it really
>> seems as if get_hz() is too high.
>> For 1000Mbps - it is 1MB per 1 ms and assuming HZ=1000, then burst
>> should be about 1MB.
>> But I must admit, I'm not familiar with latest state of HZ in kernel.
>> There was "NO_NZ" effort IIRC, where the HZ granularity can be
>> considerably finer - but still not infinite.
> 
> 
> 
> On Monday 02 February 2009 20:07:42 Stephen Hemminger wrote:
>> On Mon, 2 Feb 2009 19:26:17 +0200
>>
>> Denys Fedoryschenko <denys@visp.net.lb> wrote:
>>> ------------->
>>> iproute2 : invalid burst/cburst calculation with hrtimers
>>>
>>> If hrtimers on, /proc/net/psched shows 4th variable
>>> as 1000000000
>>> Because burst calculated by division rate to this variable,
>>> it will be almost always zero. As result, we will get higher system
>>> load on low rates, and on high rates shaper will not able to process
>>> data. So it is kind of critical bugfix for systems with hrtimers.
>>> It is checked and proved. Core 2 Quad was not able to
>>> shape 200Mbps, and gave only 180-190. It is more safe to set it
>>> to 1000HZ. If user wants, he can set custom "env" HZ variable.
>>>
>>> Signed-off-by: Denys Fedoryschenko <denys@visp.net.lb>
>>> ---
>>>
>>> -------------------------------------------------------
>> I would rather this be converted to floating point.
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


