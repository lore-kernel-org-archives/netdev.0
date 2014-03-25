From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH V14 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Tue, 25 Mar 2014 12:10:54 -0700
Message-ID: <01ae01cf485d$f2e695b0$d8b3c110$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:47640 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbaCYTLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 15:11:03 -0400
Content-language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Reddy <siva.kallam@samsung.com>

This patch adds support for Samsung 10Gb ethernet driver(sxgbe).

- sxgbe core initialization
- Tx and Rx support
- MDIO support
- ISRs for Tx and Rx
- ifconfig support to driver

Signed-off-by: Siva Reddy Kallam <siva.kallam@samsung.com>
Signed-off-by: Vipul Pandya <vipul.pandya@samsung.com>
Signed-off-by: Girish K S <ks.giri@samsung.com>
Neatening-by: Joe Perches <joe@perches.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/samsung/Kconfig               |   16 +
 drivers/net/ethernet/samsung/Makefile              |    5 +
 drivers/net/ethernet/samsung/sxgbe/Kconfig         |    9 +
 drivers/net/ethernet/samsung/sxgbe/Makefile        |    4 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h  |  462 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c    |  158 ++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c    |  515 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h    |  298 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c     |  372 ++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h     |   48 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c |   44 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    | 2052 ++++++++++++++++++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c    |  251 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c     |  254 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.h     |  104 +
 .../net/ethernet/samsung/sxgbe/sxgbe_platform.c    |  253 +++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h     |  477 +++++
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c    |   91 +
 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h    |   38 +
 include/linux/sxgbe_platform.h                     |   54 +
 22 files changed, 5507 insertions(+)
 create mode 100644 drivers/net/ethernet/samsung/Kconfig
 create mode 100644 drivers/net/ethernet/samsung/Makefile
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/Kconfig
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/Makefile
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.h
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c
 create mode 100644 drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h
 create mode 100644 include/linux/sxgbe_platform.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 506b024..d4545fa 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -149,6 +149,7 @@ config S6GMAC
 	  To compile this driver as a module, choose M here. The module
 	  will be called s6gmac.
 
+source "drivers/net/ethernet/samsung/Kconfig"
 source "drivers/net/ethernet/seeq/Kconfig"
 source "drivers/net/ethernet/silan/Kconfig"
 source "drivers/net/ethernet/sis/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index c0b8789..2a53f84 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -60,6 +60,7 @@ obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_SH_ETH) += renesas/
 obj-$(CONFIG_NET_VENDOR_RDC) += rdc/
 obj-$(CONFIG_S6GMAC) += s6gmac.o
+obj-$(CONFIG_NET_VENDOR_SAMSUNG) += samsung/
 obj-$(CONFIG_NET_VENDOR_SEEQ) += seeq/
 obj-$(CONFIG_NET_VENDOR_SILAN) += silan/
 obj-$(CONFIG_NET_VENDOR_SIS) += sis/
