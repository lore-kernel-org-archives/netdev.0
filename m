From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v2 net-next 0/4] tunnels: fix incorrect IPv4/v6 headers interpretation
Date: Fri, 28 Aug 2015 20:48:18 +0200
Message-ID: <cover.1440787600.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>, Pravin Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40371 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751872AbbH1StX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2015 14:49:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With tunneling, it is currently possible to get an IPv6 header and interpret
it as an IPv4 header, or to interpret an IPv6 address as an IPv4 address
(and vice versa). This leads to things like sending packets to incorrect
address, IPv6 flow label being interpreted as IP packet length, etc.

Fix several places where this can happen.

Most of this is net-next only. The third patch affects net, too, but it
doesn't seem there's anything in user space that sets the attribute at all
currently, thus net-next is fine.

Changelog:
v2: fixed geneve after incorrect rebase on top of Pravin's patches

Jiri Benc (4):
  ip_tunnels: convert the mode field of ip_tunnel_info to flags
  ip_tunnels: record IP version in tunnel info
  fou: reject IPv6 config
  vxlan: do not receive IPv4 packets on IPv6 socket

 drivers/net/geneve.c       |  4 +++-
 drivers/net/vxlan.c        |  5 ++++-
 include/net/dst_metadata.h |  2 +-
 include/net/ip_tunnels.h   | 19 ++++++++++++-------
 include/net/udp_tunnel.h   |  3 ++-
 net/core/filter.c          |  2 ++
 net/ipv4/fou.c             |  2 +-
 net/ipv4/ip_gre.c          |  3 ++-
 net/ipv4/ip_tunnel_core.c  |  2 +-
 net/ipv4/route.c           |  2 +-
 net/ipv6/ip6_udp_tunnel.c  |  9 +++++++++
 net/ipv6/route.c           |  2 +-
 net/openvswitch/flow.c     |  2 ++
 net/openvswitch/vport.c    |  2 ++
 14 files changed, 43 insertions(+), 16 deletions(-)

-- 
1.8.3.1
