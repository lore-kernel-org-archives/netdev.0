From: David Miller <davem@davemloft.net>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 02 Oct 2012 23:10:37 -0400 (EDT)
Message-ID: <20121002.231037.581571797430134988.davem@davemloft.net>
References: <1349192133.12401.768.camel@edumazet-glaptop>
	<1349192919.12401.778.camel@edumazet-glaptop>
	<alpine.LFD.2.00.1210030032430.25856@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, chris2553@googlemail.com,
	netdev@vger.kernel.org, gpiez@web.de, davej@redhat.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab2JCDKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 23:10:39 -0400
In-Reply-To: <alpine.LFD.2.00.1210030032430.25856@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 3 Oct 2012 02:24:53 +0300 (EEST)

> 	Can it be a problem related to fib_info reuse
> from different routes. For example, when local IP address
> is created for subnet we have:
> 
> broadcast 192.168.0.255 dev DEV  proto kernel  scope link  src 192.168.0.1
> 192.168.0.0/24 dev DEV  proto kernel  scope link  src 192.168.0.1
> local 192.168.0.1 dev DEV  proto kernel  scope host  src 192.168.0.1
> 
> 	The "dev DEV  proto kernel  scope link  src 192.168.0.1" is
> a reused fib_info structure where we put cached routes.
> The result can be same fib_info for 192.168.0.255 and
> 192.168.0.0/24. RTN_BROADCAST is cached only for input
> routes. Incoming broadcast to 192.168.0.255 can be cached
> and can cause problems for traffic forwarded to 192.168.0.0/24.
> So, this patch should solve the problem because it
> separates the broadcast from unicast traffic.

Now I understand the problem.

I think the way to fix this is to add cfg->fc_type as another
thing that fib_info objects are key'd by.

I think it also would fix your obscure output multicast case too.
 
