From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 0/6] tipc: refcount and memory leak fixes
Date: Wed, 5 Mar 2014 08:56:12 +0100
Message-ID: <1394006178-23966-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:54930 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381AbaCEHzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 02:55:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

v2: Drop specific -ENOMEM logging in patch #1 (tipc: allow connection
    shutdown callback to be invoked in advance) And add a general error
    message if an internal server tries to send a message on a
    closed/nonexisting connection.

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

 net/tipc/config.c     |  9 ++-------
 net/tipc/handler.c    |  1 -
 net/tipc/name_table.c | 37 ++++++++++++++++++++++++++++++++++---
 net/tipc/server.c     | 19 +++++++++++--------
 net/tipc/socket.c     |  4 ++--
 net/tipc/subscr.c     | 19 ++-----------------
 6 files changed, 51 insertions(+), 38 deletions(-)

-- 
1.8.3.2
