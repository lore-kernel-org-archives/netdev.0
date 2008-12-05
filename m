From: David Miller <davem@davemloft.net>
Subject: Re: IPv6 multicast bind(), esp. v4-mapped addresses
Date: Fri, 05 Dec 2008 00:03:22 -0800 (PST)
Message-ID: <20081205.000322.147998414.davem@davemloft.net>
References: <alpine.LRH.2.00.0812050820380.28482@netcore.fi>
	<20081205.161117.109565135.yoshfuji@linux-ipv6.org>
	<alpine.LRH.2.00.0812050928340.28482@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51714
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750720AbYLEIDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 03:03:22 -0500
In-Reply-To: <alpine.LRH.2.00.0812050928340.28482@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Savola <pekkas@netcore.fi>
Date: Fri, 5 Dec 2008 09:42:43 +0200 (EET)

> It does this:
> 
> setsockopt(7, SOL_IPV6, IPV6_MULTICAST_HOPS, [1], 4) = 0
>
> In Java MulticastSocket API, if you only specify the port and not
> multicast group, it will bind to "::", and it succeeds.  Afterwards
> Java issues an IPv4 IGMP join:
>
> setsockopt(7, SOL_IP, IP_ADD_MEMBERSHIP, "\351\f\f\f\0\0\0\0\0\0\0\0", 12) = 0
>
> So Java implementation will parse whether the group is IPv4 or IPv6
> multicast -- it isn't using MCAST_JOIN_GROUP API.  It could be
> argued that if it already knows the protocol, it _could_ create IPv4
> socket from the start, instead of doing this via a mapped v6 socket.

>From what I've read, ipv4 mapped addresses are full of all kinds of
tricky cases and issues.  And, given that, using ipv4 mapped address
for ipv4 multicast is just asking for trouble in my opinion.