diff --git a/drivers/net/ethernet/samsung/Kconfig b/drivers/net/ethernet/samsung/Kconfig
new file mode 100644
index 0000000..7902341
--- /dev/null
+++ b/drivers/net/ethernet/samsung/Kconfig
@@ -0,0 +1,16 @@
+#
+# Samsung Ethernet device configuration
+#
+
+config NET_VENDOR_SAMSUNG
+	bool "Samsung Ethernet device"
+	default y
+	---help---
+	  This is the driver for the SXGBE 10G Ethernet IP block found on Samsung
+	  platforms.
+
+if NET_VENDOR_SAMSUNG
+
+source "drivers/net/ethernet/samsung/sxgbe/Kconfig"
+
+endif # NET_VENDOR_SAMSUNG
diff --git a/drivers/net/ethernet/samsung/Makefile b/drivers/net/ethernet/samsung/Makefile
new file mode 100644
index 0000000..1773c29
--- /dev/null
+++ b/drivers/net/ethernet/samsung/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Samsung Ethernet device drivers.
+#
+
+obj-$(CONFIG_SXGBE_ETH) += sxgbe/
diff --git a/drivers/net/ethernet/samsung/sxgbe/Kconfig b/drivers/net/ethernet/samsung/sxgbe/Kconfig
new file mode 100644
index 0000000..d79288c
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/Kconfig
@@ -0,0 +1,9 @@
+config SXGBE_ETH
+	tristate "Samsung 10G/2.5G/1G SXGBE Ethernet driver"
+	depends on HAS_IOMEM && HAS_DMA
+	select PHYLIB
+	select CRC32
+	select PTP_1588_CLOCK
+	---help---
+	  This is the driver for the SXGBE 10G Ethernet IP block found on Samsung
+	  platforms.
diff --git a/drivers/net/ethernet/samsung/sxgbe/Makefile b/drivers/net/ethernet/samsung/sxgbe/Makefile
new file mode 100644
index 0000000..dcc80b9
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/Makefile
@@ -0,0 +1,4 @@
+obj-$(CONFIG_SXGBE_ETH) += samsung-sxgbe.o
+samsung-sxgbe-objs:= sxgbe_platform.o sxgbe_main.o sxgbe_desc.o \
+		sxgbe_dma.o sxgbe_core.o sxgbe_mtl.o  sxgbe_mdio.o \
+		sxgbe_ethtool.o sxgbe_xpcs.o $(samsung-sxgbe-y)
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
new file mode 100644
index 0000000..c7803f1
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h
@@ -0,0 +1,462 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#ifndef __SXGBE_COMMON_H__
+#define __SXGBE_COMMON_H__
+
+/* forward references */
+struct sxgbe_desc_ops;
+struct sxgbe_dma_ops;
+struct sxgbe_mtl_ops;
+
+#define SXGBE_RESOURCE_NAME	"sam_sxgbeeth"
+#define DRV_MODULE_VERSION	"November_2013"
+
+/* MAX HW feature words */
+#define SXGBE_HW_WORDS 3
+
+#define SXGBE_RX_COE_NONE	0
+
+/* CSR Frequency Access Defines*/
+#define SXGBE_CSR_F_150M	150000000
+#define SXGBE_CSR_F_250M	250000000
+#define SXGBE_CSR_F_300M	300000000
+#define SXGBE_CSR_F_350M	350000000
+#define SXGBE_CSR_F_400M	400000000
+#define SXGBE_CSR_F_500M	500000000
+
+/* pause time */
+#define SXGBE_PAUSE_TIME 0x200
+
+/* tx queues */
+#define SXGBE_TX_QUEUES   8
+#define SXGBE_RX_QUEUES   16
+
+/* Calculated based how much time does it take to fill 256KB Rx memory
+ * at 10Gb speed at 156MHz clock rate and considered little less then
+ * the actual value.
+ */
+#define SXGBE_MAX_DMA_RIWT	0x70
+#define SXGBE_MIN_DMA_RIWT	0x01
+
+/* Tx coalesce parameters */
+#define SXGBE_COAL_TX_TIMER	40000
+#define SXGBE_MAX_COAL_TX_TICK	100000
+#define SXGBE_TX_MAX_FRAMES	512
+#define SXGBE_TX_FRAMES	128
+
+/* SXGBE TX FIFO is 8K, Rx FIFO is 16K */
+#define BUF_SIZE_16KiB 16384
+#define BUF_SIZE_8KiB 8192
+#define BUF_SIZE_4KiB 4096
+#define BUF_SIZE_2KiB 2048
+
+#define SXGBE_DEFAULT_LIT_LS	0x3E8
+#define SXGBE_DEFAULT_TWT_LS	0x0
+
+/* Flow Control defines */
+#define SXGBE_FLOW_OFF		0
+#define SXGBE_FLOW_RX		1
+#define SXGBE_FLOW_TX		2
+#define SXGBE_FLOW_AUTO		(SXGBE_FLOW_TX | SXGBE_FLOW_RX)
+
+#define SF_DMA_MODE 1		/* DMA STORE-AND-FORWARD Operation Mode */
+
+/* errors */
+#define RX_GMII_ERR		0x01
+#define RX_WATCHDOG_ERR		0x02
+#define RX_CRC_ERR		0x03
+#define RX_GAINT_ERR		0x04
+#define RX_IP_HDR_ERR		0x05
+#define RX_PAYLOAD_ERR		0x06
+#define RX_OVERFLOW_ERR		0x07
+
+/* pkt type */
+#define RX_LEN_PKT		0x00
+#define RX_MACCTL_PKT		0x01
+#define RX_DCBCTL_PKT		0x02
+#define RX_ARP_PKT		0x03
+#define RX_OAM_PKT		0x04
+#define RX_UNTAG_PKT		0x05
+#define RX_OTHER_PKT		0x07
+#define RX_SVLAN_PKT		0x08
+#define RX_CVLAN_PKT		0x09
+#define RX_DVLAN_OCVLAN_ICVLAN_PKT		0x0A
+#define RX_DVLAN_OSVLAN_ISVLAN_PKT		0x0B
+#define RX_DVLAN_OSVLAN_ICVLAN_PKT		0x0C
+#define RX_DVLAN_OCVLAN_ISVLAN_PKT		0x0D
+
+#define RX_NOT_IP_PKT		0x00
+#define RX_IPV4_TCP_PKT		0x01
+#define RX_IPV4_UDP_PKT		0x02
+#define RX_IPV4_ICMP_PKT	0x03
+#define RX_IPV4_UNKNOWN_PKT	0x07
+#define RX_IPV6_TCP_PKT		0x09
+#define RX_IPV6_UDP_PKT		0x0A
+#define RX_IPV6_ICMP_PKT	0x0B
+#define RX_IPV6_UNKNOWN_PKT	0x0F
+
+#define RX_NO_PTP		0x00
+#define RX_PTP_SYNC		0x01
+#define RX_PTP_FOLLOW_UP	0x02
+#define RX_PTP_DELAY_REQ	0x03
+#define RX_PTP_DELAY_RESP	0x04
+#define RX_PTP_PDELAY_REQ	0x05
+#define RX_PTP_PDELAY_RESP	0x06
+#define RX_PTP_PDELAY_FOLLOW_UP	0x07
+#define RX_PTP_ANNOUNCE		0x08
+#define RX_PTP_MGMT		0x09
+#define RX_PTP_SIGNAL		0x0A
+#define RX_PTP_RESV_MSG		0x0F
+
+enum dma_irq_status {
+	tx_hard_error	= BIT(0),
+	tx_bump_tc	= BIT(1),
+	handle_tx	= BIT(2),
+	rx_hard_error	= BIT(3),
+	rx_bump_tc	= BIT(4),
+	handle_rx	= BIT(5),
+};
+
+#define NETIF_F_HW_VLAN_ALL     (NETIF_F_HW_VLAN_CTAG_RX |	\
+				 NETIF_F_HW_VLAN_STAG_RX |	\
+				 NETIF_F_HW_VLAN_CTAG_TX |	\
+				 NETIF_F_HW_VLAN_STAG_TX |	\
+				 NETIF_F_HW_VLAN_CTAG_FILTER |	\
+				 NETIF_F_HW_VLAN_STAG_FILTER)
+
+/* MMC control defines */
+#define SXGBE_MMC_CTRL_CNT_FRZ  0x00000008
+
+/* SXGBE HW ADDR regs */
+#define SXGBE_ADDR_HIGH(reg)    (((reg > 15) ? 0x00000800 : 0x00000040) + \
+				 (reg * 8))
+#define SXGBE_ADDR_LOW(reg)     (((reg > 15) ? 0x00000804 : 0x00000044) + \
+				 (reg * 8))
+#define SXGBE_MAX_PERFECT_ADDRESSES 32 /* Maximum unicast perfect filtering */
+#define SXGBE_FRAME_FILTER       0x00000004      /* Frame Filter */
+
+/* SXGBE Frame Filter defines */
+#define SXGBE_FRAME_FILTER_PR    0x00000001      /* Promiscuous Mode */
+#define SXGBE_FRAME_FILTER_HUC   0x00000002      /* Hash Unicast */
+#define SXGBE_FRAME_FILTER_HMC   0x00000004      /* Hash Multicast */
+#define SXGBE_FRAME_FILTER_DAIF  0x00000008      /* DA Inverse Filtering */
+#define SXGBE_FRAME_FILTER_PM    0x00000010      /* Pass all multicast */
+#define SXGBE_FRAME_FILTER_DBF   0x00000020      /* Disable Broadcast frames */
+#define SXGBE_FRAME_FILTER_SAIF  0x00000100      /* Inverse Filtering */
+#define SXGBE_FRAME_FILTER_SAF   0x00000200      /* Source Address Filter */
+#define SXGBE_FRAME_FILTER_HPF   0x00000400      /* Hash or perfect Filter */
+#define SXGBE_FRAME_FILTER_RA    0x80000000      /* Receive all mode */
+
+#define SXGBE_HASH_TABLE_SIZE    64
+#define SXGBE_HASH_HIGH          0x00000008      /* Multicast Hash Table High */
+#define SXGBE_HASH_LOW           0x0000000c      /* Multicast Hash Table Low */
+
+#define SXGBE_HI_REG_AE          0x80000000
+
+/* Minimum and maximum MTU */
+#define MIN_MTU         68
+#define MAX_MTU         9000
+
+#define SXGBE_FOR_EACH_QUEUE(max_queues, queue_num)			\
+	for (queue_num = 0; queue_num < max_queues; queue_num++)
+
+/* sxgbe statistics counters */
+struct sxgbe_extra_stats {
+	/* TX/RX IRQ events */
+	unsigned long tx_underflow_irq;
+	unsigned long tx_process_stopped_irq;
+	unsigned long tx_ctxt_desc_err;
+	unsigned long tx_threshold;
+	unsigned long rx_threshold;
+	unsigned long tx_pkt_n;
+	unsigned long rx_pkt_n;
+	unsigned long normal_irq_n;
+	unsigned long tx_normal_irq_n;
+	unsigned long rx_normal_irq_n;
+	unsigned long napi_poll;
+	unsigned long tx_clean;
+	unsigned long tx_reset_ic_bit;
+	unsigned long rx_process_stopped_irq;
+	unsigned long rx_underflow_irq;
+
+	/* Bus access errors */
+	unsigned long fatal_bus_error_irq;
+	unsigned long tx_read_transfer_err;
+	unsigned long tx_write_transfer_err;
+	unsigned long tx_desc_access_err;
+	unsigned long tx_buffer_access_err;
+	unsigned long tx_data_transfer_err;
+	unsigned long rx_read_transfer_err;
+	unsigned long rx_write_transfer_err;
+	unsigned long rx_desc_access_err;
+	unsigned long rx_buffer_access_err;
+	unsigned long rx_data_transfer_err;
+
+	/* RX specific */
+	/* L2 error */
+	unsigned long rx_code_gmii_err;
+	unsigned long rx_watchdog_err;
+	unsigned long rx_crc_err;
+	unsigned long rx_gaint_pkt_err;
+	unsigned long ip_hdr_err;
+	unsigned long ip_payload_err;
+	unsigned long overflow_error;
+
+	/* L2 Pkt type */
+	unsigned long len_pkt;
+	unsigned long mac_ctl_pkt;
+	unsigned long dcb_ctl_pkt;
+	unsigned long arp_pkt;
+	unsigned long oam_pkt;
+	unsigned long untag_okt;
+	unsigned long other_pkt;
+	unsigned long svlan_tag_pkt;
+	unsigned long cvlan_tag_pkt;
+	unsigned long dvlan_ocvlan_icvlan_pkt;
+	unsigned long dvlan_osvlan_isvlan_pkt;
+	unsigned long dvlan_osvlan_icvlan_pkt;
+	unsigned long dvan_ocvlan_icvlan_pkt;
+
+	/* L3/L4 Pkt type */
+	unsigned long not_ip_pkt;
+	unsigned long ip4_tcp_pkt;
+	unsigned long ip4_udp_pkt;
+	unsigned long ip4_icmp_pkt;
+	unsigned long ip4_unknown_pkt;
+	unsigned long ip6_tcp_pkt;
+	unsigned long ip6_udp_pkt;
+	unsigned long ip6_icmp_pkt;
+	unsigned long ip6_unknown_pkt;
+
+	/* Filter specific */
+	unsigned long vlan_filter_match;
+	unsigned long sa_filter_fail;
+	unsigned long da_filter_fail;
+	unsigned long hash_filter_pass;
+	unsigned long l3_filter_match;
+	unsigned long l4_filter_match;
+
+	/* RX context specific */
+	unsigned long timestamp_dropped;
+	unsigned long rx_msg_type_no_ptp;
+	unsigned long rx_ptp_type_sync;
+	unsigned long rx_ptp_type_follow_up;
+	unsigned long rx_ptp_type_delay_req;
+	unsigned long rx_ptp_type_delay_resp;
+	unsigned long rx_ptp_type_pdelay_req;
+	unsigned long rx_ptp_type_pdelay_resp;
+	unsigned long rx_ptp_type_pdelay_follow_up;
+	unsigned long rx_ptp_announce;
+	unsigned long rx_ptp_mgmt;
+	unsigned long rx_ptp_signal;
+	unsigned long rx_ptp_resv_msg_type;
+};
+
+struct mac_link {
+	int port;
+	int duplex;
+	int speed;
+};
+
+struct mii_regs {
+	unsigned int addr;	/* MII Address */
+	unsigned int data;	/* MII Data */
+};
+
+struct sxgbe_core_ops {
+	/* MAC core initialization */
+	void (*core_init)(void __iomem *ioaddr);
+	/* Dump MAC registers */
+	void (*dump_regs)(void __iomem *ioaddr);
+	/* Handle extra events on specific interrupts hw dependent */
+	int (*host_irq_status)(void __iomem *ioaddr,
+			       struct sxgbe_extra_stats *x);
+	/* Set power management mode (e.g. magic frame) */
+	void (*pmt)(void __iomem *ioaddr, unsigned long mode);
+	/* Set/Get Unicast MAC addresses */
+	void (*set_umac_addr)(void __iomem *ioaddr, unsigned char *addr,
+			      unsigned int reg_n);
+	void (*get_umac_addr)(void __iomem *ioaddr, unsigned char *addr,
+			      unsigned int reg_n);
+	void (*enable_rx)(void __iomem *ioaddr, bool enable);
+	void (*enable_tx)(void __iomem *ioaddr, bool enable);
+
+	/* controller version specific operations */
+	int (*get_controller_version)(void __iomem *ioaddr);
+
+	/* If supported then get the optional core features */
+	unsigned int (*get_hw_feature)(void __iomem *ioaddr,
+				       unsigned char feature_index);
+	/* adjust SXGBE speed */
+	void (*set_speed)(void __iomem *ioaddr, unsigned char speed);
+};
+
+const struct sxgbe_core_ops *sxgbe_get_core_ops(void);
+
+struct sxgbe_ops {
+	const struct sxgbe_core_ops *mac;
+	const struct sxgbe_desc_ops *desc;
+	const struct sxgbe_dma_ops *dma;
+	const struct sxgbe_mtl_ops *mtl;
+	struct mii_regs mii;	/* MII register Addresses */
+	struct mac_link link;
+	unsigned int ctrl_uid;
+	unsigned int ctrl_id;
+};
+
+/* SXGBE private data structures */
+struct sxgbe_tx_queue {
+	unsigned int irq_no;
+	struct sxgbe_priv_data *priv_ptr;
+	struct sxgbe_tx_norm_desc *dma_tx;
+	dma_addr_t dma_tx_phy;
+	dma_addr_t *tx_skbuff_dma;
+	struct sk_buff **tx_skbuff;
+	struct timer_list txtimer;
+	spinlock_t tx_lock;	/* lock for tx queues */
+	unsigned int cur_tx;
+	unsigned int dirty_tx;
+	u32 tx_count_frames;
+	u32 tx_coal_frames;
+	u32 tx_coal_timer;
+	int hwts_tx_en;
+	u8 queue_no;
+};
+
+struct sxgbe_rx_queue {
+	struct sxgbe_priv_data *priv_ptr;
+	struct sxgbe_rx_norm_desc *dma_rx;
+	struct sk_buff **rx_skbuff;
+	unsigned int cur_rx;
+	unsigned int dirty_rx;
+	unsigned int irq_no;
+	u32 rx_riwt;
+	dma_addr_t *rx_skbuff_dma;
+	dma_addr_t dma_rx_phy;
+	u8 queue_no;
+};
+
+/* SXGBE HW capabilities */
+struct sxgbe_hw_features {
+	/****** CAP [0] *******/
+	unsigned int pmt_remote_wake_up;
+	unsigned int pmt_magic_frame;
+	/* IEEE 1588-2008 */
+	unsigned int atime_stamp;
+
+	unsigned int tx_csum_offload;
+	unsigned int rx_csum_offload;
+	unsigned int multi_macaddr;
+	unsigned int tstamp_srcselect;
+	unsigned int sa_vlan_insert;
+
+	/****** CAP [1] *******/
+	unsigned int rxfifo_size;
+	unsigned int txfifo_size;
+	unsigned int atstmap_hword;
+	unsigned int dcb_enable;
+	unsigned int splithead_enable;
+	unsigned int tcpseg_offload;
+	unsigned int debug_mem;
+	unsigned int rss_enable;
+	unsigned int hash_tsize;
+	unsigned int l3l4_filer_size;
+
+	/* This value is in bytes and
+	 * as mentioned in HW features
+	 * of SXGBE data book
+	 */
+	unsigned int rx_mtl_qsize;
+	unsigned int tx_mtl_qsize;
+
+	/****** CAP [2] *******/
+	/* TX and RX number of channels */
+	unsigned int rx_mtl_queues;
+	unsigned int tx_mtl_queues;
+	unsigned int rx_dma_channels;
+	unsigned int tx_dma_channels;
+	unsigned int pps_output_count;
+	unsigned int aux_input_count;
+};
+
+struct sxgbe_priv_data {
+	/* DMA descriptos */
+	struct sxgbe_tx_queue *txq[SXGBE_TX_QUEUES];
+	struct sxgbe_rx_queue *rxq[SXGBE_RX_QUEUES];
+	u8 cur_rx_qnum;
+
+	unsigned int dma_tx_size;
+	unsigned int dma_rx_size;
+	unsigned int dma_buf_sz;
+	u32 rx_riwt;
+
+	struct napi_struct napi;
+
+	void __iomem *ioaddr;
+	struct net_device *dev;
+	struct device *device;
+	struct sxgbe_ops *hw;	/* sxgbe specific ops */
+	int no_csum_insertion;
+	int irq;
+	spinlock_t stats_lock;	/* lock for tx/rx statatics */
+
+	struct phy_device *phydev;
+	int oldlink;
+	int speed;
+	int oldduplex;
+	struct mii_bus *mii;
+	int mii_irq[PHY_MAX_ADDR];
+	u8 rx_pause;
+	u8 tx_pause;
+
+	struct sxgbe_extra_stats xstats;
+	struct sxgbe_plat_data *plat;
+	struct sxgbe_hw_features hw_cap;
+
+	u32 msg_enable;
+
+	struct clk *sxgbe_clk;
+	int clk_csr;
+	unsigned int mode;
+	unsigned int default_addend;
+
+	/* advanced time stamp support */
+	u32 adv_ts;
+	int use_riwt;
+
+	/* tc control */
+	int tx_tc;
+	int rx_tc;
+};
+
+/* Function prototypes */
+struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
+					struct sxgbe_plat_data *plat_dat,
+					void __iomem *addr);
+int sxgbe_drv_remove(struct net_device *ndev);
+void sxgbe_set_ethtool_ops(struct net_device *netdev);
+int sxgbe_mdio_unregister(struct net_device *ndev);
+int sxgbe_mdio_register(struct net_device *ndev);
+int sxgbe_register_platform(void);
+void sxgbe_unregister_platform(void);
+
+#ifdef CONFIG_PM
+int sxgbe_suspend(struct net_device *ndev);
+int sxgbe_resume(struct net_device *ndev);
+int sxgbe_freeze(struct net_device *ndev);
+int sxgbe_restore(struct net_device *ndev);
+#endif /* CONFIG_PM */
+
+const struct sxgbe_mtl_ops *sxgbe_get_mtl_ops(void);
+
+#endif /* __SXGBE_COMMON_H__ */
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
new file mode 100644
index 0000000..4ad31bb
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c
@@ -0,0 +1,158 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/export.h>
+#include <linux/io.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#include "sxgbe_common.h"
+#include "sxgbe_reg.h"
+
+/* MAC core initialization */
+static void sxgbe_core_init(void __iomem *ioaddr)
+{
+	u32 regval;
+
+	/* TX configuration */
+	regval = readl(ioaddr + SXGBE_CORE_TX_CONFIG_REG);
+	/* Other configurable parameters IFP, IPG, ISR, ISM
+	 * needs to be set if needed
+	 */
+	regval |= SXGBE_TX_JABBER_DISABLE;
+	writel(regval, ioaddr + SXGBE_CORE_TX_CONFIG_REG);
+
+	/* RX configuration */
+	regval = readl(ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+	/* Other configurable parameters CST, SPEN, USP, GPSLCE
+	 * WD, LM, S2KP, HDSMS, GPSL, ELEN, ARPEN needs to be
+	 * set if needed
+	 */
+	regval |= SXGBE_RX_JUMBPKT_ENABLE | SXGBE_RX_ACS_ENABLE;
+	writel(regval, ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+}
+
+/* Dump MAC registers */
+static void sxgbe_core_dump_regs(void __iomem *ioaddr)
+{
+}
+
+/* Handle extra events on specific interrupts hw dependent */
+static int sxgbe_core_host_irq_status(void __iomem *ioaddr,
+				      struct sxgbe_extra_stats *x)
+{
+	return 0;
+}
+
+/* Set power management mode (e.g. magic frame) */
+static void sxgbe_core_pmt(void __iomem *ioaddr, unsigned long mode)
+{
+}
+
+/* Set/Get Unicast MAC addresses */
+static void sxgbe_core_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
+				     unsigned int reg_n)
+{
+	u32 high_word, low_word;
+
+	high_word = (addr[5] << 8) || (addr[4]);
+	low_word = ((addr[3] << 24) || (addr[2] << 16) ||
+		    (addr[1] << 8) || (addr[0]));
+	writel(high_word, ioaddr + SXGBE_CORE_ADD_HIGHOFFSET(reg_n));
+	writel(low_word, ioaddr + SXGBE_CORE_ADD_LOWOFFSET(reg_n));
+}
+
+static void sxgbe_core_get_umac_addr(void __iomem *ioaddr, unsigned char *addr,
+				     unsigned int reg_n)
+{
+	u32 high_word, low_word;
+
+	high_word = readl(ioaddr + SXGBE_CORE_ADD_HIGHOFFSET(reg_n));
+	low_word = readl(ioaddr + SXGBE_CORE_ADD_LOWOFFSET(reg_n));
+
+	/* extract and assign address */
+	addr[5] = (high_word & 0x0000FF00) >> 8;
+	addr[4] = (high_word & 0x000000FF);
+	addr[3] = (low_word & 0xFF000000) >> 24;
+	addr[2] = (low_word & 0x00FF0000) >> 16;
+	addr[1] = (low_word & 0x0000FF00) >> 8;
+	addr[0] = (low_word & 0x000000FF);
+}
+
+static void sxgbe_enable_tx(void __iomem *ioaddr, bool enable)
+{
+	u32 tx_config;
+
+	tx_config = readl(ioaddr + SXGBE_CORE_TX_CONFIG_REG);
+	tx_config &= ~SXGBE_TX_ENABLE;
+
+	if (enable)
+		tx_config |= SXGBE_TX_ENABLE;
+	writel(tx_config, ioaddr + SXGBE_CORE_TX_CONFIG_REG);
+}
+
+static void sxgbe_enable_rx(void __iomem *ioaddr, bool enable)
+{
+	u32 rx_config;
+
+	rx_config = readl(ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+	rx_config &= ~SXGBE_RX_ENABLE;
+
+	if (enable)
+		rx_config |= SXGBE_RX_ENABLE;
+	writel(rx_config, ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+}
+
+static int sxgbe_get_controller_version(void __iomem *ioaddr)
+{
+	return readl(ioaddr + SXGBE_CORE_VERSION_REG);
+}
+
+/* If supported then get the optional core features */
+static unsigned int sxgbe_get_hw_feature(void __iomem *ioaddr,
+					 unsigned char feature_index)
+{
+	return readl(ioaddr + (SXGBE_CORE_HW_FEA_REG(feature_index)));
+}
+
+static void sxgbe_core_set_speed(void __iomem *ioaddr, unsigned char speed)
+{
+	u32 tx_cfg = readl(ioaddr + SXGBE_CORE_TX_CONFIG_REG);
+
+	/* clear the speed bits */
+	tx_cfg &= ~0x60000000;
+	tx_cfg |= (speed << SXGBE_SPEED_LSHIFT);
+
+	/* set the speed */
+	writel(tx_cfg, ioaddr + SXGBE_CORE_TX_CONFIG_REG);
+}
+
+const struct sxgbe_core_ops core_ops = {
+	.core_init		= sxgbe_core_init,
+	.dump_regs		= sxgbe_core_dump_regs,
+	.host_irq_status	= sxgbe_core_host_irq_status,
+	.pmt			= sxgbe_core_pmt,
+	.set_umac_addr		= sxgbe_core_set_umac_addr,
+	.get_umac_addr		= sxgbe_core_get_umac_addr,
+	.enable_rx		= sxgbe_enable_rx,
+	.enable_tx		= sxgbe_enable_tx,
+	.get_controller_version	= sxgbe_get_controller_version,
+	.get_hw_feature		= sxgbe_get_hw_feature,
+	.set_speed		= sxgbe_core_set_speed,
+};
+
+const struct sxgbe_core_ops *sxgbe_get_core_ops(void)
+{
+	return &core_ops;
+}
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
new file mode 100644
index 0000000..7cb5520
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.c
@@ -0,0 +1,515 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/bitops.h>
+#include <linux/export.h>
+#include <linux/io.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#include "sxgbe_common.h"
+#include "sxgbe_dma.h"
+#include "sxgbe_desc.h"
+
+/* DMA TX descriptor ring initialization */
+static void sxgbe_init_tx_desc(struct sxgbe_tx_norm_desc *p)
+{
+	p->tdes23.tx_rd_des23.own_bit = 0;
+}
+
+static void sxgbe_tx_desc_enable_tse(struct sxgbe_tx_norm_desc *p, u8 is_tse,
+				     u32 total_hdr_len, u32 tcp_hdr_len,
+				     u32 tcp_payload_len)
+{
+	p->tdes23.tx_rd_des23.tse_bit = is_tse;
+	p->tdes23.tx_rd_des23.buf1_size = total_hdr_len;
+	p->tdes23.tx_rd_des23.tcp_hdr_len = tcp_hdr_len / 4;
+	p->tdes23.tx_rd_des23.tx_pkt_len.tcp_payload_len  = tcp_payload_len;
+}
+
+/* Assign buffer lengths for descriptor */
+static void sxgbe_prepare_tx_desc(struct sxgbe_tx_norm_desc *p, u8 is_fd,
+				  int buf1_len, int pkt_len, int cksum)
+{
+	p->tdes23.tx_rd_des23.first_desc = is_fd;
+	p->tdes23.tx_rd_des23.buf1_size = buf1_len;
+
+	p->tdes23.tx_rd_des23.tx_pkt_len.cksum_pktlen.total_pkt_len = pkt_len;
+
+	if (cksum)
+		p->tdes23.tx_rd_des23.tx_pkt_len.cksum_pktlen.cksum_ctl = cic_full;
+}
+
+/* Set VLAN control information */
+static void sxgbe_tx_vlanctl_desc(struct sxgbe_tx_norm_desc *p, int vlan_ctl)
+{
+	p->tdes23.tx_rd_des23.vlan_tag_ctl = vlan_ctl;
+}
+
+/* Set the owner of Normal descriptor */
+static void sxgbe_set_tx_owner(struct sxgbe_tx_norm_desc *p)
+{
+	p->tdes23.tx_rd_des23.own_bit = 1;
+}
+
+/* Get the owner of Normal descriptor */
+static int sxgbe_get_tx_owner(struct sxgbe_tx_norm_desc *p)
+{
+	return p->tdes23.tx_rd_des23.own_bit;
+}
+
+/* Invoked by the xmit function to close the tx descriptor */
+static void sxgbe_close_tx_desc(struct sxgbe_tx_norm_desc *p)
+{
+	p->tdes23.tx_rd_des23.last_desc = 1;
+	p->tdes23.tx_rd_des23.int_on_com = 1;
+}
+
+/* Clean the tx descriptor as soon as the tx irq is received */
+static void sxgbe_release_tx_desc(struct sxgbe_tx_norm_desc *p)
+{
+	memset(p, 0, sizeof(*p));
+}
+
+/* Clear interrupt on tx frame completion. When this bit is
+ * set an interrupt happens as soon as the frame is transmitted
+ */
+static void sxgbe_clear_tx_ic(struct sxgbe_tx_norm_desc *p)
+{
+	p->tdes23.tx_rd_des23.int_on_com = 0;
+}
+
+/* Last tx segment reports the transmit status */
+static int sxgbe_get_tx_ls(struct sxgbe_tx_norm_desc *p)
+{
+	return p->tdes23.tx_rd_des23.last_desc;
+}
+
+/* Get the buffer size from the descriptor */
+static int sxgbe_get_tx_len(struct sxgbe_tx_norm_desc *p)
+{
+	return p->tdes23.tx_rd_des23.buf1_size;
+}
+
+/* Set tx timestamp enable bit */
+static void sxgbe_tx_enable_tstamp(struct sxgbe_tx_norm_desc *p)
+{
+	p->tdes23.tx_rd_des23.timestmp_enable = 1;
+}
+
+/* get tx timestamp status */
+static int sxgbe_get_tx_timestamp_status(struct sxgbe_tx_norm_desc *p)
+{
+	return p->tdes23.tx_rd_des23.timestmp_enable;
+}
+
+/* TX Context Descripto Specific */
+static void sxgbe_tx_ctxt_desc_set_ctxt(struct sxgbe_tx_ctxt_desc *p)
+{
+	p->ctxt_bit = 1;
+}
+
+/* Set the owner of TX context descriptor */
+static void sxgbe_tx_ctxt_desc_set_owner(struct sxgbe_tx_ctxt_desc *p)
+{
+	p->own_bit = 1;
+}
+
+/* Get the owner of TX context descriptor */
+static int sxgbe_tx_ctxt_desc_get_owner(struct sxgbe_tx_ctxt_desc *p)
+{
+	return p->own_bit;
+}
+
+/* Set TX mss in TX context Descriptor */
+static void sxgbe_tx_ctxt_desc_set_mss(struct sxgbe_tx_ctxt_desc *p, int mss)
+{
+	p->maxseg_size = mss;
+}
+
+/* Get TX mss from TX context Descriptor */
+static int sxgbe_tx_ctxt_desc_get_mss(struct sxgbe_tx_ctxt_desc *p)
+{
+	return p->maxseg_size;
+}
+
+/* Set TX tcmssv in TX context Descriptor */
+static void sxgbe_tx_ctxt_desc_set_tcmssv(struct sxgbe_tx_ctxt_desc *p)
+{
+	p->tcmssv = 1;
+}
+
+/* Reset TX ostc in TX context Descriptor */
+static void sxgbe_tx_ctxt_desc_reset_ostc(struct sxgbe_tx_ctxt_desc *p)
+{
+	p->ostc = 0;
+}
+
+/* Set IVLAN information */
+static void sxgbe_tx_ctxt_desc_set_ivlantag(struct sxgbe_tx_ctxt_desc *p,
+					    int is_ivlanvalid, int ivlan_tag,
+					    int ivlan_ctl)
+{
+	if (is_ivlanvalid) {
+		p->ivlan_tag_valid = is_ivlanvalid;
+		p->ivlan_tag = ivlan_tag;
+		p->ivlan_tag_ctl = ivlan_ctl;
+	}
+}
+
+/* Return IVLAN Tag */
+static int sxgbe_tx_ctxt_desc_get_ivlantag(struct sxgbe_tx_ctxt_desc *p)
+{
+	return p->ivlan_tag;
+}
+
+/* Set VLAN Tag */
+static void sxgbe_tx_ctxt_desc_set_vlantag(struct sxgbe_tx_ctxt_desc *p,
+					   int is_vlanvalid, int vlan_tag)
+{
+	if (is_vlanvalid) {
+		p->vltag_valid = is_vlanvalid;
+		p->vlan_tag = vlan_tag;
+	}
+}
+
+/* Return VLAN Tag */
+static int sxgbe_tx_ctxt_desc_get_vlantag(struct sxgbe_tx_ctxt_desc *p)
+{
+	return p->vlan_tag;
+}
+
+/* Set Time stamp */
+static void sxgbe_tx_ctxt_desc_set_tstamp(struct sxgbe_tx_ctxt_desc *p,
+					  u8 ostc_enable, u64 tstamp)
+{
+	if (ostc_enable) {
+		p->ostc = ostc_enable;
+		p->tstamp_lo = (u32) tstamp;
+		p->tstamp_hi = (u32) (tstamp>>32);
+	}
+}
+/* Close TX context descriptor */
+static void sxgbe_tx_ctxt_desc_close(struct sxgbe_tx_ctxt_desc *p)
+{
+	p->own_bit = 1;
+}
+
+/* WB status of context descriptor */
+static int sxgbe_tx_ctxt_desc_get_cde(struct sxgbe_tx_ctxt_desc *p)
+{
+	return p->ctxt_desc_err;
+}
+
+/* DMA RX descriptor ring initialization */
+static void sxgbe_init_rx_desc(struct sxgbe_rx_norm_desc *p, int disable_rx_ic,
+			       int mode, int end)
+{
+	p->rdes23.rx_rd_des23.own_bit = 1;
+	if (disable_rx_ic)
+		p->rdes23.rx_rd_des23.int_on_com = disable_rx_ic;
+}
+
+/* Get RX own bit */
+static int sxgbe_get_rx_owner(struct sxgbe_rx_norm_desc *p)
+{
+	return p->rdes23.rx_rd_des23.own_bit;
+}
+
+/* Set RX own bit */
+static void sxgbe_set_rx_owner(struct sxgbe_rx_norm_desc *p)
+{
+	p->rdes23.rx_rd_des23.own_bit = 1;
+}
+
+/* Get the receive frame size */
+static int sxgbe_get_rx_frame_len(struct sxgbe_rx_norm_desc *p)
+{
+	return p->rdes23.rx_wb_des23.pkt_len;
+}
+
+/* Return first Descriptor status */
+static int sxgbe_get_rx_fd_status(struct sxgbe_rx_norm_desc *p)
+{
+	return p->rdes23.rx_wb_des23.first_desc;
+}
+
+/* Return Last Descriptor status */
+static int sxgbe_get_rx_ld_status(struct sxgbe_rx_norm_desc *p)
+{
+	return p->rdes23.rx_wb_des23.last_desc;
+}
+
+
+/* Return the RX status looking at the WB fields */
+static int sxgbe_rx_wbstatus(struct sxgbe_rx_norm_desc *p,
+			     struct sxgbe_extra_stats *x, int *checksum)
+{
+	int status = 0;
+
+	*checksum = CHECKSUM_UNNECESSARY;
+	if (p->rdes23.rx_wb_des23.err_summary) {
+		switch (p->rdes23.rx_wb_des23.err_l2_type) {
+		case RX_GMII_ERR:
+			status = -EINVAL;
+			x->rx_code_gmii_err++;
+			break;
+		case RX_WATCHDOG_ERR:
+			status = -EINVAL;
+			x->rx_watchdog_err++;
+			break;
+		case RX_CRC_ERR:
+			status = -EINVAL;
+			x->rx_crc_err++;
+			break;
+		case RX_GAINT_ERR:
+			status = -EINVAL;
+			x->rx_gaint_pkt_err++;
+			break;
+		case RX_IP_HDR_ERR:
+			*checksum = CHECKSUM_NONE;
+			x->ip_hdr_err++;
+			break;
+		case RX_PAYLOAD_ERR:
+			*checksum = CHECKSUM_NONE;
+			x->ip_payload_err++;
+			break;
+		case RX_OVERFLOW_ERR:
+			status = -EINVAL;
+			x->overflow_error++;
+			break;
+		default:
+			pr_err("Invalid Error type\n");
+			break;
+		}
+	} else {
+		switch (p->rdes23.rx_wb_des23.err_l2_type) {
+		case RX_LEN_PKT:
+			x->len_pkt++;
+			break;
+		case RX_MACCTL_PKT:
+			x->mac_ctl_pkt++;
+			break;
+		case RX_DCBCTL_PKT:
+			x->dcb_ctl_pkt++;
+			break;
+		case RX_ARP_PKT:
+			x->arp_pkt++;
+			break;
+		case RX_OAM_PKT:
+			x->oam_pkt++;
+			break;
+		case RX_UNTAG_PKT:
+			x->untag_okt++;
+			break;
+		case RX_OTHER_PKT:
+			x->other_pkt++;
+			break;
+		case RX_SVLAN_PKT:
+			x->svlan_tag_pkt++;
+			break;
+		case RX_CVLAN_PKT:
+			x->cvlan_tag_pkt++;
+			break;
+		case RX_DVLAN_OCVLAN_ICVLAN_PKT:
+			x->dvlan_ocvlan_icvlan_pkt++;
+			break;
+		case RX_DVLAN_OSVLAN_ISVLAN_PKT:
+			x->dvlan_osvlan_isvlan_pkt++;
+			break;
+		case RX_DVLAN_OSVLAN_ICVLAN_PKT:
+			x->dvlan_osvlan_icvlan_pkt++;
+			break;
+		case RX_DVLAN_OCVLAN_ISVLAN_PKT:
+			x->dvlan_ocvlan_icvlan_pkt++;
+			break;
+		default:
+			pr_err("Invalid L2 Packet type\n");
+			break;
+		}
+	}
+
+	/* L3/L4 Pkt type */
+	switch (p->rdes23.rx_wb_des23.layer34_pkt_type) {
+	case RX_NOT_IP_PKT:
+		x->not_ip_pkt++;
+		break;
+	case RX_IPV4_TCP_PKT:
+		x->ip4_tcp_pkt++;
+		break;
+	case RX_IPV4_UDP_PKT:
+		x->ip4_udp_pkt++;
+		break;
+	case RX_IPV4_ICMP_PKT:
+		x->ip4_icmp_pkt++;
+		break;
+	case RX_IPV4_UNKNOWN_PKT:
+		x->ip4_unknown_pkt++;
+		break;
+	case RX_IPV6_TCP_PKT:
+		x->ip6_tcp_pkt++;
+		break;
+	case RX_IPV6_UDP_PKT:
+		x->ip6_udp_pkt++;
+		break;
+	case RX_IPV6_ICMP_PKT:
+		x->ip6_icmp_pkt++;
+		break;
+	case RX_IPV6_UNKNOWN_PKT:
+		x->ip6_unknown_pkt++;
+		break;
+	default:
+		pr_err("Invalid L3/L4 Packet type\n");
+		break;
+	}
+
+	/* Filter */
+	if (p->rdes23.rx_wb_des23.vlan_filter_match)
+		x->vlan_filter_match++;
+
+	if (p->rdes23.rx_wb_des23.sa_filter_fail) {
+		status = -EINVAL;
+		x->sa_filter_fail++;
+	}
+	if (p->rdes23.rx_wb_des23.da_filter_fail) {
+		status = -EINVAL;
+		x->da_filter_fail++;
+	}
+	if (p->rdes23.rx_wb_des23.hash_filter_pass)
+		x->hash_filter_pass++;
+
+	if (p->rdes23.rx_wb_des23.l3_filter_match)
+		x->l3_filter_match++;
+
+	if (p->rdes23.rx_wb_des23.l4_filter_match)
+		x->l4_filter_match++;
+
+	return status;
+}
+
+/* Get own bit of context descriptor */
+static int sxgbe_get_rx_ctxt_owner(struct sxgbe_rx_ctxt_desc *p)
+{
+	return p->own_bit;
+}
+
+/* Set own bit for context descriptor */
+static void sxgbe_set_ctxt_rx_owner(struct sxgbe_rx_ctxt_desc *p)
+{
+	p->own_bit = 1;
+}
+
+
+/* Return the reception status looking at Context control information */
+static void sxgbe_rx_ctxt_wbstatus(struct sxgbe_rx_ctxt_desc *p,
+				   struct sxgbe_extra_stats *x)
+{
+	if (p->tstamp_dropped)
+		x->timestamp_dropped++;
+
+	/* ptp */
+	if (p->ptp_msgtype == RX_NO_PTP)
+		x->rx_msg_type_no_ptp++;
+	else if (p->ptp_msgtype == RX_PTP_SYNC)
+		x->rx_ptp_type_sync++;
+	else if (p->ptp_msgtype == RX_PTP_FOLLOW_UP)
+		x->rx_ptp_type_follow_up++;
+	else if (p->ptp_msgtype == RX_PTP_DELAY_REQ)
+		x->rx_ptp_type_delay_req++;
+	else if (p->ptp_msgtype == RX_PTP_DELAY_RESP)
+		x->rx_ptp_type_delay_resp++;
+	else if (p->ptp_msgtype == RX_PTP_PDELAY_REQ)
+		x->rx_ptp_type_pdelay_req++;
+	else if (p->ptp_msgtype == RX_PTP_PDELAY_RESP)
+		x->rx_ptp_type_pdelay_resp++;
+	else if (p->ptp_msgtype == RX_PTP_PDELAY_FOLLOW_UP)
+		x->rx_ptp_type_pdelay_follow_up++;
+	else if (p->ptp_msgtype == RX_PTP_ANNOUNCE)
+		x->rx_ptp_announce++;
+	else if (p->ptp_msgtype == RX_PTP_MGMT)
+		x->rx_ptp_mgmt++;
+	else if (p->ptp_msgtype == RX_PTP_SIGNAL)
+		x->rx_ptp_signal++;
+	else if (p->ptp_msgtype == RX_PTP_RESV_MSG)
+		x->rx_ptp_resv_msg_type++;
+}
+
+/* Get rx timestamp status */
+static int sxgbe_get_rx_ctxt_tstamp_status(struct sxgbe_rx_ctxt_desc *p)
+{
+	if ((p->tstamp_hi == 0xffffffff) && (p->tstamp_lo == 0xffffffff)) {
+		pr_err("Time stamp corrupted\n");
+		return 0;
+	}
+
+	return p->tstamp_available;
+}
+
+
+static u64 sxgbe_get_rx_timestamp(struct sxgbe_rx_ctxt_desc *p)
+{
+	u64 ns;
+
+	ns = p->tstamp_lo;
+	ns |= ((u64)p->tstamp_hi) << 32;
+
+	return ns;
+}
+
+static const struct sxgbe_desc_ops desc_ops = {
+	.init_tx_desc			= sxgbe_init_tx_desc,
+	.tx_desc_enable_tse		= sxgbe_tx_desc_enable_tse,
+	.prepare_tx_desc		= sxgbe_prepare_tx_desc,
+	.tx_vlanctl_desc		= sxgbe_tx_vlanctl_desc,
+	.set_tx_owner			= sxgbe_set_tx_owner,
+	.get_tx_owner			= sxgbe_get_tx_owner,
+	.close_tx_desc			= sxgbe_close_tx_desc,
+	.release_tx_desc		= sxgbe_release_tx_desc,
+	.clear_tx_ic			= sxgbe_clear_tx_ic,
+	.get_tx_ls			= sxgbe_get_tx_ls,
+	.get_tx_len			= sxgbe_get_tx_len,
+	.tx_enable_tstamp		= sxgbe_tx_enable_tstamp,
+	.get_tx_timestamp_status	= sxgbe_get_tx_timestamp_status,
+	.tx_ctxt_desc_set_ctxt		= sxgbe_tx_ctxt_desc_set_ctxt,
+	.tx_ctxt_desc_set_owner		= sxgbe_tx_ctxt_desc_set_owner,
+	.get_tx_ctxt_owner		= sxgbe_tx_ctxt_desc_get_owner,
+	.tx_ctxt_desc_set_mss		= sxgbe_tx_ctxt_desc_set_mss,
+	.tx_ctxt_desc_get_mss		= sxgbe_tx_ctxt_desc_get_mss,
+	.tx_ctxt_desc_set_tcmssv	= sxgbe_tx_ctxt_desc_set_tcmssv,
+	.tx_ctxt_desc_reset_ostc	= sxgbe_tx_ctxt_desc_reset_ostc,
+	.tx_ctxt_desc_set_ivlantag	= sxgbe_tx_ctxt_desc_set_ivlantag,
+	.tx_ctxt_desc_get_ivlantag	= sxgbe_tx_ctxt_desc_get_ivlantag,
+	.tx_ctxt_desc_set_vlantag	= sxgbe_tx_ctxt_desc_set_vlantag,
+	.tx_ctxt_desc_get_vlantag	= sxgbe_tx_ctxt_desc_get_vlantag,
+	.tx_ctxt_set_tstamp		= sxgbe_tx_ctxt_desc_set_tstamp,
+	.close_tx_ctxt_desc		= sxgbe_tx_ctxt_desc_close,
+	.get_tx_ctxt_cde		= sxgbe_tx_ctxt_desc_get_cde,
+	.init_rx_desc			= sxgbe_init_rx_desc,
+	.get_rx_owner			= sxgbe_get_rx_owner,
+	.set_rx_owner			= sxgbe_set_rx_owner,
+	.get_rx_frame_len		= sxgbe_get_rx_frame_len,
+	.get_rx_fd_status		= sxgbe_get_rx_fd_status,
+	.get_rx_ld_status		= sxgbe_get_rx_ld_status,
+	.rx_wbstatus			= sxgbe_rx_wbstatus,
+	.get_rx_ctxt_owner		= sxgbe_get_rx_ctxt_owner,
+	.set_rx_ctxt_owner		= sxgbe_set_ctxt_rx_owner,
+	.rx_ctxt_wbstatus		= sxgbe_rx_ctxt_wbstatus,
+	.get_rx_ctxt_tstamp_status	= sxgbe_get_rx_ctxt_tstamp_status,
+	.get_timestamp			= sxgbe_get_rx_timestamp,
+};
+
+const struct sxgbe_desc_ops *sxgbe_get_desc_ops(void)
+{
+	return &desc_ops;
+}
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
new file mode 100644
index 0000000..2caef1a
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_desc.h
@@ -0,0 +1,298 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __SXGBE_DESC_H__
+#define __SXGBE_DESC_H__
+
+#define SXGBE_DESC_SIZE_BYTES	16
+
+/* forward declaration */
+struct sxgbe_extra_stats;
+
+/* Transmit checksum insertion control */
+enum tdes_csum_insertion {
+	cic_disabled		= 0,	/* Checksum Insertion Control */
+	cic_only_ip		= 1,	/* Only IP header */
+	/* IP header but pseudoheader is not calculated */
+	cic_no_pseudoheader	= 2,
+	cic_full		= 3,	/* IP header and pseudoheader */
+};
+
+struct sxgbe_tx_norm_desc {
+	u64 tdes01; /* buf1 address */
+	union {
+		/* TX Read-Format Desc 2,3 */
+		struct {
+			/* TDES2 */
+			u32 buf1_size:14;
+			u32 vlan_tag_ctl:2;
+			u32 buf2_size:14;
+			u32 timestmp_enable:1;
+			u32 int_on_com:1;
+			/* TDES3 */
+			union {
+				u32 tcp_payload_len:18;
+				struct {
+					u32 total_pkt_len:15;
+					u32 reserved1:1;
+					u32 cksum_ctl:2;
+				} cksum_pktlen;
+			} tx_pkt_len;
+
+			u32 tse_bit:1;
+			u32 tcp_hdr_len:4;
+			u32 sa_insert_ctl:3;
+			u32 crc_pad_ctl:2;
+			u32 last_desc:1;
+			u32 first_desc:1;
+			u32 ctxt_bit:1;
+			u32 own_bit:1;
+		} tx_rd_des23;
+
+		/* tx write back Desc 2,3 */
+		struct {
+			/* WB TES2 */
+			u32 reserved1;
+			/* WB TES3 */
+			u32 reserved2:31;
+			u32 own_bit:1;
+		} tx_wb_des23;
+	} tdes23;
+};
+
+struct sxgbe_rx_norm_desc {
+	union {
+		u32 rdes0; /* buf1 address */
+		struct {
+			u32 out_vlan_tag:16;
+			u32 in_vlan_tag:16;
+		} wb_rx_des0;
+	} rd_wb_des0;
+
+	union {
+		u32 rdes1;	/* buf2 address or buf1[63:32] */
+		u32 rss_hash;	/* Write-back RX */
+	} rd_wb_des1;
+
+	union {
+		/* RX Read format Desc 2,3 */
+		struct{
+			/* RDES2 */
+			u32 buf2_addr;
+			/* RDES3 */
+			u32 buf2_hi_addr:30;
+			u32 int_on_com:1;
+			u32 own_bit:1;
+		} rx_rd_des23;
+
+		/* RX write back */
+		struct{
+			/* WB RDES2 */
+			u32 hdr_len:10;
+			u32 rdes2_reserved:2;
+			u32 elrd_val:1;
+			u32 iovt_sel:1;
+			u32 res_pkt:1;
+			u32 vlan_filter_match:1;
+			u32 sa_filter_fail:1;
+			u32 da_filter_fail:1;
+			u32 hash_filter_pass:1;
+			u32 macaddr_filter_match:8;
+			u32 l3_filter_match:1;
+			u32 l4_filter_match:1;
+			u32 l34_filter_num:3;
+
+			/* WB RDES3 */
+			u32 pkt_len:14;
+			u32 rdes3_reserved:1;
+			u32 err_summary:15;
+			u32 err_l2_type:4;
+			u32 layer34_pkt_type:4;
+			u32 no_coagulation_pkt:1;
+			u32 in_seq_pkt:1;
+			u32 rss_valid:1;
+			u32 context_des_avail:1;
+			u32 last_desc:1;
+			u32 first_desc:1;
+			u32 recv_context_desc:1;
+			u32 own_bit:1;
+		} rx_wb_des23;
+	} rdes23;
+};
+
+/* Context descriptor structure */
+struct sxgbe_tx_ctxt_desc {
+	u32 tstamp_lo;
+	u32 tstamp_hi;
+	u32 maxseg_size:15;
+	u32 reserved1:1;
+	u32 ivlan_tag:16;
+	u32 vlan_tag:16;
+	u32 vltag_valid:1;
+	u32 ivlan_tag_valid:1;
+	u32 ivlan_tag_ctl:2;
+	u32 reserved2:3;
+	u32 ctxt_desc_err:1;
+	u32 reserved3:2;
+	u32 ostc:1;
+	u32 tcmssv:1;
+	u32 reserved4:2;
+	u32 ctxt_bit:1;
+	u32 own_bit:1;
+};
+
+struct sxgbe_rx_ctxt_desc {
+	u32 tstamp_lo;
+	u32 tstamp_hi;
+	u32 reserved1;
+	u32 ptp_msgtype:4;
+	u32 tstamp_available:1;
+	u32 ptp_rsp_err:1;
+	u32 tstamp_dropped:1;
+	u32 reserved2:23;
+	u32 rx_ctxt_desc:1;
+	u32 own_bit:1;
+};
+
+struct sxgbe_desc_ops {
+	/* DMA TX descriptor ring initialization */
+	void (*init_tx_desc)(struct sxgbe_tx_norm_desc *p);
+
+	/* Invoked by the xmit function to prepare the tx descriptor */
+	void (*tx_desc_enable_tse)(struct sxgbe_tx_norm_desc *p, u8 is_tse,
+				   u32 total_hdr_len, u32 payload_len,
+				   u32 tcp_payload_len);
+
+	/* Assign buffer lengths for descriptor */
+	void (*prepare_tx_desc)(struct sxgbe_tx_norm_desc *p, u8 is_fd,
+				int buf1_len, int pkt_len, int cksum);
+
+	/* Set VLAN control information */
+	void (*tx_vlanctl_desc)(struct sxgbe_tx_norm_desc *p, int vlan_ctl);
+
+	/* Set the owner of the descriptor */
+	void (*set_tx_owner)(struct sxgbe_tx_norm_desc *p);
+
+	/* Get the owner of the descriptor */
+	int (*get_tx_owner)(struct sxgbe_tx_norm_desc *p);
+
+	/* Invoked by the xmit function to close the tx descriptor */
+	void (*close_tx_desc)(struct sxgbe_tx_norm_desc *p);
+
+	/* Clean the tx descriptor as soon as the tx irq is received */
+	void (*release_tx_desc)(struct sxgbe_tx_norm_desc *p);
+
+	/* Clear interrupt on tx frame completion. When this bit is
+	 * set an interrupt happens as soon as the frame is transmitted
+	 */
+	void (*clear_tx_ic)(struct sxgbe_tx_norm_desc *p);
+
+	/* Last tx segment reports the transmit status */
+	int (*get_tx_ls)(struct sxgbe_tx_norm_desc *p);
+
+	/* Get the buffer size from the descriptor */
+	int (*get_tx_len)(struct sxgbe_tx_norm_desc *p);
+
+	/* Set tx timestamp enable bit */
+	void (*tx_enable_tstamp)(struct sxgbe_tx_norm_desc *p);
+
+	/* get tx timestamp status */
+	int (*get_tx_timestamp_status)(struct sxgbe_tx_norm_desc *p);
+
+	/* TX Context Descripto Specific */
+	void (*tx_ctxt_desc_set_ctxt)(struct sxgbe_tx_ctxt_desc *p);
+
+	/* Set the owner of the TX context descriptor */
+	void (*tx_ctxt_desc_set_owner)(struct sxgbe_tx_ctxt_desc *p);
+
+	/* Get the owner of the TX context descriptor */
+	int (*get_tx_ctxt_owner)(struct sxgbe_tx_ctxt_desc *p);
+
+	/* Set TX mss */
+	void (*tx_ctxt_desc_set_mss)(struct sxgbe_tx_ctxt_desc *p, int mss);
+
+	/* Set TX mss */
+	int (*tx_ctxt_desc_get_mss)(struct sxgbe_tx_ctxt_desc *p);
+
+	/* Set TX tcmssv */
+	void (*tx_ctxt_desc_set_tcmssv)(struct sxgbe_tx_ctxt_desc *p);
+
+	/* Reset TX ostc */
+	void (*tx_ctxt_desc_reset_ostc)(struct sxgbe_tx_ctxt_desc *p);
+
+	/* Set IVLAN information */
+	void (*tx_ctxt_desc_set_ivlantag)(struct sxgbe_tx_ctxt_desc *p,
+					  int is_ivlanvalid, int ivlan_tag,
+					  int ivlan_ctl);
+
+	/* Return IVLAN Tag */
+	int (*tx_ctxt_desc_get_ivlantag)(struct sxgbe_tx_ctxt_desc *p);
+
+	/* Set VLAN Tag */
+	void (*tx_ctxt_desc_set_vlantag)(struct sxgbe_tx_ctxt_desc *p,
+					 int is_vlanvalid, int vlan_tag);
+
+	/* Return VLAN Tag */
+	int (*tx_ctxt_desc_get_vlantag)(struct sxgbe_tx_ctxt_desc *p);
+
+	/* Set Time stamp */
+	void (*tx_ctxt_set_tstamp)(struct sxgbe_tx_ctxt_desc *p,
+				   u8 ostc_enable, u64 tstamp);
+
+	/* Close TX context descriptor */
+	void (*close_tx_ctxt_desc)(struct sxgbe_tx_ctxt_desc *p);
+
+	/* WB status of context descriptor */
+	int (*get_tx_ctxt_cde)(struct sxgbe_tx_ctxt_desc *p);
+
+	/* DMA RX descriptor ring initialization */
+	void (*init_rx_desc)(struct sxgbe_rx_norm_desc *p, int disable_rx_ic,
+			     int mode, int end);
+
+	/* Get own bit */
+	int (*get_rx_owner)(struct sxgbe_rx_norm_desc *p);
+
+	/* Set own bit */
+	void (*set_rx_owner)(struct sxgbe_rx_norm_desc *p);
+
+	/* Get the receive frame size */
+	int (*get_rx_frame_len)(struct sxgbe_rx_norm_desc *p);
+
+	/* Return first Descriptor status */
+	int (*get_rx_fd_status)(struct sxgbe_rx_norm_desc *p);
+
+	/* Return first Descriptor status */
+	int (*get_rx_ld_status)(struct sxgbe_rx_norm_desc *p);
+
+	/* Return the reception status looking at the RDES1 */
+	int (*rx_wbstatus)(struct sxgbe_rx_norm_desc *p,
+			   struct sxgbe_extra_stats *x, int *checksum);
+
+	/* Get own bit */
+	int (*get_rx_ctxt_owner)(struct sxgbe_rx_ctxt_desc *p);
+
+	/* Set own bit */
+	void (*set_rx_ctxt_owner)(struct sxgbe_rx_ctxt_desc *p);
+
+	/* Return the reception status looking at Context control information */
+	void (*rx_ctxt_wbstatus)(struct sxgbe_rx_ctxt_desc *p,
+				 struct sxgbe_extra_stats *x);
+
+	/* Get rx timestamp status */
+	int (*get_rx_ctxt_tstamp_status)(struct sxgbe_rx_ctxt_desc *p);
+
+	/* Get timestamp value for rx, need to check this */
+	u64 (*get_timestamp)(struct sxgbe_rx_ctxt_desc *p);
+};
+
+const struct sxgbe_desc_ops *sxgbe_get_desc_ops(void);
+
+#endif /* __SXGBE_DESC_H__ */
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
new file mode 100644
index 0000000..59d2d39
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c
@@ -0,0 +1,372 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/io.h>
+#include <linux/delay.h>
+#include <linux/export.h>
+#include <linux/io.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#include "sxgbe_common.h"
+#include "sxgbe_dma.h"
+#include "sxgbe_reg.h"
+#include "sxgbe_desc.h"
+
+/* DMA core initialization */
+static int sxgbe_dma_init(void __iomem *ioaddr, int fix_burst, int burst_map)
+{
+	int retry_count = 10;
+	u32 reg_val;
+
+	/* reset the DMA */
+	writel(SXGBE_DMA_SOFT_RESET, ioaddr + SXGBE_DMA_MODE_REG);
+	while (retry_count--) {
+		if (!(readl(ioaddr + SXGBE_DMA_MODE_REG) &
+		      SXGBE_DMA_SOFT_RESET))
+			break;
+		mdelay(10);
+	}
+
+	if (retry_count < 0)
+		return -EBUSY;
+
+	reg_val = readl(ioaddr + SXGBE_DMA_SYSBUS_MODE_REG);
+
+	/* if fix_burst = 0, Set UNDEF = 1 of DMA_Sys_Mode Register.
+	 * if fix_burst = 1, Set UNDEF = 0 of DMA_Sys_Mode Register.
+	 * burst_map is bitmap for  BLEN[4, 8, 16, 32, 64, 128 and 256].
+	 * Set burst_map irrespective of fix_burst value.
+	 */
+	if (!fix_burst)
+		reg_val |= SXGBE_DMA_AXI_UNDEF_BURST;
+
+	/* write burst len map */
+	reg_val |= (burst_map << SXGBE_DMA_BLENMAP_LSHIFT);
+
+	writel(reg_val,	ioaddr + SXGBE_DMA_SYSBUS_MODE_REG);
+
+	return 0;
+}
+
+static void sxgbe_dma_channel_init(void __iomem *ioaddr, int cha_num,
+				   int fix_burst, int pbl, dma_addr_t dma_tx,
+				   dma_addr_t dma_rx, int t_rsize, int r_rsize)
+{
+	u32 reg_val;
+	dma_addr_t dma_addr;
+
+	reg_val = readl(ioaddr + SXGBE_DMA_CHA_CTL_REG(cha_num));
+	/* set the pbl */
+	if (fix_burst) {
+		reg_val |= SXGBE_DMA_PBL_X8MODE;
+		writel(reg_val, ioaddr + SXGBE_DMA_CHA_CTL_REG(cha_num));
+		/* program the TX pbl */
+		reg_val = readl(ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cha_num));
+		reg_val |= (pbl << SXGBE_DMA_TXPBL_LSHIFT);
+		writel(reg_val, ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cha_num));
+		/* program the RX pbl */
+		reg_val = readl(ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cha_num));
+		reg_val |= (pbl << SXGBE_DMA_RXPBL_LSHIFT);
+		writel(reg_val, ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cha_num));
+	}
+
+	/* program desc registers */
+	writel(upper_32_bits(dma_tx),
+	       ioaddr + SXGBE_DMA_CHA_TXDESC_HADD_REG(cha_num));
+	writel(lower_32_bits(dma_tx),
+	       ioaddr + SXGBE_DMA_CHA_TXDESC_LADD_REG(cha_num));
+
+	writel(upper_32_bits(dma_rx),
+	       ioaddr + SXGBE_DMA_CHA_RXDESC_HADD_REG(cha_num));
+	writel(lower_32_bits(dma_rx),
+	       ioaddr + SXGBE_DMA_CHA_RXDESC_LADD_REG(cha_num));
+
+	/* program tail pointers */
+	/* assumption: upper 32 bits are constant and
+	 * same as TX/RX desc list
+	 */
+	dma_addr = dma_tx + ((t_rsize - 1) * SXGBE_DESC_SIZE_BYTES);
+	writel(lower_32_bits(dma_addr),
+	       ioaddr + SXGBE_DMA_CHA_TXDESC_TAILPTR_REG(cha_num));
+
+	dma_addr = dma_rx + ((r_rsize - 1) * SXGBE_DESC_SIZE_BYTES);
+	writel(lower_32_bits(dma_addr),
+	       ioaddr + SXGBE_DMA_CHA_RXDESC_LADD_REG(cha_num));
+	/* program the ring sizes */
+	writel(t_rsize - 1, ioaddr + SXGBE_DMA_CHA_TXDESC_RINGLEN_REG(cha_num));
+	writel(r_rsize - 1, ioaddr + SXGBE_DMA_CHA_RXDESC_RINGLEN_REG(cha_num));
+
+	/* Enable TX/RX interrupts */
+	writel(SXGBE_DMA_ENA_INT,
+	       ioaddr + SXGBE_DMA_CHA_INT_ENABLE_REG(cha_num));
+}
+
+static void sxgbe_enable_dma_transmission(void __iomem *ioaddr, int cha_num)
+{
+	u32 tx_config;
+
+	tx_config = readl(ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cha_num));
+	tx_config |= SXGBE_TX_START_DMA;
+	writel(tx_config, ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cha_num));
+}
+
+static void sxgbe_enable_dma_irq(void __iomem *ioaddr, int dma_cnum)
+{
+	/* Enable TX/RX interrupts */
+	writel(SXGBE_DMA_ENA_INT,
+	       ioaddr + SXGBE_DMA_CHA_INT_ENABLE_REG(dma_cnum));
+}
+
+static void sxgbe_disable_dma_irq(void __iomem *ioaddr, int dma_cnum)
+{
+	/* Disable TX/RX interrupts */
+	writel(0, ioaddr + SXGBE_DMA_CHA_INT_ENABLE_REG(dma_cnum));
+}
+
+static void sxgbe_dma_start_tx(void __iomem *ioaddr, int tchannels)
+{
+	int cnum;
+	u32 tx_ctl_reg;
+
+	for (cnum = 0; cnum < tchannels; cnum++) {
+		tx_ctl_reg = readl(ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cnum));
+		tx_ctl_reg |= SXGBE_TX_ENABLE;
+		writel(tx_ctl_reg,
+		       ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cnum));
+	}
+}
+
+static void sxgbe_dma_start_tx_queue(void __iomem *ioaddr, int dma_cnum)
+{
+	u32 tx_ctl_reg;
+
+	tx_ctl_reg = readl(ioaddr + SXGBE_DMA_CHA_TXCTL_REG(dma_cnum));
+	tx_ctl_reg |= SXGBE_TX_ENABLE;
+	writel(tx_ctl_reg, ioaddr + SXGBE_DMA_CHA_TXCTL_REG(dma_cnum));
+}
+
+static void sxgbe_dma_stop_tx_queue(void __iomem *ioaddr, int dma_cnum)
+{
+	u32 tx_ctl_reg;
+
+	tx_ctl_reg = readl(ioaddr + SXGBE_DMA_CHA_TXCTL_REG(dma_cnum));
+	tx_ctl_reg &= ~(SXGBE_TX_ENABLE);
+	writel(tx_ctl_reg, ioaddr + SXGBE_DMA_CHA_TXCTL_REG(dma_cnum));
+}
+
+static void sxgbe_dma_stop_tx(void __iomem *ioaddr, int tchannels)
+{
+	int cnum;
+	u32 tx_ctl_reg;
+
+	for (cnum = 0; cnum < tchannels; cnum++) {
+		tx_ctl_reg = readl(ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cnum));
+		tx_ctl_reg &= ~(SXGBE_TX_ENABLE);
+		writel(tx_ctl_reg, ioaddr + SXGBE_DMA_CHA_TXCTL_REG(cnum));
+	}
+}
+
+static void sxgbe_dma_start_rx(void __iomem *ioaddr, int rchannels)
+{
+	int cnum;
+	u32 rx_ctl_reg;
+
+	for (cnum = 0; cnum < rchannels; cnum++) {
+		rx_ctl_reg = readl(ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cnum));
+		rx_ctl_reg |= SXGBE_RX_ENABLE;
+		writel(rx_ctl_reg,
+		       ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cnum));
+	}
+}
+
+static void sxgbe_dma_stop_rx(void __iomem *ioaddr, int rchannels)
+{
+	int cnum;
+	u32 rx_ctl_reg;
+
+	for (cnum = 0; cnum < rchannels; cnum++) {
+		rx_ctl_reg = readl(ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cnum));
+		rx_ctl_reg &= ~(SXGBE_RX_ENABLE);
+		writel(rx_ctl_reg, ioaddr + SXGBE_DMA_CHA_RXCTL_REG(cnum));
+	}
+}
+
+static int sxgbe_tx_dma_int_status(void __iomem *ioaddr, int channel_no,
+				   struct sxgbe_extra_stats *x)
+{
+	u32 int_status = readl(ioaddr + SXGBE_DMA_CHA_STATUS_REG(channel_no));
+	u32 clear_val = 0;
+	u32 ret_val = 0;
+
+	/* TX Normal Interrupt Summary */
+	if (likely(int_status & SXGBE_DMA_INT_STATUS_NIS)) {
+		x->normal_irq_n++;
+		if (int_status & SXGBE_DMA_INT_STATUS_TI) {
+			ret_val |= handle_tx;
+			x->tx_normal_irq_n++;
+			clear_val |= SXGBE_DMA_INT_STATUS_TI;
+		}
+
+		if (int_status & SXGBE_DMA_INT_STATUS_TBU) {
+			x->tx_underflow_irq++;
+			ret_val |= tx_bump_tc;
+			clear_val |= SXGBE_DMA_INT_STATUS_TBU;
+		}
+	} else if (unlikely(int_status & SXGBE_DMA_INT_STATUS_AIS)) {
+		/* TX Abnormal Interrupt Summary */
+		if (int_status & SXGBE_DMA_INT_STATUS_TPS) {
+			ret_val |= tx_hard_error;
+			clear_val |= SXGBE_DMA_INT_STATUS_TPS;
+			x->tx_process_stopped_irq++;
+		}
+
+		if (int_status & SXGBE_DMA_INT_STATUS_FBE) {
+			ret_val |= tx_hard_error;
+			x->fatal_bus_error_irq++;
+
+			/* Assumption: FBE bit is the combination of
+			 * all the bus access erros and cleared when
+			 * the respective error bits cleared
+			 */
+
+			/* check for actual cause */
+			if (int_status & SXGBE_DMA_INT_STATUS_TEB0) {
+				x->tx_read_transfer_err++;
+				clear_val |= SXGBE_DMA_INT_STATUS_TEB0;
+			} else {
+				x->tx_write_transfer_err++;
+			}
+
+			if (int_status & SXGBE_DMA_INT_STATUS_TEB1) {
+				x->tx_desc_access_err++;
+				clear_val |= SXGBE_DMA_INT_STATUS_TEB1;
+			} else {
+				x->tx_buffer_access_err++;
+			}
+
+			if (int_status & SXGBE_DMA_INT_STATUS_TEB2) {
+				x->tx_data_transfer_err++;
+				clear_val |= SXGBE_DMA_INT_STATUS_TEB2;
+			}
+		}
+
+		/* context descriptor error */
+		if (int_status & SXGBE_DMA_INT_STATUS_CTXTERR) {
+			x->tx_ctxt_desc_err++;
+			clear_val |= SXGBE_DMA_INT_STATUS_CTXTERR;
+		}
+	}
+
+	/* clear the served bits */
+	writel(clear_val, ioaddr + SXGBE_DMA_CHA_STATUS_REG(channel_no));
+
+	return ret_val;
+}
+
+static int sxgbe_rx_dma_int_status(void __iomem *ioaddr, int channel_no,
+				   struct sxgbe_extra_stats *x)
+{
+	u32 int_status = readl(ioaddr + SXGBE_DMA_CHA_STATUS_REG(channel_no));
+	u32 clear_val = 0;
+	u32 ret_val = 0;
+
+	/* RX Normal Interrupt Summary */
+	if (likely(int_status & SXGBE_DMA_INT_STATUS_NIS)) {
+		x->normal_irq_n++;
+		if (int_status & SXGBE_DMA_INT_STATUS_RI) {
+			ret_val |= handle_rx;
+			x->rx_normal_irq_n++;
+			clear_val |= SXGBE_DMA_INT_STATUS_RI;
+		}
+	} else if (unlikely(int_status & SXGBE_DMA_INT_STATUS_AIS)) {
+		/* RX Abnormal Interrupt Summary */
+		if (int_status & SXGBE_DMA_INT_STATUS_RBU) {
+			ret_val |= rx_bump_tc;
+			clear_val |= SXGBE_DMA_INT_STATUS_RBU;
+			x->rx_underflow_irq++;
+		}
+
+		if (int_status & SXGBE_DMA_INT_STATUS_RPS) {
+			ret_val |= rx_hard_error;
+			clear_val |= SXGBE_DMA_INT_STATUS_RPS;
+			x->rx_process_stopped_irq++;
+		}
+
+		if (int_status & SXGBE_DMA_INT_STATUS_FBE) {
+			ret_val |= rx_hard_error;
+			x->fatal_bus_error_irq++;
+
+			/* Assumption: FBE bit is the combination of
+			 * all the bus access erros and cleared when
+			 * the respective error bits cleared
+			 */
+
+			/* check for actual cause */
+			if (int_status & SXGBE_DMA_INT_STATUS_REB0) {
+				x->rx_read_transfer_err++;
+				clear_val |= SXGBE_DMA_INT_STATUS_REB0;
+			} else {
+				x->rx_write_transfer_err++;
+			}
+
+			if (int_status & SXGBE_DMA_INT_STATUS_REB1) {
+				x->rx_desc_access_err++;
+				clear_val |= SXGBE_DMA_INT_STATUS_REB1;
+			} else {
+				x->rx_buffer_access_err++;
+			}
+
+			if (int_status & SXGBE_DMA_INT_STATUS_REB2) {
+				x->rx_data_transfer_err++;
+				clear_val |= SXGBE_DMA_INT_STATUS_REB2;
+			}
+		}
+	}
+
+	/* clear the served bits */
+	writel(clear_val, ioaddr + SXGBE_DMA_CHA_STATUS_REG(channel_no));
+
+	return ret_val;
+}
+
+/* Program the HW RX Watchdog */
+static void sxgbe_dma_rx_watchdog(void __iomem *ioaddr, u32 riwt)
+{
+	u32 que_num;
+
+	SXGBE_FOR_EACH_QUEUE(SXGBE_RX_QUEUES, que_num) {
+		writel(riwt,
+		       ioaddr + SXGBE_DMA_CHA_INT_RXWATCHTMR_REG(que_num));
+	}
+}
+
+static const struct sxgbe_dma_ops sxgbe_dma_ops = {
+	.init				= sxgbe_dma_init,
+	.cha_init			= sxgbe_dma_channel_init,
+	.enable_dma_transmission	= sxgbe_enable_dma_transmission,
+	.enable_dma_irq			= sxgbe_enable_dma_irq,
+	.disable_dma_irq		= sxgbe_disable_dma_irq,
+	.start_tx			= sxgbe_dma_start_tx,
+	.start_tx_queue			= sxgbe_dma_start_tx_queue,
+	.stop_tx			= sxgbe_dma_stop_tx,
+	.stop_tx_queue			= sxgbe_dma_stop_tx_queue,
+	.start_rx			= sxgbe_dma_start_rx,
+	.stop_rx			= sxgbe_dma_stop_rx,
+	.tx_dma_int_status		= sxgbe_tx_dma_int_status,
+	.rx_dma_int_status		= sxgbe_rx_dma_int_status,
+	.rx_watchdog			= sxgbe_dma_rx_watchdog,
+};
+
+const struct sxgbe_dma_ops *sxgbe_get_dma_ops(void)
+{
+	return &sxgbe_dma_ops;
+}
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
new file mode 100644
index 0000000..bbf167e
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h
@@ -0,0 +1,48 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __SXGBE_DMA_H__
+#define __SXGBE_DMA_H__
+
+/* forward declaration */
+struct sxgbe_extra_stats;
+
+#define SXGBE_DMA_BLENMAP_LSHIFT	1
+#define SXGBE_DMA_TXPBL_LSHIFT		16
+#define SXGBE_DMA_RXPBL_LSHIFT		16
+#define DEFAULT_DMA_PBL			8
+
+struct sxgbe_dma_ops {
+	/* DMA core initialization */
+	int (*init)(void __iomem *ioaddr, int fix_burst, int burst_map);
+	void (*cha_init)(void __iomem *ioaddr, int cha_num, int fix_burst,
+			 int pbl, dma_addr_t dma_tx, dma_addr_t dma_rx,
+			 int t_rzie, int r_rsize);
+	void (*enable_dma_transmission)(void __iomem *ioaddr, int dma_cnum);
+	void (*enable_dma_irq)(void __iomem *ioaddr, int dma_cnum);
+	void (*disable_dma_irq)(void __iomem *ioaddr, int dma_cnum);
+	void (*start_tx)(void __iomem *ioaddr, int tchannels);
+	void (*start_tx_queue)(void __iomem *ioaddr, int dma_cnum);
+	void (*stop_tx)(void __iomem *ioaddr, int tchannels);
+	void (*stop_tx_queue)(void __iomem *ioaddr, int dma_cnum);
+	void (*start_rx)(void __iomem *ioaddr, int rchannels);
+	void (*stop_rx)(void __iomem *ioaddr, int rchannels);
+	int (*tx_dma_int_status)(void __iomem *ioaddr, int channel_no,
+				 struct sxgbe_extra_stats *x);
+	int (*rx_dma_int_status)(void __iomem *ioaddr, int channel_no,
+				 struct sxgbe_extra_stats *x);
+	/* Program the HW RX Watchdog */
+	void (*rx_watchdog)(void __iomem *ioaddr, u32 riwt);
+};
+
+const struct sxgbe_dma_ops *sxgbe_get_dma_ops(void);
+
+#endif /* __SXGBE_CORE_H__ */
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
new file mode 100644
index 0000000..1dce2b2
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c
@@ -0,0 +1,44 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#include "sxgbe_common.h"
+
+struct sxgbe_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define SXGBE_STAT(m)						\
+{								\
+	#m,							\
+	FIELD_SIZEOF(struct sxgbe_extra_stats, m),		\
+	offsetof(struct sxgbe_priv_data, xstats.m)		\
+}
+
+static const struct sxgbe_stats sxgbe_gstrings_stats[] = {
+};
+#define SXGBE_STATS_LEN ARRAY_SIZE(sxgbe_gstrings_stats)
+
+static const struct ethtool_ops sxgbe_ethtool_ops = {
+};
+
+void sxgbe_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &sxgbe_ethtool_ops);
+}
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
new file mode 100644
index 0000000..75ba57c
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -0,0 +1,2052 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/clk.h>
+#include <linux/crc32.h>
+#include <linux/dma-mapping.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/if.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+#include <linux/net_tstamp.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/prefetch.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/tcp.h>
+#include <linux/sxgbe_platform.h>
+
+#include "sxgbe_common.h"
+#include "sxgbe_desc.h"
+#include "sxgbe_dma.h"
+#include "sxgbe_mtl.h"
+#include "sxgbe_reg.h"
+
+#define SXGBE_ALIGN(x)	L1_CACHE_ALIGN(x)
+#define JUMBO_LEN	9000
+
+/* Module parameters */
+#define TX_TIMEO	5000
+#define DMA_TX_SIZE	512
+#define DMA_RX_SIZE	1024
+#define TC_DEFAULT	64
+#define DMA_BUFFER_SIZE	BUF_SIZE_2KiB
+/* The default timer value as per the sxgbe specification 1 sec(1000 ms) */
+#define SXGBE_DEFAULT_LPI_TIMER	1000
+
+static int debug = -1;
+
+module_param(debug, int, S_IRUGO | S_IWUSR);
+static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
+				      NETIF_MSG_LINK | NETIF_MSG_IFUP |
+				      NETIF_MSG_IFDOWN | NETIF_MSG_TIMER);
+
+static irqreturn_t sxgbe_common_interrupt(int irq, void *dev_id);
+static irqreturn_t sxgbe_tx_interrupt(int irq, void *dev_id);
+static irqreturn_t sxgbe_rx_interrupt(int irq, void *dev_id);
+
+#define SXGBE_COAL_TIMER(x) (jiffies + usecs_to_jiffies(x))
+
+/**
+ * sxgbe_clk_csr_set - dynamically set the MDC clock
+ * @priv: driver private structure
+ * Description: this is to dynamically set the MDC clock according to the csr
+ * clock input.
+ */
+static void sxgbe_clk_csr_set(struct sxgbe_priv_data *priv)
+{
+	u32 clk_rate = clk_get_rate(priv->sxgbe_clk);
+
+	/* assign the proper divider, this will be used during
+	 * mdio communication
+	 */
+	if (clk_rate < SXGBE_CSR_F_150M)
+		priv->clk_csr = SXGBE_CSR_100_150M;
+	else if (clk_rate <= SXGBE_CSR_F_250M)
+		priv->clk_csr = SXGBE_CSR_150_250M;
+	else if (clk_rate <= SXGBE_CSR_F_300M)
+		priv->clk_csr = SXGBE_CSR_250_300M;
+	else if (clk_rate <= SXGBE_CSR_F_350M)
+		priv->clk_csr = SXGBE_CSR_300_350M;
+	else if (clk_rate <= SXGBE_CSR_F_400M)
+		priv->clk_csr = SXGBE_CSR_350_400M;
+	else if (clk_rate <= SXGBE_CSR_F_500M)
+		priv->clk_csr = SXGBE_CSR_400_500M;
+}
+
+/* minimum number of free TX descriptors required to wake up TX process */
+#define SXGBE_TX_THRESH(x)	(x->dma_tx_size/4)
+
+static inline u32 sxgbe_tx_avail(struct sxgbe_tx_queue *queue, int tx_qsize)
+{
+	return queue->dirty_tx + tx_qsize - queue->cur_tx - 1;
+}
+
+/**
+ * sxgbe_adjust_link
+ * @dev: net device structure
+ * Description: it adjusts the link parameters.
+ */
+static void sxgbe_adjust_link(struct net_device *dev)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+	u8 new_state = 0;
+	u8 speed = 0xff;
+
+	if (!phydev)
+		return;
+
+	/* SXGBE is not supporting auto-negotiation and
+	 * half duplex mode. so, not handling duplex change
+	 * in this function. only handling speed and link status
+	 */
+	if (phydev->link) {
+		if (phydev->speed != priv->speed) {
+			new_state = 1;
+			switch (phydev->speed) {
+			case SPEED_10000:
+				speed = SXGBE_SPEED_10G;
+				break;
+			case SPEED_2500:
+				speed = SXGBE_SPEED_2_5G;
+				break;
+			case SPEED_1000:
+				speed = SXGBE_SPEED_1G;
+				break;
+			default:
+				netif_err(priv, link, dev,
+					  "Speed (%d) not supported\n",
+					  phydev->speed);
+			}
+
+			priv->speed = phydev->speed;
+			priv->hw->mac->set_speed(priv->ioaddr, speed);
+		}
+
+		if (!priv->oldlink) {
+			new_state = 1;
+			priv->oldlink = 1;
+		}
+	} else if (priv->oldlink) {
+		new_state = 1;
+		priv->oldlink = 0;
+		priv->speed = SPEED_UNKNOWN;
+	}
+
+	if (new_state & netif_msg_link(priv))
+		phy_print_status(phydev);
+}
+
+/**
+ * sxgbe_init_phy - PHY initialization
+ * @dev: net device structure
+ * Description: it initializes the driver's PHY state, and attaches the PHY
+ * to the mac driver.
+ *  Return value:
+ *  0 on success
+ */
+static int sxgbe_init_phy(struct net_device *ndev)
+{
+	char phy_id_fmt[MII_BUS_ID_SIZE + 3];
+	char bus_id[MII_BUS_ID_SIZE];
+	struct phy_device *phydev;
+	struct sxgbe_priv_data *priv = netdev_priv(ndev);
+	int phy_iface = priv->plat->interface;
+
+	/* assign default link status */
+	priv->oldlink = 0;
+	priv->speed = SPEED_UNKNOWN;
+	priv->oldduplex = DUPLEX_UNKNOWN;
+
+	if (priv->plat->phy_bus_name)
+		snprintf(bus_id, MII_BUS_ID_SIZE, "%s-%x",
+			 priv->plat->phy_bus_name, priv->plat->bus_id);
+	else
+		snprintf(bus_id, MII_BUS_ID_SIZE, "sxgbe-%x",
+			 priv->plat->bus_id);
+
+	snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
+		 priv->plat->phy_addr);
+	netdev_dbg(ndev, "%s: trying to attach to %s\n", __func__, phy_id_fmt);
+
+	phydev = phy_connect(ndev, phy_id_fmt, &sxgbe_adjust_link, phy_iface);
+
+	if (IS_ERR(phydev)) {
+		netdev_err(ndev, "Could not attach to PHY\n");
+		return PTR_ERR(phydev);
+	}
+
+	/* Stop Advertising 1000BASE Capability if interface is not GMII */
+	if ((phy_iface == PHY_INTERFACE_MODE_MII) ||
+	    (phy_iface == PHY_INTERFACE_MODE_RMII))
+		phydev->advertising &= ~(SUPPORTED_1000baseT_Half |
+					 SUPPORTED_1000baseT_Full);
+	if (phydev->phy_id == 0) {
+		phy_disconnect(phydev);
+		return -ENODEV;
+	}
+
+	netdev_dbg(ndev, "%s: attached to PHY (UID 0x%x) Link = %d\n",
+		   __func__, phydev->phy_id, phydev->link);
+
+	/* save phy device in private structure */
+	priv->phydev = phydev;
+
+	return 0;
+}
+
+/**
+ * sxgbe_clear_descriptors: clear descriptors
+ * @priv: driver private structure
+ * Description: this function is called to clear the tx and rx descriptors
+ * in case of both basic and extended descriptors are used.
+ */
+static void sxgbe_clear_descriptors(struct sxgbe_priv_data *priv)
+{
+	int i, j;
+	unsigned int txsize = priv->dma_tx_size;
+	unsigned int rxsize = priv->dma_rx_size;
+
+	/* Clear the Rx/Tx descriptors */
+	for (j = 0; j < SXGBE_RX_QUEUES; j++) {
+		for (i = 0; i < rxsize; i++)
+			priv->hw->desc->init_rx_desc(&priv->rxq[j]->dma_rx[i],
+						     priv->use_riwt, priv->mode,
+						     (i == rxsize - 1));
+	}
+
+	for (j = 0; j < SXGBE_TX_QUEUES; j++) {
+		for (i = 0; i < txsize; i++)
+			priv->hw->desc->init_tx_desc(&priv->txq[j]->dma_tx[i]);
+	}
+}
+
+static int sxgbe_init_rx_buffers(struct net_device *dev,
+				 struct sxgbe_rx_norm_desc *p, int i,
+				 unsigned int dma_buf_sz,
+				 struct sxgbe_rx_queue *rx_ring)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+	struct sk_buff *skb;
+
+	skb = __netdev_alloc_skb_ip_align(dev, dma_buf_sz, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	rx_ring->rx_skbuff[i] = skb;
+	rx_ring->rx_skbuff_dma[i] = dma_map_single(priv->device, skb->data,
+						   dma_buf_sz, DMA_FROM_DEVICE);
+
+	if (dma_mapping_error(priv->device, rx_ring->rx_skbuff_dma[i])) {
+		netdev_err(dev, "%s: DMA mapping error\n", __func__);
+		dev_kfree_skb_any(skb);
+		return -EINVAL;
+	}
+
+	p->rdes23.rx_rd_des23.buf2_addr = rx_ring->rx_skbuff_dma[i];
+
+	return 0;
+}
+/**
+ * init_tx_ring - init the TX descriptor ring
+ * @dev: net device structure
+ * @tx_ring: ring to be intialised
+ * @tx_rsize: ring size
+ * Description:  this function initializes the DMA TX descriptor
+ */
+static int init_tx_ring(struct device *dev, u8 queue_no,
+			struct sxgbe_tx_queue *tx_ring,	int tx_rsize)
+{
+	/* TX ring is not allcoated */
+	if (!tx_ring) {
+		dev_err(dev, "No memory for TX queue of SXGBE\n");
+		return -ENOMEM;
+	}
+
+	/* allocate memory for TX descriptors */
+	tx_ring->dma_tx = dma_zalloc_coherent(dev,
+					      tx_rsize * sizeof(struct sxgbe_tx_norm_desc),
+					      &tx_ring->dma_tx_phy, GFP_KERNEL);
+	if (!tx_ring->dma_tx)
+		return -ENOMEM;
+
+	/* allocate memory for TX skbuff array */
+	tx_ring->tx_skbuff_dma = devm_kcalloc(dev, tx_rsize,
+					      sizeof(dma_addr_t), GFP_KERNEL);
+	if (!tx_ring->tx_skbuff_dma)
+		goto dmamem_err;
+
+	tx_ring->tx_skbuff = devm_kcalloc(dev, tx_rsize,
+					  sizeof(struct sk_buff *), GFP_KERNEL);
+
+	if (!tx_ring->tx_skbuff)
+		goto dmamem_err;
+
+	/* assign queue number */
+	tx_ring->queue_no = queue_no;
+
+	/* initalise counters */
+	tx_ring->dirty_tx = 0;
+	tx_ring->cur_tx = 0;
+
+	/* initalise TX queue lock */
+	spin_lock_init(&tx_ring->tx_lock);
+
+	return 0;
+
+dmamem_err:
+	dma_free_coherent(dev, tx_rsize * sizeof(struct sxgbe_tx_norm_desc),
+			  tx_ring->dma_tx, tx_ring->dma_tx_phy);
+	return -ENOMEM;
+}
+
+/**
+ * free_rx_ring - free the RX descriptor ring
+ * @dev: net device structure
+ * @rx_ring: ring to be intialised
+ * @rx_rsize: ring size
+ * Description:  this function initializes the DMA RX descriptor
+ */
+void free_rx_ring(struct device *dev, struct sxgbe_rx_queue *rx_ring,
+		  int rx_rsize)
+{
+	dma_free_coherent(dev, rx_rsize * sizeof(struct sxgbe_rx_norm_desc),
+			  rx_ring->dma_rx, rx_ring->dma_rx_phy);
+	kfree(rx_ring->rx_skbuff_dma);
+	kfree(rx_ring->rx_skbuff);
+}
+
+/**
+ * init_rx_ring - init the RX descriptor ring
+ * @dev: net device structure
+ * @rx_ring: ring to be intialised
+ * @rx_rsize: ring size
+ * Description:  this function initializes the DMA RX descriptor
+ */
+static int init_rx_ring(struct net_device *dev, u8 queue_no,
+			struct sxgbe_rx_queue *rx_ring,	int rx_rsize)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+	int desc_index;
+	unsigned int bfsize = 0;
+	unsigned int ret = 0;
+
+	/* Set the max buffer size according to the MTU. */
+	bfsize = ALIGN(dev->mtu + ETH_HLEN + ETH_FCS_LEN + NET_IP_ALIGN, 8);
+
+	netif_dbg(priv, probe, dev, "%s: bfsize %d\n", __func__, bfsize);
+
+	/* RX ring is not allcoated */
+	if (rx_ring == NULL) {
+		netdev_err(dev, "No memory for RX queue\n");
+		goto error;
+	}
+
+	/* assign queue number */
+	rx_ring->queue_no = queue_no;
+
+	/* allocate memory for RX descriptors */
+	rx_ring->dma_rx = dma_zalloc_coherent(priv->device,
+					      rx_rsize * sizeof(struct sxgbe_rx_norm_desc),
+					      &rx_ring->dma_rx_phy, GFP_KERNEL);
+
+	if (rx_ring->dma_rx == NULL)
+		goto error;
+
+	/* allocate memory for RX skbuff array */
+	rx_ring->rx_skbuff_dma = kmalloc_array(rx_rsize,
+					       sizeof(dma_addr_t), GFP_KERNEL);
+	if (rx_ring->rx_skbuff_dma == NULL)
+		goto dmamem_err;
+
+	rx_ring->rx_skbuff = kmalloc_array(rx_rsize,
+					   sizeof(struct sk_buff *), GFP_KERNEL);
+	if (rx_ring->rx_skbuff == NULL)
+		goto rxbuff_err;
+
+	/* initialise the buffers */
+	for (desc_index = 0; desc_index < rx_rsize; desc_index++) {
+		struct sxgbe_rx_norm_desc *p;
+		p = rx_ring->dma_rx + desc_index;
+		ret = sxgbe_init_rx_buffers(dev, p, desc_index,
+					    bfsize, rx_ring);
+		if (ret)
+			goto err_init_rx_buffers;
+	}
+
+	/* initalise counters */
+	rx_ring->cur_rx = 0;
+	rx_ring->dirty_rx = (unsigned int)(desc_index - rx_rsize);
+	priv->dma_buf_sz = bfsize;
+
+	return 0;
+
+err_init_rx_buffers:
+	while (--desc_index >= 0)
+		free_rx_ring(priv->device, rx_ring, desc_index);
+	kfree(rx_ring->rx_skbuff);
+rxbuff_err:
+	kfree(rx_ring->rx_skbuff_dma);
+dmamem_err:
+	dma_free_coherent(priv->device,
+			  rx_rsize * sizeof(struct sxgbe_rx_norm_desc),
+			  rx_ring->dma_rx, rx_ring->dma_rx_phy);
+error:
+	return -ENOMEM;
+}
+/**
+ * free_tx_ring - free the TX descriptor ring
+ * @dev: net device structure
+ * @tx_ring: ring to be intialised
+ * @tx_rsize: ring size
+ * Description:  this function initializes the DMA TX descriptor
+ */
+void free_tx_ring(struct device *dev, struct sxgbe_tx_queue *tx_ring,
+		  int tx_rsize)
+{
+	dma_free_coherent(dev, tx_rsize * sizeof(struct sxgbe_tx_norm_desc),
+			  tx_ring->dma_tx, tx_ring->dma_tx_phy);
+}
+
+/**
+ * init_dma_desc_rings - init the RX/TX descriptor rings
+ * @dev: net device structure
+ * Description:  this function initializes the DMA RX/TX descriptors
+ * and allocates the socket buffers. It suppors the chained and ring
+ * modes.
+ */
+static int init_dma_desc_rings(struct net_device *netd)
+{
+	int queue_num, ret;
+	struct sxgbe_priv_data *priv = netdev_priv(netd);
+	int tx_rsize = priv->dma_tx_size;
+	int rx_rsize = priv->dma_rx_size;
+
+	/* Allocate memory for queue structures and TX descs */
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
+		ret = init_tx_ring(priv->device, queue_num,
+				   priv->txq[queue_num], tx_rsize);
+		if (ret) {
+			dev_err(&netd->dev, "TX DMA ring allocation failed!\n");
+			goto txalloc_err;
+		}
+
+		/* save private pointer in each ring this
+		 * pointer is needed during cleaing TX queue
+		 */
+		priv->txq[queue_num]->priv_ptr = priv;
+	}
+
+	/* Allocate memory for queue structures and RX descs */
+	SXGBE_FOR_EACH_QUEUE(SXGBE_RX_QUEUES, queue_num) {
+		ret = init_rx_ring(netd, queue_num,
+				   priv->rxq[queue_num], rx_rsize);
+		if (ret) {
+			netdev_err(netd, "RX DMA ring allocation failed!!\n");
+			goto rxalloc_err;
+		}
+
+		/* save private pointer in each ring this
+		 * pointer is needed during cleaing TX queue
+		 */
+		priv->rxq[queue_num]->priv_ptr = priv;
+	}
+
+	sxgbe_clear_descriptors(priv);
+
+	return 0;
+
+txalloc_err:
+	while (queue_num--)
+		free_tx_ring(priv->device, priv->txq[queue_num], tx_rsize);
+	return ret;
+
+rxalloc_err:
+	while (queue_num--)
+		free_rx_ring(priv->device, priv->rxq[queue_num], rx_rsize);
+	return ret;
+}
+
+static void tx_free_ring_skbufs(struct sxgbe_tx_queue *txqueue)
+{
+	int dma_desc;
+	struct sxgbe_priv_data *priv = txqueue->priv_ptr;
+	int tx_rsize = priv->dma_tx_size;
+
+	for (dma_desc = 0; dma_desc < tx_rsize; dma_desc++) {
+		struct sxgbe_tx_norm_desc *tdesc = txqueue->dma_tx + dma_desc;
+
+		if (txqueue->tx_skbuff_dma[dma_desc])
+			dma_unmap_single(priv->device,
+					 txqueue->tx_skbuff_dma[dma_desc],
+					 priv->hw->desc->get_tx_len(tdesc),
+					 DMA_TO_DEVICE);
+
+		dev_kfree_skb_any(txqueue->tx_skbuff[dma_desc]);
+		txqueue->tx_skbuff[dma_desc] = NULL;
+		txqueue->tx_skbuff_dma[dma_desc] = 0;
+	}
+}
+
+
+static void dma_free_tx_skbufs(struct sxgbe_priv_data *priv)
+{
+	int queue_num;
+
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
+		struct sxgbe_tx_queue *tqueue = priv->txq[queue_num];
+		tx_free_ring_skbufs(tqueue);
+	}
+}
+
+static void free_dma_desc_resources(struct sxgbe_priv_data *priv)
+{
+	int queue_num;
+	int tx_rsize = priv->dma_tx_size;
+	int rx_rsize = priv->dma_rx_size;
+
+	/* Release the DMA TX buffers */
+	dma_free_tx_skbufs(priv);
+
+	/* Release the TX ring memory also */
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
+		free_tx_ring(priv->device, priv->txq[queue_num], tx_rsize);
+	}
+
+	/* Release the RX ring memory also */
+	SXGBE_FOR_EACH_QUEUE(SXGBE_RX_QUEUES, queue_num) {
+		free_rx_ring(priv->device, priv->rxq[queue_num], rx_rsize);
+	}
+}
+
+static int txring_mem_alloc(struct sxgbe_priv_data *priv)
+{
+	int queue_num;
+
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
+		priv->txq[queue_num] = devm_kmalloc(priv->device,
+						    sizeof(struct sxgbe_tx_queue), GFP_KERNEL);
+		if (!priv->txq[queue_num])
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static int rxring_mem_alloc(struct sxgbe_priv_data *priv)
+{
+	int queue_num;
+
+	SXGBE_FOR_EACH_QUEUE(SXGBE_RX_QUEUES, queue_num) {
+		priv->rxq[queue_num] = devm_kmalloc(priv->device,
+						    sizeof(struct sxgbe_rx_queue), GFP_KERNEL);
+		if (!priv->rxq[queue_num])
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+/**
+ *  sxgbe_mtl_operation_mode - HW MTL operation mode
+ *  @priv: driver private structure
+ *  Description: it sets the MTL operation mode: tx/rx MTL thresholds
+ *  or Store-And-Forward capability.
+ */
+static void sxgbe_mtl_operation_mode(struct sxgbe_priv_data *priv)
+{
+	int queue_num;
+
+	/* TX/RX threshold control */
+	if (likely(priv->plat->force_sf_dma_mode)) {
+		/* set TC mode for TX QUEUES */
+		SXGBE_FOR_EACH_QUEUE(priv->hw_cap.tx_mtl_queues, queue_num)
+			priv->hw->mtl->set_tx_mtl_mode(priv->ioaddr, queue_num,
+						       SXGBE_MTL_SFMODE);
+		priv->tx_tc = SXGBE_MTL_SFMODE;
+
+		/* set TC mode for RX QUEUES */
+		SXGBE_FOR_EACH_QUEUE(priv->hw_cap.rx_mtl_queues, queue_num)
+			priv->hw->mtl->set_rx_mtl_mode(priv->ioaddr, queue_num,
+						       SXGBE_MTL_SFMODE);
+		priv->rx_tc = SXGBE_MTL_SFMODE;
+	} else if (unlikely(priv->plat->force_thresh_dma_mode)) {
+		/* set TC mode for TX QUEUES */
+		SXGBE_FOR_EACH_QUEUE(priv->hw_cap.tx_mtl_queues, queue_num)
+			priv->hw->mtl->set_tx_mtl_mode(priv->ioaddr, queue_num,
+						       priv->tx_tc);
+		/* set TC mode for RX QUEUES */
+		SXGBE_FOR_EACH_QUEUE(priv->hw_cap.rx_mtl_queues, queue_num)
+			priv->hw->mtl->set_rx_mtl_mode(priv->ioaddr, queue_num,
+						       priv->rx_tc);
+	} else {
+		pr_err("ERROR: %s: Invalid TX threshold mode\n", __func__);
+	}
+}
+
+/**
+ * sxgbe_tx_queue_clean:
+ * @priv: driver private structure
+ * Description: it reclaims resources after transmission completes.
+ */
+static void sxgbe_tx_queue_clean(struct sxgbe_tx_queue *tqueue)
+{
+	struct sxgbe_priv_data *priv = tqueue->priv_ptr;
+	unsigned int tx_rsize = priv->dma_tx_size;
+	struct netdev_queue *dev_txq;
+	u8 queue_no = tqueue->queue_no;
+
+	dev_txq = netdev_get_tx_queue(priv->dev, queue_no);
+
+	spin_lock(&tqueue->tx_lock);
+
+	priv->xstats.tx_clean++;
+	while (tqueue->dirty_tx != tqueue->cur_tx) {
+		unsigned int entry = tqueue->dirty_tx % tx_rsize;
+		struct sk_buff *skb = tqueue->tx_skbuff[entry];
+		struct sxgbe_tx_norm_desc *p;
+
+		p = tqueue->dma_tx + entry;
+
+		/* Check if the descriptor is owned by the DMA. */
+		if (priv->hw->desc->get_tx_owner(p))
+			break;
+
+		if (netif_msg_tx_done(priv))
+			pr_debug("%s: curr %d, dirty %d\n",
+				 __func__, tqueue->cur_tx, tqueue->dirty_tx);
+
+		if (likely(tqueue->tx_skbuff_dma[entry])) {
+			dma_unmap_single(priv->device,
+					 tqueue->tx_skbuff_dma[entry],
+					 priv->hw->desc->get_tx_len(p),
+					 DMA_TO_DEVICE);
+			tqueue->tx_skbuff_dma[entry] = 0;
+		}
+
+		if (likely(skb)) {
+			dev_kfree_skb(skb);
+			tqueue->tx_skbuff[entry] = NULL;
+		}
+
+		priv->hw->desc->release_tx_desc(p);
+
+		tqueue->dirty_tx++;
+	}
+
+	/* wake up queue */
+	if (unlikely(netif_tx_queue_stopped(dev_txq) &&
+		     sxgbe_tx_avail(tqueue, tx_rsize) > SXGBE_TX_THRESH(priv))) {
+		netif_tx_lock(priv->dev);
+		if (netif_tx_queue_stopped(dev_txq) &&
+		    sxgbe_tx_avail(tqueue, tx_rsize) > SXGBE_TX_THRESH(priv)) {
+			if (netif_msg_tx_done(priv))
+				pr_debug("%s: restart transmit\n", __func__);
+			netif_tx_wake_queue(dev_txq);
+		}
+		netif_tx_unlock(priv->dev);
+	}
+
+	spin_unlock(&tqueue->tx_lock);
+}
+
+/**
+ * sxgbe_tx_clean:
+ * @priv: driver private structure
+ * Description: it reclaims resources after transmission completes.
+ */
+static void sxgbe_tx_all_clean(struct sxgbe_priv_data *priv)
+{
+	u8 queue_num;
+
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
+		struct sxgbe_tx_queue *tqueue = priv->txq[queue_num];
+
+		sxgbe_tx_queue_clean(tqueue);
+	}
+}
+
+/**
+ * sxgbe_restart_tx_queue: irq tx error mng function
+ * @priv: driver private structure
+ * Description: it cleans the descriptors and restarts the transmission
+ * in case of errors.
+ */
+static void sxgbe_restart_tx_queue(struct sxgbe_priv_data *priv, int queue_num)
+{
+	struct sxgbe_tx_queue *tx_ring = priv->txq[queue_num];
+	struct netdev_queue *dev_txq = netdev_get_tx_queue(priv->dev,
+							   queue_num);
+
+	/* stop the queue */
+	netif_tx_stop_queue(dev_txq);
+
+	/* stop the tx dma */
+	priv->hw->dma->stop_tx_queue(priv->ioaddr, queue_num);
+
+	/* free the skbuffs of the ring */
+	tx_free_ring_skbufs(tx_ring);
+
+	/* initalise counters */
+	tx_ring->cur_tx = 0;
+	tx_ring->dirty_tx = 0;
+
+	/* start the tx dma */
+	priv->hw->dma->start_tx_queue(priv->ioaddr, queue_num);
+
+	priv->dev->stats.tx_errors++;
+
+	/* wakeup the queue */
+	netif_tx_wake_queue(dev_txq);
+}
+
+/**
+ * sxgbe_reset_all_tx_queues: irq tx error mng function
+ * @priv: driver private structure
+ * Description: it cleans all the descriptors and
+ * restarts the transmission on all queues in case of errors.
+ */
+static void sxgbe_reset_all_tx_queues(struct sxgbe_priv_data *priv)
+{
+	int queue_num;
+
+	/* On TX timeout of net device, resetting of all queues
+	 * may not be proper way, revisit this later if needed
+	 */
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num)
+		sxgbe_restart_tx_queue(priv, queue_num);
+}
+
+/**
+ * sxgbe_get_hw_features: get XMAC capabilities from the HW cap. register.
+ * @priv: driver private structure
+ * Description:
+ *  new GMAC chip generations have a new register to indicate the
+ *  presence of the optional feature/functions.
+ *  This can be also used to override the value passed through the
+ *  platform and necessary for old MAC10/100 and GMAC chips.
+ */
+static int sxgbe_get_hw_features(struct sxgbe_priv_data * const priv)
+{
+	int rval = 0;
+	struct sxgbe_hw_features *features = &priv->hw_cap;
+
+	/* Read First Capability Register CAP[0] */
+	rval = priv->hw->mac->get_hw_feature(priv->ioaddr, 0);
+	if (rval) {
+		features->pmt_remote_wake_up =
+			SXGBE_HW_FEAT_PMT_TEMOTE_WOP(rval);
+		features->pmt_magic_frame = SXGBE_HW_FEAT_PMT_MAGIC_PKT(rval);
+		features->atime_stamp = SXGBE_HW_FEAT_IEEE1500_2008(rval);
+		features->tx_csum_offload =
+			SXGBE_HW_FEAT_TX_CSUM_OFFLOAD(rval);
+		features->rx_csum_offload =
+			SXGBE_HW_FEAT_RX_CSUM_OFFLOAD(rval);
+		features->multi_macaddr = SXGBE_HW_FEAT_MACADDR_COUNT(rval);
+		features->tstamp_srcselect = SXGBE_HW_FEAT_TSTMAP_SRC(rval);
+		features->sa_vlan_insert = SXGBE_HW_FEAT_SRCADDR_VLAN(rval);
+	}
+
+	/* Read First Capability Register CAP[1] */
+	rval = priv->hw->mac->get_hw_feature(priv->ioaddr, 1);
+	if (rval) {
+		features->rxfifo_size = SXGBE_HW_FEAT_RX_FIFO_SIZE(rval);
+		features->txfifo_size = SXGBE_HW_FEAT_TX_FIFO_SIZE(rval);
+		features->atstmap_hword = SXGBE_HW_FEAT_TX_FIFO_SIZE(rval);
+		features->dcb_enable = SXGBE_HW_FEAT_DCB(rval);
+		features->splithead_enable = SXGBE_HW_FEAT_SPLIT_HDR(rval);
+		features->tcpseg_offload = SXGBE_HW_FEAT_TSO(rval);
+		features->debug_mem = SXGBE_HW_FEAT_DEBUG_MEM_IFACE(rval);
+		features->rss_enable = SXGBE_HW_FEAT_RSS(rval);
+		features->hash_tsize = SXGBE_HW_FEAT_HASH_TABLE_SIZE(rval);
+		features->l3l4_filer_size = SXGBE_HW_FEAT_L3L4_FILTER_NUM(rval);
+	}
+
+	/* Read First Capability Register CAP[2] */
+	rval = priv->hw->mac->get_hw_feature(priv->ioaddr, 2);
+	if (rval) {
+		features->rx_mtl_queues = SXGBE_HW_FEAT_RX_MTL_QUEUES(rval);
+		features->tx_mtl_queues = SXGBE_HW_FEAT_TX_MTL_QUEUES(rval);
+		features->rx_dma_channels = SXGBE_HW_FEAT_RX_DMA_CHANNELS(rval);
+		features->tx_dma_channels = SXGBE_HW_FEAT_TX_DMA_CHANNELS(rval);
+		features->pps_output_count = SXGBE_HW_FEAT_PPS_OUTPUTS(rval);
+		features->aux_input_count = SXGBE_HW_FEAT_AUX_SNAPSHOTS(rval);
+	}
+
+	return rval;
+}
+
+/**
+ * sxgbe_check_ether_addr: check if the MAC addr is valid
+ * @priv: driver private structure
+ * Description:
+ * it is to verify if the MAC address is valid, in case of failures it
+ * generates a random MAC address
+ */
+static void sxgbe_check_ether_addr(struct sxgbe_priv_data *priv)
+{
+	if (!is_valid_ether_addr(priv->dev->dev_addr)) {
+		priv->hw->mac->get_umac_addr((void __iomem *)
+					     priv->ioaddr,
+					     priv->dev->dev_addr, 0);
+		if (!is_valid_ether_addr(priv->dev->dev_addr))
+			eth_hw_addr_random(priv->dev);
+	}
+	dev_info(priv->device, "device MAC address %pM\n",
+		 priv->dev->dev_addr);
+}
+
+/**
+ * sxgbe_init_dma_engine: DMA init.
+ * @priv: driver private structure
+ * Description:
+ * It inits the DMA invoking the specific SXGBE callback.
+ * Some DMA parameters can be passed from the platform;
+ * in case of these are not passed a default is kept for the MAC or GMAC.
+ */
+static int sxgbe_init_dma_engine(struct sxgbe_priv_data *priv)
+{
+	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_map = 0;
+	int queue_num;
+
+	if (priv->plat->dma_cfg) {
+		pbl = priv->plat->dma_cfg->pbl;
+		fixed_burst = priv->plat->dma_cfg->fixed_burst;
+		burst_map = priv->plat->dma_cfg->burst_map;
+	}
+
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num)
+		priv->hw->dma->cha_init(priv->ioaddr, queue_num,
+					fixed_burst, pbl,
+					(priv->txq[queue_num])->dma_tx_phy,
+					(priv->rxq[queue_num])->dma_rx_phy,
+					priv->dma_tx_size, priv->dma_rx_size);
+
+	return priv->hw->dma->init(priv->ioaddr, fixed_burst, burst_map);
+}
+
+/**
+ * sxgbe_init_mtl_engine: MTL init.
+ * @priv: driver private structure
+ * Description:
+ * It inits the MTL invoking the specific SXGBE callback.
+ */
+static void sxgbe_init_mtl_engine(struct sxgbe_priv_data *priv)
+{
+	int queue_num;
+
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
+		priv->hw->mtl->mtl_set_txfifosize(priv->ioaddr, queue_num,
+						  priv->hw_cap.tx_mtl_qsize);
+		priv->hw->mtl->mtl_enable_txqueue(priv->ioaddr, queue_num);
+	}
+}
+
+/**
+ * sxgbe_disable_mtl_engine: MTL disable.
+ * @priv: driver private structure
+ * Description:
+ * It disables the MTL queues by invoking the specific SXGBE callback.
+ */
+static void sxgbe_disable_mtl_engine(struct sxgbe_priv_data *priv)
+{
+	int queue_num;
+
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num)
+		priv->hw->mtl->mtl_disable_txqueue(priv->ioaddr, queue_num);
+}
+
+
+/**
+ * sxgbe_tx_timer: mitigation sw timer for tx.
+ * @data: data pointer
+ * Description:
+ * This is the timer handler to directly invoke the sxgbe_tx_clean.
+ */
+static void sxgbe_tx_timer(unsigned long data)
+{
+	struct sxgbe_tx_queue *p = (struct sxgbe_tx_queue *)data;
+	sxgbe_tx_queue_clean(p);
+}
+
+/**
+ * sxgbe_init_tx_coalesce: init tx mitigation options.
+ * @priv: driver private structure
+ * Description:
+ * This inits the transmit coalesce parameters: i.e. timer rate,
+ * timer handler and default threshold used for enabling the
+ * interrupt on completion bit.
+ */
+static void sxgbe_tx_init_coalesce(struct sxgbe_priv_data *priv)
+{
+	u8 queue_num;
+
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
+		struct sxgbe_tx_queue *p = priv->txq[queue_num];
+		p->tx_coal_frames =  SXGBE_TX_FRAMES;
+		p->tx_coal_timer = SXGBE_COAL_TX_TIMER;
+		init_timer(&p->txtimer);
+		p->txtimer.expires = SXGBE_COAL_TIMER(p->tx_coal_timer);
+		p->txtimer.data = (unsigned long)&priv->txq[queue_num];
+		p->txtimer.function = sxgbe_tx_timer;
+		add_timer(&p->txtimer);
+	}
+}
+
+static void sxgbe_tx_del_timer(struct sxgbe_priv_data *priv)
+{
+	u8 queue_num;
+
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
+		struct sxgbe_tx_queue *p = priv->txq[queue_num];
+		del_timer_sync(&p->txtimer);
+	}
+}
+
+/**
+ *  sxgbe_open - open entry point of the driver
+ *  @dev : pointer to the device structure.
+ *  Description:
+ *  This function is the open entry point of the driver.
+ *  Return value:
+ *  0 on success and an appropriate (-)ve integer as defined in errno.h
+ *  file on failure.
+ */
+static int sxgbe_open(struct net_device *dev)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+	int ret, queue_num;
+
+	clk_prepare_enable(priv->sxgbe_clk);
+
+	sxgbe_check_ether_addr(priv);
+
+	/* Init the phy */
+	ret = sxgbe_init_phy(dev);
+	if (ret) {
+		netdev_err(dev, "%s: Cannot attach to PHY (error: %d)\n",
+			   __func__, ret);
+		goto phy_error;
+	}
+
+	/* Create and initialize the TX/RX descriptors chains. */
+	priv->dma_tx_size = SXGBE_ALIGN(DMA_TX_SIZE);
+	priv->dma_rx_size = SXGBE_ALIGN(DMA_RX_SIZE);
+	priv->dma_buf_sz = SXGBE_ALIGN(DMA_BUFFER_SIZE);
+	priv->tx_tc = TC_DEFAULT;
+	priv->rx_tc = TC_DEFAULT;
+	init_dma_desc_rings(dev);
+
+	/* DMA initialization and SW reset */
+	ret = sxgbe_init_dma_engine(priv);
+	if (ret < 0) {
+		netdev_err(dev, "%s: DMA initialization failed\n", __func__);
+		goto init_error;
+	}
+
+	/*  MTL initialization */
+	sxgbe_init_mtl_engine(priv);
+
+	/* Copy the MAC addr into the HW  */
+	priv->hw->mac->set_umac_addr(priv->ioaddr, dev->dev_addr, 0);
+
+	/* Initialize the MAC Core */
+	priv->hw->mac->core_init(priv->ioaddr);
+
+	/* Request the IRQ lines */
+	ret = devm_request_irq(priv->device, priv->irq, sxgbe_common_interrupt,
+			       IRQF_SHARED, dev->name, dev);
+	if (unlikely(ret < 0)) {
+		netdev_err(dev, "%s: ERROR: allocating the IRQ %d (error: %d)\n",
+			   __func__, priv->irq, ret);
+		goto init_error;
+	}
+
+	/* Request TX DMA irq lines */
+	SXGBE_FOR_EACH_QUEUE(SXGBE_TX_QUEUES, queue_num) {
+		ret = devm_request_irq(priv->device,
+				       (priv->txq[queue_num])->irq_no,
+				       sxgbe_tx_interrupt, 0,
+				       dev->name, priv->txq[queue_num]);
+		if (unlikely(ret < 0)) {
+			netdev_err(dev, "%s: ERROR: allocating TX IRQ %d (error: %d)\n",
+				   __func__, priv->irq, ret);
+			goto init_error;
+		}
+	}
+
+	/* Request RX DMA irq lines */
+	SXGBE_FOR_EACH_QUEUE(SXGBE_RX_QUEUES, queue_num) {
+		ret = devm_request_irq(priv->device,
+				       (priv->rxq[queue_num])->irq_no,
+				       sxgbe_rx_interrupt, 0,
+				       dev->name, priv->rxq[queue_num]);
+		if (unlikely(ret < 0)) {
+			netdev_err(dev, "%s: ERROR: allocating TX IRQ %d (error: %d)\n",
+				   __func__, priv->irq, ret);
+			goto init_error;
+		}
+	}
+
+	/* Enable the MAC Rx/Tx */
+	priv->hw->mac->enable_tx(priv->ioaddr, true);
+	priv->hw->mac->enable_rx(priv->ioaddr, true);
+
+	/* Set the HW DMA mode and the COE */
+	sxgbe_mtl_operation_mode(priv);
+
+	/* Extra statistics */
+	memset(&priv->xstats, 0, sizeof(struct sxgbe_extra_stats));
+
+	priv->xstats.tx_threshold = priv->tx_tc;
+	priv->xstats.rx_threshold = priv->rx_tc;
+
+	/* Start the ball rolling... */
+	netdev_dbg(dev, "DMA RX/TX processes started...\n");
+	priv->hw->dma->start_tx(priv->ioaddr, SXGBE_TX_QUEUES);
+	priv->hw->dma->start_rx(priv->ioaddr, SXGBE_RX_QUEUES);
+
+	if (priv->phydev)
+		phy_start(priv->phydev);
+
+	/* initalise TX coalesce parameters */
+	sxgbe_tx_init_coalesce(priv);
+
+	if ((priv->use_riwt) && (priv->hw->dma->rx_watchdog)) {
+		priv->rx_riwt = SXGBE_MAX_DMA_RIWT;
+		priv->hw->dma->rx_watchdog(priv->ioaddr, SXGBE_MAX_DMA_RIWT);
+	}
+
+	napi_enable(&priv->napi);
+	netif_start_queue(dev);
+
+	return 0;
+
+init_error:
+	free_dma_desc_resources(priv);
+	if (priv->phydev)
+		phy_disconnect(priv->phydev);
+phy_error:
+	clk_disable_unprepare(priv->sxgbe_clk);
+
+	return ret;
+}
+
+/**
+ *  sxgbe_release - close entry point of the driver
+ *  @dev : device pointer.
+ *  Description:
+ *  This is the stop entry point of the driver.
+ */
+static int sxgbe_release(struct net_device *dev)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+
+	/* Stop and disconnect the PHY */
+	if (priv->phydev) {
+		phy_stop(priv->phydev);
+		phy_disconnect(priv->phydev);
+		priv->phydev = NULL;
+	}
+
+	netif_tx_stop_all_queues(dev);
+
+	napi_disable(&priv->napi);
+
+	/* delete TX timers */
+	sxgbe_tx_del_timer(priv);
+
+	/* Stop TX/RX DMA and clear the descriptors */
+	priv->hw->dma->stop_tx(priv->ioaddr, SXGBE_TX_QUEUES);
+	priv->hw->dma->stop_rx(priv->ioaddr, SXGBE_RX_QUEUES);
+
+	/* disable MTL queue */
+	sxgbe_disable_mtl_engine(priv);
+
+	/* Release and free the Rx/Tx resources */
+	free_dma_desc_resources(priv);
+
+	/* Disable the MAC Rx/Tx */
+	priv->hw->mac->enable_tx(priv->ioaddr, false);
+	priv->hw->mac->enable_rx(priv->ioaddr, false);
+
+	clk_disable_unprepare(priv->sxgbe_clk);
+
+	return 0;
+}
+
+/**
+ *  sxgbe_xmit: Tx entry point of the driver
+ *  @skb : the socket buffer
+ *  @dev : device pointer
+ *  Description : this is the tx entry point of the driver.
+ *  It programs the chain or the ring and supports oversized frames
+ *  and SG feature.
+ */
+static netdev_tx_t sxgbe_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	unsigned int entry, frag_num;
+	struct netdev_queue *dev_txq;
+	unsigned txq_index = skb_get_queue_mapping(skb);
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+	unsigned int tx_rsize = priv->dma_tx_size;
+	struct sxgbe_tx_queue *tqueue = priv->txq[txq_index];
+	struct sxgbe_tx_norm_desc *tx_desc, *first_desc;
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	int no_pagedlen = skb_headlen(skb);
+	int is_jumbo = 0;
+
+	/* get the TX queue handle */
+	dev_txq = netdev_get_tx_queue(dev, txq_index);
+
+	/* get the spinlock */
+	spin_lock(&tqueue->tx_lock);
+
+	if (unlikely(sxgbe_tx_avail(tqueue, tx_rsize) < nr_frags + 1)) {
+		if (!netif_tx_queue_stopped(dev_txq)) {
+			netif_tx_stop_queue(dev_txq);
+			netdev_err(dev, "%s: Tx Ring is full when %d queue is awake\n",
+				   __func__, txq_index);
+		}
+		/* release the spin lock in case of BUSY */
+		spin_unlock(&tqueue->tx_lock);
+		return NETDEV_TX_BUSY;
+	}
+
+	entry = tqueue->cur_tx % tx_rsize;
+	tx_desc = tqueue->dma_tx + entry;
+
+	first_desc = tx_desc;
+
+	/* save the skb address */
+	tqueue->tx_skbuff[entry] = skb;
+
+	if (!is_jumbo) {
+		tx_desc->tdes01 = dma_map_single(priv->device, skb->data,
+						   no_pagedlen, DMA_TO_DEVICE);
+		if (dma_mapping_error(priv->device, tx_desc->tdes01))
+			pr_err("%s: TX dma mapping failed!!\n", __func__);
+
+		priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
+						no_pagedlen, 0);
+	}
+
+	for (frag_num = 0; frag_num < nr_frags; frag_num++) {
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[frag_num];
+		int len = skb_frag_size(frag);
+
+		entry = (++tqueue->cur_tx) % tx_rsize;
+		tx_desc = tqueue->dma_tx + entry;
+		tx_desc->tdes01 = skb_frag_dma_map(priv->device, frag, 0, len,
+						   DMA_TO_DEVICE);
+
+		tqueue->tx_skbuff_dma[entry] = tx_desc->tdes01;
+		tqueue->tx_skbuff[entry] = NULL;
+
+		/* prepare the descriptor */
+		priv->hw->desc->prepare_tx_desc(tx_desc, 0, len,
+						len, 0);
+		/* memory barrier to flush descriptor */
+		wmb();
+
+		/* set the owner */
+		priv->hw->desc->set_tx_owner(tx_desc);
+	}
+
+	/* close the descriptors */
+	priv->hw->desc->close_tx_desc(tx_desc);
+
+	/* memory barrier to flush descriptor */
+	wmb();
+
+	tqueue->tx_count_frames += nr_frags + 1;
+	if (tqueue->tx_count_frames > tqueue->tx_coal_frames) {
+		priv->hw->desc->clear_tx_ic(tx_desc);
+		priv->xstats.tx_reset_ic_bit++;
+		mod_timer(&tqueue->txtimer,
+			  SXGBE_COAL_TIMER(tqueue->tx_coal_timer));
+	} else {
+		tqueue->tx_count_frames = 0;
+	}
+
+	/* set owner for first desc */
+	priv->hw->desc->set_tx_owner(first_desc);
+
+	/* memory barrier to flush descriptor */
+	wmb();
+
+	tqueue->cur_tx++;
+
+	/* display current ring */
+	netif_dbg(priv, pktdata, dev, "%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d\n",
+		  __func__, tqueue->cur_tx % tx_rsize,
+		  tqueue->dirty_tx % tx_rsize, entry,
+		  first_desc, nr_frags);
+
+	if (unlikely(sxgbe_tx_avail(tqueue, tx_rsize) <= (MAX_SKB_FRAGS + 1))) {
+		netif_dbg(priv, hw, dev, "%s: stop transmitted packets\n",
+			  __func__);
+		netif_tx_stop_queue(dev_txq);
+	}
+
+	dev->stats.tx_bytes += skb->len;
+
+	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+		     tqueue->hwts_tx_en)) {
+		/* declare that device is doing timestamping */
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		priv->hw->desc->tx_enable_tstamp(first_desc);
+	}
+
+	if (!tqueue->hwts_tx_en)
+		skb_tx_timestamp(skb);
+
+	priv->hw->dma->enable_dma_transmission(priv->ioaddr, txq_index);
+
+	spin_unlock(&tqueue->tx_lock);
+
+	return NETDEV_TX_OK;
+}
+
+/**
+ * sxgbe_rx_refill: refill used skb preallocated buffers
+ * @priv: driver private structure
+ * Description : this is to reallocate the skb for the reception process
+ * that is based on zero-copy.
+ */
+static void sxgbe_rx_refill(struct sxgbe_priv_data *priv)
+{
+	unsigned int rxsize = priv->dma_rx_size;
+	int bfsize = priv->dma_buf_sz;
+	u8 qnum = priv->cur_rx_qnum;
+
+	for (; priv->rxq[qnum]->cur_rx - priv->rxq[qnum]->dirty_rx > 0;
+	     priv->rxq[qnum]->dirty_rx++) {
+		unsigned int entry = priv->rxq[qnum]->dirty_rx % rxsize;
+		struct sxgbe_rx_norm_desc *p;
+
+		p = priv->rxq[qnum]->dma_rx + entry;
+
+		if (likely(priv->rxq[qnum]->rx_skbuff[entry] == NULL)) {
+			struct sk_buff *skb;
+
+			skb = netdev_alloc_skb_ip_align(priv->dev, bfsize);
+
+			if (unlikely(skb == NULL))
+				break;
+
+			priv->rxq[qnum]->rx_skbuff[entry] = skb;
+			priv->rxq[qnum]->rx_skbuff_dma[entry] =
+				dma_map_single(priv->device, skb->data, bfsize,
+					       DMA_FROM_DEVICE);
+
+			p->rdes23.rx_rd_des23.buf2_addr =
+				priv->rxq[qnum]->rx_skbuff_dma[entry];
+		}
+
+		/* Added memory barrier for RX descriptor modification */
+		wmb();
+		priv->hw->desc->set_rx_owner(p);
+		/* Added memory barrier for RX descriptor modification */
+		wmb();
+	}
+}
+
+/**
+ * sxgbe_rx: receive the frames from the remote host
+ * @priv: driver private structure
+ * @limit: napi bugget.
+ * Description :  this the function called by the napi poll method.
+ * It gets all the frames inside the ring.
+ */
+static int sxgbe_rx(struct sxgbe_priv_data *priv, int limit)
+{
+	u8 qnum = priv->cur_rx_qnum;
+	unsigned int rxsize = priv->dma_rx_size;
+	unsigned int entry = priv->rxq[qnum]->cur_rx;
+	unsigned int next_entry = 0;
+	unsigned int count = 0;
+
+	while (count < limit) {
+		struct sxgbe_rx_norm_desc *p;
+		struct sk_buff *skb;
+		int frame_len;
+
+		p = priv->rxq[qnum]->dma_rx + entry;
+
+		if (priv->hw->desc->get_rx_owner(p))
+			break;
+
+		count++;
+
+		next_entry = (++priv->rxq[qnum]->cur_rx) % rxsize;
+		prefetch(priv->rxq[qnum]->dma_rx + next_entry);
+
+		/*TO DO read the status of the incoming frame */
+
+		skb = priv->rxq[qnum]->rx_skbuff[entry];
+
+		if (unlikely(!skb))
+			netdev_err(priv->dev, "rx descriptor is not consistent\n");
+
+		prefetch(skb->data - NET_IP_ALIGN);
+		priv->rxq[qnum]->rx_skbuff[entry] = NULL;
+
+		frame_len = priv->hw->desc->get_rx_frame_len(p);
+
+		skb_put(skb, frame_len);
+
+		netif_receive_skb(skb);
+
+		entry = next_entry;
+	}
+
+	sxgbe_rx_refill(priv);
+
+	return count;
+}
+
+/**
+ *  sxgbe_poll - sxgbe poll method (NAPI)
+ *  @napi : pointer to the napi structure.
+ *  @budget : maximum number of packets that the current CPU can receive from
+ *	      all interfaces.
+ *  Description :
+ *  To look at the incoming frames and clear the tx resources.
+ */
+static int sxgbe_poll(struct napi_struct *napi, int budget)
+{
+	struct sxgbe_priv_data *priv = container_of(napi,
+						    struct sxgbe_priv_data, napi);
+	int work_done = 0;
+	u8 qnum = priv->cur_rx_qnum;
+
+	priv->xstats.napi_poll++;
+	/* first, clean the tx queues */
+	sxgbe_tx_all_clean(priv);
+
+	work_done = sxgbe_rx(priv, budget);
+	if (work_done < budget) {
+		napi_complete(napi);
+		priv->hw->dma->enable_dma_irq(priv->ioaddr, qnum);
+	}
+
+	return work_done;
+}
+
+/**
+ *  sxgbe_tx_timeout
+ *  @dev : Pointer to net device structure
+ *  Description: this function is called when a packet transmission fails to
+ *   complete within a reasonable time. The driver will mark the error in the
+ *   netdev structure and arrange for the device to be reset to a sane state
+ *   in order to transmit a new packet.
+ */
+static void sxgbe_tx_timeout(struct net_device *dev)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+
+	sxgbe_reset_all_tx_queues(priv);
+}
+
+/**
+ *  sxgbe_common_interrupt - main ISR
+ *  @irq: interrupt number.
+ *  @dev_id: to pass the net device pointer.
+ *  Description: this is the main driver interrupt service routine.
+ *  It calls the DMA ISR and also the core ISR to manage PMT, MMC, LPI
+ *  interrupts.
+ */
+static irqreturn_t sxgbe_common_interrupt(int irq, void *dev_id)
+{
+	return IRQ_HANDLED;
+}
+
+/**
+ *  sxgbe_tx_interrupt - TX DMA ISR
+ *  @irq: interrupt number.
+ *  @dev_id: to pass the net device pointer.
+ *  Description: this is the tx dma interrupt service routine.
+ */
+static irqreturn_t sxgbe_tx_interrupt(int irq, void *dev_id)
+{
+	int status;
+	struct sxgbe_tx_queue *txq = (struct sxgbe_tx_queue *)dev_id;
+	struct sxgbe_priv_data *priv = txq->priv_ptr;
+
+	/* get the channel status */
+	status = priv->hw->dma->tx_dma_int_status(priv->ioaddr, txq->queue_no,
+						  &priv->xstats);
+	/* check for normal path */
+	if (likely((status & handle_tx)))
+		napi_schedule(&priv->napi);
+
+	/* check for unrecoverable error */
+	if (unlikely((status & tx_hard_error)))
+		sxgbe_restart_tx_queue(priv, txq->queue_no);
+
+	/* check for TC configuration change */
+	if (unlikely((status & tx_bump_tc) &&
+		     (priv->tx_tc != SXGBE_MTL_SFMODE) &&
+		     (priv->tx_tc < 512))) {
+		/* step of TX TC is 32 till 128, otherwise 64 */
+		priv->tx_tc += (priv->tx_tc < 128) ? 32 : 64;
+		priv->hw->mtl->set_tx_mtl_mode(priv->ioaddr,
+					       txq->queue_no, priv->tx_tc);
+		priv->xstats.tx_threshold = priv->tx_tc;
+	}
+
+	return IRQ_HANDLED;
+}
+
+/**
+ *  sxgbe_rx_interrupt - RX DMA ISR
+ *  @irq: interrupt number.
+ *  @dev_id: to pass the net device pointer.
+ *  Description: this is the rx dma interrupt service routine.
+ */
+static irqreturn_t sxgbe_rx_interrupt(int irq, void *dev_id)
+{
+	int status;
+	struct sxgbe_rx_queue *rxq = (struct sxgbe_rx_queue *)dev_id;
+	struct sxgbe_priv_data *priv = rxq->priv_ptr;
+
+	/* get the channel status */
+	status = priv->hw->dma->rx_dma_int_status(priv->ioaddr, rxq->queue_no,
+						  &priv->xstats);
+
+	if (likely((status & handle_rx) && (napi_schedule_prep(&priv->napi)))) {
+		priv->hw->dma->disable_dma_irq(priv->ioaddr, rxq->queue_no);
+		__napi_schedule(&priv->napi);
+	}
+
+	/* check for TC configuration change */
+	if (unlikely((status & rx_bump_tc) &&
+		     (priv->rx_tc != SXGBE_MTL_SFMODE) &&
+		     (priv->rx_tc < 128))) {
+		/* step of TC is 32 */
+		priv->rx_tc += 32;
+		priv->hw->mtl->set_rx_mtl_mode(priv->ioaddr,
+					       rxq->queue_no, priv->rx_tc);
+		priv->xstats.rx_threshold = priv->rx_tc;
+	}
+
+	return IRQ_HANDLED;
+}
+
+static inline u64 sxgbe_get_stat64(void __iomem *ioaddr, int reg_lo, int reg_hi)
+{
+	u64 val = readl(ioaddr + reg_lo);
+
+	val |= ((u64)readl(ioaddr + reg_hi)) << 32;
+
+	return val;
+}
+
+
+/*  sxgbe_get_stats64 - entry point to see statistical information of device
+ *  @dev : device pointer.
+ *  @stats : pointer to hold all the statistical information of device.
+ *  Description:
+ *  This function is a driver entry point whenever ifconfig command gets
+ *  executed to see device statistics. Statistics are number of
+ *  bytes sent or received, errors occured etc.
+ *  Return value:
+ *  This function returns various statistical information of device.
+ */
+static struct rtnl_link_stats64 *sxgbe_get_stats64(struct net_device *dev,
+						   struct rtnl_link_stats64 *stats)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+	void __iomem *ioaddr = priv->ioaddr;
+	u64 count;
+
+	spin_lock(&priv->stats_lock);
+	/* Freeze the counter registers before reading value otherwise it may
+	 * get updated by hardware while we are reading them
+	 */
+	writel(SXGBE_MMC_CTRL_CNT_FRZ, ioaddr + SXGBE_MMC_CTL_REG);
+
+	stats->rx_bytes = sxgbe_get_stat64(ioaddr,
+					   SXGBE_MMC_RXOCTETLO_GCNT_REG,
+					   SXGBE_MMC_RXOCTETHI_GCNT_REG);
+
+	stats->rx_packets = sxgbe_get_stat64(ioaddr,
+					     SXGBE_MMC_RXFRAMELO_GBCNT_REG,
+					     SXGBE_MMC_RXFRAMEHI_GBCNT_REG);
+
+	stats->multicast = sxgbe_get_stat64(ioaddr,
+					    SXGBE_MMC_RXMULTILO_GCNT_REG,
+					    SXGBE_MMC_RXMULTIHI_GCNT_REG);
+
+	stats->rx_crc_errors = sxgbe_get_stat64(ioaddr,
+						SXGBE_MMC_RXCRCERRLO_REG,
+						SXGBE_MMC_RXCRCERRHI_REG);
+
+	stats->rx_length_errors = sxgbe_get_stat64(ioaddr,
+						  SXGBE_MMC_RXLENERRLO_REG,
+						  SXGBE_MMC_RXLENERRHI_REG);
+
+	stats->rx_missed_errors = sxgbe_get_stat64(ioaddr,
+						   SXGBE_MMC_RXFIFOOVERFLOWLO_GBCNT_REG,
+						   SXGBE_MMC_RXFIFOOVERFLOWHI_GBCNT_REG);
+
+	stats->tx_bytes = sxgbe_get_stat64(ioaddr,
+					   SXGBE_MMC_TXOCTETLO_GCNT_REG,
+					   SXGBE_MMC_TXOCTETHI_GCNT_REG);
+
+	count = sxgbe_get_stat64(ioaddr, SXGBE_MMC_TXFRAMELO_GBCNT_REG,
+				 SXGBE_MMC_TXFRAMEHI_GBCNT_REG);
+
+	stats->tx_errors = sxgbe_get_stat64(ioaddr, SXGBE_MMC_TXFRAMELO_GCNT_REG,
+					    SXGBE_MMC_TXFRAMEHI_GCNT_REG);
+	stats->tx_errors = count - stats->tx_errors;
+	stats->tx_packets = count;
+	stats->tx_fifo_errors = sxgbe_get_stat64(ioaddr, SXGBE_MMC_TXUFLWLO_GBCNT_REG,
+						 SXGBE_MMC_TXUFLWHI_GBCNT_REG);
+	writel(0, ioaddr + SXGBE_MMC_CTL_REG);
+	spin_unlock(&priv->stats_lock);
+
+	return stats;
+}
+
+/*  sxgbe_set_features - entry point to set offload features of the device.
+ *  @dev : device pointer.
+ *  @features : features which are required to be set.
+ *  Description:
+ *  This function is a driver entry point and called by Linux kernel whenever
+ *  any device features are set or reset by user.
+ *  Return value:
+ *  This function returns 0 after setting or resetting device features.
+ */
+static int sxgbe_set_features(struct net_device *dev,
+			      netdev_features_t features)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+	netdev_features_t changed = dev->features ^ features;
+	u32 ctrl;
+
+	if (changed & NETIF_F_RXCSUM) {
+		ctrl = readl(priv->ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+		if (features & NETIF_F_RXCSUM)
+			ctrl |= SXGBE_RX_CSUMOFFLOAD_ENABLE;
+		else
+			ctrl &= ~SXGBE_RX_CSUMOFFLOAD_ENABLE;
+		writel(ctrl, priv->ioaddr + SXGBE_CORE_RX_CONFIG_REG);
+	}
+
+	return 0;
+}
+
+/*  sxgbe_change_mtu - entry point to change MTU size for the device.
+ *  @dev : device pointer.
+ *  @new_mtu : the new MTU size for the device.
+ *  Description: the Maximum Transfer Unit (MTU) is used by the network layer
+ *  to drive packet transmission. Ethernet has an MTU of 1500 octets
+ *  (ETH_DATA_LEN). This value can be changed with ifconfig.
+ *  Return value:
+ *  0 on success and an appropriate (-)ve integer as defined in errno.h
+ *  file on failure.
+ */
+static int sxgbe_change_mtu(struct net_device *dev, int new_mtu)
+{
+	/* RFC 791, page 25, "Every internet module must be able to forward
+	 * a datagram of 68 octets without further fragmentation."
+	 */
+	if (new_mtu < MIN_MTU || (new_mtu > MAX_MTU)) {
+		netdev_err(dev, "invalid MTU, MTU should be in between %d and %d\n",
+			   MIN_MTU, MAX_MTU);
+		return -EINVAL;
+	}
+
+	/* Return if the buffer sizes will not change */
+	if (dev->mtu == new_mtu)
+		return 0;
+
+	dev->mtu = new_mtu;
+
+	if (!netif_running(dev))
+		return 0;
+
+	/* Recevice ring buffer size is needed to be set based on MTU. If MTU is
+	 * changed then reinitilisation of the receive ring buffers need to be
+	 * done. Hence bring interface down and bring interface back up
+	 */
+	sxgbe_release(dev);
+	return sxgbe_open(dev);
+}
+
+static void sxgbe_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
+				unsigned int reg_n)
+{
+	unsigned long data;
+
+	data = (addr[5] << 8) | addr[4];
+	/* For MAC Addr registers se have to set the Address Enable (AE)
+	 * bit that has no effect on the High Reg 0 where the bit 31 (MO)
+	 * is RO.
+	 */
+	writel(data | SXGBE_HI_REG_AE, ioaddr + SXGBE_ADDR_HIGH(reg_n));
+	data = (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
+	writel(data, ioaddr + SXGBE_ADDR_LOW(reg_n));
+}
+
+/**
+ * sxgbe_set_rx_mode - entry point for setting different receive mode of
+ * a device. unicast, multicast addressing
+ * @dev : pointer to the device structure
+ * Description:
+ * This function is a driver entry point which gets called by the kernel
+ * whenever different receive mode like unicast, multicast and promiscuous
+ * must be enabled/disabled.
+ * Return value:
+ * void.
+ */
+static void sxgbe_set_rx_mode(struct net_device *dev)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+	void __iomem *ioaddr = (void __iomem *)priv->ioaddr;
+	unsigned int value = 0;
+	u32 mc_filter[2];
+	struct netdev_hw_addr *ha;
+	int reg = 1;
+
+	netdev_dbg(dev, "%s: # mcasts %d, # unicast %d\n",
+		   __func__, netdev_mc_count(dev), netdev_uc_count(dev));
+
+	if (dev->flags & IFF_PROMISC) {
+		value = SXGBE_FRAME_FILTER_PR;
+
+	} else if ((netdev_mc_count(dev) > SXGBE_HASH_TABLE_SIZE) ||
+		   (dev->flags & IFF_ALLMULTI)) {
+		value = SXGBE_FRAME_FILTER_PM;	/* pass all multi */
+		writel(0xffffffff, ioaddr + SXGBE_HASH_HIGH);
+		writel(0xffffffff, ioaddr + SXGBE_HASH_LOW);
+
+	} else if (!netdev_mc_empty(dev)) {
+		/* Hash filter for multicast */
+		value = SXGBE_FRAME_FILTER_HMC;
+
+		memset(mc_filter, 0, sizeof(mc_filter));
+		netdev_for_each_mc_addr(ha, dev) {
+			/* The upper 6 bits of the calculated CRC are used to
+			 * index the contens of the hash table
+			 */
+			int bit_nr = bitrev32(~crc32_le(~0, ha->addr, 6)) >> 26;
+
+			/* The most significant bit determines the register to
+			 * use (H/L) while the other 5 bits determine the bit
+			 * within the register.
+			 */
+			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
+		}
+		writel(mc_filter[0], ioaddr + SXGBE_HASH_LOW);
+		writel(mc_filter[1], ioaddr + SXGBE_HASH_HIGH);
+	}
+
+	/* Handle multiple unicast addresses (perfect filtering) */
+	if (netdev_uc_count(dev) > SXGBE_MAX_PERFECT_ADDRESSES)
+		/* Switch to promiscuous mode if more than 16 addrs
+		 * are required
+		 */
+		value |= SXGBE_FRAME_FILTER_PR;
+	else {
+		netdev_for_each_uc_addr(ha, dev) {
+			sxgbe_set_umac_addr(ioaddr, ha->addr, reg);
+			reg++;
+		}
+	}
+#ifdef FRAME_FILTER_DEBUG
+	/* Enable Receive all mode (to debug filtering_fail errors) */
+	value |= SXGBE_FRAME_FILTER_RA;
+#endif
+	writel(value, ioaddr + SXGBE_FRAME_FILTER);
+
+	netdev_dbg(dev, "Filter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
+		   readl(ioaddr + SXGBE_FRAME_FILTER),
+		   readl(ioaddr + SXGBE_HASH_HIGH),
+		   readl(ioaddr + SXGBE_HASH_LOW));
+}
+
+/**
+ * sxgbe_config - entry point for changing configuration mode passed on by
+ * ifconfig
+ * @dev : pointer to the device structure
+ * @map : pointer to the device mapping structure
+ * Description:
+ * This function is a driver entry point which gets called by the kernel
+ * whenever some device configuration is changed.
+ * Return value:
+ * This function returns 0 if success and appropriate error otherwise.
+ */
+static int sxgbe_config(struct net_device *dev, struct ifmap *map)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+
+	/* Can't act on a running interface */
+	if (dev->flags & IFF_UP)
+		return -EBUSY;
+
+	/* Don't allow changing the I/O address */
+	if (map->base_addr != (unsigned long)priv->ioaddr) {
+		netdev_warn(dev, "can't change I/O address\n");
+		return -EOPNOTSUPP;
+	}
+
+	/* Don't allow changing the IRQ */
+	if (map->irq != priv->irq) {
+		netdev_warn(dev, "not change IRQ number %d\n", priv->irq);
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/**
+ * sxgbe_poll_controller - entry point for polling receive by device
+ * @dev : pointer to the device structure
+ * Description:
+ * This function is used by NETCONSOLE and other diagnostic tools
+ * to allow network I/O with interrupts disabled.
+ * Return value:
+ * Void.
+ */
+static void sxgbe_poll_controller(struct net_device *dev)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+
+	disable_irq(priv->irq);
+	sxgbe_rx_interrupt(priv->irq, dev);
+	enable_irq(priv->irq);
+}
+#endif
+
+/*  sxgbe_ioctl - Entry point for the Ioctl
+ *  @dev: Device pointer.
+ *  @rq: An IOCTL specefic structure, that can contain a pointer to
+ *  a proprietary structure used to pass information to the driver.
+ *  @cmd: IOCTL command
+ *  Description:
+ *  Currently it supports the phy_mii_ioctl(...) and HW time stamping.
+ */
+static int sxgbe_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(dev);
+	int ret = -EOPNOTSUPP;
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	switch (cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		if (!priv->phydev)
+			return -EINVAL;
+		ret = phy_mii_ioctl(priv->phydev, rq, cmd);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+static const struct net_device_ops sxgbe_netdev_ops = {
+	.ndo_open		= sxgbe_open,
+	.ndo_start_xmit		= sxgbe_xmit,
+	.ndo_stop		= sxgbe_release,
+	.ndo_get_stats64	= sxgbe_get_stats64,
+	.ndo_change_mtu		= sxgbe_change_mtu,
+	.ndo_set_features	= sxgbe_set_features,
+	.ndo_set_rx_mode	= sxgbe_set_rx_mode,
+	.ndo_tx_timeout		= sxgbe_tx_timeout,
+	.ndo_do_ioctl		= sxgbe_ioctl,
+	.ndo_set_config		= sxgbe_config,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= sxgbe_poll_controller,
+#endif
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
+/* Get the hardware ops */
+void sxgbe_get_ops(struct sxgbe_ops * const ops_ptr)
+{
+	ops_ptr->mac		= sxgbe_get_core_ops();
+	ops_ptr->desc		= sxgbe_get_desc_ops();
+	ops_ptr->dma		= sxgbe_get_dma_ops();
+	ops_ptr->mtl		= sxgbe_get_mtl_ops();
+
+	/* set the MDIO communication Address/Data regisers */
+	ops_ptr->mii.addr	= SXGBE_MDIO_SCMD_ADD_REG;
+	ops_ptr->mii.data	= SXGBE_MDIO_SCMD_DATA_REG;
+
+	/* Assigning the default link settings
+	 * no SXGBE defined default values to be set in registers,
+	 * so assigning as 0 for port and duplex
+	 */
+	ops_ptr->link.port	= 0;
+	ops_ptr->link.duplex	= 0;
+	ops_ptr->link.speed	= SXGBE_SPEED_10G;
+}
+
+/**
+ *  sxgbe_hw_init - Init the GMAC device
+ *  @priv: driver private structure
+ *  Description: this function checks the HW capability
+ *  (if supported) and sets the driver's features.
+ */
+static void sxgbe_hw_init(struct sxgbe_priv_data * const priv)
+{
+	u32 ctrl_ids;
+
+	priv->hw = kmalloc(sizeof(*priv->hw), GFP_KERNEL);
+
+	/* get the hardware ops */
+	sxgbe_get_ops(priv->hw);
+
+	/* get the controller id */
+	ctrl_ids = priv->hw->mac->get_controller_version(priv->ioaddr);
+	priv->hw->ctrl_uid = (ctrl_ids & 0x00ff0000) >> 16;
+	priv->hw->ctrl_id = (ctrl_ids & 0x000000ff);
+	pr_info("user ID: 0x%x, Controller ID: 0x%x\n",
+		priv->hw->ctrl_uid, priv->hw->ctrl_id);
+
+	/* get the H/W features */
+	if (!sxgbe_get_hw_features(priv))
+		pr_info("Hardware features not found\n");
+
+	if (priv->hw_cap.tx_csum_offload)
+		pr_info("TX Checksum offload supported\n");
+
+	if (priv->hw_cap.rx_csum_offload)
+		pr_info("RX Checksum offload supported\n");
+}
+
+/**
+ * sxgbe_drv_probe
+ * @device: device pointer
+ * @plat_dat: platform data pointer
+ * @addr: iobase memory address
+ * Description: this is the main probe function used to
+ * call the alloc_etherdev, allocate the priv structure.
+ */
+struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
+					struct sxgbe_plat_data *plat_dat,
+					void __iomem *addr)
+{
+	struct sxgbe_priv_data *priv;
+	struct net_device *ndev;
+	int ret;
+
+	ndev = alloc_etherdev_mqs(sizeof(struct sxgbe_priv_data),
+				  SXGBE_TX_QUEUES, SXGBE_RX_QUEUES);
+	if (!ndev)
+		return NULL;
+
+	SET_NETDEV_DEV(ndev, device);
+
+	priv = netdev_priv(ndev);
+	priv->device = device;
+	priv->dev = ndev;
+
+	sxgbe_set_ethtool_ops(ndev);
+	priv->plat = plat_dat;
+	priv->ioaddr = addr;
+
+	/* Init MAC and get the capabilities */
+	sxgbe_hw_init(priv);
+
+	/* allocate memory resources for Descriptor rings */
+	ret = txring_mem_alloc(priv);
+	if (ret)
+		goto error_free_netdev;
+
+	ret = rxring_mem_alloc(priv);
+	if (ret)
+		goto error_free_netdev;
+
+	ndev->netdev_ops = &sxgbe_netdev_ops;
+
+	ndev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM;
+	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
+	ndev->watchdog_timeo = msecs_to_jiffies(TX_TIMEO);
+
+	/* assign filtering support */
+	ndev->priv_flags |= IFF_UNICAST_FLT;
+
+	priv->msg_enable = netif_msg_init(debug, default_msg_level);
+
+	/* Rx Watchdog is available, enable depend on platform data */
+	if (!priv->plat->riwt_off) {
+		priv->use_riwt = 1;
+		pr_info("Enable RX Mitigation via HW Watchdog Timer\n");
+	}
+
+	netif_napi_add(ndev, &priv->napi, sxgbe_poll, 64);
+
+	spin_lock_init(&priv->stats_lock);
+
+	priv->sxgbe_clk = clk_get(priv->device, SXGBE_RESOURCE_NAME);
+	if (IS_ERR(priv->sxgbe_clk)) {
+		netdev_warn(ndev, "%s: warning: cannot get CSR clock\n",
+			    __func__);
+		goto error_clk_get;
+	}
+
+	/* If a specific clk_csr value is passed from the platform
+	 * this means that the CSR Clock Range selection cannot be
+	 * changed at run-time and it is fixed. Viceversa the driver'll try to
+	 * set the MDC clock dynamically according to the csr actual
+	 * clock input.
+	 */
+	if (!priv->plat->clk_csr)
+		sxgbe_clk_csr_set(priv);
+	else
+		priv->clk_csr = priv->plat->clk_csr;
+
+	/* MDIO bus Registration */
+	ret = sxgbe_mdio_register(ndev);
+	if (ret < 0) {
+		netdev_dbg(ndev, "%s: MDIO bus (id: %d) registration failed\n",
+			   __func__, priv->plat->bus_id);
+		goto error_mdio_register;
+	}
+
+	ret = register_netdev(ndev);
+	if (ret) {
+		pr_err("%s: ERROR %i registering the device\n", __func__, ret);
+		goto error_netdev_register;
+	}
+
+	sxgbe_check_ether_addr(priv);
+
+	return priv;
+
+error_mdio_register:
+	clk_put(priv->sxgbe_clk);
+error_clk_get:
+error_netdev_register:
+	netif_napi_del(&priv->napi);
+error_free_netdev:
+	free_netdev(ndev);
+
+	return NULL;
+}
+
+/**
+ * sxgbe_drv_remove
+ * @ndev: net device pointer
+ * Description: this function resets the TX/RX processes, disables the MAC RX/TX
+ * changes the link status, releases the DMA descriptor rings.
+ */
+int sxgbe_drv_remove(struct net_device *ndev)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(ndev);
+
+	netdev_info(ndev, "%s: removing driver\n", __func__);
+
+	priv->hw->dma->stop_rx(priv->ioaddr, SXGBE_RX_QUEUES);
+	priv->hw->dma->stop_tx(priv->ioaddr, SXGBE_TX_QUEUES);
+
+	priv->hw->mac->enable_tx(priv->ioaddr, false);
+	priv->hw->mac->enable_rx(priv->ioaddr, false);
+
+	netif_napi_del(&priv->napi);
+
+	sxgbe_mdio_unregister(ndev);
+
+	unregister_netdev(ndev);
+
+	free_netdev(ndev);
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+int sxgbe_suspend(struct net_device *ndev)
+{
+	return 0;
+}
+
+int sxgbe_resume(struct net_device *ndev)
+{
+	return 0;
+}
+
+int sxgbe_freeze(struct net_device *ndev)
+{
+	return -ENOSYS;
+}
+
+int sxgbe_restore(struct net_device *ndev)
+{
+	return -ENOSYS;
+}
+#endif /* CONFIG_PM */
+
+/* Driver is configured as Platform driver */
+static int __init sxgbe_init(void)
+{
+	int ret;
+
+	ret = sxgbe_register_platform();
+	if (ret)
+		goto err;
+	return 0;
+err:
+	pr_err("driver registration failed\n");
+	return ret;
+}
+
+static void __exit sxgbe_exit(void)
+{
+	sxgbe_unregister_platform();
+}
+
+module_init(sxgbe_init);
+module_exit(sxgbe_exit);
+
+#ifndef MODULE
+static int __init sxgbe_cmdline_opt(char *str)
+{
+	return 0;
+}
+
+__setup("sxgbeeth=", sxgbe_cmdline_opt);
+#endif /* MODULE */
+
+
+
+MODULE_DESCRIPTION("SAMSUNG 10G/2.5G/1G Ethernet PLATFORM driver");
+
+MODULE_PARM_DESC(debug, "Message Level (-1: default, 0: no output, 16: all)");
+
+MODULE_AUTHOR("Siva Reddy Kallam <siva.kallam@samsung.com>");
+MODULE_AUTHOR("ByungHo An <bh74.an@samsung.com>");
+MODULE_AUTHOR("Girish K S <ks.giri@samsung.com>");
+MODULE_AUTHOR("Vipul Pandya <vipul.pandya@samsung.com>");
+
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c
new file mode 100644
index 0000000..b0eb0a2
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c
@@ -0,0 +1,251 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/io.h>
+#include <linux/mii.h>
+#include <linux/netdevice.h>
+#include <linux/platform_device.h>
+#include <linux/phy.h>
+#include <linux/slab.h>
+#include <linux/sxgbe_platform.h>
+
+#include "sxgbe_common.h"
+#include "sxgbe_reg.h"
+
+#define SXGBE_SMA_WRITE_CMD	0x01 /* write command */
+#define SXGBE_SMA_PREAD_CMD	0x02 /* post read  increament address */
+#define SXGBE_SMA_READ_CMD	0x03 /* read command */
+#define SXGBE_SMA_SKIP_ADDRFRM	0x00040000 /* skip the address frame */
+#define SXGBE_MII_BUSY		0x00800000 /* mii busy */
+
+static int sxgbe_mdio_busy_wait(void __iomem *ioaddr, unsigned int mii_data)
+{
+	unsigned long fin_time = jiffies + 3 * HZ; /* 3 seconds */
+
+	while (!time_after(jiffies, fin_time)) {
+		if (!(readl(ioaddr + mii_data) & SXGBE_MII_BUSY))
+			return 0;
+		cpu_relax();
+	}
+
+	return -EBUSY;
+}
+
+static void sxgbe_mdio_ctrl_data(struct sxgbe_priv_data *sp, u32 cmd,
+				 u16 phydata)
+{
+	u32 reg = phydata;
+
+	reg |= (cmd << 16) | SXGBE_SMA_SKIP_ADDRFRM |
+	       ((sp->clk_csr & 0x7) << 19) | SXGBE_MII_BUSY;
+	writel(reg, sp->ioaddr + sp->hw->mii.data);
+}
+
+static void sxgbe_mdio_c45(struct sxgbe_priv_data *sp, u32 cmd, int phyaddr,
+			   int phyreg, u16 phydata)
+{
+	u32 reg;
+
+	/* set mdio address register */
+	reg = ((phyreg >> 16) & 0x1f) << 21;
+	reg |= (phyaddr << 16) | (phyreg & 0xffff);
+	writel(reg, sp->ioaddr + sp->hw->mii.addr);
+
+	sxgbe_mdio_ctrl_data(sp, cmd, phydata);
+}
+
+static void sxgbe_mdio_c22(struct sxgbe_priv_data *sp, u32 cmd, int phyaddr,
+			   int phyreg, u16 phydata)
+{
+	u32 reg;
+
+	writel(1 << phyaddr, sp->ioaddr + SXGBE_MDIO_CLAUSE22_PORT_REG);
+
+	/* set mdio address register */
+	reg = (phyaddr << 16) | (phyreg & 0x1f);
+	writel(reg, sp->ioaddr + sp->hw->mii.addr);
+
+	sxgbe_mdio_ctrl_data(sp, cmd, phydata);
+}
+
+static int sxgbe_mdio_access(struct sxgbe_priv_data *sp, u32 cmd, int phyaddr,
+			     int phyreg, u16 phydata)
+{
+	const struct mii_regs *mii = &sp->hw->mii;
+	int rc;
+
+	rc = sxgbe_mdio_busy_wait(sp->ioaddr, mii->data);
+	if (rc < 0)
+		return rc;
+
+	if (phyreg & MII_ADDR_C45) {
+		sxgbe_mdio_c45(sp, cmd, phyaddr, phyreg, phydata);
+	} else {
+		 /* Ports 0-3 only support C22. */
+		if (phyaddr >= 4)
+			return -ENODEV;
+
+		sxgbe_mdio_c22(sp, cmd, phyaddr, phyreg, phydata);
+	}
+
+	return sxgbe_mdio_busy_wait(sp->ioaddr, mii->data);
+}
+
+/**
+ * sxgbe_mdio_read
+ * @bus: points to the mii_bus structure
+ * @phyaddr: address of phy port
+ * @phyreg: address of register with in phy register
+ * Description: this function used for C45 and C22 MDIO Read
+ */
+static int sxgbe_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
+{
+	struct net_device *ndev = bus->priv;
+	struct sxgbe_priv_data *priv = netdev_priv(ndev);
+	int rc;
+
+	rc = sxgbe_mdio_access(priv, SXGBE_SMA_READ_CMD, phyaddr, phyreg, 0);
+	if (rc < 0)
+		return rc;
+
+	return readl(priv->ioaddr + priv->hw->mii.data) & 0xffff;
+}
+
+/**
+ * sxgbe_mdio_write
+ * @bus: points to the mii_bus structure
+ * @phyaddr: address of phy port
+ * @phyreg: address of phy registers
+ * @phydata: data to be written into phy register
+ * Description: this function is used for C45 and C22 MDIO write
+ */
+static int sxgbe_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
+			     u16 phydata)
+{
+	struct net_device *ndev = bus->priv;
+	struct sxgbe_priv_data *priv = netdev_priv(ndev);
+
+	return sxgbe_mdio_access(priv, SXGBE_SMA_WRITE_CMD, phyaddr, phyreg,
+				 phydata);
+}
+
+int sxgbe_mdio_register(struct net_device *ndev)
+{
+	struct mii_bus *mdio_bus;
+	struct sxgbe_priv_data *priv = netdev_priv(ndev);
+	struct sxgbe_mdio_bus_data *mdio_data = priv->plat->mdio_bus_data;
+	int err, phy_addr;
+	int *irqlist;
+	bool act;
+
+	/* allocate the new mdio bus */
+	mdio_bus = mdiobus_alloc();
+	if (!mdio_bus) {
+		netdev_err(ndev, "%s: mii bus allocation failed\n", __func__);
+		return -ENOMEM;
+	}
+
+	if (mdio_data->irqs)
+		irqlist = mdio_data->irqs;
+	else
+		irqlist = priv->mii_irq;
+
+	/* assign mii bus fields */
+	mdio_bus->name = "samsxgbe";
+	mdio_bus->read = &sxgbe_mdio_read;
+	mdio_bus->write = &sxgbe_mdio_write;
+	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		 mdio_bus->name, priv->plat->bus_id);
+	mdio_bus->priv = ndev;
+	mdio_bus->phy_mask = mdio_data->phy_mask;
+	mdio_bus->parent = priv->device;
+
+	/* register with kernel subsystem */
+	err = mdiobus_register(mdio_bus);
+	if (err != 0) {
+		netdev_err(ndev, "mdiobus register failed\n");
+		goto mdiobus_err;
+	}
+
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+		struct phy_device *phy = mdio_bus->phy_map[phy_addr];
+
+		if (phy) {
+			char irq_num[4];
+			char *irq_str;
+			/* If an IRQ was provided to be assigned after
+			 * the bus probe, do it here.
+			 */
+			if ((mdio_data->irqs == NULL) &&
+			    (mdio_data->probed_phy_irq > 0)) {
+				irqlist[phy_addr] = mdio_data->probed_phy_irq;
+				phy->irq = mdio_data->probed_phy_irq;
+			}
+
+			/* If we're  going to bind the MAC to this PHY bus,
+			 * and no PHY number was provided to the MAC,
+			 * use the one probed here.
+			 */
+			if (priv->plat->phy_addr == -1)
+				priv->plat->phy_addr = phy_addr;
+
+			act = (priv->plat->phy_addr == phy_addr);
+			switch (phy->irq) {
+			case PHY_POLL:
+				irq_str = "POLL";
+				break;
+			case PHY_IGNORE_INTERRUPT:
+				irq_str = "IGNORE";
+				break;
+			default:
+				sprintf(irq_num, "%d", phy->irq);
+				irq_str = irq_num;
+				break;
+			}
+			netdev_info(ndev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
+				    phy->phy_id, phy_addr, irq_str,
+				    dev_name(&phy->dev), act ? " active" : "");
+		}
+	}
+
+	if (!err) {
+		netdev_err(ndev, "PHY not found\n");
+		mdiobus_unregister(mdio_bus);
+		mdiobus_free(mdio_bus);
+		goto mdiobus_err;
+	}
+
+	priv->mii = mdio_bus;
+
+	return 0;
+
+mdiobus_err:
+	mdiobus_free(mdio_bus);
+	return err;
+}
+
+int sxgbe_mdio_unregister(struct net_device *ndev)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(ndev);
+
+	if (!priv->mii)
+		return 0;
+
+	mdiobus_unregister(priv->mii);
+	priv->mii->priv = NULL;
+	mdiobus_free(priv->mii);
+	priv->mii = NULL;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c
new file mode 100644
index 0000000..324681c
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c
@@ -0,0 +1,254 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/io.h>
+#include <linux/errno.h>
+#include <linux/export.h>
+#include <linux/jiffies.h>
+
+#include "sxgbe_mtl.h"
+#include "sxgbe_reg.h"
+
+static void sxgbe_mtl_init(void __iomem *ioaddr, unsigned int etsalg,
+			   unsigned int raa)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_OP_MODE_REG);
+	reg_val &= ETS_RST;
+
+	/* ETS Algorith */
+	switch (etsalg & SXGBE_MTL_OPMODE_ESTMASK) {
+	case ETS_WRR:
+		reg_val &= ETS_WRR;
+		break;
+	case ETS_WFQ:
+		reg_val |= ETS_WFQ;
+		break;
+	case ETS_DWRR:
+		reg_val |= ETS_DWRR;
+		break;
+	}
+	writel(reg_val, ioaddr + SXGBE_MTL_OP_MODE_REG);
+
+	switch (raa & SXGBE_MTL_OPMODE_RAAMASK) {
+	case RAA_SP:
+		reg_val &= RAA_SP;
+		break;
+	case RAA_WSP:
+		reg_val |= RAA_WSP;
+		break;
+	}
+	writel(reg_val, ioaddr + SXGBE_MTL_OP_MODE_REG);
+}
+
+/* For Dynamic DMA channel mapping for Rx queue */
+static void sxgbe_mtl_dma_dm_rxqueue(void __iomem *ioaddr)
+{
+	writel(RX_QUEUE_DYNAMIC, ioaddr + SXGBE_MTL_RXQ_DMAMAP0_REG);
+	writel(RX_QUEUE_DYNAMIC, ioaddr + SXGBE_MTL_RXQ_DMAMAP1_REG);
+	writel(RX_QUEUE_DYNAMIC, ioaddr + SXGBE_MTL_RXQ_DMAMAP2_REG);
+}
+
+static void sxgbe_mtl_set_txfifosize(void __iomem *ioaddr, int queue_num,
+				     int queue_fifo)
+{
+	u32 fifo_bits, reg_val;
+
+	/* 0 means 256 bytes */
+	fifo_bits = (queue_fifo / SXGBE_MTL_TX_FIFO_DIV) - 1;
+	reg_val = readl(ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+	reg_val |= (fifo_bits << SXGBE_MTL_FIFO_LSHIFT);
+	writel(reg_val, ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+}
+
+static void sxgbe_mtl_set_rxfifosize(void __iomem *ioaddr, int queue_num,
+				     int queue_fifo)
+{
+	u32 fifo_bits, reg_val;
+
+	/* 0 means 256 bytes */
+	fifo_bits = (queue_fifo / SXGBE_MTL_RX_FIFO_DIV)-1;
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val |= (fifo_bits << SXGBE_MTL_FIFO_LSHIFT);
+	writel(reg_val, ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void sxgbe_mtl_enable_txqueue(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+	reg_val |= SXGBE_MTL_ENABLE_QUEUE;
+	writel(reg_val, ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+}
+
+static void sxgbe_mtl_disable_txqueue(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+	reg_val &= ~SXGBE_MTL_ENABLE_QUEUE;
+	writel(reg_val, ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+}
+
+static void sxgbe_mtl_fc_active(void __iomem *ioaddr, int queue_num,
+				int threshold)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val &= ~(SXGBE_MTL_FCMASK << RX_FC_ACTIVE);
+	reg_val |= (threshold << RX_FC_ACTIVE);
+
+	writel(reg_val, ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void sxgbe_mtl_fc_enable(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val |= SXGBE_MTL_ENABLE_FC;
+	writel(reg_val, ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void sxgbe_mtl_fc_deactive(void __iomem *ioaddr, int queue_num,
+				  int threshold)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val &= ~(SXGBE_MTL_FCMASK << RX_FC_DEACTIVE);
+	reg_val |= (threshold << RX_FC_DEACTIVE);
+
+	writel(reg_val, ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void sxgbe_mtl_fep_enable(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val |= SXGBE_MTL_RXQ_OP_FEP;
+
+	writel(reg_val, ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void sxgbe_mtl_fep_disable(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val &= ~(SXGBE_MTL_RXQ_OP_FEP);
+
+	writel(reg_val, ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void sxgbe_mtl_fup_enable(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val |= SXGBE_MTL_RXQ_OP_FUP;
+
+	writel(reg_val, ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void sxgbe_mtl_fup_disable(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val &= ~(SXGBE_MTL_RXQ_OP_FUP);
+
+	writel(reg_val, ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+
+static void sxgbe_set_tx_mtl_mode(void __iomem *ioaddr, int queue_num,
+				  int tx_mode)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+	/* TX specific MTL mode settings */
+	if (tx_mode == SXGBE_MTL_SFMODE) {
+		reg_val |= SXGBE_MTL_SFMODE;
+	} else {
+		/* set the TTC values */
+		if (tx_mode <= 64)
+			reg_val |= MTL_CONTROL_TTC_64;
+		else if (tx_mode <= 96)
+			reg_val |= MTL_CONTROL_TTC_96;
+		else if (tx_mode <= 128)
+			reg_val |= MTL_CONTROL_TTC_128;
+		else if (tx_mode <= 192)
+			reg_val |= MTL_CONTROL_TTC_192;
+		else if (tx_mode <= 256)
+			reg_val |= MTL_CONTROL_TTC_256;
+		else if (tx_mode <= 384)
+			reg_val |= MTL_CONTROL_TTC_384;
+		else
+			reg_val |= MTL_CONTROL_TTC_512;
+	}
+
+	/* write into TXQ operation register */
+	writel(reg_val, ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));
+}
+
+static void sxgbe_set_rx_mtl_mode(void __iomem *ioaddr, int queue_num,
+				  int rx_mode)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+	/* RX specific MTL mode settings */
+	if (rx_mode == SXGBE_RX_MTL_SFMODE) {
+		reg_val |= SXGBE_RX_MTL_SFMODE;
+	} else {
+		if (rx_mode <= 64)
+			reg_val |= MTL_CONTROL_RTC_64;
+		else if (rx_mode <= 96)
+			reg_val |= MTL_CONTROL_RTC_96;
+		else if (rx_mode <= 128)
+			reg_val |= MTL_CONTROL_RTC_128;
+	}
+
+	/* write into RXQ operation register */
+	writel(reg_val, ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static const struct sxgbe_mtl_ops mtl_ops = {
+	.mtl_set_txfifosize		= sxgbe_mtl_set_txfifosize,
+	.mtl_set_rxfifosize		= sxgbe_mtl_set_rxfifosize,
+	.mtl_enable_txqueue		= sxgbe_mtl_enable_txqueue,
+	.mtl_disable_txqueue		= sxgbe_mtl_disable_txqueue,
+	.mtl_dynamic_dma_rxqueue	= sxgbe_mtl_dma_dm_rxqueue,
+	.set_tx_mtl_mode		= sxgbe_set_tx_mtl_mode,
+	.set_rx_mtl_mode		= sxgbe_set_rx_mtl_mode,
+	.mtl_init			= sxgbe_mtl_init,
+	.mtl_fc_active			= sxgbe_mtl_fc_active,
+	.mtl_fc_deactive		= sxgbe_mtl_fc_deactive,
+	.mtl_fc_enable			= sxgbe_mtl_fc_enable,
+	.mtl_fep_enable			= sxgbe_mtl_fep_enable,
+	.mtl_fep_disable		= sxgbe_mtl_fep_disable,
+	.mtl_fup_enable			= sxgbe_mtl_fup_enable,
+	.mtl_fup_disable		= sxgbe_mtl_fup_disable
+};
+
+const struct sxgbe_mtl_ops *sxgbe_get_mtl_ops(void)
+{
+	return &mtl_ops;
+}
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.h
new file mode 100644
index 0000000..7e4810c
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.h
@@ -0,0 +1,104 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __SXGBE_MTL_H__
+#define __SXGBE_MTL_H__
+
+#define SXGBE_MTL_OPMODE_ESTMASK	0x3
+#define SXGBE_MTL_OPMODE_RAAMASK	0x1
+#define SXGBE_MTL_FCMASK		0x7
+#define SXGBE_MTL_TX_FIFO_DIV		256
+#define SXGBE_MTL_RX_FIFO_DIV		256
+
+#define SXGBE_MTL_RXQ_OP_FEP		BIT(4)
+#define SXGBE_MTL_RXQ_OP_FUP		BIT(3)
+#define SXGBE_MTL_ENABLE_FC		0x80
+
+#define ETS_WRR				0xFFFFFF9F
+#define ETS_RST				0xFFFFFF9F
+#define ETS_WFQ				0x00000020
+#define ETS_DWRR			0x00000040
+#define RAA_SP				0xFFFFFFFB
+#define RAA_WSP				0x00000004
+
+#define RX_QUEUE_DYNAMIC		0x80808080
+#define RX_FC_ACTIVE			8
+#define RX_FC_DEACTIVE			13
+
+enum ttc_control {
+	MTL_CONTROL_TTC_64 = 0x00000000,
+	MTL_CONTROL_TTC_96 = 0x00000020,
+	MTL_CONTROL_TTC_128 = 0x00000030,
+	MTL_CONTROL_TTC_192 = 0x00000040,
+	MTL_CONTROL_TTC_256 = 0x00000050,
+	MTL_CONTROL_TTC_384 = 0x00000060,
+	MTL_CONTROL_TTC_512 = 0x00000070,
+};
+
+enum rtc_control {
+	MTL_CONTROL_RTC_64 = 0x00000000,
+	MTL_CONTROL_RTC_96 = 0x00000002,
+	MTL_CONTROL_RTC_128 = 0x00000003,
+};
+
+enum flow_control_th {
+	MTL_FC_FULL_1K = 0x00000000,
+	MTL_FC_FULL_2K = 0x00000001,
+	MTL_FC_FULL_4K = 0x00000002,
+	MTL_FC_FULL_5K = 0x00000003,
+	MTL_FC_FULL_6K = 0x00000004,
+	MTL_FC_FULL_8K = 0x00000005,
+	MTL_FC_FULL_16K = 0x00000006,
+	MTL_FC_FULL_24K = 0x00000007,
+};
+
+struct sxgbe_mtl_ops {
+	void (*mtl_init)(void __iomem *ioaddr, unsigned int etsalg,
+			 unsigned int raa);
+
+	void (*mtl_set_txfifosize)(void __iomem *ioaddr, int queue_num,
+				   int mtl_fifo);
+
+	void (*mtl_set_rxfifosize)(void __iomem *ioaddr, int queue_num,
+				   int queue_fifo);
+
+	void (*mtl_enable_txqueue)(void __iomem *ioaddr, int queue_num);
+
+	void (*mtl_disable_txqueue)(void __iomem *ioaddr, int queue_num);
+
+	void (*set_tx_mtl_mode)(void __iomem *ioaddr, int queue_num,
+				int tx_mode);
+
+	void (*set_rx_mtl_mode)(void __iomem *ioaddr, int queue_num,
+				int rx_mode);
+
+	void (*mtl_dynamic_dma_rxqueue)(void __iomem *ioaddr);
+
+	void (*mtl_fc_active)(void __iomem *ioaddr, int queue_num,
+			      int threshold);
+
+	void (*mtl_fc_deactive)(void __iomem *ioaddr, int queue_num,
+				int threshold);
+
+	void (*mtl_fc_enable)(void __iomem *ioaddr, int queue_num);
+
+	void (*mtl_fep_enable)(void __iomem *ioaddr, int queue_num);
+
+	void (*mtl_fep_disable)(void __iomem *ioaddr, int queue_num);
+
+	void (*mtl_fup_enable)(void __iomem *ioaddr, int queue_num);
+
+	void (*mtl_fup_disable)(void __iomem *ioaddr, int queue_num);
+};
+
+const struct sxgbe_mtl_ops *sxgbe_get_mtl_ops(void);
+
+#endif /* __SXGBE_MTL_H__ */
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
new file mode 100644
index 0000000..f5a9de7
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
@@ -0,0 +1,253 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/etherdevice.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/of.h>
+#include <linux/of_irq.h>
+#include <linux/of_net.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/sxgbe_platform.h>
+
+#include "sxgbe_common.h"
+#include "sxgbe_reg.h"
+
+#ifdef CONFIG_OF
+static int sxgbe_probe_config_dt(struct platform_device *pdev,
+				 struct sxgbe_plat_data *plat,
+				 const char **mac)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct sxgbe_dma_cfg *dma_cfg;
+
+	if (!np)
+		return -ENODEV;
+
+	*mac = of_get_mac_address(np);
+	plat->interface = of_get_phy_mode(np);
+
+	plat->bus_id = of_alias_get_id(np, "ethernet");
+	if (plat->bus_id < 0)
+		plat->bus_id = 0;
+
+	plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
+					   sizeof(*plat->mdio_bus_data),
+					   GFP_KERNEL);
+
+	dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg), GFP_KERNEL);
+	if (!dma_cfg)
+		return -ENOMEM;
+
+	plat->dma_cfg = dma_cfg;
+	of_property_read_u32(np, "samsung,pbl", &dma_cfg->pbl);
+	if (of_property_read_u32(np, "samsung,burst-map", &dma_cfg->burst_map) == 0)
+		dma_cfg->fixed_burst = true;
+
+	return 0;
+}
+#else
+static int sxgbe_probe_config_dt(struct platform_device *pdev,
+				 struct sxgbe_plat_data *plat,
+				 const char **mac)
+{
+	return -ENOSYS;
+}
+#endif /* CONFIG_OF */
+
+/**
+ * sxgbe_platform_probe
+ * @pdev: platform device pointer
+ * Description: platform_device probe function. It allocates
+ * the necessary resources and invokes the main to init
+ * the net device, register the mdio bus etc.
+ */
+static int sxgbe_platform_probe(struct platform_device *pdev)
+{
+	int ret;
+	int i, chan;
+	struct resource *res;
+	struct device *dev = &pdev->dev;
+	void __iomem *addr;
+	struct sxgbe_priv_data *priv = NULL;
+	struct sxgbe_plat_data *plat_dat = NULL;
+	const char *mac = NULL;
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct device_node *node = dev->of_node;
+
+	/* Get memory resource */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res)
+		goto err_out;
+
+	addr = devm_ioremap_resource(dev, res);
+	if (IS_ERR(addr))
+		return PTR_ERR(addr);
+
+	if (pdev->dev.of_node) {
+		plat_dat = devm_kzalloc(&pdev->dev,
+					sizeof(struct sxgbe_plat_data),
+					GFP_KERNEL);
+		if (!plat_dat)
+			return  -ENOMEM;
+
+		ret = sxgbe_probe_config_dt(pdev, plat_dat, &mac);
+		if (ret) {
+			pr_err("%s: main dt probe failed\n", __func__);
+			return ret;
+		}
+	}
+
+	/* Get MAC address if available (DT) */
+	if (mac)
+		ether_addr_copy(priv->dev->dev_addr, mac);
+
+	priv = sxgbe_drv_probe(&(pdev->dev), plat_dat, addr);
+	if (!priv) {
+		pr_err("%s: main driver probe failed\n", __func__);
+		goto err_out;
+	}
+
+	/* Get the SXGBE common INT information */
+	priv->irq  = irq_of_parse_and_map(node, 0);
+	if (priv->irq <= 0) {
+		dev_err(dev, "sxgbe common irq parsing failed\n");
+		goto err_drv_remove;
+	}
+
+	/* Get the TX/RX IRQ numbers */
+	for (i = 0, chan = 1; i < SXGBE_TX_QUEUES; i++) {
+		priv->txq[i]->irq_no = irq_of_parse_and_map(node, chan++);
+		if (priv->txq[i]->irq_no <= 0) {
+			dev_err(dev, "sxgbe tx irq parsing failed\n");
+			goto err_tx_irq_unmap;
+		}
+	}
+
+	for (i = 0; i < SXGBE_RX_QUEUES; i++) {
+		priv->rxq[i]->irq_no = irq_of_parse_and_map(node, chan++);
+		if (priv->rxq[i]->irq_no <= 0) {
+			dev_err(dev, "sxgbe rx irq parsing failed\n");
+			goto err_rx_irq_unmap;
+		}
+	}
+
+	platform_set_drvdata(pdev, priv->dev);
+
+	pr_debug("platform driver registration completed\n");
+
+	return 0;
+
+err_rx_irq_unmap:
+	while (--i)
+		irq_dispose_mapping(priv->rxq[i]->irq_no);
+	i = SXGBE_TX_QUEUES;
+err_tx_irq_unmap:
+	while (--i)
+		irq_dispose_mapping(priv->txq[i]->irq_no);
+	irq_dispose_mapping(priv->irq);
+err_drv_remove:
+	sxgbe_drv_remove(ndev);
+err_out:
+	return -ENODEV;
+}
+
+/**
+ * sxgbe_platform_remove
+ * @pdev: platform device pointer
+ * Description: this function calls the main to free the net resources
+ * and calls the platforms hook and release the resources (e.g. mem).
+ */
+static int sxgbe_platform_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	int ret = sxgbe_drv_remove(ndev);
+
+	return ret;
+}
+
+#ifdef CONFIG_PM
+static int sxgbe_platform_suspend(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	return sxgbe_suspend(ndev);
+}
+
+static int sxgbe_platform_resume(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	return sxgbe_resume(ndev);
+}
+
+int sxgbe_platform_freeze(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	return sxgbe_freeze(ndev);
+}
+
+int sxgbe_platform_restore(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	return sxgbe_restore(ndev);
+}
+
+static const struct dev_pm_ops sxgbe_platform_pm_ops = {
+	.suspend	= sxgbe_platform_suspend,
+	.resume		= sxgbe_platform_resume,
+	.freeze		= sxgbe_platform_freeze,
+	.thaw		= sxgbe_platform_restore,
+	.restore	= sxgbe_platform_restore,
+};
+#else
+static const struct dev_pm_ops sxgbe_platform_pm_ops;
+#endif /* CONFIG_PM */
+
+static const struct of_device_id sxgbe_dt_ids[] = {
+	{ .compatible = "samsung,sxgbe-v2.0a"},
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, sxgbe_dt_ids);
+
+struct platform_driver sxgbe_platform_driver = {
+	.probe	= sxgbe_platform_probe,
+	.remove	= sxgbe_platform_remove,
+	.driver	= {
+		.name		= SXGBE_RESOURCE_NAME,
+		.owner		= THIS_MODULE,
+		.pm		= &sxgbe_platform_pm_ops,
+		.of_match_table	= of_match_ptr(sxgbe_dt_ids),
+	},
+};
+
+int sxgbe_register_platform(void)
+{
+	int err;
+
+	err = platform_driver_register(&sxgbe_platform_driver);
+	if (err)
+		pr_err("failed to register the platform driver\n");
+
+	return err;
+}
+
+void sxgbe_unregister_platform(void)
+{
+	platform_driver_unregister(&sxgbe_platform_driver);
+}
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
new file mode 100644
index 0000000..d1cd9ac
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
@@ -0,0 +1,477 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __SXGBE_REGMAP_H__
+#define __SXGBE_REGMAP_H__
+
+/* SXGBE MAC Registers */
+#define SXGBE_CORE_TX_CONFIG_REG	0x0000
+#define SXGBE_CORE_RX_CONFIG_REG	0x0004
+#define SXGBE_CORE_PKT_FILTER_REG	0x0008
+#define SXGBE_CORE_WATCHDOG_TIMEOUT_REG 0x000C
+#define SXGBE_CORE_HASH_TABLE_REG0	0x0010
+#define SXGBE_CORE_HASH_TABLE_REG1	0x0014
+#define SXGBE_CORE_HASH_TABLE_REG2	0x0018
+#define SXGBE_CORE_HASH_TABLE_REG3	0x001C
+#define SXGBE_CORE_HASH_TABLE_REG4	0x0020
+#define SXGBE_CORE_HASH_TABLE_REG5	0x0024
+#define SXGBE_CORE_HASH_TABLE_REG6	0x0028
+#define SXGBE_CORE_HASH_TABLE_REG7	0x002C
+/* VLAN Specific Registers */
+#define SXGBE_CORE_VLAN_TAG_REG		0x0050
+#define SXGBE_CORE_VLAN_HASHTAB_REG	0x0058
+#define SXGBE_CORE_VLAN_INSCTL_REG	0x0060
+#define SXGBE_CORE_VLAN_INNERCTL_REG	0x0064
+#define SXGBE_CORE_RX_ETHTYPE_MATCH_REG 0x006C
+
+/* Flow Contol Registers */
+#define SXGBE_CORE_TX_Q0_FLOWCTL_REG	0x0070
+#define SXGBE_CORE_TX_Q1_FLOWCTL_REG	0x0074
+#define SXGBE_CORE_TX_Q2_FLOWCTL_REG	0x0078
+#define SXGBE_CORE_TX_Q3_FLOWCTL_REG	0x007C
+#define SXGBE_CORE_TX_Q4_FLOWCTL_REG	0x0080
+#define SXGBE_CORE_TX_Q5_FLOWCTL_REG	0x0084
+#define SXGBE_CORE_TX_Q6_FLOWCTL_REG	0x0088
+#define SXGBE_CORE_TX_Q7_FLOWCTL_REG	0x008C
+#define SXGBE_CORE_RX_FLOWCTL_REG	0x0090
+#define SXGBE_CORE_RX_CTL0_REG		0x00A0
+#define SXGBE_CORE_RX_CTL1_REG		0x00A4
+#define SXGBE_CORE_RX_CTL2_REG		0x00A8
+#define SXGBE_CORE_RX_CTL3_REG		0x00AC
+
+/* Interrupt Registers */
+#define SXGBE_CORE_INT_STATUS_REG	0x00B0
+#define SXGBE_CORE_INT_ENABLE_REG	0x00B4
+#define SXGBE_CORE_RXTX_ERR_STATUS_REG	0x00B8
+#define SXGBE_CORE_PMT_CTL_STATUS_REG	0x00C0
+#define SXGBE_CORE_RWK_PKT_FILTER_REG	0x00C4
+#define SXGBE_CORE_VERSION_REG		0x0110
+#define SXGBE_CORE_DEBUG_REG		0x0114
+#define SXGBE_CORE_HW_FEA_REG(index)	(0x011C + index * 4)
+
+/* SMA(MDIO) module registers */
+#define SXGBE_MDIO_SCMD_ADD_REG		0x0200
+#define SXGBE_MDIO_SCMD_DATA_REG	0x0204
+#define SXGBE_MDIO_CCMD_WADD_REG	0x0208
+#define SXGBE_MDIO_CCMD_WDATA_REG	0x020C
+#define SXGBE_MDIO_CSCAN_PORT_REG	0x0210
+#define SXGBE_MDIO_INT_STATUS_REG	0x0214
+#define SXGBE_MDIO_INT_ENABLE_REG	0x0218
+#define SXGBE_MDIO_PORT_CONDCON_REG	0x021C
+#define SXGBE_MDIO_CLAUSE22_PORT_REG	0x0220
+
+/* port specific, addr = 0-3 */
+#define SXGBE_MDIO_DEV_BASE_REG		0x0230
+#define SXGBE_MDIO_PORT_DEV_REG(addr)			\
+	(SXGBE_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x0)
+#define SXGBE_MDIO_PORT_LSTATUS_REG(addr)		\
+	(SXGBE_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x4)
+#define SXGBE_MDIO_PORT_ALIVE_REG(addr)			\
+	(SXGBE_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x8)
+
+#define SXGBE_CORE_GPIO_CTL_REG		0x0278
+#define SXGBE_CORE_GPIO_STATUS_REG	0x027C
+
+/* Address registers for filtering */
+#define SXGBE_CORE_ADD_BASE_REG		0x0300
+
+/* addr = 0-31 */
+#define SXGBE_CORE_ADD_HIGHOFFSET(addr)			\
+	(SXGBE_CORE_ADD_BASE_REG + (0x8 * addr) + 0x0)
+#define SXGBE_CORE_ADD_LOWOFFSET(addr)			\
+	(SXGBE_CORE_ADD_BASE_REG + (0x8 * addr) + 0x4)
+
+/* SXGBE MMC registers */
+#define SXGBE_MMC_CTL_REG		0x0800
+#define SXGBE_MMC_RXINT_STATUS_REG	0x0804
+#define SXGBE_MMC_TXINT_STATUS_REG	0x0808
+#define SXGBE_MMC_RXINT_ENABLE_REG	0x080C
+#define SXGBE_MMC_TXINT_ENABLE_REG	0x0810
+
+/* TX specific counters */
+#define SXGBE_MMC_TXOCTETHI_GBCNT_REG	0x0814
+#define SXGBE_MMC_TXOCTETLO_GBCNT_REG	0x0818
+#define SXGBE_MMC_TXFRAMELO_GBCNT_REG	0x081C
+#define SXGBE_MMC_TXFRAMEHI_GBCNT_REG	0x0820
+#define SXGBE_MMC_TXBROADLO_GCNT_REG	0x0824
+#define SXGBE_MMC_TXBROADHI_GCNT_REG	0x0828
+#define SXGBE_MMC_TXMULTILO_GCNT_REG	0x082C
+#define SXGBE_MMC_TXMULTIHI_GCNT_REG	0x0830
+#define SXGBE_MMC_TX64LO_GBCNT_REG	0x0834
+#define SXGBE_MMC_TX64HI_GBCNT_REG	0x0838
+#define SXGBE_MMC_TX65TO127LO_GBCNT_REG		0x083C
+#define SXGBE_MMC_TX65TO127HI_GBCNT_REG		0x0840
+#define SXGBE_MMC_TX128TO255LO_GBCNT_REG	0x0844
+#define SXGBE_MMC_TX128TO255HI_GBCNT_REG	0x0848
+#define SXGBE_MMC_TX256TO511LO_GBCNT_REG	0x084C
+#define SXGBE_MMC_TX256TO511HI_GBCNT_REG	0x0850
+#define SXGBE_MMC_TX512TO1023LO_GBCNT_REG	0x0854
+#define SXGBE_MMC_TX512TO1023HI_GBCNT_REG	0x0858
+#define SXGBE_MMC_TX1023TOMAXLO_GBCNT_REG	0x085C
+#define SXGBE_MMC_TX1023TOMAXHI_GBCNT_REG	0x0860
+#define SXGBE_MMC_TXUNICASTLO_GBCNT_REG		0x0864
+#define SXGBE_MMC_TXUNICASTHI_GBCNT_REG		0x0868
+#define SXGBE_MMC_TXMULTILO_GBCNT_REG		0x086C
+#define SXGBE_MMC_TXMULTIHI_GBCNT_REG		0x0870
+#define SXGBE_MMC_TXBROADLO_GBCNT_REG		0x0874
+#define SXGBE_MMC_TXBROADHI_GBCNT_REG		0x0878
+#define SXGBE_MMC_TXUFLWLO_GBCNT_REG		0x087C
+#define SXGBE_MMC_TXUFLWHI_GBCNT_REG		0x0880
+#define SXGBE_MMC_TXOCTETLO_GCNT_REG	0x0884
+#define SXGBE_MMC_TXOCTETHI_GCNT_REG	0x0888
+#define SXGBE_MMC_TXFRAMELO_GCNT_REG	0x088C
+#define SXGBE_MMC_TXFRAMEHI_GCNT_REG	0x0890
+#define SXGBE_MMC_TXPAUSELO_CNT_REG	0x0894
+#define SXGBE_MMC_TXPAUSEHI_CNT_REG	0x0898
+#define SXGBE_MMC_TXVLANLO_GCNT_REG	0x089C
+#define SXGBE_MMC_TXVLANHI_GCNT_REG	0x08A0
+
+/* RX specific counters */
+#define SXGBE_MMC_RXFRAMELO_GBCNT_REG	0x0900
+#define SXGBE_MMC_RXFRAMEHI_GBCNT_REG	0x0904
+#define SXGBE_MMC_RXOCTETLO_GBCNT_REG	0x0908
+#define SXGBE_MMC_RXOCTETHI_GBCNT_REG	0x090C
+#define SXGBE_MMC_RXOCTETLO_GCNT_REG	0x0910
+#define SXGBE_MMC_RXOCTETHI_GCNT_REG	0x0914
+#define SXGBE_MMC_RXBROADLO_GCNT_REG	0x0918
+#define SXGBE_MMC_RXBROADHI_GCNT_REG	0x091C
+#define SXGBE_MMC_RXMULTILO_GCNT_REG	0x0920
+#define SXGBE_MMC_RXMULTIHI_GCNT_REG	0x0924
+#define SXGBE_MMC_RXCRCERRLO_REG	0x0928
+#define SXGBE_MMC_RXCRCERRHI_REG	0x092C
+#define SXGBE_MMC_RXSHORT64BFRAME_ERR_REG	0x0930
+#define SXGBE_MMC_RXJABBERERR_REG		0x0934
+#define SXGBE_MMC_RXSHORT64BFRAME_COR_REG	0x0938
+#define SXGBE_MMC_RXOVERMAXFRAME_COR_REG	0x093C
+#define SXGBE_MMC_RX64LO_GBCNT_REG		0x0940
+#define SXGBE_MMC_RX64HI_GBCNT_REG		0x0944
+#define SXGBE_MMC_RX65TO127LO_GBCNT_REG		0x0948
+#define SXGBE_MMC_RX65TO127HI_GBCNT_REG		0x094C
+#define SXGBE_MMC_RX128TO255LO_GBCNT_REG	0x0950
+#define SXGBE_MMC_RX128TO255HI_GBCNT_REG	0x0954
+#define SXGBE_MMC_RX256TO511LO_GBCNT_REG	0x0958
+#define SXGBE_MMC_RX256TO511HI_GBCNT_REG	0x095C
+#define SXGBE_MMC_RX512TO1023LO_GBCNT_REG	0x0960
+#define SXGBE_MMC_RX512TO1023HI_GBCNT_REG	0x0964
+#define SXGBE_MMC_RX1023TOMAXLO_GBCNT_REG	0x0968
+#define SXGBE_MMC_RX1023TOMAXHI_GBCNT_REG	0x096C
+#define SXGBE_MMC_RXUNICASTLO_GCNT_REG		0x0970
+#define SXGBE_MMC_RXUNICASTHI_GCNT_REG		0x0974
+#define SXGBE_MMC_RXLENERRLO_REG		0x0978
+#define SXGBE_MMC_RXLENERRHI_REG		0x097C
+#define SXGBE_MMC_RXOUTOFRANGETYPELO_REG	0x0980
+#define SXGBE_MMC_RXOUTOFRANGETYPEHI_REG	0x0984
+#define SXGBE_MMC_RXPAUSELO_CNT_REG		0x0988
+#define SXGBE_MMC_RXPAUSEHI_CNT_REG		0x098C
+#define SXGBE_MMC_RXFIFOOVERFLOWLO_GBCNT_REG	0x0990
+#define SXGBE_MMC_RXFIFOOVERFLOWHI_GBCNT_REG	0x0994
+#define SXGBE_MMC_RXVLANLO_GBCNT_REG		0x0998
+#define SXGBE_MMC_RXVLANHI_GBCNT_REG		0x099C
+#define SXGBE_MMC_RXWATCHDOG_ERR_REG		0x09A0
+
+/* L3/L4 function registers */
+#define SXGBE_CORE_L34_ADDCTL_REG	0x0C00
+#define SXGBE_CORE_L34_ADDCTL_REG	0x0C00
+#define SXGBE_CORE_L34_DATA_REG		0x0C04
+
+/* ARP registers */
+#define SXGBE_CORE_ARP_ADD_REG		0x0C10
+
+/* RSS registers */
+#define SXGBE_CORE_RSS_CTL_REG		0x0C80
+#define SXGBE_CORE_RSS_ADD_REG		0x0C88
+#define SXGBE_CORE_RSS_DATA_REG		0x0C8C
+
+/* IEEE 1588 registers */
+#define SXGBE_CORE_TSTAMP_CTL_REG	0x0D00
+#define SXGBE_CORE_SUBSEC_INC_REG	0x0D04
+#define SXGBE_CORE_SYSTIME_SEC_REG	0x0D0C
+#define SXGBE_CORE_SYSTIME_NSEC_REG	0x0D10
+#define SXGBE_CORE_SYSTIME_SECUP_REG	0x0D14
+#define SXGBE_CORE_TSTAMP_ADD_REG	0x0D18
+#define SXGBE_CORE_SYSTIME_HWORD_REG	0x0D1C
+#define SXGBE_CORE_TSTAMP_STATUS_REG	0x0D20
+#define SXGBE_CORE_TXTIME_STATUSNSEC_REG 0x0D30
+#define SXGBE_CORE_TXTIME_STATUSSEC_REG	0x0D34
+
+/* Auxiliary registers */
+#define SXGBE_CORE_AUX_CTL_REG			 0x0D40
+#define SXGBE_CORE_AUX_TSTAMP_NSEC_REG		 0x0D48
+#define SXGBE_CORE_AUX_TSTAMP_SEC_REG		 0x0D4C
+#define SXGBE_CORE_AUX_TSTAMP_INGCOR_REG	 0x0D50
+#define SXGBE_CORE_AUX_TSTAMP_ENGCOR_REG	 0x0D54
+#define SXGBE_CORE_AUX_TSTAMP_INGCOR_NSEC_REG	 0x0D58
+#define SXGBE_CORE_AUX_TSTAMP_INGCOR_SUBNSEC_REG 0x0D5C
+#define SXGBE_CORE_AUX_TSTAMP_ENGCOR_NSEC_REG	 0x0D60
+#define SXGBE_CORE_AUX_TSTAMP_ENGCOR_SUBNSEC_REG 0x0D64
+
+/* PPS registers */
+#define SXGBE_CORE_PPS_CTL_REG		0x0D70
+#define SXGBE_CORE_PPS_BASE			0x0D80
+
+/* addr = 0 - 3 */
+#define SXGBE_CORE_PPS_TTIME_SEC_REG(addr)		\
+	(SXGBE_CORE_PPS_BASE + (0x10 * addr) + 0x0)
+#define SXGBE_CORE_PPS_TTIME_NSEC_REG(addr)		\
+	(SXGBE_CORE_PPS_BASE + (0x10 * addr) + 0x4)
+#define SXGBE_CORE_PPS_INTERVAL_REG(addr)		\
+	(SXGBE_CORE_PPS_BASE + (0x10 * addr) + 0x8)
+#define SXGBE_CORE_PPS_WIDTH_REG(addr)			\
+	(SXGBE_CORE_PPS_BASE + (0x10 * addr) + 0xC)
+#define SXGBE_CORE_PTO_CTL_REG		0x0DC0
+#define SXGBE_CORE_SRCPORT_ITY0_REG	0x0DC4
+#define SXGBE_CORE_SRCPORT_ITY1_REG	0x0DC8
+#define SXGBE_CORE_SRCPORT_ITY2_REG	0x0DCC
+#define SXGBE_CORE_LOGMSG_LEVEL_REG	0x0DD0
+
+/* SXGBE MTL Registers */
+#define SXGBE_MTL_BASE_REG		0x1000
+#define SXGBE_MTL_OP_MODE_REG		(SXGBE_MTL_BASE_REG + 0x0000)
+#define SXGBE_MTL_DEBUG_CTL_REG		(SXGBE_MTL_BASE_REG + 0x0008)
+#define SXGBE_MTL_DEBUG_STATUS_REG	(SXGBE_MTL_BASE_REG + 0x000C)
+#define SXGBE_MTL_FIFO_DEBUGDATA_REG	(SXGBE_MTL_BASE_REG + 0x0010)
+#define SXGBE_MTL_INT_STATUS_REG	(SXGBE_MTL_BASE_REG + 0x0020)
+#define SXGBE_MTL_RXQ_DMAMAP0_REG	(SXGBE_MTL_BASE_REG + 0x0030)
+#define SXGBE_MTL_RXQ_DMAMAP1_REG	(SXGBE_MTL_BASE_REG + 0x0034)
+#define SXGBE_MTL_RXQ_DMAMAP2_REG	(SXGBE_MTL_BASE_REG + 0x0038)
+#define SXGBE_MTL_TX_PRTYMAP0_REG	(SXGBE_MTL_BASE_REG + 0x0040)
+#define SXGBE_MTL_TX_PRTYMAP1_REG	(SXGBE_MTL_BASE_REG + 0x0044)
+
+/* TC/Queue registers, qnum=0-15 */
+#define SXGBE_MTL_TC_TXBASE_REG		(SXGBE_MTL_BASE_REG + 0x0100)
+#define SXGBE_MTL_TXQ_OPMODE_REG(qnum)				\
+	(SXGBE_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x00)
+#define SXGBE_MTL_SFMODE		BIT(1)
+#define SXGBE_MTL_FIFO_LSHIFT		16
+#define SXGBE_MTL_ENABLE_QUEUE		0x00000008
+#define SXGBE_MTL_TXQ_UNDERFLOW_REG(qnum)			\
+	(SXGBE_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x04)
+#define SXGBE_MTL_TXQ_DEBUG_REG(qnum)				\
+	(SXGBE_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x08)
+#define SXGBE_MTL_TXQ_ETSCTL_REG(qnum)				\
+	(SXGBE_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x10)
+#define SXGBE_MTL_TXQ_ETSSTATUS_REG(qnum)			\
+	(SXGBE_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x14)
+#define SXGBE_MTL_TXQ_QUANTWEIGHT_REG(qnum)			\
+	(SXGBE_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x18)
+
+#define SXGBE_MTL_TC_RXBASE_REG		0x1140
+#define SXGBE_RX_MTL_SFMODE		BIT(5)
+#define SXGBE_MTL_RXQ_OPMODE_REG(qnum)				\
+	(SXGBE_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x00)
+#define SXGBE_MTL_RXQ_MISPKTOVERFLOW_REG(qnum)			\
+	(SXGBE_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x04)
+#define SXGBE_MTL_RXQ_DEBUG_REG(qnum)				\
+	(SXGBE_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x08)
+#define SXGBE_MTL_RXQ_CTL_REG(qnum)				\
+	(SXGBE_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x0C)
+#define SXGBE_MTL_RXQ_INTENABLE_REG(qnum)			\
+	(SXGBE_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x30)
+#define SXGBE_MTL_RXQ_INTSTATUS_REG(qnum)			\
+	(SXGBE_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x34)
+
+/* SXGBE DMA Registers */
+#define SXGBE_DMA_BASE_REG		0x3000
+#define SXGBE_DMA_MODE_REG		(SXGBE_DMA_BASE_REG + 0x0000)
+#define SXGBE_DMA_SOFT_RESET		BIT(0)
+#define SXGBE_DMA_SYSBUS_MODE_REG	(SXGBE_DMA_BASE_REG + 0x0004)
+#define SXGBE_DMA_AXI_UNDEF_BURST	BIT(0)
+#define SXGBE_DMA_ENHACE_ADDR_MODE	BIT(11)
+#define SXGBE_DMA_INT_STATUS_REG	(SXGBE_DMA_BASE_REG + 0x0008)
+#define SXGBE_DMA_AXI_ARCACHECTL_REG	(SXGBE_DMA_BASE_REG + 0x0010)
+#define SXGBE_DMA_AXI_AWCACHECTL_REG	(SXGBE_DMA_BASE_REG + 0x0018)
+#define SXGBE_DMA_DEBUG_STATUS0_REG	(SXGBE_DMA_BASE_REG + 0x0020)
+#define SXGBE_DMA_DEBUG_STATUS1_REG	(SXGBE_DMA_BASE_REG + 0x0024)
+#define SXGBE_DMA_DEBUG_STATUS2_REG	(SXGBE_DMA_BASE_REG + 0x0028)
+#define SXGBE_DMA_DEBUG_STATUS3_REG	(SXGBE_DMA_BASE_REG + 0x002C)
+#define SXGBE_DMA_DEBUG_STATUS4_REG	(SXGBE_DMA_BASE_REG + 0x0030)
+#define SXGBE_DMA_DEBUG_STATUS5_REG	(SXGBE_DMA_BASE_REG + 0x0034)
+
+/* Channel Registers, cha_num = 0-15 */
+#define SXGBE_DMA_CHA_BASE_REG			\
+	(SXGBE_DMA_BASE_REG + 0x0100)
+#define SXGBE_DMA_CHA_CTL_REG(cha_num)				\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x00)
+#define SXGBE_DMA_PBL_X8MODE			BIT(16)
+#define SXGBE_DMA_CHA_TXCTL_TSE_ENABLE		BIT(12)
+#define SXGBE_DMA_CHA_TXCTL_REG(cha_num)			\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x04)
+#define SXGBE_DMA_CHA_RXCTL_REG(cha_num)			\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x08)
+#define SXGBE_DMA_CHA_TXDESC_HADD_REG(cha_num)			\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x10)
+#define SXGBE_DMA_CHA_TXDESC_LADD_REG(cha_num)			\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x14)
+#define SXGBE_DMA_CHA_RXDESC_HADD_REG(cha_num)			\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x18)
+#define SXGBE_DMA_CHA_RXDESC_LADD_REG(cha_num)			\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x1C)
+#define SXGBE_DMA_CHA_TXDESC_TAILPTR_REG(cha_num)		\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x24)
+#define SXGBE_DMA_CHA_RXDESC_TAILPTR_REG(cha_num)		\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x2C)
+#define SXGBE_DMA_CHA_TXDESC_RINGLEN_REG(cha_num)		\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x30)
+#define SXGBE_DMA_CHA_RXDESC_RINGLEN_REG(cha_num)		\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x34)
+#define SXGBE_DMA_CHA_INT_ENABLE_REG(cha_num)			\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x38)
+#define SXGBE_DMA_CHA_INT_RXWATCHTMR_REG(cha_num)		\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x3C)
+#define SXGBE_DMA_CHA_TXDESC_CURADDLO_REG(cha_num)		\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x44)
+#define SXGBE_DMA_CHA_RXDESC_CURADDLO_REG(cha_num)		\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x4C)
+#define SXGBE_DMA_CHA_CURTXBUF_ADDHI_REG(cha_num)		\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x50)
+#define SXGBE_DMA_CHA_CURTXBUF_ADDLO_REG(cha_num)		\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x54)
+#define SXGBE_DMA_CHA_CURRXBUF_ADDHI_REG(cha_num)		\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x58)
+#define SXGBE_DMA_CHA_CURRXBUF_ADDLO_REG(cha_num)		\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x5C)
+#define SXGBE_DMA_CHA_STATUS_REG(cha_num)			\
+	(SXGBE_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x60)
+
+/* TX DMA control register specific */
+#define SXGBE_TX_START_DMA	BIT(0)
+
+/* sxgbe tx configuration register bitfields */
+#define SXGBE_SPEED_10G		0x0
+#define SXGBE_SPEED_2_5G	0x1
+#define SXGBE_SPEED_1G		0x2
+#define SXGBE_SPEED_LSHIFT	29
+
+#define SXGBE_TX_ENABLE		BIT(0)
+#define SXGBE_TX_DISDIC_ALGO	BIT(1)
+#define SXGBE_TX_JABBER_DISABLE	BIT(16)
+
+/* sxgbe rx configuration register bitfields */
+#define SXGBE_RX_ENABLE		BIT(0)
+#define SXGBE_RX_ACS_ENABLE		BIT(1)
+#define SXGBE_RX_WATCHDOG_DISABLE	BIT(7)
+#define SXGBE_RX_JUMBPKT_ENABLE		BIT(8)
+#define SXGBE_RX_CSUMOFFLOAD_ENABLE	BIT(9)
+#define SXGBE_RX_LOOPBACK_ENABLE	BIT(10)
+#define SXGBE_RX_ARPOFFLOAD_ENABLE	BIT(31)
+
+/* sxgbe vlan Tag Register bitfields */
+#define SXGBE_VLAN_SVLAN_ENABLE		BIT(18)
+#define SXGBE_VLAN_DOUBLEVLAN_ENABLE	BIT(26)
+#define SXGBE_VLAN_INNERVLAN_ENABLE	BIT(27)
+
+/* XMAC VLAN Tag Inclusion Register(0x0060) bitfields
+ * Below fields same for  Inner VLAN Tag Inclusion
+ * Register(0x0064) register
+ */
+enum vlan_tag_ctl_tx {
+	VLAN_TAG_TX_NOP,
+	VLAN_TAG_TX_DEL,
+	VLAN_TAG_TX_INSERT,
+	VLAN_TAG_TX_REPLACE
+};
+#define SXGBE_VLAN_PRTY_CTL	BIT(18)
+#define SXGBE_VLAN_CSVL_CTL	BIT(19)
+
+/* SXGBE TX Q Flow Control Register bitfields */
+#define SXGBE_TX_FLOW_CTL_FCB	BIT(0)
+#define SXGBE_TX_FLOW_CTL_TFB	BIT(1)
+
+/* SXGBE RX Q Flow Control Register bitfields */
+#define SXGBE_RX_FLOW_CTL_ENABLE	BIT(0)
+#define SXGBE_RX_UNICAST_DETECT		BIT(1)
+#define SXGBE_RX_PRTYFLOW_CTL_ENABLE	BIT(8)
+
+/* sxgbe rx Q control0 register bitfields */
+#define SXGBE_RX_Q_ENABLE	0x2
+
+/* SXGBE hardware features bitfield specific */
+/* Capability Register 0 */
+#define SXGBE_HW_FEAT_GMII(cap)			((cap & 0x00000002) >> 1)
+#define SXGBE_HW_FEAT_VLAN_HASH_FILTER(cap)	((cap & 0x00000010) >> 4)
+#define SXGBE_HW_FEAT_SMA(cap)			((cap & 0x00000020) >> 5)
+#define SXGBE_HW_FEAT_PMT_TEMOTE_WOP(cap)	((cap & 0x00000040) >> 6)
+#define SXGBE_HW_FEAT_PMT_MAGIC_PKT(cap)	((cap & 0x00000080) >> 7)
+#define SXGBE_HW_FEAT_RMON(cap)			((cap & 0x00000100) >> 8)
+#define SXGBE_HW_FEAT_ARP_OFFLOAD(cap)		((cap & 0x00000200) >> 9)
+#define SXGBE_HW_FEAT_IEEE1500_2008(cap)	((cap & 0x00001000) >> 12)
+#define SXGBE_HW_FEAT_EEE(cap)			((cap & 0x00002000) >> 13)
+#define SXGBE_HW_FEAT_TX_CSUM_OFFLOAD(cap)	((cap & 0x00004000) >> 14)
+#define SXGBE_HW_FEAT_RX_CSUM_OFFLOAD(cap)	((cap & 0x00010000) >> 16)
+#define SXGBE_HW_FEAT_MACADDR_COUNT(cap)	((cap & 0x007C0000) >> 18)
+#define SXGBE_HW_FEAT_TSTMAP_SRC(cap)		((cap & 0x06000000) >> 25)
+#define SXGBE_HW_FEAT_SRCADDR_VLAN(cap)		((cap & 0x08000000) >> 27)
+
+/* Capability Register 1 */
+#define SXGBE_HW_FEAT_RX_FIFO_SIZE(cap)		((cap & 0x0000001F))
+#define SXGBE_HW_FEAT_TX_FIFO_SIZE(cap)		((cap & 0x000007C0) >> 6)
+#define SXGBE_HW_FEAT_IEEE1588_HWORD(cap)	((cap & 0x00002000) >> 13)
+#define SXGBE_HW_FEAT_DCB(cap)			((cap & 0x00010000) >> 16)
+#define SXGBE_HW_FEAT_SPLIT_HDR(cap)		((cap & 0x00020000) >> 17)
+#define SXGBE_HW_FEAT_TSO(cap)			((cap & 0x00040000) >> 18)
+#define SXGBE_HW_FEAT_DEBUG_MEM_IFACE(cap)	((cap & 0x00080000) >> 19)
+#define SXGBE_HW_FEAT_RSS(cap)			((cap & 0x00100000) >> 20)
+#define SXGBE_HW_FEAT_HASH_TABLE_SIZE(cap)	((cap & 0x03000000) >> 24)
+#define SXGBE_HW_FEAT_L3L4_FILTER_NUM(cap)	((cap & 0x78000000) >> 27)
+
+/* Capability Register 2 */
+#define SXGBE_HW_FEAT_RX_MTL_QUEUES(cap)	((cap & 0x0000000F))
+#define SXGBE_HW_FEAT_TX_MTL_QUEUES(cap)	((cap & 0x000003C0) >> 6)
+#define SXGBE_HW_FEAT_RX_DMA_CHANNELS(cap)	((cap & 0x0000F000) >> 12)
+#define SXGBE_HW_FEAT_TX_DMA_CHANNELS(cap)	((cap & 0x003C0000) >> 18)
+#define SXGBE_HW_FEAT_PPS_OUTPUTS(cap)		((cap & 0x07000000) >> 24)
+#define SXGBE_HW_FEAT_AUX_SNAPSHOTS(cap)	((cap & 0x70000000) >> 28)
+
+/* DMAchannel interrupt enable specific */
+/* DMA Normal interrupt */
+#define SXGBE_DMA_INT_ENA_NIE	BIT(16)	/* Normal Summary */
+#define SXGBE_DMA_INT_ENA_TIE	BIT(0)	/* Transmit Interrupt */
+#define SXGBE_DMA_INT_ENA_TUE	BIT(2)	/* Transmit Buffer Unavailable */
+#define SXGBE_DMA_INT_ENA_RIE	BIT(6)	/* Receive Interrupt */
+
+#define SXGBE_DMA_INT_NORMAL					\
+	(SXGBE_DMA_INT_ENA_NIE | SXGBE_DMA_INT_ENA_RIE |	\
+	 SXGBE_DMA_INT_ENA_TIE | SXGBE_DMA_INT_ENA_TUE)
+
+/* DMA Abnormal interrupt */
+#define SXGBE_DMA_INT_ENA_AIE	BIT(15)	/* Abnormal Summary */
+#define SXGBE_DMA_INT_ENA_TSE	BIT(1)	/* Transmit Stopped */
+#define SXGBE_DMA_INT_ENA_RUE	BIT(7)	/* Receive Buffer Unavailable */
+#define SXGBE_DMA_INT_ENA_RSE	BIT(8)	/* Receive Stopped */
+#define SXGBE_DMA_INT_ENA_FBE	BIT(12)	/* Fatal Bus Error */
+#define SXGBE_DMA_INT_ENA_CDEE	BIT(13)	/* Context Descriptor Error */
+
+#define SXGBE_DMA_INT_ABNORMAL					\
+	(SXGBE_DMA_INT_ENA_AIE | SXGBE_DMA_INT_ENA_TSE |	\
+	 SXGBE_DMA_INT_ENA_RUE | SXGBE_DMA_INT_ENA_RSE |	\
+	 SXGBE_DMA_INT_ENA_FBE | SXGBE_DMA_INT_ENA_CDEE)
+
+#define SXGBE_DMA_ENA_INT	(SXGBE_DMA_INT_NORMAL | SXGBE_DMA_INT_ABNORMAL)
+
+/* DMA channel interrupt status specific */
+#define	SXGBE_DMA_INT_STATUS_REB2	BIT(21)
+#define	SXGBE_DMA_INT_STATUS_REB1	BIT(20)
+#define	SXGBE_DMA_INT_STATUS_REB0	BIT(19)
+#define	SXGBE_DMA_INT_STATUS_TEB2	BIT(18)
+#define	SXGBE_DMA_INT_STATUS_TEB1	BIT(17)
+#define	SXGBE_DMA_INT_STATUS_TEB0	BIT(16)
+#define	SXGBE_DMA_INT_STATUS_NIS	BIT(15)
+#define SXGBE_DMA_INT_STATUS_AIS	BIT(14)
+#define SXGBE_DMA_INT_STATUS_CTXTERR	BIT(13)
+#define SXGBE_DMA_INT_STATUS_FBE	BIT(12)
+#define SXGBE_DMA_INT_STATUS_RPS	BIT(8)
+#define SXGBE_DMA_INT_STATUS_RBU	BIT(7)
+#define SXGBE_DMA_INT_STATUS_RI		BIT(6)
+#define SXGBE_DMA_INT_STATUS_TBU	BIT(2)
+#define SXGBE_DMA_INT_STATUS_TPS	BIT(1)
+#define SXGBE_DMA_INT_STATUS_TI		BIT(0)
+
+#endif /* __SXGBE_REGMAP_H__ */
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c
new file mode 100644
index 0000000..51c3219
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.c
@@ -0,0 +1,91 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/bitops.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include "sxgbe_common.h"
+#include "sxgbe_xpcs.h"
+
+static int sxgbe_xpcs_read(struct net_device *ndev, unsigned int reg)
+{
+	u32 value;
+	struct sxgbe_priv_data *priv = netdev_priv(ndev);
+
+	value = readl(priv->ioaddr + XPCS_OFFSET + reg);
+
+	return value;
+}
+
+static int sxgbe_xpcs_write(struct net_device *ndev, int reg, int data)
+{
+	struct sxgbe_priv_data *priv = netdev_priv(ndev);
+
+	writel(data, priv->ioaddr + XPCS_OFFSET + reg);
+
+	return 0;
+}
+
+int sxgbe_xpcs_init(struct net_device *ndev)
+{
+	u32 value;
+
+	value = sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
+	/* 10G XAUI mode */
+	sxgbe_xpcs_write(ndev, SR_PCS_CONTROL2, XPCS_TYPE_SEL_X);
+	sxgbe_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, XPCS_XAUI_MODE);
+	sxgbe_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, value | BIT(13));
+	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value | BIT(11));
+
+	do {
+		value = sxgbe_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
+	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) == XPCS_QSEQ_STATE_STABLE);
+
+	value = sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
+	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(11));
+
+	do {
+		value = sxgbe_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
+	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) != XPCS_QSEQ_STATE_STABLE);
+
+	return 0;
+}
+
+int sxgbe_xpcs_init_1G(struct net_device *ndev)
+{
+	int value;
+
+	/* 10GBASE-X PCS (1G) mode */
+	sxgbe_xpcs_write(ndev, SR_PCS_CONTROL2, XPCS_TYPE_SEL_X);
+	sxgbe_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, XPCS_XAUI_MODE);
+	value = sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
+	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(13));
+
+	value = sxgbe_xpcs_read(ndev, SR_MII_MMD_CONTROL);
+	sxgbe_xpcs_write(ndev, SR_MII_MMD_CONTROL, value | BIT(6));
+	sxgbe_xpcs_write(ndev, SR_MII_MMD_CONTROL, value & ~BIT(13));
+	value = sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
+	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value | BIT(11));
+
+	do {
+		value = sxgbe_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
+	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) != XPCS_QSEQ_STATE_STABLE);
+
+	value = sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
+	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(11));
+
+	/* Auto Negotiation cluase 37 enable */
+	value = sxgbe_xpcs_read(ndev, SR_MII_MMD_CONTROL);
+	sxgbe_xpcs_write(ndev, SR_MII_MMD_CONTROL, value | BIT(12));
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h
new file mode 100644
index 0000000..6b26a50
--- /dev/null
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_xpcs.h
@@ -0,0 +1,38 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Byungho An <bh74.an@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __SXGBE_XPCS_H__
+#define __SXGBE_XPCS_H__
+
+/* XPCS Registers */
+#define XPCS_OFFSET			0x1A060000
+#define SR_PCS_MMD_CONTROL1		0x030000
+#define SR_PCS_CONTROL2			0x030007
+#define VR_PCS_MMD_XAUI_MODE_CONTROL	0x038004
+#define VR_PCS_MMD_DIGITAL_STATUS	0x038010
+#define SR_MII_MMD_CONTROL		0x1F0000
+#define SR_MII_MMD_AN_ADV		0x1F0004
+#define SR_MII_MMD_AN_LINK_PARTNER_BA	0x1F0005
+#define VR_MII_MMD_AN_CONTROL		0x1F8001
+#define VR_MII_MMD_AN_INT_STATUS	0x1F8002
+
+#define XPCS_QSEQ_STATE_STABLE		0x10
+#define XPCS_QSEQ_STATE_MPLLOFF		0x1c
+#define XPCS_TYPE_SEL_R			0x00
+#define XPCS_TYPE_SEL_X			0x01
+#define XPCS_TYPE_SEL_W			0x02
+#define XPCS_XAUI_MODE			0x00
+#define XPCS_RXAUI_MODE			0x01
+
+int sxgbe_xpcs_init(struct net_device *ndev);
+int sxgbe_xpcs_init_1G(struct net_device *ndev);
+
+#endif /* __SXGBE_XPCS_H__ */
diff --git a/include/linux/sxgbe_platform.h b/include/linux/sxgbe_platform.h
new file mode 100644
index 0000000..a62442c
--- /dev/null
+++ b/include/linux/sxgbe_platform.h
@@ -0,0 +1,54 @@
+/*
+ * 10G controller driver for Samsung EXYNOS SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __SXGBE_PLATFORM_H__
+#define __SXGBE_PLATFORM_H__
+
+/* MDC Clock Selection define*/
+#define SXGBE_CSR_100_150M	0x0	/* MDC = clk_scr_i/62 */
+#define SXGBE_CSR_150_250M	0x1	/* MDC = clk_scr_i/102 */
+#define SXGBE_CSR_250_300M	0x2	/* MDC = clk_scr_i/122 */
+#define SXGBE_CSR_300_350M	0x3	/* MDC = clk_scr_i/142 */
+#define SXGBE_CSR_350_400M	0x4	/* MDC = clk_scr_i/162 */
+#define SXGBE_CSR_400_500M	0x5	/* MDC = clk_scr_i/202 */
+
+/* Platfrom data for platform device structure's
+ * platform_data field
+ */
+struct sxgbe_mdio_bus_data {
+	unsigned int phy_mask;
+	int *irqs;
+	int probed_phy_irq;
+};
+
+struct sxgbe_dma_cfg {
+	int pbl;
+	int fixed_burst;
+	int burst_map;
+	int adv_addr_mode;
+};
+
+struct sxgbe_plat_data {
+	char *phy_bus_name;
+	int bus_id;
+	int phy_addr;
+	int interface;
+	struct sxgbe_mdio_bus_data *mdio_bus_data;
+	struct sxgbe_dma_cfg *dma_cfg;
+	int clk_csr;
+	int pmt;
+	int force_sf_dma_mode;
+	int force_thresh_dma_mode;
+	int riwt_off;
+};
+
+#endif /* __SXGBE_PLATFORM_H__ */
-- 
1.7.10.4
