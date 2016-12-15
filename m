From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC v2 03/10] IB/hfi-vnic: Virtual Network Interface Controller (VNIC) netdev
Date: Wed, 14 Dec 2016 23:59:35 -0800
Message-ID: <1481788782-89964-4-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sudeep Dutt <sudeep.dutt-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Andrzej Kacprowski <andrzej.kacprowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

HFI VNIC netdev function supports Ethernet functionality over Omni-Path
fabric by encapsulating Ethernet packets inside Omni-Path packet header.
It interfaces with the network stack to provide standard Ethernet network
interfaces. It invokes HFI device's VNIC callback functions for HW access.

Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Reviewed-by: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sudeep Dutt <sudeep.dutt-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Andrzej Kacprowski <andrzej.kacprowski-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 MAINTAINERS                                        |   7 +
 drivers/infiniband/Kconfig                         |   1 +
 drivers/infiniband/sw/Makefile                     |   1 +
 drivers/infiniband/sw/intel/hfi_vnic/Kconfig       |   8 +
 drivers/infiniband/sw/intel/hfi_vnic/Makefile      |   6 +
 .../infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c  | 238 ++++++++++++
 .../infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.h  |  62 ++++
 .../sw/intel/hfi_vnic/hfi_vnic_ethtool.c           |  65 ++++
 .../sw/intel/hfi_vnic/hfi_vnic_internal.h          | 220 +++++++++++
 .../infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c | 409 +++++++++++++++++++++
 10 files changed, 1017 insertions(+)
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/Kconfig
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/Makefile
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.h
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_ethtool.c
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h
 create mode 100644 drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 2c7a7b6..62db3ea 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5628,6 +5628,13 @@ F:	drivers/block/cciss*
 F:	include/linux/cciss_ioctl.h
 F:	include/uapi/linux/cciss_ioctl.h
 
+HFI-VNIC DRIVER
+M:	Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
+M:	Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
+L:	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+S:	Supported
+F:	drivers/infiniband/sw/intel/hfi_vnic
+
 HFI1 DRIVER
 M:	Mike Marciniszyn <mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 M:	Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index 6709173..900daf3 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -85,6 +85,7 @@ source "drivers/infiniband/ulp/srpt/Kconfig"
 source "drivers/infiniband/ulp/iser/Kconfig"
 source "drivers/infiniband/ulp/isert/Kconfig"
 
+source "drivers/infiniband/sw/intel/hfi_vnic/Kconfig"
 source "drivers/infiniband/sw/rdmavt/Kconfig"
 source "drivers/infiniband/sw/rxe/Kconfig"
 
diff --git a/drivers/infiniband/sw/Makefile b/drivers/infiniband/sw/Makefile
index 8b095b2..2792559 100644
--- a/drivers/infiniband/sw/Makefile
+++ b/drivers/infiniband/sw/Makefile
@@ -1,2 +1,3 @@
 obj-$(CONFIG_INFINIBAND_RDMAVT)		+= rdmavt/
 obj-$(CONFIG_RDMA_RXE)			+= rxe/
