From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next-2.6] net: QDISC_STATE_RUNNING dont need
 atomic bit ops
Date: Wed, 02 Jun 2010 03:25:56 -0700 (PDT)
Message-ID: <20100602.032556.26947105.davem@davemloft.net>
References: <1274460275.2439.469.camel@edumazet-laptop>
	<1274463643.2439.473.camel@edumazet-laptop>
	<1275472233.2725.146.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59471
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754322Ab0FBKZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 06:25:46 -0400
In-Reply-To: <1275472233.2725.146.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Jun 2010 11:50:33 +0200

> __QDISC_STATE_RUNNING is always changed while qdisc lock is held.
> 
> We can avoid two atomic operations in xmit path, if we move this bit in
> a new __state container.
> 
> Location of this __state container is carefully chosen so that fast path
> only dirties one qdisc cache line.
> 
> THROTTLED bit could later be moved into this __state location too, to
> avoid dirtying first qdisc cache line.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also looks good, applied.

One thing about naming.  Here, even though we name the type and the
state member with two leading underscores, the things that actually
modify these state members are helper functions with names that lack
double underscores.

So really, reading the code, you don't see that special considerations
for these state changes might be necessary.
