From: Jim Westfall <jwestfall@surrealistic.net>
Subject: ipv6 secondary ips and default ipv6 ip for new outbound connections
Date: Fri, 18 Mar 2011 16:03:12 -0700
Message-ID: <20110318230312.GX13831@surrealistic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from whipper.surrealistic.net ([75.151.103.193]:52477 "EHLO
	whipper.surrealistic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754690Ab1CRXMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 19:12:32 -0400
Received: from jwestfall by whipper.surrealistic.net with local (Exim 4.69)
	(envelope-from <jwestfall@surrealistic.net>)
	id 1Q0ihM-0007KA-Ap
	for netdev@vger.kernel.org; Fri, 18 Mar 2011 16:03:12 -0700
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On ipv4 the first ip added to a nic will be used as the source ip for 
new outbound connections.  Any additional ips, in the same netblock, 
will be added as secondaries.

ipv6 seems to have the opposite behavior.  The last ipv6 ip added to a 
nic is be used for new outbound connections.

~# ip -6 addr list br0
11: br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 
    inet6 fe80::21a:64ff:fe12:54bd/64 scope link 
       valid_lft forever preferred_lft forever

~# ip addr add 2600:c00:0:1::1101/64 dev br0
~# traceroute6 www.kame.net | head -0
traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1101, 30 hops max, 16 byte packets

~# ip addr add 2600:c00:0:1::1102/64 dev br0
~# traceroute6 www.kame.net | head -0
traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1102, 30 hops max, 16 byte packets

~# ip -6 addr list br0
11: br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 
    inet6 2600:c00:0:1::1102/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 2600:c00:0:1::1101/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::21a:64ff:fe12:54bd/64 scope link 
       valid_lft forever preferred_lft forever

This makes things a bit of a pita when dealing with floater ipv6 ips for 
HA.

This there some way to change this behavior to be like ipv4 or force 
a specific ipv6 ip to be the default used for new outbound connections?

thanks
Jim Westfall
