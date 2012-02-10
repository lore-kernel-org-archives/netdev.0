From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Shaping egress and ingress traffic inside an IPSec VPN tunnel
Date: Fri, 10 Feb 2012 15:54:50 -0500
Message-ID: <1328907290.3310.100.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:61368 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932214Ab2BJUyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 15:54:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I am working on a way to dynamically shape our traffic to
conform to 95th percentile billing using tc.  However, I'm struggling a
bit with VPN traffic both for IPSec and OpenVPN.

I think the IPSec egress is the easiest scenario.  I am guessing from
the diagrams I have seen for packet processing that tc will act after
the packet has been encapsulated. Given that, I assume I need to do
something like set a CONNMARK on the traffic and restore the mark so tc
know which IPSec packets to prioritize, correct?

But what about IPSec ingress? The ifb interfaces receive the traffic
before marks are applied so we need to use tc filters to identify the
traffic.  Will the ifb interface see the decrypted traffic? I am
assuming so so that part is easy however, what do we do with the IPSec
packets arriving on the regulated interface?

Let's say I'm pushing VoIP and bulk traffic across my IPSec connection.
Just to simplify matters, let's say I give VoIP traffic 1200 kbits and
everything else 300 kbits.  Let's also say that both are continually
backlogged.  I first thought that we would be fine - the only traffic
initially seen on the interface is ESP traffic (for simplicity's sake)
and this will be passed through using all the shared bandwidth.  Once it
was decrypted, it would pass through as VoIP or bulk traffic, be shaped
scheduled accordingly generating the appropriate back pressure for the
sending system.  But, if the traffic is passed through an interface
twice for IPSec traffic, won't I artificially see twice the bandwidth.
So, if I am shaping my traffic based upon 1500 kbits and that 1500 kbits
passes through the interface twice appearing as 3000 kbits, what
happens?

To keep this email short, I'll send a separate email for OpenVPN and
KLIPS with their separate interfaces.  Thanks - John
