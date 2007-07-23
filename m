From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Odd behaviour of proxy_arp
Date: Mon, 23 Jul 2007 16:36:22 -0400
Message-ID: <20070723203622.GA15500@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:41402 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935167AbXGWVKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 17:10:31 -0400
Received: from caffeine.csclub.uwaterloo.ca (localhost [127.0.0.1])
	by caffeine.csclub.uwaterloo.ca (Postfix) with ESMTP id 0346573D29
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 17:03:21 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have been seeing some occasional strange behavior when using
proxy_arp.  I have a router running with an ADSL PPPoE link to the
Internet, and an Ethernet link to a local network.  It has proxy_arp
enabled on the internal Ethernet port since I sometimes have ipsec
tunnels running where I use proxy_arp to proxy for the IP assigned to
the other end of the tunnel so that local machines can find and reach
it.  I run two independent subnets on the local network (one with fixed
IPs for my machines here, and another with DHCP addresses for guest
machines that visit occasionally just to give them Internet access).

I run 10.0.0.0/8 and 192.168.254.0/24 on the local network with the
router having an IP in each subnet.

The strangeness that occurs is that once in a while there is a 10
second period where the system will answer all arp requests for all IPs
on the local network, with it's own MAC address, which is clearly wrong
since it doesn't have any of those IP addresses.  It seems to happen
every couple of days or so on average, although not at any specific
time.  One day it happened at 11:32:30 to 11:32:39, and a few days later
it happened at 12:08:38 to 12:08:48.  If I disable proxy_arp, it never
happens at all, but then I loose the ability to do what I have proxy_arp
enabled for in the first place.

Related to that problem, there is also the annoyance that any IP that
isn't part of either of the two subnets the router belongs to, have arp
requests answered by the router all the time, which it also should not
be answering, since it doesn't actually have a clue what those IP
addresses belong to and certainly has no idea where it should forward to
to reach them.  I occasionally have other random subnets in use on the
network for running local test networks separate from everything else.
It would be great if the kernel would keep its nose out of those subnets
too.

So far I have seen this behavior with 2.6.8, 2.6.16, and 2.6.18 (being
the kernels I have run on this router).

So have I misunderstood something about what proxy_arp is supposed to
do, or is proxy_arp in the kernel simply broken, or is it perhaps
mis-designed?  Are there some tuning parameters that could perhaps make
it actually do what one would expect it to be doing?

--
Len Sorensen
