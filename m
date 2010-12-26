From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: dont create routes on down devices
Date: Sat, 25 Dec 2010 20:05:59 -0800 (PST)
Message-ID: <20101225.200559.112599615.davem@davemloft.net>
References: <4D120096.6080508@6wind.com>
	<1293028779.3027.133.camel@edumazet-laptop>
	<201012231050.25942.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39973
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751740Ab0LZEF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 23:05:29 -0500
In-Reply-To: <201012231050.25942.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Thu, 23 Dec 2010 10:50:25 +0200

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wednesday 22 December 2010, 16:39:39
> 
>> [PATCH] ipv4: dont create routes on down devices
>> 
>> In ip_route_output_slow(), instead of allowing a route to be created on
>> a not UPed device, report -ENETUNREACH immediately.
>> 
>> # ip tunnel add mode ipip remote 10.16.0.164 local
>> 10.16.0.72 dev eth0
>> # (Note : tunl1 is down)
>> # ping -I tunl1 10.1.2.3
>> PING 10.1.2.3 (10.1.2.3) from 192.168.18.5 tunl1: 56(84) bytes of data.
>> (nothing)
>> # ./a.out tunl1
>> # ip tunnel del tunl1
>> Message from syslogd@shelby at Dec 22 10:12:08 ...
>>   kernel: unregister_netdevice: waiting for tunl1 to become free.
>> Usage count = 3
>> 
>> After patch:
>> # ping -I tunl1 10.1.2.3
>> connect: Network is unreachable
>> 
>> 
>> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Cc: Octavian Purdila <opurdila@ixiacom.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Thanks Eric !
> 
> Reviewed-by: Octavian Purdila <opurdila@ixiacom.com>

Applied, thanks everyone.
