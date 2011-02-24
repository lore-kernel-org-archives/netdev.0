From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/17] TIPC: Another mixed bag of cleanups and bugfixes
Date: Wed, 23 Feb 2011 20:26:28 -0500
Message-ID: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34434 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659Ab1BXB06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:26:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are still seeing some rewards from dumping the native API stuff,
things like the top two struct amalgamation commits are a direct
result of that.  The rest is just a mixed bag of largely unrelated
small bugfixes and other cleanups as summarized below.

Paul.

--------


The following changes since commit dee9f4bceb5fd9dbfcc1567148fccdbf16d6a38a:

  net: Make flow cache paths use a const struct flowi. (2011-02-22 18:44:31 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/net-next-2.6.git tipc-Feb23-2011

Allan Stephens (17):
      tipc: Combine port structure with tipc_port structure
      tipc: Combine bearer structure with tipc_bearer structure
      tipc: Remove unused global variable tipc_user_count
      tipc: Prevent invalid memory access when sending to configuration service
      tipc: Improve handling of invalid link tolerance values
      tipc: Fix print statements that assume pointers are 32-bit values
      tipc: Clean out all remaining instances of #if 0'd unused code
      tipc: Clean up tracking of node requesting a broadcast retransmit
      tipc: Eliminate unnecessary locking when starting topology service
      tipc: Improve accuracy of link transmit queue maximum size statistic
      tipc: Set unused probe field of link protocol messages to defined value
      tipc: Minor optimization to topology service connection establishment
      tipc: Fix port counter handling to correct congestion control
      tipc: Add in missing lock during link initialization
      tipc: Remove support for per-connection message sequence numbering
      tipc: Remove unused message header field for requested number of links
      tipc: Avoid reliable broadcast preparation for NACK messages

 include/linux/tipc.h        |    8 +-
 include/linux/tipc_config.h |   32 +----
 net/tipc/bcast.c            |   47 ++++---
 net/tipc/bcast.h            |    3 +-
 net/tipc/bearer.c           |  100 +++++++-------
 net/tipc/bearer.h           |   67 +++++-----
 net/tipc/core.c             |    3 +-
 net/tipc/core.h             |    3 +-
 net/tipc/discover.c         |   37 +++---
 net/tipc/discover.h         |    9 +-
 net/tipc/link.c             |   82 ++++++------
 net/tipc/link.h             |   28 ++---
 net/tipc/msg.c              |    7 +-
 net/tipc/msg.h              |   22 +---
 net/tipc/node.c             |    4 +-
 net/tipc/port.c             |  306 +++++++++++++++++++++----------------------
 net/tipc/port.h             |   73 +++++------
 net/tipc/socket.c           |    6 +-
 net/tipc/subscr.c           |   13 +--
 19 files changed, 381 insertions(+), 469 deletions(-)
