From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v3 0/6] tipc: refcount and memory leak fixes
Date: Thu, 6 Mar 2014 14:40:15 +0100
Message-ID: <1394113221-30100-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg20.ericsson.net ([193.180.251.50]:63600 "EHLO
	sessmg20.mgmt.ericsson.se" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751531AbaCFNjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 08:39:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

v3: Remove error logging from data path completely. Rebased on top of
    latest net merge.

v2: Drop specific -ENOMEM logging in patch #1 (tipc: allow connection
    shutdown callback to be invoked in advance) And add a general error
    message if an internal server tries to send a message on a
    closed/nonexisting connection.

In addition to the fix for refcount leak and memory leak during
module removal, we also fix a problem where the topology server
listening socket where unexpectedly closed. We also eliminate an
unnecessary context switch during accept()/recvmsg() for nonblocking
sockets.

It might be good to include this patchset in stable aswell. After the 
v3 rebase on latest merge from net all patches apply cleanly on that
tree.

Erik Hugne (3):
  tipc: drop subscriber connection id invalidation
  tipc: fix memory leak during module removal
  tipc: don't log disabled tasklet handler errors

Ying Xue (3):
  tipc: allow connection shutdown callback to be invoked in advance
  tipc: fix connection refcount leak
  tipc: avoid to unnecessary process switch under non-block mode

 net/tipc/config.c     |  9 ++-------
 net/tipc/handler.c    |  1 -
 net/tipc/name_table.c | 37 ++++++++++++++++++++++++++++++++++---
 net/tipc/server.c     | 14 +++++++-------
 net/tipc/socket.c     |  4 ++--
 net/tipc/subscr.c     | 19 ++-----------------
 6 files changed, 47 insertions(+), 37 deletions(-)

-- 
1.8.3.2
