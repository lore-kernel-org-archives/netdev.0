From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 10/10] enic: Clean ups
Date: Thu, 24 Jun 2010 13:52:26 -0700
Message-ID: <20100624205213.22595.97942.stgit@savbu-pc100.cisco.com>
References: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, vkolluri@cisco.com,
	roprabhu@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:2868 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338Ab0FXUw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 16:52:26 -0400
In-Reply-To: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

1) Update copyright
2) Fix hardware queue descriptor field size CQ_ENET_RQ_DESC_FCOE_SOF_BITS
3) Include rtnetlink.h instead of if_link.h
4) Selectively flush writes to interrupt mask register
5) Use pci_enable_device_mem
6) Remove unused variables and header files
7) Fix size mismatch between memory alloc and free operations of a variable
8) Check for non null arguments to vic_provinfo_alloc

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/cq_desc.h       |    2 +-
 drivers/net/enic/cq_enet_desc.h  |    4 ++--
 drivers/net/enic/enic.h          |    4 ++--
 drivers/net/enic/enic_main.c     |   11 ++++++-----
 drivers/net/enic/enic_res.c      |    2 +-
 drivers/net/enic/enic_res.h      |    2 +-
 drivers/net/enic/rq_enet_desc.h  |    2 +-
 drivers/net/enic/vnic_cq.c       |    2 +-
 drivers/net/enic/vnic_cq.h       |    2 +-
 drivers/net/enic/vnic_dev.c      |   25 +++----------------------
 drivers/net/enic/vnic_dev.h      |    2 +-
 drivers/net/enic/vnic_devcmd.h   |    2 +-
 drivers/net/enic/vnic_enet.h     |    2 +-
 drivers/net/enic/vnic_intr.c     |    2 +-
 drivers/net/enic/vnic_intr.h     |    8 ++++++--
 drivers/net/enic/vnic_nic.h      |    2 +-
 drivers/net/enic/vnic_resource.h |    2 +-
 drivers/net/enic/vnic_rq.c       |    4 +---
 drivers/net/enic/vnic_rq.h       |    2 +-
 drivers/net/enic/vnic_rss.h      |    2 +-
 drivers/net/enic/vnic_stats.h    |    2 +-
 drivers/net/enic/vnic_vic.c      |    3 +++
 drivers/net/enic/vnic_wq.c       |    3 +--
 drivers/net/enic/vnic_wq.h       |    2 +-
 drivers/net/enic/wq_enet_desc.h  |    2 +-
 25 files changed, 41 insertions(+), 55 deletions(-)

