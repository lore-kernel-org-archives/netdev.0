From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: Implement read-only protection and COW'ing of
 metrics.
Date: Thu, 27 Jan 2011 12:28:24 -0800 (PST)
Message-ID: <20110127.122824.193719098.davem@davemloft.net>
References: <20101216.115900.183061857.davem@davemloft.net>
	<20110126.152538.260074157.davem@davemloft.net>
	<1296122511.3027.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46486
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752485Ab1A0U1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 15:27:49 -0500
In-Reply-To: <1296122511.3027.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 Jan 2011 11:01:51 +0100

> Since you use cmpxchg() to permut the dst->_metrics, I feel this rt->fi
> needs some protection as well. Maybe store fi pointer inside the metrics
> instead of dst, or else you need a spinlock to perform the whole
> transaction (change dst->_metrics & rt->fi) ?

I think this is OK, because there are only two points at which the
"rt->fi" is tested and (conditionally) released.

1) At dst destruction time, which is when no other references may
   exist to the dst.

2) At COW time, and here we know a) we are the one and only entity
   which successfully COW'd the metrics and b) there is at least our
   reference to the dst and therefore dst destroy (and therefore case
   #1) may not execute in parallel with us.

So I think it's safe.
