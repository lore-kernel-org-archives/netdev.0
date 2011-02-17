From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Always use single transmit and single
	receive hardware queues per device
Date: Thu, 17 Feb 2011 15:57:19 -0800
Message-ID: <20110217235719.6978.78272.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:35362 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754960Ab1BQX5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 18:57:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

We believe that our earlier patch for supporting multiple hardware receive queues per enic device requires more internal testing. At this point, we think that it's best to disable the use of multiple receive queues. The current patch provides an effective means for the same.

Also, we continue to disallow multiple hardware transmit queues per device. But change the way we enforce this in order to maintain consistency with the way receive queues are handled.

Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Danny Guo <dannguo@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |    6 +++---
 drivers/net/enic/enic_main.c |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 2ac891b..aee5256 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,13 +32,13 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.8"
+#define DRV_VERSION		"2.1.1.9"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
 
-#define ENIC_WQ_MAX		8
-#define ENIC_RQ_MAX		8
+#define ENIC_WQ_MAX		1
+#define ENIC_RQ_MAX		1
 #define ENIC_CQ_MAX		(ENIC_WQ_MAX + ENIC_RQ_MAX)
 #define ENIC_INTR_MAX		(ENIC_CQ_MAX + 2)
 
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index d1aa807..4f1710e 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -2080,7 +2080,7 @@ static void enic_reset(struct work_struct *work)
 static int enic_set_intr_mode(struct enic *enic)
 {
 	unsigned int n = min_t(unsigned int, enic->rq_count, ENIC_RQ_MAX);
-	unsigned int m = 1;
+	unsigned int m = min_t(unsigned int, enic->wq_count, ENIC_WQ_MAX);
 	unsigned int i;
 
 	/* Set interrupt mode (INTx, MSI, MSI-X) depending

