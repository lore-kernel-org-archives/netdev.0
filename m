From: David Miller <davem@davemloft.net>
Subject: Re: Connect hangs for a while before returns -1 with ECONNREFUSED
 on 3.2 for loopback
Date: Sat, 04 Feb 2012 15:39:58 -0500 (EST)
Message-ID: <20120204.153958.1218040403575354726.davem@davemloft.net>
References: <1328279894.2157.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1328282126.2157.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1328358402.2731.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yurij.Plotnikov@oktetlabs.ru, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab2BDUkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 15:40:10 -0500
In-Reply-To: <1328358402.2731.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 04 Feb 2012 13:26:42 +0100

> [PATCH] ipv4: fix a route regression

Eric, you can't do this.

The rest of the users depend upon the on-stack flow being fully
resolved as a side effect of the route lookup.  For example
ip_route_connect() wants the source address et-al filled in for it.

And the in-socket flow object that gets passed around expects the full
flow key to be resolved by the route lookup path as well.

Fix the case(s) that depend upon the flow not changing instead.
