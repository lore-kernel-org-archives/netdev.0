From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Mon, 23 Apr 2012 17:01:01 -0400 (EDT)
Message-ID: <20120423.170101.1369764871919045849.davem@davemloft.net>
References: <1335201795.5205.35.camel@edumazet-glaptop>
	<20120423.160149.1515408777176168288.davem@davemloft.net>
	<1335213446.5205.65.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org, therbert@google.com,
	ncardwell@google.com, maze@google.com, ycheng@google.com,
	ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753966Ab2DWVB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 17:01:26 -0400
In-Reply-To: <1335213446.5205.65.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Apr 2012 22:37:26 +0200

> We could try to coalesce ACKs before backlogging them. I'll work on
> this.

Great idea, although I wonder about the effect this could have on RTT
measurements.  Instead of having N RTT measurements, we'd have just
one.

Granted, what happens right now wrt. RTT measurements with such huge
ACK backlogs isn't all that nice either.

Ideally, perhaps, we'd do a timestamp diff at the time we insert the
packet into the backlog.  That way we wouldn't gain the RTT inaccuracy
introduced by such queueing delays and ACK backlogs.

Another way to look at it is that the coalesced scheme would actually
improve RTT measurements, since the most accurate (and least
"delayed") of the timestamps would be the only one processed :-)
