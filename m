From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Link-local source IPv6 address in unicast Neighbor Solicitation towards global destination
Date: Thu, 6 Mar 2014 08:02:50 +0100
Message-ID: <20140306070250.GC26307@order.stressinduktion.org>
References: <trinity-07b36174-6d20-4edd-b2f3-553cf69a5ac7-1394028029667@3capp-gmx-bs51>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44517 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbaCFHCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 02:02:52 -0500
Content-Disposition: inline
In-Reply-To: <trinity-07b36174-6d20-4edd-b2f3-553cf69a5ac7-1394028029667@3capp-gmx-bs51>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon!

On Wed, Mar 05, 2014 at 03:00:29PM +0100, Simon Schneider wrote:
> I noticed something I don't quite understand in a very basic scenario.
> 
> Two machines connected to each other, say A and B.
> 
> Both have their automatically configured link-local IPv6 addresses on the interface, plus one global IPv6 interface address.
> 
> A pings the global address of B.
> 
> What happens:
> 1) Address resolution from A to B. B creates a neighbor cache entry for A's address in STALE state. Since B sends Neighbor Advertisement back to A, the entry moves to DELAY and the delay_first_probe_time timer (5s) is started.
> 
> 2) After successful resolution, echo request / reply are exchanged.
> 
> 3) After delay_first_probe_time at B expires, B transmits a unicast Neighbor Solicitation to A's global address (reachability check). 
> 
> All good so far.
> 
> However, although the destination address of the NS has global scope, B uses its link-local address as source.
> 
> I don't think this is correct. According to the source address selection rules in RFC3484, chapter 5, Rule 2 should match and B's global interface address should be used as source.

Plain RFC3484 cannot be used to select source address for NS, as we
must be sure to select an IPv6 address belonging to the interface and
RFC3484 does not gurantee that (Rule 2 would filter out link-local address
in case of global scope while only Rule 5 later would prefer to select
an address belonging to the interface). It would be possible to try RFC3484
source selection, check if the address belongs to the interface and fallback
to LL address in case it does not. I'll test if it improves things.

> In this simple example, it leads to a sequence of further reachability checks for the link-local addresses of A and B. I don't think these are necessary and they could be avoided if B had used its global interface address as source in the first NS.
> 
> Observed under kernel version 3.11.
> 
> Is this a bug or do I miss something?

Always using link-local address in this scenario is in my opinion totally
valid but maybe not the best choice.

Greetings,

  Hannes
