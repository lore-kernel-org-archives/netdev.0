From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 0/6] net: allow setting congctl via routing table
Date: Mon,  5 Jan 2015 23:57:42 +0100
Message-ID: <1420498668-4660-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: hannes@stressinduktion.org, fw@strlen.de, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36282 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754456AbbAEW6D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 17:58:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second part of our work and allows for setting the congestion
control algorithm via routing table. For details, please see individual
patches.

Since patch 1 is a bug fix, we suggest applying patch 1 to net, and then
merging net into net-next, for example, and following up with the remaining
feature patches wrt dependencies.

Joint work with Florian Westphal, suggested by Hannes Frederic Sowa.

Patch for iproute2 is available under [1], but will be reposted with along
with the man-page update when this set hits net-next.

  [1] http://patchwork.ozlabs.org/patch/418149/

Thanks!

v2 -> v3:
 - Added module auto-loading as suggested by David Miller, thanks!
  - Added patch 2 for handling possible sleeps in fib6
  - While working on this, we discovered a bug, hence fix in patch 1
  - Added auto-loading to patch 4
 - Rebased, retested, rest the same.
v1 -> v2:
 - Very sorry, I noticed I had decnet disabled during testing.
   Added missing header include in decnet, rest as is.

Daniel Borkmann (5):
  net: fib6: fib6_commit_metrics: fix potential NULL pointer dereference
  net: tcp: refactor reinitialization of congestion control
  net: tcp: add key management to congestion control
  net: tcp: add RTAX_CC_ALGO fib handling
  net: tcp: add per route congestion control

Florian Westphal (1):
  net: fib6: convert cfg metric to u32 outside of table write lock

 include/net/inet_connection_sock.h |   3 +-
 include/net/ip6_fib.h              |  10 ++-
 include/net/tcp.h                  |  22 ++++++-
 include/uapi/linux/rtnetlink.h     |   2 +
 net/core/rtnetlink.c               |  15 ++++-
 net/decnet/dn_fib.c                |   3 +-
 net/decnet/dn_table.c              |   4 +-
 net/ipv4/fib_semantics.c           |  14 ++++-
 net/ipv4/tcp_cong.c                | 121 +++++++++++++++++++++++++++++--------
 net/ipv4/tcp_ipv4.c                |   2 +
 net/ipv4/tcp_minisocks.c           |  30 +++++++--
 net/ipv4/tcp_output.c              |  21 +++++++
 net/ipv6/ip6_fib.c                 |  68 +++++++++++----------
 net/ipv6/route.c                   |  72 ++++++++++++++++++----
 net/ipv6/tcp_ipv6.c                |   2 +
 15 files changed, 304 insertions(+), 85 deletions(-)

-- 
1.7.11.7
