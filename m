From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 2/3] enic: Make local functions static
Date: Thu, 30 Sep 2010 16:35:45 -0700
Message-ID: <20100930233540.16528.14130.stgit@savbu-pc100.cisco.com>
References: <20100930233412.16528.52523.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, roprabhu@cisco.com,
	dwang2@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:58919 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754853Ab0I3Xft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 19:35:49 -0400
In-Reply-To: <20100930233412.16528.52523.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Make functions used locally in a file as static

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic_main.c |    6 +++---
 drivers/net/enic/vnic_dev.c  |   10 +++++-----
 drivers/net/enic/vnic_dev.h  |    7 -------
 drivers/net/enic/vnic_rq.c   |    2 +-
 drivers/net/enic/vnic_rq.h   |    4 ----
 drivers/net/enic/vnic_wq.c   |    2 +-
 drivers/net/enic/vnic_wq.h   |    4 ----
 7 files changed, 10 insertions(+), 25 deletions(-)


diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 711077a..a1f92f1 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1972,7 +1972,7 @@ static int enic_dev_hang_notify(struct enic *enic)
 	return err;
 }
 
-int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic)
+static int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic)
 {
 	int err;
 
@@ -2147,14 +2147,14 @@ static const struct net_device_ops enic_netdev_ops = {
 #endif
 };
 
-void enic_dev_deinit(struct enic *enic)
+static void enic_dev_deinit(struct enic *enic)
 {
 	netif_napi_del(&enic->napi);
 	enic_free_vnic_resources(enic);
 	enic_clear_intr_mode(enic);
 }
 
-int enic_dev_init(struct enic *enic)
+static int enic_dev_init(struct enic *enic)
 {
 	struct device *dev = enic_get_dev(enic);
 	struct net_device *netdev = enic->netdev;
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index f99ddee..11dc8f7 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -186,7 +186,7 @@ void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
 	}
 }
 
-unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
+static unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
 	unsigned int desc_count, unsigned int desc_size)
 {
 	/* The base address of the desc rings must be 512 byte aligned.
@@ -525,14 +525,14 @@ int vnic_dev_open_done(struct vnic_dev *vdev, int *done)
 	return 0;
 }
 
-int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg)
+static int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg)
 {
 	u64 a0 = (u32)arg, a1 = 0;
 	int wait = 1000;
 	return vnic_dev_cmd(vdev, CMD_SOFT_RESET, &a0, &a1, wait);
 }
 
-int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done)
+static int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done)
 {
 	u64 a0 = 0, a1 = 0;
 	int wait = 1000;
@@ -681,7 +681,7 @@ int vnic_dev_set_ig_vlan_rewrite_mode(struct vnic_dev *vdev,
 	return err;
 }
 
-int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
+static int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
 	void *notify_addr, dma_addr_t notify_pa, u16 intr)
 {
 	u64 a0, a1;
@@ -720,7 +720,7 @@ int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
 	return vnic_dev_notify_setcmd(vdev, notify_addr, notify_pa, intr);
 }
 
-int vnic_dev_notify_unsetcmd(struct vnic_dev *vdev)
+static int vnic_dev_notify_unsetcmd(struct vnic_dev *vdev)
 {
 	u64 a0, a1;
 	int wait = 1000;
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index 008304b..3f00143 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -84,8 +84,6 @@ unsigned int vnic_dev_get_res_count(struct vnic_dev *vdev,
 	enum vnic_res_type type);
 void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
 	unsigned int index);
-unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
-	unsigned int desc_count, unsigned int desc_size);
 void vnic_dev_clear_desc_ring(struct vnic_dev_ring *ring);
 int vnic_dev_alloc_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring,
 	unsigned int desc_count, unsigned int desc_size);
@@ -106,10 +104,7 @@ int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
-int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
-	void *notify_addr, dma_addr_t notify_pa, u16 intr);
 int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr);
-int vnic_dev_notify_unsetcmd(struct vnic_dev *vdev);
 int vnic_dev_notify_unset(struct vnic_dev *vdev);
 int vnic_dev_link_status(struct vnic_dev *vdev);
 u32 vnic_dev_port_speed(struct vnic_dev *vdev);
@@ -124,8 +119,6 @@ int vnic_dev_init(struct vnic_dev *vdev, int arg);
 int vnic_dev_init_done(struct vnic_dev *vdev, int *done, int *err);
 int vnic_dev_init_prov(struct vnic_dev *vdev, u8 *buf, u32 len);
 int vnic_dev_deinit(struct vnic_dev *vdev);
-int vnic_dev_soft_reset(struct vnic_dev *vdev, int arg);
-int vnic_dev_soft_reset_done(struct vnic_dev *vdev, int *done);
 int vnic_dev_hang_reset(struct vnic_dev *vdev, int arg);
 int vnic_dev_hang_reset_done(struct vnic_dev *vdev, int *done);
 void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
diff --git a/drivers/net/enic/vnic_rq.c b/drivers/net/enic/vnic_rq.c
index b236d7c..34105e0 100644
--- a/drivers/net/enic/vnic_rq.c
+++ b/drivers/net/enic/vnic_rq.c
@@ -115,7 +115,7 @@ int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
 	return 0;
 }
 
-void vnic_rq_init_start(struct vnic_rq *rq, unsigned int cq_index,
+static void vnic_rq_init_start(struct vnic_rq *rq, unsigned int cq_index,
 	unsigned int fetch_index, unsigned int posted_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset)
diff --git a/drivers/net/enic/vnic_rq.h b/drivers/net/enic/vnic_rq.h
index 4b6f021..37f08de 100644
--- a/drivers/net/enic/vnic_rq.h
+++ b/drivers/net/enic/vnic_rq.h
@@ -202,10 +202,6 @@ static inline int vnic_rq_fill(struct vnic_rq *rq,
 void vnic_rq_free(struct vnic_rq *rq);
 int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
 	unsigned int desc_count, unsigned int desc_size);
-void vnic_rq_init_start(struct vnic_rq *rq, unsigned int cq_index,
-	unsigned int fetch_index, unsigned int posted_index,
-	unsigned int error_interrupt_enable,
-	unsigned int error_interrupt_offset);
 void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset);
diff --git a/drivers/net/enic/vnic_wq.c b/drivers/net/enic/vnic_wq.c
index 4b2a6c6..df61bd9 100644
--- a/drivers/net/enic/vnic_wq.c
+++ b/drivers/net/enic/vnic_wq.c
@@ -115,7 +115,7 @@ int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
 	return 0;
 }
 
-void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
+static void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
 	unsigned int fetch_index, unsigned int posted_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset)
diff --git a/drivers/net/enic/vnic_wq.h b/drivers/net/enic/vnic_wq.h
index 94ac462..7dd937a 100644
--- a/drivers/net/enic/vnic_wq.h
+++ b/drivers/net/enic/vnic_wq.h
@@ -153,10 +153,6 @@ static inline void vnic_wq_service(struct vnic_wq *wq,
 void vnic_wq_free(struct vnic_wq *wq);
 int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
 	unsigned int desc_count, unsigned int desc_size);
-void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
-	unsigned int fetch_index, unsigned int posted_index,
-	unsigned int error_interrupt_enable,
-	unsigned int error_interrupt_offset);
 void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset);

