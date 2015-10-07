From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 0/4 v2] net: VRF support in IPv6 stack
Date: Wed,  7 Oct 2015 15:02:13 -0700
Message-ID: <1444255337-36414-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34936 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637AbbJGWCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 18:02:23 -0400
Received: by pacfv12 with SMTP id fv12so33540228pac.2
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 15:02:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial support for VRF in IPv6 stack. Makes IPv6 functionality
on par with IPv4 -- ping, tcp client/server and udp client/server
all work fine. tcpdump on vrf device and external tap (e.g., host
side tap device) shows all packets with proper addresses. IPv6
does not need the source address operation like IPv4. Verified
vti6 works properly in my setup as does use of an IPv6 address
on the VRF device.

v2
- fixed CONFIG_IPV6 dependency as questioned by Cong
  - if IPV6 is a module, kbuild ensures VRF is a module
  - if IPV6 is disabled IPV6 functionality is compiled out of VRF module

- addressed comments from Nik over IRC
  - removed duplicate call to netif_is_l3_master in l3mdev_rt6_dst_by_oif
  - changed allocation flag from GFP_ATOMIC to GFP_KERNEL since it is init time
  - added free of rt6i_pcpu
  - check_ipv6_frame returns false only if packet is NDISC type

David Ahern (4):
  net: Add IPv6 support to l3mdev
  net: Export fib6_get_table and nd_tbl
  net: Add IPv6 support to VRF device
  net: Add VRF support to IPv6 stack

 drivers/net/Kconfig   |   4 +-
 drivers/net/vrf.c     | 279 +++++++++++++++++++++++++++++++++++++++++++++++++-
 include/net/l3mdev.h  |  46 +++++++++
 net/ipv6/addrconf.c   |  12 ++-
 net/ipv6/icmp.c       |   6 +-
 net/ipv6/ip6_fib.c    |   1 +
 net/ipv6/ip6_output.c |   6 +-
 net/ipv6/ndisc.c      |  27 ++++-
 net/ipv6/route.c      |  22 +++-
 9 files changed, 387 insertions(+), 16 deletions(-)

-- 
1.9.1
