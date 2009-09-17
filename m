From: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Subject: [ANNOUNCE] new iptables module match large amount of ip addresses
Date: Thu, 17 Sep 2009 21:15:31 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909172100220.27299@artax.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from artax.karlin.mff.cuni.cz ([195.113.26.195]:38942 "EHLO
	artax.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbZIQTfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 15:35:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Here I submit an iptables module that can match large amounts (millions) 
of ip addresses efficiently using binary search. I needed it to protect my 
home network from spam. It may be useful for other people too, so if you 
want it, you can take it and add it to the kernel.

Get the patches for netfilter and kernel at:
http://artax.karlin.mff.cuni.cz/~mikulas/xt_ipfile/
(you need to copy the file include/linux/netfilter/xt_ipfile.h from kernel 
sources to /usr/include/linux/netfilter/ to compile the userspace)

The main features:
- fast matching of large amount of ip addresses using binary search.
- an ability to match ranges of addresses or address/mask subnets.
- fast loading of the addresses (on Pentium 3 850, 2 million addresses 
load in 5.5s, if they are already sorted in the file, the load time is 
just 1.5s).
- memory efficient --- consumes only 8 bytes per address.

USAGE:

prepare a file with addreses, in this example /root/firewall/bad-ips. One 
entry per line, the allowed formats are:
1.2.3.4
1.2.3.0/24
1.2.3.4-1.2.3.8

insert it into iptables with:
iptables -A SPAM -m ipfile --src-file /root/firewall/bad-ips -j DROP

The module doesn't support ipv6 because I don't use it, but it's generic 
enough that it could be extended for it. It could be also extended to 
match ethernet MAC addresses.

Mikulas
