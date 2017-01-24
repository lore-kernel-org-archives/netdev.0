From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 0/6] topology server fixes for nametable soft lockup
Date: Tue, 24 Jan 2017 13:00:42 +0100
Message-ID: <1485259248-21812-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:46098 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750773AbdAXMBu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 07:01:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this series, we revert the commit 333f796235a527 ("tipc: fix a
race condition leading to subscriber refcnt bug") and provide an
alternate solution to fix the race conditions in commits 2-4.

We have to do this as the above commit introduced a nametbl soft
lockup at module exit as described by patch#4.

Parthasarathy Bhuvaragan (6):
  tipc: fix nametbl_lock soft lockup at node/link events
  tipc: add subscription refcount to avoid invalid delete
  tipc: fix connection refcount error
  tipc: fix nametbl_lock soft lockup at module exit
  tipc: ignore requests when the connection state is not CONNECTED
  tipc: fix cleanup at module unload

 net/tipc/node.c   |   9 +++-
 net/tipc/server.c |  48 +++++++++------------
 net/tipc/subscr.c | 124 ++++++++++++++++++++++++++++++------------------------
 net/tipc/subscr.h |   1 +
 4 files changed, 99 insertions(+), 83 deletions(-)

-- 
2.1.4
