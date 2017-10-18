From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v5 net-next 00/12] gtp: Additional feature support - Part I
Date: Wed, 18 Oct 2017 13:10:06 -0700
Message-ID: <20171018201018.5692-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:47467 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751465AbdJRUKy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 16:10:54 -0400
Received: by mail-pg0-f65.google.com with SMTP id r25so5161837pgn.4
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 13:10:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set builds upon the initial GTP implementation to make
support closer to that enjoyed by other encapsulation protocols.

The major items are:

  - Experimental IPv6 support
  - Configurable networking interfaces so that GTP kernel can be
    used and tested without needing GSN network emulation (i.e. no user
    space daemon needed).
  - Addition of a dst_cache in the GTP structure and other cleanup

Additionally, this patch set also includes:

  - Common functions to get a route fo for an IP tunnel

For IPv6 support, the mobile subscriber needs to allow IPv6 addresses,
and the remote endpoint can be IPv6.

For configurable interfaces, configuration is added to allow an
alternate means to configure a GTP and device. This follows the
typical UDP encapsulation model of specifying a listener port for
receive, and a remote address and port for transmit.

Configuration is performed by iproute2/ip. I will post that
in a subsequent patch set.

Tested:

Configured the matrix of IPv4/IPv6 mobile subscriber, IPv4/IPv6 remote
peer, and GTP version 0 and 1 (eight combinations). Observed
connectivity and functional netperf. Also, tested VXLAN for
regression.

Test using openggs with ggsn and kernel module on one side and
emulated sgsn on the other. Observed connectivity and
functional netperf.

v2:
  - Split the original patch to post in parts in order to make
    review more manageable
  - Make IPv6 support experimental with a configuration option for it
  - Prepend hash functions with gtp
  - Generalize iptunnel update path MTU function and call it from gtp
    instead using custom code
  - Split original patch cleaning up udp_recv into several for easier
    review

v3: Properly include netdev on cc

v4:
  - Move __ip6_tnl_get_route to ipv6/route.c to avoid creting dependency
    on ip6_tunnel
  - Add "select GRO_CELLS" fo Kconfig for GTP

v5:
  - Rebase to current next-net and repost


Tom Herbert (12):
  iptunnel: Add common functions to get a tunnel route
  vxlan: Call common functions to get tunnel routes
  gtp: Call common functions to get tunnel routes and add dst_cache
  iptunnel: Generalize tunnel update pmtu
  gtp: Change to use gro_cells
  gtp: Use goto for exceptions in gtp_udp_encap_recv funcs
  gtp: udp recv clean up
  gtp: Call function to update path mtu
  gtp: Eliminate pktinfo and add port configuration
  gtp: Experimental encapsulation of IPv6 packets
  gtp: Experimental support encpasulating over IPv6
  gtp: Allow configuring GTP interface as standalone

 drivers/net/Kconfig          |   13 +-
 drivers/net/gtp.c            | 1043 ++++++++++++++++++++++++++++++------------
 drivers/net/vxlan.c          |   84 +---
 include/net/ip6_tunnel.h     |   33 ++
 include/net/ip_tunnels.h     |   36 ++
 include/uapi/linux/gtp.h     |    8 +
 include/uapi/linux/if_link.h |    3 +
 net/ipv4/ip_tunnel.c         |   70 ++-
 net/ipv6/route.c             |   42 ++
 9 files changed, 945 insertions(+), 387 deletions(-)

-- 
2.11.0
