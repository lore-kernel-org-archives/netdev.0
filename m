From: David Miller <davem@davemloft.net>
Subject: Re: state of rtcache removal...
Date: Wed, 16 Feb 2011 22:39:32 -0800 (PST)
Message-ID: <20110216.223932.112610567.davem@davemloft.net>
References: <20110216.160838.39164069.davem@davemloft.net>
	<1297923915.2645.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43745
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751245Ab1BQGi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 01:38:56 -0500
In-Reply-To: <1297923915.2645.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Feb 2011 07:25:15 +0100

> Thanks David for this work in progress.

It was my pleasure :-)

> If I remember my works in last October/November, I also know fib_hash
> was a bit faster than fib_trie (around 20%)...

Right, if table is small hash can be faster.

I just wrote a hack that puts fib_lookup() results into the the
flow cache, and hooked it only into the one fib_lookup() call
that happens in ip_route_output_slow().

This pointed out another costly thing we do when resolving output
routes.  If the flow key's source is not INADDR_ANY, we validate the
source address is our's by doing a fib table lookup in the local
table, with the address in the flow key's destination field.

So even on output we were doing 3 fib lookups :-/

Therefore, the flow cache hack gets rid of 2 of those 3.
