From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Bug Fix: Pass napi reference to the isr
	that services receive queue
Date: Wed, 01 Dec 2010 23:08:33 -0800
Message-ID: <20101202070833.4213.8072.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:33328 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581Ab0LBHId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 02:08:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Pass reference to napi instead of enic device to the isr that services receive queue.

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |    3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 7067254..a930fb9 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.4.1.7"
+#define DRV_VERSION		"1.4.1.8"
 #define DRV_COPYRIGHT		"Copyright 2008-2010 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 9f293fa..828a436 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1962,7 +1962,8 @@ static void enic_poll_controller(struct net_device *netdev)
 	case VNIC_DEV_INTR_MODE_MSIX:
 		for (i = 0; i < enic->rq_count; i++) {
 			intr = enic_msix_rq_intr(enic, i);
-			enic_isr_msix_rq(enic->msix_entry[intr].vector, enic);
+			enic_isr_msix_rq(enic->msix_entry[intr].vector,
+				&enic->napi[i]);
 		}
 		intr = enic_msix_wq_intr(enic, i);
 		enic_isr_msix_wq(enic->msix_entry[intr].vector, enic);

