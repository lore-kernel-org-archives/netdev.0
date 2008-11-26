From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: release skb->dst in sock_queue_rcv_skb()
Date: Tue, 25 Nov 2008 18:04:04 -0800 (PST)
Message-ID: <20081125.180404.157859705.davem@davemloft.net>
References: <492B8274.6080609@cosmosbay.com>
	<20081124.210038.90767194.davem@davemloft.net>
	<492C919E.3050108@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46999
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751083AbYKZCEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 21:04:05 -0500
In-Reply-To: <492C919E.3050108@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 26 Nov 2008 01:00:30 +0100

> In the meantime, what do you think of the following patch ?
> 
> [PATCH] net: release skb->dst in sock_queue_rcv_skb()
> 
> When queuing a skb to sk->sk_receive_queue, we can release its dst, not
> anymore needed.
> Since current cpu did the dst_hold(), refcount is probably still hot
> int this cpu caches.
> 
> This avoids readers to access the original dst to decrement its refcount,
> possibly a long time after packet reception. This should speedup UDP
> and RAW receive path.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I guess the idea is that if we release quickly we'll not have
to reget the cacheline in owned state.

I wonder if this might actually slightly hurt loads like tbench where
we are banging on the refcnt constantly on every cpu anyways.

Can you do a quick check?
