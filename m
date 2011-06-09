From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 2/4] enic: Log device configuration in detail
	during driver load
Date: Thu, 09 Jun 2011 13:36:57 -0700
Message-ID: <20110609203657.31838.53051.stgit@savbu-pc100.cisco.com>
References: <20110609203620.31838.61879.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:39019 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369Ab1FIUhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 16:37:18 -0400
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
 drivers/net/enic/enic_res.c  |   23 ++++++++++++++++++-----
 drivers/net/enic/vnic_enet.h |    7 +++++++
 3 files changed, 26 insertions(+), 6 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index e0d2ad1..23e2103 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.16"
+#define DRV_VERSION		"2.1.1.17"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index 6e5c635..34f4207 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -97,11 +97,24 @@ int enic_get_vnic_config(struct enic *enic)
 	dev_info(enic_get_dev(enic),
 		"vNIC MAC addr %pM wq/rq %d/%d mtu %d\n",
 		enic->mac_addr, c->wq_desc_count, c->rq_desc_count, c->mtu);
-	dev_info(enic_get_dev(enic), "vNIC csum tx/rx %d/%d "
-		"tso %d intr timer %d usec rss %d\n",
-		ENIC_SETTING(enic, TXCSUM), ENIC_SETTING(enic, RXCSUM),
-		ENIC_SETTING(enic, TSO),
-		c->intr_timer_usec, ENIC_SETTING(enic, RSS));
+
+	dev_info(enic_get_dev(enic), "vNIC csum tx/rx %s/%s "
+		"tso/lro %s/%s rss %s intr mode %s type %s timer %d usec "
+		"loopback tag 0x%04x\n",
+		ENIC_SETTING(enic, TXCSUM) ? "yes" : "no",
+		ENIC_SETTING(enic, RXCSUM) ? "yes" : "no",
+		ENIC_SETTING(enic, TSO) ? "yes" : "no",
+		ENIC_SETTING(enic, LRO) ? "yes" : "no",
+		ENIC_SETTING(enic, RSS) ? "yes" : "no",
+		c->intr_mode == VENET_INTR_MODE_INTX ? "INTx" :
+		c->intr_mode == VENET_INTR_MODE_MSI ? "MSI" :
+		c->intr_mode == VENET_INTR_MODE_ANY ? "any" :
+		"unknown",
+		c->intr_timer_type == VENET_INTR_TYPE_MIN ? "min" :
+		c->intr_timer_type == VENET_INTR_TYPE_IDLE ? "idle" :
+		"unknown",
+		c->intr_timer_usec,
+		c->loop_tag);
 
 	return 0;
 }
diff --git a/drivers/net/enic/vnic_enet.h b/drivers/net/enic/vnic_enet.h
index e8740e3..061ad87 100644
--- a/drivers/net/enic/vnic_enet.h
+++ b/drivers/net/enic/vnic_enet.h
@@ -51,4 +51,11 @@ struct vnic_enet_config {
 #define VENETF_RSSHASH_TCPIPV6_EX 0x400	/* Hash on TCP + IPv6 ext. fields */
 #define VENETF_LOOP		0x800	/* Loopback enabled */
 
+#define VENET_INTR_TYPE_MIN	0	/* Timer specs min interrupt spacing */
+#define VENET_INTR_TYPE_IDLE	1	/* Timer specs idle time before irq */
+
+#define VENET_INTR_MODE_ANY	0	/* Try MSI-X, then MSI, then INTx */
+#define VENET_INTR_MODE_MSI	1	/* Try MSI then INTx */
+#define VENET_INTR_MODE_INTX	2	/* Try INTx only */
+
 #endif /* _VNIC_ENIC_H_ */

