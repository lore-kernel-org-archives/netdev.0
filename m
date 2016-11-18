From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC 03/10] IB/hfi-vnic: Virtual Network Interface Controller (VNIC) netdev driver
Date: Fri, 18 Nov 2016 14:42:11 -0800
Message-ID: <1479508938-63799-4-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sudeep Dutt <sudeep.dutt-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Andrzej Kacprowski <andrzej.kacprowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

HFI VNIC netdev driver supports Ethernet functionality over Omni-Path
fabric by encapsulating Ethernet packets inside Omni-Path packet header.
It interfaces with the network stack to provide standard Ethernet network
interfaces to the user. It binds with the HFI VNIC device and invokes the
bus operations supported by it.

Change-Id: I2613b2c36e548182828e732181e4bde99b8d01dc
Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sudeep Dutt <sudeep.dutt-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Andrzej Kacprowski <andrzej.kacprowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/Kconfig                         |   1 +
 drivers/infiniband/sw/intel/vnic/Makefile          |   1 +
 drivers/infiniband/sw/intel/vnic/hfi_vnic/Kconfig  |   8 +
 drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile |   7 +
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_encap.c        | 239 +++++++++++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h        |  62 +++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_ethtool.c      |  81 ++++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h     | 221 ++++++++++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c       | 469 +++++++++++++++++++++
 9 files changed, 1089 insertions(+)
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/Kconfig
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.c
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_ethtool.c
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
 create mode 100644 drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index 7fe9095..0c419d2 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -85,6 +85,7 @@ source "drivers/infiniband/ulp/iser/Kconfig"
 source "drivers/infiniband/ulp/isert/Kconfig"
 
 source "drivers/infiniband/sw/intel/vnic/hfi_vnic_bus/Kconfig"
+source "drivers/infiniband/sw/intel/vnic/hfi_vnic/Kconfig"
 source "drivers/infiniband/sw/rdmavt/Kconfig"
 source "drivers/infiniband/sw/rxe/Kconfig"
 
diff --git a/drivers/infiniband/sw/intel/vnic/Makefile b/drivers/infiniband/sw/intel/vnic/Makefile
index 083e55b..bb22e22 100644
--- a/drivers/infiniband/sw/intel/vnic/Makefile
+++ b/drivers/infiniband/sw/intel/vnic/Makefile
@@ -1 +1,2 @@
 obj-$(CONFIG_HFI_VNIC_BUS)		+= hfi_vnic_bus/
