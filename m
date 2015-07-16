From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 00/13] tipc: separate link and link aggregation layer
Date: Thu, 16 Jul 2015 16:54:18 -0400
Message-ID: <1437080071-6686-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.biz.mail.bf1.yahoo.com ([98.139.221.61]:39199 "EHLO
	smtp102.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751340AbbGPUyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 16:54:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first batch of a longer series that has two main objectives:

o Finer lock granularity during message sending and reception,
  especially regarding usage of the node spinlock.

o Better separation between the link layer implementation and the link
  aggregation layer, represented by node.c::struct tipc_node.

Hopefully these changes also make this part of code somewhat easier
to comprehend and maintain.


Jon Maloy (13):
  tipc: introduce link entry structure to struct tipc_node
  tipc: move link creation from neighbor discoverer to node
  tipc: move link input queue to tipc_node
  tipc: use bearer index when looking up active links
  tipc: change sk_buffer handling in tipc_link_xmit()
  tipc: make media xmit call outside node spinlock context
  tipc: clean up definitions and usage of link flags
  tipc: introduce new link protocol msg create function
  tipc: improve link FSM implementation
  tipc: simplify link timer implementation
  tipc: move link supervision timer to node level
  tipc: introduce node contact FSM
  tipc: reduce locking scope during packet reception

 net/tipc/bcast.c      |   31 +-
 net/tipc/bcast.h      |    1 +
 net/tipc/bearer.c     |   26 +
 net/tipc/bearer.h     |    3 +
 net/tipc/core.h       |    5 +
 net/tipc/discover.c   |   20 +-
 net/tipc/link.c       | 1517 ++++++++++++++++++++++++-------------------------
 net/tipc/link.h       |   74 +--
 net/tipc/msg.h        |   53 +-
 net/tipc/name_distr.c |    6 +-
 net/tipc/node.c       |  549 ++++++++++++++----
 net/tipc/node.h       |   93 ++-
 net/tipc/socket.c     |   71 +--
 13 files changed, 1431 insertions(+), 1018 deletions(-)

-- 
1.9.1
