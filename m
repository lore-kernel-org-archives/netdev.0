From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove skb recycling
Date: Sun, 07 Oct 2012 00:41:09 -0400 (EDT)
Message-ID: <20121007.004109.1308709793907808073.davem@davemloft.net>
References: <1349450151.28867.33.camel@sakura.staff.proxad.net>
	<1349451425.21172.119.camel@edumazet-glaptop>
	<1349454235.21172.132.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbizon@freebox.fr, david+ml@madore.org, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab2JGElL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 00:41:11 -0400
In-Reply-To: <1349454235.21172.132.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 05 Oct 2012 18:23:55 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Over time, skb recycling infrastructure got litle interest and
> many bugs. Generic rx path skb allocation is now using page
> fragments for efficient GRO / TCP coalescing, and recyling
> a tx skb for rx path is not worth the pain.
> 
> Last identified bug is that fat skbs can be recycled
> and it can endup using high order pages after few iterations.
> 
> With help from Maxime Bizon, who pointed out that commit
> 87151b8689d (net: allow pskb_expand_head() to get maximum tailroom)
> introduced this regression for recycled skbs.
> 
> Instead of fixing this bug, lets remove skb recycling.
> 
> Drivers wanting really hot skbs should use build_skb() anyway,
> to allocate/populate sk_buff right before netif_receive_skb()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maxime Bizon <mbizon@freebox.fr>

Applied, thanks Eric.
