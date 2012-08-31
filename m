From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv4: Improve the scaling of the ARP cache for
 multicast destinations.
Date: Thu, 30 Aug 2012 21:06:28 -0400 (EDT)
Message-ID: <20120830.210628.365120808137655227.davem@davemloft.net>
References: <50400B68.3060302@aristanetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gilligan@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44925 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753082Ab2HaBGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 21:06:31 -0400
In-Reply-To: <50400B68.3060302@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bob Gilligan <gilligan@aristanetworks.com>
Date: Thu, 30 Aug 2012 17:55:04 -0700

> The mapping from multicast IPv4 address to MAC address can just as
> easily be done at the time a packet is to be sent.  With this change,
> we maintain one ARP cache entry for each interface that has at least
> one multicast group member.  All routes to IPv4 multicast destinations
> via a particular interface use the same ARP cache entry.  This entry
> does not store the MAC address to use.  Instead, packets for multicast
> destinations go to a new output function that maps the destination
> IPv4 multicast address into the MAC address and forms the MAC header.

Doing an ARP MC mapping on every packet is much more expensive than
doing a copy of the hard header cache.

I do not believe the memory consumption issue you use to justify this
change is a real issue.

If you are talking to that many multicast groups actively, you do want
that many neighbour cache entries.  This is not different from talking
to nearly every IP address on a local /8 subnet.  You'll have a huge
number of neighbour table entries in that case as well.

If your the actual steady state number of active groups being spoken
to is smaller, you can tune the neighbour cache thresholds to collect
old less used entries more quickly.

And this today is trivial, since routes no longer hold a reference
to neighbour entries.  Therefore any neighbour entry whatsoever can
be immediately reclaimed at any moment.

I'm not fond of these patches, and adding yet more special cases to
the neighbour layer, and therefore will not apply them.
