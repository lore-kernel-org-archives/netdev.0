From: Steven Barth <steven@midlink.org>
Subject: IPV6_PKTINFO seems not to be honored correctly by RAW-sockets
Date: Tue, 30 Oct 2012 09:58:04 +0100
Message-ID: <508F969C.9080300@midlink.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steven Barth <steven@midlink.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chi.subsignal.org ([188.40.166.11]:33507 "EHLO
	chi.subsignal.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756222Ab2J3JIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 05:08:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I recently noticed that there might be an unexpected behavior in the 
handling of IPV6_PKTINFO for RAW-sockets. It seems that the given 
destination interface is ignored.

I just reproduced this on 3.7.0-rc3 vanilla but some quick tests with 
2.6.32 and 3.5 distro-kernels on different machines showed the same.

I've noticed this first in my own software but I could also reproduce it 
easily with standard tools like ping6 from iputils:

Have 2 network interfaces with (global) IPv6-addresses assigned (e.g. 
eth0 with fd00::1/64 and eth1 with fd01::1/64) and do a ping6 -I eth1 
fd00::1 (ping6 from iputils uses IPV6_PKTINFO internally).

For me the result was that even though I set the interface to eth1 the 
ECHO was still send to eth0.

Also (although probably unrelated) forwarding for IPv6 was disabled.

If I try something similar with IPv4 and ping -I ... the ECHO doesn't go 
out on eth0 but - as expected - on eth1.

However if I use traceroute(6) with -I (ICMP-traceroute) and the -i 
option to determine the interface, packages seem to be sent through the 
expected interface. Internally it seems that traceroute(6) uses 
SO_BINDTODEVICE instead of IP(V6)_PKTINFO which seems to work.

So it seems there might be something wrong with IPV6_PKTINFO or is this 
expected behavior?


Thanks and Regards,

Steven
