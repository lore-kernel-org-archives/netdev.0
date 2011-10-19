From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] l2tp: give proper headroom in pppol2tp_xmit()
Date: Tue, 18 Oct 2011 23:34:44 -0400 (EDT)
Message-ID: <20111018.233444.955647916101091708.davem@davemloft.net>
References: <1318002357.3207.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab1JSDer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:34:47 -0400
In-Reply-To: <1318002357.3207.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 Oct 2011 17:45:57 +0200

> pppol2tp_xmit() calls skb_cow_head(skb, 2) before calling
> l2tp_xmit_skb()
> 
> Then l2tp_xmit_skb() calls again skb_cow_head(skb, large_headroom)
> 
> This patchs changes the first skb_cow_head() call to supply the needed
> headroom to make sure at most one (expensive) pskb_expand_head() is
> done.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> Maybe we should add a counter to help diagnose too many
> pskb_expand_head() calls...

Applied.

I think it's the kind of event that deserves a tracepoint, this way one
could use perf to notice and diagnose such problems.
