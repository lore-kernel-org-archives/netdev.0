From: Stephen Clark <sclark46@earthlink.net>
Subject: ipv6 doesn't chose correct source address
Date: Thu, 03 Feb 2011 10:10:43 -0500
Message-ID: <4D4AC573.6010506@earthlink.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:49462 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755806Ab1BCPKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 10:10:44 -0500
Received: from [69.22.83.66] (helo=joker.seclark.com)
	by elasmtp-banded.atl.sa.earthlink.net with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <sclark46@earthlink.net>)
	id 1Pl0pY-0006ZX-1u
	for netdev@vger.kernel.org; Thu, 03 Feb 2011 10:10:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a Linux 2.6.32.26-175.fc12 box with
two possible ipv6 default gateways. So I was trying
to have two different ipv6 addresses on my eth0 interface.
Then by simply changing my default ipv6 gateway have packets
routed appropriately.

But when I do this the source address in the packet always is the
first ipv6 address and not the one that should be associated with
the corresponding default route.

ip -6 addr sh
4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
     inet6 2001:470:34::129:91/48 scope global
        valid_lft forever preferred_lft forever
     inet6 2001:4830:28::129:91/48 scope global
        valid_lft forever preferred_lft forever
     inet6 fe80::21c:c0ff:fe94:3a12/64 scope link
        valid_lft forever preferred_lft forever

ip -6 rout sh
default via 2001:4830:28::1 dev eth0  metric 1024  mtu 1500 advmss 1440 
hoplimit 0

so I would expect to have packet going out the default address use the 
source address
of 2001:4830:28::129:91

but:
09:50:28.887483 IP6 2001:470:34::129:91 > 2001:558:1002:5:68:87:64:48: 
ICMP6, echo request, seq 1, length 64

I would have expected the source address to be: 2001:4830:28::129:91

This works correctly with ipv4.
ip addr sh eth0
4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast 
state UP qlen 1000
     link/ether 00:1c:c0:94:3a:12 brd ff:ff:ff:ff:ff:ff
     inet 10.0.129.91/17 brd 10.0.255.255 scope global eth0
     inet 192.168.198.48/24 scope global eth0
     inet 10.254.150.91/24 scope global eth0
     inet 10.0.1.91/24 scope global eth0
     inet 192.168.3.6/24 scope global eth0
     inet 192.168.198.91/24 scope global secondary eth0

default via 192.168.198.252 dev eth0

09:52:06.968934 IP 192.168.198.48 > 68.87.64.48: ICMP echo request, id 
34402, seq 1, length 64



Is this broken or a feature of ipv6 or a misconfiguration on my part?

Thanks,
Steve

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)



