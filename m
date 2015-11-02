From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: make skb_set_owner_w() more robust
Date: Mon, 02 Nov 2015 16:29:17 -0500 (EST)
Message-ID: <20151102.162917.316954656038063696.davem@davemloft.net>
References: <1446417380.6254.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446418728.6254.101.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446421015.6254.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, edumazet@google.com,
	netdev@vger.kernel.org, kys@microsoft.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35832 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbbKBV3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 16:29:19 -0500
In-Reply-To: <1446421015.6254.106.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 01 Nov 2015 15:36:55 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> skb_set_owner_w() is called from various places that assume
> skb->sk always point to a full blown socket (as it changes
> sk->sk_wmem_alloc)
> 
> We'd like to attach skb to request sockets, and in the future
> to timewait sockets as well. For these kind of pseudo sockets,
> we need to take a traditional refcount and use sock_edemux()
> as the destructor.
> 
> It is now time to un-inline skb_set_owner_w(), being too big.
> 
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Bisected-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied, thanks.
