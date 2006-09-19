From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.18-rc7 6/9] NetXen: Main header file
Date: Tue, 19 Sep 2006 08:28:21 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609190826450.25990@dut39>
References: <Pine.LNX.4.64.0609151124560.7710@dut39> <Pine.LNX.4.64.0609151148580.7710@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, unmproj@linsyssoft.com,
	brazilnut@us.ibm.com, wendyx@us.ibm.com,
	"Amit S. Kale" <amitkale@netxen.com>,
	Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:36978 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1750730AbWISP23
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 11:28:29 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0609151148580.7710@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.18-rc7/drivers/net/netxen/netxen_nic.h linux-2.6.18-rc7/drivers/net/netxen/netxen_nic.h
--- linux-2.6.18-rc7/drivers/net/netxen/netxen_nic.h	2006-09-15 10:51:59.000000000 -0700
+++ linux-2.6.18-rc7/drivers/net/netxen/netxen_nic.h	2006-09-19 07:51:20.000000000 -0700
@@ -62,8 +62,6 @@
  #include <asm/uaccess.h>
  #include <asm/pgtable.h>

-#include <linux/skbuff.h>
-
  #include "netxen_nic_hw.h"

  #define NETXEN_NIC_BUILD_NO     "232"
@@ -74,9 +72,9 @@
  #define NETXEN_NIC_FW_VERSIONID "2.3.57"

  #define RCV_DESC_RINGSIZE	\
-	(sizeof(struct rcv_desc_t) * adapter->max_rx_desc_count)
+	(sizeof(struct rcv_desc) * adapter->max_rx_desc_count)
  #define STATUS_DESC_RINGSIZE	\
-	(sizeof(struct status_desc_t)* adapter->max_rx_desc_count)
+	(sizeof(struct status_desc)* adapter->max_rx_desc_count)
  #define TX_RINGSIZE	\
  	(sizeof(struct netxen_cmd_buffer) * adapter->max_tx_desc_count)
  #define RCV_BUFFSIZE	\
@@ -158,7 +156,7 @@
  #define MAX_RCV_DESC		MAX_RCV_DESCRIPTORS
  #define MAX_RCVSTATUS_DESC	MAX_RCV_DESCRIPTORS
  #define NUM_RCV_DESC		(MAX_RCV_DESC + MAX_JUMBO_RCV_DESCRIPTORS)
-#define MAX_EPG_DESCRIPTORS	MAX_CMD_DESCRIPTORS * 8
+#define MAX_EPG_DESCRIPTORS	(MAX_CMD_DESCRIPTORS * 8)

  #define MIN_TX_COUNT	4096
  #define MIN_RX_COUNT	4096
@@ -174,16 +172,16 @@
  #define get_index_range(index,length,count)	\
  	(((index) + (count)) & ((length) - 1))

-/**
+/*
   * Following data structures describe the descriptors that will be used.
   * Added fileds of tcpHdrSize and ipHdrSize, The driver needs to do it only when
   * we are doing LSO (above the 1500 size packet) only.
- **/
+ */

-/**
+/*
   * The size of reference handle been changed to 16 bits to pass the MSS fields
   * for the LSO packet
- **/
+ */

  #define FLAGS_CHECKSUM_ENABLED	0x01
  #define FLAGS_LSO_ENABLED	0x02
@@ -205,7 +203,7 @@
  #define CMD_DESC_PORT_WRT(cmd_desc, var)	\
  		((cmd_desc)->port_ctxid |= ((var) & 0x0F))

