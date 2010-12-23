From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] ipv4: dont create routes on down devices
Date: Thu, 23 Dec 2010 10:50:25 +0200
Message-ID: <201012231050.25942.opurdila@ixiacom.com>
References: <4CA208C9.1020800@6wind.com> <4D120096.6080508@6wind.com> <1293028779.3027.133.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:13685 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752027Ab0LWIu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 03:50:28 -0500
In-Reply-To: <1293028779.3027.133.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wednesday 22 December 2010, 16:39:39

> [PATCH] ipv4: dont create routes on down devices
> 
> In ip_route_output_slow(), instead of allowing a route to be created on
> a not UPed device, report -ENETUNREACH immediately.
> 
> # ip tunnel add mode ipip remote 10.16.0.164 local
> 10.16.0.72 dev eth0
> # (Note : tunl1 is down)
> # ping -I tunl1 10.1.2.3
> PING 10.1.2.3 (10.1.2.3) from 192.168.18.5 tunl1: 56(84) bytes of data.
> (nothing)
> # ./a.out tunl1
> # ip tunnel del tunl1
> Message from syslogd@shelby at Dec 22 10:12:08 ...
>   kernel: unregister_netdevice: waiting for tunl1 to become free.
> Usage count = 3
> 
> After patch:
> # ping -I tunl1 10.1.2.3
> connect: Network is unreachable
> 
> 
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Cc: Octavian Purdila <opurdila@ixiacom.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Eric !

Reviewed-by: Octavian Purdila <opurdila@ixiacom.com>
