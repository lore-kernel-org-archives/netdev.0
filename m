From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/26] tipc: Yet another mixed bag of updates
Date: Sun, 13 Mar 2011 17:33:48 -0400
Message-ID: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49841 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754920Ab1CMVe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Content varies, from cleanups to bugfixes to removals of orphaned code.

In the new functionality department, there is the SO_RCVTIMEO sockopt
and the multi-chunk iovec changes that simply were not supported before.

In the removal dep't there were a couple more blocks relating to the
now-gone prototype routing that can also now be deleted.

Nobody likes Kconfig options for micro tuning anymore, so one of those
gets shot in the head, which triggered a bunch of associated cleanups,
like the killing off of a largely useless global structure.

The remainder are either bugfixes or cosmetic cleanups initiated by
the bugfix; with the usual intent of not mixing both types of content
within a single commit, so that review/inspection is hopefully easier.

Thanks,
Paul.

---

The following changes since commit bef55aebd560c5a6f8883c421abccee39978c58c:

  decnet: Convert to use flowidn where applicable. (2011-03-12 15:08:55 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/net-next-2.6.git tipc-Mar13-2011


Allan Stephens (25):
  tipc: Allow receiving into iovec containing multiple entries
  tipc: Correct broadcast link peer info when displaying links
  tipc: Add network address mask helper routines
  tipc: Prevent null pointer error when removing a node subscription
  tipc: Cosmetic changes to node subscription code
  tipc: Add support for SO_RCVTIMEO socket option
  tipc: Fix problem with missing link in "tipc-config -l" output
  tipc: Split up unified structure of network-related variables
  tipc: Eliminate configuration for maximum number of cluster nodes
  tipc: Convert node object array to a hash table
  tipc: manually inline net_start/stop, make assoc. vars static
  tipc: Eliminate timestamp from link protocol messages
  tipc: make msg_set_redundant_link() consistent with other set ops
  tipc: Fix redundant link field handling in link protocol message
  tipc: Cosmetic changes to neighbor discovery logic
  tipc: Give Tx of discovery responses priority over link messages
  tipc: Optimizations to link creation code
  tipc: Correct misnamed references to neighbor discovery domain
  tipc: Remove unused field in bearer structure
  tipc: Eliminate unnecessary constant for neighbor discovery msg size
  tipc: Don't respond to neighbor discovery request on blocked bearer
  tipc: Remove bearer flag indicating existence of broadcast address
  tipc: Eliminate remaining support for routing table messages
  tipc: Eliminate obsolete routine for handling routed messages
  tipc: Update maintenance information

Paul Gortmaker (1):
  tipc: cosmetic - function names are not to be full sentences

 MAINTAINERS                 |    6 +--
 include/linux/tipc_config.h |    6 +-
 net/tipc/Kconfig            |   12 ----
 net/tipc/addr.c             |   15 ++----
 net/tipc/addr.h             |   17 +++++--
 net/tipc/bearer.c           |   18 +++----
 net/tipc/bearer.h           |    6 +--
 net/tipc/config.c           |   31 ++---------
 net/tipc/core.c             |    6 --
 net/tipc/core.h             |    1 -
 net/tipc/discover.c         |  103 +++++++++++++++++++++---------------
 net/tipc/link.c             |   50 ++++++++++-------
 net/tipc/link.h             |    3 +-
 net/tipc/msg.c              |   34 ------------
 net/tipc/msg.h              |   42 +--------------
 net/tipc/name_distr.c       |   18 +++---
 net/tipc/net.c              |   32 ++---------
 net/tipc/net.h              |   19 +------
 net/tipc/node.c             |  123 ++++++++++++++++++++-----------------------
 net/tipc/node.h             |   36 ++++++++-----
 net/tipc/node_subscr.c      |   21 +++++++-
 net/tipc/node_subscr.h      |    3 +-
 net/tipc/socket.c           |   70 +++++++++++-------------
 23 files changed, 278 insertions(+), 394 deletions(-)

-- 
1.7.3.3

