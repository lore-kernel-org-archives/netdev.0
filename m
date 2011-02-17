From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 3/3] enic: Always use single transmit and single
	receive hardware queues per device
Date: Thu, 17 Feb 2011 10:53:22 -0800
Message-ID: <20110217185322.2476.10728.stgit@savbu-pc100.cisco.com>
References: <20110217185245.2476.60944.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:45700 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757701Ab1BQSxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 13:53:22 -0500
In-Reply-To: <20110217185245.2476.60944.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>



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

