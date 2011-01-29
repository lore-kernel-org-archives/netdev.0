From: Jonathan Thibault <jonathan@navigue.com>
Subject: Ethernet over GRE and vlans
Date: Sat, 29 Jan 2011 00:16:06 -0500
Message-ID: <4D43A296.4040906@navigue.com>
References: <4D2F77A8.1010700@navigue.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.navigue.com ([74.117.40.3]:39911 "EHLO mail.navigue.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1749667Ab1A2FSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jan 2011 00:18:01 -0500
In-Reply-To: <4D2F77A8.1010700@navigue.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per one of my previous posts, imagine a setup like this:

Three linux hosts connected to their individual 802.1Q network via
eth0 interface linked by a L3 network through their eth1 interface.
 
 (local network)
 |                                              (remote network 1)
 | eth0.1 <--br1--> gre1.1                                       |
 | eth0.3 <--br0--> gre1 -- (l3_to_host1) -- gre0 <--br0--> eth0-+
 +-eth0
   eth0.4 <--br3--> gre2 -- (l3-to_host2) -- gre0 <--br0--> eth0-+
   eth0.2 <--br2--> gre2.2                                       |
                                                (remote network 2)
 
Wanting only untagged packets from remote networks 1 and 2 requires
simple ebtables rules wich answers my original query.  But I ran into
a strange issue where vlan1 and vlan2 tagged packets from their
respective remote networks do not appear on gre1.1 and gre2.2
interfaces at all.

I see the tagged packets on the gre1 and gre2 interfaces respectively
but cannot make their untagged equivalent (or anything else) show up
on gre2.2 and gre1.1 as they would on standard ethernet devices.

Is it wrong on my part to expect such behaviour from gretap devices
or is this simply not possible/implemented yet?

Please include me in replies, I am not currently subscribed to netdev.

Jonathan

P.S.:  I CCed Mr. Xu as I believe he originally submitted gretap
patches.
