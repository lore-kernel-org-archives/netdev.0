From: Chris Mason <clm@fb.com>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for /proc/net/ipv6_route
Date: Mon, 28 Apr 2014 13:21:05 -0400
Message-ID: <535E8E01.6070908@fb.com>
References: <535918BC.5030708@fb.com>	<20140425.160929.1031376209639331549.davem@davemloft.net>	<535AC529.4030107@fb.com> <20140426.001134.778620720962127881.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:20294 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753082AbaD1Tfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:35:43 -0400
In-Reply-To: <20140426.001134.778620720962127881.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2014 12:11 AM, David Miller wrote:
> From: Chris Mason <clm@fb.com>
> Date: Fri, 25 Apr 2014 16:27:21 -0400
>
>> Ah ok, so the rtnl mutex can replace rcu_read_lock().  Will it end up
>> blocking any traffic? (sorry, filesystem guys are a little slow)
>
> It stops networking configuration operations.
>
> BTW, this means that netlink based ipv6 route dumps can be
> optimized similarly.  Because those code paths implicitly
> hold the RTNL mutex.
>

Ok, the rtnl mutex looks like a much better path.  I'll give it a shot 
this week.

If anyone working on patches in this area wants help testing, just let 
me know.

-chris
