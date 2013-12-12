From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Cache route in IP tunnels
Date: Thu, 12 Dec 2013 13:54:33 -0500 (EST)
Message-ID: <20131212.135433.87781160683841713.davem@davemloft.net>
References: <alpine.DEB.2.02.1312112207400.27914@tomh.mtv.corp.google.com>
	<1386833838.19078.45.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611Ab3LLSyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 13:54:35 -0500
In-Reply-To: <1386833838.19078.45.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Dec 2013 23:37:18 -0800

> On Wed, 2013-12-11 at 22:17 -0800, Tom Herbert wrote:
>> Avoid doing a route lookup on every packet being tunneled.
>> 
>> In ip_tunnel.c cache the route returned from ip_route_output if
>> the tunnel is "connected", that is all the routing parameters are
>> taken from tunnel parms for a packet. Specifically, not NBMA tunnel
>> and tos is from tunnel parms (not inner packet).
>> 
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
> 
> Replacing per cpu dst (nh_pcpu_rth_output) with a single shared dst is
> not going to be better on SMP.
> 
> Do you have any performance data using multiqueue NIC, with say 32 cpus
> and 32 TX queues ?
> 
> I suspect a high false sharing on dst refcount.

First off I'm glad someone looked into this, I've been meaning to play
with this for a while.

Secondly, Eric's concern is valid but we should keep in mind that IPV6
tunnels do this kind of caching already so if it's undesirable we
should perhaps undo the caching there too.

But honestly I suspect that doing a lookup every packet is more
expensive than false sharing on a cache entry, but I'm happy to be
proven wrong :)
