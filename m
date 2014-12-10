From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [REGRESSION] iproute: change to if_bridge.h breaks build
Date: Tue, 9 Dec 2014 16:43:12 -0800
Message-ID: <20141209164312.6423b215@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Gregory Fong <gregory.0xf0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:47859 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318AbaLJAnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 19:43:21 -0500
Received: by mail-pa0-f44.google.com with SMTP id et14so1639129pad.17
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 16:43:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit causes build problems in iproute.

I can fix it for iproute, by reordering the headers
but on the principle that updates should never break
builds of existing code, this is wrong.


gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declarations -Wold-style-definition -Wformat=2 -O2 -I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE -DHAVE_SETNS   -c -o iplink_bridge_slave.o iplink_bridge_slave.c
In file included from ../include/linux/if_bridge.h:18:0,
                 from iplink_bridge_slave.c:16:
../include/linux/in6.h:169:0: warning: "IPV6_ADD_MEMBERSHIP" redefined
 #define IPV6_ADD_MEMBERSHIP 20
 ^
In file included from /usr/include/netinet/in.h:37:0,
                 from iplink_bridge_slave.c:14:
commit 66f1c44887ba4f47d617f8ae21cf8e04e1892bd7
Author: Gregory Fong <gregory.0xf0@gmail.com>
Date:   Tue Nov 4 11:21:21 2014 -0800

    bridge: include in6.h in if_bridge.h for struct in6_addr
    
    if_bridge.h uses struct in6_addr ip6, but wasn't including the in6.h
    header.  Thomas Backlund originally sent a patch to do this, but this
    revealed a redefinition issue: https://lkml.org/lkml/2013/1/13/116
    
    The redefinition issue should have been fixed by the following Linux
    commits:
    ee262ad827f89e2dc7851ec2986953b5b125c6bc inet: defines IPPROTO_* needed for module alias generation
    cfd280c91253cc28e4919e349fa7a813b63e71e8 net: sync some IP headers with glibc
    
    and the following glibc commit:
    6c82a2f8d7c8e21e39237225c819f182ae438db3 Coordinate IPv6 definitions for Linux and glibc
    
    so actually include the header now.
    
    Reported-by: Colin Guthrie <colin@mageia.org>
    Reported-by: Christiaan Welvaart <cjw@daneel.dyndns.org>
    Reported-by: Thomas Backlund <tmb@mageia.org>
    Cc: Florian Fainelli <f.fainelli@gmail.com>
    Cc: Cong Wang <xiyou.wangcong@gmail.com>
    Cc: David Miller <davem@davemloft.net>
    Signed-off-by: Gregory Fong <gregory.0xf0@gmail.com>
    Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