+obj-$(CONFIG_HFI_VNIC)			+= hfi_vnic/
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/Kconfig b/drivers/infiniband/sw/intel/vnic/hfi_vnic/Kconfig
new file mode 100644
index 0000000..d03efc9
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/Kconfig
@@ -0,0 +1,8 @@
+config HFI_VNIC
+	tristate "Intel HFI VNIC support"
+	depends on X86_64 && INFINIBAND && HFI_VNIC_BUS
+	---help---
+	This is HFI Virtual Network Interface Controller (VNIC) driver
+	for Ethernet over HFI feature. It implements the HW independent
+	VNIC functionality. It interfaces with Linux stack for data path
+	and IB MAD for the control path.
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile b/drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile
new file mode 100644
index 0000000..a05b2f5
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/Makefile
@@ -0,0 +1,7 @@
+# Makefile - Intel HFI Virtual Network Controller driver
+# Copyright(c) 2016, Intel Corporation.
+#
+ccflags-y += -I$(src)/../include
+obj-$(CONFIG_HFI_VNIC) += hfi_vnic.o
+
+hfi_vnic-y := hfi_vnic_netdev.o hfi_vnic_encap.o hfi_vnic_ethtool.o
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.c b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.c
new file mode 100644
index 0000000..9804c6d
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.c
@@ -0,0 +1,239 @@
+/*
+ * Copyright(c) 2016 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+/*
+ * This file contains HFI VNIC encapsulation/decapsulation function.
+ */
+
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+
+#include "hfi_vnic.h"
+#include "hfi_vnic_internal.h"
+
+/**
+ * union hfi_vnic_bypass_hdr - VNIC bypass header
+ * @slid: source lid
+ * @length: length of packet
+ * @becn: backward explicit congestion notification
+ * @dlid: destination lid
+ * @sc: service class
+ * @fecn: forward explicit congestion notification
+ * @l2: L2 type (2=16B)
+ * @lt: link transfer field
+ * @l4: L4 type
+ * @slid_high: upper 4 bits of source lid
+ * @dlid_high: upper 4 bits of destination lid
+ * @pkey: partition key
+ * @entropy: entropy
+ * @age: packet age
+ * @l4_hdr: L4 header
+ */
+union hfi_vnic_bypass_hdr {
+	struct {
+	struct {
+		uint64_t slid   : 20;
+		uint64_t length : 11;
+		uint64_t becn   : 1;
+		uint64_t dlid   : 20;
+		uint64_t sc     : 5;
+		uint64_t rsvd   : 3;
+		uint64_t fecn   : 1;
+		uint64_t l2     : 2;
+		uint64_t lt     : 1;
+	};
+	struct {
+		uint64_t l4        : 8;
+		uint64_t slid_high : 4;
+		uint64_t dlid_high : 4;
+		uint64_t pkey      : 16;
+		uint64_t entropy   : 16;
+		uint64_t age       : 8;
+		uint64_t rsvd1     : 8;
+	};
+	struct {
+		uint32_t rsvd2  : 16;
+		uint32_t l4_hdr : 16;
+	};
+	} __packed;
+	u32 dw[5];
+};
+
+#define HFI_VNIC_SC_MASK 0x1f
+
+/* hfi_vnic_get_dlid - find and return the DLID */
+static uint32_t hfi_vnic_get_dlid(struct hfi_vnic_adapter *adapter,
+				  struct sk_buff *skb, u8 def_port)
+{
+	struct __hfi_veswport_info *info = &adapter->info;
+	struct ethhdr *mac_hdr = (struct ethhdr *)skb_mac_header(skb);
+	u32 dlid;
+
+	if (is_multicast_ether_addr(mac_hdr->h_dest)) {
+		dlid = info->vesw.u_mcast_dlid;
+	} else {
+		if (is_local_ether_addr(mac_hdr->h_dest)) {
+			dlid = ((uint32_t)mac_hdr->h_dest[5] << 16) |
+				((uint32_t)mac_hdr->h_dest[4] << 8)  |
+				mac_hdr->h_dest[3];
+			if (unlikely(!dlid))
+				v_warn("Null dlid in MAC address\n");
+		} else if (def_port != HFI_VNIC_INVALID_PORT) {
+			dlid = info->vesw.u_ucast_dlid[def_port];
+		}
+	}
+
+	return dlid;
+}
+
+/* hfi_vnic_get_sc - return the service class */
+static u8 hfi_vnic_get_sc(struct __hfi_veswport_info *info,
+			  struct sk_buff *skb)
+{
+	struct ethhdr *mac_hdr = (struct ethhdr *)skb_mac_header(skb);
+	u16 vlan_tci;
+	u8 sc;
+
+	if (!__vlan_get_tag(skb, &vlan_tci)) {
+		u8 pcp = HFI_VNIC_VLAN_PCP(vlan_tci);
+
+		if (is_multicast_ether_addr(mac_hdr->h_dest))
+			sc = info->vport.pcp_to_sc_mc[pcp];
+		else
+			sc = info->vport.pcp_to_sc_uc[pcp];
+	} else {
+		if (is_multicast_ether_addr(mac_hdr->h_dest))
+			sc = info->vport.non_vlan_sc_mc;
+		else
+			sc = info->vport.non_vlan_sc_uc;
+	}
+
+	return sc & HFI_VNIC_SC_MASK;
+}
+
+/* hfi_vnic_calc_entropy - calculate the packet entropy */
+u8 hfi_vnic_calc_entropy(struct hfi_vnic_adapter *adapter, struct sk_buff *skb)
+{
+	u16 hash16;
+
+	/*
+	 * Get flow based 16-bit hash and then XOR the upper and lower bytes
+	 * to get the entropy.
+	 * __skb_tx_hash limits qcount to 16 bits. Hence, get 15-bit hash.
+	 */
+	hash16 = __skb_tx_hash(adapter->netdev, skb, BIT(15));
+	return (u8)((hash16 >> 8) ^ (hash16 & 0xff));
+}
+
+/* hfi_vnic_get_def_port - get default port based on entropy */
+static inline u8 hfi_vnic_get_def_port(struct hfi_vnic_adapter *adapter,
+				       u8 entropy)
+{
+	u8 flow_id;
+
+	/* Add the upper and lower 4-bits of entropy to get the flow id */
+	flow_id = ((entropy & 0xf) + (entropy >> 4));
+	return adapter->flow_tbl[flow_id & (HFI_VNIC_FLOW_TBL_SIZE - 1)];
+}
+
+/* Calculate packet length including OPA header, crc and padding */
+static inline int hfi_vnic_wire_length(struct sk_buff *skb)
+{
+	u32 pad_len, hlen = HFI_VNIC_HDR_LEN;
+
+	/* padding for 8 bytes size alignment */
+	pad_len = -(skb->len + hlen + HFI_VNIC_ICRC_TAIL_LEN) & 0x7;
+	pad_len += HFI_VNIC_ICRC_TAIL_LEN;
+
+	return (skb->len + hlen + pad_len) >> 3;
+}
+
+/* hfi_vnic_encap_skb - encapsulate skb (ethernet) packet with OPA header */
+int hfi_vnic_encap_skb(struct hfi_vnic_adapter *adapter, struct sk_buff *skb)
+{
+	struct __hfi_veswport_info *info = &adapter->info;
+	union hfi_vnic_bypass_hdr *hdr;
+	u32 dlid;
+	u8 def_port;
+
+	hdr = (union hfi_vnic_bypass_hdr *)(skb->data - HFI_VNIC_HDR_LEN);
+	memset(hdr, 0, HFI_VNIC_HDR_LEN);
+
+	hdr->entropy = hfi_vnic_calc_entropy(adapter, skb);
+	def_port = hfi_vnic_get_def_port(adapter, hdr->entropy);
+
+	hdr->slid = info->vport.encap_slid;
+	hdr->slid_high = info->vport.encap_slid >> 20;
+
+	dlid = hfi_vnic_get_dlid(adapter, skb, def_port);
+	if (unlikely(!dlid))
+		return -EFAULT;
+
+	hdr->dlid = dlid;
+	hdr->dlid_high = dlid >> 20;
+
+	hdr->length = hfi_vnic_wire_length(skb);
+	hdr->sc = hfi_vnic_get_sc(info, skb);
+
+	hdr->l2 = HFI_VNIC_L2_TYPE;
+	hdr->lt = 1;
+
+	hdr->pkey = info->vesw.pkey;
+
+	hdr->l4 = HFI_VNIC_L4_ETHR;
+	hdr->l4_hdr = info->vesw.vesw_id;
+
+	skb_push(skb, HFI_VNIC_HDR_LEN);
+	return 0;
+}
+
+/* hfi_vnic_decap_skb - strip OPA header from the skb (ethernet) packet */
+int hfi_vnic_decap_skb(struct hfi_vnic_rx_queue *rxq, struct sk_buff *skb)
+{
+	skb_pull(skb, HFI_VNIC_HDR_LEN);
+	return 0;
+}
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h
new file mode 100644
index 0000000..6786cce
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h
@@ -0,0 +1,62 @@
+#ifndef _HFI_VNIC_ENCAP_H
+#define _HFI_VNIC_ENCAP_H
+/*
+ * Copyright(c) 2016 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+/*
+ * This file contains all HFI VNIC declaration required for encapsulation
+ * and decapsulation of Ethernet packets
+ */
+
+#define HFI_VESW_MAX_NUM_DEF_PORT   16
+#define HFI_VNIC_MAX_NUM_PCP        8
+
+/* VNIC configured and operational state values */
+#define HFI_VNIC_STATE_DROP_ALL        0x1
+#define HFI_VNIC_STATE_FORWARDING      0x3
+
+#endif /* _HFI_VNIC_ENCAP_H */
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_ethtool.c b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_ethtool.c
new file mode 100644
index 0000000..32bb9ce
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_ethtool.c
@@ -0,0 +1,81 @@
+/*
+ * Copyright(c) 2016 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+/*
+ * This file contains HFI VNIC ethtool functions
+ */
+
+#include <linux/ethtool.h>
+
+#include "hfi_vnic.h"
+#include "hfi_vnic_internal.h"
+
+/* vnic_get_drvinfo - get driver info */
+static void vnic_get_drvinfo(struct net_device *netdev,
+			     struct ethtool_drvinfo *drvinfo)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	struct hfi_vnic_device *vdev = adapter->vdev;
+
+	strlcpy(drvinfo->driver, hfi_vnic_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, hfi_vnic_driver_version,
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->bus_info, dev_name(&vdev->dev),
+		sizeof(drvinfo->bus_info));
+}
+
+/* ethtool ops */
+static const struct ethtool_ops hfi_vnic_ethtool_ops = {
+	.get_drvinfo = vnic_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+};
+
+/* hfi_vnic_set_ethtool_ops - set ethtool ops */
+void hfi_vnic_set_ethtool_ops(struct net_device *ndev)
+{
+	ndev->ethtool_ops = &hfi_vnic_ethtool_ops;
+}
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
new file mode 100644
index 0000000..8a5e0c1
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
@@ -0,0 +1,221 @@
+#ifndef _HFI_VNIC_INTERNAL_H
+#define _HFI_VNIC_INTERNAL_H
+/*
+ * Copyright(c) 2016 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+/*
+ * This file contains HFI VNIC driver internal declarations
+ */
+
+#include <linux/bitops.h>
+#include <linux/etherdevice.h>
+#include <linux/hashtable.h>
+#include <linux/sizes.h>
+
+#include "hfi_vnic_encap.h"
+
+/* VNIC uses 16B header format */
+#define HFI_VNIC_L2_TYPE    0x2
+
+/* 16 header bytes + 2 reserved bytes */
+#define HFI_VNIC_L2_HDR_LEN   (16 + 2)
+
+#define HFI_VNIC_L4_HDR_LEN   2
+
+#define HFI_VNIC_HDR_LEN      (HFI_VNIC_L2_HDR_LEN + \
+			       HFI_VNIC_L4_HDR_LEN)
+
+#define HFI_VNIC_L4_ETHR  0x78
+
+#define HFI_VNIC_ICRC_LEN   4
+#define HFI_VNIC_TAIL_LEN   1
+#define HFI_VNIC_ICRC_TAIL_LEN  (HFI_VNIC_ICRC_LEN + HFI_VNIC_TAIL_LEN)
+
+#define HFI_VNIC_VLAN_PCP(vlan_tci)  \
+			(((vlan_tci) & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT)
+
+#define HFI_VNIC_SKB_HEADROOM ALIGN(HFI_VNIC_HDR_LEN, 8)
+
+/* Flow to default port redirection table size */
+#define HFI_VNIC_FLOW_TBL_SIZE    32
+
+/* Invalid port number */
+#define HFI_VNIC_INVALID_PORT     0xff
+
+enum hfi_vnic_flags_t {
+	HFI_VNIC_UP,
+	HFI_VNIC_OPEN,
+};
+
+struct hfi_vnic_adapter;
+
+/**
+ * struct __hfi_vesw_info - HFI vnic virtual switch info
+ */
+struct __hfi_vesw_info {
+	u16  fabric_id;
+	u16  vesw_id;
+
+	u8   rsvd0[6];
+	u16  def_fw_id_mask;
+
+	u8   rsvd1[2];
+	u16  pkey;
+
+	u8   rsvd2[4];
+	u32  u_mcast_dlid;
+	u32  u_ucast_dlid[HFI_VESW_MAX_NUM_DEF_PORT];
+
+	u8   rsvd3[44];
+	u16  eth_mtu[HFI_VNIC_MAX_NUM_PCP];
+	u16  eth_mtu_non_vlan;
+	u8   rsvd4[2];
+} __packed;
+
+/**
+ * struct __hfi_per_veswport_info - HFI vnic per port info
+ */
+struct __hfi_per_veswport_info {
+	u32  port_num;
+
+	u8   eth_link_status;
+	u8   rsvd0[3];
+
+	u8   base_mac_addr[ETH_ALEN];
+	u8   config_state;
+	u8   oper_state;
+
+	u16  max_mac_tbl_ent;
+	u16  max_smac_ent;
+	u32  mac_tbl_digest;
+	u8   rsvd1[4];
+
+	u32  encap_slid;
+
+	u8   pcp_to_sc_uc[HFI_VNIC_MAX_NUM_PCP];
+	u8   pcp_to_vl_uc[HFI_VNIC_MAX_NUM_PCP];
+	u8   pcp_to_sc_mc[HFI_VNIC_MAX_NUM_PCP];
+	u8   pcp_to_vl_mc[HFI_VNIC_MAX_NUM_PCP];
+
+	u8   non_vlan_sc_uc;
+	u8   non_vlan_vl_uc;
+	u8   non_vlan_sc_mc;
+	u8   non_vlan_vl_mc;
+
+	u8   rsvd2[48];
+
+	u16  uc_macs_gen_count;
+	u16  mc_macs_gen_count;
+
+	u8   rsvd3[8];
+} __packed;
+
+/**
+ * struct __hfi_veswport_info - HFI vnic port info
+ */
+struct __hfi_veswport_info {
+	struct __hfi_vesw_info            vesw;
+	struct __hfi_per_veswport_info    vport;
+};
+
+/**
+ * struct hfi_vnic_rx_queue - HFI VNIC receive queue
+ * @idx: queue index
+ * @adapter: netdev adapter
+ * @napi: netdev napi structure
+ */
+struct hfi_vnic_rx_queue {
+	u8                        idx;
+	struct hfi_vnic_adapter  *adapter;
+	struct napi_struct        napi;
+};
+
+/**
+ * struct hfi_vnic_adapter - HFI VNIC netdev private data structure
+ * @netdev: pointer to associated netdev
+ * @vdev: pointer to hfi vnic device
+ * @flags: flags indicating various states
+ * @lock: adapter lock
+ * @rxq: receive queue array
+ * @info: virtual ethernet switch port information
+ * @flow_tbl: flow to default port redirection table
+ */
+struct hfi_vnic_adapter {
+	struct net_device        *netdev;
+	struct hfi_vnic_device   *vdev;
+	unsigned long             flags;
+
+	/* Lock used around state updates */
+	struct mutex              lock;
+
+	struct hfi_vnic_rx_queue  rxq[HFI_VNIC_MAX_QUEUE];
+
+	struct __hfi_veswport_info info;
+
+	u8 flow_tbl[HFI_VNIC_FLOW_TBL_SIZE];
+};
+
+#define v_dbg(format, arg...) \
+	netdev_dbg(adapter->netdev, format, ## arg)
+#define v_err(format, arg...) \
+	netdev_err(adapter->netdev, format, ## arg)
+#define v_info(format, arg...) \
+	netdev_info(adapter->netdev, format, ## arg)
+#define v_warn(format, arg...) \
+	netdev_warn(adapter->netdev, format, ## arg)
+#define v_notice(format, arg...) \
+	netdev_notice(adapter->netdev, format, ## arg)
+
+extern char hfi_vnic_driver_name[];
+extern const char hfi_vnic_driver_version[];
+
+int hfi_vnic_encap_skb(struct hfi_vnic_adapter *adapter, struct sk_buff *skb);
+int hfi_vnic_decap_skb(struct hfi_vnic_rx_queue *rxq, struct sk_buff *skb);
+u8 hfi_vnic_calc_entropy(struct hfi_vnic_adapter *adapter, struct sk_buff *skb);
+void hfi_vnic_set_ethtool_ops(struct net_device *ndev);
+
+#endif /* _HFI_VNIC_INTERNAL_H */
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c
new file mode 100644
index 0000000..7121637
--- /dev/null
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_netdev.c
@@ -0,0 +1,469 @@
+/*
+ * Copyright(c) 2016 Intel Corporation.
+ *
+ * This file is provided under a dual BSD/GPLv2 license.  When using or
+ * redistributing this file, you may do so under either license.
+ *
+ * GPL LICENSE SUMMARY
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * BSD LICENSE
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ *
+ *  - Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ *  - Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in
+ *    the documentation and/or other materials provided with the
+ *    distribution.
+ *  - Neither the name of Intel Corporation nor the names of its
+ *    contributors may be used to endorse or promote products derived
+ *    from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+/*
+ * This file contains HFI Virtual Network Interface Controller (VNIC) driver
+ */
+
+#include <linux/module.h>
+#include <linux/if_vlan.h>
+
+#include "hfi_vnic.h"
+#include "hfi_vnic_internal.h"
+
+#define DRV_VERSION "1.0"
+char hfi_vnic_driver_name[] = "hfi_vnic";
+const char hfi_vnic_driver_version[] = DRV_VERSION;
+
+#define HFI_TX_TIMEOUT_MS 1000
+
+#define HFI_VNIC_MIN_ETH_MTU (ETH_ZLEN - ETH_HLEN)
+
+/* hfi_vnic_maybe_stop_tx - stop tx queue if required */
+static void hfi_vnic_maybe_stop_tx(struct hfi_vnic_adapter *adapter, u8 q_idx)
+{
+	struct hfi_vnic_device *vdev = adapter->vdev;
+
+	netif_stop_subqueue(vdev->netdev, q_idx);
+	if (!vdev->bus_ops->get_write_avail(vdev, q_idx))
+		return;
+
+	netif_start_subqueue(vdev->netdev, q_idx);
+}
+
+/* hfi_netdev_start_xmit - transmit function */
+static netdev_tx_t hfi_netdev_start_xmit(struct sk_buff *skb,
+					 struct net_device *netdev)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	struct hfi_vnic_device *vdev = adapter->vdev;
+	u8 q_idx = skb->queue_mapping;
+	bool skip_skb_free = false;
+	int rc = -1;
+
+	v_dbg("xmit: queue %d skb len %d\n", q_idx, skb->len);
+	if (unlikely(adapter->info.vport.oper_state !=
+		     HFI_VNIC_STATE_FORWARDING))
+		goto tx_finish;
+
+	/* pad to ensure mininum ethernet packet length */
+	if (unlikely(skb->len < ETH_ZLEN)) {
+		if (skb_padto(skb, ETH_ZLEN)) {
+			skip_skb_free = true;
+			goto tx_finish;
+		}
+		skb_put(skb, ETH_ZLEN - skb->len);
+	}
+
+	rc = hfi_vnic_encap_skb(adapter, skb);
+	if (unlikely(rc))
+		goto tx_finish;
+
+	/* Get reference to skb as hfi driver might release it */
+	skb_get(skb);
+	rc = vdev->bus_ops->put_skb(vdev, q_idx, skb);
+	/* remove the header */
+	skb_pull(skb, HFI_VNIC_HDR_LEN);
+
+tx_finish:
+	if (unlikely(rc == -EBUSY)) {
+		hfi_vnic_maybe_stop_tx(adapter, q_idx);
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_BUSY;
+	}
+
+	if (!skip_skb_free)
+		dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
+}
+
+/* vnic_handle_rx - handle skb receive */
+static void vnic_handle_rx(struct hfi_vnic_rx_queue *rxq,
+			   int *work_done, int work_to_do)
+{
+	struct hfi_vnic_adapter *adapter = rxq->adapter;
+	struct hfi_vnic_device *vdev = adapter->vdev;
+	struct sk_buff *skb;
+
+	while (1) {
+		if (*work_done >= work_to_do)
+			break;
+
+		skb = vdev->bus_ops->get_skb(vdev, rxq->idx);
+		if (!skb)
+			break;
+
+		if (hfi_vnic_decap_skb(rxq, skb)) {
+			dev_kfree_skb_any(skb);
+			continue;
+		}
+
+		skb_checksum_none_assert(skb);
+		skb->protocol = eth_type_trans(skb, vdev->netdev);
+
+		napi_gro_receive(&rxq->napi, skb);
+		(*work_done)++;
+	}
+}
+
+/* vnic_napi - napi receive polling callback function */
+static int vnic_napi(struct napi_struct *napi, int budget)
+{
+	struct hfi_vnic_rx_queue *rxq = container_of(napi,
+					     struct hfi_vnic_rx_queue, napi);
+	struct hfi_vnic_adapter *adapter = rxq->adapter;
+	struct hfi_vnic_device *vdev = adapter->vdev;
+	u8 evt = rxq->idx + HFI_VNIC_EVT_RX0;
+	int work_done = 0;
+
+	v_dbg("napi %d budget %d\n", rxq->idx, budget);
+	vnic_handle_rx(rxq, &work_done, budget);
+
+	v_dbg("napi %d work_done %d\n", rxq->idx, work_done);
+	if (work_done < budget) {
+		napi_complete(napi);
+		vdev->bus_ops->config_notify(vdev, evt, true);
+	}
+
+	return work_done;
+}
+
+/* vnic_event_cb - handle events from vnic hfi driver */
+static void vnic_event_cb(struct hfi_vnic_device *vdev, u8 evt)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(vdev->netdev);
+	struct hfi_vnic_rx_queue *rxq;
+	u8 q_idx;
+
+	v_dbg("received event %d\n", evt);
+	if (evt < vdev->hfi_info.num_rx_q) {
+		q_idx = evt;
+		if (unlikely(adapter->info.vport.oper_state !=
+			     HFI_VNIC_STATE_FORWARDING))
+			return;
+
+		rxq = &adapter->rxq[q_idx];
+		if (napi_schedule_prep(&rxq->napi)) {
+			v_dbg("napi %d scheduling\n", q_idx);
+			vdev->bus_ops->config_notify(vdev, evt, false);
+			__napi_schedule(&rxq->napi);
+		}
+		return;
+	}
+	if ((evt >= HFI_VNIC_EVT_TX0) &&
+	    (evt < (HFI_VNIC_EVT_TX0 + vdev->hfi_info.num_tx_q))) {
+		q_idx = evt - HFI_VNIC_EVT_TX0;
+
+		if (__netif_subqueue_stopped(vdev->netdev, q_idx))
+			netif_wake_subqueue(vdev->netdev, q_idx);
+
+		return;
+	}
+	v_err("Invalid event\n");
+}
+
+static u16 hfi_vnic_select_queue(struct net_device *netdev, struct sk_buff *skb,
+				 void *accel_priv,
+				 select_queue_fallback_t fallback)
+{
+	struct ethhdr *mac_hdr = (struct ethhdr *)skb_mac_header(skb);
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	struct __hfi_veswport_info *info = &adapter->info;
+	struct hfi_vnic_device *vdev = adapter->vdev;
+	u8 vl, entropy;
+
+	if (skb_vlan_tag_present(skb)) {
+		u8 pcp = skb_vlan_tag_get(skb) >> VLAN_PRIO_SHIFT;
+
+		if (is_multicast_ether_addr(mac_hdr->h_dest))
+			vl = info->vport.pcp_to_vl_mc[pcp];
+		else
+			vl = info->vport.pcp_to_vl_uc[pcp];
+	} else {
+		if (is_multicast_ether_addr(mac_hdr->h_dest))
+			vl = info->vport.non_vlan_vl_mc;
+		else
+			vl = info->vport.non_vlan_vl_uc;
+	}
+
+	entropy =  hfi_vnic_calc_entropy(adapter, skb);
+	return vdev->bus_ops->select_queue(vdev, vl, entropy);
+}
+
+/* hfi_netdev_change_mtu - change the MTU */
+static int hfi_netdev_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	struct __hfi_veswport_info *info = &adapter->info;
+	u16 min_mtu = HFI_VNIC_MIN_ETH_MTU;
+	u16 max_mtu = max(min_mtu, info->vesw.eth_mtu_non_vlan);
+
+	/* Supported MTUs */
+	if ((new_mtu < min_mtu) || (new_mtu > max_mtu)) {
+		v_err("Unsupported MTU setting\n");
+		return -EINVAL;
+	}
+
+	v_info("changing MTU from %d to %d\n", netdev->mtu, new_mtu);
+	netdev->mtu = new_mtu;
+	return 0;
+}
+
+/* hfi_vnic_up - enable vnic data flow */
+static int hfi_vnic_up(struct hfi_vnic_adapter *adapter)
+{
+	struct hfi_vnic_device *vdev = adapter->vdev;
+	int i, rc;
+
+	rc = vdev->bus_ops->open(vdev, vnic_event_cb);
+	if (rc) {
+		v_dbg("hfi_open failed %d\n", rc);
+		return rc;
+	}
+
+	netif_carrier_on(adapter->netdev);
+	netif_tx_start_all_queues(adapter->netdev);
+	for (i = 0; i < vdev->hfi_info.num_rx_q; i++)
+		napi_enable(&adapter->rxq[i].napi);
+
+	set_bit(HFI_VNIC_UP, &adapter->flags);
+	return 0;
+}
+
+/* hfi_vnic_down - disable vnic data flow */
+static void hfi_vnic_down(struct hfi_vnic_adapter *adapter)
+{
+	struct hfi_vnic_device *vdev = adapter->vdev;
+	int i;
+
+	netif_carrier_off(adapter->netdev);
+	netif_tx_disable(adapter->netdev);
+	for (i = 0; i < vdev->hfi_info.num_rx_q; i++)
+		napi_disable(&adapter->rxq[i].napi);
+
+	vdev->bus_ops->close(vdev);
+	clear_bit(HFI_VNIC_UP, &adapter->flags);
+}
+
+/* hfi_vnic_set_mac_addr - change mac address */
+static int hfi_vnic_set_mac_addr(struct net_device *netdev, void *addr)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	int rc;
+
+	mutex_lock(&adapter->lock);
+	rc = eth_mac_addr(netdev, addr);
+	mutex_unlock(&adapter->lock);
+
+	return rc;
+}
+
+/* hfi_netdev_open - activate network interface */
+static int hfi_netdev_open(struct net_device *netdev)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	int rc;
+
+	mutex_lock(&adapter->lock);
+	rc = hfi_vnic_up(adapter);
+	if (rc)
+		goto open_done;
+
+	set_bit(HFI_VNIC_OPEN, &adapter->flags);
+	v_info("opened\n");
+open_done:
+	mutex_unlock(&adapter->lock);
+	return rc;
+}
+
+/* hfi_netdev_close - disable network interface */
+static int hfi_netdev_close(struct net_device *netdev)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+
+	mutex_lock(&adapter->lock);
+	if (test_bit(HFI_VNIC_UP, &adapter->flags))
+		hfi_vnic_down(adapter);
+
+	clear_bit(HFI_VNIC_OPEN, &adapter->flags);
+	mutex_unlock(&adapter->lock);
+	v_info("closed\n");
+	return 0;
+}
+
+/* netdev ops */
+static const struct net_device_ops hfi_netdev_ops = {
+	.ndo_open = hfi_netdev_open,
+	.ndo_stop = hfi_netdev_close,
+	.ndo_start_xmit = hfi_netdev_start_xmit,
+	.ndo_change_mtu = hfi_netdev_change_mtu,
+	.ndo_select_queue = hfi_vnic_select_queue,
+	.ndo_set_mac_address = hfi_vnic_set_mac_addr,
+};
+
+/* hfi_vnic_drv_probe - device initialization routine */
+static int hfi_vnic_drv_probe(struct device *dev)
+{
+	struct net_device *netdev;
+	struct hfi_vnic_adapter *adapter;
+	struct hfi_vnic_device *vdev = container_of(dev,
+					    struct hfi_vnic_device, dev);
+	int i, rc;
+
+	if (vdev->hfi_info.num_rx_q > HFI_VNIC_MAX_QUEUE ||
+	    vdev->hfi_info.num_tx_q > HFI_VNIC_MAX_QUEUE) {
+		dev_err(dev, "Number of VNIC (rx %d, tx %d) queues > Max Queue Size (%d)",
+			vdev->hfi_info.num_rx_q, vdev->hfi_info.num_tx_q,
+			HFI_VNIC_MAX_QUEUE);
+		return -EINVAL;
+	}
+	netdev = alloc_etherdev_mqs(sizeof(struct hfi_vnic_adapter),
+				    vdev->hfi_info.num_tx_q,
+				    vdev->hfi_info.num_rx_q);
+	if (!netdev)
+		return -ENOMEM;
+	adapter = netdev_priv(netdev);
+	adapter->netdev = netdev;
+	adapter->vdev = vdev;
+	vdev->netdev = netdev;
+	netdev->features = NETIF_F_HIGHDMA;
+	if (vdev->hfi_info.cap & HFI_VNIC_CAP_SG)
+		netdev->features |= NETIF_F_SG;
+	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	netdev->hw_features = netdev->features;
+	netdev->vlan_features = netdev->features;
+	netdev->watchdog_timeo = msecs_to_jiffies(HFI_TX_TIMEOUT_MS);
+	netdev->netdev_ops = &hfi_netdev_ops;
+	netdev->hard_header_len += HFI_VNIC_SKB_HEADROOM;
+	mutex_init(&adapter->lock);
+	strcpy(netdev->name, "veth%d");
+
+	hfi_vnic_set_ethtool_ops(netdev);
+	for (i = 0; i < vdev->hfi_info.num_rx_q; i++) {
+		adapter->rxq[i].idx = i;
+		adapter->rxq[i].adapter = adapter;
+		netif_napi_add(netdev, &adapter->rxq[i].napi, vnic_napi, 64);
+	}
+
+	rc = vdev->bus_ops->init(vdev);
+	if (rc)
+		goto hw_err;
+
+	rc = register_netdev(netdev);
+	if (rc)
+		goto netdev_err;
+
+	netif_carrier_off(netdev);
+	v_info("initialized\n");
+
+	return 0;
+
+netdev_err:
+	vdev->bus_ops->deinit(vdev);
+hw_err:
+	mutex_destroy(&adapter->lock);
+	free_netdev(netdev);
+	dev_err(dev, "initialization failed %d\n", rc);
+
+	return rc;
+}
+
+/* hfi_vnic_drv_remove - device removal routine */
+static int hfi_vnic_drv_remove(struct device *dev)
+{
+	struct hfi_vnic_device *vdev = container_of(dev,
+					    struct hfi_vnic_device, dev);
+	struct hfi_vnic_adapter *adapter = netdev_priv(vdev->netdev);
+
+	unregister_netdev(vdev->netdev);
+	vdev->bus_ops->deinit(vdev);
+	mutex_destroy(&adapter->lock);
+	free_netdev(vdev->netdev);
+
+	dev_info(dev, "removed\n");
+	return 0;
+}
+
+/* HFI Virtual Network Driver */
+static struct hfi_vnic_driver hfi_vnic_drv = {
+	.drvwrap = {
+		.type = HFI_VNIC_DRV,
+		.driver = {
+			.name   = hfi_vnic_driver_name,
+			.probe  = hfi_vnic_drv_probe,
+			.remove = hfi_vnic_drv_remove
+		}
+	}
+};
+
+/* hfi_vnic_init_module - driver registration routine */
+static int __init hfi_vnic_init_module(void)
+{
+	int rc;
+
+	pr_info("HFI Virtual Network Driver - %s\n",
+		hfi_vnic_driver_version);
+
+	rc = hfi_vnic_driver_register(&hfi_vnic_drv);
+	if (rc)
+		pr_err("VNIC driver register failed %d\n", rc);
+
+	return rc;
+}
+module_init(hfi_vnic_init_module);
+
+/* hfi_vnic_exit_module - driver Exit cleanup routine */
+static void __exit hfi_vnic_exit_module(void)
+{
+	hfi_vnic_driver_unregister(&hfi_vnic_drv);
+}
+module_exit(hfi_vnic_exit_module);
+
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_AUTHOR("Intel Corporation");
+MODULE_DESCRIPTION("Intel HFI Virtual Network Controller driver");
+MODULE_VERSION(DRV_VERSION);
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
