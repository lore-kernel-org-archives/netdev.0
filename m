From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: allow for bigger reordering level
Date: Wed, 29 Oct 2014 15:06:24 -0400 (EDT)
Message-ID: <20141029.150624.878155212768758630.davem@davemloft.net>
References: <1414471524.13259.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wygivan@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756050AbaJ2TG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 15:06:26 -0400
In-Reply-To: <1414471524.13259.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Oct 2014 21:45:24 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While testing upcoming Yaogong patch (converting out of order queue
> into an RB tree), I hit the max reordering level of linux TCP stack.
> 
> Reordering level was limited to 127 for no good reason, and some
> network setups [1] can easily reach this limit and get limited
> throughput.
> 
> Allow a new max limit of 300, and add a sysctl to allow admins to even
> allow bigger (or lower) values if needed.
> 
> [1] Aggregation of links, per packet load balancing, fabrics not doing
>  deep packet inspections, alternative TCP congestion modules...
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I'll apply this, thanks.

However in the longer term I'd say that this value, if it is to have a
limit, then such a limit should probably be scaled based upon the
window size.
