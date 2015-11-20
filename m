From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix potential huge kmalloc() calls in
 TCP_REPAIR
Date: Fri, 20 Nov 2015 10:58:17 -0500 (EST)
Message-ID: <20151120.105817.2021312996636736468.davem@davemloft.net>
References: <1447909413.22599.191.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@parallels.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60992 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752989AbbKTP6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 10:58:19 -0500
In-Reply-To: <1447909413.22599.191.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Nov 2015 21:03:33 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_send_rcvq() is used for re-injecting data into tcp receive queue.
> 
> Problems :
> 
> - No check against size is performed, allowed user to fool kernel in
>   attempting very large memory allocations, eventually triggering
>   OOM when memory is fragmented.
> 
> - In case of fault during the copy we do not return correct errno.
> 
> Lets use alloc_skb_with_frags() to cook optimal skbs.
> 
> Fixes: 292e8d8c8538 ("tcp: Move rcvq sending to tcp_input.c")
> Fixes: c0e88ff0f256 ("tcp: Repair socket queues")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Good catch, applied and queued up for -stable.

Thanks!