+obj-$(CONFIG_HFI_VNIC)			+= intel/hfi_vnic/
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/Kconfig b/drivers/infiniband/sw/intel/hfi_vnic/Kconfig
new file mode 100644
index 0000000..84d13e7
--- /dev/null
+++ b/drivers/infiniband/sw/intel/hfi_vnic/Kconfig
@@ -0,0 +1,8 @@
+config HFI_VNIC
+	tristate "Intel HFI VNIC support"
+	depends on X86_64 && INFINIBAND
+	---help---
+	This is HFI Virtual Network Interface Controller (VNIC) driver
+	for Ethernet over HFI feature. It implements the HW independent
+	VNIC functionality. It interfaces with Linux stack for data path
+	and IB MAD for the control path.
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/Makefile b/drivers/infiniband/sw/intel/hfi_vnic/Makefile
new file mode 100644
index 0000000..8e3dca7
--- /dev/null
+++ b/drivers/infiniband/sw/intel/hfi_vnic/Makefile
@@ -0,0 +1,6 @@
+# Makefile - Intel HFI Virtual Network Controller driver
+# Copyright(c) 2016, Intel Corporation.
+#
+obj-$(CONFIG_HFI_VNIC) += hfi_vnic.o
+
+hfi_vnic-y := hfi_vnic_netdev.o hfi_vnic_encap.o hfi_vnic_ethtool.o
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c
new file mode 100644
index 0000000..093df67
--- /dev/null
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.c
@@ -0,0 +1,238 @@
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
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.h b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.h
new file mode 100644
index 0000000..6786cce
--- /dev/null
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_encap.h
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
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_ethtool.c b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_ethtool.c
new file mode 100644
index 0000000..0b4da5e
--- /dev/null
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_ethtool.c
@@ -0,0 +1,65 @@
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
+#include "hfi_vnic_internal.h"
+
+/* ethtool ops */
+static const struct ethtool_ops hfi_vnic_ethtool_ops = {
+	.get_link = ethtool_op_get_link,
+};
+
+/* hfi_vnic_set_ethtool_ops - set ethtool ops */
+void hfi_vnic_set_ethtool_ops(struct net_device *netdev)
+{
+	netdev->ethtool_ops = &hfi_vnic_ethtool_ops;
+}
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h
new file mode 100644
index 0000000..30731b4
--- /dev/null
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_internal.h
@@ -0,0 +1,220 @@
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
+#include <rdma/opa_hfi.h>
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
+	u16  def_port_mask;
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
+ * @vport: pointer to hfi vnic port
+ * @flags: flags indicating various states
+ * @lock: adapter lock
+ * @rxq: receive queue array
+ * @info: virtual ethernet switch port information
+ * @flow_tbl: flow to default port redirection table
+ */
+struct hfi_vnic_adapter {
+	struct net_device             *netdev;
+	struct hfi_vnic_port          *vport;
+	unsigned long                  flags;
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
+
+struct hfi_vnic_adapter *hfi_vnic_add_netdev(struct hfi_vnic_port *vport,
+					     struct device *parent);
+void hfi_vnic_rem_netdev(struct hfi_vnic_port *vport);
+int hfi_vnic_encap_skb(struct hfi_vnic_adapter *adapter, struct sk_buff *skb);
+int hfi_vnic_decap_skb(struct hfi_vnic_rx_queue *rxq, struct sk_buff *skb);
+u8 hfi_vnic_calc_entropy(struct hfi_vnic_adapter *adapter, struct sk_buff *skb);
+void hfi_vnic_set_ethtool_ops(struct net_device *netdev);
+
+#endif /* _HFI_VNIC_INTERNAL_H */
diff --git a/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c
new file mode 100644
index 0000000..6360d37
--- /dev/null
+++ b/drivers/infiniband/sw/intel/hfi_vnic/hfi_vnic_netdev.c
@@ -0,0 +1,409 @@
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
+#include "hfi_vnic_internal.h"
+
+#define HFI_TX_TIMEOUT_MS 1000
+
+#define HFI_VNIC_MIN_ETH_MTU (ETH_ZLEN - ETH_HLEN)
+
+/* hfi_vnic_maybe_stop_tx - stop tx queue if required */
+static void hfi_vnic_maybe_stop_tx(struct hfi_vnic_adapter *adapter, u8 q_idx)
+{
+	struct hfi_vnic_port *vport = adapter->vport;
+
+	netif_stop_subqueue(vport->netdev, q_idx);
+	if (!vport->ops->get_write_avail(vport, q_idx))
+		return;
+
+	netif_start_subqueue(vport->netdev, q_idx);
+}
+
+/* hfi_netdev_start_xmit - transmit function */
+static netdev_tx_t hfi_netdev_start_xmit(struct sk_buff *skb,
+					 struct net_device *netdev)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	struct hfi_vnic_port *vport = adapter->vport;
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
+	rc = vport->ops->put_skb(vport, q_idx, skb);
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
+	struct hfi_vnic_port *vport = adapter->vport;
+	struct sk_buff *skb;
+
+	while (1) {
+		if (*work_done >= work_to_do)
+			break;
+
+		skb = vport->ops->get_skb(vport, rxq->idx);
+		if (!skb)
+			break;
+
+		if (hfi_vnic_decap_skb(rxq, skb)) {
+			dev_kfree_skb_any(skb);
+			continue;
+		}
+
+		skb_checksum_none_assert(skb);
+		skb->protocol = eth_type_trans(skb, vport->netdev);
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
+	struct hfi_vnic_port *vport = adapter->vport;
+	u8 evt = rxq->idx + HFI_VNIC_EVT_RX0;
+	int work_done = 0;
+
+	v_dbg("napi %d budget %d\n", rxq->idx, budget);
+	vnic_handle_rx(rxq, &work_done, budget);
+
+	v_dbg("napi %d work_done %d\n", rxq->idx, work_done);
+	if (work_done < budget) {
+		napi_complete(napi);
+		vport->ops->config_notify(vport, evt, true);
+	}
+
+	return work_done;
+}
+
+/* vnic_event_cb - handle events from vnic hfi driver */
+static void vnic_event_cb(struct hfi_vnic_port *vport, u8 evt)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(vport->netdev);
+	struct hfi_vnic_rx_queue *rxq;
+	u8 q_idx;
+
+	v_dbg("received event %d\n", evt);
+	if (evt < vport->hfi_info.num_rx_q) {
+		q_idx = evt;
+		if (unlikely(adapter->info.vport.oper_state !=
+			     HFI_VNIC_STATE_FORWARDING))
+			return;
+
+		rxq = &adapter->rxq[q_idx];
+		if (napi_schedule_prep(&rxq->napi)) {
+			v_dbg("napi %d scheduling\n", q_idx);
+			vport->ops->config_notify(vport, evt, false);
+			__napi_schedule(&rxq->napi);
+		}
+		return;
+	}
+	if ((evt >= HFI_VNIC_EVT_TX0) &&
+	    (evt < (HFI_VNIC_EVT_TX0 + vport->hfi_info.num_tx_q))) {
+		q_idx = evt - HFI_VNIC_EVT_TX0;
+
+		if (__netif_subqueue_stopped(vport->netdev, q_idx))
+			netif_wake_subqueue(vport->netdev, q_idx);
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
+	struct hfi_vnic_port *vport = adapter->vport;
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
+	return vport->ops->select_queue(vport, vl, entropy);
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
+	struct hfi_vnic_port *vport = adapter->vport;
+	int i, rc;
+
+	rc = vport->ops->open(vport, vnic_event_cb);
+	if (rc) {
+		v_dbg("hfi_open failed %d\n", rc);
+		return rc;
+	}
+
+	netif_carrier_on(adapter->netdev);
+	netif_tx_start_all_queues(adapter->netdev);
+	for (i = 0; i < vport->hfi_info.num_rx_q; i++)
+		napi_enable(&adapter->rxq[i].napi);
+
+	set_bit(HFI_VNIC_UP, &adapter->flags);
+	return 0;
+}
+
+/* hfi_vnic_down - disable vnic data flow */
+static void hfi_vnic_down(struct hfi_vnic_adapter *adapter)
+{
+	struct hfi_vnic_port *vport = adapter->vport;
+	int i;
+
+	netif_carrier_off(adapter->netdev);
+	netif_tx_disable(adapter->netdev);
+	for (i = 0; i < vport->hfi_info.num_rx_q; i++)
+		napi_disable(&adapter->rxq[i].napi);
+
+	vport->ops->close(vport);
+	clear_bit(HFI_VNIC_UP, &adapter->flags);
+}
+
+/* hfi_vnic_set_mac_addr - change mac address */
+static int hfi_vnic_set_mac_addr(struct net_device *netdev, void *addr)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(netdev);
+	struct sockaddr *sa = addr;
+	int rc;
+
+	if (!memcmp(netdev->dev_addr, sa->sa_data, ETH_ALEN))
+		return 0;
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
+/* hfi_vnic_add_netdev - create vnic netdev interface */
+struct hfi_vnic_adapter *hfi_vnic_add_netdev(struct hfi_vnic_port *vport,
+					     struct device *parent)
+{
+	struct net_device *netdev;
+	struct hfi_vnic_adapter *adapter;
+	int i, rc;
+
+	netdev = alloc_etherdev_mqs(sizeof(struct hfi_vnic_adapter),
+				    vport->hfi_info.num_tx_q,
+				    vport->hfi_info.num_rx_q);
+	if (!netdev)
+		return ERR_PTR(-ENOMEM);
+	adapter = netdev_priv(netdev);
+	adapter->netdev = netdev;
+	adapter->vport = vport;
+	vport->netdev = netdev;
+	netdev->features = NETIF_F_HIGHDMA;
+	if (vport->hfi_info.cap & HFI_VNIC_CAP_SG)
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
+	SET_NETDEV_DEV(netdev, parent);
+
+	hfi_vnic_set_ethtool_ops(netdev);
+	for (i = 0; i < vport->hfi_info.num_rx_q; i++) {
+		adapter->rxq[i].idx = i;
+		adapter->rxq[i].adapter = adapter;
+		netif_napi_add(netdev, &adapter->rxq[i].napi, vnic_napi, 64);
+	}
+
+	rc = register_netdev(netdev);
+	if (rc)
+		goto netdev_err;
+
+	netif_carrier_off(netdev);
+	v_info("initialized\n");
+
+	return adapter;
+netdev_err:
+	mutex_destroy(&adapter->lock);
+	free_netdev(netdev);
+
+	return ERR_PTR(rc);
+}
+
+/* hfi_vnic_rem_netdev - remove vnic netdev interface */
+void hfi_vnic_rem_netdev(struct hfi_vnic_port *vport)
+{
+	struct hfi_vnic_adapter *adapter = netdev_priv(vport->netdev);
+
+	v_info("removing\n");
+	unregister_netdev(vport->netdev);
+	mutex_destroy(&adapter->lock);
+	free_netdev(vport->netdev);
+}
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
