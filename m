From: David Miller <davem@davemloft.net>
Subject: Re: Rate Limitation of Router Reachability Probing for possible
 dead routers (is Re: ipv6: Do not depend on rt->n in rt6_probe().)
Date: Tue, 22 Jan 2013 00:49:39 -0500 (EST)
Message-ID: <20130122.004939.407076325729804829.davem@davemloft.net>
References: <50FD96E4.1020607@linux-ipv6.org>
	<20130121.154425.239941234471254414.davem@davemloft.net>
	<50FE0BDE.2080206@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082Ab3AVFtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 00:49:42 -0500
In-Reply-To: <50FE0BDE.2080206@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 22 Jan 2013 12:47:42 +0900

> It seems that we removed check for gc_thresh1 (number of
> minimum entries) in neigh_alloc() during 2.3.x but I cannot
> remember the reason (or just I do not know it).

You seem to suggest that neigh_periodic_work() should check gc_thresh1
and I agree with this idea.

Considering how neighbour references work now, what it does currently
doesn't make any sense.

Right now it runs over and over again, unconditionally, and purges
entries even if there are very few of them.
