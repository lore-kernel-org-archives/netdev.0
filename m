From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Strange connection slowdown on pcnet32
Date: Thu, 15 Feb 2007 17:50:30 -0500
Message-ID: <20070215225030.GA7585@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:40192 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422692AbXBOXWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Feb 2007 18:22:25 -0500
Received: from caffeine.csclub.uwaterloo.ca (localhost.localdomain [127.0.0.1])
	by caffeine.csclub.uwaterloo.ca (Postfix) with ESMTP id AF81973D35
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 17:52:03 -0500 (EST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have encountered a strange behaviour with the pcnet32.

I am transfering data from a server to a client routing it through my
router.  The router has 2 ethernet ports, both of which are amd 972
chips (pcnet32).  The transfer has so far been either http or ftp (both
see the same problem).  I transfer lots of data, and after a while (I
have seen anywhere from 200 to 700MB or so) the speed suddenly drops to
less than 1KB/s.  If I ping from the router to the server, the ping
requests go out normally (seen by tcpdump on the server) every second,
but on the router the replies are not seen by the kernel for multiple
seconds.  Sometimes I will see 3 ping replies together, sometimes 5 or
even 10.  The turn around times will show 10500, 9500, 8500, ..., 500ms
for the packets received in a batch.  ifconfig on the router shows the
packet receive counts showing up in lumps, just as ping does, and
tcpdump on the interface on the router.

Doing ifconfig down and up on the port connecting to the server makes
the problem clear and it can handle another pile of data before the
problem reappears.

The CPU on the router is not fast enough to ensure there won't ever be
dropped packets at 100Mbps.  When I force the port to the server to
10Mbps I have no problems at all.

Replacing the port to the server with an rtl8139 doesn't show any
problems at 100Mbps, although the transfer rate drops from 6500KBps to
4000KBps compared to using the pcnet32.

Kernel used so far is 2.6.16 and 2.6.18.

I have a tulip card I intend to try with as well just to see if it
affects anything other than the pcnet32.

Does anyone have any hints as to what part of the code to look at for
changes made by doing ifconfig eth1 down; ifconfig eth1 up?  Any ideas
as to what could make the reception of packets suddenly get very very
slow?

On one pass where I was running tcpdump on the router, I saw a wrap of
the sequence number right before the problem occoured, but that has not
been the case every time as far as I can tell, so I am not sure if that
is related to the problem at all.

--
Len Sorensen
