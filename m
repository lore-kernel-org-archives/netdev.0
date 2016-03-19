From: Jesse Gross <jesse@kernel.org>
Subject: [PATCH net v2 0/3] Tunneling fixes
Date: Sat, 19 Mar 2016 09:31:59 -0700
Message-ID: <1458405122-12565-1-git-send-email-jesse@kernel.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:55626 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754586AbcCSQcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2016 12:32:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes a problem that was reported where encapsulated packets
do not have their encapsulation offload markers stripped off when being
decapsulated. This causes a significant performance drop if the packets
are later retransmitted.

Fixing this revealed two other bugs which are also addressed as prerequisites:
 * GRO can aggregate packets for multiple layers of encapsulation which the
   stack cannot properly handle.
 * IPIP packets which are combined by GRO are not marked properly with their
   GSO type.

Note that this is based off the net-next tree as the current target for
bug fixes.

v2: No code changes, just additional information in commit messages and
    a new cover letter.

Jesse Gross (3):
  ipip: Properly mark ipip GRO packets as encapsulated.
  tunnels: Don't apply GRO to multiple layers of encapsulation.
  tunnels: Remove encapsulation offloads on decap.

 include/linux/netdevice.h |  4 ++--
 include/net/ip_tunnels.h  | 16 ++++++++++++++++
 net/core/dev.c            |  2 +-
 net/ipv4/af_inet.c        | 24 ++++++++++++++++++++++--
 net/ipv4/fou.c            | 13 +++++++++++--
 net/ipv4/gre_offload.c    |  5 +++++
 net/ipv4/ip_tunnel_core.c |  3 ++-
 net/ipv4/udp_offload.c    |  6 +++---
 net/ipv6/ip6_offload.c    | 15 ++++++++++++++-
 net/ipv6/sit.c            |  6 ++++--
 10 files changed, 80 insertions(+), 14 deletions(-)

-- 
2.5.0
