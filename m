From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 0/4] net: allow setting congctl via routing table
Date: Sun,  7 Dec 2014 00:39:19 +0100
Message-ID: <1417909163-19135-1-git-send-email-dborkman@redhat.com>
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005AbaLFXje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 18:39:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second part of our work and allows for setting the congestion
control algorithm via routing table. For details, please see individual
patches.

Joint work with Florian Westphal, suggested by Hannes Frederic Sowa.

Patch for iproute2: http://patchwork.ozlabs.org/patch/418149/

Thanks!

v1->v2:
 - Very sorry, I noticed I had decnet disabled during testing.
   Added missing header include in decnet, rest as is.

Daniel Borkmann (4):
  net: tcp: refactor reinitialization of congestion control
  net: tcp: add key management to congestion control
  net: tcp: add RTAX_CC_ALGO fib handling
  net: tcp: add per route congestion control

 include/net/inet_connection_sock.h |  3 +-
 include/net/tcp.h                  | 22 +++++++++-
 include/uapi/linux/rtnetlink.h     |  2 +
 net/core/rtnetlink.c               | 15 ++++++-
 net/decnet/dn_fib.c                |  3 +-
 net/decnet/dn_table.c              |  4 +-
 net/ipv4/fib_semantics.c           | 14 +++++-
 net/ipv4/tcp_cong.c                | 87 ++++++++++++++++++++++++++++++++------
 net/ipv4/tcp_ipv4.c                |  2 +
 net/ipv4/tcp_minisocks.c           | 30 +++++++++++--
 net/ipv4/tcp_output.c              | 21 +++++++++
 net/ipv6/ip6_fib.c                 | 15 ++++++-
 net/ipv6/route.c                   |  3 +-
 net/ipv6/tcp_ipv6.c                |  2 +
 14 files changed, 197 insertions(+), 26 deletions(-)

-- 
1.7.11.7
