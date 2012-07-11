From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPoIB: fix skb truesize underestimatiom
Date: Tue, 10 Jul 2012 23:37:43 -0700 (PDT)
Message-ID: <20120710.233743.282062793119280863.davem@davemloft.net>
References: <1341950621.3265.6331.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, erezsh@mellanox.com, roland@purestorage.com,
	netdev@vger.kernel.org, shlomop@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754324Ab2GKGhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 02:37:46 -0400
In-Reply-To: <1341950621.3265.6331.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Jul 2012 22:03:41 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Or Gerlitz reported triggering of WARN_ON_ONCE(delta < len); in
> skb_try_coalesce()
> This warning tracks drivers that incorrectly set skb->truesize
> 
> IPoIB indeed allocates a full page to store a fragment, but only
> accounts in skb->truesize the used part of the page (frame length)
> 
> This patch fixes skb truesize underestimation, and
> also fixes a performance issue, because RX skbs have not enough tailroom
> to allow IP and TCP stacks to pull their header in skb linear part
> without an expensive call to pskb_expand_head()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied to net, thanks.
