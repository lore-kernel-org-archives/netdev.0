From: huangdaode <huangdaode@hisilicon.com>
Subject: [PATCH v2 4/5] net: add Hisilicon Network Subsystem DSAF support
Date: Thu, 17 Sep 2015 14:51:49 +0800
Message-ID: <1442472710-20909-5-git-send-email-huangdaode@hisilicon.com>
References: <1442472710-20909-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<davem@davemloft.net>, <paul.gortmaker@windriver.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:5636 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753443AbbIQGpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 02:45:03 -0400
In-Reply-To: <1442472710-20909-1-git-send-email-huangdaode@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSAF, namely Distributed System Area Fabric, is one of the HNS
acceleration engine implementation. This patch add DSAF driver to the
system.

hns_ae_adapt: the adaptor for registering the driver to HNAE framework
hns_dsaf_mac: MAC cover interface for GE and XGE
hns_dsaf_gmac: GE (10/100/1000G Ethernet) MAC function
hns_dsaf_xgmac: XGE (10000+G Ethernet) MAC function
hns_dsaf_main: the platform device driver for the whole hardware
hns_dsaf_misc: some misc helper function, such as LED support
hns_dsaf_ppe: packet process engine function
hns_dsaf_rcb: ring buffer function

Signed-off-by: huangdaode <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Signed-off-by: Kenneth Lee <liguozhu@huawei.com>
---
 drivers/net/ethernet/hisilicon/Kconfig             |    9 +
 drivers/net/ethernet/hisilicon/hns/Makefile        |    4 +
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  777 +++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |  704 ++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.h |   45 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  900 +++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  456 ++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 2445 ++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  427 ++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |  317 +++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h |   43 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  583 +++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h  |  105 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  | 1023 ++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |  137 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  972 ++++++++
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c    |  836 +++++++
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h    |   15 +
 18 files changed, 9798 insertions(+)
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
 create mode 100644 drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h

diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
index 85a2609..aae2c47 100644
--- a/drivers/net/ethernet/hisilicon/Kconfig
+++ b/drivers/net/ethernet/hisilicon/Kconfig
@@ -46,4 +46,13 @@ config HNS
 	  is needed by any driver which provides HNS acceleration engine or make
 	  use of the engine
 
+config HNS_DSAF
+	tristate "Hisilicon HNS DSAF device Support"
+	select HNS
+	select HNS_MDIO
+	---help---
+	  This selects the DSAF (Distributed System Area Frabric) network
+	  acceleration engine support. The engine is used in Hisilicon hip05,
+	  Hi1610 and further ICT SoC
+
 endif # NET_VENDOR_HISILICON
diff --git a/drivers/net/ethernet/hisilicon/hns/Makefile b/drivers/net/ethernet/hisilicon/hns/Makefile
index 8a5f1e7..0516af7 100644
--- a/drivers/net/ethernet/hisilicon/hns/Makefile
+++ b/drivers/net/ethernet/hisilicon/hns/Makefile
@@ -3,3 +3,7 @@
 #
 
 obj-$(CONFIG_HNS) += hnae.o
+
+obj-$(CONFIG_HNS_DSAF) += hns_dsaf.o
+hns_dsaf-objs = hns_ae_adapt.o hns_dsaf_gmac.o hns_dsaf_mac.o hns_dsaf_misc.o \
+	hns_dsaf_main.o hns_dsaf_ppe.o hns_dsaf_rcb.o hns_dsaf_xgmac.o
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
new file mode 100644
index 0000000..a2c72f8
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -0,0 +1,777 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/etherdevice.h>
+#include <linux/netdevice.h>
+#include <linux/spinlock.h>
+
+#include "hnae.h"
+#include "hns_dsaf_mac.h"
+#include "hns_dsaf_main.h"
+#include "hns_dsaf_ppe.h"
+#include "hns_dsaf_rcb.h"
+
+#define AE_NAME_PORT_ID_IDX 6
+#define ETH_STATIC_REG	 1
+#define ETH_DUMP_REG	 5
+#define ETH_GSTRING_LEN	32
+
+static struct hns_mac_cb *hns_get_mac_cb(struct hnae_handle *handle)
+{
+	struct  hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
+
+	return vf_cb->mac_cb;
+}
+
+/**
+ * hns_ae_map_eport_to_dport - translate enet port id to dsaf port id
+ * @port_id: enet port id
+ *: debug port 0-1, service port 2 -7 (dsaf mode only 2)
+ * return: dsaf port id
+ *: service ports 0 - 5, debug port 6-7
+ **/
+static int hns_ae_map_eport_to_dport(u32 port_id)
+{
+	int port_index;
+
+	if (port_id < DSAF_DEBUG_NW_NUM)
+		port_index = port_id + DSAF_SERVICE_PORT_NUM_PER_DSAF;
+	else
+		port_index = port_id - DSAF_DEBUG_NW_NUM;
+
+	return port_index;
+}
+
+static struct dsaf_device *hns_ae_get_dsaf_dev(struct hnae_ae_dev *dev)
+{
+	return container_of(dev, struct dsaf_device, ae_dev);
+}
+
+static struct hns_ppe_cb *hns_get_ppe_cb(struct hnae_handle *handle)
+{
+	int ppe_index;
+	int ppe_common_index;
+	struct ppe_common_cb *ppe_comm;
+	struct  hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
+
+	if (vf_cb->port_index < DSAF_SERVICE_PORT_NUM_PER_DSAF) {
+		ppe_index = vf_cb->port_index;
+		ppe_common_index = 0;
+	} else {
+		ppe_index = 0;
+		ppe_common_index =
+			vf_cb->port_index - DSAF_SERVICE_PORT_NUM_PER_DSAF + 1;
+	}
+	ppe_comm = vf_cb->dsaf_dev->ppe_common[ppe_common_index];
+	return &ppe_comm->ppe_cb[ppe_index];
+}
+
+static int hns_ae_get_q_num_per_vf(
+	struct dsaf_device *dsaf_dev, int port)
+{
+	int common_idx = hns_dsaf_get_comm_idx_by_port(port);
+
+	return dsaf_dev->rcb_common[common_idx]->max_q_per_vf;
+}
+
+static int hns_ae_get_vf_num_per_port(
+	struct dsaf_device *dsaf_dev, int port)
+{
+	int common_idx = hns_dsaf_get_comm_idx_by_port(port);
+
+	return dsaf_dev->rcb_common[common_idx]->max_vfn;
+}
+
+static struct ring_pair_cb *hns_ae_get_base_ring_pair(
+	struct dsaf_device *dsaf_dev, int port)
+{
+	int common_idx = hns_dsaf_get_comm_idx_by_port(port);
+	struct rcb_common_cb *rcb_comm = dsaf_dev->rcb_common[common_idx];
+	int q_num = rcb_comm->max_q_per_vf;
+	int vf_num = rcb_comm->max_vfn;
+
+	if (common_idx == HNS_DSAF_COMM_SERVICE_NW_IDX)
+		return &rcb_comm->ring_pair_cb[port * q_num * vf_num];
+	else
+		return &rcb_comm->ring_pair_cb[0];
+}
+
+static struct ring_pair_cb *hns_ae_get_ring_pair(struct hnae_queue *q)
+{
+	return container_of(q, struct ring_pair_cb, q);
+}
+
+struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
+				      u32 port_id)
+{
+	int port_idx;
+	int vfnum_per_port;
+	int qnum_per_vf;
+	int i;
+	struct dsaf_device *dsaf_dev;
+	struct hnae_handle *ae_handle;
+	struct ring_pair_cb *ring_pair_cb;
+	struct hnae_vf_cb *vf_cb;
+
+	dsaf_dev = hns_ae_get_dsaf_dev(dev);
+	port_idx = hns_ae_map_eport_to_dport(port_id);
+
+	ring_pair_cb = hns_ae_get_base_ring_pair(dsaf_dev, port_idx);
+	vfnum_per_port = hns_ae_get_vf_num_per_port(dsaf_dev, port_idx);
+	qnum_per_vf = hns_ae_get_q_num_per_vf(dsaf_dev, port_idx);
+
+	vf_cb = kzalloc(sizeof(*vf_cb) +
+			qnum_per_vf * sizeof(struct hnae_queue *), GFP_KERNEL);
+	if (unlikely(!vf_cb)) {
+		dev_err(dsaf_dev->dev, "malloc vf_cb fail!\n");
+		ae_handle = ERR_PTR(-ENOMEM);
+		goto handle_err;
+	}
+	ae_handle = &vf_cb->ae_handle;
+	/* ae_handle Init  */
+	ae_handle->owner_dev = dsaf_dev->dev;
+	ae_handle->dev = dev;
+	ae_handle->q_num = qnum_per_vf;
+
+	/* find ring pair, and set vf id*/
+	for (ae_handle->vf_id = 0;
+		ae_handle->vf_id < vfnum_per_port; ae_handle->vf_id++) {
+		if (!ring_pair_cb->used_by_vf)
+			break;
+		ring_pair_cb += qnum_per_vf;
+	}
+	if (ae_handle->vf_id >= vfnum_per_port) {
+		dev_err(dsaf_dev->dev, "malloc queue fail!\n");
+		ae_handle = ERR_PTR(-EINVAL);
+		goto vf_id_err;
+	}
+
+	ae_handle->qs = (struct hnae_queue **)(&ae_handle->qs + 1);
+	for (i = 0; i < qnum_per_vf; i++) {
+		ae_handle->qs[i] = &ring_pair_cb->q;
+		ae_handle->qs[i]->rx_ring.q = ae_handle->qs[i];
+		ae_handle->qs[i]->tx_ring.q = ae_handle->qs[i];
+
+		ring_pair_cb->used_by_vf = 1;
+		if (port_idx < DSAF_SERVICE_PORT_NUM_PER_DSAF)
+			ring_pair_cb->port_id_in_dsa = port_idx;
+		else
+			ring_pair_cb->port_id_in_dsa = 0;
+
+		ring_pair_cb++;
+	}
+
+	vf_cb->dsaf_dev = dsaf_dev;
+	vf_cb->port_index = port_idx;
+	vf_cb->mac_cb = &dsaf_dev->mac_cb[port_idx];
+
+	ae_handle->phy_if = vf_cb->mac_cb->phy_if;
+	ae_handle->phy_node = vf_cb->mac_cb->phy_node;
+	ae_handle->if_support = vf_cb->mac_cb->if_support;
+	ae_handle->port_type = vf_cb->mac_cb->mac_type;
+
+	return ae_handle;
+vf_id_err:
+	kfree(vf_cb);
+handle_err:
+	return ae_handle;
+}
+
+static void hns_ae_put_handle(struct hnae_handle *handle)
+{
+	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
+	int i;
+
+	vf_cb->mac_cb	 = NULL;
+
+	kfree(vf_cb);
+
+	for (i = 0; i < handle->q_num; i++)
+		hns_ae_get_ring_pair(handle->qs[i])->used_by_vf = 0;
+}
+
+static void hns_ae_ring_enable_all(struct hnae_handle *handle, int val)
+{
+	int q_num = handle->q_num;
+	int i;
+
+	for (i = 0; i < q_num; i++)
+		hns_rcb_ring_enable_hw(handle->qs[i], val);
+}
+
+static void hns_ae_init_queue(struct hnae_queue *q)
+{
+	struct ring_pair_cb *ring =
+		container_of(q, struct ring_pair_cb, q);
+
+	hns_rcb_init_hw(ring);
+}
+
+static void hns_ae_fini_queue(struct hnae_queue *q)
+{
+	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(q->handle);
+
+	if (vf_cb->mac_cb->mac_type == HNAE_PORT_SERVICE)
+		hns_rcb_reset_ring_hw(q);
+}
+
+static int hns_ae_set_mac_address(struct hnae_handle *handle, void *p)
+{
+	int ret;
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
+	if (!p || !is_valid_ether_addr((const u8 *)p)) {
+		dev_err(handle->owner_dev, "is not valid ether addr !\n");
+		return -EADDRNOTAVAIL;
+	}
+
+	ret = hns_mac_change_vf_addr(mac_cb, handle->vf_id, p);
+	if (ret != 0) {
+		dev_err(handle->owner_dev,
+			"set_mac_address fail, ret=%d!\n", ret);
+		return ret;
+	}
+
+	return 0;
+}
+
+static int hns_ae_set_multicast_one(struct hnae_handle *handle, void *addr)
+{
+	int ret;
+	char *mac_addr = (char *)addr;
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
+	assert(mac_cb);
+
+	if (mac_cb->mac_type != HNAE_PORT_SERVICE)
+		return 0;
+
+	ret = hns_mac_set_multi(mac_cb, mac_cb->mac_id, mac_addr, ENABLE);
+	if (ret) {
+		dev_err(handle->owner_dev,
+			"mac add mul_mac:%pM port%d  fail, ret = %#x!\n",
+			mac_addr, mac_cb->mac_id, ret);
+		return ret;
+	}
+
+	ret = hns_mac_set_multi(mac_cb, DSAF_BASE_INNER_PORT_NUM,
+				mac_addr, ENABLE);
+	if (ret)
+		dev_err(handle->owner_dev,
+			"mac add mul_mac:%pM port%d  fail, ret = %#x!\n",
+			mac_addr, DSAF_BASE_INNER_PORT_NUM, ret);
+
+	return ret;
+}
+
+static int hns_ae_set_mtu(struct hnae_handle *handle, int new_mtu)
+{
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
+	return hns_mac_set_mtu(mac_cb, new_mtu);
+}
+
+static int hns_ae_start(struct hnae_handle *handle)
+{
+	int ret;
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
+	ret = hns_mac_vm_config_bc_en(mac_cb, 0, ENABLE);
+	if (ret)
+		return ret;
+
+	hns_ae_ring_enable_all(handle, 1);
+	msleep(100);
+
+	hns_mac_start(mac_cb);
+
+	return 0;
+}
+
+void hns_ae_stop(struct hnae_handle *handle)
+{
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
+	/* just clean tx fbd, neednot rx fbd*/
+	hns_rcb_wait_fbd_clean(handle->qs, handle->q_num, RCB_INT_FLAG_TX);
+
+	msleep(20);
+
+	hns_mac_stop(mac_cb);
+
+	usleep_range(10000, 20000);
+
+	hns_ae_ring_enable_all(handle, 0);
+
+	(void)hns_mac_vm_config_bc_en(mac_cb, 0, DISABLE);
+}
+
+static void hns_ae_reset(struct hnae_handle *handle)
+{
+	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
+
+	if (vf_cb->mac_cb->mac_type == HNAE_PORT_DEBUG) {
+		u8 ppe_common_index =
+			vf_cb->port_index - DSAF_SERVICE_PORT_NUM_PER_DSAF + 1;
+
+		hns_mac_reset(vf_cb->mac_cb);
+		hns_ppe_reset_common(vf_cb->dsaf_dev, ppe_common_index);
+	}
+}
+
+void hns_ae_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
+{
+	u32 flag;
+
+	if (is_tx_ring(ring))
+		flag = RCB_INT_FLAG_TX;
+	else
+		flag = RCB_INT_FLAG_RX;
+
+	hns_rcb_int_clr_hw(ring->q, flag);
+	hns_rcb_int_ctrl_hw(ring->q, flag, mask);
+}
+
+static void hns_ae_toggle_queue_status(struct hnae_queue *queue, u32 val)
+{
+	hns_rcb_start(queue, val);
+}
+
+static int hns_ae_get_link_status(struct hnae_handle *handle)
+{
+	u32 link_status;
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
+	hns_mac_get_link_status(mac_cb, &link_status);
+
+	return !!link_status;
+}
+
+static int hns_ae_get_mac_info(struct hnae_handle *handle,
+			       u8 *auto_neg, u16 *speed, u8 *duplex)
+{
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
+	return hns_mac_get_port_info(mac_cb, auto_neg, speed, duplex);
+}
+
+static void hns_ae_adjust_link(struct hnae_handle *handle, int speed,
+			       int duplex)
+{
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
+	hns_mac_adjust_link(mac_cb, speed, duplex);
+}
+
+static void hns_ae_get_ring_bdnum_limit(struct hnae_queue *queue,
+					u32 *uplimit)
+{
+	*uplimit = HNS_RCB_RING_MAX_PENDING_BD;
+}
+
+static void hns_ae_get_pauseparam(struct hnae_handle *handle,
+				  u32 *auto_neg, u32 *rx_en, u32 *tx_en)
+{
+	assert(handle);
+
+	hns_mac_get_autoneg(hns_get_mac_cb(handle), auto_neg);
+
+	hns_mac_get_pauseparam(hns_get_mac_cb(handle), rx_en, tx_en);
+}
+
+static int hns_ae_set_autoneg(struct hnae_handle *handle, u8 enable)
+{
+	assert(handle);
+
+	return hns_mac_set_autoneg(hns_get_mac_cb(handle), enable);
+}
+
+static int hns_ae_get_autoneg(struct hnae_handle *handle)
+{
+	u32     auto_neg;
+
+	assert(handle);
+
+	hns_mac_get_autoneg(hns_get_mac_cb(handle), &auto_neg);
+
+	return auto_neg;
+}
+
+static int hns_ae_set_pauseparam(struct hnae_handle *handle,
+				 u32 autoneg, u32 rx_en, u32 tx_en)
+{
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+	int ret;
+
+	ret = hns_mac_set_autoneg(mac_cb, autoneg);
+	if (ret)
+		return ret;
+
+	return hns_mac_set_pauseparam(mac_cb, rx_en, tx_en);
+}
+
+static void hns_ae_get_coalesce_usecs(struct hnae_handle *handle,
+				      u32 *tx_usecs, u32 *rx_usecs)
+{
+	int port;
+
+	port = hns_ae_map_eport_to_dport(handle->eport_id);
+
+	*tx_usecs = hns_rcb_get_coalesce_usecs(
+		hns_ae_get_dsaf_dev(handle->dev),
+		hns_dsaf_get_comm_idx_by_port(port));
+	*rx_usecs = hns_rcb_get_coalesce_usecs(
+		hns_ae_get_dsaf_dev(handle->dev),
+		hns_dsaf_get_comm_idx_by_port(port));
+}
+
+static void hns_ae_get_rx_max_coalesced_frames(struct hnae_handle *handle,
+					       u32 *tx_frames, u32 *rx_frames)
+{
+	int port;
+
+	assert(handle);
+
+	port = hns_ae_map_eport_to_dport(handle->eport_id);
+
+	*tx_frames = hns_rcb_get_coalesced_frames(
+		hns_ae_get_dsaf_dev(handle->dev), port);
+	*rx_frames = hns_rcb_get_coalesced_frames(
+		hns_ae_get_dsaf_dev(handle->dev), port);
+}
+
+static void hns_ae_set_coalesce_usecs(struct hnae_handle *handle,
+				      u32 timeout)
+{
+	int port;
+
+	assert(handle);
+
+	port = hns_ae_map_eport_to_dport(handle->eport_id);
+
+	hns_rcb_set_coalesce_usecs(hns_ae_get_dsaf_dev(handle->dev),
+				   port, timeout);
+}
+
+static int  hns_ae_set_coalesce_frames(struct hnae_handle *handle,
+				       u32 coalesce_frames)
+{
+	int port;
+	int ret;
+
+	assert(handle);
+
+	port = hns_ae_map_eport_to_dport(handle->eport_id);
+
+	ret = hns_rcb_set_coalesced_frames(hns_ae_get_dsaf_dev(handle->dev),
+					   port, coalesce_frames);
+	return ret;
+}
+
+void hns_ae_update_stats(struct hnae_handle *handle,
+			 struct net_device_stats *net_stats)
+{
+	int port;
+	int idx;
+	struct dsaf_device *dsaf_dev;
+	struct hns_mac_cb *mac_cb;
+	struct hns_ppe_cb *ppe_cb;
+	struct hnae_queue *queue;
+	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
+	u64 tx_bytes = 0, rx_bytes = 0, tx_packets = 0, rx_packets = 0;
+	u64 rx_errors = 0, tx_errors = 0, tx_dropped = 0;
+	u64 rx_missed_errors = 0;
+
+	dsaf_dev = hns_ae_get_dsaf_dev(handle->dev);
+	if (!dsaf_dev)
+		return;
+	port = vf_cb->port_index;
+	ppe_cb = hns_get_ppe_cb(handle);
+	mac_cb = hns_get_mac_cb(handle);
+
+	for (idx = 0; idx < handle->q_num; idx++) {
+		queue = handle->qs[idx];
+		hns_rcb_update_stats(queue);
+
+		tx_bytes += queue->tx_ring.stats.tx_bytes;
+		tx_packets += queue->tx_ring.stats.tx_pkts;
+		rx_bytes += queue->rx_ring.stats.rx_bytes;
+		rx_packets += queue->rx_ring.stats.rx_pkts;
+
+		rx_errors += queue->rx_ring.stats.err_pkt_len
+				+ queue->rx_ring.stats.l2_err
+				+ queue->rx_ring.stats.l3l4_csum_err;
+	}
+
+	hns_ppe_update_stats(ppe_cb);
+	rx_missed_errors = ppe_cb->hw_stats.rx_drop_no_buf;
+	tx_errors += ppe_cb->hw_stats.tx_err_checksum
+		+ ppe_cb->hw_stats.tx_err_fifo_empty;
+
+	if (mac_cb->mac_type == HNAE_PORT_SERVICE) {
+		hns_dsaf_update_stats(dsaf_dev, port);
+		/* for port upline direction, i.e., rx. */
+		rx_missed_errors += dsaf_dev->hw_stats[port].bp_drop;
+		rx_missed_errors += dsaf_dev->hw_stats[port].pad_drop;
+		rx_missed_errors += dsaf_dev->hw_stats[port].crc_false;
+
+		/* for port downline direction, i.e., tx. */
+		port = port + DSAF_PPE_INODE_BASE;
+		hns_dsaf_update_stats(dsaf_dev, port);
+		tx_dropped += dsaf_dev->hw_stats[port].bp_drop;
+		tx_dropped += dsaf_dev->hw_stats[port].pad_drop;
+		tx_dropped += dsaf_dev->hw_stats[port].crc_false;
+		tx_dropped += dsaf_dev->hw_stats[port].rslt_drop;
+		tx_dropped += dsaf_dev->hw_stats[port].vlan_drop;
+		tx_dropped += dsaf_dev->hw_stats[port].stp_drop;
+	}
+
+	hns_mac_update_stats(mac_cb);
+	rx_errors += mac_cb->hw_stats.rx_fifo_overrun_err;
+
+	tx_errors += mac_cb->hw_stats.tx_bad_pkts
+		+ mac_cb->hw_stats.tx_fragment_err
+		+ mac_cb->hw_stats.tx_jabber_err
+		+ mac_cb->hw_stats.tx_underrun_err
+		+ mac_cb->hw_stats.tx_crc_err;
+
+	net_stats->tx_bytes = tx_bytes;
+	net_stats->tx_packets = tx_packets;
+	net_stats->rx_bytes = rx_bytes;
+	net_stats->rx_dropped = 0;
+	net_stats->rx_packets = rx_packets;
+	net_stats->rx_errors = rx_errors;
+	net_stats->tx_errors = tx_errors;
+	net_stats->tx_dropped = tx_dropped;
+	net_stats->rx_missed_errors = rx_missed_errors;
+	net_stats->rx_crc_errors = mac_cb->hw_stats.rx_fcs_err;
+	net_stats->rx_frame_errors = mac_cb->hw_stats.rx_align_err;
+	net_stats->rx_fifo_errors = mac_cb->hw_stats.rx_fifo_overrun_err;
+	net_stats->rx_length_errors = mac_cb->hw_stats.rx_len_err;
+	net_stats->multicast = mac_cb->hw_stats.rx_mc_pkts;
+}
+
+void hns_ae_get_stats(struct hnae_handle *handle, u64 *data)
+{
+	int idx;
+	struct hns_mac_cb *mac_cb;
+	struct hns_ppe_cb *ppe_cb;
+	u64 *p = data;
+	struct  hnae_vf_cb *vf_cb;
+
+	if (!handle || !data) {
+		pr_err("hns_ae_get_stats NULL handle or data pointer!\n");
+		return;
+	}
+
+	vf_cb = hns_ae_get_vf_cb(handle);
+	mac_cb = hns_get_mac_cb(handle);
+	ppe_cb = hns_get_ppe_cb(handle);
+
+	for (idx = 0; idx < handle->q_num; idx++) {
+		hns_rcb_get_stats(handle->qs[idx], p);
+		p += hns_rcb_get_ring_sset_count((int)ETH_SS_STATS);
+	}
+
+	hns_ppe_get_stats(ppe_cb, p);
+	p += hns_ppe_get_sset_count((int)ETH_SS_STATS);
+
+	hns_mac_get_stats(mac_cb, p);
+	p += hns_mac_get_sset_count(mac_cb, (int)ETH_SS_STATS);
+
+	if (mac_cb->mac_type == HNAE_PORT_SERVICE)
+		hns_dsaf_get_stats(vf_cb->dsaf_dev, p, vf_cb->port_index);
+}
+
+void hns_ae_get_strings(struct hnae_handle *handle,
+			u32 stringset, u8 *data)
+{
+	int port;
+	int idx;
+	struct hns_mac_cb *mac_cb;
+	struct hns_ppe_cb *ppe_cb;
+	u8 *p = data;
+	struct	hnae_vf_cb *vf_cb;
+
+	assert(handle);
+
+	vf_cb = hns_ae_get_vf_cb(handle);
+	port = vf_cb->port_index;
+	mac_cb = hns_get_mac_cb(handle);
+	ppe_cb = hns_get_ppe_cb(handle);
+
+	for (idx = 0; idx < handle->q_num; idx++) {
+		hns_rcb_get_strings(stringset, p, idx);
+		p += ETH_GSTRING_LEN * hns_rcb_get_ring_sset_count(stringset);
+	}
+
+	hns_ppe_get_strings(ppe_cb, stringset, p);
+	p += ETH_GSTRING_LEN * hns_ppe_get_sset_count(stringset);
+
+	hns_mac_get_strings(mac_cb, stringset, p);
+	p += ETH_GSTRING_LEN * hns_mac_get_sset_count(mac_cb, stringset);
+
+	if (mac_cb->mac_type == HNAE_PORT_SERVICE)
+		hns_dsaf_get_strings(stringset, p, port);
+}
+
+int hns_ae_get_sset_count(struct hnae_handle *handle, int stringset)
+{
+	u32 sset_count = 0;
+	struct hns_mac_cb *mac_cb;
+
+	assert(handle);
+
+	mac_cb = hns_get_mac_cb(handle);
+
+	sset_count += hns_rcb_get_ring_sset_count(stringset) * handle->q_num;
+	sset_count += hns_ppe_get_sset_count(stringset);
+	sset_count += hns_mac_get_sset_count(mac_cb, stringset);
+
+	if (mac_cb->mac_type == HNAE_PORT_SERVICE)
+		sset_count += hns_dsaf_get_sset_count(stringset);
+
+	return sset_count;
+}
+
+static int hns_ae_config_loopback(struct hnae_handle *handle,
+				  enum hnae_loop loop, int en)
+{
+	int ret;
+	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
+
+	switch (loop) {
+	case MAC_INTERNALLOOP_SERDES:
+		ret = hns_mac_config_sds_loopback(vf_cb->mac_cb, en);
+		break;
+	case MAC_INTERNALLOOP_MAC:
+		ret = hns_mac_config_mac_loopback(vf_cb->mac_cb, loop, en);
+		break;
+	default:
+		ret = -EINVAL;
+	}
+	return ret;
+}
+
+void hns_ae_update_led_status(struct hnae_handle *handle)
+{
+	struct hns_mac_cb *mac_cb;
+
+	assert(handle);
+	mac_cb = hns_get_mac_cb(handle);
+	if (!mac_cb->cpld_vaddr)
+		return;
+	hns_set_led_opt(mac_cb);
+}
+
+int hns_ae_cpld_set_led_id(struct hnae_handle *handle,
+			   enum hnae_led_state status)
+{
+	struct hns_mac_cb *mac_cb;
+
+	assert(handle);
+
+	mac_cb = hns_get_mac_cb(handle);
+
+	return hns_cpld_led_set_id(mac_cb, status);
+}
+
+void hns_ae_get_regs(struct hnae_handle *handle, void *data)
+{
+	u32 *p = data;
+	u32 rcb_com_idx;
+	int i;
+	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
+	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
+
+	hns_ppe_get_regs(ppe_cb, p);
+	p += hns_ppe_get_regs_count();
+
+	rcb_com_idx = hns_dsaf_get_comm_idx_by_port(vf_cb->port_index);
+	hns_rcb_get_common_regs(vf_cb->dsaf_dev->rcb_common[rcb_com_idx], p);
+	p += hns_rcb_get_common_regs_count();
+
+	for (i = 0; i < handle->q_num; i++) {
+		hns_rcb_get_ring_regs(handle->qs[i], p);
+		p += hns_rcb_get_ring_regs_count();
+	}
+
+	hns_mac_get_regs(vf_cb->mac_cb, p);
+	p += hns_mac_get_regs_count(vf_cb->mac_cb);
+
+	if (vf_cb->mac_cb->mac_type == HNAE_PORT_SERVICE)
+		hns_dsaf_get_regs(vf_cb->dsaf_dev, vf_cb->port_index, p);
+}
+
+int hns_ae_get_regs_len(struct hnae_handle *handle)
+{
+	u32 total_num;
+	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
+
+	total_num = hns_ppe_get_regs_count();
+	total_num += hns_rcb_get_common_regs_count();
+	total_num += hns_rcb_get_ring_regs_count() * handle->q_num;
+	total_num += hns_mac_get_regs_count(vf_cb->mac_cb);
+
+	if (vf_cb->mac_cb->mac_type == HNAE_PORT_SERVICE)
+		total_num += hns_dsaf_get_regs_count();
+
+	return total_num;
+}
+
+static struct hnae_ae_ops hns_dsaf_ops = {
+	.get_handle = hns_ae_get_handle,
+	.put_handle = hns_ae_put_handle,
+	.init_queue = hns_ae_init_queue,
+	.fini_queue = hns_ae_fini_queue,
+	.start = hns_ae_start,
+	.stop = hns_ae_stop,
+	.reset = hns_ae_reset,
+	.toggle_ring_irq = hns_ae_toggle_ring_irq,
+	.toggle_queue_status = hns_ae_toggle_queue_status,
+	.get_status = hns_ae_get_link_status,
+	.get_info = hns_ae_get_mac_info,
+	.adjust_link = hns_ae_adjust_link,
+	.set_loopback = hns_ae_config_loopback,
+	.get_ring_bdnum_limit = hns_ae_get_ring_bdnum_limit,
+	.get_pauseparam = hns_ae_get_pauseparam,
+	.set_autoneg = hns_ae_set_autoneg,
+	.get_autoneg = hns_ae_get_autoneg,
+	.set_pauseparam = hns_ae_set_pauseparam,
+	.get_coalesce_usecs = hns_ae_get_coalesce_usecs,
+	.get_rx_max_coalesced_frames = hns_ae_get_rx_max_coalesced_frames,
+	.set_coalesce_usecs = hns_ae_set_coalesce_usecs,
+	.set_coalesce_frames = hns_ae_set_coalesce_frames,
+	.set_mac_addr = hns_ae_set_mac_address,
+	.set_mc_addr = hns_ae_set_multicast_one,
+	.set_mtu = hns_ae_set_mtu,
+	.update_stats = hns_ae_update_stats,
+	.get_stats = hns_ae_get_stats,
+	.get_strings = hns_ae_get_strings,
+	.get_sset_count = hns_ae_get_sset_count,
+	.update_led_status = hns_ae_update_led_status,
+	.set_led_id = hns_ae_cpld_set_led_id,
+	.get_regs = hns_ae_get_regs,
+	.get_regs_len = hns_ae_get_regs_len
+};
+
+int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev)
+{
+	struct hnae_ae_dev *ae_dev = &dsaf_dev->ae_dev;
+
+	ae_dev->ops = &hns_dsaf_ops;
+	ae_dev->dev = dsaf_dev->dev;
+
+	return hnae_ae_register(ae_dev, THIS_MODULE);
+}
+
+void hns_dsaf_ae_uninit(struct dsaf_device *dsaf_dev)
+{
+	hnae_ae_unregister(&dsaf_dev->ae_dev);
+}
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
new file mode 100644
index 0000000..b8517b0
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -0,0 +1,704 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/delay.h>
+#include <linux/of_mdio.h>
+#include "hns_dsaf_main.h"
+#include "hns_dsaf_mac.h"
+#include "hns_dsaf_gmac.h"
+
+static const struct mac_stats_string g_gmac_stats_string[] = {
+	{"gmac_rx_octets_total_ok", MAC_STATS_FIELD_OFF(rx_good_bytes)},
+	{"gmac_rx_octets_bad", MAC_STATS_FIELD_OFF(rx_bad_bytes)},
+	{"gmac_rx_uc_pkts", MAC_STATS_FIELD_OFF(rx_uc_pkts)},
+	{"gamc_rx_mc_pkts", MAC_STATS_FIELD_OFF(rx_mc_pkts)},
+	{"gmac_rx_bc_pkts", MAC_STATS_FIELD_OFF(rx_bc_pkts)},
+	{"gmac_rx_pkts_64octets", MAC_STATS_FIELD_OFF(rx_64bytes)},
+	{"gmac_rx_pkts_65to127", MAC_STATS_FIELD_OFF(rx_65to127)},
+	{"gmac_rx_pkts_128to255", MAC_STATS_FIELD_OFF(rx_128to255)},
+	{"gmac_rx_pkts_256to511", MAC_STATS_FIELD_OFF(rx_256to511)},
+	{"gmac_rx_pkts_512to1023", MAC_STATS_FIELD_OFF(rx_512to1023)},
+	{"gmac_rx_pkts_1024to1518", MAC_STATS_FIELD_OFF(rx_1024to1518)},
+	{"gmac_rx_pkts_1519tomax", MAC_STATS_FIELD_OFF(rx_1519tomax)},
+	{"gmac_rx_fcs_errors", MAC_STATS_FIELD_OFF(rx_fcs_err)},
+	{"gmac_rx_tagged", MAC_STATS_FIELD_OFF(rx_vlan_pkts)},
+	{"gmac_rx_data_err", MAC_STATS_FIELD_OFF(rx_data_err)},
+	{"gmac_rx_align_errors", MAC_STATS_FIELD_OFF(rx_align_err)},
+	{"gmac_rx_long_errors", MAC_STATS_FIELD_OFF(rx_oversize)},
+	{"gmac_rx_jabber_errors", MAC_STATS_FIELD_OFF(rx_jabber_err)},
+	{"gmac_rx_pause_maccontrol", MAC_STATS_FIELD_OFF(rx_pfc_tc0)},
+	{"gmac_rx_unknown_maccontrol", MAC_STATS_FIELD_OFF(rx_unknown_ctrl)},
+	{"gmac_rx_very_long_err", MAC_STATS_FIELD_OFF(rx_long_err)},
+	{"gmac_rx_runt_err", MAC_STATS_FIELD_OFF(rx_minto64)},
+	{"gmac_rx_short_err", MAC_STATS_FIELD_OFF(rx_under_min)},
+	{"gmac_rx_filt_pkt", MAC_STATS_FIELD_OFF(rx_filter_bytes)},
+	{"gmac_rx_octets_total_filt", MAC_STATS_FIELD_OFF(rx_filter_pkts)},
+	{"gmac_rx_overrun_cnt", MAC_STATS_FIELD_OFF(rx_fifo_overrun_err)},
+	{"gmac_rx_length_err", MAC_STATS_FIELD_OFF(rx_len_err)},
+	{"gmac_rx_fail_comma", MAC_STATS_FIELD_OFF(rx_comma_err)},
+
+	{"gmac_tx_octets_ok", MAC_STATS_FIELD_OFF(tx_good_bytes)},
+	{"gmac_tx_octets_bad", MAC_STATS_FIELD_OFF(tx_bad_bytes)},
+	{"gmac_tx_uc_pkts", MAC_STATS_FIELD_OFF(tx_uc_pkts)},
+	{"gmac_tx_mc_pkts", MAC_STATS_FIELD_OFF(tx_mc_pkts)},
+	{"gmac_tx_bc_pkts", MAC_STATS_FIELD_OFF(tx_bc_pkts)},
+	{"gmac_tx_pkts_64octets", MAC_STATS_FIELD_OFF(tx_64bytes)},
+	{"gmac_tx_pkts_65to127", MAC_STATS_FIELD_OFF(tx_65to127)},
+	{"gmac_tx_pkts_128to255", MAC_STATS_FIELD_OFF(tx_128to255)},
+	{"gmac_tx_pkts_256to511", MAC_STATS_FIELD_OFF(tx_256to511)},
+	{"gmac_tx_pkts_512to1023", MAC_STATS_FIELD_OFF(tx_512to1023)},
+	{"gmac_tx_pkts_1024to1518", MAC_STATS_FIELD_OFF(tx_1024to1518)},
+	{"gmac_tx_pkts_1519tomax", MAC_STATS_FIELD_OFF(tx_1519tomax)},
+	{"gmac_tx_excessive_length_drop", MAC_STATS_FIELD_OFF(tx_jabber_err)},
+	{"gmac_tx_underrun", MAC_STATS_FIELD_OFF(tx_underrun_err)},
+	{"gmac_tx_tagged", MAC_STATS_FIELD_OFF(tx_vlan)},
+	{"gmac_tx_crc_error", MAC_STATS_FIELD_OFF(tx_crc_err)},
+	{"gmac_tx_pause_frames", MAC_STATS_FIELD_OFF(tx_pfc_tc0)}
+};
+
+static void hns_gmac_enable(void *mac_drv, enum mac_commom_mode mode)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	/*enable GE rX/tX */
+	if ((mode == MAC_COMM_MODE_TX) || (mode == MAC_COMM_MODE_RX_AND_TX))
+		dsaf_set_dev_bit(drv, GMAC_PORT_EN_REG, GMAC_PORT_TX_EN_B, 1);
+
+	if ((mode == MAC_COMM_MODE_RX) || (mode == MAC_COMM_MODE_RX_AND_TX))
+		dsaf_set_dev_bit(drv, GMAC_PORT_EN_REG, GMAC_PORT_RX_EN_B, 1);
+}
+
+static void hns_gmac_disable(void *mac_drv, enum mac_commom_mode mode)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	/*disable GE rX/tX */
+	if ((mode == MAC_COMM_MODE_TX) || (mode == MAC_COMM_MODE_RX_AND_TX))
+		dsaf_set_dev_bit(drv, GMAC_PORT_EN_REG, GMAC_PORT_TX_EN_B, 0);
+
+	if ((mode == MAC_COMM_MODE_RX) || (mode == MAC_COMM_MODE_RX_AND_TX))
+		dsaf_set_dev_bit(drv, GMAC_PORT_EN_REG, GMAC_PORT_RX_EN_B, 0);
+}
+
+/**
+*hns_gmac_get_en - get port enable
+*@mac_drv:mac device
+*@rx:rx enable
+*@tx:tx enable
+*/
+static void hns_gmac_get_en(void *mac_drv, u32 *rx, u32 *tx)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	u32 porten;
+
+	porten = dsaf_read_dev(drv, GMAC_PORT_EN_REG);
+	*tx = dsaf_get_bit(porten, GMAC_PORT_TX_EN_B);
+	*rx = dsaf_get_bit(porten, GMAC_PORT_RX_EN_B);
+}
+
+static void hns_gmac_free(void *mac_drv)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	struct dsaf_device *dsaf_dev
+		= (struct dsaf_device *)dev_get_drvdata(drv->dev);
+
+	u32 mac_id = drv->mac_id;
+
+	hns_dsaf_ge_srst_by_port(dsaf_dev, mac_id, 0);
+}
+
+static void hns_gmac_set_tx_auto_pause_frames(void *mac_drv, u16 newval)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	dsaf_set_dev_field(drv, GMAC_FC_TX_TIMER_REG, GMAC_FC_TX_TIMER_M,
+			   GMAC_FC_TX_TIMER_S, newval);
+}
+
+static void hns_gmac_get_tx_auto_pause_frames(void *mac_drv, u16 *newval)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	*newval = dsaf_get_dev_field(drv, GMAC_FC_TX_TIMER_REG,
+				     GMAC_FC_TX_TIMER_M, GMAC_FC_TX_TIMER_S);
+}
+
+static void hns_gmac_set_rx_auto_pause_frames(void *mac_drv, u32 newval)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	dsaf_set_dev_bit(drv, GMAC_PAUSE_EN_REG,
+			 GMAC_PAUSE_EN_RX_FDFC_B, !!newval);
+}
+
+static void hns_gmac_config_max_frame_length(void *mac_drv, u16 newval)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	dsaf_set_dev_field(drv, GMAC_MAX_FRM_SIZE_REG, GMAC_MAX_FRM_SIZE_M,
+			   GMAC_MAX_FRM_SIZE_S, newval);
+
+	dsaf_set_dev_field(drv, GAMC_RX_MAX_FRAME, GMAC_MAX_FRM_SIZE_M,
+			   GMAC_MAX_FRM_SIZE_S, newval);
+}
+
+static void hns_gmac_config_an_mode(void *mac_drv, u8 newval)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	dsaf_set_dev_bit(drv, GMAC_TRANSMIT_CONTROL_REG,
+			 GMAC_TX_AN_EN_B, !!newval);
+}
+
+static void hns_gmac_tx_loop_pkt_dis(void *mac_drv)
+{
+	u32 tx_loop_pkt_pri;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	tx_loop_pkt_pri = dsaf_read_dev(drv, GMAC_TX_LOOP_PKT_PRI_REG);
+	dsaf_set_bit(tx_loop_pkt_pri, GMAC_TX_LOOP_PKT_EN_B, 1);
+	dsaf_set_bit(tx_loop_pkt_pri, GMAC_TX_LOOP_PKT_HIG_PRI_B, 0);
+	dsaf_write_dev(drv, GMAC_TX_LOOP_PKT_PRI_REG, tx_loop_pkt_pri);
+}
+
+static void hns_gmac_set_duplex_type(void *mac_drv, u8 newval)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	dsaf_set_dev_bit(drv, GMAC_DUPLEX_TYPE_REG,
+			 GMAC_DUPLEX_TYPE_B, !!newval);
+}
+
+static void hns_gmac_get_duplex_type(void *mac_drv,
+				     enum hns_gmac_duplex_mdoe *duplex_mode)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	*duplex_mode = (enum hns_gmac_duplex_mdoe)dsaf_get_dev_bit(
+		drv, GMAC_DUPLEX_TYPE_REG, GMAC_DUPLEX_TYPE_B);
+}
+
+static void hns_gmac_get_port_mode(void *mac_drv, enum hns_port_mode *port_mode)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	*port_mode = (enum hns_port_mode)dsaf_get_dev_field(
+		drv, GMAC_PORT_MODE_REG, GMAC_PORT_MODE_M, GMAC_PORT_MODE_S);
+}
+
+static void hns_gmac_port_mode_get(void *mac_drv,
+				   struct hns_gmac_port_mode_cfg *port_mode)
+{
+	u32 tx_ctrl;
+	u32 recv_ctrl;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	port_mode->port_mode = (enum hns_port_mode)dsaf_get_dev_field(
+		drv, GMAC_PORT_MODE_REG, GMAC_PORT_MODE_M, GMAC_PORT_MODE_S);
+
+	tx_ctrl = dsaf_read_dev(drv, GMAC_TRANSMIT_CONTROL_REG);
+	recv_ctrl = dsaf_read_dev(drv, GMAC_RECV_CONTROL_REG);
+
+	port_mode->max_frm_size =
+		dsaf_get_dev_field(drv, GMAC_MAX_FRM_SIZE_REG,
+				   GMAC_MAX_FRM_SIZE_M, GMAC_MAX_FRM_SIZE_S);
+	port_mode->short_runts_thr =
+		dsaf_get_dev_field(drv, GMAC_SHORT_RUNTS_THR_REG,
+				   GMAC_SHORT_RUNTS_THR_M,
+				   GMAC_SHORT_RUNTS_THR_S);
+
+	port_mode->pad_enable = dsaf_get_bit(tx_ctrl, GMAC_TX_PAD_EN_B);
+	port_mode->crc_add = dsaf_get_bit(tx_ctrl, GMAC_TX_CRC_ADD_B);
+	port_mode->an_enable = dsaf_get_bit(tx_ctrl, GMAC_TX_AN_EN_B);
+
+	port_mode->runt_pkt_en =
+		dsaf_get_bit(recv_ctrl, GMAC_RECV_CTRL_RUNT_PKT_EN_B);
+	port_mode->strip_pad_en =
+		dsaf_get_bit(recv_ctrl, GMAC_RECV_CTRL_STRIP_PAD_EN_B);
+}
+
+static void hns_gmac_pause_frm_cfg(void *mac_drv, u32 rx_pause_en,
+				   u32 tx_pause_en)
+{
+	u32 pause_en;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	pause_en = dsaf_read_dev(drv, GMAC_PAUSE_EN_REG);
+	dsaf_set_bit(pause_en, GMAC_PAUSE_EN_RX_FDFC_B, !!rx_pause_en);
+	dsaf_set_bit(pause_en, GMAC_PAUSE_EN_TX_FDFC_B, !!tx_pause_en);
+	dsaf_write_dev(drv, GMAC_PAUSE_EN_REG, pause_en);
+}
+
+static void hns_gmac_get_pausefrm_cfg(void *mac_drv, u32 *rx_pause_en,
+				      u32 *tx_pause_en)
+{
+	u32 pause_en;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	pause_en = dsaf_read_dev(drv, GMAC_PAUSE_EN_REG);
+
+	*rx_pause_en = dsaf_get_bit(pause_en, GMAC_PAUSE_EN_RX_FDFC_B);
+	*tx_pause_en = dsaf_get_bit(pause_en, GMAC_PAUSE_EN_TX_FDFC_B);
+}
+
+static int hns_gmac_adjust_link(void *mac_drv, enum mac_speed speed,
+				u32 full_duplex)
+{
+	u32 tx_ctrl;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	dsaf_set_dev_bit(drv, GMAC_DUPLEX_TYPE_REG,
+			 GMAC_DUPLEX_TYPE_B, !!full_duplex);
+
+	switch (speed) {
+	case MAC_SPEED_10:
+		dsaf_set_dev_field(
+			drv, GMAC_PORT_MODE_REG,
+			GMAC_PORT_MODE_M, GMAC_PORT_MODE_S, 0x6);
+		break;
+	case MAC_SPEED_100:
+		dsaf_set_dev_field(
+			drv, GMAC_PORT_MODE_REG,
+			GMAC_PORT_MODE_M, GMAC_PORT_MODE_S, 0x7);
+		break;
+	case MAC_SPEED_1000:
+		dsaf_set_dev_field(
+			drv, GMAC_PORT_MODE_REG,
+			GMAC_PORT_MODE_M, GMAC_PORT_MODE_S, 0x8);
+		break;
+	default:
+		dev_err(drv->dev,
+			"hns_gmac_adjust_link fail, speed%d mac%d\n",
+			speed, drv->mac_id);
+		return -EINVAL;
+	}
+
+	tx_ctrl = dsaf_read_dev(drv, GMAC_TRANSMIT_CONTROL_REG);
+	dsaf_set_bit(tx_ctrl, GMAC_TX_PAD_EN_B, 1);
+	dsaf_set_bit(tx_ctrl, GMAC_TX_CRC_ADD_B, 1);
+	dsaf_write_dev(drv, GMAC_TRANSMIT_CONTROL_REG, tx_ctrl);
+
+	dsaf_set_dev_bit(drv, GMAC_MODE_CHANGE_EN_REG,
+			 GMAC_MODE_CHANGE_EB_B, 1);
+
+	return 0;
+}
+
+static void hns_gmac_init(void *mac_drv)
+{
+	u32 port;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	struct dsaf_device *dsaf_dev
+		= (struct dsaf_device *)dev_get_drvdata(drv->dev);
+
+	port = drv->mac_id;
+
+	hns_dsaf_ge_srst_by_port(dsaf_dev, port, 0);
+	mdelay(10);
+	hns_dsaf_ge_srst_by_port(dsaf_dev, port, 1);
+	mdelay(10);
+	hns_gmac_disable(mac_drv, MAC_COMM_MODE_RX_AND_TX);
+	hns_gmac_tx_loop_pkt_dis(mac_drv);
+}
+
+void hns_gmac_update_stats(void *mac_drv)
+{
+	struct mac_hw_stats *hw_stats = NULL;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	hw_stats = &drv->mac_cb->hw_stats;
+
+	/* RX */
+	hw_stats->rx_good_bytes
+		+= dsaf_read_dev(drv, GMAC_RX_OCTETS_TOTAL_OK_REG);
+	hw_stats->rx_bad_bytes
+		+= dsaf_read_dev(drv, GMAC_RX_OCTETS_BAD_REG);
+	hw_stats->rx_uc_pkts += dsaf_read_dev(drv, GMAC_RX_UC_PKTS_REG);
+	hw_stats->rx_mc_pkts += dsaf_read_dev(drv, GMAC_RX_MC_PKTS_REG);
+	hw_stats->rx_bc_pkts += dsaf_read_dev(drv, GMAC_RX_BC_PKTS_REG);
+	hw_stats->rx_64bytes
+		+= dsaf_read_dev(drv, GMAC_RX_PKTS_64OCTETS_REG);
+	hw_stats->rx_65to127
+		+= dsaf_read_dev(drv, GMAC_RX_PKTS_65TO127OCTETS_REG);
+	hw_stats->rx_128to255
+		+= dsaf_read_dev(drv, GMAC_RX_PKTS_128TO255OCTETS_REG);
+	hw_stats->rx_256to511
+		+= dsaf_read_dev(drv, GMAC_RX_PKTS_255TO511OCTETS_REG);
+	hw_stats->rx_512to1023
+		+= dsaf_read_dev(drv, GMAC_RX_PKTS_512TO1023OCTETS_REG);
+	hw_stats->rx_1024to1518
+		+= dsaf_read_dev(drv, GMAC_RX_PKTS_1024TO1518OCTETS_REG);
+	hw_stats->rx_1519tomax
+		+= dsaf_read_dev(drv, GMAC_RX_PKTS_1519TOMAXOCTETS_REG);
+	hw_stats->rx_fcs_err += dsaf_read_dev(drv, GMAC_RX_FCS_ERRORS_REG);
+	hw_stats->rx_vlan_pkts += dsaf_read_dev(drv, GMAC_RX_TAGGED_REG);
+	hw_stats->rx_data_err += dsaf_read_dev(drv, GMAC_RX_DATA_ERR_REG);
+	hw_stats->rx_align_err
+		+= dsaf_read_dev(drv, GMAC_RX_ALIGN_ERRORS_REG);
+	hw_stats->rx_oversize
+		+= dsaf_read_dev(drv, GMAC_RX_LONG_ERRORS_REG);
+	hw_stats->rx_jabber_err
+		+= dsaf_read_dev(drv, GMAC_RX_JABBER_ERRORS_REG);
+	hw_stats->rx_pfc_tc0
+		+= dsaf_read_dev(drv, GMAC_RX_PAUSE_MACCTRL_FRAM_REG);
+	hw_stats->rx_unknown_ctrl
+		+= dsaf_read_dev(drv, GMAC_RX_UNKNOWN_MACCTRL_FRAM_REG);
+	hw_stats->rx_long_err
+		+= dsaf_read_dev(drv, GMAC_RX_VERY_LONG_ERR_CNT_REG);
+	hw_stats->rx_minto64
+		+= dsaf_read_dev(drv, GMAC_RX_RUNT_ERR_CNT_REG);
+	hw_stats->rx_under_min
+		+= dsaf_read_dev(drv, GMAC_RX_SHORT_ERR_CNT_REG);
+	hw_stats->rx_filter_pkts
+		+= dsaf_read_dev(drv, GMAC_RX_FILT_PKT_CNT_REG);
+	hw_stats->rx_filter_bytes
+		+= dsaf_read_dev(drv, GMAC_RX_OCTETS_TOTAL_FILT_REG);
+	hw_stats->rx_fifo_overrun_err
+		+= dsaf_read_dev(drv, GMAC_RX_OVERRUN_CNT_REG);
+	hw_stats->rx_len_err
+		+= dsaf_read_dev(drv, GMAC_RX_LENGTHFIELD_ERR_CNT_REG);
+	hw_stats->rx_comma_err
+		+= dsaf_read_dev(drv, GMAC_RX_FAIL_COMMA_CNT_REG);
+
+	/* TX */
+	hw_stats->tx_good_bytes
+		+= dsaf_read_dev(drv, GMAC_OCTETS_TRANSMITTED_OK_REG);
+	hw_stats->tx_bad_bytes
+		+= dsaf_read_dev(drv, GMAC_OCTETS_TRANSMITTED_BAD_REG);
+	hw_stats->tx_uc_pkts += dsaf_read_dev(drv, GMAC_TX_UC_PKTS_REG);
+	hw_stats->tx_mc_pkts += dsaf_read_dev(drv, GMAC_TX_MC_PKTS_REG);
+	hw_stats->tx_bc_pkts += dsaf_read_dev(drv, GMAC_TX_BC_PKTS_REG);
+	hw_stats->tx_64bytes
+		+= dsaf_read_dev(drv, GMAC_TX_PKTS_64OCTETS_REG);
+	hw_stats->tx_65to127
+		+= dsaf_read_dev(drv, GMAC_TX_PKTS_65TO127OCTETS_REG);
+	hw_stats->tx_128to255
+		+= dsaf_read_dev(drv, GMAC_TX_PKTS_128TO255OCTETS_REG);
+	hw_stats->tx_256to511
+		+= dsaf_read_dev(drv, GMAC_TX_PKTS_255TO511OCTETS_REG);
+	hw_stats->tx_512to1023
+		+= dsaf_read_dev(drv, GMAC_TX_PKTS_512TO1023OCTETS_REG);
+	hw_stats->tx_1024to1518
+		+= dsaf_read_dev(drv, GMAC_TX_PKTS_1024TO1518OCTETS_REG);
+	hw_stats->tx_1519tomax
+		+= dsaf_read_dev(drv, GMAC_TX_PKTS_1519TOMAXOCTETS_REG);
+	hw_stats->tx_jabber_err
+		+= dsaf_read_dev(drv, GMAC_TX_EXCESSIVE_LENGTH_DROP_REG);
+	hw_stats->tx_underrun_err
+		+= dsaf_read_dev(drv, GMAC_TX_UNDERRUN_REG);
+	hw_stats->tx_vlan += dsaf_read_dev(drv, GMAC_TX_TAGGED_REG);
+	hw_stats->tx_crc_err += dsaf_read_dev(drv, GMAC_TX_CRC_ERROR_REG);
+	hw_stats->tx_pfc_tc0
+		+= dsaf_read_dev(drv, GMAC_TX_PAUSE_FRAMES_REG);
+}
+
+static void hns_gmac_set_mac_addr(void *mac_drv, char *mac_addr)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	if (drv->mac_id >= DSAF_SERVICE_NW_NUM) {
+		u32 high_val = mac_addr[1] | (mac_addr[0] << 8);
+
+		u32 low_val = mac_addr[5] | (mac_addr[4] << 8)
+			| (mac_addr[3] << 16) | (mac_addr[2] << 24);
+		dsaf_write_dev(drv, GMAC_STATION_ADDR_LOW_2_REG, low_val);
+		dsaf_write_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG, high_val);
+	}
+}
+
+static int hns_gmac_config_loopback(void *mac_drv, enum hnae_loop loop_mode,
+				    u8 enable)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	switch (loop_mode) {
+	case MAC_INTERNALLOOP_MAC:
+		dsaf_set_dev_bit(drv, GMAC_LOOP_REG, GMAC_LP_REG_CF2MI_LP_EN_B,
+				 !!enable);
+		break;
+	default:
+		dev_err(drv->dev, "loop_mode error\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static void hns_gmac_config_pad_and_crc(void *mac_drv, u8 newval)
+{
+	u32 tx_ctrl;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	tx_ctrl = dsaf_read_dev(drv, GMAC_TRANSMIT_CONTROL_REG);
+	dsaf_set_bit(tx_ctrl, GMAC_TX_PAD_EN_B, !!newval);
+	dsaf_set_bit(tx_ctrl, GMAC_TX_CRC_ADD_B, !!newval);
+	dsaf_write_dev(drv, GMAC_TRANSMIT_CONTROL_REG, tx_ctrl);
+}
+
+static void hns_gmac_get_id(void *mac_drv, u8 *mac_id)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	*mac_id = drv->mac_id;
+}
+
+static void hns_gmac_get_info(void *mac_drv, struct mac_info *mac_info)
+{
+	enum hns_gmac_duplex_mdoe duplex;
+	enum hns_port_mode speed;
+	u32 rx_pause;
+	u32 tx_pause;
+	u32 rx;
+	u32 tx;
+	u16 fc_tx_timer;
+	struct hns_gmac_port_mode_cfg port_mode = { GMAC_10M_MII, 0 };
+
+	hns_gmac_port_mode_get(mac_drv, &port_mode);
+	mac_info->pad_and_crc_en = port_mode.crc_add && port_mode.pad_enable;
+	mac_info->auto_neg = port_mode.an_enable;
+
+	hns_gmac_get_tx_auto_pause_frames(mac_drv, &fc_tx_timer);
+	mac_info->tx_pause_time = fc_tx_timer;
+
+	hns_gmac_get_en(mac_drv, &rx, &tx);
+	mac_info->port_en = rx && tx;
+
+	hns_gmac_get_duplex_type(mac_drv, &duplex);
+	mac_info->duplex = duplex;
+
+	hns_gmac_get_port_mode(mac_drv, &speed);
+	switch (speed) {
+	case GMAC_10M_SGMII:
+		mac_info->speed = MAC_SPEED_10;
+		break;
+	case GMAC_100M_SGMII:
+		mac_info->speed = MAC_SPEED_100;
+		break;
+	case GMAC_1000M_SGMII:
+		mac_info->speed = MAC_SPEED_1000;
+		break;
+	default:
+		mac_info->speed = 0;
+		break;
+	}
+
+	hns_gmac_get_pausefrm_cfg(mac_drv, &rx_pause, &tx_pause);
+	mac_info->rx_pause_en = rx_pause;
+	mac_info->tx_pause_en = tx_pause;
+}
+
+static void hns_gmac_autoneg_stat(void *mac_drv, u32 *enable)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	*enable = dsaf_get_dev_bit(drv, GMAC_TRANSMIT_CONTROL_REG,
+				   GMAC_TX_AN_EN_B);
+}
+
+static void hns_gmac_get_link_status(void *mac_drv, u32 *link_stat)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	*link_stat = dsaf_get_dev_bit(drv, GMAC_AN_NEG_STATE_REG,
+				      GMAC_AN_NEG_STAT_RX_SYNC_OK_B);
+}
+
+static void hns_gmac_get_regs(void *mac_drv, void *data)
+{
+	u32 *regs = data;
+	int i;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	/* base config registers */
+	regs[0] = dsaf_read_dev(drv, GMAC_DUPLEX_TYPE_REG);
+	regs[1] = dsaf_read_dev(drv, GMAC_FD_FC_TYPE_REG);
+	regs[2] = dsaf_read_dev(drv, GMAC_FC_TX_TIMER_REG);
+	regs[3] = dsaf_read_dev(drv, GMAC_FD_FC_ADDR_LOW_REG);
+	regs[4] = dsaf_read_dev(drv, GMAC_FD_FC_ADDR_HIGH_REG);
+	regs[5] = dsaf_read_dev(drv, GMAC_IPG_TX_TIMER_REG);
+	regs[6] = dsaf_read_dev(drv, GMAC_PAUSE_THR_REG);
+	regs[7] = dsaf_read_dev(drv, GMAC_MAX_FRM_SIZE_REG);
+	regs[8] = dsaf_read_dev(drv, GMAC_PORT_MODE_REG);
+	regs[9] = dsaf_read_dev(drv, GMAC_PORT_EN_REG);
+	regs[10] = dsaf_read_dev(drv, GMAC_PAUSE_EN_REG);
+	regs[11] = dsaf_read_dev(drv, GMAC_SHORT_RUNTS_THR_REG);
+	regs[12] = dsaf_read_dev(drv, GMAC_AN_NEG_STATE_REG);
+	regs[13] = dsaf_read_dev(drv, GMAC_TX_LOCAL_PAGE_REG);
+	regs[14] = dsaf_read_dev(drv, GMAC_TRANSMIT_CONTROL_REG);
+	regs[15] = dsaf_read_dev(drv, GMAC_REC_FILT_CONTROL_REG);
+	regs[16] = dsaf_read_dev(drv, GMAC_PTP_CONFIG_REG);
+
+	/* rx static registers */
+	regs[17] = dsaf_read_dev(drv, GMAC_RX_OCTETS_TOTAL_OK_REG);
+	regs[18] = dsaf_read_dev(drv, GMAC_RX_OCTETS_BAD_REG);
+	regs[19] = dsaf_read_dev(drv, GMAC_RX_UC_PKTS_REG);
+	regs[20] = dsaf_read_dev(drv, GMAC_RX_MC_PKTS_REG);
+	regs[21] = dsaf_read_dev(drv, GMAC_RX_BC_PKTS_REG);
+	regs[22] = dsaf_read_dev(drv, GMAC_RX_PKTS_64OCTETS_REG);
+	regs[23] = dsaf_read_dev(drv, GMAC_RX_PKTS_65TO127OCTETS_REG);
+	regs[24] = dsaf_read_dev(drv, GMAC_RX_PKTS_128TO255OCTETS_REG);
+	regs[25] = dsaf_read_dev(drv, GMAC_RX_PKTS_255TO511OCTETS_REG);
+	regs[26] = dsaf_read_dev(drv, GMAC_RX_PKTS_512TO1023OCTETS_REG);
+	regs[27] = dsaf_read_dev(drv, GMAC_RX_PKTS_1024TO1518OCTETS_REG);
+	regs[28] = dsaf_read_dev(drv, GMAC_RX_PKTS_1519TOMAXOCTETS_REG);
+	regs[29] = dsaf_read_dev(drv, GMAC_RX_FCS_ERRORS_REG);
+	regs[30] = dsaf_read_dev(drv, GMAC_RX_TAGGED_REG);
+	regs[31] = dsaf_read_dev(drv, GMAC_RX_DATA_ERR_REG);
+	regs[32] = dsaf_read_dev(drv, GMAC_RX_ALIGN_ERRORS_REG);
+	regs[33] = dsaf_read_dev(drv, GMAC_RX_LONG_ERRORS_REG);
+	regs[34] = dsaf_read_dev(drv, GMAC_RX_JABBER_ERRORS_REG);
+	regs[35] = dsaf_read_dev(drv, GMAC_RX_PAUSE_MACCTRL_FRAM_REG);
+	regs[36] = dsaf_read_dev(drv, GMAC_RX_UNKNOWN_MACCTRL_FRAM_REG);
+	regs[37] = dsaf_read_dev(drv, GMAC_RX_VERY_LONG_ERR_CNT_REG);
+	regs[38] = dsaf_read_dev(drv, GMAC_RX_RUNT_ERR_CNT_REG);
+	regs[39] = dsaf_read_dev(drv, GMAC_RX_SHORT_ERR_CNT_REG);
+	regs[40] = dsaf_read_dev(drv, GMAC_RX_FILT_PKT_CNT_REG);
+	regs[41] = dsaf_read_dev(drv, GMAC_RX_OCTETS_TOTAL_FILT_REG);
+
+	/* tx static registers */
+	regs[42] = dsaf_read_dev(drv, GMAC_OCTETS_TRANSMITTED_OK_REG);
+	regs[43] = dsaf_read_dev(drv, GMAC_OCTETS_TRANSMITTED_BAD_REG);
+	regs[44] = dsaf_read_dev(drv, GMAC_TX_UC_PKTS_REG);
+	regs[45] = dsaf_read_dev(drv, GMAC_TX_MC_PKTS_REG);
+	regs[46] = dsaf_read_dev(drv, GMAC_TX_BC_PKTS_REG);
+	regs[47] = dsaf_read_dev(drv, GMAC_TX_PKTS_64OCTETS_REG);
+	regs[48] = dsaf_read_dev(drv, GMAC_TX_PKTS_65TO127OCTETS_REG);
+	regs[49] = dsaf_read_dev(drv, GMAC_TX_PKTS_128TO255OCTETS_REG);
+	regs[50] = dsaf_read_dev(drv, GMAC_TX_PKTS_255TO511OCTETS_REG);
+	regs[51] = dsaf_read_dev(drv, GMAC_TX_PKTS_512TO1023OCTETS_REG);
+	regs[52] = dsaf_read_dev(drv, GMAC_TX_PKTS_1024TO1518OCTETS_REG);
+	regs[53] = dsaf_read_dev(drv, GMAC_TX_PKTS_1519TOMAXOCTETS_REG);
+	regs[54] = dsaf_read_dev(drv, GMAC_TX_EXCESSIVE_LENGTH_DROP_REG);
+	regs[55] = dsaf_read_dev(drv, GMAC_TX_UNDERRUN_REG);
+	regs[56] = dsaf_read_dev(drv, GMAC_TX_TAGGED_REG);
+	regs[57] = dsaf_read_dev(drv, GMAC_TX_CRC_ERROR_REG);
+	regs[58] = dsaf_read_dev(drv, GMAC_TX_PAUSE_FRAMES_REG);
+
+	regs[59] = dsaf_read_dev(drv, GAMC_RX_MAX_FRAME);
+	regs[60] = dsaf_read_dev(drv, GMAC_LINE_LOOP_BACK_REG);
+	regs[61] = dsaf_read_dev(drv, GMAC_CF_CRC_STRIP_REG);
+	regs[62] = dsaf_read_dev(drv, GMAC_MODE_CHANGE_EN_REG);
+	regs[63] = dsaf_read_dev(drv, GMAC_SIXTEEN_BIT_CNTR_REG);
+	regs[64] = dsaf_read_dev(drv, GMAC_LD_LINK_COUNTER_REG);
+	regs[65] = dsaf_read_dev(drv, GMAC_LOOP_REG);
+	regs[66] = dsaf_read_dev(drv, GMAC_RECV_CONTROL_REG);
+	regs[67] = dsaf_read_dev(drv, GMAC_VLAN_CODE_REG);
+	regs[68] = dsaf_read_dev(drv, GMAC_RX_OVERRUN_CNT_REG);
+	regs[69] = dsaf_read_dev(drv, GMAC_RX_LENGTHFIELD_ERR_CNT_REG);
+	regs[70] = dsaf_read_dev(drv, GMAC_RX_FAIL_COMMA_CNT_REG);
+
+	regs[71] = dsaf_read_dev(drv, GMAC_STATION_ADDR_LOW_0_REG);
+	regs[72] = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_0_REG);
+	regs[73] = dsaf_read_dev(drv, GMAC_STATION_ADDR_LOW_1_REG);
+	regs[74] = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_1_REG);
+	regs[75] = dsaf_read_dev(drv, GMAC_STATION_ADDR_LOW_2_REG);
+	regs[76] = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_2_REG);
+	regs[77] = dsaf_read_dev(drv, GMAC_STATION_ADDR_LOW_3_REG);
+	regs[78] = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_3_REG);
+	regs[79] = dsaf_read_dev(drv, GMAC_STATION_ADDR_LOW_4_REG);
+	regs[80] = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_4_REG);
+	regs[81] = dsaf_read_dev(drv, GMAC_STATION_ADDR_LOW_5_REG);
+	regs[82] = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_5_REG);
+	regs[83] = dsaf_read_dev(drv, GMAC_STATION_ADDR_LOW_MSK_0_REG);
+	regs[84] = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_MSK_0_REG);
+	regs[85] = dsaf_read_dev(drv, GMAC_STATION_ADDR_LOW_MSK_1_REG);
+	regs[86] = dsaf_read_dev(drv, GMAC_STATION_ADDR_HIGH_MSK_1_REG);
+	regs[87] = dsaf_read_dev(drv, GMAC_MAC_SKIP_LEN_REG);
+	regs[88] = dsaf_read_dev(drv, GMAC_TX_LOOP_PKT_PRI_REG);
+
+	/* mark end of mac regs */
+	for (i = 89; i < 96; i++)
+		regs[i] = 0xaaaaaaaa;
+}
+
+static void hns_gmac_get_stats(void *mac_drv, u64 *data)
+{
+	u32 i;
+	u64 *buf = data;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	struct mac_hw_stats *hw_stats = NULL;
+
+	hw_stats = &drv->mac_cb->hw_stats;
+
+	for (i = 0; i < ARRAY_SIZE(g_gmac_stats_string); i++) {
+		buf[i] = DSAF_STATS_READ(hw_stats,
+			g_gmac_stats_string[i].offset);
+	}
+}
+
+static void hns_gmac_get_strings(u32 stringset, u8 *data)
+{
+	char *buff = (char *)data;
+	u32 i;
+
+	if (stringset != ETH_SS_STATS)
+		return;
+
+	for (i = 0; i < ARRAY_SIZE(g_gmac_stats_string); i++) {
+		snprintf(buff, ETH_GSTRING_LEN, g_gmac_stats_string[i].desc);
+		buff = buff + ETH_GSTRING_LEN;
+	}
+}
+
+static int hns_gmac_get_sset_count(int stringset)
+{
+	if (stringset == ETH_SS_STATS)
+		return ARRAY_SIZE(g_gmac_stats_string);
+
+	return 0;
+}
+
+static int hns_gmac_get_regs_count(void)
+{
+	return ETH_GMAC_DUMP_NUM;
+}
+
+void *hns_gmac_config(struct hns_mac_cb *mac_cb, struct mac_params *mac_param)
+{
+	struct mac_driver *mac_drv;
+
+	mac_drv = devm_kzalloc(mac_cb->dev, sizeof(*mac_drv), GFP_KERNEL);
+	if (!mac_drv)
+		return NULL;
+
+	mac_drv->mac_init = hns_gmac_init;
+	mac_drv->mac_enable = hns_gmac_enable;
+	mac_drv->mac_disable = hns_gmac_disable;
+	mac_drv->mac_free = hns_gmac_free;
+	mac_drv->adjust_link = hns_gmac_adjust_link;
+	mac_drv->set_tx_auto_pause_frames = hns_gmac_set_tx_auto_pause_frames;
+	mac_drv->config_max_frame_length = hns_gmac_config_max_frame_length;
+	mac_drv->mac_pausefrm_cfg = hns_gmac_pause_frm_cfg;
+
+	mac_drv->mac_id = mac_param->mac_id;
+	mac_drv->mac_mode = mac_param->mac_mode;
+	mac_drv->io_base = mac_param->vaddr;
+	mac_drv->dev = mac_param->dev;
+	mac_drv->mac_cb = mac_cb;
+
+	mac_drv->set_mac_addr = hns_gmac_set_mac_addr;
+	mac_drv->set_an_mode = hns_gmac_config_an_mode;
+	mac_drv->config_loopback = hns_gmac_config_loopback;
+	mac_drv->config_pad_and_crc = hns_gmac_config_pad_and_crc;
+	mac_drv->config_half_duplex = hns_gmac_set_duplex_type;
+	mac_drv->set_rx_ignore_pause_frames = hns_gmac_set_rx_auto_pause_frames;
+	mac_drv->mac_get_id = hns_gmac_get_id;
+	mac_drv->get_info = hns_gmac_get_info;
+	mac_drv->autoneg_stat = hns_gmac_autoneg_stat;
+	mac_drv->get_pause_enable = hns_gmac_get_pausefrm_cfg;
+	mac_drv->get_link_status = hns_gmac_get_link_status;
+	mac_drv->get_regs = hns_gmac_get_regs;
+	mac_drv->get_regs_count = hns_gmac_get_regs_count;
+	mac_drv->get_ethtool_stats = hns_gmac_get_stats;
+	mac_drv->get_sset_count = hns_gmac_get_sset_count;
+	mac_drv->get_strings = hns_gmac_get_strings;
+	mac_drv->update_stats = hns_gmac_update_stats;
+
+	return (void *)mac_drv;
+}
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.h
new file mode 100644
index 0000000..44fe301
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.h
@@ -0,0 +1,45 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_GMAC_H
+#define _HNS_GMAC_H
+
+#include "hns_dsaf_mac.h"
+
+enum hns_port_mode {
+	GMAC_10M_MII = 0,
+	GMAC_100M_MII,
+	GMAC_1000M_GMII,
+	GMAC_10M_RGMII,
+	GMAC_100M_RGMII,
+	GMAC_1000M_RGMII,
+	GMAC_10M_SGMII,
+	GMAC_100M_SGMII,
+	GMAC_1000M_SGMII,
+	GMAC_10000M_SGMII	/* 10GE */
+};
+
+enum hns_gmac_duplex_mdoe {
+	GMAC_HALF_DUPLEX_MODE = 0,
+	GMAC_FULL_DUPLEX_MODE
+};
+
+struct hns_gmac_port_mode_cfg {
+	enum hns_port_mode port_mode;
+	u32 max_frm_size;
+	u32 short_runts_thr;
+	u32 pad_enable;
+	u32 crc_add;
+	u32 an_enable;	/*auto-nego enable  */
+	u32 runt_pkt_en;
+	u32 strip_pad_en;
+};
+
+#define ETH_GMAC_DUMP_NUM		96
+#endif				/* __HNS_GMAC_H__ */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
new file mode 100644
index 0000000..a8bd27b
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -0,0 +1,900 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/phy_fixed.h>
+#include <linux/interrupt.h>
+#include <linux/platform_device.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+
+#include "hns_dsaf_misc.h"
+#include "hns_dsaf_main.h"
+#include "hns_dsaf_rcb.h"
+
+#define MAC_EN_FLAG_V		0xada0328
+
+static const u16 mac_phy_to_speed[] = {
+	[PHY_INTERFACE_MODE_MII] = MAC_SPEED_100,
+	[PHY_INTERFACE_MODE_GMII] = MAC_SPEED_1000,
+	[PHY_INTERFACE_MODE_SGMII] = MAC_SPEED_1000,
+	[PHY_INTERFACE_MODE_TBI] = MAC_SPEED_1000,
+	[PHY_INTERFACE_MODE_RMII] = MAC_SPEED_100,
+	[PHY_INTERFACE_MODE_RGMII] = MAC_SPEED_1000,
+	[PHY_INTERFACE_MODE_RGMII_ID] = MAC_SPEED_1000,
+	[PHY_INTERFACE_MODE_RGMII_RXID]	= MAC_SPEED_1000,
+	[PHY_INTERFACE_MODE_RGMII_TXID]	= MAC_SPEED_1000,
+	[PHY_INTERFACE_MODE_RTBI] = MAC_SPEED_1000,
+	[PHY_INTERFACE_MODE_XGMII] = MAC_SPEED_10000
+};
+
+static const enum mac_mode g_mac_mode_100[] = {
+	[PHY_INTERFACE_MODE_MII]	= MAC_MODE_MII_100,
+	[PHY_INTERFACE_MODE_RMII]   = MAC_MODE_RMII_100
+};
+
+static const enum mac_mode g_mac_mode_1000[] = {
+	[PHY_INTERFACE_MODE_GMII]   = MAC_MODE_GMII_1000,
+	[PHY_INTERFACE_MODE_SGMII]  = MAC_MODE_SGMII_1000,
+	[PHY_INTERFACE_MODE_TBI]	= MAC_MODE_TBI_1000,
+	[PHY_INTERFACE_MODE_RGMII]  = MAC_MODE_RGMII_1000,
+	[PHY_INTERFACE_MODE_RGMII_ID]   = MAC_MODE_RGMII_1000,
+	[PHY_INTERFACE_MODE_RGMII_RXID] = MAC_MODE_RGMII_1000,
+	[PHY_INTERFACE_MODE_RGMII_TXID] = MAC_MODE_RGMII_1000,
+	[PHY_INTERFACE_MODE_RTBI]   = MAC_MODE_RTBI_1000
+};
+
+static enum mac_mode hns_mac_dev_to_enet_if(const struct hns_mac_cb *mac_cb)
+{
+	switch (mac_cb->max_speed) {
+	case MAC_SPEED_100:
+		return g_mac_mode_100[mac_cb->phy_if];
+	case MAC_SPEED_1000:
+		return g_mac_mode_1000[mac_cb->phy_if];
+	case MAC_SPEED_10000:
+		return MAC_MODE_XGMII_10000;
+	default:
+		return MAC_MODE_MII_100;
+	}
+}
+
+static enum mac_mode hns_get_enet_interface(const struct hns_mac_cb *mac_cb)
+{
+	switch (mac_cb->max_speed) {
+	case MAC_SPEED_100:
+		return g_mac_mode_100[mac_cb->phy_if];
+	case MAC_SPEED_1000:
+		return g_mac_mode_1000[mac_cb->phy_if];
+	case MAC_SPEED_10000:
+		return MAC_MODE_XGMII_10000;
+	default:
+		return MAC_MODE_MII_100;
+	}
+}
+
+int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
+{
+	if (!mac_cb->cpld_vaddr)
+		return -ENODEV;
+
+	*sfp_prsnt = !dsaf_read_b((u64)mac_cb->cpld_vaddr
+					+ MAC_SFP_PORT_OFFSET);
+
+	return 0;
+}
+
+void hns_mac_get_link_status(struct hns_mac_cb *mac_cb, u32 *link_status)
+{
+	struct mac_driver *mac_ctrl_drv;
+	int ret, sfp_prsnt;
+
+	mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	if (mac_ctrl_drv->get_link_status)
+		mac_ctrl_drv->get_link_status(mac_ctrl_drv, link_status);
+	else
+		*link_status = 0;
+
+	ret = hns_mac_get_sfp_prsnt(mac_cb, &sfp_prsnt);
+	if (!ret)
+		*link_status = *link_status && sfp_prsnt;
+
+	mac_cb->link = *link_status;
+}
+
+int hns_mac_get_port_info(struct hns_mac_cb *mac_cb,
+			  u8 *auto_neg, u16 *speed, u8 *duplex)
+{
+	struct mac_driver *mac_ctrl_drv;
+	struct mac_info    info;
+
+	mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	if (!mac_ctrl_drv->get_info)
+		return -ENODEV;
+
+	mac_ctrl_drv->get_info(mac_ctrl_drv, &info);
+	if (auto_neg)
+		*auto_neg = info.auto_neg;
+	if (speed)
+		*speed = info.speed;
+	if (duplex)
+		*duplex = info.duplex;
+
+	return 0;
+}
+
+void hns_mac_adjust_link(struct hns_mac_cb *mac_cb, int speed, int duplex)
+{
+	int ret;
+	struct mac_driver *mac_ctrl_drv;
+
+	mac_ctrl_drv = (struct mac_driver *)(mac_cb->priv.mac);
+
+	mac_cb->speed = speed;
+	mac_cb->half_duplex = !duplex;
+	mac_ctrl_drv->mac_mode = hns_mac_dev_to_enet_if(mac_cb);
+
+	if (mac_ctrl_drv->adjust_link) {
+		ret = mac_ctrl_drv->adjust_link(mac_ctrl_drv,
+			(enum mac_speed)speed, duplex);
+		if (ret) {
+			dev_err(mac_cb->dev,
+				"adjust_link failed,%s mac%d ret = %#x!\n",
+				mac_cb->dsaf_dev->ae_dev.name,
+				mac_cb->mac_id, ret);
+			return;
+		}
+	}
+}
+
+/**
+ *hns_mac_get_inner_port_num - get mac table inner port number
+ *@mac_cb: mac device
+ *@vmid: vm id
+ *@port_num:port number
+ *
+ */
+static int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
+				      u8 vmid, u8 *port_num)
+{
+	u8 tmp_port;
+	u32 comm_idx;
+
+	if (mac_cb->dsaf_dev->dsaf_mode <= DSAF_MODE_ENABLE) {
+		if (mac_cb->mac_id != DSAF_MAX_PORT_NUM_PER_CHIP) {
+			dev_err(mac_cb->dev,
+				"input invalid,%s mac%d vmid%d !\n",
+				mac_cb->dsaf_dev->ae_dev.name,
+				mac_cb->mac_id, vmid);
+			return -EINVAL;
+		}
+	} else if (mac_cb->dsaf_dev->dsaf_mode < DSAF_MODE_MAX) {
+		if (mac_cb->mac_id <= DSAF_MAX_PORT_NUM_PER_CHIP) {
+			dev_err(mac_cb->dev,
+				"input invalid,%s mac%d vmid%d!\n",
+				mac_cb->dsaf_dev->ae_dev.name,
+				mac_cb->mac_id, vmid);
+			return -EINVAL;
+		}
+	} else {
+		dev_err(mac_cb->dev, "dsaf mode invalid,%s mac%d!\n",
+			mac_cb->dsaf_dev->ae_dev.name, mac_cb->mac_id);
+		return -EINVAL;
+	}
+
+	comm_idx = hns_dsaf_get_comm_idx_by_port(mac_cb->mac_id);
+
+	if (vmid >= mac_cb->dsaf_dev->rcb_common[comm_idx]->max_vfn) {
+		dev_err(mac_cb->dev, "input invalid,%s mac%d vmid%d !\n",
+			mac_cb->dsaf_dev->ae_dev.name, mac_cb->mac_id, vmid);
+		return -EINVAL;
+	}
+
+	switch (mac_cb->dsaf_dev->dsaf_mode) {
+	case DSAF_MODE_ENABLE_FIX:
+		tmp_port = 0;
+		break;
+	case DSAF_MODE_DISABLE_FIX:
+		tmp_port = 0;
+		break;
+	case DSAF_MODE_ENABLE_0VM:
+	case DSAF_MODE_ENABLE_8VM:
+	case DSAF_MODE_ENABLE_16VM:
+	case DSAF_MODE_ENABLE_32VM:
+	case DSAF_MODE_ENABLE_128VM:
+	case DSAF_MODE_DISABLE_2PORT_8VM:
+	case DSAF_MODE_DISABLE_2PORT_16VM:
+	case DSAF_MODE_DISABLE_2PORT_64VM:
+	case DSAF_MODE_DISABLE_6PORT_0VM:
+	case DSAF_MODE_DISABLE_6PORT_2VM:
+	case DSAF_MODE_DISABLE_6PORT_4VM:
+	case DSAF_MODE_DISABLE_6PORT_16VM:
+		tmp_port = vmid;
+		break;
+	default:
+		dev_err(mac_cb->dev, "dsaf mode invalid,%s mac%d!\n",
+			mac_cb->dsaf_dev->ae_dev.name, mac_cb->mac_id);
+		return -EINVAL;
+	}
+	tmp_port += DSAF_BASE_INNER_PORT_NUM;
+
+	*port_num = tmp_port;
+
+	return 0;
+}
+
+/**
+ *hns_mac_get_inner_port_num - change vf mac address
+ *@mac_cb: mac device
+ *@vmid: vmid
+ *@addr:mac address
+ */
+int hns_mac_change_vf_addr(struct hns_mac_cb *mac_cb,
+			   u32 vmid, char *addr)
+{
+	int ret;
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
+	struct dsaf_drv_mac_single_dest_entry mac_entry;
+	struct mac_entry_idx *old_entry;
+
+	old_entry = &mac_cb->addr_entry_idx[vmid];
+	if (dsaf_dev) {
+		memcpy(mac_entry.addr, addr, sizeof(mac_entry.addr));
+		mac_entry.in_vlan_id = old_entry->vlan_id;
+		mac_entry.in_port_num = mac_cb->mac_id;
+		ret = hns_mac_get_inner_port_num(mac_cb, (u8)vmid,
+						 &mac_entry.port_num);
+		if (ret)
+			return ret;
+
+		if ((old_entry->valid != 0) &&
+		    (memcmp(old_entry->addr,
+		    addr, sizeof(mac_entry.addr)) != 0)) {
+			ret = hns_dsaf_del_mac_entry(dsaf_dev,
+						     old_entry->vlan_id,
+						     mac_cb->mac_id,
+						     old_entry->addr);
+			if (ret)
+				return ret;
+		}
+
+		ret = hns_dsaf_set_mac_uc_entry(dsaf_dev, &mac_entry);
+		if (ret)
+			return ret;
+	}
+
+	if ((mac_ctrl_drv->set_mac_addr) && (vmid == 0))
+		mac_ctrl_drv->set_mac_addr(mac_cb->priv.mac, addr);
+
+	memcpy(old_entry->addr, addr, sizeof(old_entry->addr));
+	old_entry->valid = 1;
+	return 0;
+}
+
+int hns_mac_set_multi(struct hns_mac_cb *mac_cb,
+		      u32 port_num, char *addr, u8 en)
+{
+	int ret;
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
+	struct dsaf_drv_mac_single_dest_entry mac_entry;
+
+	if (dsaf_dev && addr) {
+		memcpy(mac_entry.addr, addr, sizeof(mac_entry.addr));
+		mac_entry.in_vlan_id = 0;/*vlan_id;*/
+		mac_entry.in_port_num = mac_cb->mac_id;
+		mac_entry.port_num = port_num;
+
+		if (en == DISABLE)
+			ret = hns_dsaf_del_mac_mc_port(dsaf_dev, &mac_entry);
+		else
+			ret = hns_dsaf_add_mac_mc_port(dsaf_dev, &mac_entry);
+		if (ret) {
+			dev_err(dsaf_dev->dev,
+				"set mac mc port failed,%s mac%d ret = %#x!\n",
+				mac_cb->dsaf_dev->ae_dev.name,
+				mac_cb->mac_id, ret);
+			return ret;
+		}
+	}
+
+	return 0;
+}
+
+/**
+ *hns_mac_del_mac - delete mac address into dsaf table,can't delete the same
+ *                  address twice
+ *@net_dev: net device
+ *@vfn :   vf lan
+ *@mac : mac address
+ *return status
+ */
+int hns_mac_del_mac(struct hns_mac_cb *mac_cb, u32 vfn, char *mac)
+{
+	struct mac_entry_idx *old_mac;
+	struct dsaf_device *dsaf_dev;
+	u32 ret;
+
+	dsaf_dev = mac_cb->dsaf_dev;
+
+	if (vfn < DSAF_MAX_VM_NUM) {
+		old_mac = &mac_cb->addr_entry_idx[vfn];
+	} else {
+		dev_err(mac_cb->dev,
+			"vf queue is too large,%s mac%d queue = %#x!\n",
+			mac_cb->dsaf_dev->ae_dev.name, mac_cb->mac_id, vfn);
+		return -EINVAL;
+	}
+
+	if (dsaf_dev) {
+		ret = hns_dsaf_del_mac_entry(dsaf_dev, old_mac->vlan_id,
+					     mac_cb->mac_id, old_mac->addr);
+		if (ret)
+			return ret;
+
+		if (memcmp(old_mac->addr, mac, sizeof(old_mac->addr)) == 0)
+			old_mac->valid = 0;
+	}
+
+	return 0;
+}
+
+static void hns_mac_param_get(struct mac_params *param,
+			      struct hns_mac_cb *mac_cb)
+{
+	param->vaddr = (void *)mac_cb->vaddr;
+	param->mac_mode = hns_get_enet_interface(mac_cb);
+	memcpy(param->addr, mac_cb->addr_entry_idx[0].addr,
+	       MAC_NUM_OCTETS_PER_ADDR);
+	param->mac_id = mac_cb->mac_id;
+	param->dev = mac_cb->dev;
+}
+
+/**
+ *hns_mac_queue_config_bc_en - set broadcast rx&tx enable
+ *@mac_cb: mac device
+ *@queue: queue number
+ *@en:enable
+ *retuen 0 - success , negative --fail
+ */
+static int hns_mac_port_config_bc_en(struct hns_mac_cb *mac_cb,
+				     u32 port_num, u16 vlan_id, u8 en)
+{
+	int ret;
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
+	u8 addr[MAC_NUM_OCTETS_PER_ADDR]
+		= {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+	struct dsaf_drv_mac_single_dest_entry mac_entry;
+
+	/* directy return ok in debug network mode */
+	if (mac_cb->mac_type == HNAE_PORT_DEBUG)
+		return 0;
+
+	if (dsaf_dev) {
+		memcpy(mac_entry.addr, addr, sizeof(mac_entry.addr));
+		mac_entry.in_vlan_id = vlan_id;
+		mac_entry.in_port_num = mac_cb->mac_id;
+		mac_entry.port_num = port_num;
+
+		if (en == DISABLE)
+			ret = hns_dsaf_del_mac_mc_port(dsaf_dev, &mac_entry);
+		else
+			ret = hns_dsaf_add_mac_mc_port(dsaf_dev, &mac_entry);
+		return ret;
+	}
+
+	return 0;
+}
+
+/**
+ *hns_mac_vm_config_bc_en - set broadcast rx&tx enable
+ *@mac_cb: mac device
+ *@vmid: vm id
+ *@en:enable
+ *retuen 0 - success , negative --fail
+ */
+int hns_mac_vm_config_bc_en(struct hns_mac_cb *mac_cb, u32 vmid, u8 en)
+{
+	int ret;
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
+	u8 port_num;
+	u8 addr[MAC_NUM_OCTETS_PER_ADDR]
+		= {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+	struct mac_entry_idx *uc_mac_entry;
+	struct dsaf_drv_mac_single_dest_entry mac_entry;
+
+	if (mac_cb->mac_type == HNAE_PORT_DEBUG)
+		return 0;
+
+	uc_mac_entry = &mac_cb->addr_entry_idx[vmid];
+
+	if (dsaf_dev)  {
+		memcpy(mac_entry.addr, addr, sizeof(mac_entry.addr));
+		mac_entry.in_vlan_id = uc_mac_entry->vlan_id;
+		mac_entry.in_port_num = mac_cb->mac_id;
+		ret = hns_mac_get_inner_port_num(mac_cb, vmid, &port_num);
+		if (ret)
+			return ret;
+		mac_entry.port_num = port_num;
+
+		if (en == DISABLE)
+			ret = hns_dsaf_del_mac_mc_port(dsaf_dev, &mac_entry);
+		else
+			ret = hns_dsaf_add_mac_mc_port(dsaf_dev, &mac_entry);
+		return ret;
+	}
+
+	return 0;
+}
+
+void hns_mac_reset(struct hns_mac_cb *mac_cb)
+{
+	struct mac_driver *drv;
+
+	drv = hns_mac_get_drv(mac_cb);
+
+	drv->mac_init(drv);
+
+	if (drv->config_max_frame_length)
+		drv->config_max_frame_length(drv, mac_cb->max_frm);
+
+	if (drv->set_tx_auto_pause_frames)
+		drv->set_tx_auto_pause_frames(drv, mac_cb->tx_pause_frm_time);
+
+	if (drv->set_an_mode)
+		drv->set_an_mode(drv, 1);
+
+	if (drv->mac_pausefrm_cfg) {
+		if (mac_cb->mac_type == HNAE_PORT_DEBUG)
+			drv->mac_pausefrm_cfg(drv, 0, 0);
+		else /* mac rx must disable, dsaf pfc close instead of it*/
+			drv->mac_pausefrm_cfg(drv, 0, 1);
+	}
+}
+
+int hns_mac_set_mtu(struct hns_mac_cb *mac_cb, u32 new_mtu)
+{
+	struct mac_driver *drv = hns_mac_get_drv(mac_cb);
+	u32 buf_size = mac_cb->dsaf_dev->buf_size;
+	u32 new_frm = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+
+	if ((new_mtu < MAC_MIN_MTU) || (new_frm > MAC_MAX_MTU) ||
+	    (new_frm > HNS_RCB_RING_MAX_BD_PER_PKT * buf_size))
+		return -EINVAL;
+
+	if (!drv->config_max_frame_length)
+		return -ECHILD;
+
+	/* adjust max frame to be at least the size of a standard frame */
+	if (new_frm < (ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN))
+		new_frm = (ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN);
+
+	drv->config_max_frame_length(drv, new_frm);
+
+	mac_cb->max_frm = new_frm;
+
+	return 0;
+}
+
+void hns_mac_start(struct hns_mac_cb *mac_cb)
+{
+	struct mac_driver *mac_drv = hns_mac_get_drv(mac_cb);
+
+	/* for virt */
+	if (mac_drv->mac_en_flg == MAC_EN_FLAG_V) {
+		/*plus 1 when the virtual mac has been enabled */
+		mac_drv->virt_dev_num += 1;
+		return;
+	}
+
+	if (mac_drv->mac_enable) {
+		mac_drv->mac_enable(mac_cb->priv.mac, MAC_COMM_MODE_RX_AND_TX);
+		mac_drv->mac_en_flg = MAC_EN_FLAG_V;
+	}
+}
+
+void hns_mac_stop(struct hns_mac_cb *mac_cb)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	/*modified for virtualization */
+	if (mac_ctrl_drv->virt_dev_num > 0) {
+		mac_ctrl_drv->virt_dev_num -= 1;
+		if (mac_ctrl_drv->virt_dev_num > 0)
+			return;
+	}
+
+	if (mac_ctrl_drv->mac_disable)
+		mac_ctrl_drv->mac_disable(mac_cb->priv.mac,
+			MAC_COMM_MODE_RX_AND_TX);
+
+	mac_ctrl_drv->mac_en_flg = 0;
+	mac_cb->link = 0;
+	cpld_led_reset(mac_cb);
+}
+
+/**
+ * hns_mac_get_autoneg - get auto autonegotiation
+ * @mac_cb: mac control block
+ * @enable: enable or not
+ * retuen 0 - success , negative --fail
+ */
+void hns_mac_get_autoneg(struct hns_mac_cb *mac_cb, u32 *auto_neg)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	if (mac_ctrl_drv->autoneg_stat)
+		mac_ctrl_drv->autoneg_stat(mac_ctrl_drv, auto_neg);
+	else
+		*auto_neg = 0;
+}
+
+/**
+ * hns_mac_get_pauseparam - set rx & tx pause parameter
+ * @mac_cb: mac control block
+ * @rx_en: rx enable status
+ * @tx_en: tx enable status
+ * retuen 0 - success , negative --fail
+ */
+void hns_mac_get_pauseparam(struct hns_mac_cb *mac_cb, u32 *rx_en, u32 *tx_en)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	if (mac_ctrl_drv->get_pause_enable) {
+		mac_ctrl_drv->get_pause_enable(mac_ctrl_drv, rx_en, tx_en);
+	} else {
+		*rx_en = 0;
+		*tx_en = 0;
+	}
+
+	/* Due to the chip defect, the service mac's rx pause CAN'T be enabled.
+	 * We set the rx pause frm always be true (1), because DSAF deals with
+	 * the rx pause frm instead of service mac. After all, we still support
+	 * rx pause frm.
+	 */
+	if (mac_cb->mac_type == HNAE_PORT_SERVICE)
+		*rx_en = 1;
+}
+
+/**
+ * hns_mac_set_autoneg - set auto autonegotiation
+ * @mac_cb: mac control block
+ * @enable: enable or not
+ * retuen 0 - success , negative --fail
+ */
+int hns_mac_set_autoneg(struct hns_mac_cb *mac_cb, u8 enable)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	if (mac_cb->phy_if == PHY_INTERFACE_MODE_XGMII && enable) {
+		dev_err(mac_cb->dev, "enable autoneg is not allowed!");
+		return -ENOTSUPP;
+	}
+
+	if (mac_ctrl_drv->set_an_mode)
+		mac_ctrl_drv->set_an_mode(mac_ctrl_drv, enable);
+
+	return 0;
+}
+
+/**
+ * hns_mac_set_autoneg - set rx & tx pause parameter
+ * @mac_cb: mac control block
+ * @rx_en: rx enable or not
+ * @tx_en: tx enable or not
+ * return 0 - success , negative --fail
+ */
+int hns_mac_set_pauseparam(struct hns_mac_cb *mac_cb, u32 rx_en, u32 tx_en)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	if (mac_cb->mac_type == HNAE_PORT_SERVICE) {
+		if (!rx_en) {
+			dev_err(mac_cb->dev, "disable rx_pause is not allowed!");
+			return -EINVAL;
+		}
+	} else if (mac_cb->mac_type == HNAE_PORT_DEBUG) {
+		if (tx_en || rx_en) {
+			dev_err(mac_cb->dev, "enable tx_pause or enable rx_pause are not allowed!");
+			return -EINVAL;
+		}
+	} else {
+		dev_err(mac_cb->dev, "Unsupport this operation!");
+		return -EINVAL;
+	}
+
+	if (mac_ctrl_drv->mac_pausefrm_cfg)
+		mac_ctrl_drv->mac_pausefrm_cfg(mac_ctrl_drv, rx_en, tx_en);
+
+	return 0;
+}
+
+/**
+ * hns_mac_init_ex - mac init
+ * @mac_cb: mac control block
+ * retuen 0 - success , negative --fail
+ */
+static int hns_mac_init_ex(struct hns_mac_cb *mac_cb)
+{
+	int ret;
+	struct mac_params param;
+	struct mac_driver *drv;
+
+	hns_dsaf_fix_mac_mode(mac_cb);
+
+	memset(&param, 0, sizeof(struct mac_params));
+	hns_mac_param_get(&param, mac_cb);
+
+	if (MAC_SPEED_FROM_MODE(param.mac_mode) < MAC_SPEED_10000)
+		drv = (struct mac_driver *)hns_gmac_config(mac_cb, &param);
+	else
+		drv = (struct mac_driver *)hns_xgmac_config(mac_cb, &param);
+
+	if (!drv)
+		return -ENOMEM;
+
+	mac_cb->priv.mac = (void *)drv;
+	hns_mac_reset(mac_cb);
+
+	hns_mac_adjust_link(mac_cb, mac_cb->speed, !mac_cb->half_duplex);
+
+	ret = hns_mac_port_config_bc_en(mac_cb, mac_cb->mac_id, 0, ENABLE);
+	if (ret)
+		goto free_mac_drv;
+
+	return 0;
+
+free_mac_drv:
+	drv->mac_free(mac_cb->priv.mac);
+	mac_cb->priv.mac = NULL;
+
+	return ret;
+}
+
+/**
+ *mac_free_dev  - get mac information from device node
+ *@mac_cb: mac device
+ *@np:device node
+ *@mac_mode_idx:mac mode index
+ */
+static void hns_mac_get_info(struct hns_mac_cb *mac_cb,
+			     struct device_node *np, u32 mac_mode_idx)
+{
+	mac_cb->link = false;
+	mac_cb->half_duplex = false;
+	mac_cb->speed = mac_phy_to_speed[mac_cb->phy_if];
+	mac_cb->max_speed = mac_cb->speed;
+
+	if (mac_cb->phy_if == PHY_INTERFACE_MODE_SGMII) {
+		mac_cb->if_support = MAC_GMAC_SUPPORTED;
+		mac_cb->if_support |= SUPPORTED_1000baseT_Full;
+	} else if (mac_cb->phy_if == PHY_INTERFACE_MODE_XGMII) {
+		mac_cb->if_support = SUPPORTED_10000baseR_FEC;
+		mac_cb->if_support |= SUPPORTED_10000baseKR_Full;
+	}
+
+	mac_cb->max_frm = MAC_DEFAULT_MTU;
+	mac_cb->tx_pause_frm_time = MAC_DEFAULT_PAUSE_TIME;
+
+	/* Get the rest of the PHY information */
+	mac_cb->phy_node = of_parse_phandle(np, "phy-handle", mac_cb->mac_id);
+	if (mac_cb->phy_node)
+		dev_dbg(mac_cb->dev, "mac%d phy_node: %s\n",
+			mac_cb->mac_id, mac_cb->phy_node->name);
+}
+
+/**
+ * hns_mac_get_mode - get mac mode
+ * @phy_if: phy interface
+ * retuen 0 - gmac, 1 - xgmac , negative --fail
+ */
+static int hns_mac_get_mode(phy_interface_t phy_if)
+{
+	switch (phy_if) {
+	case PHY_INTERFACE_MODE_SGMII:
+		return MAC_GMAC_IDX;
+	case PHY_INTERFACE_MODE_XGMII:
+		return MAC_XGMAC_IDX;
+	default:
+		return -EINVAL;
+	}
+}
+
+u8 __iomem *hns_mac_get_vaddr(struct dsaf_device *dsaf_dev,
+			      struct hns_mac_cb *mac_cb, u32 mac_mode_idx)
+{
+	u8 __iomem *base = dsaf_dev->io_base;
+	int mac_id = mac_cb->mac_id;
+
+	if (mac_cb->mac_type == HNAE_PORT_SERVICE)
+		return base + 0x40000 + mac_id * 0x4000 -
+				mac_mode_idx * 0x20000;
+	else
+		return mac_cb->serdes_vaddr + 0x1000
+			+ (mac_id - DSAF_SERVICE_PORT_NUM_PER_DSAF) * 0x100000;
+}
+
+/**
+ * hns_mac_get_cfg - get mac cfg from dtb or acpi table
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @mac_idx: mac index
+ * retuen 0 - success , negative --fail
+ */
+int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, int mac_idx)
+{
+	int ret;
+	u32 mac_mode_idx;
+	struct hns_mac_cb *mac_cb = &dsaf_dev->mac_cb[mac_idx];
+
+	mac_cb->dsaf_dev = dsaf_dev;
+	mac_cb->dev = dsaf_dev->dev;
+	mac_cb->mac_id = mac_idx;
+
+	mac_cb->sys_ctl_vaddr =	dsaf_dev->sc_base;
+	mac_cb->serdes_vaddr = dsaf_dev->sds_base;
+
+	if (dsaf_dev->cpld_base &&
+	    mac_idx < DSAF_SERVICE_PORT_NUM_PER_DSAF)
+		mac_cb->cpld_vaddr = dsaf_dev->cpld_base +
+			mac_cb->mac_id * CPLD_ADDR_PORT_OFFSET;
+	mac_cb->sfp_prsnt = 0;
+	mac_cb->txpkt_for_led = 0;
+	mac_cb->rxpkt_for_led = 0;
+
+	if (mac_idx < DSAF_SERVICE_PORT_NUM_PER_DSAF)
+		mac_cb->mac_type = HNAE_PORT_SERVICE;
+	else
+		mac_cb->mac_type = HNAE_PORT_DEBUG;
+
+	mac_cb->phy_if = hns_mac_get_phy_if(mac_cb);
+
+	ret = hns_mac_get_mode(mac_cb->phy_if);
+	if (ret < 0) {
+		dev_err(dsaf_dev->dev,
+			"hns_mac_get_mode failed,mac%d ret = %#x!\n",
+			mac_cb->mac_id, ret);
+		return ret;
+	}
+	mac_mode_idx = (u32)ret;
+
+	hns_mac_get_info(mac_cb, mac_cb->dev->of_node, mac_mode_idx);
+
+	mac_cb->vaddr = hns_mac_get_vaddr(dsaf_dev, mac_cb, mac_mode_idx);
+
+	return 0;
+}
+
+/**
+ * hns_mac_init - init mac
+ * @dsaf_dev: dsa fabric device struct pointer
+ * retuen 0 - success , negative --fail
+ */
+int hns_mac_init(struct dsaf_device *dsaf_dev)
+{
+	int i;
+	int ret;
+	size_t size;
+	struct hns_mac_cb *mac_cb;
+
+	size = sizeof(struct hns_mac_cb) * DSAF_MAX_PORT_NUM_PER_CHIP;
+	dsaf_dev->mac_cb = devm_kzalloc(dsaf_dev->dev, size, GFP_KERNEL);
+	if (!dsaf_dev->mac_cb)
+		return -ENOMEM;
+
+	for (i = 0; i < DSAF_MAX_PORT_NUM_PER_CHIP; i++) {
+		ret = hns_mac_get_cfg(dsaf_dev, i);
+		if (ret)
+			goto free_mac_cb;
+
+		mac_cb = &dsaf_dev->mac_cb[i];
+		ret = hns_mac_init_ex(mac_cb);
+		if (ret)
+			goto free_mac_cb;
+	}
+
+	return 0;
+
+free_mac_cb:
+	dsaf_dev->mac_cb = NULL;
+
+	return ret;
+}
+
+void hns_mac_uninit(struct dsaf_device *dsaf_dev)
+{
+	cpld_led_reset(dsaf_dev->mac_cb);
+	dsaf_dev->mac_cb = NULL;
+}
+
+int hns_mac_config_mac_loopback(struct hns_mac_cb *mac_cb,
+				enum hnae_loop loop, int en)
+{
+	int ret;
+	struct mac_driver *drv = hns_mac_get_drv(mac_cb);
+
+	if (drv->config_loopback)
+		ret = drv->config_loopback(drv, loop, en);
+	else
+		ret = -ENOTSUPP;
+
+	return ret;
+}
+
+void hns_mac_update_stats(struct hns_mac_cb *mac_cb)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	mac_ctrl_drv->update_stats(mac_ctrl_drv);
+}
+
+void hns_mac_get_stats(struct hns_mac_cb *mac_cb, u64 *data)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	mac_ctrl_drv->get_ethtool_stats(mac_ctrl_drv, data);
+}
+
+void hns_mac_get_strings(struct hns_mac_cb *mac_cb,
+			 int stringset, u8 *data)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	mac_ctrl_drv->get_strings(stringset, data);
+}
+
+int hns_mac_get_sset_count(struct hns_mac_cb *mac_cb, int stringset)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	return mac_ctrl_drv->get_sset_count(stringset);
+}
+
+int hns_mac_get_regs_count(struct hns_mac_cb *mac_cb)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	return mac_ctrl_drv->get_regs_count();
+}
+
+void hns_mac_get_regs(struct hns_mac_cb *mac_cb, void *data)
+{
+	struct mac_driver *mac_ctrl_drv = hns_mac_get_drv(mac_cb);
+
+	mac_ctrl_drv->get_regs(mac_ctrl_drv, data);
+}
+
+void hns_set_led_opt(struct hns_mac_cb *mac_cb)
+{
+	int nic_data = 0;
+	int txpkts, rxpkts;
+
+	txpkts = mac_cb->txpkt_for_led - mac_cb->hw_stats.tx_good_pkts;
+	rxpkts = mac_cb->rxpkt_for_led - mac_cb->hw_stats.rx_good_pkts;
+	if (txpkts || rxpkts)
+		nic_data = 1;
+	else
+		nic_data = 0;
+	mac_cb->txpkt_for_led = mac_cb->hw_stats.tx_good_pkts;
+	mac_cb->rxpkt_for_led = mac_cb->hw_stats.rx_good_pkts;
+	hns_cpld_set_led(mac_cb, (int)mac_cb->link,
+			 mac_cb->speed, nic_data);
+}
+
+int hns_cpld_led_set_id(struct hns_mac_cb *mac_cb,
+			enum hnae_led_state status)
+{
+	if (!mac_cb || !mac_cb->cpld_vaddr)
+		return 0;
+
+	return cpld_set_led_id(mac_cb, status);
+}
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
new file mode 100644
index 0000000..7da95a7
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -0,0 +1,456 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_DSAF_MAC_H
+#define _HNS_DSAF_MAC_H
+
+#include <linux/phy.h>
+#include <linux/kernel.h>
+#include <linux/if_vlan.h>
+#include "hns_dsaf_main.h"
+
+struct dsaf_device;
+
+#define MAC_GMAC_SUPPORTED \
+	(SUPPORTED_10baseT_Half \
+	| SUPPORTED_10baseT_Full \
+	| SUPPORTED_100baseT_Half \
+	| SUPPORTED_100baseT_Full \
+	| SUPPORTED_Autoneg)
+
+#define MAC_DEFAULT_MTU	(ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN + ETH_DATA_LEN)
+#define MAC_MAX_MTU		9600
+#define MAC_MIN_MTU		68
+
+#define MAC_DEFAULT_PAUSE_TIME 0xff
+
+#define MAC_GMAC_IDX 0
+#define MAC_XGMAC_IDX 1
+
+#define ETH_STATIC_REG	 1
+#define ETH_DUMP_REG	 5
+/* check mac addr broadcast */
+#define MAC_IS_BROADCAST(p)	((*(p) == 0xff) && (*((p) + 1) == 0xff) && \
+		(*((p) + 2) == 0xff) &&  (*((p) + 3) == 0xff)  && \
+		(*((p) + 4) == 0xff) && (*((p) + 5) == 0xff))
+
+/* check mac addr is 01-00-5e-xx-xx-xx*/
+#define MAC_IS_L3_MULTICAST(p) ((*((p) + 0) == 0x01) && \
+			(*((p) + 1) == 0x00)   && \
+			(*((p) + 2) == 0x5e))
+
+/*check the mac addr is 0 in all bit*/
+#define MAC_IS_ALL_ZEROS(p)   ((*(p) == 0) && (*((p) + 1) == 0) && \
+	(*((p) + 2) == 0) && (*((p) + 3) == 0) && \
+	(*((p) + 4) == 0) && (*((p) + 5) == 0))
+
+/*check mac addr multicast*/
+#define MAC_IS_MULTICAST(p)	((*((u8 *)((p) + 0)) & 0x01) ? (1) : (0))
+
+/**< Number of octets (8-bit bytes) in an ethernet address */
+#define MAC_NUM_OCTETS_PER_ADDR 6
+
+struct mac_priv {
+	void *mac;
+};
+
+/* net speed */
+enum mac_speed {
+	MAC_SPEED_10	= 10,	   /**< 10 Mbps */
+	MAC_SPEED_100	= 100,	  /**< 100 Mbps */
+	MAC_SPEED_1000  = 1000,	 /**< 1000 Mbps = 1 Gbps */
+	MAC_SPEED_10000 = 10000	 /**< 10000 Mbps = 10 Gbps */
+};
+
+/*mac interface keyword	*/
+enum mac_intf {
+	MAC_IF_NONE  = 0x00000000,   /**< interface not invalid */
+	MAC_IF_MII   = 0x00010000,   /**< MII interface */
+	MAC_IF_RMII  = 0x00020000,   /**< RMII interface */
+	MAC_IF_SMII  = 0x00030000,   /**< SMII interface */
+	MAC_IF_GMII  = 0x00040000,   /**< GMII interface */
+	MAC_IF_RGMII = 0x00050000,   /**< RGMII interface */
+	MAC_IF_TBI   = 0x00060000,   /**< TBI interface */
+	MAC_IF_RTBI  = 0x00070000,   /**< RTBI interface */
+	MAC_IF_SGMII = 0x00080000,   /**< SGMII interface */
+	MAC_IF_XGMII = 0x00090000,   /**< XGMII interface */
+	MAC_IF_QSGMII = 0x000a0000	/**< QSGMII interface */
+};
+
+/*mac mode */
+enum mac_mode {
+	/**< Invalid Ethernet mode */
+	MAC_MODE_INVALID	 = 0,
+	/**<	10 Mbps MII   */
+	MAC_MODE_MII_10	  = (MAC_IF_MII   | MAC_SPEED_10),
+	/**<   100 Mbps MII   */
+	MAC_MODE_MII_100	 = (MAC_IF_MII   | MAC_SPEED_100),
+	/**<	10 Mbps RMII  */
+	MAC_MODE_RMII_10	 = (MAC_IF_RMII  | MAC_SPEED_10),
+	/**<   100 Mbps RMII  */
+	MAC_MODE_RMII_100	= (MAC_IF_RMII  | MAC_SPEED_100),
+	/**<	10 Mbps SMII  */
+	MAC_MODE_SMII_10	 = (MAC_IF_SMII  | MAC_SPEED_10),
+	/**<   100 Mbps SMII  */
+	MAC_MODE_SMII_100	= (MAC_IF_SMII  | MAC_SPEED_100),
+	/**<  1000 Mbps GMII  */
+	MAC_MODE_GMII_1000   = (MAC_IF_GMII  | MAC_SPEED_1000),
+	/**<	10 Mbps RGMII */
+	MAC_MODE_RGMII_10	= (MAC_IF_RGMII | MAC_SPEED_10),
+	/**<   100 Mbps RGMII */
+	MAC_MODE_RGMII_100   = (MAC_IF_RGMII | MAC_SPEED_100),
+	/**<  1000 Mbps RGMII */
+	MAC_MODE_RGMII_1000  = (MAC_IF_RGMII | MAC_SPEED_1000),
+	/**<  1000 Mbps TBI   */
+	MAC_MODE_TBI_1000	= (MAC_IF_TBI   | MAC_SPEED_1000),
+	/**<  1000 Mbps RTBI  */
+	MAC_MODE_RTBI_1000   = (MAC_IF_RTBI  | MAC_SPEED_1000),
+	/**<	10 Mbps SGMII */
+	MAC_MODE_SGMII_10	= (MAC_IF_SGMII | MAC_SPEED_10),
+	/**<   100 Mbps SGMII */
+	MAC_MODE_SGMII_100   = (MAC_IF_SGMII | MAC_SPEED_100),
+	/**<  1000 Mbps SGMII */
+	MAC_MODE_SGMII_1000  = (MAC_IF_SGMII | MAC_SPEED_1000),
+	/**< 10000 Mbps XGMII */
+	MAC_MODE_XGMII_10000 = (MAC_IF_XGMII | MAC_SPEED_10000),
+	/**<  1000 Mbps QSGMII */
+	MAC_MODE_QSGMII_1000 = (MAC_IF_QSGMII | MAC_SPEED_1000)
+};
+
+/*mac communicate mode*/
+enum mac_commom_mode {
+	MAC_COMM_MODE_NONE	  = 0, /**< No transmit/receive communication */
+	MAC_COMM_MODE_RX		= 1, /**< Only receive communication */
+	MAC_COMM_MODE_TX		= 2, /**< Only transmit communication */
+	MAC_COMM_MODE_RX_AND_TX = 3  /**< Both tx and rx communication */
+};
+
+/*mac statistics */
+struct mac_statistics {
+	u64  stat_pkts64; /* r-10G tr-DT 64 byte frame counter */
+	u64  stat_pkts65to127; /* r-10G 65 to 127 byte frame counter */
+	u64  stat_pkts128to255; /* r-10G 128 to 255 byte frame counter */
+	u64  stat_pkts256to511; /*r-10G 256 to 511 byte frame counter */
+	u64  stat_pkts512to1023;/* r-10G 512 to 1023 byte frame counter */
+	u64  stat_pkts1024to1518; /* r-10G 1024 to 1518 byte frame counter */
+	u64  stat_pkts1519to1522; /* r-10G 1519 to 1522 byte good frame count*/
+	/* Total number of packets that were less than 64 octets */
+	/*			long with a wrong CRC.*/
+	u64  stat_fragments;
+	/* Total number of packets longer than valid maximum length octets */
+	u64  stat_jabbers;
+	/* number of dropped packets due to internal errors of */
+	/*			the MAC Client. */
+	u64  stat_drop_events;
+	/* Incremented when frames of correct length but with */
+	/*			CRC error are received.*/
+	u64  stat_crc_align_errors;
+	/* Total number of packets that were less than 64 octets */
+	/*			long with a good CRC.*/
+	u64  stat_undersize_pkts;
+	u64  stat_oversize_pkts;  /**< T,B.D*/
+
+	u64  stat_rx_pause;		   /**< Pause MAC Control received */
+	u64  stat_tx_pause;		   /**< Pause MAC Control sent */
+
+	u64  in_octets;		/**< Total number of byte received. */
+	u64  in_pkts;		/* Total number of packets received.*/
+	u64  in_mcast_pkts;	/* Total number of multicast frame received */
+	u64  in_bcast_pkts;	/* Total number of broadcast frame received */
+				/* Frames received, but discarded due to */
+				/* problems within the MAC RX. */
+	u64  in_discards;
+	u64  in_errors;		/* Number of frames received with error: */
+				/*	- FIFO Overflow Error */
+				/*	- CRC Error */
+				/*	- Frame Too Long Error */
+				/*	- Alignment Error */
+	u64  out_octets; /*Total number of byte sent. */
+	u64  out_pkts;	/**< Total number of packets sent .*/
+	u64  out_mcast_pkts; /* Total number of multicast frame sent */
+	u64  out_bcast_pkts; /* Total number of multicast frame sent */
+	/* Frames received, but discarded due to problems within */
+	/*			the MAC TX N/A!.*/
+	u64  out_discards;
+	u64  out_errors;	/*Number of frames transmitted with error: */
+			/*	- FIFO Overflow Error */
+			/*	- FIFO Underflow Error */
+			/*	 - Other */
+};
+
+/*mac para struct ,mac get param from nic or dsaf when initialize*/
+struct mac_params {
+	char addr[MAC_NUM_OCTETS_PER_ADDR];
+	void *vaddr; /*virtual address*/
+	struct device *dev;
+	u8 mac_id;
+	/**< Ethernet operation mode (MAC-PHY interface and speed) */
+	enum mac_mode mac_mode;
+};
+
+struct mac_info {
+	u16 speed;/* The forced speed (lower bits) in */
+		/*		 *mbps. Please use */
+		/*		 * ethtool_cmd_speed()/_set() to */
+		/*		 * access it */
+	u8 duplex;		/* Duplex, half or full */
+	u8 auto_neg;	/* Enable or disable autonegotiation */
+	enum hnae_loop loop_mode;
+	u8 tx_pause_en;
+	u8 tx_pause_time;
+	u8 rx_pause_en;
+	u8 pad_and_crc_en;
+	u8 promiscuous_en;
+	u8 port_en;	 /*port enable*/
+};
+
+struct mac_entry_idx {
+	u8 addr[MAC_NUM_OCTETS_PER_ADDR];
+	u16 vlan_id:12;
+	u16 valid:1;
+	u16 qos:3;
+};
+
+struct mac_hw_stats {
+	u64 rx_good_pkts;	/* only for xgmac */
+	u64 rx_good_bytes;
+	u64 rx_total_pkts;	/* only for xgmac */
+	u64 rx_total_bytes;	/* only for xgmac */
+	u64 rx_bad_bytes;	/* only for gmac */
+	u64 rx_uc_pkts;
+	u64 rx_mc_pkts;
+	u64 rx_bc_pkts;
+	u64 rx_fragment_err;	/* only for xgmac */
+	u64 rx_undersize;	/* only for xgmac */
+	u64 rx_under_min;
+	u64 rx_minto64;		/* only for gmac */
+	u64 rx_64bytes;
+	u64 rx_65to127;
+	u64 rx_128to255;
+	u64 rx_256to511;
+	u64 rx_512to1023;
+	u64 rx_1024to1518;
+	u64 rx_1519tomax;
+	u64 rx_1519tomax_good;	/* only for xgmac */
+	u64 rx_oversize;
+	u64 rx_jabber_err;
+	u64 rx_fcs_err;
+	u64 rx_vlan_pkts;	/* only for gmac */
+	u64 rx_data_err;	/* only for gmac */
+	u64 rx_align_err;	/* only for gmac */
+	u64 rx_long_err;	/* only for gmac */
+	u64 rx_pfc_tc0;
+	u64 rx_pfc_tc1;		/* only for xgmac */
+	u64 rx_pfc_tc2;		/* only for xgmac */
+	u64 rx_pfc_tc3;		/* only for xgmac */
+	u64 rx_pfc_tc4;		/* only for xgmac */
+	u64 rx_pfc_tc5;		/* only for xgmac */
+	u64 rx_pfc_tc6;		/* only for xgmac */
+	u64 rx_pfc_tc7;		/* only for xgmac */
+	u64 rx_unknown_ctrl;
+	u64 rx_filter_pkts;	/* only for gmac */
+	u64 rx_filter_bytes;	/* only for gmac */
+	u64 rx_fifo_overrun_err;/* only for gmac */
+	u64 rx_len_err;		/* only for gmac */
+	u64 rx_comma_err;	/* only for gmac */
+	u64 rx_symbol_err;	/* only for xgmac */
+	u64 tx_good_to_sw;	/* only for xgmac */
+	u64 tx_bad_to_sw;	/* only for xgmac */
+	u64 rx_1731_pkts;	/* only for xgmac */
+
+	u64 tx_good_bytes;
+	u64 tx_good_pkts;	/* only for xgmac */
+	u64 tx_total_bytes;	/* only for xgmac */
+	u64 tx_total_pkts;	/* only for xgmac */
+	u64 tx_bad_bytes;	/* only for gmac */
+	u64 tx_bad_pkts;	/* only for xgmac */
+	u64 tx_uc_pkts;
+	u64 tx_mc_pkts;
+	u64 tx_bc_pkts;
+	u64 tx_undersize;	/* only for xgmac */
+	u64 tx_fragment_err;	/* only for xgmac */
+	u64 tx_under_min_pkts;	/* only for gmac */
+	u64 tx_64bytes;
+	u64 tx_65to127;
+	u64 tx_128to255;
+	u64 tx_256to511;
+	u64 tx_512to1023;
+	u64 tx_1024to1518;
+	u64 tx_1519tomax;
+	u64 tx_1519tomax_good;	/* only for xgmac */
+	u64 tx_oversize;	/* only for xgmac */
+	u64 tx_jabber_err;
+	u64 tx_underrun_err;	/* only for gmac */
+	u64 tx_vlan;		/* only for gmac */
+	u64 tx_crc_err;		/* only for gmac */
+	u64 tx_pfc_tc0;
+	u64 tx_pfc_tc1;		/* only for xgmac */
+	u64 tx_pfc_tc2;		/* only for xgmac */
+	u64 tx_pfc_tc3;		/* only for xgmac */
+	u64 tx_pfc_tc4;		/* only for xgmac */
+	u64 tx_pfc_tc5;		/* only for xgmac */
+	u64 tx_pfc_tc6;		/* only for xgmac */
+	u64 tx_pfc_tc7;		/* only for xgmac */
+	u64 tx_ctrl;		/* only for xgmac */
+	u64 tx_1731_pkts;	/* only for xgmac */
+	u64 tx_1588_pkts;	/* only for xgmac */
+	u64 rx_good_from_sw;	/* only for xgmac */
+	u64 rx_bad_from_sw;	/* only for xgmac */
+};
+
+struct hns_mac_cb {
+	struct device *dev;
+	struct dsaf_device *dsaf_dev;
+	struct mac_priv priv;
+	u8 __iomem *vaddr;
+	u8 __iomem *cpld_vaddr;
+	u8 __iomem *sys_ctl_vaddr;
+	u8 __iomem *serdes_vaddr;
+	struct mac_entry_idx addr_entry_idx[DSAF_MAX_VM_NUM];
+	u8 sfp_prsnt;
+	u8 cpld_led_value;
+	u8 mac_id;
+
+	u8 link;
+	u8 half_duplex;
+	u16 speed;
+	u16 max_speed;
+	u16 max_frm;
+	u16 tx_pause_frm_time;
+	u32 if_support;
+	u64 txpkt_for_led;
+	u64 rxpkt_for_led;
+	enum hnae_port_type mac_type;
+	phy_interface_t phy_if;
+	enum hnae_loop loop_mode;
+
+	struct device_node *phy_node;
+
+	struct mac_hw_stats hw_stats;
+};
+
+struct mac_driver {
+	/*init Mac when init nic or dsaf*/
+	void (*mac_init)(void *mac_drv);
+	/*remove mac when remove nic or dsaf*/
+	void (*mac_free)(void *mac_drv);
+	/*enable mac when enable nic or dsaf*/
+	void (*mac_enable)(void *mac_drv, enum mac_commom_mode mode);
+	/*disable mac when disable nic or dsaf*/
+	void (*mac_disable)(void *mac_drv, enum mac_commom_mode mode);
+	/* config mac address*/
+	void (*set_mac_addr)(void *mac_drv,	char *mac_addr);
+	/*adjust mac mode of port,include speed and duplex*/
+	int (*adjust_link)(void *mac_drv, enum mac_speed speed,
+			   u32 full_duplex);
+	/* config autoegotaite mode of port*/
+	void (*set_an_mode)(void *mac_drv, u8 enable);
+	/* config loopbank mode */
+	int (*config_loopback)(void *mac_drv, enum hnae_loop loop_mode,
+			       u8 enable);
+	/* config mtu*/
+	void (*config_max_frame_length)(void *mac_drv, u16 newval);
+	/*config PAD and CRC enable */
+	void (*config_pad_and_crc)(void *mac_drv, u8 newval);
+	/* config duplex mode*/
+	void (*config_half_duplex)(void *mac_drv, u8 newval);
+	/*config tx pause time,if pause_time is zero,disable tx pause enable*/
+	void (*set_tx_auto_pause_frames)(void *mac_drv, u16 pause_time);
+	/*config rx pause enable*/
+	void (*set_rx_ignore_pause_frames)(void *mac_drv, u32 enable);
+	/* config rx mode for promiscuous*/
+	int (*set_promiscuous)(void *mac_drv, u8 enable);
+	/* get mac id */
+	void (*mac_get_id)(void *mac_drv, u8 *mac_id);
+	void (*mac_pausefrm_cfg)(void *mac_drv, u32 rx_en, u32 tx_en);
+
+	void (*autoneg_stat)(void *mac_drv, u32 *enable);
+	int (*set_pause_enable)(void *mac_drv, u32 rx_en, u32 tx_en);
+	void (*get_pause_enable)(void *mac_drv, u32 *rx_en, u32 *tx_en);
+	void (*get_link_status)(void *mac_drv, u32 *link_stat);
+	/* get the imporant regs*/
+	void (*get_regs)(void *mac_drv, void *data);
+	int (*get_regs_count)(void);
+	/* get strings name for ethtool statistic */
+	void (*get_strings)(u32 stringset, u8 *data);
+	/* get the number of strings*/
+	int (*get_sset_count)(int stringset);
+
+	/* get the statistic by ethtools*/
+	void (*get_ethtool_stats)(void *mac_drv, u64 *data);
+
+	/* get mac information */
+	void (*get_info)(void *mac_drv, struct mac_info *mac_info);
+
+	void (*update_stats)(void *mac_drv);
+
+	enum mac_mode mac_mode;
+	u8 mac_id;
+	struct hns_mac_cb *mac_cb;
+	void __iomem *io_base;
+	unsigned int mac_en_flg;/*you'd better don't enable mac twice*/
+	unsigned int virt_dev_num;
+	struct device *dev;
+};
+
+struct mac_stats_string {
+	char desc[64];
+	unsigned long offset;
+};
+
+#define MAC_MAKE_MODE(interface, speed) (enum mac_mode)((interface) | (speed))
+#define MAC_INTERFACE_FROM_MODE(mode) (enum mac_intf)((mode) & 0xFFFF0000)
+#define MAC_SPEED_FROM_MODE(mode) (enum mac_speed)((mode) & 0x0000FFFF)
+#define MAC_STATS_FIELD_OFF(field) (offsetof(struct mac_hw_stats, field))
+
+static inline struct mac_driver *hns_mac_get_drv(
+	const struct hns_mac_cb *mac_cb)
+{
+	return (struct mac_driver *)(mac_cb->priv.mac);
+}
+
+void *hns_gmac_config(struct hns_mac_cb *mac_cb,
+		      struct mac_params *mac_param);
+void *hns_xgmac_config(struct hns_mac_cb *mac_cb,
+		       struct mac_params *mac_param);
+
+int hns_mac_init(struct dsaf_device *dsaf_dev);
+void mac_adjust_link(struct net_device *net_dev);
+void hns_mac_get_link_status(struct hns_mac_cb *mac_cb,	u32 *link_status);
+int hns_mac_change_vf_addr(struct hns_mac_cb *mac_cb, u32 vmid, char *addr);
+int hns_mac_set_multi(struct hns_mac_cb *mac_cb,
+		      u32 port_num, char *addr, u8 en);
+int hns_mac_vm_config_bc_en(struct hns_mac_cb *mac_cb, u32 vm, u8 en);
+void hns_mac_start(struct hns_mac_cb *mac_cb);
+void hns_mac_stop(struct hns_mac_cb *mac_cb);
+int hns_mac_del_mac(struct hns_mac_cb *mac_cb, u32 vfn, char *mac);
+void hns_mac_uninit(struct dsaf_device *dsaf_dev);
+void hns_mac_adjust_link(struct hns_mac_cb *mac_cb, int speed, int duplex);
+void hns_mac_reset(struct hns_mac_cb *mac_cb);
+void hns_mac_get_autoneg(struct hns_mac_cb *mac_cb, u32 *auto_neg);
+void hns_mac_get_pauseparam(struct hns_mac_cb *mac_cb, u32 *rx_en, u32 *tx_en);
+int hns_mac_set_autoneg(struct hns_mac_cb *mac_cb, u8 enable);
+int hns_mac_set_pauseparam(struct hns_mac_cb *mac_cb, u32 rx_en, u32 tx_en);
+int hns_mac_set_mtu(struct hns_mac_cb *mac_cb, u32 new_mtu);
+int hns_mac_get_port_info(struct hns_mac_cb *mac_cb,
+			  u8 *auto_neg, u16 *speed, u8 *duplex);
+phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb);
+int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, u8 en);
+int hns_mac_config_mac_loopback(struct hns_mac_cb *mac_cb,
+				enum hnae_loop loop, int en);
+void hns_mac_update_stats(struct hns_mac_cb *mac_cb);
+void hns_mac_get_stats(struct hns_mac_cb *mac_cb, u64 *data);
+void hns_mac_get_strings(struct hns_mac_cb *mac_cb, int stringset, u8 *data);
+int hns_mac_get_sset_count(struct hns_mac_cb *mac_cb, int stringset);
+void hns_mac_get_regs(struct hns_mac_cb *mac_cb, void *data);
+int hns_mac_get_regs_count(struct hns_mac_cb *mac_cb);
+void hns_set_led_opt(struct hns_mac_cb *mac_cb);
+int hns_cpld_led_set_id(struct hns_mac_cb *mac_cb,
+			enum hnae_led_state status);
+#endif /* _HNS_DSAF_MAC_H */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
new file mode 100644
index 0000000..26ae6c6
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -0,0 +1,2445 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/platform_device.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/of_irq.h>
+#include <linux/device.h>
+#include "hns_dsaf_main.h"
+#include "hns_dsaf_rcb.h"
+#include "hns_dsaf_ppe.h"
+#include "hns_dsaf_mac.h"
+
+const char *g_dsaf_mode_match[DSAF_MODE_MAX] = {
+	[DSAF_MODE_DISABLE_2PORT_64VM] = "2port-64vf",
+	[DSAF_MODE_DISABLE_6PORT_0VM] = "6port-16rss",
+	[DSAF_MODE_DISABLE_6PORT_16VM] = "6port-16vf",
+};
+
+int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
+{
+	int ret, i;
+	u32 desc_num;
+	u32 buf_size;
+	const char *name, *mode_str;
+	struct device_node *np = dsaf_dev->dev->of_node;
+
+	if (of_device_is_compatible(np, "hisilicon,hns-dsaf-v2"))
+		dsaf_dev->dsaf_ver = AE_VERSION_2;
+	else
+		dsaf_dev->dsaf_ver = AE_VERSION_1;
+
+	ret = of_property_read_string(np, "dsa_name", &name);
+	if (ret) {
+		dev_err(dsaf_dev->dev, "get dsaf name fail, ret=%d!\n", ret);
+		return ret;
+	}
+	strncpy(dsaf_dev->ae_dev.name, name, AE_NAME_SIZE);
+	dsaf_dev->ae_dev.name[AE_NAME_SIZE - 1] = '\0';
+
+	ret = of_property_read_string(np, "mode", &mode_str);
+	if (ret) {
+		dev_err(dsaf_dev->dev, "get dsaf mode fail, ret=%d!\n", ret);
+		return ret;
+	}
+	for (i = 0; i < DSAF_MODE_MAX; i++) {
+		if (g_dsaf_mode_match[i] &&
+		    !strcmp(mode_str, g_dsaf_mode_match[i]))
+			break;
+	}
+	if (i >= DSAF_MODE_MAX ||
+	    i == DSAF_MODE_INVALID || i == DSAF_MODE_ENABLE) {
+		dev_err(dsaf_dev->dev,
+			"%s prs mode str fail!\n", dsaf_dev->ae_dev.name);
+		return -EINVAL;
+	}
+	dsaf_dev->dsaf_mode = (enum dsaf_mode)i;
+
+	if (dsaf_dev->dsaf_mode > DSAF_MODE_ENABLE)
+		dsaf_dev->dsaf_en = HRD_DSAF_NO_DSAF_MODE;
+	else
+		dsaf_dev->dsaf_en = HRD_DSAF_MODE;
+
+	if ((i == DSAF_MODE_ENABLE_16VM) ||
+	    (i == DSAF_MODE_DISABLE_2PORT_8VM) ||
+	    (i == DSAF_MODE_DISABLE_6PORT_2VM))
+		dsaf_dev->dsaf_tc_mode = HRD_DSAF_8TC_MODE;
+	else
+		dsaf_dev->dsaf_tc_mode = HRD_DSAF_4TC_MODE;
+
+	dsaf_dev->sc_base = of_iomap(np, 0);
+	if (!dsaf_dev->sc_base) {
+		dev_err(dsaf_dev->dev,
+			"%s of_iomap 0 fail!\n", dsaf_dev->ae_dev.name);
+		ret = -ENOMEM;
+		goto unmap_base_addr;
+	}
+
+	dsaf_dev->sds_base = of_iomap(np, 1);
+	if (!dsaf_dev->sds_base) {
+		dev_err(dsaf_dev->dev,
+			"%s of_iomap 1 fail!\n", dsaf_dev->ae_dev.name);
+		ret = -ENOMEM;
+		goto unmap_base_addr;
+	}
+
+	dsaf_dev->ppe_base = of_iomap(np, 2);
+	if (!dsaf_dev->ppe_base) {
+		dev_err(dsaf_dev->dev,
+			"%s of_iomap 2 fail!\n", dsaf_dev->ae_dev.name);
+		ret = -ENOMEM;
+		goto unmap_base_addr;
+	}
+
+	dsaf_dev->io_base = of_iomap(np, 3);
+	if (!dsaf_dev->io_base) {
+		dev_err(dsaf_dev->dev,
+			"%s of_iomap 3 fail!\n", dsaf_dev->ae_dev.name);
+		ret = -ENOMEM;
+		goto unmap_base_addr;
+	}
+
+	dsaf_dev->cpld_base = of_iomap(np, 4);
+	if (!dsaf_dev->cpld_base)
+		dev_dbg(dsaf_dev->dev, "NO CPLD ADDR");
+
+	ret = of_property_read_u32(np, "desc-num", &desc_num);
+	if (ret < 0 || desc_num < HNS_DSAF_MIN_DESC_CNT ||
+	    desc_num > HNS_DSAF_MAX_DESC_CNT) {
+		dev_err(dsaf_dev->dev, "get desc-num(%d) fail, ret=%d!\n",
+			desc_num, ret);
+		goto unmap_base_addr;
+	}
+	dsaf_dev->desc_num = desc_num;
+
+	ret = of_property_read_u32(np, "buf-size", &buf_size);
+	if (ret < 0) {
+		dev_err(dsaf_dev->dev,
+			"get buf-size fail, ret=%d!\r\n", ret);
+		goto unmap_base_addr;
+	}
+	dsaf_dev->buf_size = buf_size;
+
+	dsaf_dev->buf_size_type = hns_rcb_buf_size2type(buf_size);
+	if (dsaf_dev->buf_size_type < 0) {
+		dev_err(dsaf_dev->dev,
+			"buf_size(%d) is wrong!\n", buf_size);
+		goto unmap_base_addr;
+	}
+
+	if (!dma_set_mask_and_coherent(dsaf_dev->dev, DMA_BIT_MASK(64ULL)))
+		dev_dbg(dsaf_dev->dev, "set mask to 64bit\n");
+	else
+		dev_err(dsaf_dev->dev, "set mask to 64bit fail!\n");
+
+	return 0;
+
+unmap_base_addr:
+	if (dsaf_dev->io_base)
+		iounmap(dsaf_dev->io_base);
+	if (dsaf_dev->ppe_base)
+		iounmap(dsaf_dev->ppe_base);
+	if (dsaf_dev->sds_base)
+		iounmap(dsaf_dev->sds_base);
+	if (dsaf_dev->sc_base)
+		iounmap(dsaf_dev->sc_base);
+	if (dsaf_dev->cpld_base)
+		iounmap(dsaf_dev->cpld_base);
+	return ret;
+}
+
+static void hns_dsaf_free_cfg(struct dsaf_device *dsaf_dev)
+{
+	if (dsaf_dev->io_base)
+		iounmap(dsaf_dev->io_base);
+
+	if (dsaf_dev->ppe_base)
+		iounmap(dsaf_dev->ppe_base);
+
+	if (dsaf_dev->sds_base)
+		iounmap(dsaf_dev->sds_base);
+
+	if (dsaf_dev->sc_base)
+		iounmap(dsaf_dev->sc_base);
+
+	if (dsaf_dev->cpld_base)
+		iounmap(dsaf_dev->cpld_base);
+}
+
+/**
+ * hns_dsaf_sbm_link_sram_init_en - config dsaf_sbm_init_en
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_sbm_link_sram_init_en(struct dsaf_device *dsaf_dev)
+{
+	dsaf_set_dev_bit(dsaf_dev, DSAF_CFG_0_REG, DSAF_CFG_SBM_INIT_S, 1);
+}
+
+/**
+ * hns_dsaf_reg_cnt_clr_ce - config hns_dsaf_reg_cnt_clr_ce
+ * @dsaf_id: dsa fabric id
+ * @hns_dsaf_reg_cnt_clr_ce: config value
+ */
+static void
+hns_dsaf_reg_cnt_clr_ce(struct dsaf_device *dsaf_dev, u32 reg_cnt_clr_ce)
+{
+	dsaf_set_dev_bit(dsaf_dev, DSAF_DSA_REG_CNT_CLR_CE_REG,
+			 DSAF_CNT_CLR_CE_S, reg_cnt_clr_ce);
+}
+
+/**
+ * hns_ppe_qid_cfg - config ppe qid
+ * @dsaf_id: dsa fabric id
+ * @pppe_qid_cfg: value array
+ */
+static void
+hns_dsaf_ppe_qid_cfg(struct dsaf_device *dsaf_dev, u32 qid_cfg)
+{
+	u32 i;
+
+	for (i = 0; i < DSAF_COMM_CHN; i++) {
+		dsaf_set_dev_field(dsaf_dev,
+				   DSAF_PPE_QID_CFG_0_REG + 0x0004 * i,
+				   DSAF_PPE_QID_CFG_M, DSAF_PPE_QID_CFG_S,
+				   qid_cfg);
+	}
+}
+
+/**
+ * hns_dsaf_sw_port_type_cfg - cfg sw type
+ * @dsaf_id: dsa fabric id
+ * @psw_port_type: array
+ */
+static void hns_dsaf_sw_port_type_cfg(struct dsaf_device *dsaf_dev,
+				      enum dsaf_sw_port_type port_type)
+{
+	u32 i;
+
+	for (i = 0; i < DSAF_SW_PORT_NUM; i++) {
+		dsaf_set_dev_field(dsaf_dev,
+				   DSAF_SW_PORT_TYPE_0_REG + 0x0004 * i,
+				   DSAF_SW_PORT_TYPE_M, DSAF_SW_PORT_TYPE_S,
+				   port_type);
+	}
+}
+
+/**
+ * hns_dsaf_stp_port_type_cfg - cfg stp type
+ * @dsaf_id: dsa fabric id
+ * @pstp_port_type: array
+ */
+static void hns_dsaf_stp_port_type_cfg(struct dsaf_device *dsaf_dev,
+				       enum dsaf_stp_port_type port_type)
+{
+	u32 i;
+
+	for (i = 0; i < DSAF_COMM_CHN; i++) {
+		dsaf_set_dev_field(dsaf_dev,
+				   DSAF_STP_PORT_TYPE_0_REG + 0x0004 * i,
+				   DSAF_STP_PORT_TYPE_M, DSAF_STP_PORT_TYPE_S,
+				   port_type);
+	}
+}
+
+/**
+ * hns_dsaf_sbm_cfg - config sbm
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_sbm_cfg(struct dsaf_device *dsaf_dev)
+{
+	u32 o_sbm_cfg;
+	u32 i;
+
+	for (i = 0; i < DSAF_SBM_NUM; i++) {
+		o_sbm_cfg = dsaf_read_dev(dsaf_dev,
+					  DSAF_SBM_CFG_REG_0_REG + 0x80 * i);
+		dsaf_set_bit(o_sbm_cfg, DSAF_SBM_CFG_EN_S, 1);
+		dsaf_set_bit(o_sbm_cfg, DSAF_SBM_CFG_SHCUT_EN_S, 0);
+		dsaf_write_dev(dsaf_dev,
+			       DSAF_SBM_CFG_REG_0_REG + 0x80 * i, o_sbm_cfg);
+	}
+}
+
+/**
+ * hns_dsaf_sbm_cfg_mib_en - config sbm
+ * @dsaf_id: dsa fabric id
+ */
+static int hns_dsaf_sbm_cfg_mib_en(struct dsaf_device *dsaf_dev)
+{
+	u32 sbm_cfg_mib_en;
+	u32 i;
+	u32 reg;
+	u32 read_cnt;
+
+	for (i = 0; i < DSAF_SBM_NUM; i++) {
+		reg = DSAF_SBM_CFG_REG_0_REG + 0x80 * i;
+		dsaf_set_dev_bit(dsaf_dev, reg, DSAF_SBM_CFG_MIB_EN_S, 1);
+	}
+
+	/* waitint for all sbm enable finished */
+	for (i = 0; i < DSAF_SBM_NUM; i++) {
+		read_cnt = 0;
+		reg = DSAF_SBM_CFG_REG_0_REG + 0x80 * i;
+		do {
+			udelay(1);
+			sbm_cfg_mib_en = dsaf_get_dev_bit(
+					dsaf_dev, reg, DSAF_SBM_CFG_MIB_EN_S);
+			read_cnt++;
+		} while (sbm_cfg_mib_en == 0 &&
+			read_cnt < DSAF_CFG_READ_CNT);
+
+		if (sbm_cfg_mib_en == 0) {
+			dev_err(dsaf_dev->dev,
+				"sbm_cfg_mib_en fail,%s,sbm_num=%d\n",
+				dsaf_dev->ae_dev.name, i);
+			return -ENODEV;
+		}
+	}
+
+	return 0;
+}
+
+/**
+ * hns_dsaf_sbm_bp_wl_cfg - config sbm
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_sbm_bp_wl_cfg(struct dsaf_device *dsaf_dev)
+{
+	u32 o_sbm_bp_cfg0;
+	u32 o_sbm_bp_cfg1;
+	u32 o_sbm_bp_cfg2;
+	u32 o_sbm_bp_cfg3;
+	u32 reg;
+	u32 i;
+
+	/* XGE */
+	for (i = 0; i < DSAF_XGE_NUM; i++) {
+		reg = DSAF_SBM_BP_CFG_0_XGE_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg0 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg0, DSAF_SBM_CFG0_COM_MAX_BUF_NUM_M,
+			       DSAF_SBM_CFG0_COM_MAX_BUF_NUM_S, 512);
+		dsaf_set_field(o_sbm_bp_cfg0, DSAF_SBM_CFG0_VC0_MAX_BUF_NUM_M,
+			       DSAF_SBM_CFG0_VC0_MAX_BUF_NUM_S, 0);
+		dsaf_set_field(o_sbm_bp_cfg0, DSAF_SBM_CFG0_VC1_MAX_BUF_NUM_M,
+			       DSAF_SBM_CFG0_VC1_MAX_BUF_NUM_S, 0);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg0);
+
+		reg = DSAF_SBM_BP_CFG_1_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg1 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg1, DSAF_SBM_CFG1_TC4_MAX_BUF_NUM_M,
+			       DSAF_SBM_CFG1_TC4_MAX_BUF_NUM_S, 0);
+		dsaf_set_field(o_sbm_bp_cfg1, DSAF_SBM_CFG1_TC0_MAX_BUF_NUM_M,
+			       DSAF_SBM_CFG1_TC0_MAX_BUF_NUM_S, 0);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg1);
+
+		reg = DSAF_SBM_BP_CFG_2_XGE_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg2 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAF_SBM_CFG2_SET_BUF_NUM_M,
+			       DSAF_SBM_CFG2_SET_BUF_NUM_S, 104);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAF_SBM_CFG2_RESET_BUF_NUM_M,
+			       DSAF_SBM_CFG2_RESET_BUF_NUM_S, 128);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg2);
+
+		reg = DSAF_SBM_BP_CFG_3_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg3 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg3,
+			       DSAF_SBM_CFG3_SET_BUF_NUM_NO_PFC_M,
+			       DSAF_SBM_CFG3_SET_BUF_NUM_NO_PFC_S, 110);
+		dsaf_set_field(o_sbm_bp_cfg3,
+			       DSAF_SBM_CFG3_RESET_BUF_NUM_NO_PFC_M,
+			       DSAF_SBM_CFG3_RESET_BUF_NUM_NO_PFC_S, 160);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg3);
+
+		/* for no enable pfc mode */
+		reg = DSAF_SBM_BP_CFG_4_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg3 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg3,
+			       DSAF_SBM_CFG3_SET_BUF_NUM_NO_PFC_M,
+			       DSAF_SBM_CFG3_SET_BUF_NUM_NO_PFC_S, 128);
+		dsaf_set_field(o_sbm_bp_cfg3,
+			       DSAF_SBM_CFG3_RESET_BUF_NUM_NO_PFC_M,
+			       DSAF_SBM_CFG3_RESET_BUF_NUM_NO_PFC_S, 192);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg3);
+	}
+
+	/* PPE */
+	for (i = 0; i < DSAF_COMM_CHN; i++) {
+		reg = DSAF_SBM_BP_CFG_2_PPE_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg2 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAF_SBM_CFG2_SET_BUF_NUM_M,
+			       DSAF_SBM_CFG2_SET_BUF_NUM_S, 10);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAF_SBM_CFG2_RESET_BUF_NUM_M,
+			       DSAF_SBM_CFG2_RESET_BUF_NUM_S, 12);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg2);
+	}
+
+	/* RoCEE */
+	for (i = 0; i < DSAF_COMM_CHN; i++) {
+		reg = DSAF_SBM_BP_CFG_2_ROCEE_REG_0_REG + 0x80 * i;
+		o_sbm_bp_cfg2 = dsaf_read_dev(dsaf_dev, reg);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAF_SBM_CFG2_SET_BUF_NUM_M,
+			       DSAF_SBM_CFG2_SET_BUF_NUM_S, 2);
+		dsaf_set_field(o_sbm_bp_cfg2, DSAF_SBM_CFG2_RESET_BUF_NUM_M,
+			       DSAF_SBM_CFG2_RESET_BUF_NUM_S, 4);
+		dsaf_write_dev(dsaf_dev, reg, o_sbm_bp_cfg2);
+	}
+}
+
+/**
+ * hns_dsaf_voq_bp_all_thrd_cfg -  voq
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_voq_bp_all_thrd_cfg(struct dsaf_device *dsaf_dev)
+{
+	u32 voq_bp_all_thrd;
+	u32 i;
+
+	for (i = 0; i < DSAF_VOQ_NUM; i++) {
+		voq_bp_all_thrd = dsaf_read_dev(
+			dsaf_dev, DSAF_VOQ_BP_ALL_THRD_0_REG + 0x40 * i);
+		if (i < DSAF_XGE_NUM) {
+			dsaf_set_field(voq_bp_all_thrd,
+				       DSAF_VOQ_BP_ALL_DOWNTHRD_M,
+				       DSAF_VOQ_BP_ALL_DOWNTHRD_S, 930);
+			dsaf_set_field(voq_bp_all_thrd,
+				       DSAF_VOQ_BP_ALL_UPTHRD_M,
+				       DSAF_VOQ_BP_ALL_UPTHRD_S, 950);
+		} else {
+			dsaf_set_field(voq_bp_all_thrd,
+				       DSAF_VOQ_BP_ALL_DOWNTHRD_M,
+				       DSAF_VOQ_BP_ALL_DOWNTHRD_S, 220);
+			dsaf_set_field(voq_bp_all_thrd,
+				       DSAF_VOQ_BP_ALL_UPTHRD_M,
+				       DSAF_VOQ_BP_ALL_UPTHRD_S, 230);
+		}
+		dsaf_write_dev(
+			dsaf_dev, DSAF_VOQ_BP_ALL_THRD_0_REG + 0x40 * i,
+			voq_bp_all_thrd);
+	}
+}
+
+/**
+ * hns_dsaf_tbl_tcam_data_cfg - tbl
+ * @dsaf_id: dsa fabric id
+ * @ptbl_tcam_data: addr
+ */
+static void hns_dsaf_tbl_tcam_data_cfg(
+	struct dsaf_device *dsaf_dev,
+	struct dsaf_tbl_tcam_data *ptbl_tcam_data)
+{
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_LOW_0_REG,
+		       ptbl_tcam_data->tbl_tcam_data_low);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_HIGH_0_REG,
+		       ptbl_tcam_data->tbl_tcam_data_high);
+}
+
+/**
+ * dsaf_tbl_tcam_mcast_cfg - tbl
+ * @dsaf_id: dsa fabric id
+ * @ptbl_tcam_mcast: addr
+ */
+static void hns_dsaf_tbl_tcam_mcast_cfg(
+	struct dsaf_device *dsaf_dev,
+	struct dsaf_tbl_tcam_mcast_cfg *mcast)
+{
+	u32 mcast_cfg4;
+
+	mcast_cfg4 = dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_MCAST_CFG_4_0_REG);
+	dsaf_set_bit(mcast_cfg4, DSAF_TBL_MCAST_CFG4_ITEM_VLD_S,
+		     mcast->tbl_mcast_item_vld);
+	dsaf_set_bit(mcast_cfg4, DSAF_TBL_MCAST_CFG4_OLD_EN_S,
+		     mcast->tbl_mcast_old_en);
+	dsaf_set_field(mcast_cfg4, DSAF_TBL_MCAST_CFG4_VM128_112_M,
+		       DSAF_TBL_MCAST_CFG4_VM128_112_S,
+		       mcast->tbl_mcast_port_msk[4]);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MCAST_CFG_4_0_REG, mcast_cfg4);
+
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MCAST_CFG_3_0_REG,
+		       mcast->tbl_mcast_port_msk[3]);
+
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MCAST_CFG_2_0_REG,
+		       mcast->tbl_mcast_port_msk[2]);
+
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MCAST_CFG_1_0_REG,
+		       mcast->tbl_mcast_port_msk[1]);
+
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MCAST_CFG_0_0_REG,
+		       mcast->tbl_mcast_port_msk[0]);
+}
+
+/**
+ * hns_dsaf_tbl_tcam_ucast_cfg - tbl
+ * @dsaf_id: dsa fabric id
+ * @ptbl_tcam_ucast: addr
+ */
+static void hns_dsaf_tbl_tcam_ucast_cfg(
+	struct dsaf_device *dsaf_dev,
+	struct dsaf_tbl_tcam_ucast_cfg *tbl_tcam_ucast)
+{
+	u32 ucast_cfg1;
+
+	ucast_cfg1 = dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_UCAST_CFG_0_REG);
+	dsaf_set_bit(ucast_cfg1, DSAF_TBL_UCAST_CFG1_MAC_DISCARD_S,
+		     tbl_tcam_ucast->tbl_ucast_mac_discard);
+	dsaf_set_bit(ucast_cfg1, DSAF_TBL_UCAST_CFG1_ITEM_VLD_S,
+		     tbl_tcam_ucast->tbl_ucast_item_vld);
+	dsaf_set_bit(ucast_cfg1, DSAF_TBL_UCAST_CFG1_OLD_EN_S,
+		     tbl_tcam_ucast->tbl_ucast_old_en);
+	dsaf_set_bit(ucast_cfg1, DSAF_TBL_UCAST_CFG1_DVC_S,
+		     tbl_tcam_ucast->tbl_ucast_dvc);
+	dsaf_set_field(ucast_cfg1, DSAF_TBL_UCAST_CFG1_OUT_PORT_M,
+		       DSAF_TBL_UCAST_CFG1_OUT_PORT_S,
+		       tbl_tcam_ucast->tbl_ucast_out_port);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_UCAST_CFG_0_REG, ucast_cfg1);
+}
+
+/**
+ * hns_dsaf_tbl_line_cfg - tbl
+ * @dsaf_id: dsa fabric id
+ * @ptbl_lin: addr
+ */
+static void hns_dsaf_tbl_line_cfg(struct dsaf_device *dsaf_dev,
+				  struct dsaf_tbl_line_cfg *tbl_lin)
+{
+	u32 tbl_line;
+
+	tbl_line = dsaf_read_dev(dsaf_dev, DSAF_TBL_LIN_CFG_0_REG);
+	dsaf_set_bit(tbl_line, DSAF_TBL_LINE_CFG_MAC_DISCARD_S,
+		     tbl_lin->tbl_line_mac_discard);
+	dsaf_set_bit(tbl_line, DSAF_TBL_LINE_CFG_DVC_S,
+		     tbl_lin->tbl_line_dvc);
+	dsaf_set_field(tbl_line, DSAF_TBL_LINE_CFG_OUT_PORT_M,
+		       DSAF_TBL_LINE_CFG_OUT_PORT_S,
+		       tbl_lin->tbl_line_out_port);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_LIN_CFG_0_REG, tbl_line);
+}
+
+/**
+ * hns_dsaf_tbl_tcam_mcast_pul - tbl
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_tbl_tcam_mcast_pul(struct dsaf_device *dsaf_dev)
+{
+	u32 o_tbl_pul;
+
+	o_tbl_pul = dsaf_read_dev(dsaf_dev, DSAF_TBL_PUL_0_REG);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_MCAST_VLD_S, 1);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_PUL_0_REG, o_tbl_pul);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_MCAST_VLD_S, 0);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_PUL_0_REG, o_tbl_pul);
+}
+
+/**
+ * hns_dsaf_tbl_line_pul - tbl
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_tbl_line_pul(struct dsaf_device *dsaf_dev)
+{
+	u32 tbl_pul;
+
+	tbl_pul = dsaf_read_dev(dsaf_dev, DSAF_TBL_PUL_0_REG);
+	dsaf_set_bit(tbl_pul, DSAF_TBL_PUL_LINE_VLD_S, 1);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_PUL_0_REG, tbl_pul);
+	dsaf_set_bit(tbl_pul, DSAF_TBL_PUL_LINE_VLD_S, 0);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_PUL_0_REG, tbl_pul);
+}
+
+/**
+ * hns_dsaf_tbl_tcam_data_mcast_pul - tbl
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_tbl_tcam_data_mcast_pul(
+	struct dsaf_device *dsaf_dev)
+{
+	u32 o_tbl_pul;
+
+	o_tbl_pul = dsaf_read_dev(dsaf_dev, DSAF_TBL_PUL_0_REG);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_TCAM_DATA_VLD_S, 1);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_MCAST_VLD_S, 1);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_PUL_0_REG, o_tbl_pul);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_TCAM_DATA_VLD_S, 0);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_MCAST_VLD_S, 0);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_PUL_0_REG, o_tbl_pul);
+}
+
+/**
+ * hns_dsaf_tbl_tcam_data_ucast_pul - tbl
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_tbl_tcam_data_ucast_pul(
+	struct dsaf_device *dsaf_dev)
+{
+	u32 o_tbl_pul;
+
+	o_tbl_pul = dsaf_read_dev(dsaf_dev, DSAF_TBL_PUL_0_REG);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_TCAM_DATA_VLD_S, 1);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_UCAST_VLD_S, 1);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_PUL_0_REG, o_tbl_pul);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_TCAM_DATA_VLD_S, 0);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_UCAST_VLD_S, 0);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_PUL_0_REG, o_tbl_pul);
+}
+
+/**
+ * hns_dsaf_tbl_stat_en - tbl
+ * @dsaf_id: dsa fabric id
+ * @ptbl_stat_en: addr
+ */
+static void hns_dsaf_tbl_stat_en(struct dsaf_device *dsaf_dev)
+{
+	u32 o_tbl_ctrl;
+
+	o_tbl_ctrl = dsaf_read_dev(dsaf_dev, DSAF_TBL_DFX_CTRL_0_REG);
+	dsaf_set_bit(o_tbl_ctrl, DSAF_TBL_DFX_LINE_LKUP_NUM_EN_S, 1);
+	dsaf_set_bit(o_tbl_ctrl, DSAF_TBL_DFX_UC_LKUP_NUM_EN_S, 1);
+	dsaf_set_bit(o_tbl_ctrl, DSAF_TBL_DFX_MC_LKUP_NUM_EN_S, 1);
+	dsaf_set_bit(o_tbl_ctrl, DSAF_TBL_DFX_BC_LKUP_NUM_EN_S, 1);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_DFX_CTRL_0_REG, o_tbl_ctrl);
+}
+
+/**
+ * hns_dsaf_rocee_bp_en - rocee back press enable
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_rocee_bp_en(struct dsaf_device *dsaf_dev)
+{
+	dsaf_set_dev_bit(dsaf_dev, DSAF_XGE_CTRL_SIG_CFG_0_REG,
+			 DSAF_FC_XGE_TX_PAUSE_S, 1);
+}
+
+/* set msk for dsaf exception irq*/
+static void hns_dsaf_int_xge_msk_set(struct dsaf_device *dsaf_dev,
+				     u32 chnn_num, u32 mask_set)
+{
+	dsaf_write_dev(dsaf_dev,
+		       DSAF_XGE_INT_MSK_0_REG + 0x4 * chnn_num, mask_set);
+}
+
+static void hns_dsaf_int_ppe_msk_set(struct dsaf_device *dsaf_dev,
+				     u32 chnn_num, u32 msk_set)
+{
+	dsaf_write_dev(dsaf_dev,
+		       DSAF_PPE_INT_MSK_0_REG + 0x4 * chnn_num, msk_set);
+}
+
+static void hns_dsaf_int_rocee_msk_set(struct dsaf_device *dsaf_dev,
+				       u32 chnn, u32 msk_set)
+{
+	dsaf_write_dev(dsaf_dev,
+		       DSAF_ROCEE_INT_MSK_0_REG + 0x4 * chnn, msk_set);
+}
+
+static void
+hns_dsaf_int_tbl_msk_set(struct dsaf_device *dsaf_dev, u32 msk_set)
+{
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_INT_MSK_0_REG, msk_set);
+}
+
+/* clr dsaf exception irq*/
+static void hns_dsaf_int_xge_src_clr(struct dsaf_device *dsaf_dev,
+				     u32 chnn_num, u32 int_src)
+{
+	dsaf_write_dev(dsaf_dev,
+		       DSAF_XGE_INT_SRC_0_REG + 0x4 * chnn_num, int_src);
+}
+
+static void hns_dsaf_int_ppe_src_clr(struct dsaf_device *dsaf_dev,
+				     u32 chnn, u32 int_src)
+{
+	dsaf_write_dev(dsaf_dev,
+		       DSAF_PPE_INT_SRC_0_REG + 0x4 * chnn, int_src);
+}
+
+static void hns_dsaf_int_rocee_src_clr(struct dsaf_device *dsaf_dev,
+				       u32 chnn, u32 int_src)
+{
+	dsaf_write_dev(dsaf_dev,
+		       DSAF_ROCEE_INT_SRC_0_REG + 0x4 * chnn, int_src);
+}
+
+static void hns_dsaf_int_tbl_src_clr(struct dsaf_device *dsaf_dev,
+				     u32 int_src)
+{
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_INT_SRC_0_REG, int_src);
+}
+
+/**
+ * hns_dsaf_single_line_tbl_cfg - INT
+ * @dsaf_id: dsa fabric id
+ * @address:
+ * @ptbl_line:
+ */
+static void hns_dsaf_single_line_tbl_cfg(
+	struct dsaf_device *dsaf_dev,
+	u32 address, struct dsaf_tbl_line_cfg *ptbl_line)
+{
+	/*Write Addr*/
+	hns_dsaf_tbl_line_addr_cfg(dsaf_dev, address);
+
+	/*Write Line*/
+	hns_dsaf_tbl_line_cfg(dsaf_dev, ptbl_line);
+
+	/*Write Plus*/
+	hns_dsaf_tbl_line_pul(dsaf_dev);
+}
+
+/**
+ * hns_dsaf_tcam_uc_cfg - INT
+ * @dsaf_id: dsa fabric id
+ * @address,
+ * @ptbl_tcam_data,
+ */
+static void hns_dsaf_tcam_uc_cfg(
+	struct dsaf_device *dsaf_dev, u32 address,
+	struct dsaf_tbl_tcam_data *ptbl_tcam_data,
+	struct dsaf_tbl_tcam_ucast_cfg *ptbl_tcam_ucast)
+{
+	/*Write Addr*/
+	hns_dsaf_tbl_tcam_addr_cfg(dsaf_dev, address);
+	/*Write Tcam Data*/
+	hns_dsaf_tbl_tcam_data_cfg(dsaf_dev, ptbl_tcam_data);
+	/*Write Tcam Ucast*/
+	hns_dsaf_tbl_tcam_ucast_cfg(dsaf_dev, ptbl_tcam_ucast);
+	/*Write Plus*/
+	hns_dsaf_tbl_tcam_data_ucast_pul(dsaf_dev);
+}
+
+/**
+ * hns_dsaf_tcam_mc_cfg - INT
+ * @dsaf_id: dsa fabric id
+ * @address,
+ * @ptbl_tcam_data,
+ * @ptbl_tcam_mcast,
+ */
+static void hns_dsaf_tcam_mc_cfg(
+	struct dsaf_device *dsaf_dev, u32 address,
+	struct dsaf_tbl_tcam_data *ptbl_tcam_data,
+	struct dsaf_tbl_tcam_mcast_cfg *ptbl_tcam_mcast)
+{
+	/*Write Addr*/
+	hns_dsaf_tbl_tcam_addr_cfg(dsaf_dev, address);
+	/*Write Tcam Data*/
+	hns_dsaf_tbl_tcam_data_cfg(dsaf_dev, ptbl_tcam_data);
+	/*Write Tcam Mcast*/
+	hns_dsaf_tbl_tcam_mcast_cfg(dsaf_dev, ptbl_tcam_mcast);
+	/*Write Plus*/
+	hns_dsaf_tbl_tcam_data_mcast_pul(dsaf_dev);
+}
+
+/**
+ * hns_dsaf_tcam_mc_invld - INT
+ * @dsaf_id: dsa fabric id
+ * @address
+ */
+static void hns_dsaf_tcam_mc_invld(struct dsaf_device *dsaf_dev, u32 address)
+{
+	/*Write Addr*/
+	hns_dsaf_tbl_tcam_addr_cfg(dsaf_dev, address);
+
+	/*write tcam mcast*/
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MCAST_CFG_0_0_REG, 0);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MCAST_CFG_1_0_REG, 0);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MCAST_CFG_2_0_REG, 0);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MCAST_CFG_3_0_REG, 0);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MCAST_CFG_4_0_REG, 0);
+
+	/*Write Plus*/
+	hns_dsaf_tbl_tcam_mcast_pul(dsaf_dev);
+}
+
+/**
+ * hns_dsaf_tcam_uc_get - INT
+ * @dsaf_id: dsa fabric id
+ * @address
+ * @ptbl_tcam_data
+ * @ptbl_tcam_ucast
+ */
+static void hns_dsaf_tcam_uc_get(
+	struct dsaf_device *dsaf_dev, u32 address,
+	struct dsaf_tbl_tcam_data *ptbl_tcam_data,
+	struct dsaf_tbl_tcam_ucast_cfg *ptbl_tcam_ucast)
+{
+	u32 tcam_read_data0;
+	u32 tcam_read_data4;
+
+	/*Write Addr*/
+	hns_dsaf_tbl_tcam_addr_cfg(dsaf_dev, address);
+
+	/*read tcam item puls*/
+	hns_dsaf_tbl_tcam_load_pul(dsaf_dev);
+
+	/*read tcam data*/
+	ptbl_tcam_data->tbl_tcam_data_high
+		= dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RDATA_LOW_0_REG);
+	ptbl_tcam_data->tbl_tcam_data_low
+		= dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RDATA_HIGH_0_REG);
+
+	/*read tcam mcast*/
+	tcam_read_data0 = dsaf_read_dev(dsaf_dev,
+					DSAF_TBL_TCAM_RAM_RDATA0_0_REG);
+	tcam_read_data4 = dsaf_read_dev(dsaf_dev,
+					DSAF_TBL_TCAM_RAM_RDATA4_0_REG);
+
+	ptbl_tcam_ucast->tbl_ucast_item_vld
+		= dsaf_get_bit(tcam_read_data4,
+			       DSAF_TBL_MCAST_CFG4_ITEM_VLD_S);
+	ptbl_tcam_ucast->tbl_ucast_old_en
+		= dsaf_get_bit(tcam_read_data4, DSAF_TBL_MCAST_CFG4_OLD_EN_S);
+	ptbl_tcam_ucast->tbl_ucast_mac_discard
+		= dsaf_get_bit(tcam_read_data0,
+			       DSAF_TBL_UCAST_CFG1_MAC_DISCARD_S);
+	ptbl_tcam_ucast->tbl_ucast_out_port
+		= dsaf_get_field(tcam_read_data0,
+				 DSAF_TBL_UCAST_CFG1_OUT_PORT_M,
+				 DSAF_TBL_UCAST_CFG1_OUT_PORT_S);
+	ptbl_tcam_ucast->tbl_ucast_dvc
+		= dsaf_get_bit(tcam_read_data0, DSAF_TBL_UCAST_CFG1_DVC_S);
+}
+
+/**
+ * hns_dsaf_tcam_mc_get - INT
+ * @dsaf_id: dsa fabric id
+ * @address
+ * @ptbl_tcam_data
+ * @ptbl_tcam_ucast
+ */
+static void hns_dsaf_tcam_mc_get(
+	struct dsaf_device *dsaf_dev, u32 address,
+	struct dsaf_tbl_tcam_data *ptbl_tcam_data,
+	struct dsaf_tbl_tcam_mcast_cfg *ptbl_tcam_mcast)
+{
+	u32 data_tmp;
+
+	/*Write Addr*/
+	hns_dsaf_tbl_tcam_addr_cfg(dsaf_dev, address);
+
+	/*read tcam item puls*/
+	hns_dsaf_tbl_tcam_load_pul(dsaf_dev);
+
+	/*read tcam data*/
+	ptbl_tcam_data->tbl_tcam_data_high =
+		dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RDATA_LOW_0_REG);
+	ptbl_tcam_data->tbl_tcam_data_low =
+		dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RDATA_HIGH_0_REG);
+
+	/*read tcam mcast*/
+	ptbl_tcam_mcast->tbl_mcast_port_msk[0] =
+		dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RAM_RDATA0_0_REG);
+	ptbl_tcam_mcast->tbl_mcast_port_msk[1] =
+		dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RAM_RDATA1_0_REG);
+	ptbl_tcam_mcast->tbl_mcast_port_msk[2] =
+		dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RAM_RDATA2_0_REG);
+	ptbl_tcam_mcast->tbl_mcast_port_msk[3] =
+		dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RAM_RDATA3_0_REG);
+
+	data_tmp = dsaf_read_dev(dsaf_dev, DSAF_TBL_TCAM_RAM_RDATA4_0_REG);
+	ptbl_tcam_mcast->tbl_mcast_item_vld =
+		dsaf_get_bit(data_tmp, DSAF_TBL_MCAST_CFG4_ITEM_VLD_S);
+	ptbl_tcam_mcast->tbl_mcast_old_en =
+		dsaf_get_bit(data_tmp, DSAF_TBL_MCAST_CFG4_OLD_EN_S);
+	ptbl_tcam_mcast->tbl_mcast_port_msk[4] =
+		dsaf_get_field(data_tmp, DSAF_TBL_MCAST_CFG4_VM128_112_M,
+			       DSAF_TBL_MCAST_CFG4_VM128_112_S);
+}
+
+/**
+ * hns_dsaf_tbl_line_init - INT
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_tbl_line_init(struct dsaf_device *dsaf_dev)
+{
+	u32 i;
+	/* defaultly set all lineal mac table entry resulting discard */
+	struct dsaf_tbl_line_cfg tbl_line[] = {{1, 0, 0} };
+
+	for (i = 0; i < DSAF_LINE_SUM; i++)
+		hns_dsaf_single_line_tbl_cfg(dsaf_dev, i, tbl_line);
+}
+
+/**
+ * hns_dsaf_tbl_tcam_init - INT
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_tbl_tcam_init(struct dsaf_device *dsaf_dev)
+{
+	u32 i;
+	struct dsaf_tbl_tcam_data tcam_data[] = {{0, 0} };
+	struct dsaf_tbl_tcam_ucast_cfg tcam_ucast[] = {{0, 0, 0, 0, 0} };
+
+	/*tcam tbl*/
+	for (i = 0; i < DSAF_TCAM_SUM; i++)
+		hns_dsaf_tcam_uc_cfg(dsaf_dev, i, tcam_data, tcam_ucast);
+}
+
+/**
+ * hns_dsaf_pfc_en_cfg - dsaf pfc pause cfg
+ * @mac_cb: mac contrl block
+ */
+static void hns_dsaf_pfc_en_cfg(struct dsaf_device *dsaf_dev,
+				int mac_id, int en)
+{
+	if (!en)
+		dsaf_write_dev(dsaf_dev, DSAF_PFC_EN_0_REG + mac_id * 4, 0);
+	else
+		dsaf_write_dev(dsaf_dev, DSAF_PFC_EN_0_REG + mac_id * 4, 0xff);
+}
+
+/**
+ * hns_dsaf_tbl_tcam_init - INT
+ * @dsaf_id: dsa fabric id
+ * @dsaf_mode
+ */
+static void hns_dsaf_comm_init(struct dsaf_device *dsaf_dev)
+{
+	u32 i;
+	u32 o_dsaf_cfg;
+
+	o_dsaf_cfg = dsaf_read_dev(dsaf_dev, DSAF_CFG_0_REG);
+	dsaf_set_bit(o_dsaf_cfg, DSAF_CFG_EN_S, dsaf_dev->dsaf_en);
+	dsaf_set_bit(o_dsaf_cfg, DSAF_CFG_TC_MODE_S, dsaf_dev->dsaf_tc_mode);
+	dsaf_set_bit(o_dsaf_cfg, DSAF_CFG_CRC_EN_S, 0);
+	dsaf_set_bit(o_dsaf_cfg, DSAF_CFG_MIX_MODE_S, 0);
+	dsaf_set_bit(o_dsaf_cfg, DSAF_CFG_LOCA_ADDR_EN_S, 0);
+	dsaf_write_dev(dsaf_dev, DSAF_CFG_0_REG, o_dsaf_cfg);
+
+	hns_dsaf_reg_cnt_clr_ce(dsaf_dev, 1);
+	hns_dsaf_stp_port_type_cfg(dsaf_dev, DSAF_STP_PORT_TYPE_FORWARD);
+
+	/* set 22 queue per tx ppe engine, only used in switch mode */
+	hns_dsaf_ppe_qid_cfg(dsaf_dev, DSAF_DEFAUTL_QUEUE_NUM_PER_PPE);
+
+	/* in non switch mode, set all port to access mode */
+	hns_dsaf_sw_port_type_cfg(dsaf_dev, DSAF_SW_PORT_TYPE_NON_VLAN);
+
+	/*set dsaf pfc  to 0 for parseing rx pause*/
+	for (i = 0; i < DSAF_COMM_CHN; i++)
+		hns_dsaf_pfc_en_cfg(dsaf_dev, i, 0);
+
+	/*msk and  clr exception irqs */
+	for (i = 0; i < DSAF_COMM_CHN; i++) {
+		hns_dsaf_int_xge_src_clr(dsaf_dev, i, 0xfffffffful);
+		hns_dsaf_int_ppe_src_clr(dsaf_dev, i, 0xfffffffful);
+		hns_dsaf_int_rocee_src_clr(dsaf_dev, i, 0xfffffffful);
+
+		hns_dsaf_int_xge_msk_set(dsaf_dev, i, 0xfffffffful);
+		hns_dsaf_int_ppe_msk_set(dsaf_dev, i, 0xfffffffful);
+		hns_dsaf_int_rocee_msk_set(dsaf_dev, i, 0xfffffffful);
+	}
+	hns_dsaf_int_tbl_src_clr(dsaf_dev, 0xfffffffful);
+	hns_dsaf_int_tbl_msk_set(dsaf_dev, 0xfffffffful);
+}
+
+/**
+ * hns_dsaf_inode_init - INT
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_inode_init(struct dsaf_device *dsaf_dev)
+{
+	u32 reg;
+	u32 tc_cfg;
+	u32 i;
+
+	if (dsaf_dev->dsaf_tc_mode == HRD_DSAF_4TC_MODE)
+		tc_cfg = HNS_DSAF_I4TC_CFG;
+	else
+		tc_cfg = HNS_DSAF_I8TC_CFG;
+
+	for (i = 0; i < DSAF_INODE_NUM; i++) {
+		reg = DSAF_INODE_IN_PORT_NUM_0_REG + 0x80 * i;
+		dsaf_set_dev_field(dsaf_dev, reg, DSAF_INODE_IN_PORT_NUM_M,
+				   DSAF_INODE_IN_PORT_NUM_S, i % DSAF_XGE_NUM);
+
+		reg = DSAF_INODE_PRI_TC_CFG_0_REG + 0x80 * i;
+		dsaf_write_dev(dsaf_dev, reg, tc_cfg);
+	}
+}
+
+/**
+ * hns_dsaf_sbm_init - INT
+ * @dsaf_id: dsa fabric id
+ */
+static int hns_dsaf_sbm_init(struct dsaf_device *dsaf_dev)
+{
+	u32 flag;
+	u32 cnt = 0;
+	int ret;
+
+	hns_dsaf_sbm_bp_wl_cfg(dsaf_dev);
+
+	/* enable sbm chanel, disable sbm chanel shcut function*/
+	hns_dsaf_sbm_cfg(dsaf_dev);
+
+	/* enable sbm mib */
+	ret = hns_dsaf_sbm_cfg_mib_en(dsaf_dev);
+	if (ret) {
+		dev_err(dsaf_dev->dev,
+			"hns_dsaf_sbm_cfg_mib_en fail,%s, ret=%d\n",
+			dsaf_dev->ae_dev.name, ret);
+		return ret;
+	}
+
+	/* enable sbm initial link sram */
+	hns_dsaf_sbm_link_sram_init_en(dsaf_dev);
+
+	do {
+		usleep_range(200, 210);/*udelay(200);*/
+		flag = dsaf_read_dev(dsaf_dev, DSAF_SRAM_INIT_OVER_0_REG);
+		cnt++;
+	} while (flag != DSAF_SRAM_INIT_FINISH_FLAG && cnt < DSAF_CFG_READ_CNT);
+
+	if (flag != DSAF_SRAM_INIT_FINISH_FLAG) {
+		dev_err(dsaf_dev->dev,
+			"hns_dsaf_sbm_init fail %s, flag=%d, cnt=%d\n",
+			dsaf_dev->ae_dev.name, flag, cnt);
+		return -ENODEV;
+	}
+
+	hns_dsaf_rocee_bp_en(dsaf_dev);
+
+	return 0;
+}
+
+/**
+ * hns_dsaf_tbl_init - INT
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_tbl_init(struct dsaf_device *dsaf_dev)
+{
+	hns_dsaf_tbl_stat_en(dsaf_dev);
+
+	hns_dsaf_tbl_tcam_init(dsaf_dev);
+	hns_dsaf_tbl_line_init(dsaf_dev);
+}
+
+/**
+ * hns_dsaf_voq_init - INT
+ * @dsaf_id: dsa fabric id
+ */
+static void hns_dsaf_voq_init(struct dsaf_device *dsaf_dev)
+{
+	hns_dsaf_voq_bp_all_thrd_cfg(dsaf_dev);
+}
+
+/**
+ * hns_dsaf_init_hw - init dsa fabric hardware
+ * @dsaf_dev: dsa fabric device struct pointer
+ */
+static int hns_dsaf_init_hw(struct dsaf_device *dsaf_dev)
+{
+	int ret;
+
+	dev_dbg(dsaf_dev->dev,
+		"hns_dsaf_init_hw begin %s !\n", dsaf_dev->ae_dev.name);
+
+	hns_dsaf_rst(dsaf_dev, 0);
+	mdelay(10);
+	hns_dsaf_rst(dsaf_dev, 1);
+
+	hns_dsaf_comm_init(dsaf_dev);
+
+	/*init XBAR_INODE*/
+	hns_dsaf_inode_init(dsaf_dev);
+
+	/*init SBM*/
+	ret = hns_dsaf_sbm_init(dsaf_dev);
+	if (ret)
+		return ret;
+
+	/*init TBL*/
+	hns_dsaf_tbl_init(dsaf_dev);
+
+	/*init VOQ*/
+	hns_dsaf_voq_init(dsaf_dev);
+
+	return 0;
+}
+
+/**
+ * hns_dsaf_remove_hw - uninit dsa fabric hardware
+ * @dsaf_dev: dsa fabric device struct pointer
+ */
+static void hns_dsaf_remove_hw(struct dsaf_device *dsaf_dev)
+{
+	/*reset*/
+	hns_dsaf_rst(dsaf_dev, 0);
+}
+
+/**
+ * hns_dsaf_init - init dsa fabric
+ * @dsaf_dev: dsa fabric device struct pointer
+ * retuen 0 - success , negative --fail
+ */
+static int hns_dsaf_init(struct dsaf_device *dsaf_dev)
+{
+	struct dsaf_drv_priv *priv =
+	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
+	u32 i;
+	int ret;
+
+	ret = hns_dsaf_init_hw(dsaf_dev);
+	if (ret)
+		return ret;
+
+	/* malloc mem for tcam mac key(vlan+mac) */
+	priv->soft_mac_tbl = vzalloc(sizeof(*priv->soft_mac_tbl)
+		  * DSAF_TCAM_SUM);
+	if (!priv->soft_mac_tbl) {
+		ret = -ENOMEM;
+		goto remove_hw;
+	}
+
+	/*all entry invall */
+	for (i = 0; i < DSAF_TCAM_SUM; i++)
+		(priv->soft_mac_tbl + i)->index = DSAF_INVALID_ENTRY_IDX;
+
+	return 0;
+
+remove_hw:
+	hns_dsaf_remove_hw(dsaf_dev);
+	return ret;
+}
+
+/**
+ * hns_dsaf_free - free dsa fabric
+ * @dsaf_dev: dsa fabric device struct pointer
+ */
+static void hns_dsaf_free(struct dsaf_device *dsaf_dev)
+{
+	struct dsaf_drv_priv *priv =
+	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
+
+	hns_dsaf_remove_hw(dsaf_dev);
+
+	/* free all mac mem */
+	vfree(priv->soft_mac_tbl);
+	priv->soft_mac_tbl = NULL;
+}
+
+/**
+ * hns_dsaf_find_soft_mac_entry - find dsa fabric soft entry
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @mac_key: mac entry struct pointer
+ */
+static u16 hns_dsaf_find_soft_mac_entry(
+	struct dsaf_device *dsaf_dev,
+	struct dsaf_drv_tbl_tcam_key *mac_key)
+{
+	struct dsaf_drv_priv *priv =
+	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
+	struct dsaf_drv_soft_mac_tbl *soft_mac_entry;
+	u32 i;
+
+	soft_mac_entry = priv->soft_mac_tbl;
+	for (i = 0; i < DSAF_TCAM_SUM; i++) {
+		/* invall tab entry */
+		if ((soft_mac_entry->index != DSAF_INVALID_ENTRY_IDX) &&
+		    (soft_mac_entry->tcam_key.high.val == mac_key->high.val) &&
+		    (soft_mac_entry->tcam_key.low.val == mac_key->low.val))
+			/* return find result --soft index */
+			return soft_mac_entry->index;
+
+		soft_mac_entry++;
+	}
+	return DSAF_INVALID_ENTRY_IDX;
+}
+
+/**
+ * hns_dsaf_find_empty_mac_entry - search dsa fabric soft empty-entry
+ * @dsaf_dev: dsa fabric device struct pointer
+ */
+static u16 hns_dsaf_find_empty_mac_entry(struct dsaf_device *dsaf_dev)
+{
+	struct dsaf_drv_priv *priv =
+	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
+	struct dsaf_drv_soft_mac_tbl *soft_mac_entry;
+	u32 i;
+
+	soft_mac_entry = priv->soft_mac_tbl;
+	for (i = 0; i < DSAF_TCAM_SUM; i++) {
+		/* inv all entry */
+		if (soft_mac_entry->index == DSAF_INVALID_ENTRY_IDX)
+			/* return find result --soft index */
+			return i;
+
+		soft_mac_entry++;
+	}
+	return DSAF_INVALID_ENTRY_IDX;
+}
+
+/**
+ * hns_dsaf_set_mac_key - set mac key
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @mac_key: tcam key pointer
+ * @vlan_id: vlan id
+ * @in_port_num: input port num
+ * @addr: mac addr
+ */
+static void hns_dsaf_set_mac_key(
+	struct dsaf_device *dsaf_dev,
+	struct dsaf_drv_tbl_tcam_key *mac_key, u16 vlan_id, u8 in_port_num,
+	u8 *addr)
+{
+	u8 port;
+
+	if (dsaf_dev->dsaf_mode <= DSAF_MODE_ENABLE)
+		/*DSAF mode : in port id fixed 0*/
+		port = 0;
+	else
+		/*non-dsaf mode*/
+		port = in_port_num;
+
+	mac_key->high.bits.mac_0 = addr[0];
+	mac_key->high.bits.mac_1 = addr[1];
+	mac_key->high.bits.mac_2 = addr[2];
+	mac_key->high.bits.mac_3 = addr[3];
+	mac_key->low.bits.mac_4 = addr[4];
+	mac_key->low.bits.mac_5 = addr[5];
+	mac_key->low.bits.vlan = vlan_id;
+	mac_key->low.bits.port = port;
+}
+
+/**
+ * hns_dsaf_set_mac_uc_entry - set mac uc-entry
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @mac_entry: uc-mac entry
+ */
+int hns_dsaf_set_mac_uc_entry(
+	struct dsaf_device *dsaf_dev,
+	struct dsaf_drv_mac_single_dest_entry *mac_entry)
+{
+	u16 entry_index = DSAF_INVALID_ENTRY_IDX;
+	struct dsaf_drv_tbl_tcam_key mac_key;
+	struct dsaf_tbl_tcam_ucast_cfg mac_data;
+	struct dsaf_drv_priv *priv =
+	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
+	struct dsaf_drv_soft_mac_tbl *soft_mac_entry = priv->soft_mac_tbl;
+
+	/* mac addr check */
+	if (MAC_IS_ALL_ZEROS(mac_entry->addr) ||
+	    MAC_IS_BROADCAST(mac_entry->addr) ||
+	    MAC_IS_MULTICAST(mac_entry->addr)) {
+		dev_err(dsaf_dev->dev,
+			"set_uc %s Mac %02x:%02x:%02x:%02x:%02x:%02x err!\n",
+			dsaf_dev->ae_dev.name, mac_entry->addr[0],
+			mac_entry->addr[1], mac_entry->addr[2],
+			mac_entry->addr[3], mac_entry->addr[4],
+			mac_entry->addr[5]);
+		return -EINVAL;
+	}
+
+	/* config key */
+	hns_dsaf_set_mac_key(dsaf_dev, &mac_key, mac_entry->in_vlan_id,
+			     mac_entry->in_port_num, mac_entry->addr);
+
+	/* entry ie exist? */
+	entry_index = hns_dsaf_find_soft_mac_entry(dsaf_dev, &mac_key);
+	if (entry_index == DSAF_INVALID_ENTRY_IDX) {
+		/*if has not inv entry,find a empty entry */
+		entry_index = hns_dsaf_find_empty_mac_entry(dsaf_dev);
+		if (entry_index == DSAF_INVALID_ENTRY_IDX) {
+			/* has not empty,return error */
+			dev_err(dsaf_dev->dev,
+				"set_uc_entry failed, %s Mac key(%#x:%#x)\n",
+				dsaf_dev->ae_dev.name,
+				mac_key.high.val, mac_key.low.val);
+			return -EINVAL;
+		}
+	}
+
+	dev_dbg(dsaf_dev->dev,
+		"set_uc_entry, %s Mac key(%#x:%#x) entry_index%d\n",
+		dsaf_dev->ae_dev.name, mac_key.high.val,
+		mac_key.low.val, entry_index);
+
+	/* config hardware entry */
+	mac_data.tbl_ucast_item_vld = 1;
+	mac_data.tbl_ucast_mac_discard = 0;
+	mac_data.tbl_ucast_old_en = 0;
+	/* default config dvc to 0 */
+	mac_data.tbl_ucast_dvc = 0;
+	mac_data.tbl_ucast_out_port = mac_entry->port_num;
+	hns_dsaf_tcam_uc_cfg(
+		dsaf_dev, entry_index,
+		(struct dsaf_tbl_tcam_data *)(&mac_key), &mac_data);
+
+	/* config software entry */
+	soft_mac_entry += entry_index;
+	soft_mac_entry->index = entry_index;
+	soft_mac_entry->tcam_key.high.val = mac_key.high.val;
+	soft_mac_entry->tcam_key.low.val = mac_key.low.val;
+
+	return 0;
+}
+
+/**
+ * hns_dsaf_set_mac_mc_entry - set mac mc-entry
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @mac_entry: mc-mac entry
+ */
+int hns_dsaf_set_mac_mc_entry(
+	struct dsaf_device *dsaf_dev,
+	struct dsaf_drv_mac_multi_dest_entry *mac_entry)
+{
+	u16 entry_index = DSAF_INVALID_ENTRY_IDX;
+	struct dsaf_drv_tbl_tcam_key mac_key;
+	struct dsaf_tbl_tcam_mcast_cfg mac_data;
+	struct dsaf_drv_priv *priv =
+	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
+	struct dsaf_drv_soft_mac_tbl *soft_mac_entry = priv->soft_mac_tbl;
+	struct dsaf_drv_tbl_tcam_key tmp_mac_key;
+
+	/* mac addr check */
+	if (MAC_IS_ALL_ZEROS(mac_entry->addr)) {
+		dev_err(dsaf_dev->dev,
+			"set uc %s Mac %02x:%02x:%02x:%02x:%02x:%02x err!\n",
+			dsaf_dev->ae_dev.name, mac_entry->addr[0],
+			mac_entry->addr[1], mac_entry->addr[2],
+			mac_entry->addr[3],
+			mac_entry->addr[4], mac_entry->addr[5]);
+		return -EINVAL;
+	}
+
+	/*config key */
+	hns_dsaf_set_mac_key(dsaf_dev, &mac_key,
+			     mac_entry->in_vlan_id,
+			     mac_entry->in_port_num, mac_entry->addr);
+
+	/* entry ie exist? */
+	entry_index = hns_dsaf_find_soft_mac_entry(dsaf_dev, &mac_key);
+	if (entry_index == DSAF_INVALID_ENTRY_IDX) {
+		/*if hasnot, find enpty entry*/
+		entry_index = hns_dsaf_find_empty_mac_entry(dsaf_dev);
+		if (entry_index == DSAF_INVALID_ENTRY_IDX) {
+			/*if hasnot empty, error*/
+			dev_err(dsaf_dev->dev,
+				"set_uc_entry failed, %s Mac key(%#x:%#x)\n",
+				dsaf_dev->ae_dev.name,
+				mac_key.high.val, mac_key.low.val);
+			return -EINVAL;
+		}
+
+		/* config hardware entry */
+		memset(mac_data.tbl_mcast_port_msk,
+		       0, sizeof(mac_data.tbl_mcast_port_msk));
+	} else {
+		/* config hardware entry */
+		hns_dsaf_tcam_mc_get(
+			dsaf_dev, entry_index,
+			(struct dsaf_tbl_tcam_data *)(&tmp_mac_key), &mac_data);
+	}
+	mac_data.tbl_mcast_old_en = 0;
+	mac_data.tbl_mcast_item_vld = 1;
+	dsaf_set_field(mac_data.tbl_mcast_port_msk[0],
+		       0x3F, 0, mac_entry->port_mask[0]);
+
+	dev_dbg(dsaf_dev->dev,
+		"set_uc_entry, %s key(%#x:%#x) entry_index%d\n",
+		dsaf_dev->ae_dev.name, mac_key.high.val,
+		mac_key.low.val, entry_index);
+
+	hns_dsaf_tcam_mc_cfg(
+		dsaf_dev, entry_index,
+		(struct dsaf_tbl_tcam_data *)(&mac_key), &mac_data);
+
+	/* config software entry */
+	soft_mac_entry += entry_index;
+	soft_mac_entry->index = entry_index;
+	soft_mac_entry->tcam_key.high.val = mac_key.high.val;
+	soft_mac_entry->tcam_key.low.val = mac_key.low.val;
+
+	return 0;
+}
+
+/**
+ * hns_dsaf_add_mac_mc_port - add mac mc-port
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @mac_entry: mc-mac entry
+ */
+int hns_dsaf_add_mac_mc_port(struct dsaf_device *dsaf_dev,
+			     struct dsaf_drv_mac_single_dest_entry *mac_entry)
+{
+	u16 entry_index = DSAF_INVALID_ENTRY_IDX;
+	struct dsaf_drv_tbl_tcam_key mac_key;
+	struct dsaf_tbl_tcam_mcast_cfg mac_data;
+	struct dsaf_drv_priv *priv =
+	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
+	struct dsaf_drv_soft_mac_tbl *soft_mac_entry = priv->soft_mac_tbl;
+	struct dsaf_drv_tbl_tcam_key tmp_mac_key;
+	int mskid;
+
+	/*chechk mac addr */
+	if (MAC_IS_ALL_ZEROS(mac_entry->addr)) {
+		dev_err(dsaf_dev->dev,
+			"set_entry failed,addr %02x:%02x:%02x:%02x:%02x:%02x!\n",
+			mac_entry->addr[0], mac_entry->addr[1],
+			mac_entry->addr[2], mac_entry->addr[3],
+			mac_entry->addr[4], mac_entry->addr[5]);
+		return -EINVAL;
+	}
+
+	/*config key */
+	hns_dsaf_set_mac_key(
+		dsaf_dev, &mac_key, mac_entry->in_vlan_id,
+		mac_entry->in_port_num, mac_entry->addr);
+
+	memset(&mac_data, 0, sizeof(struct dsaf_tbl_tcam_mcast_cfg));
+
+	/*check exist? */
+	entry_index = hns_dsaf_find_soft_mac_entry(dsaf_dev, &mac_key);
+	if (entry_index == DSAF_INVALID_ENTRY_IDX) {
+		/*if hasnot , find a empty*/
+		entry_index = hns_dsaf_find_empty_mac_entry(dsaf_dev);
+		if (entry_index == DSAF_INVALID_ENTRY_IDX) {
+			/*if hasnot empty, error*/
+			dev_err(dsaf_dev->dev,
+				"set_uc_entry failed, %s Mac key(%#x:%#x)\n",
+				dsaf_dev->ae_dev.name, mac_key.high.val,
+				mac_key.low.val);
+			return -EINVAL;
+		}
+	} else {
+		/*if exist, add in */
+		hns_dsaf_tcam_mc_get(
+			dsaf_dev, entry_index,
+			(struct dsaf_tbl_tcam_data *)(&tmp_mac_key), &mac_data);
+	}
+	/* config hardware entry */
+	if (mac_entry->port_num < DSAF_SERVICE_NW_NUM) {
+		mskid = mac_entry->port_num;
+	} else if (mac_entry->port_num >= DSAF_BASE_INNER_PORT_NUM) {
+		mskid = mac_entry->port_num -
+			DSAF_BASE_INNER_PORT_NUM + DSAF_SERVICE_NW_NUM;
+	} else {
+		dev_err(dsaf_dev->dev,
+			"%s,pnum(%d)error,key(%#x:%#x)\n",
+			dsaf_dev->ae_dev.name, mac_entry->port_num,
+			mac_key.high.val, mac_key.low.val);
+		return -EINVAL;
+	}
+	dsaf_set_bit(mac_data.tbl_mcast_port_msk[mskid / 32], mskid % 32, 1);
+	mac_data.tbl_mcast_old_en = 0;
+	mac_data.tbl_mcast_item_vld = 1;
+
+	dev_dbg(dsaf_dev->dev,
+		"set_uc_entry, %s Mac key(%#x:%#x) entry_index%d\n",
+		dsaf_dev->ae_dev.name, mac_key.high.val,
+		mac_key.low.val, entry_index);
+
+	hns_dsaf_tcam_mc_cfg(
+		dsaf_dev, entry_index,
+		(struct dsaf_tbl_tcam_data *)(&mac_key), &mac_data);
+
+	/*config software entry */
+	soft_mac_entry += entry_index;
+	soft_mac_entry->index = entry_index;
+	soft_mac_entry->tcam_key.high.val = mac_key.high.val;
+	soft_mac_entry->tcam_key.low.val = mac_key.low.val;
+
+	return 0;
+}
+
+/**
+ * hns_dsaf_del_mac_entry - del mac mc-port
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @vlan_id: vlian id
+ * @in_port_num: input port num
+ * @addr : mac addr
+ */
+int hns_dsaf_del_mac_entry(struct dsaf_device *dsaf_dev, u16 vlan_id,
+			   u8 in_port_num, u8 *addr)
+{
+	u16 entry_index = DSAF_INVALID_ENTRY_IDX;
+	struct dsaf_drv_tbl_tcam_key mac_key;
+	struct dsaf_drv_priv *priv =
+	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
+	struct dsaf_drv_soft_mac_tbl *soft_mac_entry = priv->soft_mac_tbl;
+
+	/*check mac addr */
+	if (MAC_IS_ALL_ZEROS(addr) || MAC_IS_BROADCAST(addr)) {
+		dev_err(dsaf_dev->dev,
+			"del_entry failed,addr %02x:%02x:%02x:%02x:%02x:%02x!\n",
+			addr[0], addr[1], addr[2], addr[3], addr[4], addr[5]);
+		return -EINVAL;
+	}
+
+	/*config key */
+	hns_dsaf_set_mac_key(dsaf_dev, &mac_key, vlan_id, in_port_num, addr);
+
+	/*exist ?*/
+	entry_index = hns_dsaf_find_soft_mac_entry(dsaf_dev, &mac_key);
+	if (entry_index == DSAF_INVALID_ENTRY_IDX) {
+		/*not exist, error */
+		dev_err(dsaf_dev->dev,
+			"del_mac_entry failed, %s Mac key(%#x:%#x)\n",
+			dsaf_dev->ae_dev.name,
+			mac_key.high.val, mac_key.low.val);
+		return -EINVAL;
+	}
+	dev_dbg(dsaf_dev->dev,
+		"del_mac_entry, %s Mac key(%#x:%#x) entry_index%d\n",
+		dsaf_dev->ae_dev.name, mac_key.high.val,
+		mac_key.low.val, entry_index);
+
+	/*do del opt*/
+	hns_dsaf_tcam_mc_invld(dsaf_dev, entry_index);
+
+	/*del soft emtry */
+	soft_mac_entry += entry_index;
+	soft_mac_entry->index = DSAF_INVALID_ENTRY_IDX;
+
+	return 0;
+}
+
+/**
+ * hns_dsaf_del_mac_mc_port - del mac mc- port
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @mac_entry: mac entry
+ */
+int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
+			     struct dsaf_drv_mac_single_dest_entry *mac_entry)
+{
+	u16 entry_index = DSAF_INVALID_ENTRY_IDX;
+	struct dsaf_drv_tbl_tcam_key mac_key;
+	struct dsaf_drv_priv *priv =
+	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
+	struct dsaf_drv_soft_mac_tbl *soft_mac_entry = priv->soft_mac_tbl;
+	u16 vlan_id;
+	u8 in_port_num;
+	struct dsaf_tbl_tcam_mcast_cfg mac_data;
+	struct dsaf_drv_tbl_tcam_key tmp_mac_key;
+	int mskid;
+	const u8 empty_msk[sizeof(mac_data.tbl_mcast_port_msk)] = {0};
+
+	if (!(void *)mac_entry) {
+		dev_err(dsaf_dev->dev,
+			"hns_dsaf_del_mac_mc_port mac_entry is NULL\n");
+		return -EINVAL;
+	}
+
+	/*get key info*/
+	vlan_id = mac_entry->in_vlan_id;
+	in_port_num = mac_entry->in_port_num;
+
+	/*check mac addr */
+	if (MAC_IS_ALL_ZEROS(mac_entry->addr)) {
+		dev_err(dsaf_dev->dev,
+			"del_port failed, addr %02x:%02x:%02x:%02x:%02x:%02x!\n",
+			mac_entry->addr[0], mac_entry->addr[1],
+			mac_entry->addr[2], mac_entry->addr[3],
+			mac_entry->addr[4], mac_entry->addr[5]);
+		return -EINVAL;
+	}
+
+	/*config key */
+	hns_dsaf_set_mac_key(dsaf_dev, &mac_key, vlan_id, in_port_num,
+			     mac_entry->addr);
+
+	/*check is exist? */
+	entry_index = hns_dsaf_find_soft_mac_entry(dsaf_dev, &mac_key);
+	if (entry_index == DSAF_INVALID_ENTRY_IDX) {
+		/*find none */
+		dev_err(dsaf_dev->dev,
+			"find_soft_mac_entry failed, %s Mac key(%#x:%#x)\n",
+			dsaf_dev->ae_dev.name,
+			mac_key.high.val, mac_key.low.val);
+		return -EINVAL;
+	}
+
+	dev_dbg(dsaf_dev->dev,
+		"del_mac_mc_port, %s key(%#x:%#x) index%d\n",
+		dsaf_dev->ae_dev.name, mac_key.high.val,
+		mac_key.low.val, entry_index);
+
+	/*read entry*/
+	hns_dsaf_tcam_mc_get(
+		dsaf_dev, entry_index,
+		(struct dsaf_tbl_tcam_data *)(&tmp_mac_key), &mac_data);
+
+	/*del the port*/
+	if (mac_entry->port_num < DSAF_SERVICE_NW_NUM) {
+		mskid = mac_entry->port_num;
+	} else if (mac_entry->port_num >= DSAF_BASE_INNER_PORT_NUM) {
+		mskid = mac_entry->port_num -
+			DSAF_BASE_INNER_PORT_NUM + DSAF_SERVICE_NW_NUM;
+	} else {
+		dev_err(dsaf_dev->dev,
+			"%s,pnum(%d)error,key(%#x:%#x)\n",
+			dsaf_dev->ae_dev.name, mac_entry->port_num,
+			mac_key.high.val, mac_key.low.val);
+		return -EINVAL;
+	}
+	dsaf_set_bit(mac_data.tbl_mcast_port_msk[mskid / 32], mskid % 32, 0);
+
+	/*check non port, do del entry */
+	if (!memcmp(mac_data.tbl_mcast_port_msk, empty_msk,
+		    sizeof(mac_data.tbl_mcast_port_msk))) {
+		hns_dsaf_tcam_mc_invld(dsaf_dev, entry_index);
+
+		/* del soft entry */
+		soft_mac_entry += entry_index;
+		soft_mac_entry->index = DSAF_INVALID_ENTRY_IDX;
+	} else { /* not zer, just del port, updata*/
+		hns_dsaf_tcam_mc_cfg(
+			dsaf_dev, entry_index,
+			(struct dsaf_tbl_tcam_data *)(&mac_key), &mac_data);
+	}
+
+	return 0;
+}
+
+/**
+ * hns_dsaf_get_mac_uc_entry - get mac uc entry
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @mac_entry: mac entry
+ */
+int hns_dsaf_get_mac_uc_entry(struct dsaf_device *dsaf_dev,
+			      struct dsaf_drv_mac_single_dest_entry *mac_entry)
+{
+	u16 entry_index = DSAF_INVALID_ENTRY_IDX;
+	struct dsaf_drv_tbl_tcam_key mac_key;
+
+	struct dsaf_tbl_tcam_ucast_cfg mac_data;
+
+	/* check macaddr */
+	if (MAC_IS_ALL_ZEROS(mac_entry->addr) ||
+	    MAC_IS_BROADCAST(mac_entry->addr)) {
+		dev_err(dsaf_dev->dev,
+			"get_entry failed,addr %02x:%02x:%02x:%02x:%02x:%02x\n",
+			mac_entry->addr[0], mac_entry->addr[1],
+			mac_entry->addr[2], mac_entry->addr[3],
+			mac_entry->addr[4], mac_entry->addr[5]);
+		return -EINVAL;
+	}
+
+	/*config key */
+	hns_dsaf_set_mac_key(dsaf_dev, &mac_key, mac_entry->in_vlan_id,
+			     mac_entry->in_port_num, mac_entry->addr);
+
+	/*check exist? */
+	entry_index = hns_dsaf_find_soft_mac_entry(dsaf_dev, &mac_key);
+	if (entry_index == DSAF_INVALID_ENTRY_IDX) {
+		/*find none, error */
+		dev_err(dsaf_dev->dev,
+			"get_uc_entry failed, %s Mac key(%#x:%#x)\n",
+			dsaf_dev->ae_dev.name,
+			mac_key.high.val, mac_key.low.val);
+		return -EINVAL;
+	}
+	dev_dbg(dsaf_dev->dev,
+		"get_uc_entry, %s Mac key(%#x:%#x) entry_index%d\n",
+		dsaf_dev->ae_dev.name, mac_key.high.val,
+		mac_key.low.val, entry_index);
+
+	/*read entry*/
+	hns_dsaf_tcam_uc_get(dsaf_dev, entry_index,
+			     (struct dsaf_tbl_tcam_data *)&mac_key, &mac_data);
+	mac_entry->port_num = mac_data.tbl_ucast_out_port;
+
+	return 0;
+}
+
+/**
+ * hns_dsaf_get_mac_mc_entry - get mac mc entry
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @mac_entry: mac entry
+ */
+int hns_dsaf_get_mac_mc_entry(struct dsaf_device *dsaf_dev,
+			      struct dsaf_drv_mac_multi_dest_entry *mac_entry)
+{
+	u16 entry_index = DSAF_INVALID_ENTRY_IDX;
+	struct dsaf_drv_tbl_tcam_key mac_key;
+
+	struct dsaf_tbl_tcam_mcast_cfg mac_data;
+
+	/*check mac addr */
+	if (MAC_IS_ALL_ZEROS(mac_entry->addr) ||
+	    MAC_IS_BROADCAST(mac_entry->addr)) {
+		dev_err(dsaf_dev->dev,
+			"get_entry failed,addr %02x:%02x:%02x:%02x:%02x:%02x\n",
+			mac_entry->addr[0], mac_entry->addr[1],
+			mac_entry->addr[2], mac_entry->addr[3],
+			mac_entry->addr[4], mac_entry->addr[5]);
+		return -EINVAL;
+	}
+
+	/*config key */
+	hns_dsaf_set_mac_key(dsaf_dev, &mac_key, mac_entry->in_vlan_id,
+			     mac_entry->in_port_num, mac_entry->addr);
+
+	/*check exist? */
+	entry_index = hns_dsaf_find_soft_mac_entry(dsaf_dev, &mac_key);
+	if (entry_index == DSAF_INVALID_ENTRY_IDX) {
+		/* find none, error */
+		dev_err(dsaf_dev->dev,
+			"get_mac_uc_entry failed, %s Mac key(%#x:%#x)\n",
+			dsaf_dev->ae_dev.name, mac_key.high.val,
+			mac_key.low.val);
+		return -EINVAL;
+	}
+	dev_dbg(dsaf_dev->dev,
+		"get_mac_uc_entry, %s Mac key(%#x:%#x) entry_index%d\n",
+		dsaf_dev->ae_dev.name, mac_key.high.val,
+		mac_key.low.val, entry_index);
+
+	/*read entry */
+	hns_dsaf_tcam_mc_get(dsaf_dev, entry_index,
+			     (struct dsaf_tbl_tcam_data *)&mac_key, &mac_data);
+
+	mac_entry->port_mask[0] = mac_data.tbl_mcast_port_msk[0] & 0x3F;
+	return 0;
+}
+
+/**
+ * hns_dsaf_get_mac_entry_by_index - get mac entry by tab index
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @entry_index: tab entry index
+ * @mac_entry: mac entry
+ */
+int hns_dsaf_get_mac_entry_by_index(
+	struct dsaf_device *dsaf_dev,
+	u16 entry_index, struct dsaf_drv_mac_multi_dest_entry *mac_entry)
+{
+	struct dsaf_drv_tbl_tcam_key mac_key;
+
+	struct dsaf_tbl_tcam_mcast_cfg mac_data;
+	struct dsaf_tbl_tcam_ucast_cfg mac_uc_data;
+	char mac_addr[MAC_NUM_OCTETS_PER_ADDR] = {0};
+
+	if (entry_index >= DSAF_TCAM_SUM) {
+		/* find none, del error */
+		dev_err(dsaf_dev->dev, "get_uc_entry failed, %s\n",
+			dsaf_dev->ae_dev.name);
+		return -EINVAL;
+	}
+
+	/* mc entry, do read opt */
+	hns_dsaf_tcam_mc_get(dsaf_dev, entry_index,
+			     (struct dsaf_tbl_tcam_data *)&mac_key, &mac_data);
+
+	mac_entry->port_mask[0] = mac_data.tbl_mcast_port_msk[0] & 0x3F;
+
+	/***get mac addr*/
+	mac_addr[0] = mac_key.high.bits.mac_0;
+	mac_addr[1] = mac_key.high.bits.mac_1;
+	mac_addr[2] = mac_key.high.bits.mac_2;
+	mac_addr[3] = mac_key.high.bits.mac_3;
+	mac_addr[4] = mac_key.low.bits.mac_4;
+	mac_addr[5] = mac_key.low.bits.mac_5;
+	/**is mc or uc*/
+	if (MAC_IS_MULTICAST((u8 *)mac_addr) ||
+	    MAC_IS_L3_MULTICAST((u8 *)mac_addr)) {
+		/**mc donot do*/
+	} else {
+		/*is not mc, just uc... */
+		hns_dsaf_tcam_uc_get(dsaf_dev, entry_index,
+				     (struct dsaf_tbl_tcam_data *)&mac_key,
+				     &mac_uc_data);
+		mac_entry->port_mask[0] = (1 << mac_uc_data.tbl_ucast_out_port);
+	}
+
+	return 0;
+}
+
+static struct dsaf_device *hns_dsaf_alloc_dev(struct device *dev,
+					      size_t sizeof_priv)
+{
+	struct dsaf_device *dsaf_dev;
+
+	dsaf_dev = devm_kzalloc(dev,
+				sizeof(*dsaf_dev) + sizeof_priv, GFP_KERNEL);
+	if (unlikely(!dsaf_dev)) {
+		dsaf_dev = ERR_PTR(-ENOMEM);
+	} else {
+		dsaf_dev->dev = dev;
+		dev_set_drvdata(dev, dsaf_dev);
+	}
+
+	return dsaf_dev;
+}
+
+/**
+ * hns_dsaf_free_dev - free dev mem
+ * @dev: struct device pointer
+ */
+static void hns_dsaf_free_dev(struct dsaf_device *dsaf_dev)
+{
+	(void)dev_set_drvdata(dsaf_dev->dev, NULL);
+}
+
+/**
+ * dsaf_pfc_unit_cnt - set pfc unit count
+ * @dsaf_id: dsa fabric id
+ * @pport_rate:  value array
+ * @pdsaf_pfc_unit_cnt:  value array
+ */
+static void hns_dsaf_pfc_unit_cnt(struct dsaf_device *dsaf_dev, int  mac_id,
+				  enum dsaf_port_rate_mode rate)
+{
+	u32 unit_cnt;
+
+	switch (rate) {
+	case DSAF_PORT_RATE_10000:
+		unit_cnt = HNS_DSAF_PFC_UNIT_CNT_FOR_XGE;
+		break;
+	case DSAF_PORT_RATE_1000:
+		unit_cnt = HNS_DSAF_PFC_UNIT_CNT_FOR_GE_1000;
+		break;
+	case DSAF_PORT_RATE_2500:
+		unit_cnt = HNS_DSAF_PFC_UNIT_CNT_FOR_GE_1000;
+		break;
+	default:
+		unit_cnt = HNS_DSAF_PFC_UNIT_CNT_FOR_XGE;
+	}
+
+	dsaf_set_dev_field(dsaf_dev,
+			   (DSAF_PFC_UNIT_CNT_0_REG + 0x4 * (u64)mac_id),
+			   DSAF_PFC_UNINT_CNT_M, DSAF_PFC_UNINT_CNT_S,
+			   unit_cnt);
+}
+
+/**
+ * dsaf_port_work_rate_cfg - fifo
+ * @dsaf_id: dsa fabric id
+ * @xge_ge_work_mode
+ */
+void hns_dsaf_port_work_rate_cfg(struct dsaf_device *dsaf_dev, int mac_id,
+				 enum dsaf_port_rate_mode rate_mode)
+{
+	u32 port_work_mode;
+
+	port_work_mode = dsaf_read_dev(
+		dsaf_dev, DSAF_XGE_GE_WORK_MODE_0_REG + 0x4 * (u64)mac_id);
+
+	if (rate_mode == DSAF_PORT_RATE_10000)
+		dsaf_set_bit(port_work_mode, DSAF_XGE_GE_WORK_MODE_S, 1);
+	else
+		dsaf_set_bit(port_work_mode, DSAF_XGE_GE_WORK_MODE_S, 0);
+
+	dsaf_write_dev(dsaf_dev,
+		       DSAF_XGE_GE_WORK_MODE_0_REG + 0x4 * (u64)mac_id,
+		       port_work_mode);
+
+	hns_dsaf_pfc_unit_cnt(dsaf_dev, mac_id, rate_mode);
+}
+
+/**
+ * hns_dsaf_fix_mac_mode - dsaf modify mac mode
+ * @mac_cb: mac contrl block
+ */
+void hns_dsaf_fix_mac_mode(struct hns_mac_cb *mac_cb)
+{
+	enum dsaf_port_rate_mode mode;
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
+	int mac_id = mac_cb->mac_id;
+
+	if (mac_cb->mac_type != HNAE_PORT_SERVICE)
+		return;
+	if (mac_cb->phy_if == PHY_INTERFACE_MODE_XGMII)
+		mode = DSAF_PORT_RATE_10000;
+	else
+		mode = DSAF_PORT_RATE_1000;
+
+	hns_dsaf_port_work_rate_cfg(dsaf_dev, mac_id, mode);
+}
+
+void hns_dsaf_update_stats(struct dsaf_device *dsaf_dev, u32 node_num)
+{
+	struct dsaf_hw_stats *hw_stats
+		= &dsaf_dev->hw_stats[node_num];
+
+	hw_stats->pad_drop += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_PAD_DISCARD_NUM_0_REG + 0x80 * (u64)node_num);
+	hw_stats->man_pkts += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_FINAL_IN_MAN_NUM_0_REG + 0x80 * (u64)node_num);
+	hw_stats->rx_pkts += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_FINAL_IN_PKT_NUM_0_REG + 0x80 * (u64)node_num);
+	hw_stats->rx_pkt_id += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_SBM_PID_NUM_0_REG + 0x80 * (u64)node_num);
+	hw_stats->rx_pause_frame += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_FINAL_IN_PAUSE_NUM_0_REG + 0x80 * (u64)node_num);
+	hw_stats->release_buf_num += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_SBM_RELS_NUM_0_REG + 0x80 * (u64)node_num);
+	hw_stats->sbm_drop += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_SBM_DROP_NUM_0_REG + 0x80 * (u64)node_num);
+	hw_stats->crc_false += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_CRC_FALSE_NUM_0_REG + 0x80 * (u64)node_num);
+	hw_stats->bp_drop += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_BP_DISCARD_NUM_0_REG + 0x80 * (u64)node_num);
+	hw_stats->rslt_drop += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_RSLT_DISCARD_NUM_0_REG + 0x80 * (u64)node_num);
+	hw_stats->local_addr_false += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_LOCAL_ADDR_FALSE_NUM_0_REG + 0x80 * (u64)node_num);
+
+	hw_stats->vlan_drop += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_SW_VLAN_TAG_DISC_0_REG + 0x80 * (u64)node_num);
+	hw_stats->stp_drop += dsaf_read_dev(dsaf_dev,
+		DSAF_INODE_IN_DATA_STP_DISC_0_REG + 0x80 * (u64)node_num);
+
+	hw_stats->tx_pkts += dsaf_read_dev(dsaf_dev,
+		DSAF_XOD_RCVPKT_CNT_0_REG + 0x90 * (u64)node_num);
+}
+
+/**
+ *hns_dsaf_get_regs - dump dsaf regs
+ *@dsaf_dev: dsaf device
+ *@data:data for value of regs
+ */
+void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data)
+{
+	u32 i = 0;
+	u32 j;
+	u32 *p = data;
+
+	/* dsaf common registers */
+	p[0] = dsaf_read_dev(ddev, DSAF_SRAM_INIT_OVER_0_REG);
+	p[1] = dsaf_read_dev(ddev, DSAF_CFG_0_REG);
+	p[2] = dsaf_read_dev(ddev, DSAF_ECC_ERR_INVERT_0_REG);
+	p[3] = dsaf_read_dev(ddev, DSAF_ABNORMAL_TIMEOUT_0_REG);
+	p[4] = dsaf_read_dev(ddev, DSAF_FSM_TIMEOUT_0_REG);
+	p[5] = dsaf_read_dev(ddev, DSAF_DSA_REG_CNT_CLR_CE_REG);
+	p[6] = dsaf_read_dev(ddev, DSAF_DSA_SBM_INF_FIFO_THRD_REG);
+	p[7] = dsaf_read_dev(ddev, DSAF_DSA_SRAM_1BIT_ECC_SEL_REG);
+	p[8] = dsaf_read_dev(ddev, DSAF_DSA_SRAM_1BIT_ECC_CNT_REG);
+
+	p[9] = dsaf_read_dev(ddev, DSAF_PFC_EN_0_REG + port * 4);
+	p[10] = dsaf_read_dev(ddev, DSAF_PFC_UNIT_CNT_0_REG + port * 4);
+	p[11] = dsaf_read_dev(ddev, DSAF_XGE_INT_MSK_0_REG + port * 4);
+	p[12] = dsaf_read_dev(ddev, DSAF_XGE_INT_SRC_0_REG + port * 4);
+	p[13] = dsaf_read_dev(ddev, DSAF_XGE_INT_STS_0_REG + port * 4);
+	p[14] = dsaf_read_dev(ddev, DSAF_XGE_INT_MSK_0_REG + port * 4);
+	p[15] = dsaf_read_dev(ddev, DSAF_PPE_INT_MSK_0_REG + port * 4);
+	p[16] = dsaf_read_dev(ddev, DSAF_ROCEE_INT_MSK_0_REG + port * 4);
+	p[17] = dsaf_read_dev(ddev, DSAF_XGE_INT_SRC_0_REG + port * 4);
+	p[18] = dsaf_read_dev(ddev, DSAF_PPE_INT_SRC_0_REG + port * 4);
+	p[19] =  dsaf_read_dev(ddev, DSAF_ROCEE_INT_SRC_0_REG + port * 4);
+	p[20] = dsaf_read_dev(ddev, DSAF_XGE_INT_STS_0_REG + port * 4);
+	p[21] = dsaf_read_dev(ddev, DSAF_PPE_INT_STS_0_REG + port * 4);
+	p[22] = dsaf_read_dev(ddev, DSAF_ROCEE_INT_STS_0_REG + port * 4);
+	p[23] = dsaf_read_dev(ddev, DSAF_PPE_QID_CFG_0_REG + port * 4);
+
+	for (i = 0; i < DSAF_SW_PORT_NUM; i++)
+		p[24 + i] = dsaf_read_dev(ddev,
+				DSAF_SW_PORT_TYPE_0_REG + i * 4);
+
+	p[32] = dsaf_read_dev(ddev, DSAF_MIX_DEF_QID_0_REG + port * 4);
+
+	for (i = 0; i < DSAF_SW_PORT_NUM; i++)
+		p[33 + i] = dsaf_read_dev(ddev,
+				DSAF_PORT_DEF_VLAN_0_REG + i * 4);
+
+	for (i = 0; i < DSAF_TOTAL_QUEUE_NUM; i++)
+		p[41 + i] = dsaf_read_dev(ddev,
+				DSAF_VM_DEF_VLAN_0_REG + i * 4);
+
+	/* dsaf inode registers */
+	p[170] = dsaf_read_dev(ddev, DSAF_INODE_CUT_THROUGH_CFG_0_REG);
+
+	p[171] = dsaf_read_dev(ddev,
+			DSAF_INODE_ECC_ERR_ADDR_0_REG + port * 0x80);
+
+	for (i = 0; i < DSAF_INODE_NUM / DSAF_COMM_CHN; i++) {
+		j = i * DSAF_COMM_CHN + port;
+		p[172 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_IN_PORT_NUM_0_REG + j * 0x80);
+		p[175 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_PRI_TC_CFG_0_REG + j * 0x80);
+		p[178 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_BP_STATUS_0_REG + j * 0x80);
+		p[181 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_PAD_DISCARD_NUM_0_REG + j * 0x80);
+		p[184 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_FINAL_IN_MAN_NUM_0_REG + j * 0x80);
+		p[187 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_FINAL_IN_PKT_NUM_0_REG + j * 0x80);
+		p[190 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_SBM_PID_NUM_0_REG + j * 0x80);
+		p[193 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_FINAL_IN_PAUSE_NUM_0_REG + j * 0x80);
+		p[196 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_SBM_RELS_NUM_0_REG + j * 0x80);
+		p[199 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_SBM_DROP_NUM_0_REG + j * 0x80);
+		p[202 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_CRC_FALSE_NUM_0_REG + j * 0x80);
+		p[205 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_BP_DISCARD_NUM_0_REG + j * 0x80);
+		p[208 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_RSLT_DISCARD_NUM_0_REG + j * 0x80);
+		p[211 + i] = dsaf_read_dev(ddev,
+			DSAF_INODE_LOCAL_ADDR_FALSE_NUM_0_REG + j * 0x80);
+		p[214 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_VOQ_OVER_NUM_0_REG + j * 0x80);
+		p[217 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_BD_SAVE_STATUS_0_REG + j * 4);
+		p[220 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_BD_ORDER_STATUS_0_REG + j * 4);
+		p[223 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_SW_VLAN_TAG_DISC_0_REG + j * 4);
+		p[224 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_IN_DATA_STP_DISC_0_REG + j * 4);
+	}
+
+	p[227] = dsaf_read_dev(ddev, DSAF_INODE_GE_FC_EN_0_REG + port * 4);
+
+	for (i = 0; i < DSAF_INODE_NUM / DSAF_COMM_CHN; i++) {
+		j = i * DSAF_COMM_CHN + port;
+		p[228 + i] = dsaf_read_dev(ddev,
+				DSAF_INODE_VC0_IN_PKT_NUM_0_REG + j * 4);
+	}
+
+	p[231] = dsaf_read_dev(ddev,
+		DSAF_INODE_VC1_IN_PKT_NUM_0_REG + port * 4);
+
+	/* dsaf inode registers */
+	for (i = 0; i < DSAF_SBM_NUM / DSAF_COMM_CHN; i++) {
+		j = i * DSAF_COMM_CHN + port;
+		p[232 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_CFG_REG_0_REG + j * 0x80);
+		p[235 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_BP_CFG_0_XGE_REG_0_REG + j * 0x80);
+		p[238 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_BP_CFG_1_REG_0_REG + j * 0x80);
+		p[241 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_BP_CFG_2_XGE_REG_0_REG + j * 0x80);
+		p[244 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_FREE_CNT_0_0_REG + j * 0x80);
+		p[245 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_FREE_CNT_1_0_REG + j * 0x80);
+		p[248 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_BP_CNT_0_0_REG + j * 0x80);
+		p[251 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_BP_CNT_1_0_REG + j * 0x80);
+		p[254 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_BP_CNT_2_0_REG + j * 0x80);
+		p[257 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_BP_CNT_3_0_REG + j * 0x80);
+		p[260 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_INER_ST_0_REG + j * 0x80);
+		p[263 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_MIB_REQ_FAILED_TC_0_REG + j * 0x80);
+		p[266 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_INPORT_CNT_0_REG + j * 0x80);
+		p[269 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_DROP_CNT_0_REG + j * 0x80);
+		p[272 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_INF_OUTPORT_CNT_0_REG + j * 0x80);
+		p[275 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_INPORT_TC0_CNT_0_REG + j * 0x80);
+		p[278 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_INPORT_TC1_CNT_0_REG + j * 0x80);
+		p[281 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_INPORT_TC2_CNT_0_REG + j * 0x80);
+		p[284 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_INPORT_TC3_CNT_0_REG + j * 0x80);
+		p[287 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_INPORT_TC4_CNT_0_REG + j * 0x80);
+		p[290 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_INPORT_TC5_CNT_0_REG + j * 0x80);
+		p[293 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_INPORT_TC6_CNT_0_REG + j * 0x80);
+		p[296 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_INPORT_TC7_CNT_0_REG + j * 0x80);
+		p[299 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_REQ_CNT_0_REG + j * 0x80);
+		p[302 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_LNK_RELS_CNT_0_REG + j * 0x80);
+		p[305 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_BP_CFG_3_REG_0_REG + j * 0x80);
+		p[308 + i] = dsaf_read_dev(ddev,
+				DSAF_SBM_BP_CFG_4_REG_0_REG + j * 0x80);
+	}
+
+	/* dsaf onode registers */
+	for (i = 0; i < DSAF_XOD_NUM; i++) {
+		p[311 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_ETS_TSA_TC0_TC3_CFG_0_REG + j * 0x90);
+		p[319 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_ETS_TSA_TC4_TC7_CFG_0_REG + j * 0x90);
+		p[327 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_ETS_BW_TC0_TC3_CFG_0_REG + j * 0x90);
+		p[335 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_ETS_BW_TC4_TC7_CFG_0_REG + j * 0x90);
+		p[343 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_ETS_BW_OFFSET_CFG_0_REG + j * 0x90);
+		p[351 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_ETS_TOKEN_CFG_0_REG + j * 0x90);
+	}
+
+	p[359] = dsaf_read_dev(ddev, DSAF_XOD_PFS_CFG_0_0_REG + port * 0x90);
+	p[360] = dsaf_read_dev(ddev, DSAF_XOD_PFS_CFG_1_0_REG + port * 0x90);
+	p[361] = dsaf_read_dev(ddev, DSAF_XOD_PFS_CFG_2_0_REG + port * 0x90);
+
+	for (i = 0; i < DSAF_XOD_BIG_NUM / DSAF_COMM_CHN; i++) {
+		j = i * DSAF_COMM_CHN + port;
+		p[362 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_GNT_L_0_REG + j * 0x90);
+		p[365 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_GNT_H_0_REG + j * 0x90);
+		p[368 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_CONNECT_STATE_0_REG + j * 0x90);
+		p[371 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_RCVPKT_CNT_0_REG + j * 0x90);
+		p[374 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_RCVTC0_CNT_0_REG + j * 0x90);
+		p[377 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_RCVTC1_CNT_0_REG + j * 0x90);
+		p[380 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_RCVTC2_CNT_0_REG + j * 0x90);
+		p[383 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_RCVTC3_CNT_0_REG + j * 0x90);
+		p[386 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_RCVVC0_CNT_0_REG + j * 0x90);
+		p[389 + i] = dsaf_read_dev(ddev,
+				DSAF_XOD_RCVVC1_CNT_0_REG + j * 0x90);
+	}
+
+	p[392] = dsaf_read_dev(ddev,
+		DSAF_XOD_XGE_RCVIN0_CNT_0_REG + port * 0x90);
+	p[393] = dsaf_read_dev(ddev,
+		DSAF_XOD_XGE_RCVIN1_CNT_0_REG + port * 0x90);
+	p[394] = dsaf_read_dev(ddev,
+		DSAF_XOD_XGE_RCVIN2_CNT_0_REG + port * 0x90);
+	p[395] = dsaf_read_dev(ddev,
+		DSAF_XOD_XGE_RCVIN3_CNT_0_REG + port * 0x90);
+	p[396] = dsaf_read_dev(ddev,
+		DSAF_XOD_XGE_RCVIN4_CNT_0_REG + port * 0x90);
+	p[397] = dsaf_read_dev(ddev,
+		DSAF_XOD_XGE_RCVIN5_CNT_0_REG + port * 0x90);
+	p[398] = dsaf_read_dev(ddev,
+		DSAF_XOD_XGE_RCVIN6_CNT_0_REG + port * 0x90);
+	p[399] = dsaf_read_dev(ddev,
+		DSAF_XOD_XGE_RCVIN7_CNT_0_REG + port * 0x90);
+	p[400] = dsaf_read_dev(ddev,
+		DSAF_XOD_PPE_RCVIN0_CNT_0_REG + port * 0x90);
+	p[401] = dsaf_read_dev(ddev,
+		DSAF_XOD_PPE_RCVIN1_CNT_0_REG + port * 0x90);
+	p[402] = dsaf_read_dev(ddev,
+		DSAF_XOD_ROCEE_RCVIN0_CNT_0_REG + port * 0x90);
+	p[403] = dsaf_read_dev(ddev,
+		DSAF_XOD_ROCEE_RCVIN1_CNT_0_REG + port * 0x90);
+	p[404] = dsaf_read_dev(ddev,
+		DSAF_XOD_FIFO_STATUS_0_REG + port * 0x90);
+
+	/* dsaf voq registers */
+	for (i = 0; i < DSAF_VOQ_NUM / DSAF_COMM_CHN; i++) {
+		j = (i * DSAF_COMM_CHN + port) * 0x90;
+		p[405 + i] = dsaf_read_dev(ddev,
+			DSAF_VOQ_ECC_INVERT_EN_0_REG + j);
+		p[408 + i] = dsaf_read_dev(ddev,
+			DSAF_VOQ_SRAM_PKT_NUM_0_REG + j);
+		p[411 + i] = dsaf_read_dev(ddev, DSAF_VOQ_IN_PKT_NUM_0_REG + j);
+		p[414 + i] = dsaf_read_dev(ddev,
+			DSAF_VOQ_OUT_PKT_NUM_0_REG + j);
+		p[417 + i] = dsaf_read_dev(ddev,
+			DSAF_VOQ_ECC_ERR_ADDR_0_REG + j);
+		p[420 + i] = dsaf_read_dev(ddev, DSAF_VOQ_BP_STATUS_0_REG + j);
+		p[423 + i] = dsaf_read_dev(ddev, DSAF_VOQ_SPUP_IDLE_0_REG + j);
+		p[426 + i] = dsaf_read_dev(ddev,
+			DSAF_VOQ_XGE_XOD_REQ_0_0_REG + j);
+		p[429 + i] = dsaf_read_dev(ddev,
+			DSAF_VOQ_XGE_XOD_REQ_1_0_REG + j);
+		p[432 + i] = dsaf_read_dev(ddev,
+			DSAF_VOQ_PPE_XOD_REQ_0_REG + j);
+		p[435 + i] = dsaf_read_dev(ddev,
+			DSAF_VOQ_ROCEE_XOD_REQ_0_REG + j);
+		p[438 + i] = dsaf_read_dev(ddev,
+			DSAF_VOQ_BP_ALL_THRD_0_REG + j);
+	}
+
+	/* dsaf tbl registers */
+	p[441] = dsaf_read_dev(ddev, DSAF_TBL_CTRL_0_REG);
+	p[442] = dsaf_read_dev(ddev, DSAF_TBL_INT_MSK_0_REG);
+	p[443] = dsaf_read_dev(ddev, DSAF_TBL_INT_SRC_0_REG);
+	p[444] = dsaf_read_dev(ddev, DSAF_TBL_INT_STS_0_REG);
+	p[445] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_ADDR_0_REG);
+	p[446] = dsaf_read_dev(ddev, DSAF_TBL_LINE_ADDR_0_REG);
+	p[447] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_HIGH_0_REG);
+	p[448] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_LOW_0_REG);
+	p[449] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_MCAST_CFG_4_0_REG);
+	p[450] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_MCAST_CFG_3_0_REG);
+	p[451] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_MCAST_CFG_2_0_REG);
+	p[452] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_MCAST_CFG_1_0_REG);
+	p[453] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_MCAST_CFG_0_0_REG);
+	p[454] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_UCAST_CFG_0_REG);
+	p[455] = dsaf_read_dev(ddev, DSAF_TBL_LIN_CFG_0_REG);
+	p[456] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_RDATA_HIGH_0_REG);
+	p[457] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_RDATA_LOW_0_REG);
+	p[458] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_RAM_RDATA4_0_REG);
+	p[459] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_RAM_RDATA3_0_REG);
+	p[460] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_RAM_RDATA2_0_REG);
+	p[461] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_RAM_RDATA1_0_REG);
+	p[462] = dsaf_read_dev(ddev, DSAF_TBL_TCAM_RAM_RDATA0_0_REG);
+	p[463] = dsaf_read_dev(ddev, DSAF_TBL_LIN_RDATA_0_REG);
+
+	for (i = 0; i < DSAF_SW_PORT_NUM; i++) {
+		j = i * 0x8;
+		p[464 + 2 * i] = dsaf_read_dev(ddev,
+			DSAF_TBL_DA0_MIS_INFO1_0_REG + j);
+		p[465 + 2 * i] = dsaf_read_dev(ddev,
+			DSAF_TBL_DA0_MIS_INFO0_0_REG + j);
+	}
+
+	p[480] = dsaf_read_dev(ddev, DSAF_TBL_SA_MIS_INFO2_0_REG);
+	p[481] = dsaf_read_dev(ddev, DSAF_TBL_SA_MIS_INFO1_0_REG);
+	p[482] = dsaf_read_dev(ddev, DSAF_TBL_SA_MIS_INFO0_0_REG);
+	p[483] = dsaf_read_dev(ddev, DSAF_TBL_PUL_0_REG);
+	p[484] = dsaf_read_dev(ddev, DSAF_TBL_OLD_RSLT_0_REG);
+	p[485] = dsaf_read_dev(ddev, DSAF_TBL_OLD_SCAN_VAL_0_REG);
+	p[486] = dsaf_read_dev(ddev, DSAF_TBL_DFX_CTRL_0_REG);
+	p[487] = dsaf_read_dev(ddev, DSAF_TBL_DFX_STAT_0_REG);
+	p[488] = dsaf_read_dev(ddev, DSAF_TBL_DFX_STAT_2_0_REG);
+	p[489] = dsaf_read_dev(ddev, DSAF_TBL_LKUP_NUM_I_0_REG);
+	p[490] = dsaf_read_dev(ddev, DSAF_TBL_LKUP_NUM_O_0_REG);
+	p[491] = dsaf_read_dev(ddev, DSAF_TBL_UCAST_BCAST_MIS_INFO_0_0_REG);
+
+	/* dsaf other registers */
+	p[492] = dsaf_read_dev(ddev, DSAF_INODE_FIFO_WL_0_REG + port * 0x4);
+	p[493] = dsaf_read_dev(ddev, DSAF_ONODE_FIFO_WL_0_REG + port * 0x4);
+	p[494] = dsaf_read_dev(ddev, DSAF_XGE_GE_WORK_MODE_0_REG + port * 0x4);
+	p[495] = dsaf_read_dev(ddev,
+		DSAF_XGE_APP_RX_LINK_UP_0_REG + port * 0x4);
+	p[496] = dsaf_read_dev(ddev, DSAF_NETPORT_CTRL_SIG_0_REG + port * 0x4);
+	p[497] = dsaf_read_dev(ddev, DSAF_XGE_CTRL_SIG_CFG_0_REG + port * 0x4);
+
+	/* mark end of dsaf regs */
+	for (i = 498; i < 504; i++)
+		p[i] = 0xdddddddd;
+}
+
+static char *hns_dsaf_get_node_stats_strings(char *data, int node)
+{
+	char *buff = data;
+
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_pad_drop_pkts", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_manage_pkts", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_rx_pkts", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_rx_pkt_id", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_rx_pause_frame", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_release_buf_num", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_sbm_drop_pkts", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_crc_false_pkts", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_bp_drop_pkts", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_lookup_rslt_drop_pkts", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_local_rslt_fail_pkts", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_vlan_drop_pkts", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "innod%d_stp_drop_pkts", node);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "onnod%d_tx_pkts", node);
+	buff = buff + ETH_GSTRING_LEN;
+
+	return buff;
+}
+
+static u64 *hns_dsaf_get_node_stats(struct dsaf_device *ddev, u64 *data,
+				    int node_num)
+{
+	u64 *p = data;
+	struct dsaf_hw_stats *hw_stats = &ddev->hw_stats[node_num];
+
+	p[0] = hw_stats->pad_drop;
+	p[1] = hw_stats->man_pkts;
+	p[2] = hw_stats->rx_pkts;
+	p[3] = hw_stats->rx_pkt_id;
+	p[4] = hw_stats->rx_pause_frame;
+	p[5] = hw_stats->release_buf_num;
+	p[6] = hw_stats->sbm_drop;
+	p[7] = hw_stats->crc_false;
+	p[8] = hw_stats->bp_drop;
+	p[9] = hw_stats->rslt_drop;
+	p[10] = hw_stats->local_addr_false;
+	p[11] = hw_stats->vlan_drop;
+	p[12] = hw_stats->stp_drop;
+	p[13] = hw_stats->tx_pkts;
+
+	return &p[14];
+}
+
+/**
+ *hns_dsaf_get_stats - get dsaf statistic
+ *@ddev: dsaf device
+ *@data:statistic value
+ *@port: port num
+ */
+void hns_dsaf_get_stats(struct dsaf_device *ddev, u64 *data, int port)
+{
+	u64 *p = data;
+	int node_num = port;
+
+	/* for ge/xge node info */
+	p = hns_dsaf_get_node_stats(ddev, p, node_num);
+
+	/* for ppe node info */
+	node_num = port + DSAF_PPE_INODE_BASE;
+	(void)hns_dsaf_get_node_stats(ddev, p, node_num);
+}
+
+/**
+ *hns_dsaf_get_sset_count - get dsaf string set count
+ *@stringset: type of values in data
+ *return dsaf string name count
+ */
+int hns_dsaf_get_sset_count(int stringset)
+{
+	if (stringset == ETH_SS_STATS)
+		return DSAF_STATIC_NUM;
+
+	return 0;
+}
+
+/**
+ *hns_dsaf_get_strings - get dsaf string set
+ *@stringset:srting set index
+ *@data:strings name value
+ *@port:port index
+ */
+void hns_dsaf_get_strings(int stringset, u8 *data, int port)
+{
+	char *buff = (char *)data;
+	int node = port;
+
+	if (stringset != ETH_SS_STATS)
+		return;
+
+	/* for ge/xge node info */
+	buff = hns_dsaf_get_node_stats_strings(buff, node);
+
+	/* for ppe node info */
+	node = port + DSAF_PPE_INODE_BASE;
+	(void)hns_dsaf_get_node_stats_strings(buff, node);
+}
+
+/**
+ *hns_dsaf_get_sset_count - get dsaf regs count
+ *return dsaf regs count
+ */
+int hns_dsaf_get_regs_count(void)
+{
+	return DSAF_DUMP_REGS_NUM;
+}
+
+/**
+ * dsaf_probe - probo dsaf dev
+ * @pdev: dasf platform device
+ * retuen 0 - success , negative --fail
+ */
+static int hns_dsaf_probe(struct platform_device *pdev)
+{
+	struct dsaf_device *dsaf_dev;
+	int ret;
+
+	dsaf_dev = hns_dsaf_alloc_dev(&pdev->dev, sizeof(struct dsaf_drv_priv));
+	if (IS_ERR(dsaf_dev)) {
+		ret = PTR_ERR(dsaf_dev);
+		dev_err(&pdev->dev,
+			"dsaf_probe dsaf_alloc_dev failed, ret = %#x!\n", ret);
+		return ret;
+	}
+
+	ret = hns_dsaf_get_cfg(dsaf_dev);
+	if (ret)
+		goto free_dev;
+
+	ret = hns_dsaf_init(dsaf_dev);
+	if (ret)
+		goto free_cfg;
+
+	ret = hns_mac_init(dsaf_dev);
+	if (ret)
+		goto uninit_dsaf;
+
+	ret = hns_ppe_init(dsaf_dev);
+	if (ret)
+		goto uninit_mac;
+
+	ret = hns_dsaf_ae_init(dsaf_dev);
+	if (ret)
+		goto uninit_ppe;
+
+	return 0;
+
+uninit_ppe:
+	hns_ppe_uninit(dsaf_dev);
+
+uninit_mac:
+	hns_mac_uninit(dsaf_dev);
+
+uninit_dsaf:
+	hns_dsaf_free(dsaf_dev);
+
+free_cfg:
+	hns_dsaf_free_cfg(dsaf_dev);
+
+free_dev:
+	hns_dsaf_free_dev(dsaf_dev);
+
+	return ret;
+}
+
+/**
+ * dsaf_remove - remove dsaf dev
+ * @pdev: dasf platform device
+ */
+static int hns_dsaf_remove(struct platform_device *pdev)
+{
+	struct dsaf_device *dsaf_dev = dev_get_drvdata(&pdev->dev);
+
+	hns_dsaf_ae_uninit(dsaf_dev);
+
+	hns_ppe_uninit(dsaf_dev);
+
+	hns_mac_uninit(dsaf_dev);
+
+	hns_dsaf_free(dsaf_dev);
+
+	hns_dsaf_free_cfg(dsaf_dev);
+
+	hns_dsaf_free_dev(dsaf_dev);
+
+	return 0;
+}
+
+static const struct of_device_id g_dsaf_match[] = {
+	{.compatible = "hisilicon,hns-dsaf-v1"},
+	{.compatible = "hisilicon,hns-dsaf-v2"},
+	{}
+};
+
+static struct platform_driver g_dsaf_driver = {
+	.probe = hns_dsaf_probe,
+	.remove = hns_dsaf_remove,
+	.driver = {
+		.name = DSAF_DRV_NAME,
+		.of_match_table = g_dsaf_match,
+	},
+};
+
+module_platform_driver(g_dsaf_driver);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Huawei Tech. Co., Ltd.");
+MODULE_DESCRIPTION("HNS DSAF driver");
+MODULE_VERSION(DSAF_MOD_VERSION);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
new file mode 100644
index 0000000..e0417c0
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -0,0 +1,427 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __HNS_DSAF_MAIN_H
+#define __HNS_DSAF_MAIN_H
+#include "hnae.h"
+
+#include "hns_dsaf_reg.h"
+#include "hns_dsaf_mac.h"
+
+struct hns_mac_cb;
+
+#define DSAF_DRV_NAME "hns_dsaf"
+#define DSAF_MOD_VERSION "v1.0"
+
+#define ENABLE		(0x1)
+#define DISABLE		(0x0)
+
+#define HNS_DSAF_DEBUG_NW_REG_OFFSET (0x100000)
+
+#define DSAF_BASE_INNER_PORT_NUM (127)  /* mac tbl qid*/
+
+#define DSAF_MAX_CHIP_NUM (2)  /*max 2 chips */
+
+#define DSAF_DEFAUTL_QUEUE_NUM_PER_PPE (22)
+
+#define HNS_DSAF_MAX_DESC_CNT (1024)
+#define HNS_DSAF_MIN_DESC_CNT (16)
+
+#define DSAF_INVALID_ENTRY_IDX (0xffff)
+
+#define DSAF_CFG_READ_CNT   (30)
+#define DSAF_SRAM_INIT_FINISH_FLAG (0xff)
+
+#define MAC_NUM_OCTETS_PER_ADDR 6
+
+#define DSAF_DUMP_REGS_NUM 504
+#define DSAF_STATIC_NUM 28
+
+#define DSAF_STATS_READ(p, offset) (*((u64 *)((u64)(p) + (offset))))
+
+enum hal_dsaf_mode {
+	HRD_DSAF_NO_DSAF_MODE	= 0x0,
+	HRD_DSAF_MODE		= 0x1,
+};
+
+enum hal_dsaf_tc_mode {
+	HRD_DSAF_4TC_MODE		= 0X0,
+	HRD_DSAF_8TC_MODE		= 0X1,
+};
+
+struct dsaf_vm_def_vlan {
+	u32 vm_def_vlan_id;
+	u32 vm_def_vlan_cfi;
+	u32 vm_def_vlan_pri;
+};
+
+struct dsaf_tbl_tcam_data {
+	u32 tbl_tcam_data_high;
+	u32 tbl_tcam_data_low;
+};
+
+#define DSAF_PORT_MSK_NUM \
+	((DSAF_TOTAL_QUEUE_NUM + DSAF_SERVICE_NW_NUM - 1) / 32 + 1)
+struct dsaf_tbl_tcam_mcast_cfg {
+	u8 tbl_mcast_old_en;
+	u8 tbl_mcast_item_vld;
+	u32 tbl_mcast_port_msk[DSAF_PORT_MSK_NUM];
+};
+
+struct dsaf_tbl_tcam_ucast_cfg {
+	u32 tbl_ucast_old_en;
+	u32 tbl_ucast_item_vld;
+	u32 tbl_ucast_mac_discard;
+	u32 tbl_ucast_dvc;
+	u32 tbl_ucast_out_port;
+};
+
+struct dsaf_tbl_line_cfg {
+	u32 tbl_line_mac_discard;
+	u32 tbl_line_dvc;
+	u32 tbl_line_out_port;
+};
+
+enum dsaf_port_rate_mode {
+	DSAF_PORT_RATE_1000 = 0,
+	DSAF_PORT_RATE_2500,
+	DSAF_PORT_RATE_10000
+};
+
+enum dsaf_stp_port_type {
+	DSAF_STP_PORT_TYPE_DISCARD = 0,
+	DSAF_STP_PORT_TYPE_BLOCK = 1,
+	DSAF_STP_PORT_TYPE_LISTEN = 2,
+	DSAF_STP_PORT_TYPE_LEARN = 3,
+	DSAF_STP_PORT_TYPE_FORWARD = 4
+};
+
+enum dsaf_sw_port_type {
+	DSAF_SW_PORT_TYPE_NON_VLAN = 0,
+	DSAF_SW_PORT_TYPE_ACCESS = 1,
+	DSAF_SW_PORT_TYPE_TRUNK = 2,
+};
+
+#define DSAF_SUB_BASE_SIZE                        (0x10000)
+
+/* dsaf mode define */
+enum dsaf_mode {
+	DSAF_MODE_INVALID = 0,	/**< Invalid dsaf mode */
+	DSAF_MODE_ENABLE_FIX,	/**< en DSAF-mode, fixed to queue*/
+	DSAF_MODE_ENABLE_0VM,	/**< en DSAF-mode, support 0 VM */
+	DSAF_MODE_ENABLE_8VM,	/**< en DSAF-mode, support 8 VM */
+	DSAF_MODE_ENABLE_16VM,	/**< en DSAF-mode, support 16 VM */
+	DSAF_MODE_ENABLE_32VM,	/**< en DSAF-mode, support 32 VM */
+	DSAF_MODE_ENABLE_128VM,	/**< en DSAF-mode, support 128 VM */
+	DSAF_MODE_ENABLE,		/**< before is enable DSAF mode*/
+	DSAF_MODE_DISABLE_FIX,	/**< non-dasf, fixed to queue*/
+	DSAF_MODE_DISABLE_2PORT_8VM,	/**< non-dasf, 2port 8VM */
+	DSAF_MODE_DISABLE_2PORT_16VM,	/**< non-dasf, 2port 16VM */
+	DSAF_MODE_DISABLE_2PORT_64VM,	/**< non-dasf, 2port 64VM */
+	DSAF_MODE_DISABLE_6PORT_0VM,	/**< non-dasf, 6port 0VM */
+	DSAF_MODE_DISABLE_6PORT_2VM,	/**< non-dasf, 6port 2VM */
+	DSAF_MODE_DISABLE_6PORT_4VM,	/**< non-dasf, 6port 4VM */
+	DSAF_MODE_DISABLE_6PORT_16VM,	/**< non-dasf, 6port 16VM */
+	DSAF_MODE_MAX		/**< the last one, use as the num */
+};
+
+#define DSAF_DEST_PORT_NUM 256	/* DSAF max port num */
+#define DSAF_WORD_BIT_CNT 32  /* the num bit of word */
+
+/*mac entry, mc or uc entry*/
+struct dsaf_drv_mac_single_dest_entry {
+	/* mac addr, match the entry*/
+	u8 addr[MAC_NUM_OCTETS_PER_ADDR];
+	u16 in_vlan_id; /* value of VlanId */
+
+	/* the vld input port num, dsaf-mode fix 0, */
+	/*	non-dasf is the entry whitch port vld*/
+	u8 in_port_num;
+
+	u8 port_num; /*output port num*/
+	u8 rsv[6];
+};
+
+/*only mc entry*/
+struct dsaf_drv_mac_multi_dest_entry {
+	/* mac addr, match the entry*/
+	u8 addr[MAC_NUM_OCTETS_PER_ADDR];
+	u16 in_vlan_id;
+	/* this mac addr output port,*/
+	/*	bit0-bit5 means Port0-Port5(1bit is vld)**/
+	u32 port_mask[DSAF_DEST_PORT_NUM / DSAF_WORD_BIT_CNT];
+
+	/* the vld input port num, dsaf-mode fix 0,*/
+	/*	non-dasf is the entry whitch port vld*/
+	u8 in_port_num;
+	u8 rsv[7];
+};
+
+struct dsaf_hw_stats {
+	u64 pad_drop;
+	u64 man_pkts;
+	u64 rx_pkts;
+	u64 rx_pkt_id;
+	u64 rx_pause_frame;
+	u64 release_buf_num;
+	u64 sbm_drop;
+	u64 crc_false;
+	u64 bp_drop;
+	u64 rslt_drop;
+	u64 local_addr_false;
+	u64 vlan_drop;
+	u64 stp_drop;
+	u64 tx_pkts;
+};
+
+struct hnae_vf_cb {
+	u8 port_index;
+	struct hns_mac_cb *mac_cb;
+	struct dsaf_device *dsaf_dev;
+	struct hnae_handle  ae_handle; /* must be the last number */
+};
+
+struct dsaf_int_xge_src {
+	u32    xid_xge_ecc_err_int_src;
+	u32    xid_xge_fsm_timout_int_src;
+	u32    sbm_xge_lnk_fsm_timout_int_src;
+	u32    sbm_xge_lnk_ecc_2bit_int_src;
+	u32    sbm_xge_mib_req_failed_int_src;
+	u32    sbm_xge_mib_req_fsm_timout_int_src;
+	u32    sbm_xge_mib_rels_fsm_timout_int_src;
+	u32    sbm_xge_sram_ecc_2bit_int_src;
+	u32    sbm_xge_mib_buf_sum_err_int_src;
+	u32    sbm_xge_mib_req_extra_int_src;
+	u32    sbm_xge_mib_rels_extra_int_src;
+	u32    voq_xge_start_to_over_0_int_src;
+	u32    voq_xge_start_to_over_1_int_src;
+	u32    voq_xge_ecc_err_int_src;
+};
+
+struct dsaf_int_ppe_src {
+	u32    xid_ppe_fsm_timout_int_src;
+	u32    sbm_ppe_lnk_fsm_timout_int_src;
+	u32    sbm_ppe_lnk_ecc_2bit_int_src;
+	u32    sbm_ppe_mib_req_failed_int_src;
+	u32    sbm_ppe_mib_req_fsm_timout_int_src;
+	u32    sbm_ppe_mib_rels_fsm_timout_int_src;
+	u32    sbm_ppe_sram_ecc_2bit_int_src;
+	u32    sbm_ppe_mib_buf_sum_err_int_src;
+	u32    sbm_ppe_mib_req_extra_int_src;
+	u32    sbm_ppe_mib_rels_extra_int_src;
+	u32    voq_ppe_start_to_over_0_int_src;
+	u32    voq_ppe_ecc_err_int_src;
+	u32    xod_ppe_fifo_rd_empty_int_src;
+	u32    xod_ppe_fifo_wr_full_int_src;
+};
+
+struct dsaf_int_rocee_src {
+	u32    xid_rocee_fsm_timout_int_src;
+	u32    sbm_rocee_lnk_fsm_timout_int_src;
+	u32    sbm_rocee_lnk_ecc_2bit_int_src;
+	u32    sbm_rocee_mib_req_failed_int_src;
+	u32    sbm_rocee_mib_req_fsm_timout_int_src;
+	u32    sbm_rocee_mib_rels_fsm_timout_int_src;
+	u32    sbm_rocee_sram_ecc_2bit_int_src;
+	u32    sbm_rocee_mib_buf_sum_err_int_src;
+	u32    sbm_rocee_mib_req_extra_int_src;
+	u32    sbm_rocee_mib_rels_extra_int_src;
+	u32    voq_rocee_start_to_over_0_int_src;
+	u32    voq_rocee_ecc_err_int_src;
+};
+
+struct dsaf_int_tbl_src {
+	u32    tbl_da0_mis_src;
+	u32    tbl_da1_mis_src;
+	u32    tbl_da2_mis_src;
+	u32    tbl_da3_mis_src;
+	u32    tbl_da4_mis_src;
+	u32    tbl_da5_mis_src;
+	u32    tbl_da6_mis_src;
+	u32    tbl_da7_mis_src;
+	u32    tbl_sa_mis_src;
+	u32    tbl_old_sech_end_src;
+	u32    lram_ecc_err1_src;
+	u32    lram_ecc_err2_src;
+	u32    tram_ecc_err1_src;
+	u32    tram_ecc_err2_src;
+	u32    tbl_ucast_bcast_xge0_src;
+	u32    tbl_ucast_bcast_xge1_src;
+	u32    tbl_ucast_bcast_xge2_src;
+	u32    tbl_ucast_bcast_xge3_src;
+	u32    tbl_ucast_bcast_xge4_src;
+	u32    tbl_ucast_bcast_xge5_src;
+	u32    tbl_ucast_bcast_ppe_src;
+	u32    tbl_ucast_bcast_rocee_src;
+};
+
+struct dsaf_int_stat {
+	struct dsaf_int_xge_src dsaf_int_xge_stat[DSAF_COMM_CHN];
+	struct dsaf_int_ppe_src dsaf_int_ppe_stat[DSAF_COMM_CHN];
+	struct dsaf_int_rocee_src dsaf_int_rocee_stat[DSAF_COMM_CHN];
+	struct dsaf_int_tbl_src dsaf_int_tbl_stat[1];
+
+};
+
+/* Dsaf device struct define ,and mac ->  dsaf */
+struct dsaf_device {
+	struct device *dev;
+	struct hnae_ae_dev ae_dev;
+
+	void *priv;
+
+	int virq[DSAF_IRQ_NUM];
+
+	u8 __iomem *sc_base;
+	u8 __iomem *sds_base;
+	u8 __iomem *ppe_base;
+	u8 __iomem *io_base;
+	u8 __iomem *cpld_base;
+
+	u32 desc_num; /*  desc num per queue*/
+	u32 buf_size; /*  ring buffer size */
+	int buf_size_type; /* ring buffer size-type */
+	enum dsaf_mode dsaf_mode;	 /* dsaf mode  */
+	enum hal_dsaf_mode dsaf_en;
+	enum hal_dsaf_tc_mode dsaf_tc_mode;
+	u32 dsaf_ver;
+
+	struct ppe_common_cb *ppe_common[DSAF_COMM_DEV_NUM];
+	struct rcb_common_cb *rcb_common[DSAF_COMM_DEV_NUM];
+	struct hns_mac_cb *mac_cb;
+
+	struct dsaf_hw_stats hw_stats[DSAF_NODE_NUM];
+	struct dsaf_int_stat int_stat;
+};
+
+static inline void *hns_dsaf_dev_priv(const struct dsaf_device *dsaf_dev)
+{
+	return (void *)((u64)dsaf_dev + sizeof(*dsaf_dev));
+}
+
+struct dsaf_drv_tbl_tcam_key {
+	union {
+		struct {
+			u8 mac_3;
+			u8 mac_2;
+			u8 mac_1;
+			u8 mac_0;
+		} bits;
+
+		u32 val;
+	} high;
+	union {
+		struct {
+			u32 port:4; /* port id, */
+			/* dsaf-mode fixed 0, non-dsaf-mode port id*/
+			u32 vlan:12; /* vlan id */
+			u32 mac_5:8;
+			u32 mac_4:8;
+		} bits;
+
+		u32 val;
+	} low;
+};
+
+struct dsaf_drv_soft_mac_tbl {
+	struct dsaf_drv_tbl_tcam_key tcam_key;
+	u16 index; /*the entry's index in tcam tab*/
+};
+
+struct dsaf_drv_priv {
+	/* soft tab Mac key, for hardware tab*/
+	struct dsaf_drv_soft_mac_tbl *soft_mac_tbl;
+};
+
+static inline void hns_dsaf_tbl_tcam_addr_cfg(struct dsaf_device *dsaf_dev,
+					      u32 tab_tcam_addr)
+{
+	dsaf_set_dev_field(dsaf_dev, DSAF_TBL_TCAM_ADDR_0_REG,
+			   DSAF_TBL_TCAM_ADDR_M, DSAF_TBL_TCAM_ADDR_S,
+			   tab_tcam_addr);
+}
+
+static inline void hns_dsaf_tbl_tcam_load_pul(struct dsaf_device *dsaf_dev)
+{
+	u32 o_tbl_pul;
+
+	o_tbl_pul = dsaf_read_dev(dsaf_dev, DSAF_TBL_PUL_0_REG);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_TCAM_LOAD_S, 1);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_PUL_0_REG, o_tbl_pul);
+	dsaf_set_bit(o_tbl_pul, DSAF_TBL_PUL_TCAM_LOAD_S, 0);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_PUL_0_REG, o_tbl_pul);
+}
+
+static inline void hns_dsaf_tbl_line_addr_cfg(struct dsaf_device *dsaf_dev,
+					      u32 tab_line_addr)
+{
+	dsaf_set_dev_field(dsaf_dev, DSAF_TBL_LINE_ADDR_0_REG,
+			   DSAF_TBL_LINE_ADDR_M, DSAF_TBL_LINE_ADDR_S,
+			   tab_line_addr);
+}
+
+static inline int hns_dsaf_get_comm_idx_by_port(int port)
+{
+	if ((port < DSAF_COMM_CHN) || (port == DSAF_MAX_PORT_NUM_PER_CHIP))
+		return 0;
+	else
+		return (port - DSAF_COMM_CHN + 1);
+}
+
+static inline struct hnae_vf_cb *hns_ae_get_vf_cb(
+	struct hnae_handle *handle)
+{
+	return container_of(handle, struct hnae_vf_cb, ae_handle);
+}
+
+int hns_dsaf_set_mac_uc_entry(struct dsaf_device *dsaf_dev,
+			      struct dsaf_drv_mac_single_dest_entry *mac_entry);
+int hns_dsaf_set_mac_mc_entry(struct dsaf_device *dsaf_dev,
+			      struct dsaf_drv_mac_multi_dest_entry *mac_entry);
+int hns_dsaf_add_mac_mc_port(struct dsaf_device *dsaf_dev,
+			     struct dsaf_drv_mac_single_dest_entry *mac_entry);
+int hns_dsaf_del_mac_entry(struct dsaf_device *dsaf_dev, u16 vlan_id,
+			   u8 in_port_num, u8 *addr);
+int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
+			     struct dsaf_drv_mac_single_dest_entry *mac_entry);
+int hns_dsaf_get_mac_uc_entry(struct dsaf_device *dsaf_dev,
+			      struct dsaf_drv_mac_single_dest_entry *mac_entry);
+int hns_dsaf_get_mac_mc_entry(struct dsaf_device *dsaf_dev,
+			      struct dsaf_drv_mac_multi_dest_entry *mac_entry);
+int hns_dsaf_get_mac_entry_by_index(
+	struct dsaf_device *dsaf_dev,
+	u16 entry_index,
+	struct dsaf_drv_mac_multi_dest_entry *mac_entry);
+
+void hns_dsaf_rst(struct dsaf_device *dsaf_dev, u32 val);
+
+void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val);
+
+void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val);
+
+void hns_dsaf_fix_mac_mode(struct hns_mac_cb *mac_cb);
+
+int hns_dsaf_ae_init(struct dsaf_device *dsaf_dev);
+void hns_dsaf_ae_uninit(struct dsaf_device *dsaf_dev);
+
+void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val);
+void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val);
+void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
+				    u32 port, u32 val);
+
+void hns_dsaf_update_stats(struct dsaf_device *dsaf_dev, u32 inode_num);
+
+int hns_dsaf_get_sset_count(int stringset);
+void hns_dsaf_get_stats(struct dsaf_device *ddev, u64 *data, int port);
+void hns_dsaf_get_strings(int stringset, u8 *data, int port);
+
+void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data);
+int hns_dsaf_get_regs_count(void);
+
+#endif /* __HNS_DSAF_MAIN_H__ */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
new file mode 100644
index 0000000..d611388
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -0,0 +1,317 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include "hns_dsaf_misc.h"
+#include "hns_dsaf_mac.h"
+#include "hns_dsaf_reg.h"
+#include "hns_dsaf_ppe.h"
+
+void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
+		      u16 speed, int data)
+{
+	int speed_reg = 0;
+	u8 value;
+
+	if (!mac_cb) {
+		pr_err("sfp_led_opt mac_dev is null!\n");
+		return;
+	}
+	if (!mac_cb->cpld_vaddr) {
+		dev_err(mac_cb->dev, "mac_id=%d, cpld_vaddr is null !\n",
+			mac_cb->mac_id);
+		return;
+	}
+
+	if (speed == MAC_SPEED_10000)
+		speed_reg = 1;
+
+	value = mac_cb->cpld_led_value;
+
+	if (link_status) {
+		dsaf_set_bit(value, DSAF_LED_LINK_B, link_status);
+		dsaf_set_field(value, DSAF_LED_SPEED_M,
+			       DSAF_LED_SPEED_S, speed_reg);
+		dsaf_set_bit(value, DSAF_LED_DATA_B, data);
+
+		if (value != mac_cb->cpld_led_value) {
+			dsaf_write_b(mac_cb->cpld_vaddr, value);
+			mac_cb->cpld_led_value = value;
+		}
+	} else {
+		dsaf_write_b(mac_cb->cpld_vaddr, CPLD_LED_DEFAULT_VALUE);
+		mac_cb->cpld_led_value = CPLD_LED_DEFAULT_VALUE;
+	}
+}
+
+void cpld_led_reset(struct hns_mac_cb *mac_cb)
+{
+	if (!mac_cb || !mac_cb->cpld_vaddr)
+		return;
+
+	dsaf_write_b(mac_cb->cpld_vaddr, CPLD_LED_DEFAULT_VALUE);
+	mac_cb->cpld_led_value = CPLD_LED_DEFAULT_VALUE;
+}
+
+int cpld_set_led_id(struct hns_mac_cb *mac_cb,
+		    enum hnae_led_state status)
+{
+	switch (status) {
+	case HNAE_LED_ACTIVE:
+		mac_cb->cpld_led_value = dsaf_read_b(mac_cb->cpld_vaddr);
+		return 2;
+	case HNAE_LED_ON:
+		dsaf_set_bit(mac_cb->cpld_led_value, DSAF_LED_ANCHOR_B,
+			     CPLD_LED_ON_VALUE);
+		dsaf_write_b(mac_cb->cpld_vaddr, mac_cb->cpld_led_value);
+		break;
+	case HNAE_LED_OFF:
+		dsaf_set_bit(mac_cb->cpld_led_value, DSAF_LED_ANCHOR_B,
+			     CPLD_LED_DEFAULT_VALUE);
+		dsaf_write_b(mac_cb->cpld_vaddr, mac_cb->cpld_led_value);
+		break;
+	case HNAE_LED_INACTIVE:
+		dsaf_set_bit(mac_cb->cpld_led_value, DSAF_LED_ANCHOR_B,
+			     CPLD_LED_DEFAULT_VALUE);
+		dsaf_write_b(mac_cb->cpld_vaddr, mac_cb->cpld_led_value);
+		break;
+	default:
+		break;
+	}
+
+	return 0;
+}
+
+#define RESET_REQ_OR_DREQ 1
+
+void hns_dsaf_rst(struct dsaf_device *dsaf_dev, u32 val)
+{
+	u32 xbar_reg_addr;
+	u32 nt_reg_addr;
+
+	if (!val) {
+		xbar_reg_addr = DSAF_SUB_SC_XBAR_RESET_REQ_REG;
+		nt_reg_addr = DSAF_SUB_SC_NT_RESET_REQ_REG;
+	} else {
+		xbar_reg_addr = DSAF_SUB_SC_XBAR_RESET_DREQ_REG;
+		nt_reg_addr = DSAF_SUB_SC_NT_RESET_DREQ_REG;
+	}
+
+	dsaf_write_reg(dsaf_dev->sc_base, xbar_reg_addr,
+		       RESET_REQ_OR_DREQ);
+	dsaf_write_reg(dsaf_dev->sc_base, nt_reg_addr,
+		       RESET_REQ_OR_DREQ);
+}
+
+void hns_dsaf_xge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
+{
+	u32 reg_val = 0;
+	u32 reg_addr;
+
+	if (port >= DSAF_XGE_NUM)
+		return;
+
+	reg_val |= RESET_REQ_OR_DREQ;
+	reg_val |= 0x2082082 << port;
+
+	if (val == 0)
+		reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
+	else
+		reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
+
+	dsaf_write_reg(dsaf_dev->sc_base, reg_addr, reg_val);
+}
+
+void hns_dsaf_xge_core_srst_by_port(struct dsaf_device *dsaf_dev,
+				    u32 port, u32 val)
+{
+	u32 reg_val = 0;
+	u32 reg_addr;
+
+	if (port >= DSAF_XGE_NUM)
+		return;
+
+	reg_val |= XGMAC_TRX_CORE_SRST_M << port;
+
+	if (val == 0)
+		reg_addr = DSAF_SUB_SC_XGE_RESET_REQ_REG;
+	else
+		reg_addr = DSAF_SUB_SC_XGE_RESET_DREQ_REG;
+
+	dsaf_write_reg(dsaf_dev->sc_base, reg_addr, reg_val);
+}
+
+void hns_dsaf_ge_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
+{
+	u32 reg_val_1;
+	u32 reg_val_2;
+
+	if (port >= DSAF_GE_NUM)
+		return;
+
+	if (port < DSAF_SERVICE_NW_NUM) {
+		reg_val_1  = 0x1 << port;
+		reg_val_2  = 0x1041041 << port;
+
+		if (val == 0) {
+			dsaf_write_reg(dsaf_dev->sc_base,
+				       DSAF_SUB_SC_GE_RESET_REQ1_REG,
+				       reg_val_1);
+
+			dsaf_write_reg(dsaf_dev->sc_base,
+				       DSAF_SUB_SC_GE_RESET_REQ0_REG,
+				       reg_val_2);
+		} else {
+			dsaf_write_reg(dsaf_dev->sc_base,
+				       DSAF_SUB_SC_GE_RESET_DREQ0_REG,
+				       reg_val_2);
+
+			dsaf_write_reg(dsaf_dev->sc_base,
+				       DSAF_SUB_SC_GE_RESET_DREQ1_REG,
+				       reg_val_1);
+		}
+	} else {
+		reg_val_1 = 0x15540 << (port - 6);
+		reg_val_2 = 0x100 << (port - 6);
+
+		if (val == 0) {
+			dsaf_write_reg(dsaf_dev->sc_base,
+				       DSAF_SUB_SC_GE_RESET_REQ1_REG,
+				       reg_val_1);
+
+			dsaf_write_reg(dsaf_dev->sc_base,
+				       DSAF_SUB_SC_PPE_RESET_REQ_REG,
+				       reg_val_2);
+		} else {
+			dsaf_write_reg(dsaf_dev->sc_base,
+				       DSAF_SUB_SC_GE_RESET_DREQ1_REG,
+				       reg_val_1);
+
+			dsaf_write_reg(dsaf_dev->sc_base,
+				       DSAF_SUB_SC_PPE_RESET_DREQ_REG,
+				       reg_val_2);
+		}
+	}
+}
+
+void hns_ppe_srst_by_port(struct dsaf_device *dsaf_dev, u32 port, u32 val)
+{
+	u32 reg_val = 0;
+	u32 reg_addr;
+
+	reg_val |= RESET_REQ_OR_DREQ << port;
+
+	if (val == 0)
+		reg_addr = DSAF_SUB_SC_PPE_RESET_REQ_REG;
+	else
+		reg_addr = DSAF_SUB_SC_PPE_RESET_DREQ_REG;
+
+	dsaf_write_reg(dsaf_dev->sc_base, reg_addr, reg_val);
+}
+
+void hns_ppe_com_srst(struct ppe_common_cb *ppe_common, u32 val)
+{
+	int comm_index = ppe_common->comm_index;
+	struct dsaf_device *dsaf_dev = ppe_common->dsaf_dev;
+	u32 reg_val;
+	u32 reg_addr;
+
+	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
+		reg_val = RESET_REQ_OR_DREQ;
+		if (val == 0)
+			reg_addr = DSAF_SUB_SC_RCB_PPE_COM_RESET_REQ_REG;
+		else
+			reg_addr = DSAF_SUB_SC_RCB_PPE_COM_RESET_DREQ_REG;
+
+	} else {
+		reg_val = 0x100 << (comm_index - 1);
+
+		if (val == 0)
+			reg_addr = DSAF_SUB_SC_PPE_RESET_REQ_REG;
+		else
+			reg_addr = DSAF_SUB_SC_PPE_RESET_DREQ_REG;
+	}
+
+	dsaf_write_reg(dsaf_dev->sc_base, reg_addr, reg_val);
+}
+
+/**
+ * hns_mac_get_sds_mode - get phy ifterface form serdes mode
+ * @mac_cb: mac control block
+ * retuen phy interface
+ */
+phy_interface_t hns_mac_get_phy_if(struct hns_mac_cb *mac_cb)
+{
+	u32 hilink3_mode;
+	u32 hilink4_mode;
+	void __iomem *sys_ctl_vaddr = mac_cb->sys_ctl_vaddr;
+	int dev_id = mac_cb->mac_id;
+	phy_interface_t phy_if = PHY_INTERFACE_MODE_NA;
+
+	hilink3_mode = dsaf_read_reg(sys_ctl_vaddr, HNS_MAC_HILINK3_REG);
+	hilink4_mode = dsaf_read_reg(sys_ctl_vaddr, HNS_MAC_HILINK4_REG);
+	if (dev_id >= 0 && dev_id <= 3) {
+		if (hilink4_mode == 0)
+			phy_if = PHY_INTERFACE_MODE_SGMII;
+		else
+			phy_if = PHY_INTERFACE_MODE_XGMII;
+	} else if (dev_id >= 4 && dev_id <= 5) {
+		if (hilink3_mode == 0)
+			phy_if = PHY_INTERFACE_MODE_SGMII;
+		else
+			phy_if = PHY_INTERFACE_MODE_XGMII;
+	} else {
+		phy_if = PHY_INTERFACE_MODE_SGMII;
+	}
+
+	dev_dbg(mac_cb->dev,
+		"hilink3_mode=%d, hilink4_mode=%d dev_id=%d, phy_if=%d\n",
+		hilink3_mode, hilink4_mode, dev_id, phy_if);
+	return phy_if;
+}
+
+/**
+ * hns_mac_config_sds_loopback - set loop back for serdes
+ * @mac_cb: mac control block
+ * retuen 0 == success
+ */
+int hns_mac_config_sds_loopback(struct hns_mac_cb *mac_cb, u8 en)
+{
+	/* port 0-3 hilink4 base is serdes_vaddr + 0x00280000
+	 * port 4-7 hilink3 base is serdes_vaddr + 0x00200000
+	 */
+	u8 *base_addr = (u8 *)mac_cb->serdes_vaddr +
+		       (mac_cb->mac_id <= 3 ? 0x00280000 : 0x00200000);
+	const u8 lane_id[] = {
+		0,	/* mac 0 -> lane 0 */
+		1,	/* mac 1 -> lane 1 */
+		2,	/* mac 2 -> lane 2 */
+		3,	/* mac 3 -> lane 3 */
+		2,	/* mac 4 -> lane 2 */
+		3,	/* mac 5 -> lane 3 */
+		0,	/* mac 6 -> lane 0 */
+		1	/* mac 7 -> lane 1 */
+	};
+#define RX_CSR(lane, reg) ((0x4080 + (reg) * 0x0002 + (lane) * 0x0200) * 2)
+	u64 reg_offset = RX_CSR(lane_id[mac_cb->mac_id], 0);
+
+	int sfp_prsnt;
+	int ret = hns_mac_get_sfp_prsnt(mac_cb, &sfp_prsnt);
+
+	if (!mac_cb->phy_node) {
+		if (ret)
+			pr_info("please confirm sfp is present or not\n");
+		else
+			if (!sfp_prsnt)
+				pr_info("no sfp in this eth\n");
+	}
+
+	dsaf_set_reg_field(base_addr, reg_offset, 1ull << 10, 10, !!en);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h
new file mode 100644
index 0000000..419f07a
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.h
@@ -0,0 +1,43 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_DSAF_MISC_H
+#define _HNS_DSAF_MISC_H
+
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/platform_device.h>
+
+#include "hns_dsaf_mac.h"
+
+#define CPLD_ADDR_PORT_OFFSET	0x4
+
+#define HS_LED_ON		0xE
+#define HS_LED_OFF		0xF
+
+#define CPLD_LED_ON_VALUE	1
+#define CPLD_LED_DEFAULT_VALUE	0
+
+#define MAC_SFP_PORT_OFFSET	0x2
+
+#define DSAF_LED_SPEED_S 0
+#define DSAF_LED_SPEED_M (0x3 << DSAF_LED_SPEED_S)
+
+#define DSAF_LED_LINK_B 2
+#define DSAF_LED_DATA_B 4
+#define DSAF_LED_ANCHOR_B 5
+
+void hns_cpld_set_led(struct hns_mac_cb *mac_cb, int link_status,
+		      u16 speed, int data);
+void cpld_led_reset(struct hns_mac_cb *mac_cb);
+int cpld_set_led_id(struct hns_mac_cb *mac_cb,
+		    enum hnae_led_state status);
+int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt);
+
+#endif
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
new file mode 100644
index 0000000..67f33f1
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -0,0 +1,583 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/platform_device.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/of_platform.h>
+
+#include "hns_dsaf_ppe.h"
+
+static void __iomem *hns_ppe_common_get_ioaddr(
+	struct ppe_common_cb *ppe_common)
+{
+	void __iomem *base_addr;
+
+	int idx = ppe_common->comm_index;
+
+	if (idx == HNS_DSAF_COMM_SERVICE_NW_IDX)
+		base_addr = ppe_common->dsaf_dev->ppe_base
+			+ PPE_COMMON_REG_OFFSET;
+	else
+		base_addr = ppe_common->dsaf_dev->sds_base
+			+ (idx - 1) * HNS_DSAF_DEBUG_NW_REG_OFFSET
+			+ PPE_COMMON_REG_OFFSET;
+
+	return base_addr;
+}
+
+/**
+ * hns_ppe_common_get_cfg - get ppe common config
+ * @dsaf_dev: dasf device
+ * comm_index: common index
+ * retuen 0 - success , negative --fail
+ */
+int hns_ppe_common_get_cfg(struct dsaf_device *dsaf_dev, int comm_index)
+{
+	struct ppe_common_cb *ppe_common;
+	int ppe_num;
+
+	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX)
+		ppe_num = HNS_PPE_SERVICE_NW_ENGINE_NUM;
+	else
+		ppe_num = HNS_PPE_DEBUG_NW_ENGINE_NUM;
+
+	ppe_common = devm_kzalloc(dsaf_dev->dev, sizeof(*ppe_common) +
+		ppe_num * sizeof(struct hns_ppe_cb), GFP_KERNEL);
+	if (!ppe_common)
+		return -ENOMEM;
+
+	ppe_common->ppe_num = ppe_num;
+	ppe_common->dsaf_dev = dsaf_dev;
+	ppe_common->comm_index = comm_index;
+	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX)
+		ppe_common->ppe_mode = PPE_COMMON_MODE_SERVICE;
+	else
+		ppe_common->ppe_mode = PPE_COMMON_MODE_DEBUG;
+	ppe_common->dev = dsaf_dev->dev;
+
+	ppe_common->io_base = hns_ppe_common_get_ioaddr(ppe_common);
+
+	dsaf_dev->ppe_common[comm_index] = ppe_common;
+
+	return 0;
+}
+
+void hns_ppe_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index)
+{
+	dsaf_dev->ppe_common[comm_index] = NULL;
+}
+
+static void __iomem *hns_ppe_get_iobase(struct ppe_common_cb *ppe_common,
+					int ppe_idx)
+{
+	void __iomem *base_addr;
+	int common_idx = ppe_common->comm_index;
+
+	if (ppe_common->ppe_mode == PPE_COMMON_MODE_SERVICE) {
+		base_addr = ppe_common->dsaf_dev->ppe_base +
+			ppe_idx * PPE_REG_OFFSET;
+
+	} else {
+		base_addr = ppe_common->dsaf_dev->sds_base +
+			(common_idx - 1) * HNS_DSAF_DEBUG_NW_REG_OFFSET;
+	}
+
+	return base_addr;
+}
+
+static int hns_ppe_get_port(struct ppe_common_cb *ppe_common, int idx)
+{
+	int port;
+
+	if (ppe_common->ppe_mode == PPE_COMMON_MODE_SERVICE)
+		port = idx;
+	else
+		port = HNS_PPE_SERVICE_NW_ENGINE_NUM
+			+ ppe_common->comm_index - 1;
+
+	return port;
+}
+
+static void hns_ppe_get_cfg(struct ppe_common_cb *ppe_common)
+{
+	u32 i;
+	struct hns_ppe_cb *ppe_cb;
+	u32 ppe_num = ppe_common->ppe_num;
+
+	for (i = 0; i < ppe_num; i++) {
+		ppe_cb = &ppe_common->ppe_cb[i];
+		ppe_cb->dev = ppe_common->dev;
+		ppe_cb->next = NULL;
+		ppe_cb->ppe_common_cb = ppe_common;
+		ppe_cb->index = i;
+		ppe_cb->port = hns_ppe_get_port(ppe_common, i);
+		ppe_cb->io_base = hns_ppe_get_iobase(ppe_common, i);
+		ppe_cb->virq = 0;
+	}
+}
+
+static void hns_ppe_cnt_clr_ce(struct hns_ppe_cb *ppe_cb)
+{
+	dsaf_set_dev_bit(ppe_cb, PPE_TNL_0_5_CNT_CLR_CE_REG,
+			 PPE_CNT_CLR_CE_B, 1);
+}
+
+/**
+ * hns_ppe_checksum_hw - set ppe checksum caculate
+ * @ppe_device: ppe device
+ * @value: value
+ */
+static void hns_ppe_checksum_hw(struct hns_ppe_cb *ppe_cb, u32 value)
+{
+	dsaf_set_dev_field(ppe_cb, PPE_CFG_PRO_CHECK_EN_REG,
+			   0xfffffff, 0, value);
+}
+
+static void hns_ppe_set_qid_mode(struct ppe_common_cb *ppe_common,
+				 enum ppe_qid_mode qid_mdoe)
+{
+	dsaf_set_dev_field(ppe_common, PPE_COM_CFG_QID_MODE_REG,
+			   PPE_CFG_QID_MODE_CF_QID_MODE_M,
+			   PPE_CFG_QID_MODE_CF_QID_MODE_S, qid_mdoe);
+}
+
+/**
+ * hns_ppe_set_qid - set ppe qid
+ * @ppe_common: ppe common device
+ * @qid: queue id
+ */
+static void hns_ppe_set_qid(struct ppe_common_cb *ppe_common, u32 qid)
+{
+	u32 qid_mod = dsaf_read_dev(ppe_common, PPE_COM_CFG_QID_MODE_REG);
+
+	if (!dsaf_get_field(qid_mod, PPE_CFG_QID_MODE_DEF_QID_M,
+			    PPE_CFG_QID_MODE_DEF_QID_S)) {
+		dsaf_set_field(qid_mod, PPE_CFG_QID_MODE_DEF_QID_M,
+			       PPE_CFG_QID_MODE_DEF_QID_S, qid);
+		dsaf_write_dev(ppe_common, PPE_COM_CFG_QID_MODE_REG, qid_mod);
+	}
+}
+
+/**
+ * hns_ppe_set_port_mode - set port mode
+ * @ppe_device: ppe device
+ * @mode: port mode
+ */
+static void hns_ppe_set_port_mode(struct hns_ppe_cb *ppe_cb,
+				  enum ppe_port_mode mode)
+{
+	dsaf_write_dev(ppe_cb, PPE_CFG_XGE_MODE_REG, mode);
+}
+
+/**
+ * hns_ppe_common_init_hw - init ppe common device
+ * @ppe_common: ppe common device
+ *
+ * Return 0 on success, negative on failure
+ */
+static int hns_ppe_common_init_hw(struct ppe_common_cb *ppe_common)
+{
+	enum ppe_qid_mode qid_mode;
+	enum dsaf_mode dsaf_mode = ppe_common->dsaf_dev->dsaf_mode;
+
+	hns_ppe_com_srst(ppe_common, 0);
+	mdelay(100);
+	hns_ppe_com_srst(ppe_common, 1);
+	mdelay(100);
+
+	if (ppe_common->ppe_mode == PPE_COMMON_MODE_SERVICE) {
+		switch (dsaf_mode) {
+		case DSAF_MODE_ENABLE_FIX:
+		case DSAF_MODE_DISABLE_FIX:
+			qid_mode = PPE_QID_MODE0;
+			hns_ppe_set_qid(ppe_common, 0);
+			break;
+		case DSAF_MODE_ENABLE_0VM:
+		case DSAF_MODE_DISABLE_2PORT_64VM:
+			qid_mode = PPE_QID_MODE3;
+			break;
+		case DSAF_MODE_ENABLE_8VM:
+		case DSAF_MODE_DISABLE_2PORT_16VM:
+			qid_mode = PPE_QID_MODE4;
+			break;
+		case DSAF_MODE_ENABLE_16VM:
+		case DSAF_MODE_DISABLE_6PORT_0VM:
+			qid_mode = PPE_QID_MODE5;
+			break;
+		case DSAF_MODE_ENABLE_32VM:
+		case DSAF_MODE_DISABLE_6PORT_16VM:
+			qid_mode = PPE_QID_MODE2;
+			break;
+		case DSAF_MODE_ENABLE_128VM:
+		case DSAF_MODE_DISABLE_6PORT_4VM:
+			qid_mode = PPE_QID_MODE1;
+			break;
+		case DSAF_MODE_DISABLE_2PORT_8VM:
+			qid_mode = PPE_QID_MODE7;
+			break;
+		case DSAF_MODE_DISABLE_6PORT_2VM:
+			qid_mode = PPE_QID_MODE6;
+			break;
+		default:
+			dev_err(ppe_common->dev,
+				"get ppe queue mode failed! dsaf_mode=%d\n",
+				dsaf_mode);
+			return -EINVAL;
+		}
+		hns_ppe_set_qid_mode(ppe_common, qid_mode);
+	}
+
+	dsaf_set_dev_bit(ppe_common, PPE_COM_COMMON_CNT_CLR_CE_REG,
+			 PPE_COMMON_CNT_CLR_CE_B, 1);
+
+	return 0;
+}
+
+/*clr ppe exception irq*/
+static void hns_ppe_exc_irq_en(struct hns_ppe_cb *ppe_cb, int en)
+{
+	u32 clr_vlue = 0xfffffffful;
+	u32 msk_vlue = en ? 0xfffffffful : 0; /*1 is en, 0 is dis*/
+	u32 vld_msk = 0;
+
+	/*only care bit 0,1,7*/
+	dsaf_set_bit(vld_msk, 0, 1);
+	dsaf_set_bit(vld_msk, 1, 1);
+	dsaf_set_bit(vld_msk, 7, 1);
+
+	/*clr sts**/
+	dsaf_write_dev(ppe_cb, PPE_RINT_REG, clr_vlue);
+
+	/*for some reserved bits, so set 0**/
+	dsaf_write_dev(ppe_cb, PPE_INTEN_REG, msk_vlue & vld_msk);
+}
+
+/**
+ * ppe_init_hw - init ppe
+ * @ppe_device: ppe device
+ */
+static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)
+{
+	struct ppe_common_cb *ppe_common_cb = ppe_cb->ppe_common_cb;
+	u32 port = ppe_cb->port;
+	struct dsaf_device *dsaf_dev = ppe_common_cb->dsaf_dev;
+
+	hns_ppe_srst_by_port(dsaf_dev, port, 0);
+	mdelay(10);
+	hns_ppe_srst_by_port(dsaf_dev, port, 1);
+
+	/* clr and msk except irq*/
+	hns_ppe_exc_irq_en(ppe_cb, 0);
+
+	if (ppe_common_cb->ppe_mode == PPE_COMMON_MODE_DEBUG)
+		hns_ppe_set_port_mode(ppe_cb, PPE_MODE_GE);
+	else
+		hns_ppe_set_port_mode(ppe_cb, PPE_MODE_XGE);
+	hns_ppe_checksum_hw(ppe_cb, 0xffffffff);
+	hns_ppe_cnt_clr_ce(ppe_cb);
+}
+
+/**
+ * ppe_uninit_hw - uninit ppe
+ * @ppe_device: ppe device
+ */
+static void hns_ppe_uninit_hw(struct hns_ppe_cb *ppe_cb)
+{
+	u32 port;
+
+	if (ppe_cb->ppe_common_cb) {
+		port = ppe_cb->index;
+		hns_ppe_srst_by_port(ppe_cb->ppe_common_cb->dsaf_dev, port, 0);
+	}
+}
+
+void hns_ppe_uninit_ex(struct ppe_common_cb *ppe_common)
+{
+	u32 i;
+
+	for (i = 0; i < ppe_common->ppe_num; i++) {
+		hns_ppe_uninit_hw(&ppe_common->ppe_cb[i]);
+		memset(&ppe_common->ppe_cb[i], 0, sizeof(struct hns_ppe_cb));
+	}
+}
+
+void hns_ppe_uninit(struct dsaf_device *dsaf_dev)
+{
+	u32 i;
+
+	for (i = 0; i < HNS_PPE_COM_NUM; i++) {
+		if (dsaf_dev->ppe_common[i])
+			hns_ppe_uninit_ex(dsaf_dev->ppe_common[i]);
+		hns_rcb_common_free_cfg(dsaf_dev, i);
+		hns_ppe_common_free_cfg(dsaf_dev, i);
+	}
+}
+
+/**
+ * hns_ppe_reset - reinit ppe/rcb hw
+ * @dsaf_dev: dasf device
+ * retuen void
+ */
+void hns_ppe_reset_common(struct dsaf_device *dsaf_dev, u8 ppe_common_index)
+{
+	u32 i;
+	int ret;
+	struct ppe_common_cb *ppe_common;
+
+	ppe_common = dsaf_dev->ppe_common[ppe_common_index];
+	ret = hns_ppe_common_init_hw(ppe_common);
+	if (ret)
+		return;
+
+	ret = hns_rcb_common_init_hw(dsaf_dev->rcb_common[ppe_common_index]);
+	if (ret)
+		return;
+
+	for (i = 0; i < ppe_common->ppe_num; i++)
+		hns_ppe_init_hw(&ppe_common->ppe_cb[i]);
+
+	hns_rcb_common_init_commit_hw(dsaf_dev->rcb_common[ppe_common_index]);
+}
+
+void hns_ppe_update_stats(struct hns_ppe_cb *ppe_cb)
+{
+	struct hns_ppe_hw_stats *hw_stats = &ppe_cb->hw_stats;
+
+	hw_stats->rx_pkts_from_sw
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_RX_SW_PKT_CNT_REG);
+	hw_stats->rx_pkts
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_RX_WR_BD_OK_PKT_CNT_REG);
+	hw_stats->rx_drop_no_bd
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_RX_PKT_NO_BUF_CNT_REG);
+	hw_stats->rx_alloc_buf_fail
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_RX_APP_BUF_FAIL_CNT_REG);
+	hw_stats->rx_alloc_buf_wait
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_RX_APP_BUF_WAIT_CNT_REG);
+	hw_stats->rx_drop_no_buf
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_RX_PKT_DROP_FUL_CNT_REG);
+	hw_stats->rx_err_fifo_full
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_RX_PKT_DROP_PRT_CNT_REG);
+
+	hw_stats->tx_bd_form_rcb
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_TX_BD_CNT_REG);
+	hw_stats->tx_pkts_from_rcb
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_TX_PKT_CNT_REG);
+	hw_stats->tx_pkts
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_TX_PKT_OK_CNT_REG);
+	hw_stats->tx_err_fifo_empty
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_TX_PKT_EPT_CNT_REG);
+	hw_stats->tx_err_checksum
+		+= dsaf_read_dev(ppe_cb, PPE_HIS_TX_PKT_CS_FAIL_CNT_REG);
+}
+
+int hns_ppe_get_sset_count(int stringset)
+{
+	if (stringset == ETH_SS_STATS)
+		return ETH_PPE_STATIC_NUM;
+	return 0;
+}
+
+int hns_ppe_get_regs_count(void)
+{
+	return ETH_PPE_DUMP_NUM;
+}
+
+/**
+ * ppe_get_strings - get ppe srting
+ * @ppe_device: ppe device
+ * @stringset: string set type
+ * @data: output string
+ */
+void hns_ppe_get_strings(struct hns_ppe_cb *ppe_cb, int stringset, u8 *data)
+{
+	char *buff = (char *)data;
+	int index = ppe_cb->index;
+
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_rx_sw_pkt", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_rx_pkt_ok", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_rx_drop_pkt_no_bd", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_rx_alloc_buf_fail", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_rx_alloc_buf_wait", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_rx_pkt_drop_no_buf", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_rx_pkt_err_fifo_full", index);
+	buff = buff + ETH_GSTRING_LEN;
+
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_tx_bd", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_tx_pkt", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_tx_pkt_ok", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_tx_pkt_err_fifo_empty", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "ppe%d_tx_pkt_err_csum_fail", index);
+}
+
+void hns_ppe_get_stats(struct hns_ppe_cb *ppe_cb, u64 *data)
+{
+	u64 *regs_buff = data;
+	struct hns_ppe_hw_stats *hw_stats = &ppe_cb->hw_stats;
+
+	regs_buff[0] = hw_stats->rx_pkts_from_sw;
+	regs_buff[1] = hw_stats->rx_pkts;
+	regs_buff[2] = hw_stats->rx_drop_no_bd;
+	regs_buff[3] = hw_stats->rx_alloc_buf_fail;
+	regs_buff[4] = hw_stats->rx_alloc_buf_wait;
+	regs_buff[5] = hw_stats->rx_drop_no_buf;
+	regs_buff[6] = hw_stats->rx_err_fifo_full;
+
+	regs_buff[7] = hw_stats->tx_bd_form_rcb;
+	regs_buff[8] = hw_stats->tx_pkts_from_rcb;
+	regs_buff[9] = hw_stats->tx_pkts;
+	regs_buff[10] = hw_stats->tx_err_fifo_empty;
+	regs_buff[11] = hw_stats->tx_err_checksum;
+}
+
+/**
+ * hns_ppe_init - init ppe device
+ * @dsaf_dev: dasf device
+ * retuen 0 - success , negative --fail
+ */
+int hns_ppe_init(struct dsaf_device *dsaf_dev)
+{
+	int i, k;
+	int ret;
+
+	for (i = 0; i < HNS_PPE_COM_NUM; i++) {
+		ret = hns_ppe_common_get_cfg(dsaf_dev, i);
+		if (ret)
+			goto get_ppe_cfg_fail;
+
+		ret = hns_rcb_common_get_cfg(dsaf_dev, i);
+		if (ret)
+			goto get_rcb_cfg_fail;
+
+		hns_ppe_get_cfg(dsaf_dev->ppe_common[i]);
+
+		hns_rcb_get_cfg(dsaf_dev->rcb_common[i]);
+	}
+
+	for (i = 0; i < HNS_PPE_COM_NUM; i++)
+		hns_ppe_reset_common(dsaf_dev, i);
+
+	return 0;
+
+get_rcb_cfg_fail:
+	hns_ppe_common_free_cfg(dsaf_dev, i);
+get_ppe_cfg_fail:
+	for (k = i - 1; k >= 0; k--) {
+		hns_rcb_common_free_cfg(dsaf_dev, k);
+		hns_ppe_common_free_cfg(dsaf_dev, k);
+	}
+	return ret;
+}
+
+void hns_ppe_get_regs(struct hns_ppe_cb *ppe_cb, void *data)
+{
+	struct ppe_common_cb *ppe_common = ppe_cb->ppe_common_cb;
+	u32 *regs = data;
+	u32 i;
+	u32 offset;
+
+	/* ppe common registers */
+	regs[0] = dsaf_read_dev(ppe_common, PPE_COM_CFG_QID_MODE_REG);
+	regs[1] = dsaf_read_dev(ppe_common, PPE_COM_INTEN_REG);
+	regs[2] = dsaf_read_dev(ppe_common, PPE_COM_RINT_REG);
+	regs[3] = dsaf_read_dev(ppe_common, PPE_COM_INTSTS_REG);
+	regs[4] = dsaf_read_dev(ppe_common, PPE_COM_COMMON_CNT_CLR_CE_REG);
+
+	for (i = 0; i < DSAF_TOTAL_QUEUE_NUM; i++) {
+		offset = PPE_COM_HIS_RX_PKT_QID_DROP_CNT_REG + 0x4 * i;
+		regs[5 + i] = dsaf_read_dev(ppe_common, offset);
+		offset = PPE_COM_HIS_RX_PKT_QID_OK_CNT_REG + 0x4 * i;
+		regs[5 + i + DSAF_TOTAL_QUEUE_NUM]
+				= dsaf_read_dev(ppe_common, offset);
+		offset = PPE_COM_HIS_TX_PKT_QID_ERR_CNT_REG + 0x4 * i;
+		regs[5 + i + DSAF_TOTAL_QUEUE_NUM * 2]
+				= dsaf_read_dev(ppe_common, offset);
+		offset = PPE_COM_HIS_TX_PKT_QID_OK_CNT_REG + 0x4 * i;
+		regs[5 + i + DSAF_TOTAL_QUEUE_NUM * 3]
+				= dsaf_read_dev(ppe_common, offset);
+	}
+
+	/* mark end of ppe regs */
+	for (i = 521; i < 524; i++)
+		regs[i] = 0xeeeeeeee;
+
+	/* ppe channel registers */
+	regs[525] = dsaf_read_dev(ppe_cb, PPE_CFG_TX_FIFO_THRSLD_REG);
+	regs[526] = dsaf_read_dev(ppe_cb, PPE_CFG_RX_FIFO_THRSLD_REG);
+	regs[527] = dsaf_read_dev(ppe_cb, PPE_CFG_RX_FIFO_PAUSE_THRSLD_REG);
+	regs[528] = dsaf_read_dev(ppe_cb, PPE_CFG_RX_FIFO_SW_BP_THRSLD_REG);
+	regs[529] = dsaf_read_dev(ppe_cb, PPE_CFG_PAUSE_IDLE_CNT_REG);
+	regs[530] = dsaf_read_dev(ppe_cb, PPE_CFG_BUS_CTRL_REG);
+	regs[531] = dsaf_read_dev(ppe_cb, PPE_CFG_TNL_TO_BE_RST_REG);
+	regs[532] = dsaf_read_dev(ppe_cb, PPE_CURR_TNL_CAN_RST_REG);
+
+	regs[533] = dsaf_read_dev(ppe_cb, PPE_CFG_XGE_MODE_REG);
+	regs[534] = dsaf_read_dev(ppe_cb, PPE_CFG_MAX_FRAME_LEN_REG);
+	regs[535] = dsaf_read_dev(ppe_cb, PPE_CFG_RX_PKT_MODE_REG);
+	regs[536] = dsaf_read_dev(ppe_cb, PPE_CFG_RX_VLAN_TAG_REG);
+	regs[537] = dsaf_read_dev(ppe_cb, PPE_CFG_TAG_GEN_REG);
+	regs[538] = dsaf_read_dev(ppe_cb, PPE_CFG_PARSE_TAG_REG);
+	regs[539] = dsaf_read_dev(ppe_cb, PPE_CFG_PRO_CHECK_EN_REG);
+
+	regs[540] = dsaf_read_dev(ppe_cb, PPE_INTEN_REG);
+	regs[541] = dsaf_read_dev(ppe_cb, PPE_RINT_REG);
+	regs[542] = dsaf_read_dev(ppe_cb, PPE_INTSTS_REG);
+	regs[543] = dsaf_read_dev(ppe_cb, PPE_CFG_RX_PKT_INT_REG);
+
+	regs[544] = dsaf_read_dev(ppe_cb, PPE_CFG_HEAT_DECT_TIME0_REG);
+	regs[545] = dsaf_read_dev(ppe_cb, PPE_CFG_HEAT_DECT_TIME1_REG);
+
+	/* ppe static */
+	regs[546] = dsaf_read_dev(ppe_cb, PPE_HIS_RX_SW_PKT_CNT_REG);
+	regs[547] = dsaf_read_dev(ppe_cb, PPE_HIS_RX_WR_BD_OK_PKT_CNT_REG);
+	regs[548] = dsaf_read_dev(ppe_cb, PPE_HIS_RX_PKT_NO_BUF_CNT_REG);
+	regs[549] = dsaf_read_dev(ppe_cb, PPE_HIS_TX_BD_CNT_REG);
+	regs[550] = dsaf_read_dev(ppe_cb, PPE_HIS_TX_PKT_CNT_REG);
+	regs[551] = dsaf_read_dev(ppe_cb, PPE_HIS_TX_PKT_OK_CNT_REG);
+	regs[552] = dsaf_read_dev(ppe_cb, PPE_HIS_TX_PKT_EPT_CNT_REG);
+	regs[553] = dsaf_read_dev(ppe_cb, PPE_HIS_TX_PKT_CS_FAIL_CNT_REG);
+	regs[554] = dsaf_read_dev(ppe_cb, PPE_HIS_RX_APP_BUF_FAIL_CNT_REG);
+	regs[555] = dsaf_read_dev(ppe_cb, PPE_HIS_RX_APP_BUF_WAIT_CNT_REG);
+	regs[556] = dsaf_read_dev(ppe_cb, PPE_HIS_RX_PKT_DROP_FUL_CNT_REG);
+	regs[557] = dsaf_read_dev(ppe_cb, PPE_HIS_RX_PKT_DROP_PRT_CNT_REG);
+
+	regs[558] = dsaf_read_dev(ppe_cb, PPE_TNL_0_5_CNT_CLR_CE_REG);
+	regs[559] = dsaf_read_dev(ppe_cb, PPE_CFG_AXI_DBG_REG);
+	regs[560] = dsaf_read_dev(ppe_cb, PPE_HIS_PRO_ERR_REG);
+	regs[561] = dsaf_read_dev(ppe_cb, PPE_HIS_TNL_FIFO_ERR_REG);
+	regs[562] = dsaf_read_dev(ppe_cb, PPE_CURR_CFF_DATA_NUM_REG);
+	regs[563] = dsaf_read_dev(ppe_cb, PPE_CURR_RX_ST_REG);
+	regs[564] = dsaf_read_dev(ppe_cb, PPE_CURR_TX_ST_REG);
+	regs[565] = dsaf_read_dev(ppe_cb, PPE_CURR_RX_FIFO0_REG);
+	regs[566] = dsaf_read_dev(ppe_cb, PPE_CURR_RX_FIFO1_REG);
+	regs[567] = dsaf_read_dev(ppe_cb, PPE_CURR_TX_FIFO0_REG);
+	regs[568] = dsaf_read_dev(ppe_cb, PPE_CURR_TX_FIFO1_REG);
+	regs[569] = dsaf_read_dev(ppe_cb, PPE_ECO0_REG);
+	regs[570] = dsaf_read_dev(ppe_cb, PPE_ECO1_REG);
+	regs[571] = dsaf_read_dev(ppe_cb, PPE_ECO2_REG);
+
+	/* mark end of ppe regs */
+	for (i = 572; i < 576; i++)
+		regs[i] = 0xeeeeeeee;
+}
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
new file mode 100644
index 0000000..4894f9a
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
@@ -0,0 +1,105 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_DSAF_PPE_H
+#define _HNS_DSAF_PPE_H
+
+#include <linux/platform_device.h>
+
+#include "hns_dsaf_main.h"
+#include "hns_dsaf_mac.h"
+#include "hns_dsaf_rcb.h"
+
+#define HNS_PPE_SERVICE_NW_ENGINE_NUM DSAF_COMM_CHN
+#define HNS_PPE_DEBUG_NW_ENGINE_NUM 1
+#define HNS_PPE_COM_NUM DSAF_COMM_DEV_NUM
+
+#define PPE_COMMON_REG_OFFSET 0x70000
+#define PPE_REG_OFFSET 0x10000
+
+#define ETH_PPE_DUMP_NUM 576
+#define ETH_PPE_STATIC_NUM 12
+enum ppe_qid_mode {
+	PPE_QID_MODE0 = 0,	/* fixed queue id mode */
+	PPE_QID_MODE1,		/* switch:128VM non switch:6Port/4VM/4TC */
+	PPE_QID_MODE2,		/* switch:32VM/4TC non switch:6Port/16VM */
+	PPE_QID_MODE3,		/* switch:4TC/8TAG non switch:2Port/64VM */
+	PPE_QID_MODE4,		/* switch:8VM/16TAG non switch:2Port/16VM/4TC */
+	PPE_QID_MODE5,		/* non switch:6Port/16TAG */
+	PPE_QID_MODE6,		/* non switch:6Port/2VM/8TC */
+	PPE_QID_MODE7,		/* non switch:2Port/8VM/8TC */
+};
+
+enum ppe_port_mode {
+	PPE_MODE_GE = 0,
+	PPE_MODE_XGE,
+};
+
+enum ppe_common_mode {
+	PPE_COMMON_MODE_DEBUG = 0,
+	PPE_COMMON_MODE_SERVICE,
+	PPE_COMMON_MODE_MAX
+};
+
+struct hns_ppe_hw_stats {
+	u64 rx_pkts_from_sw;
+	u64 rx_pkts;
+	u64 rx_drop_no_bd;
+	u64 rx_alloc_buf_fail;
+	u64 rx_alloc_buf_wait;
+	u64 rx_drop_no_buf;
+	u64 rx_err_fifo_full;
+	u64 tx_bd_form_rcb;
+	u64 tx_pkts_from_rcb;
+	u64 tx_pkts;
+	u64 tx_err_fifo_empty;
+	u64 tx_err_checksum;
+};
+
+struct hns_ppe_cb {
+	struct device *dev;
+	struct hns_ppe_cb *next;	/* pointer to next ppe device */
+	struct ppe_common_cb *ppe_common_cb; /* belong to */
+	struct hns_ppe_hw_stats hw_stats;
+
+	u8 index;	/* index in a ppe common device */
+	u8 port;			 /* port id in dsaf  */
+	void __iomem *io_base;
+	int virq;
+};
+
+struct ppe_common_cb {
+	struct device *dev;
+	struct dsaf_device *dsaf_dev;
+	void __iomem *io_base;
+
+	enum ppe_common_mode ppe_mode;
+
+	u8 comm_index;   /*ppe_common index*/
+
+	u32 ppe_num;
+	struct hns_ppe_cb ppe_cb[0];
+
+};
+
+int hns_ppe_init(struct dsaf_device *dsaf_dev);
+
+void hns_ppe_uninit(struct dsaf_device *dsaf_dev);
+
+void hns_ppe_reset_common(struct dsaf_device *dsaf_dev, u8 ppe_common_index);
+
+void hns_ppe_update_stats(struct hns_ppe_cb *ppe_cb);
+
+int hns_ppe_get_sset_count(int stringset);
+int hns_ppe_get_regs_count(void);
+void hns_ppe_get_regs(struct hns_ppe_cb *ppe_cb, void *data);
+
+void hns_ppe_get_strings(struct hns_ppe_cb *ppe_cb, int stringset, u8 *data);
+void hns_ppe_get_stats(struct hns_ppe_cb *ppe_cb, u64 *data);
+#endif /* _HNS_DSAF_PPE_H */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
new file mode 100644
index 0000000..50f3427
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -0,0 +1,1023 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/cdev.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <asm/cacheflush.h>
+#include <linux/platform_device.h>
+#include <linux/of.h>
+#include <linux/of_address.h>
+#include <linux/of_platform.h>
+#include <linux/of_irq.h>
+#include <linux/spinlock.h>
+
+#include "hns_dsaf_main.h"
+#include "hns_dsaf_ppe.h"
+#include "hns_dsaf_rcb.h"
+
+#define RCB_COMMON_REG_OFFSET 0x80000
+#define TX_RING 0
+#define RX_RING 1
+
+#define RCB_RESET_WAIT_TIMES 30
+#define RCB_RESET_TRY_TIMES 10
+
+/**
+ *hns_rcb_wait_fbd_clean - clean fbd
+ *@qs: ring struct pointer array
+ *@qnum: num of array
+ *@flag: tx or rx flag
+ */
+void hns_rcb_wait_fbd_clean(struct hnae_queue **qs, int q_num, u32 flag)
+{
+	int i, wait_cnt;
+	u32 fbd_num;
+
+	for (wait_cnt = i = 0; i < q_num; wait_cnt++) {
+		usleep_range(200, 300);
+		fbd_num = 0;
+		if (flag & RCB_INT_FLAG_TX)
+			fbd_num += dsaf_read_dev(qs[i],
+						 RCB_RING_TX_RING_FBDNUM_REG);
+		if (flag & RCB_INT_FLAG_RX)
+			fbd_num += dsaf_read_dev(qs[i],
+						 RCB_RING_RX_RING_FBDNUM_REG);
+		if (!fbd_num)
+			i++;
+		if (wait_cnt >= 10000)
+			break;
+	}
+
+	if (i < q_num)
+		dev_err(qs[i]->handle->owner_dev,
+			"queue(%d) wait fbd(%d) clean fail!!\n", i, fbd_num);
+}
+
+/**
+ *hns_rcb_reset_ring_hw - ring reset
+ *@q: ring struct pointer
+ */
+void hns_rcb_reset_ring_hw(struct hnae_queue *q)
+{
+	u32 wait_cnt;
+	u32 try_cnt = 0;
+	u32 could_ret;
+
+	u32 tx_fbd_num;
+
+	while (try_cnt++ < RCB_RESET_TRY_TIMES) {
+		usleep_range(100, 200);
+		tx_fbd_num = dsaf_read_dev(q, RCB_RING_TX_RING_FBDNUM_REG);
+		if (tx_fbd_num)
+			continue;
+
+		dsaf_write_dev(q, RCB_RING_PREFETCH_EN_REG, 0);
+
+		dsaf_write_dev(q, RCB_RING_T0_BE_RST, 1);
+
+		msleep(20);
+		could_ret = dsaf_read_dev(q, RCB_RING_COULD_BE_RST);
+
+		wait_cnt = 0;
+		while (!could_ret && (wait_cnt < RCB_RESET_WAIT_TIMES)) {
+			dsaf_write_dev(q, RCB_RING_T0_BE_RST, 0);
+
+			dsaf_write_dev(q, RCB_RING_T0_BE_RST, 1);
+
+			msleep(20);
+			could_ret = dsaf_read_dev(q, RCB_RING_COULD_BE_RST);
+
+			wait_cnt++;
+		}
+
+		dsaf_write_dev(q, RCB_RING_T0_BE_RST, 0);
+
+		if (could_ret)
+			break;
+	}
+
+	if (try_cnt >= RCB_RESET_TRY_TIMES)
+		dev_err(q->dev->dev, "port%d reset ring fail\n",
+			hns_ae_get_vf_cb(q->handle)->port_index);
+}
+
+/**
+ *hns_rcb_int_ctrl_hw - rcb irq enable control
+ *@q: hnae queue struct pointer
+ *@flag:ring flag tx or rx
+ *@mask:mask
+ */
+void hns_rcb_int_ctrl_hw(struct hnae_queue *q, u32 flag, u32 mask)
+{
+	u32 int_mask_en = !!mask;
+
+	if (flag & RCB_INT_FLAG_TX) {
+		dsaf_write_dev(q, RCB_RING_INTMSK_TXWL_REG, int_mask_en);
+		dsaf_write_dev(q, RCB_RING_INTMSK_TX_OVERTIME_REG,
+			       int_mask_en);
+	}
+
+	if (flag & RCB_INT_FLAG_RX) {
+		dsaf_write_dev(q, RCB_RING_INTMSK_RXWL_REG, int_mask_en);
+		dsaf_write_dev(q, RCB_RING_INTMSK_RX_OVERTIME_REG,
+			       int_mask_en);
+	}
+}
+
+void hns_rcb_int_clr_hw(struct hnae_queue *q, u32 flag)
+{
+	u32 clr = 1;
+
+	if (flag & RCB_INT_FLAG_TX) {
+		dsaf_write_dev(q, RCB_RING_INTSTS_TX_RING_REG, clr);
+		dsaf_write_dev(q, RCB_RING_INTSTS_TX_OVERTIME_REG, clr);
+	}
+
+	if (flag & RCB_INT_FLAG_RX) {
+		dsaf_write_dev(q, RCB_RING_INTSTS_RX_RING_REG, clr);
+		dsaf_write_dev(q, RCB_RING_INTSTS_RX_OVERTIME_REG, clr);
+	}
+}
+
+/**
+ *hns_rcb_ring_enable_hw - enable ring
+ *@ring: rcb ring
+ */
+void hns_rcb_ring_enable_hw(struct hnae_queue *q, u32 val)
+{
+	dsaf_write_dev(q, RCB_RING_PREFETCH_EN_REG, !!val);
+}
+
+void hns_rcb_start(struct hnae_queue *q, u32 val)
+{
+	hns_rcb_ring_enable_hw(q, val);
+}
+
+/**
+ *hns_rcb_common_init_commit_hw - make rcb common init completed
+ *@rcb_common: rcb common device
+ */
+void hns_rcb_common_init_commit_hw(struct rcb_common_cb *rcb_common)
+{
+	wmb();	/* Sync point before breakpoint */
+	dsaf_write_dev(rcb_common, RCB_COM_CFG_SYS_FSH_REG, 1);
+	wmb();	/* Sync point after breakpoint */
+}
+
+/**
+ *hns_rcb_ring_init - init rcb ring
+ *@ring_pair: ring pair control block
+ *@ring_type: ring type, RX_RING or TX_RING
+ */
+static void hns_rcb_ring_init(struct ring_pair_cb *ring_pair, int ring_type)
+{
+	struct hnae_queue *q = &ring_pair->q;
+	struct rcb_common_cb *rcb_common = ring_pair->rcb_common;
+	u32 bd_size_type = rcb_common->dsaf_dev->buf_size_type;
+	struct hnae_ring *ring =
+		(ring_type == RX_RING) ? &q->rx_ring : &q->tx_ring;
+	dma_addr_t dma = ring->desc_dma_addr;
+
+	if (ring_type == RX_RING) {
+		dsaf_write_dev(q, RCB_RING_RX_RING_BASEADDR_L_REG,
+			       (u32)dma);
+		dsaf_write_dev(q, RCB_RING_RX_RING_BASEADDR_H_REG,
+			       (u32)(dma >> 32));
+
+		dsaf_write_dev(q, RCB_RING_RX_RING_BD_LEN_REG,
+			       bd_size_type);
+		dsaf_write_dev(q, RCB_RING_RX_RING_BD_NUM_REG,
+			       ring_pair->port_id_in_dsa);
+		dsaf_write_dev(q, RCB_RING_RX_RING_PKTLINE_REG,
+			       ring_pair->port_id_in_dsa);
+	} else {
+		dsaf_write_dev(q, RCB_RING_TX_RING_BASEADDR_L_REG,
+			       (u32)dma);
+		dsaf_write_dev(q, RCB_RING_TX_RING_BASEADDR_H_REG,
+			       (u32)(dma >> 32));
+
+		dsaf_write_dev(q, RCB_RING_TX_RING_BD_LEN_REG,
+			       bd_size_type);
+		dsaf_write_dev(q, RCB_RING_TX_RING_BD_NUM_REG,
+			       ring_pair->port_id_in_dsa);
+		dsaf_write_dev(q, RCB_RING_TX_RING_PKTLINE_REG,
+			       ring_pair->port_id_in_dsa);
+	}
+}
+
+/**
+ *hns_rcb_init_hw - init rcb hardware
+ *@ring: rcb ring
+ */
+void hns_rcb_init_hw(struct ring_pair_cb *ring)
+{
+	hns_rcb_ring_init(ring, RX_RING);
+	hns_rcb_ring_init(ring, TX_RING);
+}
+
+/**
+ *hns_rcb_set_port_desc_cnt - set rcb port description num
+ *@rcb_common: rcb_common device
+ *@port_idx:port index
+ *@desc_cnt:BD num
+ */
+static void hns_rcb_set_port_desc_cnt(struct rcb_common_cb *rcb_common,
+				      u32 port_idx, u32 desc_cnt)
+{
+	if (port_idx >= HNS_RCB_SERVICE_NW_ENGINE_NUM)
+		port_idx = 0;
+
+	dsaf_write_dev(rcb_common, RCB_CFG_BD_NUM_REG + port_idx * 4,
+		       desc_cnt);
+}
+
+/**
+ *hns_rcb_set_port_coalesced_frames - set rcb port coalesced frames
+ *@rcb_common: rcb_common device
+ *@port_idx:port index
+ *@coalesced_frames:BD num for coalesced frames
+ */
+static int  hns_rcb_set_port_coalesced_frames(struct rcb_common_cb *rcb_common,
+					      u32 port_idx,
+					      u32 coalesced_frames)
+{
+	if (port_idx >= HNS_RCB_SERVICE_NW_ENGINE_NUM)
+		port_idx = 0;
+	if (coalesced_frames >= rcb_common->desc_num ||
+	    coalesced_frames > HNS_RCB_MAX_COALESCED_FRAMES)
+		return -EINVAL;
+
+	dsaf_write_dev(rcb_common, RCB_CFG_PKTLINE_REG + port_idx * 4,
+		       coalesced_frames);
+	return 0;
+}
+
+/**
+ *hns_rcb_get_port_coalesced_frames - set rcb port coalesced frames
+ *@rcb_common: rcb_common device
+ *@port_idx:port index
+ * return coaleseced frames value
+ */
+static u32 hns_rcb_get_port_coalesced_frames(struct rcb_common_cb *rcb_common,
+					     u32 port_idx)
+{
+	if (port_idx >= HNS_RCB_SERVICE_NW_ENGINE_NUM)
+		port_idx = 0;
+
+	return dsaf_read_dev(rcb_common,
+			     RCB_CFG_PKTLINE_REG + port_idx * 4);
+}
+
+/**
+ *hns_rcb_set_timeout - set rcb port coalesced time_out
+ *@rcb_common: rcb_common device
+ *@time_out:time for coalesced time_out
+ */
+static void hns_rcb_set_timeout(struct rcb_common_cb *rcb_common,
+				u32 timeout)
+{
+	dsaf_write_dev(rcb_common, RCB_CFG_OVERTIME_REG, timeout);
+}
+
+static int hns_rcb_common_get_port_num(struct rcb_common_cb *rcb_common)
+{
+	if (rcb_common->comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX)
+		return HNS_RCB_SERVICE_NW_ENGINE_NUM;
+	else
+		return HNS_RCB_DEBUG_NW_ENGINE_NUM;
+}
+
+/*clr rcb comm exception irq**/
+static void hns_rcb_comm_exc_irq_en(
+			struct rcb_common_cb *rcb_common, int en)
+{
+	u32 clr_vlue = 0xfffffffful;
+	u32 msk_vlue = en ? 0 : 0xfffffffful;
+
+	/* clr int*/
+	dsaf_write_dev(rcb_common, RCB_COM_INTSTS_ECC_ERR_REG, clr_vlue);
+
+	dsaf_write_dev(rcb_common, RCB_COM_SF_CFG_RING_STS, clr_vlue);
+
+	dsaf_write_dev(rcb_common, RCB_COM_SF_CFG_BD_RINT_STS, clr_vlue);
+
+	dsaf_write_dev(rcb_common, RCB_COM_RINT_TX_PKT_REG, clr_vlue);
+	dsaf_write_dev(rcb_common, RCB_COM_AXI_ERR_STS, clr_vlue);
+
+	/*en msk*/
+	dsaf_write_dev(rcb_common, RCB_COM_INTMASK_ECC_ERR_REG, msk_vlue);
+
+	dsaf_write_dev(rcb_common, RCB_COM_SF_CFG_INTMASK_RING, msk_vlue);
+
+	/*for tx bd neednot cacheline, so msk sf_txring_fbd_intmask (bit 1)**/
+	dsaf_write_dev(rcb_common, RCB_COM_SF_CFG_INTMASK_BD, msk_vlue | 2);
+
+	dsaf_write_dev(rcb_common, RCB_COM_INTMSK_TX_PKT_REG, msk_vlue);
+	dsaf_write_dev(rcb_common, RCB_COM_AXI_WR_ERR_INTMASK, msk_vlue);
+}
+
+/**
+ *hns_rcb_common_init_hw - init rcb common hardware
+ *@rcb_common: rcb_common device
+ *retuen 0 - success , negative --fail
+ */
+int hns_rcb_common_init_hw(struct rcb_common_cb *rcb_common)
+{
+	u32 reg_val;
+	int i;
+	int port_num = hns_rcb_common_get_port_num(rcb_common);
+
+	hns_rcb_comm_exc_irq_en(rcb_common, 0);
+
+	reg_val = dsaf_read_dev(rcb_common, RCB_COM_CFG_INIT_FLAG_REG);
+	if (0x1 != (reg_val & 0x1)) {
+		dev_err(rcb_common->dsaf_dev->dev,
+			"RCB_COM_CFG_INIT_FLAG_REG reg = 0x%x\n", reg_val);
+		return -EBUSY;
+	}
+
+	for (i = 0; i < port_num; i++) {
+		hns_rcb_set_port_desc_cnt(rcb_common, i, rcb_common->desc_num);
+		(void)hns_rcb_set_port_coalesced_frames(
+			rcb_common, i, rcb_common->coalesced_frames);
+	}
+	hns_rcb_set_timeout(rcb_common, rcb_common->timeout);
+
+	dsaf_write_dev(rcb_common, RCB_COM_CFG_ENDIAN_REG,
+		       HNS_RCB_COMMON_ENDIAN);
+
+	return 0;
+}
+
+int hns_rcb_buf_size2type(u32 buf_size)
+{
+	int bd_size_type;
+
+	switch (buf_size) {
+	case 512:
+		bd_size_type = HNS_BD_SIZE_512_TYPE;
+		break;
+	case 1024:
+		bd_size_type = HNS_BD_SIZE_1024_TYPE;
+		break;
+	case 2048:
+		bd_size_type = HNS_BD_SIZE_2048_TYPE;
+		break;
+	case 4096:
+		bd_size_type = HNS_BD_SIZE_4096_TYPE;
+		break;
+	default:
+		bd_size_type = -EINVAL;
+	}
+
+	return bd_size_type;
+}
+
+static void hns_rcb_ring_get_cfg(struct hnae_queue *q, int ring_type)
+{
+	struct hnae_ring *ring;
+	struct rcb_common_cb *rcb_common;
+	struct ring_pair_cb *ring_pair_cb;
+	u32 buf_size;
+	u16 desc_num;
+	int irq_idx;
+
+	ring_pair_cb = container_of(q, struct ring_pair_cb, q);
+	if (ring_type == RX_RING) {
+		ring = &q->rx_ring;
+		ring->io_base = ring_pair_cb->q.io_base;
+		irq_idx = HNS_RCB_IRQ_IDX_RX;
+	} else {
+		ring = &q->tx_ring;
+		ring->io_base = (u8 __iomem *)ring_pair_cb->q.io_base +
+			HNS_RCB_TX_REG_OFFSET;
+		irq_idx = HNS_RCB_IRQ_IDX_TX;
+	}
+
+	rcb_common = ring_pair_cb->rcb_common;
+	buf_size = rcb_common->dsaf_dev->buf_size;
+	desc_num = rcb_common->dsaf_dev->desc_num;
+
+	ring->desc = NULL;
+	ring->desc_cb = NULL;
+
+	ring->irq = ring_pair_cb->virq[irq_idx];
+	ring->desc_dma_addr = 0;
+
+	ring->buf_size = buf_size;
+	ring->desc_num = desc_num;
+	ring->max_desc_num_per_pkt = HNS_RCB_RING_MAX_BD_PER_PKT;
+	ring->max_raw_data_sz_per_desc = HNS_RCB_MAX_PKT_SIZE;
+	ring->max_pkt_size = HNS_RCB_MAX_PKT_SIZE;
+	ring->next_to_use = 0;
+	ring->next_to_clean = 0;
+}
+
+static void hns_rcb_ring_pair_get_cfg(struct ring_pair_cb *ring_pair_cb)
+{
+	ring_pair_cb->q.handle = NULL;
+
+	hns_rcb_ring_get_cfg(&ring_pair_cb->q, RX_RING);
+	hns_rcb_ring_get_cfg(&ring_pair_cb->q, TX_RING);
+}
+
+static int hns_rcb_get_port(struct rcb_common_cb *rcb_common, int ring_idx)
+{
+	int comm_index = rcb_common->comm_index;
+	int port;
+	int q_num;
+
+	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
+		q_num = (int)rcb_common->max_q_per_vf * rcb_common->max_vfn;
+		port = ring_idx / q_num;
+	} else {
+		port = HNS_RCB_SERVICE_NW_ENGINE_NUM + comm_index - 1;
+	}
+
+	return port;
+}
+
+static int hns_rcb_get_base_irq_idx(struct rcb_common_cb *rcb_common)
+{
+	int comm_index = rcb_common->comm_index;
+
+	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX)
+		return HNS_SERVICE_RING_IRQ_IDX;
+	else
+		return HNS_DEBUG_RING_IRQ_IDX + (comm_index - 1) * 2;
+}
+
+#define RCB_COMM_BASE_TO_RING_BASE(base, ringid)\
+	((base) + 0x10000 + HNS_RCB_REG_OFFSET * (ringid))
+/**
+ *hns_rcb_get_cfg - get rcb config
+ *@rcb_common: rcb common device
+ */
+void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
+{
+	struct ring_pair_cb *ring_pair_cb;
+	u32 i;
+	u32 ring_num = rcb_common->ring_num;
+	int base_irq_idx = hns_rcb_get_base_irq_idx(rcb_common);
+	struct device_node *np = rcb_common->dsaf_dev->dev->of_node;
+
+	for (i = 0; i < ring_num; i++) {
+		ring_pair_cb = &rcb_common->ring_pair_cb[i];
+		ring_pair_cb->rcb_common = rcb_common;
+		ring_pair_cb->dev = rcb_common->dsaf_dev->dev;
+		ring_pair_cb->index = i;
+		ring_pair_cb->q.io_base =
+			RCB_COMM_BASE_TO_RING_BASE(rcb_common->io_base, i);
+		ring_pair_cb->port_id_in_dsa = hns_rcb_get_port(rcb_common, i);
+		ring_pair_cb->virq[HNS_RCB_IRQ_IDX_TX]
+			= irq_of_parse_and_map(np, base_irq_idx + i * 2);
+		ring_pair_cb->virq[HNS_RCB_IRQ_IDX_RX]
+			= irq_of_parse_and_map(np, base_irq_idx + i * 2 + 1);
+		ring_pair_cb->q.phy_base =
+			RCB_COMM_BASE_TO_RING_BASE(rcb_common->phy_base, i);
+		hns_rcb_ring_pair_get_cfg(ring_pair_cb);
+	}
+}
+
+/**
+ *hns_rcb_get_coalesced_frames - get rcb port coalesced frames
+ *@rcb_common: rcb_common device
+ *@comm_index:port index
+ *return coalesced_frames
+ */
+u32 hns_rcb_get_coalesced_frames(struct dsaf_device *dsaf_dev, int port)
+{
+	int comm_index =  hns_dsaf_get_comm_idx_by_port(port);
+	struct rcb_common_cb *rcb_comm = dsaf_dev->rcb_common[comm_index];
+
+	return hns_rcb_get_port_coalesced_frames(rcb_comm, port);
+}
+
+/**
+ *hns_rcb_get_coalesce_usecs - get rcb port coalesced time_out
+ *@rcb_common: rcb_common device
+ *@comm_index:port index
+ *return time_out
+ */
+u32 hns_rcb_get_coalesce_usecs(struct dsaf_device *dsaf_dev, int comm_index)
+{
+	struct rcb_common_cb *rcb_comm = dsaf_dev->rcb_common[comm_index];
+
+	return rcb_comm->timeout;
+}
+
+/**
+ *hns_rcb_set_coalesce_usecs - set rcb port coalesced time_out
+ *@rcb_common: rcb_common device
+ *@comm_index: comm :index
+ *@etx_usecs:tx time for coalesced time_out
+ *@rx_usecs:rx time for coalesced time_out
+ */
+void hns_rcb_set_coalesce_usecs(struct dsaf_device *dsaf_dev,
+				int port, u32 timeout)
+{
+	int comm_index =  hns_dsaf_get_comm_idx_by_port(port);
+	struct rcb_common_cb *rcb_comm = dsaf_dev->rcb_common[comm_index];
+
+	if (rcb_comm->timeout == timeout)
+		return;
+
+	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
+		dev_err(dsaf_dev->dev,
+			"error: not support coalesce_usecs setting!\n");
+		return;
+	}
+	rcb_comm->timeout = timeout;
+	hns_rcb_set_timeout(rcb_comm, rcb_comm->timeout);
+}
+
+/**
+ *hns_rcb_set_coalesced_frames - set rcb coalesced frames
+ *@rcb_common: rcb_common device
+ *@tx_frames:tx BD num for coalesced frames
+ *@rx_frames:rx BD num for coalesced frames
+ *Return 0 on success, negative on failure
+ */
+int hns_rcb_set_coalesced_frames(struct dsaf_device *dsaf_dev,
+				 int port, u32 coalesced_frames)
+{
+	int comm_index =  hns_dsaf_get_comm_idx_by_port(port);
+	struct rcb_common_cb *rcb_comm = dsaf_dev->rcb_common[comm_index];
+	u32 coalesced_reg_val;
+	int ret;
+
+	coalesced_reg_val = hns_rcb_get_port_coalesced_frames(rcb_comm, port);
+
+	if (coalesced_reg_val == coalesced_frames)
+		return 0;
+
+	if (coalesced_frames >= HNS_RCB_MIN_COALESCED_FRAMES) {
+		ret = hns_rcb_set_port_coalesced_frames(rcb_comm, port,
+							coalesced_frames);
+		return ret;
+	} else {
+		return -EINVAL;
+	}
+}
+
+/**
+ *hns_rcb_get_queue_mode - get max VM number and max ring number per VM
+ *						accordding to dsaf mode
+ *@dsaf_mode: dsaf mode
+ *@max_vfn : max vfn number
+ *@max_q_per_vf:max ring number per vm
+ */
+static void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode, int comm_index,
+				   u16 *max_vfn, u16 *max_q_per_vf)
+{
+	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
+		switch (dsaf_mode) {
+		case DSAF_MODE_DISABLE_6PORT_0VM:
+			*max_vfn = 1;
+			*max_q_per_vf = 16;
+			break;
+		case DSAF_MODE_DISABLE_FIX:
+			*max_vfn = 1;
+			*max_q_per_vf = 1;
+			break;
+		case DSAF_MODE_DISABLE_2PORT_64VM:
+			*max_vfn = 64;
+			*max_q_per_vf = 1;
+			break;
+		case DSAF_MODE_DISABLE_6PORT_16VM:
+			*max_vfn = 16;
+			*max_q_per_vf = 1;
+			break;
+		default:
+			*max_vfn = 1;
+			*max_q_per_vf = 16;
+			break;
+		}
+	} else {
+		*max_vfn = 1;
+		*max_q_per_vf = 1;
+	}
+}
+
+int hns_rcb_get_ring_num(struct dsaf_device *dsaf_dev, int comm_index)
+{
+	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
+		switch (dsaf_dev->dsaf_mode) {
+		case DSAF_MODE_ENABLE_FIX:
+			return 1;
+
+		case DSAF_MODE_DISABLE_FIX:
+			return 6;
+
+		case DSAF_MODE_ENABLE_0VM:
+			return 32;
+
+		case DSAF_MODE_DISABLE_6PORT_0VM:
+		case DSAF_MODE_ENABLE_16VM:
+		case DSAF_MODE_DISABLE_6PORT_2VM:
+		case DSAF_MODE_DISABLE_6PORT_16VM:
+		case DSAF_MODE_DISABLE_6PORT_4VM:
+		case DSAF_MODE_ENABLE_8VM:
+			return 96;
+
+		case DSAF_MODE_DISABLE_2PORT_16VM:
+		case DSAF_MODE_DISABLE_2PORT_8VM:
+		case DSAF_MODE_ENABLE_32VM:
+		case DSAF_MODE_DISABLE_2PORT_64VM:
+		case DSAF_MODE_ENABLE_128VM:
+			return 128;
+
+		default:
+			dev_warn(dsaf_dev->dev,
+				 "get ring num fail,use default!dsaf_mode=%d\n",
+				 dsaf_dev->dsaf_mode);
+			return 128;
+		}
+	} else {
+		return 1;
+	}
+}
+
+void __iomem *hns_rcb_common_get_vaddr(struct dsaf_device *dsaf_dev,
+				       int comm_index)
+{
+	void __iomem *base_addr;
+
+	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX)
+		base_addr = dsaf_dev->ppe_base + RCB_COMMON_REG_OFFSET;
+	else
+		base_addr = dsaf_dev->sds_base
+			+ (comm_index - 1) * HNS_DSAF_DEBUG_NW_REG_OFFSET
+			+ RCB_COMMON_REG_OFFSET;
+
+	return base_addr;
+}
+
+static phys_addr_t hns_rcb_common_get_paddr(struct dsaf_device *dsaf_dev,
+					    int comm_index)
+{
+	struct device_node *np = dsaf_dev->dev->of_node;
+	phys_addr_t phy_addr;
+	const __be32 *tmp_addr;
+	u64 addr_offset = 0;
+	u64 size = 0;
+	int index = 0;
+
+	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
+		index    = 2;
+		addr_offset = RCB_COMMON_REG_OFFSET;
+	} else {
+		index    = 1;
+		addr_offset = (comm_index - 1) * HNS_DSAF_DEBUG_NW_REG_OFFSET +
+				RCB_COMMON_REG_OFFSET;
+	}
+	tmp_addr  = of_get_address(np, index, &size, NULL);
+	phy_addr  = of_translate_address(np, tmp_addr);
+	return phy_addr + addr_offset;
+}
+
+int hns_rcb_common_get_cfg(struct dsaf_device *dsaf_dev,
+			   int comm_index)
+{
+	struct rcb_common_cb *rcb_common;
+	enum dsaf_mode dsaf_mode = dsaf_dev->dsaf_mode;
+	u16 max_vfn;
+	u16 max_q_per_vf;
+	int ring_num = hns_rcb_get_ring_num(dsaf_dev, comm_index);
+
+	rcb_common =
+		devm_kzalloc(dsaf_dev->dev, sizeof(*rcb_common) +
+			ring_num * sizeof(struct ring_pair_cb), GFP_KERNEL);
+	if (!rcb_common) {
+		dev_err(dsaf_dev->dev, "rcb common devm_kzalloc fail!\n");
+		return -ENOMEM;
+	}
+	rcb_common->comm_index = comm_index;
+	rcb_common->ring_num = ring_num;
+	rcb_common->dsaf_dev = dsaf_dev;
+
+	rcb_common->desc_num = dsaf_dev->desc_num;
+	rcb_common->coalesced_frames = HNS_RCB_DEF_COALESCED_FRAMES;
+	rcb_common->timeout = HNS_RCB_MAX_TIME_OUT;
+
+	hns_rcb_get_queue_mode(dsaf_mode, comm_index, &max_vfn, &max_q_per_vf);
+	rcb_common->max_vfn = max_vfn;
+	rcb_common->max_q_per_vf = max_q_per_vf;
+
+	rcb_common->io_base = hns_rcb_common_get_vaddr(dsaf_dev, comm_index);
+	rcb_common->phy_base = hns_rcb_common_get_paddr(dsaf_dev, comm_index);
+
+	dsaf_dev->rcb_common[comm_index] = rcb_common;
+	return 0;
+}
+
+void hns_rcb_common_free_cfg(struct dsaf_device *dsaf_dev,
+			     u32 comm_index)
+{
+	dsaf_dev->rcb_common[comm_index] = NULL;
+}
+
+void hns_rcb_update_stats(struct hnae_queue *queue)
+{
+	struct ring_pair_cb *ring =
+		container_of(queue, struct ring_pair_cb, q);
+	struct dsaf_device *dsaf_dev = ring->rcb_common->dsaf_dev;
+	struct ppe_common_cb *ppe_common
+		= dsaf_dev->ppe_common[ring->rcb_common->comm_index];
+	struct hns_ring_hw_stats *hw_stats = &ring->hw_stats;
+
+	hw_stats->rx_pkts += dsaf_read_dev(queue,
+			 RCB_RING_RX_RING_PKTNUM_RECORD_REG);
+	dsaf_write_dev(queue, RCB_RING_RX_RING_PKTNUM_RECORD_REG, 0x1);
+
+	hw_stats->ppe_rx_ok_pkts += dsaf_read_dev(ppe_common,
+			 PPE_COM_HIS_RX_PKT_QID_OK_CNT_REG + 4 * ring->index);
+	hw_stats->ppe_rx_drop_pkts += dsaf_read_dev(ppe_common,
+			 PPE_COM_HIS_RX_PKT_QID_DROP_CNT_REG + 4 * ring->index);
+
+	hw_stats->tx_pkts += dsaf_read_dev(queue,
+			 RCB_RING_TX_RING_PKTNUM_RECORD_REG);
+	dsaf_write_dev(queue, RCB_RING_TX_RING_PKTNUM_RECORD_REG, 0x1);
+
+	hw_stats->ppe_tx_ok_pkts += dsaf_read_dev(ppe_common,
+			 PPE_COM_HIS_TX_PKT_QID_OK_CNT_REG + 4 * ring->index);
+	hw_stats->ppe_tx_drop_pkts += dsaf_read_dev(ppe_common,
+			 PPE_COM_HIS_TX_PKT_QID_ERR_CNT_REG + 4 * ring->index);
+}
+
+/**
+ *hns_rcb_get_stats - get rcb statistic
+ *@ring: rcb ring
+ *@data:statistic value
+ */
+void hns_rcb_get_stats(struct hnae_queue *queue, u64 *data)
+{
+	u64 *regs_buff = data;
+	struct ring_pair_cb *ring =
+		container_of(queue, struct ring_pair_cb, q);
+	struct hns_ring_hw_stats *hw_stats = &ring->hw_stats;
+
+	regs_buff[0] = hw_stats->tx_pkts;
+	regs_buff[1] = hw_stats->ppe_tx_ok_pkts;
+	regs_buff[2] = hw_stats->ppe_tx_drop_pkts;
+	regs_buff[3] =
+		dsaf_read_dev(queue, RCB_RING_TX_RING_FBDNUM_REG);
+
+	regs_buff[4] = queue->tx_ring.stats.tx_pkts;
+	regs_buff[5] = queue->tx_ring.stats.tx_bytes;
+	regs_buff[6] = queue->tx_ring.stats.tx_err_cnt;
+	regs_buff[7] = queue->tx_ring.stats.io_err_cnt;
+	regs_buff[8] = queue->tx_ring.stats.sw_err_cnt;
+	regs_buff[9] = queue->tx_ring.stats.seg_pkt_cnt;
+	regs_buff[10] = queue->tx_ring.stats.restart_queue;
+	regs_buff[11] = queue->tx_ring.stats.tx_busy;
+
+	regs_buff[12] = hw_stats->rx_pkts;
+	regs_buff[13] = hw_stats->ppe_rx_ok_pkts;
+	regs_buff[14] = hw_stats->ppe_rx_drop_pkts;
+	regs_buff[15] =
+		dsaf_read_dev(queue, RCB_RING_RX_RING_FBDNUM_REG);
+
+	regs_buff[16] = queue->rx_ring.stats.rx_pkts;
+	regs_buff[17] = queue->rx_ring.stats.rx_bytes;
+	regs_buff[18] = queue->rx_ring.stats.rx_err_cnt;
+	regs_buff[19] = queue->rx_ring.stats.io_err_cnt;
+	regs_buff[20] = queue->rx_ring.stats.sw_err_cnt;
+	regs_buff[21] = queue->rx_ring.stats.seg_pkt_cnt;
+	regs_buff[22] = queue->rx_ring.stats.reuse_pg_cnt;
+	regs_buff[23] = queue->rx_ring.stats.err_pkt_len;
+	regs_buff[24] = queue->rx_ring.stats.non_vld_descs;
+	regs_buff[25] = queue->rx_ring.stats.err_bd_num;
+	regs_buff[26] = queue->rx_ring.stats.l2_err;
+	regs_buff[27] = queue->rx_ring.stats.l3l4_csum_err;
+}
+
+/**
+ *hns_rcb_get_ring_sset_count - rcb string set count
+ *@stringset:ethtool cmd
+ *return rcb ring string set count
+ */
+int hns_rcb_get_ring_sset_count(int stringset)
+{
+	if (stringset == ETH_SS_STATS)
+		return HNS_RING_STATIC_REG_NUM;
+
+	return 0;
+}
+
+/**
+ *hns_rcb_get_common_regs_count - rcb common regs count
+ *return regs count
+ */
+int hns_rcb_get_common_regs_count(void)
+{
+	return HNS_RCB_COMMON_DUMP_REG_NUM;
+}
+
+/**
+ *rcb_get_sset_count - rcb ring regs count
+ *return regs count
+ */
+int hns_rcb_get_ring_regs_count(void)
+{
+	return HNS_RCB_RING_DUMP_REG_NUM;
+}
+
+/**
+ *hns_rcb_get_strings - get rcb string set
+ *@stringset:string set index
+ *@data:strings name value
+ *@index:queue index
+ */
+void hns_rcb_get_strings(int stringset, u8 *data, int index)
+{
+	char *buff = (char *)data;
+
+	if (stringset != ETH_SS_STATS)
+		return;
+
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_rcb_pkt_num", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_ppe_tx_pkt_num", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_ppe_drop_pkt_num", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_fbd_num", index);
+	buff = buff + ETH_GSTRING_LEN;
+
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_pkt_num", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_bytes", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_err_cnt", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_io_err", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_sw_err", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_seg_pkt", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_restart_queue", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "tx_ring%d_tx_busy", index);
+	buff = buff + ETH_GSTRING_LEN;
+
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_rcb_pkt_num", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_ppe_pkt_num", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_ppe_drop_pkt_num", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_fbd_num", index);
+	buff = buff + ETH_GSTRING_LEN;
+
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_pkt_num", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_bytes", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_err_cnt", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_io_err", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_sw_err", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_seg_pkt", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_reuse_pg", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_len_err", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_non_vld_desc_err", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_bd_num_err", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_l2_err", index);
+	buff = buff + ETH_GSTRING_LEN;
+	snprintf(buff, ETH_GSTRING_LEN, "rx_ring%d_l3l4csum_err", index);
+}
+
+void hns_rcb_get_common_regs(struct rcb_common_cb *rcb_com, void *data)
+{
+	u32 *regs = data;
+	u32 i = 0;
+
+	/*rcb common registers */
+	regs[0] = dsaf_read_dev(rcb_com, RCB_COM_CFG_ENDIAN_REG);
+	regs[1] = dsaf_read_dev(rcb_com, RCB_COM_CFG_SYS_FSH_REG);
+	regs[2] = dsaf_read_dev(rcb_com, RCB_COM_CFG_INIT_FLAG_REG);
+
+	regs[3] = dsaf_read_dev(rcb_com, RCB_COM_CFG_PKT_REG);
+	regs[4] = dsaf_read_dev(rcb_com, RCB_COM_CFG_RINVLD_REG);
+	regs[5] = dsaf_read_dev(rcb_com, RCB_COM_CFG_FNA_REG);
+	regs[6] = dsaf_read_dev(rcb_com, RCB_COM_CFG_FA_REG);
+	regs[7] = dsaf_read_dev(rcb_com, RCB_COM_CFG_PKT_TC_BP_REG);
+	regs[8] = dsaf_read_dev(rcb_com, RCB_COM_CFG_PPE_TNL_CLKEN_REG);
+
+	regs[9] = dsaf_read_dev(rcb_com, RCB_COM_INTMSK_TX_PKT_REG);
+	regs[10] = dsaf_read_dev(rcb_com, RCB_COM_RINT_TX_PKT_REG);
+	regs[11] = dsaf_read_dev(rcb_com, RCB_COM_INTMASK_ECC_ERR_REG);
+	regs[12] = dsaf_read_dev(rcb_com, RCB_COM_INTSTS_ECC_ERR_REG);
+	regs[13] = dsaf_read_dev(rcb_com, RCB_COM_EBD_SRAM_ERR_REG);
+	regs[14] = dsaf_read_dev(rcb_com, RCB_COM_RXRING_ERR_REG);
+	regs[15] = dsaf_read_dev(rcb_com, RCB_COM_TXRING_ERR_REG);
+	regs[16] = dsaf_read_dev(rcb_com, RCB_COM_TX_FBD_ERR_REG);
+	regs[17] = dsaf_read_dev(rcb_com, RCB_SRAM_ECC_CHK_EN_REG);
+	regs[18] = dsaf_read_dev(rcb_com, RCB_SRAM_ECC_CHK0_REG);
+	regs[19] = dsaf_read_dev(rcb_com, RCB_SRAM_ECC_CHK1_REG);
+	regs[20] = dsaf_read_dev(rcb_com, RCB_SRAM_ECC_CHK2_REG);
+	regs[21] = dsaf_read_dev(rcb_com, RCB_SRAM_ECC_CHK3_REG);
+	regs[22] = dsaf_read_dev(rcb_com, RCB_SRAM_ECC_CHK4_REG);
+	regs[23] = dsaf_read_dev(rcb_com, RCB_SRAM_ECC_CHK5_REG);
+	regs[24] = dsaf_read_dev(rcb_com, RCB_ECC_ERR_ADDR0_REG);
+	regs[25] = dsaf_read_dev(rcb_com, RCB_ECC_ERR_ADDR3_REG);
+	regs[26] = dsaf_read_dev(rcb_com, RCB_ECC_ERR_ADDR4_REG);
+	regs[27] = dsaf_read_dev(rcb_com, RCB_ECC_ERR_ADDR5_REG);
+
+	regs[28] = dsaf_read_dev(rcb_com, RCB_COM_SF_CFG_INTMASK_RING);
+	regs[29] = dsaf_read_dev(rcb_com, RCB_COM_SF_CFG_RING_STS);
+	regs[30] = dsaf_read_dev(rcb_com, RCB_COM_SF_CFG_RING);
+	regs[31] = dsaf_read_dev(rcb_com, RCB_COM_SF_CFG_INTMASK_BD);
+	regs[32] = dsaf_read_dev(rcb_com, RCB_COM_SF_CFG_BD_RINT_STS);
+	regs[33] = dsaf_read_dev(rcb_com, RCB_COM_RCB_RD_BD_BUSY);
+	regs[34] = dsaf_read_dev(rcb_com, RCB_COM_RCB_FBD_CRT_EN);
+	regs[35] = dsaf_read_dev(rcb_com, RCB_COM_AXI_WR_ERR_INTMASK);
+	regs[36] = dsaf_read_dev(rcb_com, RCB_COM_AXI_ERR_STS);
+	regs[37] = dsaf_read_dev(rcb_com, RCB_COM_CHK_TX_FBD_NUM_REG);
+
+	/* rcb common entry registers */
+	for (i = 0; i < 16; i++) { /* total 16 model registers */
+		regs[38 + i]
+			= dsaf_read_dev(rcb_com, RCB_CFG_BD_NUM_REG + 4 * i);
+		regs[54 + i]
+			= dsaf_read_dev(rcb_com, RCB_CFG_PKTLINE_REG + 4 * i);
+	}
+
+	regs[70] = dsaf_read_dev(rcb_com, RCB_CFG_OVERTIME_REG);
+	regs[71] = dsaf_read_dev(rcb_com, RCB_CFG_PKTLINE_INT_NUM_REG);
+	regs[72] = dsaf_read_dev(rcb_com, RCB_CFG_OVERTIME_INT_NUM_REG);
+
+	/* mark end of rcb common regs */
+	for (i = 73; i < 80; i++)
+		regs[i] = 0xcccccccc;
+}
+
+void hns_rcb_get_ring_regs(struct hnae_queue *queue, void *data)
+{
+	u32 *regs = data;
+	struct ring_pair_cb *ring_pair
+		= container_of(queue, struct ring_pair_cb, q);
+	u32 i = 0;
+
+	/*rcb ring registers */
+	regs[0] = dsaf_read_dev(queue, RCB_RING_RX_RING_BASEADDR_L_REG);
+	regs[1] = dsaf_read_dev(queue, RCB_RING_RX_RING_BASEADDR_H_REG);
+	regs[2] = dsaf_read_dev(queue, RCB_RING_RX_RING_BD_NUM_REG);
+	regs[3] = dsaf_read_dev(queue, RCB_RING_RX_RING_BD_LEN_REG);
+	regs[4] = dsaf_read_dev(queue, RCB_RING_RX_RING_PKTLINE_REG);
+	regs[5] = dsaf_read_dev(queue, RCB_RING_RX_RING_TAIL_REG);
+	regs[6] = dsaf_read_dev(queue, RCB_RING_RX_RING_HEAD_REG);
+	regs[7] = dsaf_read_dev(queue, RCB_RING_RX_RING_FBDNUM_REG);
+	regs[8] = dsaf_read_dev(queue, RCB_RING_RX_RING_PKTNUM_RECORD_REG);
+
+	regs[9] = dsaf_read_dev(queue, RCB_RING_TX_RING_BASEADDR_L_REG);
+	regs[10] = dsaf_read_dev(queue, RCB_RING_TX_RING_BASEADDR_H_REG);
+	regs[11] = dsaf_read_dev(queue, RCB_RING_TX_RING_BD_NUM_REG);
+	regs[12] = dsaf_read_dev(queue, RCB_RING_TX_RING_BD_LEN_REG);
+	regs[13] = dsaf_read_dev(queue, RCB_RING_TX_RING_PKTLINE_REG);
+	regs[15] = dsaf_read_dev(queue, RCB_RING_TX_RING_TAIL_REG);
+	regs[16] = dsaf_read_dev(queue, RCB_RING_TX_RING_HEAD_REG);
+	regs[17] = dsaf_read_dev(queue, RCB_RING_TX_RING_FBDNUM_REG);
+	regs[18] = dsaf_read_dev(queue, RCB_RING_TX_RING_OFFSET_REG);
+	regs[19] = dsaf_read_dev(queue, RCB_RING_TX_RING_PKTNUM_RECORD_REG);
+
+	regs[20] = dsaf_read_dev(queue, RCB_RING_PREFETCH_EN_REG);
+	regs[21] = dsaf_read_dev(queue, RCB_RING_CFG_VF_NUM_REG);
+	regs[22] = dsaf_read_dev(queue, RCB_RING_ASID_REG);
+	regs[23] = dsaf_read_dev(queue, RCB_RING_RX_VM_REG);
+	regs[24] = dsaf_read_dev(queue, RCB_RING_T0_BE_RST);
+	regs[25] = dsaf_read_dev(queue, RCB_RING_COULD_BE_RST);
+	regs[26] = dsaf_read_dev(queue, RCB_RING_WRR_WEIGHT_REG);
+
+	regs[27] = dsaf_read_dev(queue, RCB_RING_INTMSK_RXWL_REG);
+	regs[28] = dsaf_read_dev(queue, RCB_RING_INTSTS_RX_RING_REG);
+	regs[29] = dsaf_read_dev(queue, RCB_RING_INTMSK_TXWL_REG);
+	regs[30] = dsaf_read_dev(queue, RCB_RING_INTSTS_TX_RING_REG);
+	regs[31] = dsaf_read_dev(queue, RCB_RING_INTMSK_RX_OVERTIME_REG);
+	regs[32] = dsaf_read_dev(queue, RCB_RING_INTSTS_RX_OVERTIME_REG);
+	regs[33] = dsaf_read_dev(queue, RCB_RING_INTMSK_TX_OVERTIME_REG);
+	regs[34] = dsaf_read_dev(queue, RCB_RING_INTSTS_TX_OVERTIME_REG);
+
+	/* mark end of ring regs */
+	for (i = 35; i < 40; i++)
+		regs[i] = 0xcccccc00 + ring_pair->index;
+}
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
new file mode 100644
index 0000000..c7db613
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
@@ -0,0 +1,137 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_DSAF_RCB_H
+#define _HNS_DSAF_RCB_H
+
+#include <linux/netdevice.h>
+#include <linux/platform_device.h>
+
+#include "hnae.h"
+#include "hns_dsaf_main.h"
+
+struct rcb_common_cb;
+
+#define HNS_RCB_IRQ_NUM_PER_QUEUE		2
+#define HNS_RCB_IRQ_IDX_TX			0
+#define HNS_RCB_IRQ_IDX_RX			1
+#define HNS_RCB_TX_REG_OFFSET			0x40
+
+#define HNS_RCB_SERVICE_NW_ENGINE_NUM		DSAF_COMM_CHN
+#define HNS_RCB_DEBUG_NW_ENGINE_NUM		1
+#define HNS_RCB_RING_MAX_BD_PER_PKT		3
+#define HNS_RCB_MAX_PKT_SIZE MAC_MAX_MTU
+
+#define HNS_RCB_RING_MAX_PENDING_BD		1024
+#define HNS_RCB_RING_MIN_PENDING_BD		16
+
+#define HNS_RCB_REG_OFFSET			0x10000
+
+#define HNS_RCB_MAX_COALESCED_FRAMES		1023
+#define HNS_RCB_MIN_COALESCED_FRAMES		1
+#define HNS_RCB_DEF_COALESCED_FRAMES		50
+#define HNS_RCB_MAX_TIME_OUT			0x500
+
+#define HNS_RCB_COMMON_ENDIAN			1
+
+#define HNS_BD_SIZE_512_TYPE			0
+#define HNS_BD_SIZE_1024_TYPE			1
+#define HNS_BD_SIZE_2048_TYPE			2
+#define HNS_BD_SIZE_4096_TYPE			3
+
+#define HNS_RCB_COMMON_DUMP_REG_NUM 80
+#define HNS_RCB_RING_DUMP_REG_NUM 40
+#define HNS_RING_STATIC_REG_NUM 28
+
+#define HNS_DUMP_REG_NUM			500
+#define HNS_STATIC_REG_NUM			12
+
+enum rcb_int_flag {
+	RCB_INT_FLAG_TX = 0x1,
+	RCB_INT_FLAG_RX = (0x1 << 1),
+	RCB_INT_FLAG_MAX = (0x1 << 2),	/*must be the last element */
+};
+
+struct hns_ring_hw_stats {
+	u64 tx_pkts;
+	u64 ppe_tx_ok_pkts;
+	u64 ppe_tx_drop_pkts;
+	u64 rx_pkts;
+	u64 ppe_rx_ok_pkts;
+	u64 ppe_rx_drop_pkts;
+};
+
+struct ring_pair_cb {
+	struct rcb_common_cb *rcb_common;	/*  ring belongs to */
+	struct device *dev;	/*device for DMA mapping */
+	struct hnae_queue q;
+
+	u16 index;	/* global index in a rcb common device */
+	u16 buf_size;
+
+	int virq[HNS_RCB_IRQ_NUM_PER_QUEUE];
+
+	u8 port_id_in_dsa;
+	u8 used_by_vf;
+
+	struct hns_ring_hw_stats hw_stats;
+};
+
+struct rcb_common_cb {
+	u8 __iomem *io_base;
+	phys_addr_t phy_base;
+	struct dsaf_device *dsaf_dev;
+	u16 max_vfn;
+	u16 max_q_per_vf;
+
+	u8 comm_index;
+	u32 ring_num;
+	u32 coalesced_frames; /* frames  threshold of  rx interrupt   */
+	u32 timeout; /* time threshold of  rx interrupt  */
+	u32 desc_num; /*  desc num per queue*/
+
+	struct ring_pair_cb ring_pair_cb[0];
+};
+
+int hns_rcb_buf_size2type(u32 buf_size);
+
+int hns_rcb_common_get_cfg(struct dsaf_device *dsaf_dev, int comm_index);
+void hns_rcb_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index);
+int hns_rcb_common_init_hw(struct rcb_common_cb *rcb_common);
+void hns_rcb_start(struct hnae_queue *q, u32 val);
+void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common);
+void hns_rcb_common_init_commit_hw(struct rcb_common_cb *rcb_common);
+
+void hns_rcb_ring_enable_hw(struct hnae_queue *q, u32 val);
+void hns_rcb_int_clr_hw(struct hnae_queue *q, u32 flag);
+void hns_rcb_int_ctrl_hw(struct hnae_queue *q, u32 flag, u32 enable);
+void hns_rcb_init_hw(struct ring_pair_cb *ring);
+void hns_rcb_reset_ring_hw(struct hnae_queue *q);
+void hns_rcb_wait_fbd_clean(struct hnae_queue **qs, int q_num, u32 flag);
+
+u32 hns_rcb_get_coalesced_frames(struct dsaf_device *dsaf_dev, int comm_index);
+u32 hns_rcb_get_coalesce_usecs(struct dsaf_device *dsaf_dev, int comm_index);
+void hns_rcb_set_coalesce_usecs(struct dsaf_device *dsaf_dev,
+				int comm_index, u32 timeout);
+int hns_rcb_set_coalesced_frames(struct dsaf_device *dsaf_dev,
+				 int comm_index, u32 coalesce_frames);
+void hns_rcb_update_stats(struct hnae_queue *queue);
+
+void hns_rcb_get_stats(struct hnae_queue *queue, u64 *data);
+
+void hns_rcb_get_common_regs(struct rcb_common_cb *rcb_common, void *data);
+
+int hns_rcb_get_ring_sset_count(int stringset);
+int hns_rcb_get_common_regs_count(void);
+int hns_rcb_get_ring_regs_count(void);
+
+void hns_rcb_get_ring_regs(struct hnae_queue *queue, void *data);
+
+void hns_rcb_get_strings(int stringset, u8 *data, int index);
+#endif /* _HNS_DSAF_RCB_H */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
new file mode 100644
index 0000000..6fc58ba
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -0,0 +1,972 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _DSAF_REG_H_
+#define _DSAF_REG_H_
+
+#define HNS_GE_FIFO_ERR_INTNUM 8
+#define HNS_XGE_ERR_INTNUM 6
+#define HNS_RCB_COMM_ERR_INTNUM 12
+#define HNS_PPE_TNL_ERR_INTNUM 8
+#define HNS_DSAF_EVENT_INTNUM 21
+#define HNS_DEBUG_RING_INTNUM 4
+#define HNS_SERVICE_RING_INTNUM 256
+
+#define HNS_DEBUG_RING_IRQ_IDX (HNS_GE_FIFO_ERR_INTNUM + HNS_XGE_ERR_INTNUM +\
+		HNS_RCB_COMM_ERR_INTNUM + HNS_PPE_TNL_ERR_INTNUM +\
+		HNS_DSAF_EVENT_INTNUM)
+#define HNS_SERVICE_RING_IRQ_IDX (HNS_DEBUG_RING_IRQ_IDX +\
+		HNS_DEBUG_RING_INTNUM)
+
+#define DSAF_IRQ_NUM 18
+
+#define DSAF_MAX_PORT_NUM_PER_CHIP 8
+#define DSAF_SERVICE_PORT_NUM_PER_DSAF 6
+#define DSAF_MAX_VM_NUM 128
+
+#define DSAF_COMM_DEV_NUM 3
+#define DSAF_PPE_INODE_BASE 6
+#define HNS_DSAF_COMM_SERVICE_NW_IDX 0
+#define DSAF_DEBUG_NW_NUM	2
+#define DSAF_SERVICE_NW_NUM	6
+#define DSAF_COMM_CHN		DSAF_SERVICE_NW_NUM
+#define DSAF_GE_NUM		((DSAF_SERVICE_NW_NUM) + (DSAF_DEBUG_NW_NUM))
+#define DSAF_PORT_NUM		((DSAF_SERVICE_NW_NUM) + (DSAF_DEBUG_NW_NUM))
+#define DSAF_XGE_NUM		DSAF_SERVICE_NW_NUM
+#define DSAF_NODE_NUM		18
+#define DSAF_XOD_BIG_NUM	DSAF_NODE_NUM
+#define DSAF_SBM_NUM		DSAF_NODE_NUM
+#define DSAF_VOQ_NUM		DSAF_NODE_NUM
+#define DSAF_INODE_NUM		DSAF_NODE_NUM
+#define DSAF_XOD_NUM		8
+#define DSAF_TBL_NUM		8
+#define DSAF_SW_PORT_NUM	8
+#define DSAF_TOTAL_QUEUE_NUM	129
+
+#define DSAF_TCAM_SUM		512
+#define DSAF_LINE_SUM		(2048 * 14)
+
+#define DSAF_SUB_SC_NT_SRAM_CLK_SEL_REG                0x100
+#define DSAF_SUB_SC_HILINK3_CRG_CTRL0_REG              0x180
+#define DSAF_SUB_SC_HILINK3_CRG_CTRL1_REG              0x184
+#define DSAF_SUB_SC_HILINK3_CRG_CTRL2_REG              0x188
+#define DSAF_SUB_SC_HILINK3_CRG_CTRL3_REG              0x18C
+#define DSAF_SUB_SC_HILINK4_CRG_CTRL0_REG              0x190
+#define DSAF_SUB_SC_HILINK4_CRG_CTRL1_REG              0x194
+#define DSAF_SUB_SC_DSAF_CLK_EN_REG                    0x300
+#define DSAF_SUB_SC_DSAF_CLK_DIS_REG                   0x304
+#define DSAF_SUB_SC_NT_CLK_EN_REG                      0x308
+#define DSAF_SUB_SC_NT_CLK_DIS_REG                     0x30C
+#define DSAF_SUB_SC_XGE_CLK_EN_REG                     0x310
+#define DSAF_SUB_SC_XGE_CLK_DIS_REG                    0x314
+#define DSAF_SUB_SC_GE_CLK_EN_REG                      0x318
+#define DSAF_SUB_SC_GE_CLK_DIS_REG                     0x31C
+#define DSAF_SUB_SC_PPE_CLK_EN_REG                     0x320
+#define DSAF_SUB_SC_PPE_CLK_DIS_REG                    0x324
+#define DSAF_SUB_SC_RCB_PPE_COM_CLK_EN_REG             0x350
+#define DSAF_SUB_SC_RCB_PPE_COM_CLK_DIS_REG            0x354
+#define DSAF_SUB_SC_XBAR_RESET_REQ_REG                 0xA00
+#define DSAF_SUB_SC_XBAR_RESET_DREQ_REG                0xA04
+#define DSAF_SUB_SC_NT_RESET_REQ_REG                   0xA08
+#define DSAF_SUB_SC_NT_RESET_DREQ_REG                  0xA0C
+#define DSAF_SUB_SC_XGE_RESET_REQ_REG                  0xA10
+#define DSAF_SUB_SC_XGE_RESET_DREQ_REG                 0xA14
+#define DSAF_SUB_SC_GE_RESET_REQ0_REG                  0xA18
+#define DSAF_SUB_SC_GE_RESET_DREQ0_REG                 0xA1C
+#define DSAF_SUB_SC_GE_RESET_REQ1_REG                  0xA20
+#define DSAF_SUB_SC_GE_RESET_DREQ1_REG                 0xA24
+#define DSAF_SUB_SC_PPE_RESET_REQ_REG                  0xA48
+#define DSAF_SUB_SC_PPE_RESET_DREQ_REG                 0xA4C
+#define DSAF_SUB_SC_RCB_PPE_COM_RESET_REQ_REG          0xA88
+#define DSAF_SUB_SC_RCB_PPE_COM_RESET_DREQ_REG         0xA8C
+#define DSAF_SUB_SC_LIGHT_MODULE_DETECT_EN_REG         0x2060
+#define DSAF_SUB_SC_TCAM_MBIST_EN_REG                  0x2300
+#define DSAF_SUB_SC_DSAF_CLK_ST_REG                    0x5300
+#define DSAF_SUB_SC_NT_CLK_ST_REG                      0x5304
+#define DSAF_SUB_SC_XGE_CLK_ST_REG                     0x5308
+#define DSAF_SUB_SC_GE_CLK_ST_REG                      0x530C
+#define DSAF_SUB_SC_PPE_CLK_ST_REG                     0x5310
+#define DSAF_SUB_SC_ROCEE_CLK_ST_REG                   0x5314
+#define DSAF_SUB_SC_CPU_CLK_ST_REG                     0x5318
+#define DSAF_SUB_SC_RCB_PPE_COM_CLK_ST_REG             0x5328
+#define DSAF_SUB_SC_XBAR_RESET_ST_REG                  0x5A00
+#define DSAF_SUB_SC_NT_RESET_ST_REG                    0x5A04
+#define DSAF_SUB_SC_XGE_RESET_ST_REG                   0x5A08
+#define DSAF_SUB_SC_GE_RESET_ST0_REG                   0x5A0C
+#define DSAF_SUB_SC_GE_RESET_ST1_REG                   0x5A10
+#define DSAF_SUB_SC_PPE_RESET_ST_REG                   0x5A24
+#define DSAF_SUB_SC_RCB_PPE_COM_RESET_ST_REG           0x5A44
+
+/*serdes offset**/
+#define HNS_MAC_HILINK3_REG DSAF_SUB_SC_HILINK3_CRG_CTRL0_REG
+#define HNS_MAC_HILINK4_REG DSAF_SUB_SC_HILINK4_CRG_CTRL0_REG
+#define HNS_MAC_LANE0_CTLEDFE_REG 0x000BFFCCULL
+#define HNS_MAC_LANE1_CTLEDFE_REG 0x000BFFBCULL
+#define HNS_MAC_LANE2_CTLEDFE_REG 0x000BFFACULL
+#define HNS_MAC_LANE3_CTLEDFE_REG 0x000BFF9CULL
+#define HNS_MAC_LANE0_STATE_REG 0x000BFFD4ULL
+#define HNS_MAC_LANE1_STATE_REG 0x000BFFC4ULL
+#define HNS_MAC_LANE2_STATE_REG 0x000BFFB4ULL
+#define HNS_MAC_LANE3_STATE_REG 0x000BFFA4ULL
+
+#define HILINK_RESET_TIMOUT 10000
+
+#define DSAF_SRAM_INIT_OVER_0_REG	0x0
+#define DSAF_CFG_0_REG			0x4
+#define DSAF_ECC_ERR_INVERT_0_REG	0x8
+#define DSAF_ABNORMAL_TIMEOUT_0_REG	0x1C
+#define DSAF_FSM_TIMEOUT_0_REG		0x20
+#define DSAF_DSA_REG_CNT_CLR_CE_REG	0x2C
+#define DSAF_DSA_SBM_INF_FIFO_THRD_REG	0x30
+#define DSAF_DSA_SRAM_1BIT_ECC_SEL_REG	0x34
+#define DSAF_DSA_SRAM_1BIT_ECC_CNT_REG	0x38
+#define DSAF_PFC_EN_0_REG		0x50
+#define DSAF_PFC_UNIT_CNT_0_REG		0x70
+#define DSAF_XGE_INT_MSK_0_REG		0x100
+#define DSAF_PPE_INT_MSK_0_REG		0x120
+#define DSAF_ROCEE_INT_MSK_0_REG	0x140
+#define DSAF_XGE_INT_SRC_0_REG		0x160
+#define DSAF_PPE_INT_SRC_0_REG		0x180
+#define DSAF_ROCEE_INT_SRC_0_REG	0x1A0
+#define DSAF_XGE_INT_STS_0_REG		0x1C0
+#define DSAF_PPE_INT_STS_0_REG		0x1E0
+#define DSAF_ROCEE_INT_STS_0_REG	0x200
+#define DSAF_PPE_QID_CFG_0_REG		0x300
+#define DSAF_SW_PORT_TYPE_0_REG		0x320
+#define DSAF_STP_PORT_TYPE_0_REG	0x340
+#define DSAF_MIX_DEF_QID_0_REG		0x360
+#define DSAF_PORT_DEF_VLAN_0_REG	0x380
+#define DSAF_VM_DEF_VLAN_0_REG		0x400
+
+#define DSAF_INODE_CUT_THROUGH_CFG_0_REG	0x1000
+#define DSAF_INODE_ECC_INVERT_EN_0_REG		0x1008
+#define DSAF_INODE_ECC_ERR_ADDR_0_REG		0x100C
+#define DSAF_INODE_IN_PORT_NUM_0_REG		0x1018
+#define DSAF_INODE_PRI_TC_CFG_0_REG		0x101C
+#define DSAF_INODE_BP_STATUS_0_REG		0x1020
+#define DSAF_INODE_PAD_DISCARD_NUM_0_REG	0x1028
+#define DSAF_INODE_FINAL_IN_MAN_NUM_0_REG	0x102C
+#define DSAF_INODE_FINAL_IN_PKT_NUM_0_REG	0x1030
+#define DSAF_INODE_SBM_PID_NUM_0_REG		0x1038
+#define DSAF_INODE_FINAL_IN_PAUSE_NUM_0_REG	0x103C
+#define DSAF_INODE_SBM_RELS_NUM_0_REG		0x104C
+#define DSAF_INODE_SBM_DROP_NUM_0_REG		0x1050
+#define DSAF_INODE_CRC_FALSE_NUM_0_REG		0x1054
+#define DSAF_INODE_BP_DISCARD_NUM_0_REG		0x1058
+#define DSAF_INODE_RSLT_DISCARD_NUM_0_REG	0x105C
+#define DSAF_INODE_LOCAL_ADDR_FALSE_NUM_0_REG	0x1060
+#define DSAF_INODE_VOQ_OVER_NUM_0_REG		0x1068
+#define DSAF_INODE_BD_SAVE_STATUS_0_REG		0x1900
+#define DSAF_INODE_BD_ORDER_STATUS_0_REG	0x1950
+#define DSAF_INODE_SW_VLAN_TAG_DISC_0_REG	0x1A00
+#define DSAF_INODE_IN_DATA_STP_DISC_0_REG	0x1A50
+#define DSAF_INODE_GE_FC_EN_0_REG		0x1B00
+#define DSAF_INODE_VC0_IN_PKT_NUM_0_REG		0x1B50
+#define DSAF_INODE_VC1_IN_PKT_NUM_0_REG		0x1C00
+
+#define DSAF_SBM_CFG_REG_0_REG			0x2000
+#define DSAF_SBM_BP_CFG_0_XGE_REG_0_REG		0x2004
+#define DSAF_SBM_BP_CFG_0_PPE_REG_0_REG		0x2304
+#define DSAF_SBM_BP_CFG_0_ROCEE_REG_0_REG	0x2604
+#define DSAF_SBM_BP_CFG_1_REG_0_REG		0x2008
+#define DSAF_SBM_BP_CFG_2_XGE_REG_0_REG		0x200C
+#define DSAF_SBM_BP_CFG_2_PPE_REG_0_REG		0x230C
+#define DSAF_SBM_BP_CFG_2_ROCEE_REG_0_REG	0x260C
+#define DSAF_SBM_FREE_CNT_0_0_REG		0x2010
+#define DSAF_SBM_FREE_CNT_1_0_REG		0x2014
+#define DSAF_SBM_BP_CNT_0_0_REG			0x2018
+#define DSAF_SBM_BP_CNT_1_0_REG			0x201C
+#define DSAF_SBM_BP_CNT_2_0_REG			0x2020
+#define DSAF_SBM_BP_CNT_3_0_REG			0x2024
+#define DSAF_SBM_INER_ST_0_REG			0x2028
+#define DSAF_SBM_MIB_REQ_FAILED_TC_0_REG	0x202C
+#define DSAF_SBM_LNK_INPORT_CNT_0_REG		0x2030
+#define DSAF_SBM_LNK_DROP_CNT_0_REG		0x2034
+#define DSAF_SBM_INF_OUTPORT_CNT_0_REG		0x2038
+#define DSAF_SBM_LNK_INPORT_TC0_CNT_0_REG	0x203C
+#define DSAF_SBM_LNK_INPORT_TC1_CNT_0_REG	0x2040
+#define DSAF_SBM_LNK_INPORT_TC2_CNT_0_REG	0x2044
+#define DSAF_SBM_LNK_INPORT_TC3_CNT_0_REG	0x2048
+#define DSAF_SBM_LNK_INPORT_TC4_CNT_0_REG	0x204C
+#define DSAF_SBM_LNK_INPORT_TC5_CNT_0_REG	0x2050
+#define DSAF_SBM_LNK_INPORT_TC6_CNT_0_REG	0x2054
+#define DSAF_SBM_LNK_INPORT_TC7_CNT_0_REG	0x2058
+#define DSAF_SBM_LNK_REQ_CNT_0_REG		0x205C
+#define DSAF_SBM_LNK_RELS_CNT_0_REG		0x2060
+#define DSAF_SBM_BP_CFG_3_REG_0_REG		0x2068
+#define DSAF_SBM_BP_CFG_4_REG_0_REG		0x206C
+
+#define DSAF_XOD_ETS_TSA_TC0_TC3_CFG_0_REG	0x3000
+#define DSAF_XOD_ETS_TSA_TC4_TC7_CFG_0_REG	0x3004
+#define DSAF_XOD_ETS_BW_TC0_TC3_CFG_0_REG	0x3008
+#define DSAF_XOD_ETS_BW_TC4_TC7_CFG_0_REG	0x300C
+#define DSAF_XOD_ETS_BW_OFFSET_CFG_0_REG	0x3010
+#define DSAF_XOD_ETS_TOKEN_CFG_0_REG		0x3014
+#define DSAF_XOD_PFS_CFG_0_0_REG		0x3018
+#define DSAF_XOD_PFS_CFG_1_0_REG		0x301C
+#define DSAF_XOD_PFS_CFG_2_0_REG		0x3020
+#define DSAF_XOD_GNT_L_0_REG			0x3024
+#define DSAF_XOD_GNT_H_0_REG			0x3028
+#define DSAF_XOD_CONNECT_STATE_0_REG		0x302C
+#define DSAF_XOD_RCVPKT_CNT_0_REG		0x3030
+#define DSAF_XOD_RCVTC0_CNT_0_REG		0x3034
+#define DSAF_XOD_RCVTC1_CNT_0_REG		0x3038
+#define DSAF_XOD_RCVTC2_CNT_0_REG		0x303C
+#define DSAF_XOD_RCVTC3_CNT_0_REG		0x3040
+#define DSAF_XOD_RCVVC0_CNT_0_REG		0x3044
+#define DSAF_XOD_RCVVC1_CNT_0_REG		0x3048
+#define DSAF_XOD_XGE_RCVIN0_CNT_0_REG		0x304C
+#define DSAF_XOD_XGE_RCVIN1_CNT_0_REG		0x3050
+#define DSAF_XOD_XGE_RCVIN2_CNT_0_REG		0x3054
+#define DSAF_XOD_XGE_RCVIN3_CNT_0_REG		0x3058
+#define DSAF_XOD_XGE_RCVIN4_CNT_0_REG		0x305C
+#define DSAF_XOD_XGE_RCVIN5_CNT_0_REG		0x3060
+#define DSAF_XOD_XGE_RCVIN6_CNT_0_REG		0x3064
+#define DSAF_XOD_XGE_RCVIN7_CNT_0_REG		0x3068
+#define DSAF_XOD_PPE_RCVIN0_CNT_0_REG		0x306C
+#define DSAF_XOD_PPE_RCVIN1_CNT_0_REG		0x3070
+#define DSAF_XOD_ROCEE_RCVIN0_CNT_0_REG		0x3074
+#define DSAF_XOD_ROCEE_RCVIN1_CNT_0_REG		0x3078
+#define DSAF_XOD_FIFO_STATUS_0_REG		0x307C
+
+#define DSAF_VOQ_ECC_INVERT_EN_0_REG		0x4004
+#define DSAF_VOQ_SRAM_PKT_NUM_0_REG		0x4008
+#define DSAF_VOQ_IN_PKT_NUM_0_REG		0x400C
+#define DSAF_VOQ_OUT_PKT_NUM_0_REG		0x4010
+#define DSAF_VOQ_ECC_ERR_ADDR_0_REG		0x4014
+#define DSAF_VOQ_BP_STATUS_0_REG		0x4018
+#define DSAF_VOQ_SPUP_IDLE_0_REG		0x401C
+#define DSAF_VOQ_XGE_XOD_REQ_0_0_REG		0x4024
+#define DSAF_VOQ_XGE_XOD_REQ_1_0_REG		0x4028
+#define DSAF_VOQ_PPE_XOD_REQ_0_REG		0x402C
+#define DSAF_VOQ_ROCEE_XOD_REQ_0_REG		0x4030
+#define DSAF_VOQ_BP_ALL_THRD_0_REG		0x4034
+
+#define DSAF_TBL_CTRL_0_REG			0x5000
+#define DSAF_TBL_INT_MSK_0_REG			0x5004
+#define DSAF_TBL_INT_SRC_0_REG			0x5008
+#define DSAF_TBL_INT_STS_0_REG			0x5100
+#define DSAF_TBL_TCAM_ADDR_0_REG		0x500C
+#define DSAF_TBL_LINE_ADDR_0_REG		0x5010
+#define DSAF_TBL_TCAM_HIGH_0_REG		0x5014
+#define DSAF_TBL_TCAM_LOW_0_REG			0x5018
+#define DSAF_TBL_TCAM_MCAST_CFG_4_0_REG		0x501C
+#define DSAF_TBL_TCAM_MCAST_CFG_3_0_REG		0x5020
+#define DSAF_TBL_TCAM_MCAST_CFG_2_0_REG		0x5024
+#define DSAF_TBL_TCAM_MCAST_CFG_1_0_REG		0x5028
+#define DSAF_TBL_TCAM_MCAST_CFG_0_0_REG		0x502C
+#define DSAF_TBL_TCAM_UCAST_CFG_0_REG		0x5030
+#define DSAF_TBL_LIN_CFG_0_REG			0x5034
+#define DSAF_TBL_TCAM_RDATA_HIGH_0_REG		0x5038
+#define DSAF_TBL_TCAM_RDATA_LOW_0_REG		0x503C
+#define DSAF_TBL_TCAM_RAM_RDATA4_0_REG		0x5040
+#define DSAF_TBL_TCAM_RAM_RDATA3_0_REG		0x5044
+#define DSAF_TBL_TCAM_RAM_RDATA2_0_REG		0x5048
+#define DSAF_TBL_TCAM_RAM_RDATA1_0_REG		0x504C
+#define DSAF_TBL_TCAM_RAM_RDATA0_0_REG		0x5050
+#define DSAF_TBL_LIN_RDATA_0_REG		0x5054
+#define DSAF_TBL_DA0_MIS_INFO1_0_REG		0x5058
+#define DSAF_TBL_DA0_MIS_INFO0_0_REG		0x505C
+#define DSAF_TBL_SA_MIS_INFO2_0_REG		0x5104
+#define DSAF_TBL_SA_MIS_INFO1_0_REG		0x5098
+#define DSAF_TBL_SA_MIS_INFO0_0_REG		0x509C
+#define DSAF_TBL_PUL_0_REG			0x50A0
+#define DSAF_TBL_OLD_RSLT_0_REG			0x50A4
+#define DSAF_TBL_OLD_SCAN_VAL_0_REG		0x50A8
+#define DSAF_TBL_DFX_CTRL_0_REG			0x50AC
+#define DSAF_TBL_DFX_STAT_0_REG			0x50B0
+#define DSAF_TBL_DFX_STAT_2_0_REG		0x5108
+#define DSAF_TBL_LKUP_NUM_I_0_REG		0x50C0
+#define DSAF_TBL_LKUP_NUM_O_0_REG		0x50E0
+#define DSAF_TBL_UCAST_BCAST_MIS_INFO_0_0_REG	0x510C
+
+#define DSAF_INODE_FIFO_WL_0_REG		0x6000
+#define DSAF_ONODE_FIFO_WL_0_REG		0x6020
+#define DSAF_XGE_GE_WORK_MODE_0_REG		0x6040
+#define DSAF_XGE_APP_RX_LINK_UP_0_REG		0x6080
+#define DSAF_NETPORT_CTRL_SIG_0_REG		0x60A0
+#define DSAF_XGE_CTRL_SIG_CFG_0_REG		0x60C0
+
+#define PPE_COM_CFG_QID_MODE_REG		0x0
+#define PPE_COM_INTEN_REG			0x110
+#define PPE_COM_RINT_REG			0x114
+#define PPE_COM_INTSTS_REG			0x118
+#define PPE_COM_COMMON_CNT_CLR_CE_REG		0x1120
+#define PPE_COM_HIS_RX_PKT_QID_DROP_CNT_REG	0x300
+#define PPE_COM_HIS_RX_PKT_QID_OK_CNT_REG	0x600
+#define PPE_COM_HIS_TX_PKT_QID_ERR_CNT_REG	0x900
+#define PPE_COM_HIS_TX_PKT_QID_OK_CNT_REG	0xC00
+#define PPE_COM_COMMON_CNT_CLR_CE_REG		0x1120
+
+#define PPE_CFG_TX_FIFO_THRSLD_REG		0x0
+#define PPE_CFG_RX_FIFO_THRSLD_REG		0x4
+#define PPE_CFG_RX_FIFO_PAUSE_THRSLD_REG	0x8
+#define PPE_CFG_RX_FIFO_SW_BP_THRSLD_REG	0xC
+#define PPE_CFG_PAUSE_IDLE_CNT_REG		0x10
+#define PPE_CFG_BUS_CTRL_REG			0x40
+#define PPE_CFG_TNL_TO_BE_RST_REG		0x48
+#define PPE_CURR_TNL_CAN_RST_REG		0x4C
+#define PPE_CFG_XGE_MODE_REG			0x80
+#define PPE_CFG_MAX_FRAME_LEN_REG		0x84
+#define PPE_CFG_RX_PKT_MODE_REG			0x88
+#define PPE_CFG_RX_VLAN_TAG_REG			0x8C
+#define PPE_CFG_TAG_GEN_REG			0x90
+#define PPE_CFG_PARSE_TAG_REG			0x94
+#define PPE_CFG_PRO_CHECK_EN_REG		0x98
+#define PPE_INTEN_REG				0x100
+#define PPE_RINT_REG				0x104
+#define PPE_INTSTS_REG				0x108
+#define PPE_CFG_RX_PKT_INT_REG			0x140
+#define PPE_CFG_HEAT_DECT_TIME0_REG		0x144
+#define PPE_CFG_HEAT_DECT_TIME1_REG		0x148
+#define PPE_HIS_RX_SW_PKT_CNT_REG		0x200
+#define PPE_HIS_RX_WR_BD_OK_PKT_CNT_REG		0x204
+#define PPE_HIS_RX_PKT_NO_BUF_CNT_REG		0x208
+#define PPE_HIS_TX_BD_CNT_REG			0x20C
+#define PPE_HIS_TX_PKT_CNT_REG			0x210
+#define PPE_HIS_TX_PKT_OK_CNT_REG		0x214
+#define PPE_HIS_TX_PKT_EPT_CNT_REG		0x218
+#define PPE_HIS_TX_PKT_CS_FAIL_CNT_REG		0x21C
+#define PPE_HIS_RX_APP_BUF_FAIL_CNT_REG		0x220
+#define PPE_HIS_RX_APP_BUF_WAIT_CNT_REG		0x224
+#define PPE_HIS_RX_PKT_DROP_FUL_CNT_REG		0x228
+#define PPE_HIS_RX_PKT_DROP_PRT_CNT_REG		0x22C
+#define PPE_TNL_0_5_CNT_CLR_CE_REG		0x300
+#define PPE_CFG_AXI_DBG_REG			0x304
+#define PPE_HIS_PRO_ERR_REG			0x308
+#define PPE_HIS_TNL_FIFO_ERR_REG		0x30C
+#define PPE_CURR_CFF_DATA_NUM_REG		0x310
+#define PPE_CURR_RX_ST_REG			0x314
+#define PPE_CURR_TX_ST_REG			0x318
+#define PPE_CURR_RX_FIFO0_REG			0x31C
+#define PPE_CURR_RX_FIFO1_REG			0x320
+#define PPE_CURR_TX_FIFO0_REG			0x324
+#define PPE_CURR_TX_FIFO1_REG			0x328
+#define PPE_ECO0_REG				0x32C
+#define PPE_ECO1_REG				0x330
+#define PPE_ECO2_REG				0x334
+
+#define RCB_COM_CFG_ENDIAN_REG			0x0
+#define RCB_COM_CFG_SYS_FSH_REG			0xC
+#define RCB_COM_CFG_INIT_FLAG_REG		0x10
+#define RCB_COM_CFG_PKT_REG			0x30
+#define RCB_COM_CFG_RINVLD_REG			0x34
+#define RCB_COM_CFG_FNA_REG			0x38
+#define RCB_COM_CFG_FA_REG			0x3C
+#define RCB_COM_CFG_PKT_TC_BP_REG		0x40
+#define RCB_COM_CFG_PPE_TNL_CLKEN_REG		0x44
+
+#define RCB_COM_INTMSK_TX_PKT_REG		0x3A0
+#define RCB_COM_RINT_TX_PKT_REG			0x3A8
+#define RCB_COM_INTMASK_ECC_ERR_REG		0x400
+#define RCB_COM_INTSTS_ECC_ERR_REG		0x408
+#define RCB_COM_EBD_SRAM_ERR_REG		0x410
+#define RCB_COM_RXRING_ERR_REG			0x41C
+#define RCB_COM_TXRING_ERR_REG			0x420
+#define RCB_COM_TX_FBD_ERR_REG			0x424
+#define RCB_SRAM_ECC_CHK_EN_REG			0x428
+#define RCB_SRAM_ECC_CHK0_REG			0x42C
+#define RCB_SRAM_ECC_CHK1_REG			0x430
+#define RCB_SRAM_ECC_CHK2_REG			0x434
+#define RCB_SRAM_ECC_CHK3_REG			0x438
+#define RCB_SRAM_ECC_CHK4_REG			0x43c
+#define RCB_SRAM_ECC_CHK5_REG			0x440
+#define RCB_ECC_ERR_ADDR0_REG			0x450
+#define RCB_ECC_ERR_ADDR3_REG			0x45C
+#define RCB_ECC_ERR_ADDR4_REG			0x460
+#define RCB_ECC_ERR_ADDR5_REG			0x464
+
+#define RCB_COM_SF_CFG_INTMASK_RING		0x480
+#define RCB_COM_SF_CFG_RING_STS			0x484
+#define RCB_COM_SF_CFG_RING			0x488
+#define RCB_COM_SF_CFG_INTMASK_BD		0x48C
+#define RCB_COM_SF_CFG_BD_RINT_STS		0x470
+#define RCB_COM_RCB_RD_BD_BUSY			0x490
+#define RCB_COM_RCB_FBD_CRT_EN			0x494
+#define RCB_COM_AXI_WR_ERR_INTMASK		0x498
+#define RCB_COM_AXI_ERR_STS			0x49C
+#define RCB_COM_CHK_TX_FBD_NUM_REG		0x4a0
+
+#define RCB_CFG_BD_NUM_REG			0x9000
+#define RCB_CFG_PKTLINE_REG			0x9050
+
+#define RCB_CFG_OVERTIME_REG			0x9300
+#define RCB_CFG_PKTLINE_INT_NUM_REG		0x9304
+#define RCB_CFG_OVERTIME_INT_NUM_REG		0x9308
+
+#define RCB_RING_RX_RING_BASEADDR_L_REG		0x00000
+#define RCB_RING_RX_RING_BASEADDR_H_REG		0x00004
+#define RCB_RING_RX_RING_BD_NUM_REG		0x00008
+#define RCB_RING_RX_RING_BD_LEN_REG		0x0000C
+#define RCB_RING_RX_RING_PKTLINE_REG		0x00010
+#define RCB_RING_RX_RING_TAIL_REG		0x00018
+#define RCB_RING_RX_RING_HEAD_REG		0x0001C
+#define RCB_RING_RX_RING_FBDNUM_REG		0x00020
+#define RCB_RING_RX_RING_PKTNUM_RECORD_REG	0x0002C
+
+#define RCB_RING_TX_RING_BASEADDR_L_REG		0x00040
+#define RCB_RING_TX_RING_BASEADDR_H_REG		0x00044
+#define RCB_RING_TX_RING_BD_NUM_REG		0x00048
+#define RCB_RING_TX_RING_BD_LEN_REG		0x0004C
+#define RCB_RING_TX_RING_PKTLINE_REG		0x00050
+#define RCB_RING_TX_RING_TAIL_REG		0x00058
+#define RCB_RING_TX_RING_HEAD_REG		0x0005C
+#define RCB_RING_TX_RING_FBDNUM_REG		0x00060
+#define RCB_RING_TX_RING_OFFSET_REG		0x00064
+#define RCB_RING_TX_RING_PKTNUM_RECORD_REG	0x0006C
+
+#define RCB_RING_PREFETCH_EN_REG		0x0007C
+#define RCB_RING_CFG_VF_NUM_REG			0x00080
+#define RCB_RING_ASID_REG			0x0008C
+#define RCB_RING_RX_VM_REG			0x00090
+#define RCB_RING_T0_BE_RST			0x00094
+#define RCB_RING_COULD_BE_RST			0x00098
+#define RCB_RING_WRR_WEIGHT_REG			0x0009c
+
+#define RCB_RING_INTMSK_RXWL_REG		0x000A0
+#define RCB_RING_INTSTS_RX_RING_REG		0x000A4
+#define RCB_RING_INTMSK_TXWL_REG		0x000AC
+#define RCB_RING_INTSTS_TX_RING_REG		0x000B0
+#define RCB_RING_INTMSK_RX_OVERTIME_REG		0x000B8
+#define RCB_RING_INTSTS_RX_OVERTIME_REG		0x000BC
+#define RCB_RING_INTMSK_TX_OVERTIME_REG		0x000C4
+#define RCB_RING_INTSTS_TX_OVERTIME_REG		0x000C8
+
+#define GMAC_DUPLEX_TYPE_REG			0x0008UL
+#define GMAC_FD_FC_TYPE_REG			0x000CUL
+#define GMAC_FC_TX_TIMER_REG			0x001CUL
+#define GMAC_FD_FC_ADDR_LOW_REG			0x0020UL
+#define GMAC_FD_FC_ADDR_HIGH_REG		0x0024UL
+#define GMAC_IPG_TX_TIMER_REG			0x0030UL
+#define GMAC_PAUSE_THR_REG			0x0038UL
+#define GMAC_MAX_FRM_SIZE_REG			0x003CUL
+#define GMAC_PORT_MODE_REG			0x0040UL
+#define GMAC_PORT_EN_REG			0x0044UL
+#define GMAC_PAUSE_EN_REG			0x0048UL
+#define GMAC_SHORT_RUNTS_THR_REG		0x0050UL
+#define GMAC_AN_NEG_STATE_REG			0x0058UL
+#define GMAC_TX_LOCAL_PAGE_REG			0x005CUL
+#define GMAC_TRANSMIT_CONTROL_REG		0x0060UL
+#define GMAC_REC_FILT_CONTROL_REG		0x0064UL
+#define GMAC_PTP_CONFIG_REG			0x0074UL
+
+#define GMAC_RX_OCTETS_TOTAL_OK_REG		0x0080UL
+#define GMAC_RX_OCTETS_BAD_REG			0x0084UL
+#define GMAC_RX_UC_PKTS_REG			0x0088UL
+#define GMAC_RX_MC_PKTS_REG			0x008CUL
+#define GMAC_RX_BC_PKTS_REG			0x0090UL
+#define GMAC_RX_PKTS_64OCTETS_REG		0x0094UL
+#define GMAC_RX_PKTS_65TO127OCTETS_REG		0x0098UL
+#define GMAC_RX_PKTS_128TO255OCTETS_REG		0x009CUL
+#define GMAC_RX_PKTS_255TO511OCTETS_REG		0x00A0UL
+#define GMAC_RX_PKTS_512TO1023OCTETS_REG	0x00A4UL
+#define GMAC_RX_PKTS_1024TO1518OCTETS_REG	0x00A8UL
+#define GMAC_RX_PKTS_1519TOMAXOCTETS_REG	0x00ACUL
+#define GMAC_RX_FCS_ERRORS_REG			0x00B0UL
+#define GMAC_RX_TAGGED_REG			0x00B4UL
+#define GMAC_RX_DATA_ERR_REG			0x00B8UL
+#define GMAC_RX_ALIGN_ERRORS_REG		0x00BCUL
+#define GMAC_RX_LONG_ERRORS_REG			0x00C0UL
+#define GMAC_RX_JABBER_ERRORS_REG		0x00C4UL
+#define GMAC_RX_PAUSE_MACCTRL_FRAM_REG		0x00C8UL
+#define GMAC_RX_UNKNOWN_MACCTRL_FRAM_REG	0x00CCUL
+#define GMAC_RX_VERY_LONG_ERR_CNT_REG		0x00D0UL
+#define GMAC_RX_RUNT_ERR_CNT_REG		0x00D4UL
+#define GMAC_RX_SHORT_ERR_CNT_REG		0x00D8UL
+#define GMAC_RX_FILT_PKT_CNT_REG		0x00E8UL
+#define GMAC_RX_OCTETS_TOTAL_FILT_REG		0x00ECUL
+#define GMAC_OCTETS_TRANSMITTED_OK_REG		0x0100UL
+#define GMAC_OCTETS_TRANSMITTED_BAD_REG		0x0104UL
+#define GMAC_TX_UC_PKTS_REG			0x0108UL
+#define GMAC_TX_MC_PKTS_REG			0x010CUL
+#define GMAC_TX_BC_PKTS_REG			0x0110UL
+#define GMAC_TX_PKTS_64OCTETS_REG		0x0114UL
+#define GMAC_TX_PKTS_65TO127OCTETS_REG		0x0118UL
+#define GMAC_TX_PKTS_128TO255OCTETS_REG		0x011CUL
+#define GMAC_TX_PKTS_255TO511OCTETS_REG		0x0120UL
+#define GMAC_TX_PKTS_512TO1023OCTETS_REG	0x0124UL
+#define GMAC_TX_PKTS_1024TO1518OCTETS_REG	0x0128UL
+#define GMAC_TX_PKTS_1519TOMAXOCTETS_REG	0x012CUL
+#define GMAC_TX_EXCESSIVE_LENGTH_DROP_REG	0x014CUL
+#define GMAC_TX_UNDERRUN_REG			0x0150UL
+#define GMAC_TX_TAGGED_REG			0x0154UL
+#define GMAC_TX_CRC_ERROR_REG			0x0158UL
+#define GMAC_TX_PAUSE_FRAMES_REG		0x015CUL
+#define GAMC_RX_MAX_FRAME			0x0170UL
+#define GMAC_LINE_LOOP_BACK_REG			0x01A8UL
+#define GMAC_CF_CRC_STRIP_REG			0x01B0UL
+#define GMAC_MODE_CHANGE_EN_REG			0x01B4UL
+#define GMAC_SIXTEEN_BIT_CNTR_REG		0x01CCUL
+#define GMAC_LD_LINK_COUNTER_REG		0x01D0UL
+#define GMAC_LOOP_REG				0x01DCUL
+#define GMAC_RECV_CONTROL_REG			0x01E0UL
+#define GMAC_VLAN_CODE_REG			0x01E8UL
+#define GMAC_RX_OVERRUN_CNT_REG			0x01ECUL
+#define GMAC_RX_LENGTHFIELD_ERR_CNT_REG		0x01F4UL
+#define GMAC_RX_FAIL_COMMA_CNT_REG		0x01F8UL
+#define GMAC_STATION_ADDR_LOW_0_REG		0x0200UL
+#define GMAC_STATION_ADDR_HIGH_0_REG		0x0204UL
+#define GMAC_STATION_ADDR_LOW_1_REG		0x0208UL
+#define GMAC_STATION_ADDR_HIGH_1_REG		0x020CUL
+#define GMAC_STATION_ADDR_LOW_2_REG		0x0210UL
+#define GMAC_STATION_ADDR_HIGH_2_REG		0x0214UL
+#define GMAC_STATION_ADDR_LOW_3_REG		0x0218UL
+#define GMAC_STATION_ADDR_HIGH_3_REG		0x021CUL
+#define GMAC_STATION_ADDR_LOW_4_REG		0x0220UL
+#define GMAC_STATION_ADDR_HIGH_4_REG		0x0224UL
+#define GMAC_STATION_ADDR_LOW_5_REG		0x0228UL
+#define GMAC_STATION_ADDR_HIGH_5_REG		0x022CUL
+#define GMAC_STATION_ADDR_LOW_MSK_0_REG		0x0230UL
+#define GMAC_STATION_ADDR_HIGH_MSK_0_REG	0x0234UL
+#define GMAC_STATION_ADDR_LOW_MSK_1_REG		0x0238UL
+#define GMAC_STATION_ADDR_HIGH_MSK_1_REG	0x023CUL
+#define GMAC_MAC_SKIP_LEN_REG			0x0240UL
+#define GMAC_TX_LOOP_PKT_PRI_REG		0x0378UL
+
+#define XGMAC_INT_STATUS_REG			0x0
+#define XGMAC_INT_ENABLE_REG			0x4
+#define XGMAC_INT_SET_REG			0x8
+#define XGMAC_IERR_U_INFO_REG			0xC
+#define XGMAC_OVF_INFO_REG			0x10
+#define XGMAC_OVF_CNT_REG			0x14
+#define XGMAC_PORT_MODE_REG			0x40
+#define XGMAC_CLK_ENABLE_REG			0x44
+#define XGMAC_RESET_REG				0x48
+#define XGMAC_LINK_CONTROL_REG			0x50
+#define XGMAC_LINK_STATUS_REG			0x54
+#define XGMAC_SPARE_REG				0xC0
+#define XGMAC_SPARE_CNT_REG			0xC4
+
+#define XGMAC_MAC_ENABLE_REG			0x100
+#define XGMAC_MAC_CONTROL_REG			0x104
+#define XGMAC_MAC_IPG_REG			0x120
+#define XGMAC_MAC_MSG_CRC_EN_REG		0x124
+#define XGMAC_MAC_MSG_IMG_REG			0x128
+#define XGMAC_MAC_MSG_FC_CFG_REG		0x12C
+#define XGMAC_MAC_MSG_TC_CFG_REG		0x130
+#define XGMAC_MAC_PAD_SIZE_REG			0x134
+#define XGMAC_MAC_MIN_PKT_SIZE_REG		0x138
+#define XGMAC_MAC_MAX_PKT_SIZE_REG		0x13C
+#define XGMAC_MAC_PAUSE_CTRL_REG		0x160
+#define XGMAC_MAC_PAUSE_TIME_REG		0x164
+#define XGMAC_MAC_PAUSE_GAP_REG			0x168
+#define XGMAC_MAC_PAUSE_LOCAL_MAC_H_REG		0x16C
+#define XGMAC_MAC_PAUSE_LOCAL_MAC_L_REG		0x170
+#define XGMAC_MAC_PAUSE_PEER_MAC_H_REG		0x174
+#define XGMAC_MAC_PAUSE_PEER_MAC_L_REG		0x178
+#define XGMAC_MAC_PFC_PRI_EN_REG		0x17C
+#define XGMAC_MAC_1588_CTRL_REG			0x180
+#define XGMAC_MAC_1588_TX_PORT_DLY_REG		0x184
+#define XGMAC_MAC_1588_RX_PORT_DLY_REG		0x188
+#define XGMAC_MAC_1588_ASYM_DLY_REG		0x18C
+#define XGMAC_MAC_1588_ADJUST_CFG_REG		0x190
+#define XGMAC_MAC_Y1731_ETH_TYPE_REG		0x194
+#define XGMAC_MAC_MIB_CONTROL_REG		0x198
+#define XGMAC_MAC_WAN_RATE_ADJUST_REG		0x19C
+#define XGMAC_MAC_TX_ERR_MARK_REG		0x1A0
+#define XGMAC_MAC_TX_LF_RF_CONTROL_REG		0x1A4
+#define XGMAC_MAC_RX_LF_RF_STATUS_REG		0x1A8
+#define XGMAC_MAC_TX_RUNT_PKT_CNT_REG		0x1C0
+#define XGMAC_MAC_RX_RUNT_PKT_CNT_REG		0x1C4
+#define XGMAC_MAC_RX_PREAM_ERR_PKT_CNT_REG	0x1C8
+#define XGMAC_MAC_TX_LF_RF_TERM_PKT_CNT_REG	0x1CC
+#define XGMAC_MAC_TX_SN_MISMATCH_PKT_CNT_REG	0x1D0
+#define XGMAC_MAC_RX_ERR_MSG_CNT_REG		0x1D4
+#define XGMAC_MAC_RX_ERR_EFD_CNT_REG		0x1D8
+#define XGMAC_MAC_ERR_INFO_REG			0x1DC
+#define XGMAC_MAC_DBG_INFO_REG			0x1E0
+
+#define XGMAC_PCS_BASER_SYNC_THD_REG		0x330
+#define XGMAC_PCS_STATUS1_REG			0x404
+#define XGMAC_PCS_BASER_STATUS1_REG		0x410
+#define XGMAC_PCS_BASER_STATUS2_REG		0x414
+#define XGMAC_PCS_BASER_SEEDA_0_REG		0x420
+#define XGMAC_PCS_BASER_SEEDA_1_REG		0x424
+#define XGMAC_PCS_BASER_SEEDB_0_REG		0x428
+#define XGMAC_PCS_BASER_SEEDB_1_REG		0x42C
+#define XGMAC_PCS_BASER_TEST_CONTROL_REG	0x430
+#define XGMAC_PCS_BASER_TEST_ERR_CNT_REG	0x434
+#define XGMAC_PCS_DBG_INFO_REG			0x4C0
+#define XGMAC_PCS_DBG_INFO1_REG			0x4C4
+#define XGMAC_PCS_DBG_INFO2_REG			0x4C8
+#define XGMAC_PCS_DBG_INFO3_REG			0x4CC
+
+#define XGMAC_PMA_ENABLE_REG			0x700
+#define XGMAC_PMA_CONTROL_REG			0x704
+#define XGMAC_PMA_SIGNAL_STATUS_REG		0x708
+#define XGMAC_PMA_DBG_INFO_REG			0x70C
+#define XGMAC_PMA_FEC_ABILITY_REG		0x740
+#define XGMAC_PMA_FEC_CONTROL_REG		0x744
+#define XGMAC_PMA_FEC_CORR_BLOCK_CNT__REG	0x750
+#define XGMAC_PMA_FEC_UNCORR_BLOCK_CNT__REG	0x760
+
+#define XGMAC_TX_PKTS_FRAGMENT			0x0000
+#define XGMAC_TX_PKTS_UNDERSIZE			0x0008
+#define XGMAC_TX_PKTS_UNDERMIN			0x0010
+#define XGMAC_TX_PKTS_64OCTETS			0x0018
+#define XGMAC_TX_PKTS_65TO127OCTETS		0x0020
+#define XGMAC_TX_PKTS_128TO255OCTETS		0x0028
+#define XGMAC_TX_PKTS_256TO511OCTETS		0x0030
+#define XGMAC_TX_PKTS_512TO1023OCTETS		0x0038
+#define XGMAC_TX_PKTS_1024TO1518OCTETS		0x0040
+#define XGMAC_TX_PKTS_1519TOMAXOCTETS		0x0048
+#define XGMAC_TX_PKTS_1519TOMAXOCTETSOK		0x0050
+#define XGMAC_TX_PKTS_OVERSIZE			0x0058
+#define XGMAC_TX_PKTS_JABBER			0x0060
+#define XGMAC_TX_GOODPKTS			0x0068
+#define XGMAC_TX_GOODOCTETS			0x0070
+#define XGMAC_TX_TOTAL_PKTS			0x0078
+#define XGMAC_TX_TOTALOCTETS			0x0080
+#define XGMAC_TX_UNICASTPKTS			0x0088
+#define XGMAC_TX_MULTICASTPKTS			0x0090
+#define XGMAC_TX_BROADCASTPKTS			0x0098
+#define XGMAC_TX_PRI0PAUSEPKTS			0x00a0
+#define XGMAC_TX_PRI1PAUSEPKTS			0x00a8
+#define XGMAC_TX_PRI2PAUSEPKTS			0x00b0
+#define XGMAC_TX_PRI3PAUSEPKTS			0x00b8
+#define XGMAC_TX_PRI4PAUSEPKTS			0x00c0
+#define XGMAC_TX_PRI5PAUSEPKTS			0x00c8
+#define XGMAC_TX_PRI6PAUSEPKTS			0x00d0
+#define XGMAC_TX_PRI7PAUSEPKTS			0x00d8
+#define XGMAC_TX_MACCTRLPKTS			0x00e0
+#define XGMAC_TX_1731PKTS			0x00e8
+#define XGMAC_TX_1588PKTS			0x00f0
+#define XGMAC_RX_FROMAPPGOODPKTS		0x00f8
+#define XGMAC_RX_FROMAPPBADPKTS			0x0100
+#define XGMAC_TX_ERRALLPKTS			0x0108
+
+#define XGMAC_RX_PKTS_FRAGMENT			0x0110
+#define XGMAC_RX_PKTSUNDERSIZE			0x0118
+#define XGMAC_RX_PKTS_UNDERMIN			0x0120
+#define XGMAC_RX_PKTS_64OCTETS			0x0128
+#define XGMAC_RX_PKTS_65TO127OCTETS		0x0130
+#define XGMAC_RX_PKTS_128TO255OCTETS		0x0138
+#define XGMAC_RX_PKTS_256TO511OCTETS		0x0140
+#define XGMAC_RX_PKTS_512TO1023OCTETS		0x0148
+#define XGMAC_RX_PKTS_1024TO1518OCTETS		0x0150
+#define XGMAC_RX_PKTS_1519TOMAXOCTETS		0x0158
+#define XGMAC_RX_PKTS_1519TOMAXOCTETSOK		0x0160
+#define XGMAC_RX_PKTS_OVERSIZE			0x0168
+#define XGMAC_RX_PKTS_JABBER			0x0170
+#define XGMAC_RX_GOODPKTS			0x0178
+#define XGMAC_RX_GOODOCTETS			0x0180
+#define XGMAC_RX_TOTAL_PKTS			0x0188
+#define XGMAC_RX_TOTALOCTETS			0x0190
+#define XGMAC_RX_UNICASTPKTS			0x0198
+#define XGMAC_RX_MULTICASTPKTS			0x01a0
+#define XGMAC_RX_BROADCASTPKTS			0x01a8
+#define XGMAC_RX_PRI0PAUSEPKTS			0x01b0
+#define XGMAC_RX_PRI1PAUSEPKTS			0x01b8
+#define XGMAC_RX_PRI2PAUSEPKTS			0x01c0
+#define XGMAC_RX_PRI3PAUSEPKTS			0x01c8
+#define XGMAC_RX_PRI4PAUSEPKTS			0x01d0
+#define XGMAC_RX_PRI5PAUSEPKTS			0x01d8
+#define XGMAC_RX_PRI6PAUSEPKTS			0x01e0
+#define XGMAC_RX_PRI7PAUSEPKTS			0x01e8
+#define XGMAC_RX_MACCTRLPKTS			0x01f0
+#define XGMAC_TX_SENDAPPGOODPKTS		0x01f8
+#define XGMAC_TX_SENDAPPBADPKTS			0x0200
+#define XGMAC_RX_1731PKTS			0x0208
+#define XGMAC_RX_SYMBOLERRPKTS			0x0210
+#define XGMAC_RX_FCSERRPKTS			0x0218
+
+#define XGMAC_TRX_CORE_SRST_M			0x2080
+
+#define DSAF_CFG_EN_S 0
+#define DSAF_CFG_TC_MODE_S 1
+#define DSAF_CFG_CRC_EN_S 2
+#define DSAF_CFG_SBM_INIT_S 3
+#define DSAF_CFG_MIX_MODE_S 4
+#define DSAF_CFG_STP_MODE_S 5
+#define DSAF_CFG_LOCA_ADDR_EN_S 6
+
+#define DSAF_CNT_CLR_CE_S 0
+#define DSAF_SNAP_EN_S 1
+
+#define HNS_DSAF_PFC_UNIT_CNT_FOR_XGE 41
+#define HNS_DSAF_PFC_UNIT_CNT_FOR_GE_1000 410
+#define HNS_DSAF_PFC_UNIT_CNT_FOR_GE_2500 103
+
+#define DSAF_PFC_UNINT_CNT_M ((1ULL << 9) - 1)
+#define DSAF_PFC_UNINT_CNT_S 0
+
+#define DSAF_PPE_QID_CFG_M 0xFF
+#define DSAF_PPE_QID_CFG_S 0
+
+#define DSAF_SW_PORT_TYPE_M 3
+#define DSAF_SW_PORT_TYPE_S 0
+
+#define DSAF_STP_PORT_TYPE_M 7
+#define DSAF_STP_PORT_TYPE_S 0
+
+#define DSAF_INODE_IN_PORT_NUM_M 7
+#define DSAF_INODE_IN_PORT_NUM_S 0
+
+#define HNS_DSAF_I4TC_CFG 0x18688688
+#define HNS_DSAF_I8TC_CFG 0x18FAC688
+
+#define DSAF_SBM_CFG_SHCUT_EN_S 0
+#define DSAF_SBM_CFG_EN_S 1
+#define DSAF_SBM_CFG_MIB_EN_S 2
+#define DSAF_SBM_CFG_ECC_INVERT_EN_S 3
+
+#define DSAF_SBM_CFG0_VC1_MAX_BUF_NUM_S 0
+#define DSAF_SBM_CFG0_VC1_MAX_BUF_NUM_M (((1ULL << 10) - 1) << 0)
+#define DSAF_SBM_CFG0_VC0_MAX_BUF_NUM_S 10
+#define DSAF_SBM_CFG0_VC0_MAX_BUF_NUM_M (((1ULL << 10) - 1) << 10)
+#define DSAF_SBM_CFG0_COM_MAX_BUF_NUM_S 20
+#define DSAF_SBM_CFG0_COM_MAX_BUF_NUM_M (((1ULL << 11) - 1) << 20)
+
+#define DSAF_SBM_CFG1_TC4_MAX_BUF_NUM_S 0
+#define DSAF_SBM_CFG1_TC4_MAX_BUF_NUM_M (((1ULL << 10) - 1) << 0)
+#define DSAF_SBM_CFG1_TC0_MAX_BUF_NUM_S 10
+#define DSAF_SBM_CFG1_TC0_MAX_BUF_NUM_M (((1ULL << 10) - 1) << 10)
+
+#define DSAF_SBM_CFG2_SET_BUF_NUM_S 0
+#define DSAF_SBM_CFG2_SET_BUF_NUM_M (((1ULL << 10) - 1) << 0)
+#define DSAF_SBM_CFG2_RESET_BUF_NUM_S 10
+#define DSAF_SBM_CFG2_RESET_BUF_NUM_M (((1ULL << 10) - 1) << 10)
+
+#define DSAF_SBM_CFG3_SET_BUF_NUM_NO_PFC_S 0
+#define DSAF_SBM_CFG3_SET_BUF_NUM_NO_PFC_M (((1ULL << 10) - 1) << 0)
+#define DSAF_SBM_CFG3_RESET_BUF_NUM_NO_PFC_S 10
+#define DSAF_SBM_CFG3_RESET_BUF_NUM_NO_PFC_M (((1ULL << 10) - 1) << 10)
+
+#define DSAF_TBL_TCAM_ADDR_S 0
+#define DSAF_TBL_TCAM_ADDR_M ((1ULL << 9) - 1)
+
+#define DSAF_TBL_LINE_ADDR_S 0
+#define DSAF_TBL_LINE_ADDR_M ((1ULL << 15) - 1)
+
+#define DSAF_TBL_MCAST_CFG4_VM128_112_S 0
+#define DSAF_TBL_MCAST_CFG4_VM128_112_M (((1ULL << 7) - 1) << 0)
+#define DSAF_TBL_MCAST_CFG4_ITEM_VLD_S 7
+#define DSAF_TBL_MCAST_CFG4_OLD_EN_S 8
+
+#define DSAF_TBL_MCAST_CFG0_XGE5_0_S 0
+#define DSAF_TBL_MCAST_CFG0_XGE5_0_M (((1ULL << 6) - 1) << 0)
+#define DSAF_TBL_MCAST_CFG0_VM25_0_S 6
+#define DSAF_TBL_MCAST_CFG0_VM25_0_M (((1ULL << 26) - 1) << 6)
+
+#define DSAF_TBL_UCAST_CFG1_OUT_PORT_S 0
+#define DSAF_TBL_UCAST_CFG1_OUT_PORT_M (((1ULL << 8) - 1) << 0)
+#define DSAF_TBL_UCAST_CFG1_DVC_S 8
+#define DSAF_TBL_UCAST_CFG1_MAC_DISCARD_S 9
+#define DSAF_TBL_UCAST_CFG1_ITEM_VLD_S 10
+#define DSAF_TBL_UCAST_CFG1_OLD_EN_S 11
+
+#define DSAF_TBL_LINE_CFG_OUT_PORT_S 0
+#define DSAF_TBL_LINE_CFG_OUT_PORT_M (((1ULL << 8) - 1) << 0)
+#define DSAF_TBL_LINE_CFG_DVC_S 8
+#define DSAF_TBL_LINE_CFG_MAC_DISCARD_S 9
+
+#define DSAF_TBL_PUL_OLD_RSLT_RE_S 0
+#define DSAF_TBL_PUL_MCAST_VLD_S 1
+#define DSAF_TBL_PUL_TCAM_DATA_VLD_S 2
+#define DSAF_TBL_PUL_UCAST_VLD_S 3
+#define DSAF_TBL_PUL_LINE_VLD_S 4
+#define DSAF_TBL_PUL_TCAM_LOAD_S 5
+#define DSAF_TBL_PUL_LINE_LOAD_S 6
+
+#define DSAF_TBL_DFX_LINE_LKUP_NUM_EN_S 0
+#define DSAF_TBL_DFX_UC_LKUP_NUM_EN_S 1
+#define DSAF_TBL_DFX_MC_LKUP_NUM_EN_S 2
+#define DSAF_TBL_DFX_BC_LKUP_NUM_EN_S 3
+#define DSAF_TBL_DFX_RAM_ERR_INJECT_EN_S 4
+
+#define DSAF_VOQ_BP_ALL_DOWNTHRD_S 0
+#define DSAF_VOQ_BP_ALL_DOWNTHRD_M (((1ULL << 10) - 1) << 0)
+#define DSAF_VOQ_BP_ALL_UPTHRD_S 10
+#define DSAF_VOQ_BP_ALL_UPTHRD_M (((1ULL << 10) - 1) << 10)
+
+#define DSAF_XGE_GE_WORK_MODE_S 0
+#define DSAF_XGE_GE_LOOPBACK_S 1
+
+#define DSAF_FC_XGE_TX_PAUSE_S 0
+#define DSAF_REGS_XGE_CNT_CAR_S 1
+
+#define PPE_CFG_QID_MODE_DEF_QID_S	0
+#define PPE_CFG_QID_MODE_DEF_QID_M	(0xff << PPE_CFG_QID_MODE_DEF_QID_S)
+
+#define PPE_CFG_QID_MODE_CF_QID_MODE_S	8
+#define PPE_CFG_QID_MODE_CF_QID_MODE_M	(0x7 << PPE_CFG_QID_MODE_CF_QID_MODE_S)
+
+#define PPE_CNT_CLR_CE_B	0
+#define PPE_CNT_CLR_SNAP_EN_B	1
+
+#define PPE_COMMON_CNT_CLR_CE_B	0
+#define PPE_COMMON_CNT_CLR_SNAP_EN_B	1
+
+#define GMAC_DUPLEX_TYPE_B 0
+
+#define GMAC_FC_TX_TIMER_S 0
+#define GMAC_FC_TX_TIMER_M 0xffff
+
+#define GMAC_MAX_FRM_SIZE_S 0
+#define GMAC_MAX_FRM_SIZE_M 0xffff
+
+#define GMAC_PORT_MODE_S	0
+#define GMAC_PORT_MODE_M	0xf
+
+#define GMAC_RGMII_1000M_DELAY_B	4
+#define GMAC_MII_TX_EDGE_SEL_B		5
+#define GMAC_FIFO_ERR_AUTO_RST_B	6
+#define GMAC_DBG_CLK_LOS_MSK_B		7
+
+#define GMAC_PORT_RX_EN_B	1
+#define GMAC_PORT_TX_EN_B	2
+
+#define GMAC_PAUSE_EN_RX_FDFC_B 0
+#define GMAC_PAUSE_EN_TX_FDFC_B 1
+#define GMAC_PAUSE_EN_TX_HDFC_B 2
+
+#define GMAC_SHORT_RUNTS_THR_S 0
+#define GMAC_SHORT_RUNTS_THR_M 0x1f
+
+#define GMAC_AN_NEG_STAT_FD_B		5
+#define GMAC_AN_NEG_STAT_HD_B		6
+#define GMAC_AN_NEG_STAT_RF1_DUPLIEX_B	12
+#define GMAC_AN_NEG_STAT_RF2_B		13
+
+#define GMAC_AN_NEG_STAT_NP_LNK_OK_B	15
+#define GMAC_AN_NEG_STAT_RX_SYNC_OK_B	20
+#define GMAC_AN_NEG_STAT_AN_DONE_B	21
+
+#define GMAC_AN_NEG_STAT_PS_S		7
+#define GMAC_AN_NEG_STAT_PS_M		(0x3 << GMAC_AN_NEG_STAT_PS_S)
+
+#define GMAC_AN_NEG_STAT_SPEED_S	10
+#define GMAC_AN_NEG_STAT_SPEED_M	(0x3 << GMAC_AN_NEG_STAT_SPEED_S)
+
+#define GMAC_TX_AN_EN_B		5
+#define GMAC_TX_CRC_ADD_B	6
+#define GMAC_TX_PAD_EN_B	7
+
+#define GMAC_LINE_LOOPBACK_B	0
+
+#define GMAC_LP_REG_CF_EXT_DRV_LP_B	1
+#define GMAC_LP_REG_CF2MI_LP_EN_B	2
+
+#define GMAC_MODE_CHANGE_EB_B	0
+
+#define GMAC_RECV_CTRL_STRIP_PAD_EN_B	3
+#define GMAC_RECV_CTRL_RUNT_PKT_EN_B	4
+
+#define GMAC_TX_LOOP_PKT_HIG_PRI_B	0
+#define GMAC_TX_LOOP_PKT_EN_B		1
+
+#define XGMAC_PORT_MODE_TX_S		0x0
+#define XGMAC_PORT_MODE_TX_M		(0x3 << XGMAC_PORT_MODE_TX_S)
+#define XGMAC_PORT_MODE_TX_40G_B	0x3
+#define XGMAC_PORT_MODE_RX_S		0x4
+#define XGMAC_PORT_MODE_RX_M		(0x3 << XGMAC_PORT_MODE_RX_S)
+#define XGMAC_PORT_MODE_RX_40G_B	0x7
+
+#define XGMAC_ENABLE_TX_B		0
+#define XGMAC_ENABLE_RX_B		1
+
+#define XGMAC_CTL_TX_FCS_B		0
+#define XGMAC_CTL_TX_PAD_B		1
+#define XGMAC_CTL_TX_PREAMBLE_TRANS_B	3
+#define XGMAC_CTL_TX_UNDER_MIN_ERR_B	4
+#define XGMAC_CTL_TX_TRUNCATE_B		5
+#define XGMAC_CTL_TX_1588_B		8
+#define XGMAC_CTL_TX_1731_B		9
+#define XGMAC_CTL_TX_PFC_B		10
+#define XGMAC_CTL_RX_FCS_B		16
+#define XGMAC_CTL_RX_FCS_STRIP_B	17
+#define XGMAC_CTL_RX_PREAMBLE_TRANS_B	19
+#define XGMAC_CTL_RX_UNDER_MIN_ERR_B	20
+#define XGMAC_CTL_RX_TRUNCATE_B		21
+#define XGMAC_CTL_RX_1588_B		24
+#define XGMAC_CTL_RX_1731_B		25
+#define XGMAC_CTL_RX_PFC_B		26
+
+#define XGMAC_PMA_FEC_CTL_TX_B		0
+#define XGMAC_PMA_FEC_CTL_RX_B		1
+#define XGMAC_PMA_FEC_CTL_ERR_EN	2
+#define XGMAC_PMA_FEC_CTL_ERR_SH	3
+
+#define XGMAC_PAUSE_CTL_TX_B		0
+#define XGMAC_PAUSE_CTL_RX_B		1
+#define XGMAC_PAUSE_CTL_RSP_MODE_B	2
+#define XGMAC_PAUSE_CTL_TX_XOFF_B	3
+
+static inline void dsaf_write_reg(void *base, u32 reg, u32 value)
+{
+	u8 __iomem *reg_addr = ACCESS_ONCE(base);
+
+	writel(value, reg_addr + reg);
+}
+
+#define dsaf_write_dev(a, reg, value) \
+	dsaf_write_reg((a)->io_base, (reg), (value))
+
+static inline u32 dsaf_read_reg(u8 *base, u32 reg)
+{
+	u8 __iomem *reg_addr = ACCESS_ONCE(base);
+
+	return readl(reg_addr + reg);
+}
+
+#define dsaf_read_dev(a, reg) \
+	dsaf_read_reg((a)->io_base, (reg))
+
+#define dsaf_set_field(origin, mask, shift, val) \
+	do { \
+		(origin) &= (~(mask)); \
+		(origin) |= (((val) << (shift)) & (mask)); \
+	} while (0)
+
+#define dsaf_set_bit(origin, shift, val) \
+	dsaf_set_field((origin), (1ull << (shift)), (shift), (val))
+
+static inline void dsaf_set_reg_field(void *base, u32 reg, u32 mask, u32 shift,
+				      u32 val)
+{
+	u32 origin = dsaf_read_reg(base, reg);
+
+	dsaf_set_field(origin, mask, shift, val);
+	dsaf_write_reg(base, reg, origin);
+}
+
+#define dsaf_set_dev_field(dev, reg, mask, shift, val) \
+	dsaf_set_reg_field((dev)->io_base, (reg), (mask), (shift), (val))
+
+#define dsaf_set_dev_bit(dev, reg, bit, val) \
+	dsaf_set_reg_field((dev)->io_base, (reg), (1ull << (bit)), (bit), (val))
+
+#define dsaf_get_field(origin, mask, shift) (((origin) & (mask)) >> (shift))
+
+#define dsaf_get_bit(origin, shift) \
+	dsaf_get_field((origin), (1ull << (shift)), (shift))
+
+static inline u32 dsaf_get_reg_field(void *base, u32 reg, u32 mask, u32 shift)
+{
+	u32 origin;
+
+	origin = dsaf_read_reg(base, reg);
+	return dsaf_get_field(origin, mask, shift);
+}
+
+#define dsaf_get_dev_field(dev, reg, mask, shift) \
+	dsaf_get_reg_field((dev)->io_base, (reg), (mask), (shift))
+
+#define dsaf_get_dev_bit(dev, reg, bit) \
+	dsaf_get_reg_field((dev)->io_base, (reg), (1ull << (bit)), (bit))
+
+#define dsaf_write_b(addr, data)\
+	writeb((data), (__iomem unsigned char *)(addr))
+#define dsaf_read_b(addr)\
+	readb((__iomem unsigned char *)(addr))
+
+#define hns_mac_reg_read64(drv, offset) \
+	readq((__iomem void *)(((u64)(drv)->io_base + 0xc00 + (offset))))
+
+#endif	/* _DSAF_REG_H */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
new file mode 100644
index 0000000..fe7fa1d
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
@@ -0,0 +1,836 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/of_mdio.h>
+#include "hns_dsaf_main.h"
+#include "hns_dsaf_mac.h"
+#include "hns_dsaf_xgmac.h"
+#include "hns_dsaf_reg.h"
+
+static const struct mac_stats_string g_xgmac_stats_string[] = {
+	{"xgmac_tx_bad_pkts_minto64", MAC_STATS_FIELD_OFF(tx_fragment_err)},
+	{"xgmac_tx_good_pkts_minto64", MAC_STATS_FIELD_OFF(tx_undersize)},
+	{"xgmac_tx_total_pkts_minto64",	MAC_STATS_FIELD_OFF(tx_under_min_pkts)},
+	{"xgmac_tx_pkts_64", MAC_STATS_FIELD_OFF(tx_64bytes)},
+	{"xgmac_tx_pkts_65to127", MAC_STATS_FIELD_OFF(tx_65to127)},
+	{"xgmac_tx_pkts_128to255", MAC_STATS_FIELD_OFF(tx_128to255)},
+	{"xgmac_tx_pkts_256to511", MAC_STATS_FIELD_OFF(tx_256to511)},
+	{"xgmac_tx_pkts_512to1023", MAC_STATS_FIELD_OFF(tx_512to1023)},
+	{"xgmac_tx_pkts_1024to1518", MAC_STATS_FIELD_OFF(tx_1024to1518)},
+	{"xgmac_tx_pkts_1519tomax", MAC_STATS_FIELD_OFF(tx_1519tomax)},
+	{"xgmac_tx_good_pkts_1519tomax",
+		MAC_STATS_FIELD_OFF(tx_1519tomax_good)},
+	{"xgmac_tx_good_pkts_untralmax", MAC_STATS_FIELD_OFF(tx_oversize)},
+	{"xgmac_tx_bad_pkts_untralmax", MAC_STATS_FIELD_OFF(tx_jabber_err)},
+	{"xgmac_tx_good_pkts_all", MAC_STATS_FIELD_OFF(tx_good_pkts)},
+	{"xgmac_tx_good_byte_all", MAC_STATS_FIELD_OFF(tx_good_bytes)},
+	{"xgmac_tx_total_pkt", MAC_STATS_FIELD_OFF(tx_total_pkts)},
+	{"xgmac_tx_total_byt", MAC_STATS_FIELD_OFF(tx_total_bytes)},
+	{"xgmac_tx_uc_pkt", MAC_STATS_FIELD_OFF(tx_uc_pkts)},
+	{"xgmac_tx_mc_pkt", MAC_STATS_FIELD_OFF(tx_mc_pkts)},
+	{"xgmac_tx_bc_pkt", MAC_STATS_FIELD_OFF(tx_bc_pkts)},
+	{"xgmac_tx_pause_frame_num", MAC_STATS_FIELD_OFF(tx_pfc_tc0)},
+	{"xgmac_tx_pfc_per_1pause_framer", MAC_STATS_FIELD_OFF(tx_pfc_tc1)},
+	{"xgmac_tx_pfc_per_2pause_framer", MAC_STATS_FIELD_OFF(tx_pfc_tc2)},
+	{"xgmac_tx_pfc_per_3pause_framer", MAC_STATS_FIELD_OFF(tx_pfc_tc3)},
+	{"xgmac_tx_pfc_per_4pause_framer", MAC_STATS_FIELD_OFF(tx_pfc_tc4)},
+	{"xgmac_tx_pfc_per_5pause_framer", MAC_STATS_FIELD_OFF(tx_pfc_tc5)},
+	{"xgmac_tx_pfc_per_6pause_framer", MAC_STATS_FIELD_OFF(tx_pfc_tc6)},
+	{"xgmac_tx_pfc_per_7pause_framer", MAC_STATS_FIELD_OFF(tx_pfc_tc7)},
+	{"xgmac_tx_mac_ctrol_frame", MAC_STATS_FIELD_OFF(tx_ctrl)},
+	{"xgmac_tx_1731_pkts", MAC_STATS_FIELD_OFF(tx_1731_pkts)},
+	{"xgmac_tx_1588_pkts", MAC_STATS_FIELD_OFF(tx_1588_pkts)},
+	{"xgmac_rx_good_pkt_from_dsaf", MAC_STATS_FIELD_OFF(rx_good_from_sw)},
+	{"xgmac_rx_bad_pkt_from_dsaf", MAC_STATS_FIELD_OFF(rx_bad_from_sw)},
+	{"xgmac_tx_bad_pkt_64tomax", MAC_STATS_FIELD_OFF(tx_bad_pkts)},
+
+	{"xgmac_rx_not_well_pkt", MAC_STATS_FIELD_OFF(rx_fragment_err)},
+	{"xgmac_rx_good_well_pkt", MAC_STATS_FIELD_OFF(rx_undersize)},
+	{"xgmac_rx_total_pkt", MAC_STATS_FIELD_OFF(rx_under_min)},
+	{"xgmac_rx_pkt_64", MAC_STATS_FIELD_OFF(rx_64bytes)},
+	{"xgmac_rx_pkt_65to127", MAC_STATS_FIELD_OFF(rx_65to127)},
+	{"xgmac_rx_pkt_128to255", MAC_STATS_FIELD_OFF(rx_128to255)},
+	{"xgmac_rx_pkt_256to511", MAC_STATS_FIELD_OFF(rx_256to511)},
+	{"xgmac_rx_pkt_512to1023", MAC_STATS_FIELD_OFF(rx_512to1023)},
+	{"xgmac_rx_pkt_1024to1518", MAC_STATS_FIELD_OFF(rx_1024to1518)},
+	{"xgmac_rx_pkt_1519tomax", MAC_STATS_FIELD_OFF(rx_1519tomax)},
+	{"xgmac_rx_good_pkt_1519tomax",	MAC_STATS_FIELD_OFF(rx_1519tomax_good)},
+	{"xgmac_rx_good_pkt_untramax", MAC_STATS_FIELD_OFF(rx_oversize)},
+	{"xgmac_rx_bad_pkt_untramax", MAC_STATS_FIELD_OFF(rx_jabber_err)},
+	{"xgmac_rx_good_pkt", MAC_STATS_FIELD_OFF(rx_good_pkts)},
+	{"xgmac_rx_good_byt", MAC_STATS_FIELD_OFF(rx_good_bytes)},
+	{"xgmac_rx_pkt", MAC_STATS_FIELD_OFF(rx_total_pkts)},
+	{"xgmac_rx_byt", MAC_STATS_FIELD_OFF(rx_total_bytes)},
+	{"xgmac_rx_uc_pkt", MAC_STATS_FIELD_OFF(rx_uc_pkts)},
+	{"xgmac_rx_mc_pkt", MAC_STATS_FIELD_OFF(rx_mc_pkts)},
+	{"xgmac_rx_bc_pkt", MAC_STATS_FIELD_OFF(rx_bc_pkts)},
+	{"xgmac_rx_pause_frame_num", MAC_STATS_FIELD_OFF(rx_pfc_tc0)},
+	{"xgmac_rx_pfc_per_1pause_frame", MAC_STATS_FIELD_OFF(rx_pfc_tc1)},
+	{"xgmac_rx_pfc_per_2pause_frame", MAC_STATS_FIELD_OFF(rx_pfc_tc2)},
+	{"xgmac_rx_pfc_per_3pause_frame", MAC_STATS_FIELD_OFF(rx_pfc_tc3)},
+	{"xgmac_rx_pfc_per_4pause_frame", MAC_STATS_FIELD_OFF(rx_pfc_tc4)},
+	{"xgmac_rx_pfc_per_5pause_frame", MAC_STATS_FIELD_OFF(rx_pfc_tc5)},
+	{"xgmac_rx_pfc_per_6pause_frame", MAC_STATS_FIELD_OFF(rx_pfc_tc6)},
+	{"xgmac_rx_pfc_per_7pause_frame", MAC_STATS_FIELD_OFF(rx_pfc_tc7)},
+	{"xgmac_rx_mac_control", MAC_STATS_FIELD_OFF(rx_unknown_ctrl)},
+	{"xgmac_tx_good_pkt_todsaf", MAC_STATS_FIELD_OFF(tx_good_to_sw)},
+	{"xgmac_tx_bad_pkt_todsaf", MAC_STATS_FIELD_OFF(tx_bad_to_sw)},
+	{"xgmac_rx_1731_pkt", MAC_STATS_FIELD_OFF(rx_1731_pkts)},
+	{"xgmac_rx_symbol_err_pkt", MAC_STATS_FIELD_OFF(rx_symbol_err)},
+	{"xgmac_rx_fcs_pkt", MAC_STATS_FIELD_OFF(rx_fcs_err)}
+};
+
+/**
+ *hns_xgmac_tx_enable - xgmac port tx enable
+ *@drv: mac driver
+ *@value: value of enable
+ */
+static void hns_xgmac_tx_enable(struct mac_driver *drv, u32 value)
+{
+	dsaf_set_dev_bit(drv, XGMAC_MAC_ENABLE_REG, XGMAC_ENABLE_TX_B, !!value);
+}
+
+/**
+ *hns_xgmac_rx_enable - xgmac port rx enable
+ *@drv: mac driver
+ *@value: value of enable
+ */
+static void hns_xgmac_rx_enable(struct mac_driver *drv, u32 value)
+{
+	dsaf_set_dev_bit(drv, XGMAC_MAC_ENABLE_REG, XGMAC_ENABLE_RX_B, !!value);
+}
+
+/**
+ *hns_xgmac_enable - enable xgmac port
+ *@drv: mac driver
+ *@mode: mode of mac port
+ */
+static void hns_xgmac_enable(void *mac_drv, enum mac_commom_mode mode)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	struct dsaf_device *dsaf_dev
+		= (struct dsaf_device *)dev_get_drvdata(drv->dev);
+	u32 port = drv->mac_id;
+
+	hns_dsaf_xge_core_srst_by_port(dsaf_dev, port, 1);
+	mdelay(10);
+
+	/*enable XGE rX/tX */
+	if (mode == MAC_COMM_MODE_TX) {
+		hns_xgmac_tx_enable(drv, 1);
+	} else if (mode == MAC_COMM_MODE_RX) {
+		hns_xgmac_rx_enable(drv, 1);
+	} else if (mode == MAC_COMM_MODE_RX_AND_TX) {
+		hns_xgmac_tx_enable(drv, 1);
+		hns_xgmac_rx_enable(drv, 1);
+	} else {
+		dev_err(drv->dev, "error mac mode:%d\n", mode);
+	}
+}
+
+/**
+ *hns_xgmac_disable - disable xgmac port
+ *@mac_drv: mac driver
+ *@mode: mode of mac port
+ */
+static void hns_xgmac_disable(void *mac_drv, enum mac_commom_mode mode)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	struct dsaf_device *dsaf_dev
+		= (struct dsaf_device *)dev_get_drvdata(drv->dev);
+	u32 port = drv->mac_id;
+
+	if (mode == MAC_COMM_MODE_TX) {
+		hns_xgmac_tx_enable(drv, 0);
+	} else if (mode == MAC_COMM_MODE_RX) {
+		hns_xgmac_rx_enable(drv, 0);
+	} else if (mode == MAC_COMM_MODE_RX_AND_TX) {
+		hns_xgmac_tx_enable(drv, 0);
+		hns_xgmac_rx_enable(drv, 0);
+	}
+
+	mdelay(10);
+	hns_dsaf_xge_core_srst_by_port(dsaf_dev, port, 0);
+}
+
+/**
+ *hns_xgmac_pma_fec_enable - xgmac PMA FEC enable
+ *@drv: mac driver
+ *@tx_value: tx value
+ *@rx_value: rx value
+ *return status
+ */
+static void hns_xgmac_pma_fec_enable(struct mac_driver *drv, u32 tx_value,
+				     u32 rx_value)
+{
+	u32 origin = dsaf_read_dev(drv, XGMAC_PMA_FEC_CONTROL_REG);
+
+	dsaf_set_bit(origin, XGMAC_PMA_FEC_CTL_TX_B, !!tx_value);
+	dsaf_set_bit(origin, XGMAC_PMA_FEC_CTL_RX_B, !!rx_value);
+	dsaf_write_dev(drv, XGMAC_PMA_FEC_CONTROL_REG, origin);
+}
+
+/* clr exc irq for xge*/
+static void hns_xgmac_exc_irq_en(struct mac_driver *drv, u32 en)
+{
+	u32 clr_vlue = 0xfffffffful;
+	u32 msk_vlue = en ? 0xfffffffful : 0; /*1 is en, 0 is dis*/
+
+	dsaf_write_dev(drv, XGMAC_INT_STATUS_REG, clr_vlue);
+	dsaf_write_dev(drv, XGMAC_INT_ENABLE_REG, msk_vlue);
+}
+
+/**
+ *hns_xgmac_init - initialize XGE
+ *@mac_drv: mac driver
+ */
+static void hns_xgmac_init(void *mac_drv)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	struct dsaf_device *dsaf_dev
+		= (struct dsaf_device *)dev_get_drvdata(drv->dev);
+	u32 port = drv->mac_id;
+
+	hns_dsaf_xge_srst_by_port(dsaf_dev, port, 0);
+	mdelay(100);
+	hns_dsaf_xge_srst_by_port(dsaf_dev, port, 1);
+
+	mdelay(100);
+	hns_xgmac_exc_irq_en(drv, 0);
+
+	hns_xgmac_pma_fec_enable(drv, 0x0, 0x0);
+
+	hns_xgmac_disable(mac_drv, MAC_COMM_MODE_RX_AND_TX);
+}
+
+/**
+ *hns_xgmac_config_pad_and_crc - set xgmac pad and crc enable the same time
+ *@mac_drv: mac driver
+ *@newval:enable of pad and crc
+ */
+static void hns_xgmac_config_pad_and_crc(void *mac_drv, u8 newval)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	u32 origin = dsaf_read_dev(drv, XGMAC_MAC_CONTROL_REG);
+
+	dsaf_set_bit(origin, XGMAC_CTL_TX_PAD_B, !!newval);
+	dsaf_set_bit(origin, XGMAC_CTL_TX_FCS_B, !!newval);
+	dsaf_set_bit(origin, XGMAC_CTL_RX_FCS_B, !!newval);
+	dsaf_write_dev(drv, XGMAC_MAC_CONTROL_REG, origin);
+}
+
+/**
+ *hns_xgmac_pausefrm_cfg - set pause param about xgmac
+ *@mac_drv: mac driver
+ *@newval:enable of pad and crc
+ */
+static void hns_xgmac_pausefrm_cfg(void *mac_drv, u32 rx_en, u32 tx_en)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	u32 origin = dsaf_read_dev(drv, XGMAC_MAC_PAUSE_CTRL_REG);
+
+	dsaf_set_bit(origin, XGMAC_PAUSE_CTL_TX_B, !!tx_en);
+	dsaf_set_bit(origin, XGMAC_PAUSE_CTL_RX_B, !!rx_en);
+	dsaf_write_dev(drv, XGMAC_MAC_PAUSE_CTRL_REG, origin);
+}
+
+static void hns_xgmac_set_pausefrm_mac_addr(void *mac_drv, char *mac_addr)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	u32 high_val = mac_addr[1] | (mac_addr[0] << 8);
+	u32 low_val = mac_addr[5] | (mac_addr[4] << 8)
+		| (mac_addr[3] << 16) | (mac_addr[2] << 24);
+	dsaf_write_dev(drv, XGMAC_MAC_PAUSE_LOCAL_MAC_L_REG, low_val);
+	dsaf_write_dev(drv, XGMAC_MAC_PAUSE_LOCAL_MAC_H_REG, high_val);
+}
+
+/**
+ *hns_xgmac_set_rx_ignore_pause_frames - set rx pause param about xgmac
+ *@mac_drv: mac driver
+ *@enable:enable rx pause param
+ */
+static void hns_xgmac_set_rx_ignore_pause_frames(void *mac_drv, u32 enable)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	dsaf_set_dev_bit(drv, XGMAC_MAC_PAUSE_CTRL_REG,
+			 XGMAC_PAUSE_CTL_RX_B, !!enable);
+}
+
+/**
+ *hns_xgmac_set_tx_auto_pause_frames - set tx pause param about xgmac
+ *@mac_drv: mac driver
+ *@enable:enable tx pause param
+ */
+static void hns_xgmac_set_tx_auto_pause_frames(void *mac_drv, u16 enable)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	dsaf_set_dev_bit(drv, XGMAC_MAC_PAUSE_CTRL_REG,
+			 XGMAC_PAUSE_CTL_TX_B, !!enable);
+
+	/*if enable is not zero ,set tx pause time */
+	if (enable)
+		dsaf_write_dev(drv, XGMAC_MAC_PAUSE_TIME_REG, enable);
+}
+
+/**
+ *hns_xgmac_get_id - get xgmac port id
+ *@mac_drv: mac driver
+ *@newval:xgmac max frame length
+ */
+static void hns_xgmac_get_id(void *mac_drv, u8 *mac_id)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	*mac_id = drv->mac_id;
+}
+
+/**
+ *hns_xgmac_config_max_frame_length - set xgmac max frame length
+ *@mac_drv: mac driver
+ *@newval:xgmac max frame length
+ */
+static void hns_xgmac_config_max_frame_length(void *mac_drv, u16 newval)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	dsaf_write_dev(drv, XGMAC_MAC_MAX_PKT_SIZE_REG, newval);
+}
+
+void hns_xgmac_update_stats(void *mac_drv)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	struct mac_hw_stats *hw_stats = &drv->mac_cb->hw_stats;
+
+	/* TX */
+	hw_stats->tx_fragment_err
+		= hns_mac_reg_read64(drv, XGMAC_TX_PKTS_FRAGMENT);
+	hw_stats->tx_undersize
+		= hns_mac_reg_read64(drv, XGMAC_TX_PKTS_UNDERSIZE);
+	hw_stats->tx_under_min_pkts
+		= hns_mac_reg_read64(drv, XGMAC_TX_PKTS_UNDERMIN);
+	hw_stats->tx_64bytes = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_64OCTETS);
+	hw_stats->tx_65to127
+		= hns_mac_reg_read64(drv, XGMAC_TX_PKTS_65TO127OCTETS);
+	hw_stats->tx_128to255
+		= hns_mac_reg_read64(drv, XGMAC_TX_PKTS_128TO255OCTETS);
+	hw_stats->tx_256to511
+		= hns_mac_reg_read64(drv, XGMAC_TX_PKTS_256TO511OCTETS);
+	hw_stats->tx_512to1023
+		= hns_mac_reg_read64(drv, XGMAC_TX_PKTS_512TO1023OCTETS);
+	hw_stats->tx_1024to1518
+		= hns_mac_reg_read64(drv, XGMAC_TX_PKTS_1024TO1518OCTETS);
+	hw_stats->tx_1519tomax
+		= hns_mac_reg_read64(drv, XGMAC_TX_PKTS_1519TOMAXOCTETS);
+	hw_stats->tx_1519tomax_good
+		= hns_mac_reg_read64(drv, XGMAC_TX_PKTS_1519TOMAXOCTETSOK);
+	hw_stats->tx_oversize = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_OVERSIZE);
+	hw_stats->tx_jabber_err = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_JABBER);
+	hw_stats->tx_good_pkts = hns_mac_reg_read64(drv, XGMAC_TX_GOODPKTS);
+	hw_stats->tx_good_bytes = hns_mac_reg_read64(drv, XGMAC_TX_GOODOCTETS);
+	hw_stats->tx_total_pkts = hns_mac_reg_read64(drv, XGMAC_TX_TOTAL_PKTS);
+	hw_stats->tx_total_bytes
+		= hns_mac_reg_read64(drv, XGMAC_TX_TOTALOCTETS);
+	hw_stats->tx_uc_pkts = hns_mac_reg_read64(drv, XGMAC_TX_UNICASTPKTS);
+	hw_stats->tx_mc_pkts = hns_mac_reg_read64(drv, XGMAC_TX_MULTICASTPKTS);
+	hw_stats->tx_bc_pkts = hns_mac_reg_read64(drv, XGMAC_TX_BROADCASTPKTS);
+	hw_stats->tx_pfc_tc0 = hns_mac_reg_read64(drv, XGMAC_TX_PRI0PAUSEPKTS);
+	hw_stats->tx_pfc_tc1 = hns_mac_reg_read64(drv, XGMAC_TX_PRI1PAUSEPKTS);
+	hw_stats->tx_pfc_tc2 = hns_mac_reg_read64(drv, XGMAC_TX_PRI2PAUSEPKTS);
+	hw_stats->tx_pfc_tc3 = hns_mac_reg_read64(drv, XGMAC_TX_PRI3PAUSEPKTS);
+	hw_stats->tx_pfc_tc4 = hns_mac_reg_read64(drv, XGMAC_TX_PRI4PAUSEPKTS);
+	hw_stats->tx_pfc_tc5 = hns_mac_reg_read64(drv, XGMAC_TX_PRI5PAUSEPKTS);
+	hw_stats->tx_pfc_tc6 = hns_mac_reg_read64(drv, XGMAC_TX_PRI6PAUSEPKTS);
+	hw_stats->tx_pfc_tc7 = hns_mac_reg_read64(drv, XGMAC_TX_PRI7PAUSEPKTS);
+	hw_stats->tx_ctrl = hns_mac_reg_read64(drv, XGMAC_TX_MACCTRLPKTS);
+	hw_stats->tx_1731_pkts = hns_mac_reg_read64(drv, XGMAC_TX_1731PKTS);
+	hw_stats->tx_1588_pkts = hns_mac_reg_read64(drv, XGMAC_TX_1588PKTS);
+	hw_stats->rx_good_from_sw
+		= hns_mac_reg_read64(drv, XGMAC_RX_FROMAPPGOODPKTS);
+	hw_stats->rx_bad_from_sw
+		= hns_mac_reg_read64(drv, XGMAC_RX_FROMAPPBADPKTS);
+	hw_stats->tx_bad_pkts = hns_mac_reg_read64(drv, XGMAC_TX_ERRALLPKTS);
+
+	/* RX */
+	hw_stats->rx_fragment_err
+		= hns_mac_reg_read64(drv, XGMAC_RX_PKTS_FRAGMENT);
+	hw_stats->rx_undersize
+		= hns_mac_reg_read64(drv, XGMAC_RX_PKTSUNDERSIZE);
+	hw_stats->rx_under_min
+		= hns_mac_reg_read64(drv, XGMAC_RX_PKTS_UNDERMIN);
+	hw_stats->rx_64bytes = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_64OCTETS);
+	hw_stats->rx_65to127
+		= hns_mac_reg_read64(drv, XGMAC_RX_PKTS_65TO127OCTETS);
+	hw_stats->rx_128to255
+		= hns_mac_reg_read64(drv, XGMAC_RX_PKTS_128TO255OCTETS);
+	hw_stats->rx_256to511
+		= hns_mac_reg_read64(drv, XGMAC_RX_PKTS_256TO511OCTETS);
+	hw_stats->rx_512to1023
+		= hns_mac_reg_read64(drv, XGMAC_RX_PKTS_512TO1023OCTETS);
+	hw_stats->rx_1024to1518
+		= hns_mac_reg_read64(drv, XGMAC_RX_PKTS_1024TO1518OCTETS);
+	hw_stats->rx_1519tomax
+		= hns_mac_reg_read64(drv, XGMAC_RX_PKTS_1519TOMAXOCTETS);
+	hw_stats->rx_1519tomax_good
+		= hns_mac_reg_read64(drv, XGMAC_RX_PKTS_1519TOMAXOCTETSOK);
+	hw_stats->rx_oversize = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_OVERSIZE);
+	hw_stats->rx_jabber_err = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_JABBER);
+	hw_stats->rx_good_pkts = hns_mac_reg_read64(drv, XGMAC_RX_GOODPKTS);
+	hw_stats->rx_good_bytes = hns_mac_reg_read64(drv, XGMAC_RX_GOODOCTETS);
+	hw_stats->rx_total_pkts = hns_mac_reg_read64(drv, XGMAC_RX_TOTAL_PKTS);
+	hw_stats->rx_total_bytes
+		= hns_mac_reg_read64(drv, XGMAC_RX_TOTALOCTETS);
+	hw_stats->rx_uc_pkts = hns_mac_reg_read64(drv, XGMAC_RX_UNICASTPKTS);
+	hw_stats->rx_mc_pkts = hns_mac_reg_read64(drv, XGMAC_RX_MULTICASTPKTS);
+	hw_stats->rx_bc_pkts = hns_mac_reg_read64(drv, XGMAC_RX_BROADCASTPKTS);
+	hw_stats->rx_pfc_tc0 = hns_mac_reg_read64(drv, XGMAC_RX_PRI0PAUSEPKTS);
+	hw_stats->rx_pfc_tc1 = hns_mac_reg_read64(drv, XGMAC_RX_PRI1PAUSEPKTS);
+	hw_stats->rx_pfc_tc2 = hns_mac_reg_read64(drv, XGMAC_RX_PRI2PAUSEPKTS);
+	hw_stats->rx_pfc_tc3 = hns_mac_reg_read64(drv, XGMAC_RX_PRI3PAUSEPKTS);
+	hw_stats->rx_pfc_tc4 = hns_mac_reg_read64(drv, XGMAC_RX_PRI4PAUSEPKTS);
+	hw_stats->rx_pfc_tc5 = hns_mac_reg_read64(drv, XGMAC_RX_PRI5PAUSEPKTS);
+	hw_stats->rx_pfc_tc6 = hns_mac_reg_read64(drv, XGMAC_RX_PRI6PAUSEPKTS);
+	hw_stats->rx_pfc_tc7 = hns_mac_reg_read64(drv, XGMAC_RX_PRI7PAUSEPKTS);
+
+	hw_stats->rx_unknown_ctrl
+		= hns_mac_reg_read64(drv, XGMAC_RX_MACCTRLPKTS);
+	hw_stats->tx_good_to_sw
+		= hns_mac_reg_read64(drv, XGMAC_TX_SENDAPPGOODPKTS);
+	hw_stats->tx_bad_to_sw
+		= hns_mac_reg_read64(drv, XGMAC_TX_SENDAPPBADPKTS);
+	hw_stats->rx_1731_pkts = hns_mac_reg_read64(drv, XGMAC_RX_1731PKTS);
+	hw_stats->rx_symbol_err
+		= hns_mac_reg_read64(drv, XGMAC_RX_SYMBOLERRPKTS);
+	hw_stats->rx_fcs_err = hns_mac_reg_read64(drv, XGMAC_RX_FCSERRPKTS);
+}
+
+/**
+ *hns_xgmac_free - free xgmac driver
+ *@mac_drv: mac driver
+ */
+static void hns_xgmac_free(void *mac_drv)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	struct dsaf_device *dsaf_dev
+		= (struct dsaf_device *)dev_get_drvdata(drv->dev);
+
+	u32 mac_id = drv->mac_id;
+
+	hns_dsaf_xge_srst_by_port(dsaf_dev, mac_id, 0);
+}
+
+/**
+ *hns_xgmac_get_info - get xgmac information
+ *@mac_drv: mac driver
+ *@mac_info:mac information
+ */
+static void hns_xgmac_get_info(void *mac_drv, struct mac_info *mac_info)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	u32 pause_time, pause_ctrl, port_mode, ctrl_val;
+
+	ctrl_val = dsaf_read_dev(drv, XGMAC_MAC_CONTROL_REG);
+	mac_info->pad_and_crc_en = dsaf_get_bit(ctrl_val, XGMAC_CTL_TX_PAD_B);
+	mac_info->auto_neg = 0;
+
+	pause_time = dsaf_read_dev(drv, XGMAC_MAC_PAUSE_TIME_REG);
+	mac_info->tx_pause_time = pause_time;
+
+	port_mode = dsaf_read_dev(drv, XGMAC_PORT_MODE_REG);
+	mac_info->port_en = dsaf_get_field(port_mode, XGMAC_PORT_MODE_TX_M,
+					   XGMAC_PORT_MODE_TX_S) &&
+				dsaf_get_field(port_mode, XGMAC_PORT_MODE_RX_M,
+					       XGMAC_PORT_MODE_RX_S);
+	mac_info->duplex = 1;
+	mac_info->speed = MAC_SPEED_10000;
+
+	pause_ctrl = dsaf_read_dev(drv, XGMAC_MAC_PAUSE_CTRL_REG);
+	mac_info->rx_pause_en = dsaf_get_bit(pause_ctrl, XGMAC_PAUSE_CTL_RX_B);
+	mac_info->tx_pause_en = dsaf_get_bit(pause_ctrl, XGMAC_PAUSE_CTL_TX_B);
+}
+
+/**
+ *hns_xgmac_get_pausefrm_cfg - get xgmac pause param
+ *@mac_drv: mac driver
+ *@rx_en:xgmac rx pause enable
+ *@tx_en:xgmac tx pause enable
+ */
+static void hns_xgmac_get_pausefrm_cfg(void *mac_drv, u32 *rx_en, u32 *tx_en)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	u32 pause_ctrl;
+
+	pause_ctrl = dsaf_read_dev(drv, XGMAC_MAC_PAUSE_CTRL_REG);
+	*rx_en = dsaf_get_bit(pause_ctrl, XGMAC_PAUSE_CTL_RX_B);
+	*tx_en = dsaf_get_bit(pause_ctrl, XGMAC_PAUSE_CTL_TX_B);
+}
+
+/**
+ *hns_xgmac_get_link_status - get xgmac link status
+ *@mac_drv: mac driver
+ *@link_stat: xgmac link stat
+ */
+static void hns_xgmac_get_link_status(void *mac_drv, u32 *link_stat)
+{
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+
+	*link_stat = dsaf_read_dev(drv, XGMAC_LINK_STATUS_REG);
+}
+
+/**
+ *hns_xgmac_get_regs - dump xgmac regs
+ *@mac_drv: mac driver
+ *@cmd:ethtool cmd
+ *@data:data for value of regs
+ */
+static void hns_xgmac_get_regs(void *mac_drv, void *data)
+{
+	u32 i = 0;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	u32 *regs = data;
+	u64 qtmp;
+
+	/* base config registers */
+	regs[0] = dsaf_read_dev(drv, XGMAC_INT_STATUS_REG);
+	regs[1] = dsaf_read_dev(drv, XGMAC_INT_ENABLE_REG);
+	regs[2] = dsaf_read_dev(drv, XGMAC_INT_SET_REG);
+	regs[3] = dsaf_read_dev(drv, XGMAC_IERR_U_INFO_REG);
+	regs[4] = dsaf_read_dev(drv, XGMAC_OVF_INFO_REG);
+	regs[5] = dsaf_read_dev(drv, XGMAC_OVF_CNT_REG);
+	regs[6] = dsaf_read_dev(drv, XGMAC_PORT_MODE_REG);
+	regs[7] = dsaf_read_dev(drv, XGMAC_CLK_ENABLE_REG);
+	regs[8] = dsaf_read_dev(drv, XGMAC_RESET_REG);
+	regs[9] = dsaf_read_dev(drv, XGMAC_LINK_CONTROL_REG);
+	regs[10] = dsaf_read_dev(drv, XGMAC_LINK_STATUS_REG);
+
+	regs[11] = dsaf_read_dev(drv, XGMAC_SPARE_REG);
+	regs[12] = dsaf_read_dev(drv, XGMAC_SPARE_CNT_REG);
+	regs[13] = dsaf_read_dev(drv, XGMAC_MAC_ENABLE_REG);
+	regs[14] = dsaf_read_dev(drv, XGMAC_MAC_CONTROL_REG);
+	regs[15] = dsaf_read_dev(drv, XGMAC_MAC_IPG_REG);
+	regs[16] = dsaf_read_dev(drv, XGMAC_MAC_MSG_CRC_EN_REG);
+	regs[17] = dsaf_read_dev(drv, XGMAC_MAC_MSG_IMG_REG);
+	regs[18] = dsaf_read_dev(drv, XGMAC_MAC_MSG_FC_CFG_REG);
+	regs[19] = dsaf_read_dev(drv, XGMAC_MAC_MSG_TC_CFG_REG);
+	regs[20] = dsaf_read_dev(drv, XGMAC_MAC_PAD_SIZE_REG);
+	regs[21] = dsaf_read_dev(drv, XGMAC_MAC_MIN_PKT_SIZE_REG);
+	regs[22] = dsaf_read_dev(drv, XGMAC_MAC_MAX_PKT_SIZE_REG);
+	regs[23] = dsaf_read_dev(drv, XGMAC_MAC_PAUSE_CTRL_REG);
+	regs[24] = dsaf_read_dev(drv, XGMAC_MAC_PAUSE_TIME_REG);
+	regs[25] = dsaf_read_dev(drv, XGMAC_MAC_PAUSE_GAP_REG);
+	regs[26] = dsaf_read_dev(drv, XGMAC_MAC_PAUSE_LOCAL_MAC_H_REG);
+	regs[27] = dsaf_read_dev(drv, XGMAC_MAC_PAUSE_LOCAL_MAC_L_REG);
+	regs[28] = dsaf_read_dev(drv, XGMAC_MAC_PAUSE_PEER_MAC_H_REG);
+	regs[29] = dsaf_read_dev(drv, XGMAC_MAC_PAUSE_PEER_MAC_L_REG);
+	regs[30] = dsaf_read_dev(drv, XGMAC_MAC_PFC_PRI_EN_REG);
+	regs[31] = dsaf_read_dev(drv, XGMAC_MAC_1588_CTRL_REG);
+	regs[32] = dsaf_read_dev(drv, XGMAC_MAC_1588_TX_PORT_DLY_REG);
+	regs[33] = dsaf_read_dev(drv, XGMAC_MAC_1588_RX_PORT_DLY_REG);
+	regs[34] = dsaf_read_dev(drv, XGMAC_MAC_1588_ASYM_DLY_REG);
+	regs[35] = dsaf_read_dev(drv, XGMAC_MAC_1588_ADJUST_CFG_REG);
+
+	regs[36] = dsaf_read_dev(drv, XGMAC_MAC_Y1731_ETH_TYPE_REG);
+	regs[37] = dsaf_read_dev(drv, XGMAC_MAC_MIB_CONTROL_REG);
+	regs[38] = dsaf_read_dev(drv, XGMAC_MAC_WAN_RATE_ADJUST_REG);
+	regs[39] = dsaf_read_dev(drv, XGMAC_MAC_TX_ERR_MARK_REG);
+	regs[40] = dsaf_read_dev(drv, XGMAC_MAC_TX_LF_RF_CONTROL_REG);
+	regs[41] = dsaf_read_dev(drv, XGMAC_MAC_RX_LF_RF_STATUS_REG);
+	regs[42] = dsaf_read_dev(drv, XGMAC_MAC_TX_RUNT_PKT_CNT_REG);
+	regs[43] = dsaf_read_dev(drv, XGMAC_MAC_RX_RUNT_PKT_CNT_REG);
+	regs[44] = dsaf_read_dev(drv, XGMAC_MAC_RX_PREAM_ERR_PKT_CNT_REG);
+	regs[45] = dsaf_read_dev(drv, XGMAC_MAC_TX_LF_RF_TERM_PKT_CNT_REG);
+	regs[46] = dsaf_read_dev(drv, XGMAC_MAC_TX_SN_MISMATCH_PKT_CNT_REG);
+	regs[47] = dsaf_read_dev(drv, XGMAC_MAC_RX_ERR_MSG_CNT_REG);
+	regs[48] = dsaf_read_dev(drv, XGMAC_MAC_RX_ERR_EFD_CNT_REG);
+	regs[49] = dsaf_read_dev(drv, XGMAC_MAC_ERR_INFO_REG);
+	regs[50] = dsaf_read_dev(drv, XGMAC_MAC_DBG_INFO_REG);
+
+	regs[51] = dsaf_read_dev(drv, XGMAC_PCS_BASER_SYNC_THD_REG);
+	regs[52] = dsaf_read_dev(drv, XGMAC_PCS_STATUS1_REG);
+	regs[53] = dsaf_read_dev(drv, XGMAC_PCS_BASER_STATUS1_REG);
+	regs[54] = dsaf_read_dev(drv, XGMAC_PCS_BASER_STATUS2_REG);
+	regs[55] = dsaf_read_dev(drv, XGMAC_PCS_BASER_SEEDA_0_REG);
+	regs[56] = dsaf_read_dev(drv, XGMAC_PCS_BASER_SEEDA_1_REG);
+	regs[57] = dsaf_read_dev(drv, XGMAC_PCS_BASER_SEEDB_0_REG);
+	regs[58] = dsaf_read_dev(drv, XGMAC_PCS_BASER_SEEDB_1_REG);
+	regs[59] = dsaf_read_dev(drv, XGMAC_PCS_BASER_TEST_CONTROL_REG);
+	regs[60] = dsaf_read_dev(drv, XGMAC_PCS_BASER_TEST_ERR_CNT_REG);
+	regs[61] = dsaf_read_dev(drv, XGMAC_PCS_DBG_INFO_REG);
+	regs[62] = dsaf_read_dev(drv, XGMAC_PCS_DBG_INFO1_REG);
+	regs[63] = dsaf_read_dev(drv, XGMAC_PCS_DBG_INFO2_REG);
+	regs[64] = dsaf_read_dev(drv, XGMAC_PCS_DBG_INFO3_REG);
+
+	regs[65] = dsaf_read_dev(drv, XGMAC_PMA_ENABLE_REG);
+	regs[66] = dsaf_read_dev(drv, XGMAC_PMA_CONTROL_REG);
+	regs[67] = dsaf_read_dev(drv, XGMAC_PMA_SIGNAL_STATUS_REG);
+	regs[68] = dsaf_read_dev(drv, XGMAC_PMA_DBG_INFO_REG);
+	regs[69] = dsaf_read_dev(drv, XGMAC_PMA_FEC_ABILITY_REG);
+	regs[70] = dsaf_read_dev(drv, XGMAC_PMA_FEC_CONTROL_REG);
+	regs[71] = dsaf_read_dev(drv, XGMAC_PMA_FEC_CORR_BLOCK_CNT__REG);
+	regs[72] = dsaf_read_dev(drv, XGMAC_PMA_FEC_UNCORR_BLOCK_CNT__REG);
+
+	/* status registers */
+#define hns_xgmac_cpy_q(p, q) \
+	do {\
+		*(p) = (u32)(q);\
+		*((p) + 1) = (u32)((q) >> 32);\
+	} while (0)
+
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_FRAGMENT);
+	hns_xgmac_cpy_q(&regs[73], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_UNDERSIZE);
+	hns_xgmac_cpy_q(&regs[75], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_UNDERMIN);
+	hns_xgmac_cpy_q(&regs[77], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_64OCTETS);
+	hns_xgmac_cpy_q(&regs[79], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_65TO127OCTETS);
+	hns_xgmac_cpy_q(&regs[81], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_128TO255OCTETS);
+	hns_xgmac_cpy_q(&regs[83], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_256TO511OCTETS);
+	hns_xgmac_cpy_q(&regs[85], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_512TO1023OCTETS);
+	hns_xgmac_cpy_q(&regs[87], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_1024TO1518OCTETS);
+	hns_xgmac_cpy_q(&regs[89], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_1519TOMAXOCTETS);
+	hns_xgmac_cpy_q(&regs[91], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_1519TOMAXOCTETSOK);
+	hns_xgmac_cpy_q(&regs[93], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_OVERSIZE);
+	hns_xgmac_cpy_q(&regs[95], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PKTS_JABBER);
+	hns_xgmac_cpy_q(&regs[97], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_GOODPKTS);
+	hns_xgmac_cpy_q(&regs[99], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_GOODOCTETS);
+	hns_xgmac_cpy_q(&regs[101], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_TOTAL_PKTS);
+	hns_xgmac_cpy_q(&regs[103], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_TOTALOCTETS);
+	hns_xgmac_cpy_q(&regs[105], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_UNICASTPKTS);
+	hns_xgmac_cpy_q(&regs[107], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_MULTICASTPKTS);
+	hns_xgmac_cpy_q(&regs[109], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_BROADCASTPKTS);
+	hns_xgmac_cpy_q(&regs[111], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PRI0PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[113], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PRI1PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[115], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PRI2PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[117], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PRI3PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[119], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PRI4PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[121], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PRI5PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[123], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PRI6PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[125], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_PRI7PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[127], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_MACCTRLPKTS);
+	hns_xgmac_cpy_q(&regs[129], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_1731PKTS);
+	hns_xgmac_cpy_q(&regs[131], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_1588PKTS);
+	hns_xgmac_cpy_q(&regs[133], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_FROMAPPGOODPKTS);
+	hns_xgmac_cpy_q(&regs[135], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_FROMAPPBADPKTS);
+	hns_xgmac_cpy_q(&regs[137], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_ERRALLPKTS);
+	hns_xgmac_cpy_q(&regs[139], qtmp);
+
+	/* RX */
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_FRAGMENT);
+	hns_xgmac_cpy_q(&regs[141], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTSUNDERSIZE);
+	hns_xgmac_cpy_q(&regs[143], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_UNDERMIN);
+	hns_xgmac_cpy_q(&regs[145], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_64OCTETS);
+	hns_xgmac_cpy_q(&regs[147], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_65TO127OCTETS);
+	hns_xgmac_cpy_q(&regs[149], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_128TO255OCTETS);
+	hns_xgmac_cpy_q(&regs[151], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_256TO511OCTETS);
+	hns_xgmac_cpy_q(&regs[153], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_512TO1023OCTETS);
+	hns_xgmac_cpy_q(&regs[155], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_1024TO1518OCTETS);
+	hns_xgmac_cpy_q(&regs[157], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_1519TOMAXOCTETS);
+	hns_xgmac_cpy_q(&regs[159], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_1519TOMAXOCTETSOK);
+	hns_xgmac_cpy_q(&regs[161], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_OVERSIZE);
+	hns_xgmac_cpy_q(&regs[163], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PKTS_JABBER);
+	hns_xgmac_cpy_q(&regs[165], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_GOODPKTS);
+	hns_xgmac_cpy_q(&regs[167], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_GOODOCTETS);
+	hns_xgmac_cpy_q(&regs[169], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_TOTAL_PKTS);
+	hns_xgmac_cpy_q(&regs[171], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_TOTALOCTETS);
+	hns_xgmac_cpy_q(&regs[173], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_UNICASTPKTS);
+	hns_xgmac_cpy_q(&regs[175], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_MULTICASTPKTS);
+	hns_xgmac_cpy_q(&regs[177], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_BROADCASTPKTS);
+	hns_xgmac_cpy_q(&regs[179], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PRI0PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[181], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PRI1PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[183], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PRI2PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[185], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PRI3PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[187], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PRI4PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[189], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PRI5PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[191], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PRI6PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[193], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_PRI7PAUSEPKTS);
+	hns_xgmac_cpy_q(&regs[195], qtmp);
+
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_MACCTRLPKTS);
+	hns_xgmac_cpy_q(&regs[197], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_SENDAPPGOODPKTS);
+	hns_xgmac_cpy_q(&regs[199], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_TX_SENDAPPBADPKTS);
+	hns_xgmac_cpy_q(&regs[201], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_1731PKTS);
+	hns_xgmac_cpy_q(&regs[203], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_SYMBOLERRPKTS);
+	hns_xgmac_cpy_q(&regs[205], qtmp);
+	qtmp = hns_mac_reg_read64(drv, XGMAC_RX_FCSERRPKTS);
+	hns_xgmac_cpy_q(&regs[207], qtmp);
+
+	/* mark end of mac regs */
+	for (i = 208; i < 214; i++)
+		regs[i] = 0xaaaaaaaa;
+}
+
+/**
+ *hns_xgmac_get_stats - get xgmac statistic
+ *@mac_drv: mac driver
+ *@data:data for value of stats regs
+ */
+static void hns_xgmac_get_stats(void *mac_drv, u64 *data)
+{
+	u32 i;
+	u64 *buf = data;
+	struct mac_driver *drv = (struct mac_driver *)mac_drv;
+	struct mac_hw_stats *hw_stats = NULL;
+
+	hw_stats = &drv->mac_cb->hw_stats;
+
+	for (i = 0; i < ARRAY_SIZE(g_xgmac_stats_string); i++) {
+		buf[i] = DSAF_STATS_READ(hw_stats,
+			g_xgmac_stats_string[i].offset);
+	}
+}
+
+/**
+ *hns_xgmac_get_strings - get xgmac strings name
+ *@stringset: type of values in data
+ *@data:data for value of string name
+ */
+static void hns_xgmac_get_strings(u32 stringset, u8 *data)
+{
+	char *buff = (char *)data;
+	u32 i;
+
+	if (stringset != ETH_SS_STATS)
+		return;
+
+	for (i = 0; i < ARRAY_SIZE(g_xgmac_stats_string); i++) {
+		snprintf(buff, ETH_GSTRING_LEN, g_xgmac_stats_string[i].desc);
+		buff = buff + ETH_GSTRING_LEN;
+	}
+}
+
+/**
+ *hns_xgmac_get_sset_count - get xgmac string set count
+ *@stringset: type of values in data
+ *return xgmac string set count
+ */
+static int hns_xgmac_get_sset_count(int stringset)
+{
+	if (stringset == ETH_SS_STATS)
+		return ARRAY_SIZE(g_xgmac_stats_string);
+
+	return 0;
+}
+
+/**
+ *hns_xgmac_get_regs_count - get xgmac regs count
+ *return xgmac regs count
+ */
+static int hns_xgmac_get_regs_count(void)
+{
+	return ETH_XGMAC_DUMP_NUM;
+}
+
+void *hns_xgmac_config(struct hns_mac_cb *mac_cb, struct mac_params *mac_param)
+{
+	struct mac_driver *mac_drv;
+
+	mac_drv = devm_kzalloc(mac_cb->dev, sizeof(*mac_drv), GFP_KERNEL);
+	if (!mac_drv)
+		return NULL;
+
+	mac_drv->mac_init = hns_xgmac_init;
+	mac_drv->mac_enable = hns_xgmac_enable;
+	mac_drv->mac_disable = hns_xgmac_disable;
+
+	mac_drv->mac_id = mac_param->mac_id;
+	mac_drv->mac_mode = mac_param->mac_mode;
+	mac_drv->io_base = mac_param->vaddr;
+	mac_drv->dev = mac_param->dev;
+	mac_drv->mac_cb = mac_cb;
+
+	mac_drv->set_mac_addr = hns_xgmac_set_pausefrm_mac_addr;
+	mac_drv->set_an_mode = NULL;
+	mac_drv->config_loopback = NULL;
+	mac_drv->config_pad_and_crc = hns_xgmac_config_pad_and_crc;
+	mac_drv->config_half_duplex = NULL;
+	mac_drv->set_rx_ignore_pause_frames =
+		hns_xgmac_set_rx_ignore_pause_frames;
+	mac_drv->mac_get_id = hns_xgmac_get_id;
+	mac_drv->mac_free = hns_xgmac_free;
+	mac_drv->adjust_link = NULL;
+	mac_drv->set_tx_auto_pause_frames = hns_xgmac_set_tx_auto_pause_frames;
+	mac_drv->config_max_frame_length = hns_xgmac_config_max_frame_length;
+	mac_drv->mac_pausefrm_cfg = hns_xgmac_pausefrm_cfg;
+	mac_drv->autoneg_stat = NULL;
+	mac_drv->get_info = hns_xgmac_get_info;
+	mac_drv->get_pause_enable = hns_xgmac_get_pausefrm_cfg;
+	mac_drv->get_link_status = hns_xgmac_get_link_status;
+	mac_drv->get_regs = hns_xgmac_get_regs;
+	mac_drv->get_ethtool_stats = hns_xgmac_get_stats;
+	mac_drv->get_sset_count = hns_xgmac_get_sset_count;
+	mac_drv->get_regs_count = hns_xgmac_get_regs_count;
+	mac_drv->get_strings = hns_xgmac_get_strings;
+	mac_drv->update_stats = hns_xgmac_update_stats;
+
+	return (void *)mac_drv;
+}
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h
new file mode 100644
index 0000000..139f729
--- /dev/null
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.h
@@ -0,0 +1,15 @@
+/*
+ * Copyright (c) 2014-2015 Hisilicon Limited.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _HNS_XGMAC_H
+#define _HNS_XGMAC_H
+
+#define ETH_XGMAC_DUMP_NUM		(214)
+
+#endif
-- 
1.9.1
