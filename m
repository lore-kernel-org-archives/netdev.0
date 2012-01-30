From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V3] Xen netback / netfront improvement
Date: Mon, 30 Jan 2012 14:45:18 +0000
Message-ID: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ian.campbell@citrix.com, konrad.wilk@oracle.com
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:63150 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab2A3Opd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:45:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since this series includes both netback and netfront changes, the
whole series is named as "Xen netback / netfront improvement".

Changes in V3:
 - Rework of per-cpu scratch space
 - Multi page ring support
 - Split event channels
 - Rx protocol stub
 - Fix a minor bug in module_put path

Changes in V2:
 - Fix minor bugs in V1
 - Embed pending_tx_info into page pool
 - Per-cpu scratch space
 - Notification code path clean up

This version has been tested by 
Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

V1:
A new netback implementation which includes three major features:

 - Global page pool support
 - NAPI + kthread 1:1 model
 - Netback internal name changes

This patch series is the foundation of furture work. So it is better
to get it right first. Patch 1 and 3 have the real meat.

The first benifit of 1:1 model will be scheduling fairness.

The rational behind a global page pool is that we need to limit
overall memory consumed by all vifs.

Utilization of NAPI enables the possibility to mitigate
interrupts/events, the code path is cleaned up in a separated patch.

Netback internal changes cleans up the code structure after switching
to 1:1 model. It also prepares netback for further code layout
changes.

----
 drivers/net/xen-netback/Makefile              |    2 +-
 drivers/net/xen-netback/common.h              |  149 ++-
 drivers/net/xen-netback/interface.c           |  256 ++++--
 drivers/net/xen-netback/netback.c             | 1344 +++++++------------------
 drivers/net/xen-netback/page_pool.c           |  185 ++++
 drivers/net/xen-netback/page_pool.h           |   66 ++
 drivers/net/xen-netback/xenbus.c              |  185 ++++-
 drivers/net/xen-netback/xenvif_rx_protocol0.c |  616 +++++++++++
 drivers/net/xen-netback/xenvif_rx_protocol0.h |   53 +
 drivers/net/xen-netfront.c                    |  399 ++++++--
 10 files changed, 2062 insertions(+), 1193 deletions(-)
