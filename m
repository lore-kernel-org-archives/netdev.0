From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net 0/2] ipv6: fix sticky pktinfo behaviour
Date: Wed, 27 Jan 2016 14:45:57 +0100
Message-ID: <cover.1453830778.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46766 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932469AbcA0Nqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 08:46:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently:

ip addr add dev eth0 2001:0010::1/64
ip addr add dev eth1 2001:0020::1/64
ping6 -I eth0 2001:0020::2

do not leads to the expected results, i.e. eth1 is used as the
egress interface.

This is due to two related issues in handling sticky pktinfo,
used by ping6 to enforce the device binding:

- ip6_dst_lookup_flow()/ip6_dst_lookup_tail() do not really enforce
flowi6_oif match
- ipv6 udp connect() just ignore flowi6_oif

These patches address each issue individually.

Paolo Abeni (2):
  ipv6: enforce flowi6_oif usage in ip6_dst_lookup_tail()
  ipv6/udp: use sticky pktinfo egress ifindex on connect()

 include/net/ip6_route.h |  2 ++
 net/ipv6/datagram.c     |  3 +++
 net/ipv6/ip6_output.c   |  6 +++++-
 net/ipv6/route.c        | 12 +++++++++---
 4 files changed, 19 insertions(+), 4 deletions(-)

-- 
1.8.3.1
