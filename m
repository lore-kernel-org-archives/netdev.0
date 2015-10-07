From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/4] net: VRF support in IPv6 stack
Date: Wed,  7 Oct 2015 09:50:36 -0700
Message-ID: <1444236640-2410-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32970 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755019AbbJGQur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 12:50:47 -0400
Received: by pacex6 with SMTP id ex6so26387089pac.0
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 09:50:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial support for VRF in IPv6 stack. Makes IPv6 functionality
on par with IPv4 -- ping, tcp client/server and udp client/server
all work fine. tcpdump on vrf device and external tap (e.g., host
side tap device) shows all packets with proper addresses. IPv6
does not need the source address operation like IPv4. Verified
vti6 works properly in my setup as does use of an IPv6 address
on the VRF device.

David Ahern (4):
  net: Add IPv6 support to l3mdev
  net: Export fib6_get_table and nd_tbl
  net: Add IPv6 support to VRF device
  net: Add VRF support to IPv6 stack

 drivers/net/Kconfig   |   1 +
 drivers/net/vrf.c     | 254 +++++++++++++++++++++++++++++++++++++++++++++++++-
 include/net/l3mdev.h  |  47 ++++++++++
 net/ipv6/addrconf.c   |  12 ++-
 net/ipv6/icmp.c       |   6 +-
 net/ipv6/ip6_fib.c    |   1 +
 net/ipv6/ip6_output.c |   6 +-
 net/ipv6/ndisc.c      |  27 +++++-
 net/ipv6/route.c      |  22 ++++-
 9 files changed, 361 insertions(+), 15 deletions(-)

-- 
1.9.1
