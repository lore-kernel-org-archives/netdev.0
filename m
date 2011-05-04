From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/5] More rt->rt_{src,dst} removals.
Date: Wed, 04 May 2011 13:19:34 -0700 (PDT)
Message-ID: <20110504.131934.246537941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60195
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752327Ab1EDUUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 16:20:06 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 546CE24C088
	for <netdev@vger.kernel.org>; Wed,  4 May 2011 13:19:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After this set the number of uses of rt->rt_{src,dst} are very small.

One case to hit still will need a slight rearrangement of how we do
SRR handling, since SRR handling on input pops the nexthop and thus
creates situations where iph->daddr != rt->rt_dst and thus eliminates
the posibility of converting the rt->rt_dst access in ip_forward().

Another class of remaining cases occur in situations where we can
fetch the saddr/daddr from the inet socket.

Soon, all that will be left are the assignments and netlink dump code
cases in net/ipv4/route.c
