From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/8] tipc: some cleanups and improvements
Date: Thu, 19 Nov 2015 14:30:38 -0500
Message-ID: <1447961447-13025-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:33619 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754787AbbKSTaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:30:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series mostly contains cleanups and cosmetic code changes.
The only real functional change is in #4 and #5, where we change the
locking structure for nodes and links in order to permit full
concurrency between links working in parallel on different interfaces.
Since the groundwork for this has been done in previous commit series,
this change constitutes only the final, small step to achieve that goal.

Jon Maloy (8):
  tipc: move linearization of buffers to generic code
  tipc: small cleanup of function tipc_node_check_state()
  tipc: reduce code dependency between binding table and node layer
  tipc: introduce per-link spinlock
  tipc: convert node lock to rwlock
  tipc: narrow down exposure of struct tipc_node
  tipc: narrow down interface towards struct tipc_link
  tipc: eliminate remnants of hungarian notation

 net/tipc/bcast.c          | 126 +------
 net/tipc/bcast.h          |   1 +
 net/tipc/bearer.c         | 140 ++++----
 net/tipc/bearer.h         |   8 +-
 net/tipc/core.h           |   5 +
 net/tipc/discover.c       |  38 +-
 net/tipc/link.c           | 626 ++++++++++++++++----------------
 net/tipc/link.h           | 175 +--------
 net/tipc/name_distr.c     |  68 +---
 net/tipc/name_distr.h     |   1 -
 net/tipc/name_table.c     |   5 +-
 net/tipc/netlink.c        |   8 +-
 net/tipc/netlink_compat.c |   8 +-
 net/tipc/node.c           | 884 ++++++++++++++++++++++++++++++++++++----------
 net/tipc/node.h           | 127 +------
 net/tipc/udp_media.c      |   5 -
 16 files changed, 1151 insertions(+), 1074 deletions(-)

-- 
1.9.1
