From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 0/6] tipc: refcount and memory leak fixes
Date: Tue, 4 Mar 2014 09:05:37 +0100
Message-ID: <1393920343-4134-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:46744 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195AbaCDIFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 03:05:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

In addition to the fix for refcount leak and memory leak during
module removal, we also fix a problem where the topology server
listening socket where unexpectedly closed. We also eliminate an
unnecessary context switch during accept()/recvmsg() for nonblocking
sockets.

The following should be applied on stable aswell:
tipc: allow connection shutdown callback to be invoked in advance
tipc: fix connection refcount leak
tipc: drop subscriber connection id invalidation

We'd also like to have the fixes for memleak during module removal
in stable aswell, but unfortunately they won't apply cleanly on the
net tree:
tipc: fix memory leak during module removal
tipc: don't log disabled tasklet handler errors

Erik Hugne (3):
  tipc: drop subscriber connection id invalidation
  tipc: fix memory leak during module removal
  tipc: don't log disabled tasklet handler errors

Ying Xue (3):
  tipc: allow connection shutdown callback to be invoked in advance
  tipc: fix connection refcount leak
  tipc: avoid to unnecessary process switch under non-block mode

 net/tipc/config.c     |  2 +-
 net/tipc/handler.c    |  1 -
 net/tipc/name_table.c | 37 ++++++++++++++++++++++++++++++++++---
 net/tipc/server.c     | 14 +++++++-------
 net/tipc/socket.c     |  4 ++--
 net/tipc/subscr.c     | 13 +------------
 6 files changed, 45 insertions(+), 26 deletions(-)

-- 
1.8.3.2
