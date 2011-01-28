From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3] ipv4 metrics super-sharing
Date: Fri, 28 Jan 2011 14:35:00 -0800 (PST)
Message-ID: <20110128.143500.260088125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47160
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753287Ab1A1WeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 17:34:25 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A45B824C089
	for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 14:35:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As I mentioned a few days ago, we can "super-share" the metrics
in the most common case, which is that there are not explicit
metrics set for a route.

This makes the metrics all zero, which means we can just alias
the pointer to dst_default_metrics.

Most importantly, this means we avoid atomics on the fib_info ref
count at dst destroy time.

Depending upon the configuration, this can also save a non-trivial
amount of memory in the routing tables.  Honestly, I doubt that
sites entertaining routing tables with hundreds of thousands of
routes have any non-zero metrics specified. :-)
