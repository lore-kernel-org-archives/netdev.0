From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH 1/4 net-next] enic: move struct definition from .c to .h file
Date: Sun, 16 Aug 2015 01:44:51 +0530
Message-ID: <1439669694-21744-2-git-send-email-_govind@gmx.com>
References: <1439669694-21744-1-git-send-email-_govind@gmx.com>
Cc: nalreddy@cisco.com, ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:60381 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753332AbbHOUPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Aug 2015 16:15:40 -0400
In-Reply-To: <1439669694-21744-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the structure definitions are in .c file to make them private to
that file. This patch moves the struct definition to .h file, So that their
definitions are accessible from other files.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/vnic_dev.c | 39 -----------------------------
 drivers/net/ethernet/cisco/enic/vnic_dev.h | 40 +++++++++++++++++++++++++++++-
 2 files changed, 39 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 62f7b7b..b239cfd 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -29,45 +29,6 @@
 #include "vnic_dev.h"
 #include "vnic_stats.h"
 
-enum vnic_proxy_type {
-	PROXY_NONE,
-	PROXY_BY_BDF,
-	PROXY_BY_INDEX,
-};
-
-struct vnic_res {
-	void __iomem *vaddr;
-	dma_addr_t bus_addr;
-	unsigned int count;
-};
-
-struct vnic_intr_coal_timer_info {
-	u32 mul;
-	u32 div;
-	u32 max_usec;
-};
-
-struct vnic_dev {
-	void *priv;
-	struct pci_dev *pdev;
-	struct vnic_res res[RES_TYPE_MAX];
-	enum vnic_dev_intr_mode intr_mode;
-	struct vnic_devcmd __iomem *devcmd;
-	struct vnic_devcmd_notify *notify;
-	struct vnic_devcmd_notify notify_copy;
-	dma_addr_t notify_pa;
-	u32 notify_sz;
-	dma_addr_t linkstatus_pa;
-	struct vnic_stats *stats;
-	dma_addr_t stats_pa;
-	struct vnic_devcmd_fw_info *fw_info;
-	dma_addr_t fw_info_pa;
-	enum vnic_proxy_type proxy;
-	u32 proxy_index;
-	u64 args[VNIC_DEVCMD_NARGS];
-	struct vnic_intr_coal_timer_info intr_coal_timer_info;
-};
-
 #define VNIC_MAX_RES_HDR_SIZE \
 	(sizeof(struct vnic_resource_header) + \
 	sizeof(struct vnic_resource) * RES_TYPE_MAX)
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
index 1fb214e..90bca09 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.h
@@ -70,7 +70,45 @@ struct vnic_dev_ring {
 	unsigned int desc_avail;
 };
 
-struct vnic_dev;
+enum vnic_proxy_type {
+	PROXY_NONE,
+	PROXY_BY_BDF,
+	PROXY_BY_INDEX,
+};
+
+struct vnic_res {
+	void __iomem *vaddr;
+	dma_addr_t bus_addr;
+	unsigned int count;
+};
+
+struct vnic_intr_coal_timer_info {
+	u32 mul;
+	u32 div;
+	u32 max_usec;
+};
+
+struct vnic_dev {
+	void *priv;
+	struct pci_dev *pdev;
+	struct vnic_res res[RES_TYPE_MAX];
+	enum vnic_dev_intr_mode intr_mode;
+	struct vnic_devcmd __iomem *devcmd;
+	struct vnic_devcmd_notify *notify;
+	struct vnic_devcmd_notify notify_copy;
+	dma_addr_t notify_pa;
+	u32 notify_sz;
+	dma_addr_t linkstatus_pa;
+	struct vnic_stats *stats;
+	dma_addr_t stats_pa;
+	struct vnic_devcmd_fw_info *fw_info;
+	dma_addr_t fw_info_pa;
+	enum vnic_proxy_type proxy;
+	u32 proxy_index;
+	u64 args[VNIC_DEVCMD_NARGS];
+	struct vnic_intr_coal_timer_info intr_coal_timer_info;
+};
+
 struct vnic_stats;
 
 void *vnic_dev_priv(struct vnic_dev *vdev);
-- 
2.5.0
