From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] SCHED: Fix unnecesary driver entries when queue is stopped
Date: Tue, 13 Nov 2007 09:44:44 -0800
Message-ID: <20071113174444.27916.1892.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:15561 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761219AbXKNAmt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 19:42:49 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

This patch addresses an issue with multiqueue devices and non-multiqueue
qdiscs which is causing performance issues.  This patch should be 
considered for both 2.6.23-stable and 2.6.24 upstream.  Basically, if
a driver is using the netif_*_subqueue() calls, then qdisc_restart() will
happily call hard_start_xmit() even if subqueue 0 is stopped, which is bad.
This re-adds the check for the subqueue state.

Note that this check was removed when qdisc_restart() was rewritten.  At that
time though, we didn't understand the full effect of multiqueue with respect
to the qdiscs and queue management from a driver to kernel perspective.  Since
the driver doesn't know what qdisc capabilities live above it, it needs to
decide to use the queue or subqueue functions ahead of time.  This patch is
just cleaning up a miss from that rewrite.

Patch 1 is for 2.6.24, patch 2 is for 2.6.23 stable.

Thanks,
-- 
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
