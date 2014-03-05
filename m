From: "Simon Schneider" <simon-schneider@gmx.net>
Subject: Link-local source IPv6 address in unicast Neighbor Solicitation
 towards global destination
Date: Wed, 5 Mar 2014 15:00:29 +0100
Message-ID: <trinity-07b36174-6d20-4edd-b2f3-553cf69a5ac7-1394028029667@3capp-gmx-bs51>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:60631 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752296AbaCEOAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 09:00:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I noticed something I don't quite understand in a very basic scenario.

Two machines connected to each other, say A and B.

Both have their automatically configured link-local IPv6 addresses on the interface, plus one global IPv6 interface address.

A pings the global address of B.

What happens:
1) Address resolution from A to B. B creates a neighbor cache entry for A's address in STALE state. Since B sends Neighbor Advertisement back to A, the entry moves to DELAY and the delay_first_probe_time timer (5s) is started.

2) After successful resolution, echo request / reply are exchanged.

3) After delay_first_probe_time at B expires, B transmits a unicast Neighbor Solicitation to A's global address (reachability check). 

All good so far.

However, although the destination address of the NS has global scope, B uses its link-local address as source.

I don't think this is correct. According to the source address selection rules in RFC3484, chapter 5, Rule 2 should match and B's global interface address should be used as source.

In this simple example, it leads to a sequence of further reachability checks for the link-local addresses of A and B. I don't think these are necessary and they could be avoided if B had used its global interface address as source in the first NS.

Observed under kernel version 3.11.

Is this a bug or do I miss something?

Comments highly appreciated.

best regards, Simon Schneider
