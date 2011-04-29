From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/3] Routing refinements.
Date: Thu, 28 Apr 2011 22:25:06 -0700 (PDT)
Message-ID: <20110428.222506.226772141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37470
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752546Ab1D2FZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 01:25:39 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DC62924C087
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 22:25:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Don't initialize dst entries multiple times during allocation
and creation.

Use caller's flowi object in output route lookup paths.

These changes open the door to getting rid of several aspect of struct
rtcache.  For example, since the output route lookup updates the flow
keys, there is no need to use things like rt->rt_src since the same
information is present in the lookup flow key.

For example, connect() of stream sockets and sendmsg() of datagram
sockets do something like:

	rt = ip_route_connect(... &fl ...);
	...
	something using rt->rt_src

When we can now replace rt->rt_src with fl.saddr

Eventually all instance specific aspects of struct rtable can be
removed and we are left with a routing object that can exist as
a single instance pointed to directly from the routing table
nexthop slots.

The only part I don't have a clean vision on is the inetpeer and
metrics.  But I don't anticipate that being insurmountable.