-struct cmd_desc_type0_t {
+struct cmd_desc_type0 {
  	u64 netxen_next;	/* for fragments handled by Phantom */
  	union {
  		struct {
@@ -261,22 +259,22 @@
  } __attribute__ ((aligned(64)));

  /* Note: sizeof(rcv_desc) should always be a mutliple of 2 */
-struct rcv_desc_t {
+struct rcv_desc {
  	u16 reference_handle;
  	u16 reserved;
  	u32 buffer_length;	/* allocated buffer length (usually 2K) */
  	u64 addr_buffer;
  };

-/* opcode field in status_desc_t */
+/* opcode field in status_desc */
  #define RCV_NIC_PKT	(0xA)
  #define STATUS_NIC_PKT	((RCV_NIC_PKT) << 12)

-/* for status field in status_desc_t */
+/* for status field in status_desc */
  #define STATUS_NEED_CKSUM	(1)
  #define STATUS_CKSUM_OK		(2)

-/* owner bits of status_desc_t */
+/* owner bits of status_desc */
  #define STATUS_OWNER_HOST	(0x1)
  #define STATUS_OWNER_PHANTOM	(0x2)

@@ -293,7 +291,7 @@
  #define STATUS_DESC_OPCODE(status_desc)	\
  		(((status_desc)->port_status_type_op >> 12) & 0x0F)

-struct status_desc_t {
+struct status_desc {
  	/* Bit pattern: 0-3 port, 4-7 status, 8-11 type, 12-15 opcode */
  	u16 port_status_type_op;
  	u16 total_length;	/* NIC mode */
@@ -625,7 +623,7 @@
  	struct netxen_board_info boardcfg;
  	u32 xg_linkup;
  	/* Address of cmd ring in Phantom */
-	struct cmd_desc_type0_t *cmd_desc_head;
+	struct cmd_desc_type0 *cmd_desc_head;
  	dma_addr_t cmd_desc_phys_addr;
  	struct netxen_adapter *adapter;
  };
@@ -657,7 +655,7 @@
  	u32 rcv_pending;	/* Num of bufs posted in phantom */
  	u32 rcv_free;		/* Num of bufs in free list */
  	dma_addr_t phys_addr;
-	struct rcv_desc_t *desc_head;	/* address of rx ring in Phantom */
+	struct rcv_desc *desc_head;	/* address of rx ring in Phantom */
  	u32 max_rx_desc_count;
  	u32 dma_size;
  	u32 skb_size;
@@ -676,14 +674,13 @@
  	u32 status_rx_producer;
  	u32 status_rx_consumer;
  	dma_addr_t rcv_status_desc_phys_addr;
-	struct status_desc_t *rcv_status_desc_head;
+	struct status_desc *rcv_status_desc_head;
  };

  #define NETXEN_NIC_MSI_ENABLED 0x02

  struct netxen_drvops;

-/* this structure by all ports on the adapter */
  struct netxen_adapter {
  	struct netxen_hardware_context ahw;
  	int port_count;		/* Number of configured ports  */
@@ -776,10 +773,10 @@
  	void (*handle_phy_intr) (struct netxen_adapter *);
  	int (*macaddr_set) (struct netxen_port *, netxen_ethernet_macaddr_t);
  	int (*set_mtu) (struct netxen_port *, int);
-	int (*set_promisc_mode) (struct netxen_adapter *, int,
-				 netxen_niu_prom_mode_t);
-	int (*unset_promisc_mode) (struct netxen_adapter *, int,
-				   netxen_niu_prom_mode_t);
+	int (*set_promisc) (struct netxen_adapter *, int,
+			    netxen_niu_prom_mode_t);
+	int (*unset_promisc) (struct netxen_adapter *, int,
+			      netxen_niu_prom_mode_t);
  	int (*phy_read) (struct netxen_adapter *, long phy, long reg, u32 *);
  	int (*phy_write) (struct netxen_adapter *, long phy, long reg, u32 val);
  	int (*init_port) (struct netxen_adapter *, int);
@@ -850,7 +847,7 @@
  int netxen_init_firmware(struct netxen_adapter *adapter);
  void netxen_free_hw_resources(struct netxen_adapter *adapter);
  void netxen_tso_check(struct netxen_adapter *adapter,
-		      struct cmd_desc_type0_t *desc, struct sk_buff *skb);
+		      struct cmd_desc_type0 *desc, struct sk_buff *skb);
  int netxen_nic_hw_resources(struct netxen_adapter *adapter);
  void netxen_nic_clear_stats(struct netxen_adapter *adapter);
  int
