From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: disable GSO on sockets hitting
 dst_allfrag
Date: Sat, 19 May 2012 04:03:13 -0400 (EDT)
Message-ID: <20120519.040313.1890452580451494013.davem@davemloft.net>
References: <1337413904.7029.93.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tore@fud.no
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48191 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932206Ab2ESIEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 04:04:20 -0400
In-Reply-To: <1337413904.7029.93.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 May 2012 09:51:44 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> If the allfrag feature has been set on a host route (due to an ICMPv6
> Packet Too Big received indicating a MTU of less than 1280), we hit a
> very slow behavior in TCP stack, because all big packets are dropped and
> only a retransmit timer is able to push one MSS frame every 200 ms.
> 
> One way to handle this is to disable GSO on the socket the first time a
> super packet is dropped. Adding a specific dst_allfrag() in the fast
> path is probably overkill since the dst_allfrag() case almost never
> happen.
> 
> Result on netperf TCP_STREAM, one flow :
> 
> Before : 60 kbit/sec
> After : 1.6 Gbit/sec
> 
> Reported-by: Tore Anderson <tore@fud.no>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Tore Anderson <tore@fud.no>

Applied.
