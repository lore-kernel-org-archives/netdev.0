From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/4] rps: Look into tunnels to get hash
Date: Thu, 19 May 2011 08:38:57 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1105190833050.13026@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:4776 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863Ab1ESPjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 11:39:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
