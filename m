From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 0/4] rps: Look into tunnels to get hash
Date: Sun, 14 Aug 2011 22:44:33 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1108142135340.24599@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:61722 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676Ab1HOFoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 01:44:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this version fixed calls to sock_rps_save_rxhash in IPv6 with correct
arguments and addressed comments from Eric Dumazet.

The patches in this series are to look into encapsulated packets
to compute the rx hash for RPS.  Before these patches, all packets
received on the same tunnel would wind up on the same RPS CPU-- this
can lead to very poor loading, and make RFS ineffective on these
packets.

This patch supports getting the rxhash out of a GRE encapsulated packet.

A couple of caveats:

- rxhash should be disabled in device to be able to use this.  I believe
probably all NICs would just provide rxhash on the outer packet
2-tuple.
- The l4_rxhash flag was added so that the hash is preserved across the
tunnel and can set in flow tables by the transport.  It would be nice
it driverswould set this to so to provide more useful information to the
stack (like whether the rxhash hash should be used in the flow table).
Unfortutunately, I don't think all drivers will be able to distinguish
the type of hash (2-tuple, 4-tuple, ...) without looking into the
packet.
