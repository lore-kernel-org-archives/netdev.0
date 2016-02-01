From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 00/10] tipc: cleanups, fixes & improvements for topology server
Date: Mon, 1 Feb 2016 10:44:33 +0100
Message-ID: <1454319883-16031-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:44521 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbcBAJou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 04:44:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains topology server cleanups, fixes and improvements.

Cleanups in #1-#4:
We remove duplicate data structures and aligin the rest of the code accordingly.

Fixes in #5-#8:
The bugs occur either during configuration or while running on SMP targets,
which are race conditions that pop up under different situations.

Improvements in #9-#10:
Updates to decrease timer usage and improve readability.

Parthasarathy Bhuvaragan (10):
  tipc: remove incorrect check for subscription timeout value
  tipc: remove filter and timeout elements from struct tipc_subscription
  tipc: remove struct tipc_name_seq from struct tipc_subscription
  tipc: introduce tipc_subscrb_subscribe() routine
  tipc: fix connection abort during subscription cancellation
  tipc: fix connection abort when receiving invalid cancel request
  tipc: hold subscriber->lock for tipc_nametbl_subscribe()
  tipc: protect tipc_subscrb_get() with subscriber spin lock
  tipc: donot create timers if subscription timeout = TIPC_WAIT_FOREVER
  tipc: use alloc_ordered_workqueue() instead of WQ_UNBOUND w/
    max_active = 1

 net/tipc/name_table.c |  14 ++++--
 net/tipc/server.c     |   4 +-
 net/tipc/subscr.c     | 131 ++++++++++++++++++++++++++++++--------------------
 net/tipc/subscr.h     |  11 ++---
 4 files changed, 96 insertions(+), 64 deletions(-)

-- 
2.1.4
