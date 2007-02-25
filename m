From: Florian Zumbiehl <florz@gmx.de>
Subject: Weird problem with PPPoE on tap interface
Date: Sun, 25 Feb 2007 20:54:56 +0100
Message-ID: <20070225195455.GC3318@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mostrows@speakeasy.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-d9bbdc04.pool.mediaWays.net ([217.187.220.4]:3934 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965106AbXBYUQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 15:16:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm experiencing a pretty strange problem with kernel PPPoE on tap
interfaces with a vanilla 2.6.20 kernel that prevents the PPP connection
from being established:

Every PPPoE session packet (that is, LCP, since it never gets to a stage
where any other session data is being exchanged) is delivered to pppd
twice. This can be seen from pppd's logging messages when debugging
is enabled, and strace confirmed that it indeed does read() the exact
same data twice in a row from the same file descriptor - even though
a tcpdump on the corresponding tap interface does show each packet only
once.

For confirming this, I used a program with a select() loop that simply
moves packets unchanged and without reordering back and forth between
a "real" ethernet interface in promiscuous mode and the tap interface
used by pppd.

What makes this even stranger, is, that the setup works perfectly (and
only a single copy of packets is delivered to pppd) if I simply replace
the tap interface in pppd's config with the "real" ethernet interface
that the tap interface was previously bridged to (it's an ISA NE2K
clone, BTW).

Finally, it also works perfectly when I use userspace rp-pppoe through
the tap interface.

So far, I also confirmed that in kernel space, the call to ppp_input()
in drivers/net/pppoe.c is executed as many times as pppd receives a
packet, so the problem must be somewhere before that.

Well, I'm gonna try to find out more - but if someone with some
more knowledge of the involved kernel code would be willing to help
with this in some way or another, that would certainly be
appreciated ;-) - if you do need any additional information, let me
know ...

Florian
