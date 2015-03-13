From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 0/7] tipc: some optimizations and impovements
Date: Fri, 13 Mar 2015 16:08:04 -0400
Message-ID: <1426277291-2427-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.biz.mail.bf1.yahoo.com ([98.139.221.62]:44794 "EHLO
	smtp103.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751168AbbCMUIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 16:08:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commits in this series contain some relatively simple changes that
lead to better throughput across TIPC connections. We also make changes
to the implementation of link transmission queueing and priority
handling, in order to make the code more comprehensible and maintainable.

v2: Commit #2: Redesigned tipc_msg_validate() to use pskb_may_pull(),
               as per feedback from David Miller.
    Commit #3: Some cosmetic changes to tipc_msg_extract(). I tried to
               replace the unconditional skb_linearize() with calls to
               pskb_may_pull() at selected locations, but I gave up.
               First, skb_trim() requires a fully linearized buffer.
               Second, it doesn't make much sense; the whole buffer
               will end up linearized, one way or another.

Jon Maloy (7):
  tipc: add framework for node capabilities exchange
  tipc: move message validation function to msg.c
  tipc: eliminate unnecessary linearization of incoming buffers
  tipc: extract bundled buffers by cloning instead of copying
  tipc: eliminate unnecessary call to broadcast ack function
  tipc: split link outqueue
  tipc: clean up handling of message priorities

 net/tipc/bcast.c    |  53 ++++----
 net/tipc/discover.c |   3 +
 net/tipc/link.c     | 352 +++++++++++++++++++---------------------------------
 net/tipc/link.h     |  17 ++-
 net/tipc/msg.c      | 119 ++++++++++++------
 net/tipc/msg.h      |  87 +++++++------
 net/tipc/node.c     |   4 +-
 net/tipc/node.h     |   6 +-
 8 files changed, 300 insertions(+), 341 deletions(-)

-- 
1.9.1
