From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/16] tipc: publication lists and zero node handling
Date: Fri, 20 Apr 2012 17:05:08 -0400
Message-ID: <1334955924-907-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62184 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab2DTVF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:05:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series of commits largely focuses on two things.  The 1st is
to categorize the TIPC publication lists, so better control over
the publications can be achieved.  The 2nd is largely to improve
corner cases around the tipc address changes and how the <0.0.0>
tipc address is interpreted.

What remains after this, is less than 10 commits originating from
what was salvaged from the tipc-1.7 sourceforge fork, so I'm happy to
see the end of this task so close.  I'll be looking at those shortly.

The tipc tests (tipcTS <--> tipcTC) have been used in both directions
between a 32bit and a 64bit machine to do runtime testing, and the
entire series has been confirmed to be compile time bisectable too.

Credit to Al for all the heavy lifting.  I've just refactored things
a bit and made minor changes here and there.

Thanks,
Paul
---

The following changes since commit 798ec84d45754403571d6387396236e877965c5a:

  net/core:Remove memleak reports by kmemleak_not_leak. (2012-04-18 00:20:28 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc_net-next

for you to fetch changes up to 9d52ce4bd3fa9e0cf1658791f2c680e20e0598a1:

  tipc: Ensure network address change doesn't impact configuration service (2012-04-19 15:46:50 -0400)

----------------------------------------------------------------

Allan Stephens (16):
  tipc: introduce publication lists struct
  tipc: Factor out name publication code to a separate function
  tipc: Separate cluster-scope and zone-scope names into distinct lists
  tipc: Update node-scope publications when network address is assigned
  tipc: Don't record failed publication attempt as a success
  tipc: Add routines for safe checking of node's network address
  tipc: Ensure network address change doesn't impact name table updates
  tipc: Optimize re-initialization of port message header templates
  tipc: Ensure network address change doesn't impact new port
  tipc: delete duplicate peerport/peernode helper functions
  tipc: Ensure network address change doesn't impact local connections
  tipc: take lock while updating node network address
  tipc: properly handle off-node send requests with invalid addr
  tipc: handle <0.0.0> as an alias for this node on outgoing msgs
  tipc: Ensure network address change doesn't impact rejected message
  tipc: Ensure network address change doesn't impact configuration
    service

 net/tipc/addr.h        |   20 +++++++-
 net/tipc/bearer.c      |    2 +-
 net/tipc/config.c      |    2 +-
 net/tipc/name_distr.c  |  119 ++++++++++++++++++++++++++++++++----------------
 net/tipc/name_table.c  |   14 +++---
 net/tipc/net.c         |    3 +-
 net/tipc/node.c        |    2 +-
 net/tipc/node_subscr.c |    2 +-
 net/tipc/port.c        |  101 ++++++++++++++++++++++------------------
 net/tipc/port.h        |   11 +----
 net/tipc/socket.c      |    3 +-
 11 files changed, 172 insertions(+), 107 deletions(-)

-- 
1.7.9.3
