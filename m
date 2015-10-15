From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/7] tipc: some link level code improvements
Date: Thu, 15 Oct 2015 14:52:39 -0400
Message-ID: <1444935166-12745-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.biz.mail.bf1.yahoo.com ([98.139.244.55]:46799 "EHLO
	smtp107.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751329AbbJOSww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 14:52:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extensive testing has revealed some weaknesses and non-optimal solutions
in the link level code.

This commit series addresses those issues.


Jon Maloy (7):
  tipc: limit usage of temporary skb list during packet reception
  tipc: simplify tipc_link_rcv() reception loop
  tipc: improve sequence number checking
  tipc: disallow packet duplicates in link deferred queue
  tipc: delay ESTABLISH state event when link is established
  tipc: send out RESET immediately when link goes down
  tipc: update node FSM when peer RESET message is received

 net/tipc/bearer.c    |   8 +--
 net/tipc/link.c      | 170 ++++++++++++++++++++++++++++++---------------------
 net/tipc/link.h      |   5 +-
 net/tipc/msg.c       |  31 ++++++++++
 net/tipc/msg.h       |  34 +----------
 net/tipc/node.c      |  43 +++++++++----
 net/tipc/udp_media.c |   1 -
 7 files changed, 172 insertions(+), 120 deletions(-)

-- 
1.9.1
