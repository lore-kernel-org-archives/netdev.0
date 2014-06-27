From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V6 net-next] LISP: Locator/Identifier Separation
 Protocol
Date: Fri, 27 Jun 2014 00:13:53 -0700 (PDT)
Message-ID: <20140627.001353.840895998677889032.davem@davemloft.net>
References: <9D51E1BB-BAB2-4859-A3E1-2C4F56BAD641@logicalelegance.com>
	<20140623.150206.1941399398042390524.davem@davemloft.net>
	<53AD0D06.6070109@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chris@logicalelegance.com, netdev@vger.kernel.org,
	vermagan@cisco.com
To: lojakab@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598AbaF0HN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 03:13:56 -0400
In-Reply-To: <53AD0D06.6070109@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lori Jakab <lojakab@cisco.com>
Date: Fri, 27 Jun 2014 09:19:50 +0300

> Map-Requests can and should be rate limited. Also, if there is no
> mapping for a packet in the map-cache (while we're waiting for a
> reply), it is sent to a Proxy-ETR, a dedicated LISP infrastructure box
> part of the LISP architecture, and gets delivered to the destination.

Sorry, I don't buy this.

Still sounds DOS'able to me, you cannot process an infinite amount of
packets backlogged on pending Map Requests, your only choice is to
start dropping packets.

> If I understand correctly, the route cache was a hash table with
> multiple keys. We intend to have a trie based look-up table for
> LISP. Additionally, IPv4 routing was and still is a required component
> for every networked host, while LISP will be an optional feature.

I think you misunderstand the problem space.

If you have to lookup on EIDs you have to consider the full 32-bit
value, even if you use a trie.  Therefore you will have to limit
the size of your cache, and trim it when it hits certain thresholds.

Therefore it has the same problems that the routing cache had.

The reason the DoS'ability disappeared with the routing cache removed
is that the remaining datastructures operate on a fixed sized database
which is not influenced by traffic patterns sent by external hosts.

Read that critical component again: "not influenced by traffic
patterns sent by external hosts"

LISP fails that test regardless of the data structures you use, any
external host can influence your cache and how often you have to
create new entries.

That's a bad design and fundamentally exploitable.
