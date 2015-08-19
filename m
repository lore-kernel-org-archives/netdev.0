From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v2 net-next 00/13] lwtunnel: per route ipv6 support for vxlan
Date: Wed, 19 Aug 2015 12:09:50 +0200
Message-ID: <cover.1439978875.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753053AbbHSKLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 06:11:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2: Fixed issues in patch 4 pointed out by Alexei.

This series enables IPv6 tunnels based on lwtunnel infrastructure. Only
vxlan is supported for now.

Tested in all combinations of IPv4 over IPv6, IPv6 over IPv4 and IPv6 over
IPv6.

Jiri Benc (13):
  ip_tunnels: remove custom alignment and packing
  ip_tunnels: use u8/u16/u32
  ip_tunnels: use offsetofend
  ip_tunnels: add IPv6 addresses to ip_tunnel_key
  ip_tunnels: use tos and ttl fields also for IPv6
  route: move lwtunnel state to dst_entry
  ipv6: drop metadata dst in ip6_route_input
  ipv6: ndisc: inherit metadata dst when creating ndisc requests
  vxlan: provide access function for vxlan socket address family
  vxlan: do not shadow flags variable
  vxlan: metadata based tunneling for IPv6
  ipv6: route: extend flow representation with tunnel key
  ipv6: route: per route IP tunnel metadata via lightweight tunnel

 drivers/net/vrf.c              |   1 -
 drivers/net/vxlan.c            |  89 +++++++++++++++++--------------
 include/net/dst.h              |   3 +-
 include/net/dst_metadata.h     |  15 ++----
 include/net/flow.h             |   1 +
 include/net/ip6_fib.h          |   1 -
 include/net/ip_tunnels.h       |  50 ++++++++++-------
 include/net/lwtunnel.h         |  12 -----
 include/net/ndisc.h            |   3 +-
 include/net/route.h            |   1 -
 include/net/vxlan.h            |   5 ++
 include/uapi/linux/lwtunnel.h  |  16 ++++++
 net/core/dst.c                 |   3 ++
 net/core/filter.c              |   6 +--
 net/core/lwtunnel.c            |  70 ++++--------------------
 net/ipv4/ip_gre.c              |  20 +++----
 net/ipv4/ip_tunnel_core.c      | 118 ++++++++++++++++++++++++++++++++++++++---
 net/ipv4/route.c               |  20 +++----
 net/ipv6/addrconf.c            |   2 +-
 net/ipv6/ila.c                 |  14 ++---
 net/ipv6/ip6_fib.c             |   1 -
 net/ipv6/ndisc.c               |  10 ++--
 net/ipv6/route.c               |  29 ++++++----
 net/mpls/mpls_iptunnel.c       |   7 +--
 net/openvswitch/flow_netlink.c |  28 +++++-----
 net/openvswitch/flow_table.c   |   2 +-
 net/openvswitch/vport-geneve.c |   4 +-
 net/openvswitch/vport-netdev.c |   2 +-
 net/openvswitch/vport.c        |   6 +--
 net/openvswitch/vport.h        |   6 +--
 30 files changed, 312 insertions(+), 233 deletions(-)

-- 
1.8.3.1
