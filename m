From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2 v2] Fix ipv6 routing table entry limit.
Date: Fri, 24 Jun 2011 16:47:06 -0700 (PDT)
Message-ID: <20110624.164706.1200327249570461124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@hostway.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754918Ab1FXXrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 19:47:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As discussed in other threads, the routing table lives in the same
data structure as cached routing entries.  This enforces a false
limit on the number of routing table entries one can install
on ipv6 and this is becomming a real problem for people.

Fix this by adding a DST_NOCOUNT flag and use it for ipv6 routing
table entries.

No special handling is necessary when cloning or copying since
the flags are never directly copied by the clone/copy code in
ipv6.

This is a 2 patch series now in order to sanitize the dst->flags
setting done in net/ipv6/route.c

I've tested this by adding and removing ~16K ipv6 routes over
and over again, the routing cache limit never got hit.

Simon, you'll need to work out that crash you were seeing since
I can't reproduce it on any of my machines.
