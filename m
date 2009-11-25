From: Andreas Henriksson <andreas@fatal.se>
Subject: Adding IP(v6) address with scope link creates global address
Date: Wed, 25 Nov 2009 14:59:45 +0100
Message-ID: <20091125135945.GA7195@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy3.bredband.net ([195.54.101.73]:62697 "EHLO
	proxy3.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823AbZKYN7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 08:59:00 -0500
Received: from ipb1.telenor.se (195.54.127.164) by proxy3.bredband.net (7.3.140.3)
        id 4AD3E1BA01303448 for netdev@vger.kernel.org; Wed, 25 Nov 2009 14:59:02 +0100
Received: from gem by amd64.fatal.se with local (Exim 4.69)
	(envelope-from <gem@amd64.fatal.se>)
	id 1NDIPJ-0001tN-BV
	for netdev@vger.kernel.org; Wed, 25 Nov 2009 14:59:45 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

"Jedasothi" reported problems setting scope with iproute on newly added
ipv6 addresses in:
https://bugs.launchpad.net/ubuntu/+source/iproute/+bug/487745

> To reproduce bug run
> ip addr add '::4/64' scope link dev eth0
>
> This results in a line seen with
> ip addr show eth0
> inet6 ::4/64 scope global tentative
>
> The label "global" is seen instead of "link".

This works for me on ipv4 and seems to be only a problem with ipv6.

I think this is a kernel bug. The scope seems to be passed into the
kernel via netlink as specified on the command line.

Looking at the kernel, inet6_rtm_newaddr [1] calls inet6_addr_add [2]
without passing the ifa_scope struct member and then the scope is
generated from the address within the inet6_addr_add function.

It would be nice if someone could verify this and while at it
also whip up a patch and forward to the right person. ;)

[1]: http://lxr.linux.no/#linux+v2.6.31/net/ipv6/addrconf.c#L3263
[2]: http://lxr.linux.no/#linux+v2.6.31/net/ipv6/addrconf.c#L2081

-- 
Andreas Henriksson
