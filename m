From: David Miller <davem@davemloft.net>
Subject: Re: BQL + Basic Latency under load results - 100Mbit, GSO/TSO off,
 pfifo_fast vs SFQ vs QFQ
Date: Tue, 03 Jan 2012 12:52:37 -0500 (EST)
Message-ID: <20120103.125237.6858695266751093.davem@davemloft.net>
References: <CAA93jw5JjVBQOFL=td55rOpXbUYc=uT_rjeY04O137g_-tBJHw@mail.gmail.com>
	<CAA93jw7bLnHtVnZGN5wVPQZc46XT_B--cY1ocUbnm1AS=J_YHw@mail.gmail.com>
	<1325478811.2526.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave.taht@gmail.com, jg@freedesktop.org, shemminger@vyatta.com,
	jch@pps.jussieu.fr, nichols@pollere.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136Ab2ACRwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 12:52:55 -0500
In-Reply-To: <1325478811.2526.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Jan 2012 05:33:31 +0100

> [PATCH net-next] sch_sfq: dont put new flow at the end of flows
> 
> SFQ enqueue algo puts a new flow _behind_ all pre-existing flows in the
> circular list. In fact this is probably an old SFQ implementation bug.
> 
> 100 Mbits = ~8333 full frames per second, or ~8 frames per ms.
> 
> With 50 flows, it means your "new flow" will have to wait 50 packets
> being sent before its own packet. Thats the ~6ms.
> 
> We certainly can change SFQ to give a priority advantage to new flows,
> so that next dequeued packet is taken from a new flow, not an old one.
> 
> Reported-by: Dave Taht <dave.taht@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
