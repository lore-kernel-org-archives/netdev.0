From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: Implement read-only protection and COW'ing of
 metrics.
Date: Thu, 16 Dec 2010 11:59:00 -0800 (PST)
Message-ID: <20101216.115900.183061857.davem@davemloft.net>
References: <20101215.132113.189700977.davem@davemloft.net>
	<1292529359.2655.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753857Ab0LPT6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 14:58:31 -0500
In-Reply-To: <1292529359.2655.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 16 Dec 2010 20:55:59 +0100

> What prevents fi->fib_metrics to disappear,  if fib is destroyed, since
> we dont take a reference ?

Routing cache is flushed.

Hmm... perhaps we need to force-COW or revert to the default zero
metrics for any routing cache entries with reference counts?

Or maybe that's not even needed.

Because nobody should try to touch metrics without first doing a
dst->check(), especially after the RCU grace period, so it should be
OK no?
