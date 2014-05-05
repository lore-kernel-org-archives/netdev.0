From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 00/10] purge signal handler infrastructure
Date: Mon, 5 May 2014 08:56:08 +0800
Message-ID: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59951 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754019AbaEEA4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:56:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we delay some actions to be executed in asynchronous contexts,
these usually add unnecessary code complexities, and make their
behaviours unpredictable and indeterministic. Moreover, as the signal
handler infrastructure is first stopped when tipc module is removed,
this may cause some potential risks for us. For instance, although
signal handler is already stopped, some tipc components still submit
signal requests to signal handler infrastructure, which may lead to
some resources not to be released or freed correctly.

So the series aims to convert all actions being performed in tasklet
context asynchronously with interface provided by signal handler
infrastructure to be executed synchronously, thereby deleting the
whole infrastructure of signal handler.

Ying Xue (10):
  tipc: always use tipc_node_lock() to hold node lock
  tipc: adjust order of variables in tipc_node structure
  tipc: rename setup_blocked variable of node struct to flags
  tipc: avoid to asynchronously notify subscriptions
  tipc: remove TIPC_NAMES_GONE node flag
  tipc: avoid to asynchronously deliver name tables to peer node
  tipc: define new functions to operate bc_lock
  tipc: convert allocations of global variables associated with bclink
  tipc: avoid to asynchronously reset all links
  tipc: purge signal handler infrastructure

 net/tipc/Makefile      |    2 +-
 net/tipc/bcast.c       |  145 +++++++++++++++++++++++++++++++-----------------
 net/tipc/bcast.h       |    4 +-
 net/tipc/config.c      |    6 +-
 net/tipc/core.c        |    7 ---
 net/tipc/core.h        |    6 +-
 net/tipc/handler.c     |  134 --------------------------------------------
 net/tipc/link.c        |   54 ++++++++----------
 net/tipc/link.h        |    1 +
 net/tipc/name_distr.c  |   58 ++-----------------
 net/tipc/name_distr.h  |   30 +++++++++-
 net/tipc/net.c         |    9 ++-
 net/tipc/net.h         |    2 +-
 net/tipc/node.c        |   59 +++++++++++++-------
 net/tipc/node.h        |   92 ++++++++++++++++++------------
 net/tipc/node_subscr.c |    9 ++-
 net/tipc/node_subscr.h |    2 +-
 17 files changed, 268 insertions(+), 352 deletions(-)
 delete mode 100644 net/tipc/handler.c

-- 
1.7.9.5
