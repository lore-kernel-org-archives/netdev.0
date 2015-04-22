From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix possible deadlock in tcp_send_fin()
Date: Wed, 22 Apr 2015 14:15:34 -0400 (EDT)
Message-ID: <20150422.141534.1363191163633903371.davem@davemloft.net>
References: <55110009.4020706@akamai.com>
	<1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
	<1429666344.18561.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johunt@akamai.com, netdev@vger.kernel.org, edumazet@google.com,
	gthelen@google.com, rientjes@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013AbbDVSPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 14:15:39 -0400
In-Reply-To: <1429666344.18561.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Apr 2015 18:32:24 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Using sk_stream_alloc_skb() in tcp_send_fin() is dangerous in
> case a huge process is killed by OOM, and tcp_mem[2] is hit.
> 
> To be able to free memory we need to make progress, so this
> patch allows FIN packets to not care about tcp_mem[2], if
> skb allocation succeeded.
> 
> In a follow-up patch, we might abort tcp_send_fin() infinite loop
> in case TIF_MEMDIE is set on this thread, as memory allocator
> did its best getting extra memory already. 
> 
> This patch reverts d22e15371811 ("tcp: fix tcp fin memory accounting")
> 
> Fixes: d22e15371811 ("tcp: fix tcp fin memory accounting")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, since the tcp fin memory accounting change
went to -stable already.

Wrt. longer term solutions, I would even be OK at this point aborting
the connection altogether if the skb allocation fails period.  Not
just if TIF_MEMDIE is set.  That endless loop has been nothing but
trouble.

Thanks.
