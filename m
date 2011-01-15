From: Jan Hugo Prins <jhp@jhprins.org>
Subject: Linux IPv6 router table size.
Date: Sat, 15 Jan 2011 22:11:44 +0100
Message-ID: <4D320D90.3090005@jhprins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jhprins.org ([82.95.243.75]:50143 "EHLO mail.jhprins.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753329Ab1AOVWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jan 2011 16:22:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev kernel developers,

In the beginning of December the number of IPv6 routes in the BPG router
tables got somewhere close to 4096 and this number is somewhat magical
in Linux. Why is it magical? Well, the default setting for
net.ipv6.route.max_size is hardcoded in the linux kernel to be exactly
this number, this in contradiction with the IPv4 net.ipv4.route.max_size
which is set based upon the size of your memory. Actually, in the IPv4
part of the kernel sources their is a route.c with a nice formula
telling the kernel how big this number should be. For IPv6 their is also
a route.c with some nice formula in it, the formula says exactly the
following:
net->ipv6.sysctl.ip6_rt_max_size = 4096;

The result of all this magic was that when the BGP RIB in my quagga
routers went over the 4096 routes, quagga started complaining that it
couldn't put the routes in the kernel FIB anymore and this went all into
syslog.

It took some digging to find the reason for these error messages, but
after changing this sysctl to something more useful, everything was fine
again.

Maybe it is a good idea to change this in the IPv6 tree to something
more useful in the same direction of the solution that is in the IPv4 tree.

Greetings,
Jan Hugo Prins

