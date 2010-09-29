From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 2/2] enic: make local functions static
Date: Wed, 29 Sep 2010 15:29:12 +0900
Message-ID: <20100929152912.77d0ca5f@s6510>
References: <20100929151959.6a09a269@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53434 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab0I2G3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 02:29:21 -0400
In-Reply-To: <20100929151959.6a09a269@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lots of functions in this driver are only used in one file and should
be static. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/enic/enic_main.c |    6 +++---
 drivers/net/enic/vnic_dev.c  |    6 +++---
 drivers/net/enic/vnic_dev.h  |    7 -------
 drivers/net/enic/vnic_rq.c   |    2 +-
 drivers/net/enic/vnic_rq.h   |    4 ----
 drivers/net/enic/vnic_wq.c   |    2 +-
 drivers/net/enic/vnic_wq.h   |    4 ----
 7 files changed, 8 insertions(+), 23 deletions(-)

--- a/drivers/net/enic/enic_main.c	2010-09-29 15:21:47.173306644 +0900
+++ b/drivers/net/enic/enic_main.c	2010-09-29 15:27:30.223305739 +0900
@@ -1972,7 +1972,7 @@ static int enic_dev_hang_notify(struct e
 	return err;
 }
 
-int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic)
+static int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic)
 {
 	int err;
 
@@ -2147,14 +2147,14 @@ static const struct net_device_ops enic_
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
--- a/drivers/net/enic/vnic_dev.c	2010-09-29 15:27:22.315218464 +0900
+++ b/drivers/net/enic/vnic_dev.c	2010-09-29 15:27:30.233306032 +0900
@@ -186,7 +186,7 @@ void __iomem *vnic_dev_get_res(struct vn
 	}
 }
 
-unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
+static unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
 	unsigned int desc_count, unsigned int desc_size)
 {
 	/* The base address of the desc rings must be 512 byte aligned.
@@ -657,7 +657,7 @@ int vnic_dev_set_ig_vlan_rewrite_mode(st
 	return err;
 }
 
-int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
+static int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
 	void *notify_addr, dma_addr_t notify_pa, u16 intr)
 {
 	u64 a0, a1;
@@ -696,7 +696,7 @@ int vnic_dev_notify_set(struct vnic_dev 
 	return vnic_dev_notify_setcmd(vdev, notify_addr, notify_pa, intr);
 }
 
-int vnic_dev_notify_unsetcmd(struct vnic_dev *vdev)
+static int vnic_dev_notify_unsetcmd(struct vnic_dev *vdev)
 {
 	u64 a0, a1;
 	int wait = 1000;
--- a/drivers/net/enic/vnic_rq.c	2010-09-29 15:21:47.203305569 +0900
+++ b/drivers/net/enic/vnic_rq.c	2010-09-29 15:27:30.233306032 +0900
@@ -115,7 +115,7 @@ int vnic_rq_alloc(struct vnic_dev *vdev,
 	return 0;
 }
 
-void vnic_rq_init_start(struct vnic_rq *rq, unsigned int cq_index,
+static void vnic_rq_init_start(struct vnic_rq *rq, unsigned int cq_index,
 	unsigned int fetch_index, unsigned int posted_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset)
--- a/drivers/net/enic/vnic_wq.c	2010-09-29 15:21:47.213306002 +0900
+++ b/drivers/net/enic/vnic_wq.c	2010-09-29 15:27:30.233306032 +0900
@@ -115,7 +115,7 @@ int vnic_wq_alloc(struct vnic_dev *vdev,
 	return 0;
 }
 
-void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
+static void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
 	unsigned int fetch_index, unsigned int posted_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset)
--- a/drivers/net/enic/vnic_dev.h	2010-09-29 15:26:29.273306571 +0900
+++ b/drivers/net/enic/vnic_dev.h	2010-09-29 15:27:30.233306032 +0900
@@ -84,8 +84,6 @@ unsigned int vnic_dev_get_res_count(stru
 	enum vnic_res_type type);
 void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
 	unsigned int index);
-unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
-	unsigned int desc_count, unsigned int desc_size);
 void vnic_dev_clear_desc_ring(struct vnic_dev_ring *ring);
 int vnic_dev_alloc_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring,
 	unsigned int desc_count, unsigned int desc_size);
@@ -106,17 +104,12 @@ int vnic_dev_packet_filter(struct vnic_d
 int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
-int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr);
-int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
-	void *notify_addr, dma_addr_t notify_pa, u16 intr);
 int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr);
-int vnic_dev_notify_unsetcmd(struct vnic_dev *vdev);
 int vnic_dev_notify_unset(struct vnic_dev *vdev);
 int vnic_dev_link_status(struct vnic_dev *vdev);
 u32 vnic_dev_port_speed(struct vnic_dev *vdev);
 u32 vnic_dev_msg_lvl(struct vnic_dev *vdev);
 u32 vnic_dev_mtu(struct vnic_dev *vdev);
-u32 vnic_dev_link_down_cnt(struct vnic_dev *vdev);
 int vnic_dev_close(struct vnic_dev *vdev);
 int vnic_dev_enable(struct vnic_dev *vdev);
 int vnic_dev_disable(struct vnic_dev *vdev);
--- a/drivers/net/enic/vnic_rq.h	2010-09-29 15:21:47.243305555 +0900
+++ b/drivers/net/enic/vnic_rq.h	2010-09-29 15:27:30.233306032 +0900
@@ -202,10 +202,6 @@ static inline int vnic_rq_fill(struct vn
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
--- a/drivers/net/enic/vnic_wq.h	2010-09-29 15:21:47.263307399 +0900
+++ b/drivers/net/enic/vnic_wq.h	2010-09-29 15:27:30.233306032 +0900
@@ -153,10 +153,6 @@ static inline void vnic_wq_service(struc
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
