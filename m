From: Lori Jakab <lojakab@cisco.com>
Subject: Re: [PATCH V6 net-next] LISP: Locator/Identifier Separation Protocol
Date: Fri, 27 Jun 2014 10:31:57 +0300
Message-ID: <53AD1DED.3090908@cisco.com>
References: <9D51E1BB-BAB2-4859-A3E1-2C4F56BAD641@logicalelegance.com>	<20140623.150206.1941399398042390524.davem@davemloft.net>	<53AD0D06.6070109@cisco.com> <20140627.001353.840895998677889032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chris@logicalelegance.com, netdev@vger.kernel.org,
	vermagan@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aer-iport-3.cisco.com ([173.38.203.53]:35815 "EHLO
	aer-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbaF0Hb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 03:31:59 -0400
In-Reply-To: <20140627.001353.840895998677889032.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/27/14, 10:13 AM, David Miller wrote:
> From: Lori Jakab <lojakab@cisco.com>
> Date: Fri, 27 Jun 2014 09:19:50 +0300
>
>> Map-Requests can and should be rate limited. Also, if there is no
>> mapping for a packet in the map-cache (while we're waiting for a
>> reply), it is sent to a Proxy-ETR, a dedicated LISP infrastructure box
>> part of the LISP architecture, and gets delivered to the destination.
> Sorry, I don't buy this.
>
> Still sounds DOS'able to me, you cannot process an infinite amount of
> packets backlogged on pending Map Requests, your only choice is to
> start dropping packets.

I think I did not explain the concept of the P-ETR very well.  It is 
like a default route, and you don't backlog packets while you wait on 
pending Map-Requests.  The impact is that packets sent to the P-ETR take 
a detour, but they still get delivered.  After the Map-Reply comes in, 
packets will take the optimal route.  So even with a fixed size cache, 
you still don't need to drop packets.

>
>> If I understand correctly, the route cache was a hash table with
>> multiple keys. We intend to have a trie based look-up table for
>> LISP. Additionally, IPv4 routing was and still is a required component
>> for every networked host, while LISP will be an optional feature.
> I think you misunderstand the problem space.
>
> If you have to lookup on EIDs you have to consider the full 32-bit
> value, even if you use a trie.  Therefore you will have to limit
> the size of your cache, and trim it when it hits certain thresholds.
>
> Therefore it has the same problems that the routing cache had.
>
> The reason the DoS'ability disappeared with the routing cache removed
> is that the remaining datastructures operate on a fixed sized database
> which is not influenced by traffic patterns sent by external hosts.
>
> Read that critical component again: "not influenced by traffic
> patterns sent by external hosts"
>
> LISP fails that test regardless of the data structures you use, any
> external host can influence your cache and how often you have to
> create new entries.
>
> That's a bad design and fundamentally exploitable.

The OVS datapath's flow table is also influenced by traffic patterns 
sent by external hosts.  But while the IPv4 routing table is not 
optional for a networked host, OVS and LISP are, and people deploying 
them can still find value using them, in controlled environments at least.
