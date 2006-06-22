From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 0/32] TIPC updates
Date: Thu, 22 Jun 2006 13:14:46 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, per.liden@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:228 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1161041AbWFVLOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 07:14:51 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's a resend of the latest TIPC updates. I apologize for not properly 
submitting the patches for review the first time around.

This patch set includes several minor bugfixes. Most of them ported over 
from an older TIPC 1.5.x branch maintained on sourceforge (that branch is 
being phased).

Patches can be pulled from:

	git://tipc.cslab.ericsson.net/pub/git/tipc.git

Summary:

 include/net/tipc/tipc_bearer.h |   12 ++
 net/tipc/bcast.c               |   79 ++++++++-------
 net/tipc/bcast.h               |    2 
 net/tipc/bearer.c              |   70 +++++++------
 net/tipc/cluster.c             |   22 ++--
 net/tipc/config.c              |   85 +++++++---------
 net/tipc/core.c                |    7 +
 net/tipc/core.h                |   21 +++-
 net/tipc/discover.c            |   13 +-
 net/tipc/eth_media.c           |   29 +++--
 net/tipc/link.c                |  217 +++++++++++++++++++++++++++++++---------
 net/tipc/name_distr.c          |   30 ++++--
 net/tipc/name_table.c          |  203 ++++++++++++++++++++-----------------
 net/tipc/node.c                |   78 ++++++++------
 net/tipc/node.h                |    2 
 net/tipc/node_subscr.c         |   15 +--
 net/tipc/port.c                |   41 ++++----
 net/tipc/ref.c                 |   31 +++++-
 net/tipc/socket.c              |  100 +++++++++++-------
 net/tipc/subscr.c              |   18 ++-
 net/tipc/zone.c                |   19 ++--
 21 files changed, 661 insertions(+), 433 deletions(-)

Allan Stephens:
      [TIPC] Prevent name table corruption if no room for new publication
      [TIPC] Use correct upper bound when validating network zone number.
      [TIPC] Corrected potential misuse of tipc_media_addr structure.
      [TIPC] Allow ports to receive multicast messages through native API.
      [TIPC] Links now validate destination node specified by incoming messages.
      [TIPC] Multicast link failure now resets all links to "nacking" node.
      [TIPC] Allow compilation when CONFIG_TIPC_DEBUG is not set.
      [TIPC] Fixed privilege checking typo in dest_name_check().
      [TIPC] Fix misleading comment in buf_discard() routine.
      [TIPC] Added support for MODULE_VERSION capability.
      [TIPC] Validate entire interface name when locating bearer to enable.
      [TIPC] Non-operation-affecting corrections to comments & function definitions.
      [TIPC] Fixed connect() to detect a dest address that is missing or too short.
      [TIPC] Implied connect now saves dest name for retrieval as ancillary data.
      [TIPC] Can now return destination name of form {0,x,y} via ancillary data.
      [TIPC] Connected send now checks socket state when retrying congested send.
      [TIPC] Stream socket send indicates partial success if data partially sent.
      [TIPC] Improved performance of error checking during socket creation.
      [TIPC] recvmsg() now returns TIPC ancillary data using correct level (SOL_TIPC)
      [TIPC] Simplify code for returning partial success of stream send request.
      [TIPC] Optimized argument validation done by connect().
      [TIPC] Withdrawing all names from nameless port now returns success, not error
      [TIPC] Added missing warning for out-of-memory condition
      [TIPC] Fixed memory leak in tipc_link_send() when destination is unreachable
      [TIPC] Disallow config operations that aren't supported in certain modes.
      [TIPC] First phase of assert() cleanup
      [TIPC] Enhanced & cleaned up system messages; fixed 2 obscure memory leaks.
      [TIPC] Fixed link switchover bugs
      [TIPC] Get rid of dynamically allocated arrays in broadcast code.
      [TIPC] Fix incorrect correction to discovery timer frequency computation.

Eric Sesterhenn:
      [TIPC] Fix for NULL pointer dereference

Jon Maloy:
      [TIPC] Improved tolerance to promiscuous mode interface

/Per
