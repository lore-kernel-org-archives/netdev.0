From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/9] tipc: resolve message disordering problem
Date: Thu,  5 Feb 2015 08:36:35 -0500
Message-ID: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.biz.mail.bf1.yahoo.com ([98.139.221.62]:46154 "EHLO
	smtp103.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752947AbbBENhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:37:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When TIPC receives messages from multi-threaded device drivers it may
occasionally deliver messages to their destination sockets in the wrong
order. This happens despite correct resequencing at the link layer,
because the upcall path from link to socket is not protected by any
locks.

These commits solve this problem by introducing an 'input' message
queue in each link, through which messages must be delivered to the
upper layers.


Jon Maloy (9):
  tipc: reduce usage of context info in socket and link
  tipc: simplify message forwarding and rejection in socket layer
  tipc: enqueue arrived buffers in socket in separate function
  tipc: split up function tipc_msg_eval()
  tipc: use existing sk_write_queue for outgoing packet chain
  tipc: resolve race problem at unicast message reception
  tipc: simplify connection abort notifications when links break
  tipc: simplify socket multicast reception
  tipc: eliminate race condition at multicast reception

 net/tipc/bcast.c      | 121 ++++++----------
 net/tipc/bcast.h      |  29 ++--
 net/tipc/discover.c   |   3 +-
 net/tipc/link.c       | 301 +++++++++++++++++----------------------
 net/tipc/link.h       |  14 +-
 net/tipc/msg.c        | 109 ++++++++------
 net/tipc/msg.h        | 107 ++++++++++++--
 net/tipc/name_distr.c |  38 +++--
 net/tipc/name_distr.h |   2 +-
 net/tipc/name_table.c |  44 +++++-
 net/tipc/name_table.h |  20 ++-
 net/tipc/node.c       | 103 +++++++-------
 net/tipc/node.h       |  22 ++-
 net/tipc/socket.c     | 382 +++++++++++++++++++++++++++++---------------------
 net/tipc/socket.h     |   8 +-
 15 files changed, 740 insertions(+), 563 deletions(-)

-- 
1.9.1