diff --git a/drivers/net/enic/cq_desc.h b/drivers/net/enic/cq_desc.h
index 1eb289f..d6dd1b4 100644
--- a/drivers/net/enic/cq_desc.h
+++ b/drivers/net/enic/cq_desc.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/cq_enet_desc.h b/drivers/net/enic/cq_enet_desc.h
index f2d98bb..c2c0680 100644
--- a/drivers/net/enic/cq_enet_desc.h
+++ b/drivers/net/enic/cq_enet_desc.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
@@ -82,7 +82,7 @@ struct cq_enet_rq_desc {
 	((1 << CQ_ENET_RQ_DESC_VLAN_TCI_USER_PRIO_BITS) - 1)
 #define CQ_ENET_RQ_DESC_VLAN_TCI_USER_PRIO_SHIFT    13
 
-#define CQ_ENET_RQ_DESC_FCOE_SOF_BITS               4
+#define CQ_ENET_RQ_DESC_FCOE_SOF_BITS               8
 #define CQ_ENET_RQ_DESC_FCOE_SOF_MASK \
 	((1 << CQ_ENET_RQ_DESC_FCOE_SOF_BITS) - 1)
 #define CQ_ENET_RQ_DESC_FCOE_EOF_BITS               8
diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 7280314..f239aa8 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
@@ -33,7 +33,7 @@
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
 #define DRV_VERSION		"1.4.1.1"
-#define DRV_COPYRIGHT		"Copyright 2008-2009 Cisco Systems, Inc"
+#define DRV_COPYRIGHT		"Copyright 2008-2010 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
 
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index eda5530..6c6795b 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
@@ -29,12 +29,12 @@
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
-#include <linux/if_link.h>
 #include <linux/ethtool.h>
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/tcp.h>
+#include <linux/rtnetlink.h>
 #include <net/ip6_checksum.h>
 
 #include "cq_enet_desc.h"
@@ -1799,8 +1799,10 @@ static int enic_stop(struct net_device *netdev)
 	unsigned int i;
 	int err;
 
-	for (i = 0; i < enic->intr_count; i++)
+	for (i = 0; i < enic->intr_count; i++) {
 		vnic_intr_mask(&enic->intr[i]);
+		(void)vnic_intr_masked(&enic->intr[i]); /* flush write */
+	}
 
 	enic_synchronize_irqs(enic);
 
@@ -1810,7 +1812,6 @@ static int enic_stop(struct net_device *netdev)
 	napi_disable(&enic->napi);
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
-
 	enic_dev_del_station_addr(enic);
 
 	for (i = 0; i < enic->wq_count; i++) {
@@ -2299,7 +2300,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	/* Setup PCI resources
 	 */
 
-	err = pci_enable_device(pdev);
+	err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(dev, "Cannot enable PCI device, aborting\n");
 		goto err_out_free_netdev;
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index 2cc7e27..29ede8a 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/enic_res.h b/drivers/net/enic/enic_res.h
index 8b25a07..83bd172 100644
--- a/drivers/net/enic/enic_res.h
+++ b/drivers/net/enic/enic_res.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/rq_enet_desc.h b/drivers/net/enic/rq_enet_desc.h
index a06e649..e6dd309 100644
--- a/drivers/net/enic/rq_enet_desc.h
+++ b/drivers/net/enic/rq_enet_desc.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_cq.c b/drivers/net/enic/vnic_cq.c
index 326ea40..b86d6ef 100644
--- a/drivers/net/enic/vnic_cq.c
+++ b/drivers/net/enic/vnic_cq.c
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_cq.h b/drivers/net/enic/vnic_cq.h
index 114763c..552d3da 100644
--- a/drivers/net/enic/vnic_cq.h
+++ b/drivers/net/enic/vnic_cq.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 662123c..6a5b578 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
@@ -23,7 +23,6 @@
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <linux/if_ether.h>
-#include <linux/slab.h>
 
 #include "vnic_resource.h"
 #include "vnic_devcmd.h"
@@ -41,8 +40,6 @@ struct vnic_res {
 	unsigned int count;
 };
 
-#define VNIC_DEV_CAP_INIT	0x0001
-
 struct vnic_dev {
 	void *priv;
 	struct pci_dev *pdev;
@@ -53,13 +50,11 @@ struct vnic_dev {
 	struct vnic_devcmd_notify notify_copy;
 	dma_addr_t notify_pa;
 	u32 notify_sz;
-	u32 *linkstatus;
 	dma_addr_t linkstatus_pa;
 	struct vnic_stats *stats;
 	dma_addr_t stats_pa;
 	struct vnic_devcmd_fw_info *fw_info;
 	dma_addr_t fw_info_pa;
-	u32 cap_flags;
 	enum vnic_proxy_type proxy;
 	u32 proxy_index;
 	u64 args[VNIC_DEVCMD_NARGS];
@@ -279,7 +274,6 @@ static int _vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 		/* PCI-e target device is gone */
 		return -ENODEV;
 	}
-
 	if (status & STAT_BUSY) {
 		pr_err("Busy devcmd %d\n", _CMD_N(cmd));
 		return -EBUSY;
@@ -852,7 +846,7 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg)
 	int wait = 1000;
 	int r = 0;
 
-	if (vdev->cap_flags & VNIC_DEV_CAP_INIT)
+	if (vnic_dev_capable(vdev, CMD_INIT))
 		r = vnic_dev_cmd(vdev, CMD_INIT, &a0, &a1, wait);
 	else {
 		vnic_dev_cmd(vdev, CMD_INIT_v1, &a0, &a1, wait);
@@ -919,9 +913,6 @@ int vnic_dev_deinit(struct vnic_dev *vdev)
 
 int vnic_dev_link_status(struct vnic_dev *vdev)
 {
-	if (vdev->linkstatus)
-		return *vdev->linkstatus;
-
 	if (!vnic_dev_notify_ready(vdev))
 		return 0;
 
@@ -996,14 +987,9 @@ void vnic_dev_unregister(struct vnic_dev *vdev)
 				sizeof(struct vnic_devcmd_notify),
 				vdev->notify,
 				vdev->notify_pa);
-		if (vdev->linkstatus)
-			pci_free_consistent(vdev->pdev,
-				sizeof(u32),
-				vdev->linkstatus,
-				vdev->linkstatus_pa);
 		if (vdev->stats)
 			pci_free_consistent(vdev->pdev,
-				sizeof(struct vnic_dev),
+				sizeof(struct vnic_stats),
 				vdev->stats, vdev->stats_pa);
 		if (vdev->fw_info)
 			pci_free_consistent(vdev->pdev,
@@ -1033,11 +1019,6 @@ struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
 	if (!vdev->devcmd)
 		goto err_out;
 
-	vdev->cap_flags = 0;
-
-	if (vnic_dev_capable(vdev, CMD_INIT))
-		vdev->cap_flags |= VNIC_DEV_CAP_INIT;
-
 	return vdev;
 
 err_out:
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index cfdaa69..3a61873 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_devcmd.h b/drivers/net/enic/vnic_devcmd.h
index e6c80c7..2066175 100644
--- a/drivers/net/enic/vnic_devcmd.h
+++ b/drivers/net/enic/vnic_devcmd.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_enet.h b/drivers/net/enic/vnic_enet.h
index 42baaa1..3b32912 100644
--- a/drivers/net/enic/vnic_enet.h
+++ b/drivers/net/enic/vnic_enet.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_intr.c b/drivers/net/enic/vnic_intr.c
index 416eae7..52ab61a 100644
--- a/drivers/net/enic/vnic_intr.c
+++ b/drivers/net/enic/vnic_intr.c
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_intr.h b/drivers/net/enic/vnic_intr.h
index 2fe6c63..09dc0b7 100644
--- a/drivers/net/enic/vnic_intr.h
+++ b/drivers/net/enic/vnic_intr.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
@@ -61,7 +61,11 @@ static inline void vnic_intr_unmask(struct vnic_intr *intr)
 static inline void vnic_intr_mask(struct vnic_intr *intr)
 {
 	iowrite32(1, &intr->ctrl->mask);
-	(void)ioread32(&intr->ctrl->mask);
+}
+
+static inline int vnic_intr_masked(struct vnic_intr *intr)
+{
+	return ioread32(&intr->ctrl->mask);
 }
 
 static inline void vnic_intr_return_credits(struct vnic_intr *intr,
diff --git a/drivers/net/enic/vnic_nic.h b/drivers/net/enic/vnic_nic.h
index cf80ab4..995a50d 100644
--- a/drivers/net/enic/vnic_nic.h
+++ b/drivers/net/enic/vnic_nic.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_resource.h b/drivers/net/enic/vnic_resource.h
index b61c22a..810287b 100644
--- a/drivers/net/enic/vnic_resource.h
+++ b/drivers/net/enic/vnic_resource.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_rq.c b/drivers/net/enic/vnic_rq.c
index 061a26f..4d8e546 100644
--- a/drivers/net/enic/vnic_rq.c
+++ b/drivers/net/enic/vnic_rq.c
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
@@ -22,7 +22,6 @@
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
-#include <linux/slab.h>
 
 #include "vnic_dev.h"
 #include "vnic_rq.h"
@@ -209,7 +208,6 @@ void vnic_rq_clean(struct vnic_rq *rq,
 		/* Hardware surprise removal: reset fetch_index */
 		fetch_index = 0;
 	}
-
 	rq->to_use = rq->to_clean =
 		&rq->bufs[fetch_index / VNIC_RQ_BUF_BLK_ENTRIES(count)]
 			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES(count)];
diff --git a/drivers/net/enic/vnic_rq.h b/drivers/net/enic/vnic_rq.h
index 8f0fb78..2dc48f9 100644
--- a/drivers/net/enic/vnic_rq.h
+++ b/drivers/net/enic/vnic_rq.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008, 2009 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_rss.h b/drivers/net/enic/vnic_rss.h
index 5fbb3c9..f62d187 100644
--- a/drivers/net/enic/vnic_rss.h
+++ b/drivers/net/enic/vnic_rss.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_stats.h b/drivers/net/enic/vnic_stats.h
index 9ff9614..77750ec 100644
--- a/drivers/net/enic/vnic_stats.h
+++ b/drivers/net/enic/vnic_stats.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/vnic_vic.c b/drivers/net/enic/vnic_vic.c
index 0a35085..197c9d2 100644
--- a/drivers/net/enic/vnic_vic.c
+++ b/drivers/net/enic/vnic_vic.c
@@ -27,6 +27,9 @@ struct vic_provinfo *vic_provinfo_alloc(gfp_t flags, u8 *oui, u8 type)
 {
 	struct vic_provinfo *vp;
 
+	if (!oui)
+		return NULL;
+
 	vp = kzalloc(VIC_PROVINFO_MAX_DATA, flags);
 	if (!vp)
 		return NULL;
diff --git a/drivers/net/enic/vnic_wq.c b/drivers/net/enic/vnic_wq.c
index 3ab7fa5..5c84bb8 100644
--- a/drivers/net/enic/vnic_wq.c
+++ b/drivers/net/enic/vnic_wq.c
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
@@ -22,7 +22,6 @@
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
-#include <linux/slab.h>
 
 #include "vnic_dev.h"
 #include "vnic_wq.h"
diff --git a/drivers/net/enic/vnic_wq.h b/drivers/net/enic/vnic_wq.h
index 1c82139..94ac462 100644
--- a/drivers/net/enic/vnic_wq.h
+++ b/drivers/net/enic/vnic_wq.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify
diff --git a/drivers/net/enic/wq_enet_desc.h b/drivers/net/enic/wq_enet_desc.h
index 483596c..c7021e3 100644
--- a/drivers/net/enic/wq_enet_desc.h
+++ b/drivers/net/enic/wq_enet_desc.h
@@ -1,5 +1,5 @@
 /*
- * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
  *
  * This program is free software; you may redistribute it and/or modify

