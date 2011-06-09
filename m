From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 4/4] enic: Bug Fix: Fix hardware transmit queue
	indexing in enic_poll_controller
Date: Thu, 09 Jun 2011 13:37:07 -0700
Message-ID: <20110609203707.31838.84936.stgit@savbu-pc100.cisco.com>
References: <20110609203620.31838.61879.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:39019 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab1FIUhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 16:37:19 -0400
In-Reply-To: <20110609203620.31838.61879.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>



Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Danny Guo <dannguo@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |    8 ++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 2dcf310..f747bce 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.19"
+#define DRV_VERSION		"2.1.1.20"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index eee2526..4c5546d 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1777,8 +1777,12 @@ static void enic_poll_controller(struct net_device *netdev)
 			enic_isr_msix_rq(enic->msix_entry[intr].vector,
 				&enic->napi[i]);
 		}
-		intr = enic_msix_wq_intr(enic, i);
-		enic_isr_msix_wq(enic->msix_entry[intr].vector, enic);
+
+		for (i = 0; i < enic->wq_count; i++) {
+			intr = enic_msix_wq_intr(enic, i);
+			enic_isr_msix_wq(enic->msix_entry[intr].vector, enic);
+		}
+
 		break;
 	case VNIC_DEV_INTR_MODE_MSI:
 		enic_isr_msi(enic->pdev->irq, enic);

