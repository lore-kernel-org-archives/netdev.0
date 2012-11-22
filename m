From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 0/9] tipc: updates for what will be v3.8
Date: Thu, 22 Nov 2012 15:59:45 -0500
Message-ID: <1353617994-3962-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42957 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757564Ab2KVVAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 16:00:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The most interesting thing here, at least from a user perspective,
is the broadcast link fix -- where there was a corner case where
two endpoints could get in a state where they disagree on where
to start Rx and ack of broadcast packets.

There is also the poll/wait changes which could also impact
end users for certain use cases - the fixes there also better
align tipc with the rest of the networking code.

The rest largely falls into routine cleanup category, by getting
rid of some unused routines, some Kconfig clutter, etc.

Assuming there is nothing that jumps out as needing a rework,
the full set can be found as per below.

Thanks,
Paul.
---

The following changes since commit de4594a51c904ddcd6c3a6cdd100f7c1d94d3239:

  sctp: send abort chunk when max_retrans exceeded (2012-11-20 15:50:37 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc_net-next

for you to fetch changes up to 94fc9c4719f53264c7cce62ee558781fee7b7128:

  tipc: delete TIPC_ADVANCED Kconfig variable (2012-11-22 14:33:29 -0500)

----------------------------------------------------------------
Erik Hugne (1):
      tipc: return POLLOUT for sockets in an unconnected state

Jon Maloy (1):
      tipc: introduce message to synchronize broadcast link

Paul Gortmaker (1):
      tipc: delete TIPC_ADVANCED Kconfig variable

Ying Xue (6):
      tipc: fix race/inefficiencies in poll/wait behaviour
      tipc: wake up all waiting threads at socket shutdown
      tipc: remove the bearer congestion mechanism
      tipc: remove supportable flag from bclink structure
      tipc: rename supported flag to recv_permitted
      tipc: eliminate an unnecessary cast of node variable

 net/tipc/Kconfig      |  13 +---
 net/tipc/bcast.c      |  27 ++++----
 net/tipc/bearer.c     | 110 +++--------------------------
 net/tipc/bearer.h     |  24 +------
 net/tipc/core.c       |   5 --
 net/tipc/discover.c   |   2 +-
 net/tipc/link.c       | 188 ++++++++++++++++++++++++++------------------------
 net/tipc/link.h       |   4 --
 net/tipc/name_distr.c |   2 +-
 net/tipc/node.c       |  15 ++--
 net/tipc/node.h       |   6 +-
 net/tipc/socket.c     |  58 +++++++++++++---
 12 files changed, 185 insertions(+), 269 deletions(-)
