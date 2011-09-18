From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/28] misc. TIPC updates for what will be 3.2
Date: Sat, 17 Sep 2011 23:31:56 -0400
Message-ID: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49958 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab1IRDcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another mixed bag of misc TIPC fixes and enhancements.  Some commits
here from Ying, who Al is working with to impart/share his TIPC
experience with -- we'll definitely be seeing more commits from Ying
on TIPC in the future.  Active TIPC users may have already met Ying
on the TIPC users [sourceforge] mailing list.  Thanks Ying!

The merge-base of these is roughly net-next of around when kernel.org
went down -- so I had to temporarily revert 0856a304091 (the use
after free scm pid thing) during validation since my 64bit test box
would simply die at boot.  But I see that same revert is now in.  Just
thought I'd mention it in case someone wondered how I tested when
0856a was preventing booting.  The self test was run between 32bit and
64bit boxes, each alternating between client and server respectively.

Thanks,
Paul.
---

The following changes since commit ab7e11d9d0293ef1802d6ae8aab39ce58472b167:

  greth: convert to SKB paged frag API. (2011-08-30 17:58:03 -0400)

are available in the git repository at:
  git://openlinux.windriver.com/people/paulg/net-next tipc-Sep17-2011

Allan Stephens (23):
  tipc: Remove obsolete manipulation of message re-route count field
  tipc: Eliminate obsolete filter for unexpected unicast messages
  tipc: Display meaningful peer interface name during link creation
  tipc: Initialize peer session field of newly created link endpoint
  tipc: Enhance filtering of out-dated link reset messages
  tipc: Update obsolete references to multicast link
  tipc: Cosmetic changes to broadcast bearer send routine
  tipc: Remove non-executable code to handle broadcast bearer congestion
  tipc: Enhance cleanup of broadcast link when contact with node is lost
  tipc: Prevent broadcast link stalling when another node fails
  tipc: Fix node lock problems during broadcast message reception
  tipc: Remove deferred queue head caching during broadcast message reception
  tipc: Discard incoming broadcast messages that are unexpected
  tipc: Remove obsolete congestion handling when sending a broadcast NACK
  tipc: Eliminate redundant check when sending messages
  tipc: Prevent rounding issues when saving connect timeout option
  tipc: Ensure congested links receive bearer status updates
  tipc: Ensure both nodes recognize loss of contact between them
  tipc: Fix unsafe device list search when enabling bearer
  tipc: Remove redundant search when enabling bearer
  tipc: Lower limits for number of bearers and media types
  tipc: Prevent fragmented messages during initial name table exchange
  tipc: Enhance sending of bulk name table messages

Paul Gortmaker (1):
  tipc: relocate/coalesce node cast in tipc_named_node_up

Ying Xue (4):
  tipc: Add support for SO_SNDTIMEO socket option
  tipc: Simplify prohibition of listen and accept for connectionless sockets
  tipc: Remove callback field from subscription structure
  tipc: Remove unused link event tracking code

 net/tipc/bcast.c      |  111 +++++++++++++++++++++++--------------------------
 net/tipc/bcast.h      |    1 -
 net/tipc/bearer.c     |    8 +--
 net/tipc/bearer.h     |    4 +-
 net/tipc/config.h     |    1 -
 net/tipc/discover.c   |    6 ---
 net/tipc/eth_media.c  |   32 ++++++--------
 net/tipc/link.c       |  111 +++++++++++++++++++++++++++++++++++--------------
 net/tipc/link.h       |    1 +
 net/tipc/name_distr.c |   35 +++++++++++++---
 net/tipc/net.c        |   11 -----
 net/tipc/node.c       |   45 +++++++++++---------
 net/tipc/node.h       |   10 ++++-
 net/tipc/socket.c     |   51 +++++++++++------------
 net/tipc/subscr.c     |    3 +-
 net/tipc/subscr.h     |    6 ---
 16 files changed, 239 insertions(+), 197 deletions(-)

-- 
1.7.4.4
