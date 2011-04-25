From: dykmanj@linux.vnet.ibm.com
Subject: [PATCH v4 23/27] HFI: Define packet header formats and window register offsets
Date: Mon, 25 Apr 2011 17:24:03 -0400
Message-ID: <1303766647-30156-24-git-send-email-dykmanj@linux.vnet.ibm.com>
References: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Cc: Jim Dykman <dykmanj@linux.vnet.ibm.com>,
	Piyush Chaudhary <piyushc@linux.vnet.ibm.com>,
	Fu-Chung Chang <fcchang@linux.vnet.ibm.com>,
	" William S. Cadden" <wscadden@linux.vnet.ibm.com>,
	" Wen C. Chen" <winstonc@linux.vnet.ibm.com>,
	Scot Sakolish <sakolish@linux.vnet.ibm.com>,
	Jian Xiao <jian@linux.vnet.ibm.com>,
	" Carol L. Soto" <clsoto@linux.vnet.ibm.com>,
	" Sarah J. Sheppard" <sjsheppa@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:49143 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932127Ab1DYVYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 17:24:32 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PLLjs0010478
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:21:45 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p3PLOVDA145228
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:31 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PLOVjp000877
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 15:24:31 -0600
In-Reply-To: <1303766647-30156-1-git-send-email-dykmanj@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jim Dykman <dykmanj@linux.vnet.ibm.com>

Signed-off-by:  Piyush Chaudhary <piyushc@linux.vnet.ibm.com>
Signed-off-by:  Jim Dykman <dykmanj@linux.vnet.ibm.com>
Signed-off-by:  Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
Signed-off-by:  William S. Cadden <wscadden@linux.vnet.ibm.com>
Signed-off-by:  Wen C. Chen <winstonc@linux.vnet.ibm.com>
Signed-off-by:  Scot Sakolish <sakolish@linux.vnet.ibm.com>
Signed-off-by:  Jian Xiao <jian@linux.vnet.ibm.com>
Signed-off-by:  Carol L. Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by:  Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
---
 include/linux/hfi/hfidd_pkt_formats.h |  338 +++++++++++++++++++++++++++++++++
 include/linux/hfi/hfidd_regs.h        |  212 +++++++++++++++++++++
 2 files changed, 550 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/hfi/hfidd_pkt_formats.h
 create mode 100644 include/linux/hfi/hfidd_regs.h

diff --git a/include/linux/hfi/hfidd_pkt_formats.h b/include/linux/hfi/hfidd_pkt_formats.h
new file mode 100644
index 0000000..ee8d385
--- /dev/null
+++ b/include/linux/hfi/hfidd_pkt_formats.h
@@ -0,0 +1,338 @@
+/*
+ * hfidd_pkt_formats.h
+ *
+ * HFI device driver for IBM System p
+ *
+ *  Authors:
+ *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *      William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *      Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *      Jian Xiao <jian@linux.vnet.ibm.com>
+ *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef _HFI_PKT_FORMATS_H
+#define _HFI_PKT_FORMATS_H
+
+#define HFI_HW_DIRECT_ROUTE		0
+#define HFI_SW_INDIRECT_ROUTE		1
+#define HW_DIRECT_STRIPING_ROUTE	2
+#define HW_INDIRECT_STRIPING_ROUTE	3
+
+/* HFI packet header format */
+
+struct immediate_send_hdr {
+	unsigned int	reserved1:8;
+	unsigned int	cop_type:8;	/* HFI coprocessor type is 0x3A */
+	unsigned int	reserved2:7;
+	unsigned int	src_win:9;	/* Hi bit is hfi# */
+} __packed;
+
+struct packet_type_hdr {
+	unsigned int	header_type:7;	/* See hfi_packet_type for types */
+	unsigned int	send_origin:1;	/*  0: from Send/RDMA FIFO */
+					/*  1: from Immediate Send */
+} __packed;
+
+struct base_hdr {
+	unsigned int	reserve1:1;
+	unsigned int	dst_isr:14;	/* destination ISR */
+	unsigned int	dst_win:9;	/* destination window.
+					   Hi bit is hfi num */
+	unsigned int	reserve2:1;
+
+	unsigned int	src_isr:14;	/* src ISR, Set by hardware */
+	unsigned int	src_win:9;	/* src window, Set by hardware.
+					   Hi bit is hfi num */
+	unsigned int	src_cau:1;
+	unsigned int	dst_cau:1;
+	unsigned int	reserve3:2;
+
+	unsigned int	pkt_len:4;	/* In cache lines. 0 means 16 */
+	unsigned int	reserve4:8;
+	unsigned int	trc_enable:1;	/* Request ISR trace info
+					   send/recv, IP packest only */
+	unsigned int	ctr_incr:1;	/* Request send and receive
+					   counter increments */
+	unsigned int	sii:1;		/* Source Side Immediate Int */
+	unsigned int	dii:1;		/* Dest Side Immediate Int */
+	unsigned int	reserve5:3;
+	unsigned int	pkt_valid:1;	/* Set by hardware
+					   Toggles when rFIFO wraps */
+	unsigned int	status:5;	/* Set by hardware completion status */
+	unsigned int	route_control:2;/* ISR use only	*/
+	unsigned int	ind_node:9;	/* ISR use only	*/
+} __packed;
+
+struct hfi_rdma_extended_hdr {			/* 48B */
+	unsigned long long	source_ea;	/* Full RDMA only, byte
+						   boundary */
+	unsigned long long	dest_ea;	/* byte boundary, independent of
+						   source data boundary	*/
+	unsigned int	pkt_len:4;		/* In cache lines, with
+						   exceptions */
+	unsigned int	reserved1:3;
+	unsigned int	msg_len:25;		/* In bytes.
+						   FullRDMA: Max 32MB
+						   (encoded as 0)
+						   HalfRDMA: Max 2kB
+						   SmallRDMA: Max 16B */
+	unsigned int	reserved2:5;
+	unsigned int	rcxt_offset:20;		/* into window's rcxt area */
+	unsigned int	reserved3:1;
+	unsigned int	breakup:6;		/* Message Breakup count */
+	unsigned int	epoch:32;
+	unsigned int	seq_num:14;
+	unsigned int	pkt_cnt:18;		/* FullRDMA only */
+	unsigned int	reserved4:3;
+	unsigned int	rcxt_index:5;		/* 1-31 allowed */
+	unsigned int	read_indicator:1;	/* 1 for FULL RDMA reads */
+	unsigned int	src_completion:1;
+	unsigned int	src_completion_notify:1;
+	unsigned int	dst_completion_notify:1;
+	unsigned int	status:5;		/* Notification packet only. */
+	unsigned int	reserved6:3;
+	unsigned int	fetch:1;		/* SmallRDMA only. */
+	unsigned int	opcode:3;
+	unsigned int	reserved7:8;
+	unsigned int	reserved8:32;
+	unsigned long long	cookie;		/* Protocol cookie */
+} __packed;
+
+struct gups_rdma_element {			/* 32B. Used without Base
+						   header */
+	unsigned int	job_id:32;
+	unsigned int	header_type:7;		/* Use GUPS types only */
+	unsigned int	reserved1:2;
+	unsigned int	dst_isr:14;		/* destination ISR */
+	unsigned int	dst_win:9;		/* destination window.
+						   Hi bit is hfi# */
+	unsigned int	reserved2:15;
+	unsigned int	ctr_incr:1;		/* Request send and receive
+						   counter increments */
+	unsigned int	isr_route_hdr:16;	/* ISR use only	*/
+	unsigned int	reserved3:32;
+
+	union {
+		unsigned long long	addr;
+		struct {
+			unsigned int	dest_ea_hi:32;
+			unsigned int	dest_ea_lo:29;	/* 8-byte align */
+			unsigned int	opcode:3;	/* Use HFI_OPCODE* */
+		} bits;
+	} dest_ea;
+
+	unsigned long long     payload;
+} __packed;
+
+struct hfi_cau_extended_hdr {		/* 32B */
+	unsigned int		group_id:27;
+	unsigned int		dst_sub_id:9;
+	unsigned int		src_sub_id:9;
+	unsigned int		reserved1:3;
+	unsigned int		op_attr_unsigned:1;	/* 0->Signed */
+	unsigned int		op_attr_64bit:1;	/* 0->32 bit */
+	unsigned int		op_attr_float:1;	/* 0->Fixed  */
+	unsigned int		function:5;
+	unsigned int		payload_cnt:8;		/* bitmask */
+	unsigned int		seq_num:32;
+	unsigned int		reserved2:6;
+	unsigned int		entry:1;		/* 0->A, 1->B */
+	unsigned int		reserved3:25;
+	unsigned long long	cookie_left;		/* Protocol Cookie */
+	unsigned long long	cookie_right;
+} __packed;
+
+struct hfi_hdr {
+	union {
+		struct immediate_send_hdr immediate_hdr;
+		unsigned int		job_id;
+	} id;
+
+	struct packet_type_hdr		type;
+	struct base_hdr			base_hdr;
+} __packed;
+
+struct hfi_rdma_hdr {
+	struct hfi_hdr		hfi_hdr;
+	struct hfi_rdma_extended_hdr rdma_ext;
+	/*
+	 * Pad enough for the payload to be aligned with the dest address.
+	 * SmallRDMA: no padding FullRDMA: packets 2-N pad 64 bytes
+	 */
+} __packed;
+
+
+struct hfi_rdma_pkt {
+	struct hfi_hdr		hfi_hdr;
+	struct hfi_rdma_extended_hdr rdma_ext;
+	/*
+	 * Pad enough for the payload to be aligned with the dest address.
+	 * SmallRDMA: no padding FullRDMA: packets 2-N pad 64 bytes
+	 */
+	char			padding_slash_payload[1984];
+} __packed;
+
+
+#define CACHE_LINE_SIZE 0x80
+#define CACHE_LINE_SHIFT 0x7
+/*
+ * Encode/Decode macros/inlines for bit fields
+ */
+static inline unsigned int hfi_bytes_to_cacheline(unsigned int bytes)
+{
+	return (bytes + (CACHE_LINE_SIZE - 1)) >> CACHE_LINE_SHIFT;
+}
+
+static inline unsigned int HFI_CACHELINES_TO_BYTES(unsigned int cache_lines)
+{
+	return cache_lines << CACHE_LINE_SHIFT;
+}
+
+static inline unsigned int hfi_cachelines_to_pktlen(unsigned int cachelines)
+{
+	return cachelines & 0xf;  /* No overflow checking */
+}
+
+static inline unsigned int hfi_pktlen_to_cachelines(unsigned int pktlen)
+{
+	return pktlen ? pktlen : 16;	/* 0 pktlen == 16 cache lines */
+}
+
+struct hfi_gups_rdma_pkt {
+	struct gups_rdma_element element[4];
+} __packed;
+
+struct hfi_collective_pkt {
+	struct hfi_hdr		hfi_hdr;
+	struct hfi_cau_extended_hdr cau_ext;
+	char			payload[64];
+	char			pad[16];
+} __packed;
+
+/*
+ * Opcodes for RDMA Extended Headers and GUPS-RDMA Elements
+ */
+#define HFI_OPCODE_ADD			0x0
+#define HFI_OPCODE_AND			0x1
+#define HFI_OPCODE_OR			0x2
+#define HFI_OPCODE_XOR			0x3
+#define HFI_OPCODE_RESERVED		0x4
+#define HFI_OPCODE_CMP_SWAP_NOT_EQUAL	0x5
+#define HFI_OPCODE_CMP_SWAP_EQUAL	0x6
+#define HFI_OPCODE_SWAP			0x7
+/* Fetch can be OR'd with any of the above Opcodes (SmallRDMA only) */
+#define HFI_OPCODE_FETCH		0x8
+
+enum hfi_cau_type {
+	HFI_CAU_TYPE_FLOAT			= 0x01,
+	HFI_CAU_TYPE_64BIT			= 0x02,
+	HFI_CAU_TYPE_UNSIGNED			= 0x04
+};
+
+enum hfi_cau_function {
+	HFI_CAU_FUNCTION_NOP			= 0x00,
+	HFI_CAU_FUNCTION_SUM			= 0x01,
+	HFI_CAU_FUNCTION_MIN			= 0x02,
+	HFI_CAU_FUNCTION_MAX			= 0x03,
+	HFI_CAU_FUNCTION_AND			= 0x11,
+	HFI_CAU_FUNCTION_XOR			= 0x16,
+	HFI_CAU_FUNCTION_OR			= 0x17
+};
+
+enum hfi_pkt_status {
+	HFI_PKT_STATUS_GOOD			= 0x0,
+	HFI_PKT_STATUS_DESCRIPTOR_FAILURE	= 0x1,
+	HFI_PKT_STATUS_PACKET_KILLED		= 0x2,
+	HFI_PKT_STATUS_UNEXPECTED_LAST_FLIT	= 0x4,
+	HFI_PKT_STATUS_POWERBUS_MASTER		= 0x8,
+	HFI_PKT_STATUS_TRANSLATION_FAULT	= 0x10
+
+};
+
+enum hfi_rdma_pkt_status {
+	HFI_RDMA_PKT_STATUS_GOOD		= 0x0,
+	HFI_RDMA_PKT_STATUS_MIGRATION_CONFLICT	= 0x1,
+	HFI_RDMA_PKT_STATUS_PACKET_KILLED	= 0x4,
+	HFI_RDMA_PKT_STATUS_POWERBUS_MASTER	= 0x8,
+	HFI_RDMA_PKT_STATUS_TRANSLATION_FAULT	= 0x10
+
+};
+
+enum hfi_packet_type {
+	HFI_SEND_RECEIVE			= 0x00,	/* send FIFO -> receive
+							   FIFO */
+
+	HFI_IP_WITH_PAYLOAD			= 0x08,	/* send FIFO -> receive
+							   FIFO for IP */
+	HFI_IP_MULTICAST_WITH_PAYLOAD		= 0x09,	/* ISR use only */
+	HFI_IP_WITH_DESCRIPTORS			= 0x0C,	/* IP send/recv with
+							   indirection */
+	HFI_IP_MULTICAST_WITH_DESCRIPTORS	= 0x0D,	/* IP send/recv with
+							   indirection */
+
+	HFI_FULL_RDMA_WRITE			= 0x10,
+	HFI_FULL_RDMA_READ			= 0x11,
+	HFI_FULL_RDMA_COMPLETION		= 0x12,	/* Completion
+							   notification */
+	HFI_FULL_RDMA_PREFENCE			= 0x13,	/* Guarantee RDMA FIFO
+							   processing is
+							   complete */
+	HFI_FULL_RDMA_FENCE			= 0x14,	/* Guarantee RDMA FIFO
+							   processing is
+							   complete */
+	HFI_FULL_RMDA_WRITE_ALIAS		= 0x15,	/* HW use only */
+
+	HFI_HALF_RDMA_WRITE			= 0x18,	/* send FIFO to target
+							   EA */
+	HFI_HALF_RDMA_READ			= 0x19,	/* target EA to receive
+							   FIFO */
+	HFI_HALF_RDMA_COMPLETION		= 0x1A,	/* Completion
+							   notification */
+	HFI_HALF_RDMA_READ_ALIAS		= 0x1D,	/* HW use only */
+
+	HFI_SMALL_RDMA_WRITE			= 0x20,	/* Remote atomic
+							   operations */
+	HFI_SMALL_RDMA_COMPLETION		= 0x22,	/* Completion
+							   notification */
+	HFI_SMALL_RDMA_COMPLETION_WITH_FETCH	= 0x23,	/* Completion
+							   notification */
+
+	HFI_GUPS_RDMA_1ELEMENT			= 0x28,	/* GUPS-RDMA, 1
+							   element */
+	HFI_GUPS_RDMA_2ELEMENT			= 0x29,	/* GUPS-RDMA,
+							   2 element */
+	HFI_GUPS_RDMA_3ELEMENT			= 0x2A,	/* GUPS-RDMA, 3
+							   element */
+	HFI_GUPS_RDMA_4ELEMENT			= 0x2B,	/* GUPS-RDMA, 4
+							   element */
+
+	HFI_CAU_REDUCE				= 0x30,	/* Collective Reduce */
+	HFI_CAU_MULTICAST			= 0x31,	/* Collective
+							   Multicast */
+	HFI_CAU_ACK				= 0x32,	/* Collective Ack */
+	HFI_CAU_RETRANS_REQ			= 0x33,	/* Collective
+							   Retransmit Req */
+	HFI_LAST_HEADER
+};
+
+#endif /* _HFI_PKT_FORMATS_H */
diff --git a/include/linux/hfi/hfidd_regs.h b/include/linux/hfi/hfidd_regs.h
new file mode 100644
index 0000000..864e0e6
--- /dev/null
+++ b/include/linux/hfi/hfidd_regs.h
@@ -0,0 +1,212 @@
+/*
+ * hfidd_regs.h
+ *
+ * HFI device driver for IBM System p
+ *
+ *  Authors:
+ *      Fu-Chung Chang <fcchang@linux.vnet.ibm.com>
+ *      William S. Cadden <wscadden@linux.vnet.ibm.com>
+ *      Wen C. Chen <winstonc@linux.vnet.ibm.com>
+ *      Scot Sakolish <sakolish@linux.vnet.ibm.com>
+ *      Jian Xiao <jian@linux.vnet.ibm.com>
+ *      Carol L. Soto <clsoto@linux.vnet.ibm.com>
+ *      Sarah J. Sheppard <sjsheppa@linux.vnet.ibm.com>
+ *
+ *  (C) Copyright IBM Corp. 2010
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef HFIDD_REGS_H
+#define HFIDD_REGS_H
+
+/* MMIO Registers */
+/* These are the registers with User Privilege Level */
+
+/* Window Control */
+#define HFI_JOB_ID_SEND		0x0000	/* 32: Send Side Job ID */
+#define HFI_JOB_ID_RECV		0x0008	/* 32: Send Side Job ID */
+#define HFI_WINDOW_STATE	0x0010	/*  1: 0=closed, 1=active */
+#define HFI_SEND_BUSY		0x0020	/* Send Window Busy */
+#define HFI_RECV_BUSY		0x0028	/* Rcv Window Busy */
+
+/* Addr Translation */
+#define HFI_LPAR_ID		0x0040	/* 10: Partition ID */
+#define HFI_PROTECTION_DOMAIN	0x0048	/* 32: used for addr xlat */
+#define HFI_XLAT_BYPASS		0x0050	/*  1:			  */
+
+/* Imm Send */
+#define HFI_IMM_SEND_BUF_ATTRBS	0x0080	/* 40: Immed Send Buffer Attributes */
+#define HFI_IMM_BUF_INUSE	0x0090	/* Immed Send Buffers In Use */
+#define HFI_IMM_FINI_COUNT	0x00A0	/* Immed Send Buffer Finished Count */
+#define HFI_IMM_FINI_FREQUENCY	0x00A8	/* Immed Send Finished Frequency */
+
+/* Send Fifo */
+#define HFI_SFIFO_DB_REG	0x0110	/* 16: Send Fifo Doorbell */
+#define HFI_SFIFO_BASE_ADDR	0x0120	/* 64: Send Fifo Effective Addr */
+#define HFI_SFIFO_LKEY		0x0128	/* 32: Send Fifo Local Key */
+#define HFI_SFIFO_PULL_OFF	0x0140	/* 64: Send Fifo Pull Offset */
+#define HFI_SFIFO_SIZE		0x0148	/*  4: size from 4K to 8M   */
+#define HFI_SFIFO_PEND_COUNT	0x0150	/* 16: Send Fifo Pending Count */
+#define HFI_SFIFO_FINI_POLARITY	0x0158	/*  1: Send Fifo Finish Polarity Bit */
+#define HFI_SFIFO_FINI_ADDR	0x0180	/* 64: Send Fifo Finish Effective
+					   Addr */
+#define HFI_IMM_FINI_ADDR	0x0188	/* Immed Send Finished Address */
+#define HFI_SFIFO_INTR_CNTL	0x01C8	/* xx: Send Fifo Interrupt Control */
+
+/* Full-RDMA Send Fifo */
+#define HFI_FRDMA_DB_REG	0x0210	/* Full-RDMA Send Fifo Doorbell */
+#define HFI_FRDMA_BASE_ADDR	0x0220	/* Full-RDMA Send Fifo Effective
+					   Address */
+#define HFI_FRDMA_LKEY		0x0228	/* Full-RDMA Send Fifo Local Key */
+#define HFI_FRDMA_PULL_REG	0x0240	/* Full-RDMA Send Fifo Pull Offset */
+#define HFI_FRDMA_SIZE		0x0248	/* Full-RDMA Send Size */
+#define HFI_FRDMA_PEND_REG	0x0250	/* Full-RDMA Send Fifo Pending Count */
+#define HFI_FRDMA_FINI_POLARITY	0x0248	/* Full-RDMA Send Fifo Finished
+					   Polarity */
+#define HFI_FRDMA_BREAKUP_REG	0x0260	/* Full-RDMA Send Fifo Breakup Count */
+#define HFI_FRDMA_FINI_ADDR	0x0280	/* Full-RDMA Send Fifo Finished
+					   Address */
+#define HFI_FRDMA_INTR_REG	0x02C8	/* Full-RDMA Send Fifo Interrupt
+					   Control */
+#define HFI_FRDMA_FENCE_CNT	0x0578	/* Full-RDMA Send Fifo Fence Count */
+
+/* Send Interrupts */
+#define HFI_SINTR_CONTROL_REG	0x02E0	/* Send Force Interrupt Control */
+#define HFI_SINTR_STATUS_REG	0x02E8	/* Send Intr Status */
+
+/* Receive Fifo */
+#define HFI_RFIFO_INC_FSLOT_REG	0x0310	/* Receive Fifo Inc Free Slot Count */
+#define HFI_RFIFO_BASE_ADDR	0x0320	/* Receive Fifo Effective Address */
+#define HFI_RFIFO_LKEY		0x0328	/* Receive Fifo Local Key */
+#define HFI_RFIFO_PUSH_REG	0x0340	/* Receive Fifo Push Offset */
+#define HFI_RFIFO_SIZE		0x0348	/*  4: range from 4K to 8M   */
+#define HFI_RFIFO_FSLOT_CNT_REG	0x0350	/* Receive Fifo Free Slot Count */
+#define	HFI_RFIFO_FINI_POLARITY	0x0358	/* Receive Fifo Finished Polarity */
+#define HFI_RFIFO_INJ_TH_REG	0x0360	/* Receive Fifo Cache Injection
+					   Threshold */
+#define HFI_RFIFO_OUT_TH_REG	0x0368	/* Receive Fifo Out-of-Order
+					   Threshold */
+#define HFI_RFIFO_OUT_EVENT_REG	0x03C0	/* Receive Fifo Out-of-Order Event
+					   Control */
+#define HFI_RFIFO_INTR_REG	0x03C8	/* Receive Fifo Intr Control */
+
+/* Receive Interrupts */
+#define HFI_RINTR_CONTROL_REG	0x03E0	/* Receive Force Intr Control */
+#define HFI_RINTR_STATUS_REG	0x03E8	/* Receivce Intr Status */
+
+/* IP 2K Free Space Descriptor Fifo */
+#define HFI_IP2K_INC_AVAIL_REG	0x0410	/* IP 2k FSD Fifo Inc Avail Slot
+					   Count */
+#define HFI_IP2K_BASE_ADDR	0x0420	/* IP 2k FSD Fifo Effective Address */
+#define HFI_IP2K_LKEY		0x0428	/* IP 2k FSD Fifo Local Key */
+#define HFI_IP2K_PULL_REG	0x0440	/* IP 2k FSD Fifo Pull Offset */
+#define HFI_IP2K_SIZE		0x0448	/* IP 2k FSD Fifo Size */
+#define HFI_IP2K_ASLOT_CNT_REG	0x0450	/* IP 2k FSD Fifo Avail Slot Count */
+
+/* RDMA Pending Fifo */
+#define HFI_RDMAP_BASE_ADDR	0x0520	/* RDMA Pending Fifo Efective Address */
+#define HFI_RDMAP_LKEY		0x0528	/* RDMA Pending Fifo Local Key */
+#define HFI_RDMAP_PULL_REG	0x0540	/* RDMA Pending Fifo Pull Offset */
+#define HFI_RDMAP_SIZE		0x0548	/* RDMA Pending Fifo Size */
+#define HFI_RDMAP_READ_TH_REG	0x0568	/* RDMA Pending Fifo Read Request
+					   Threshold */
+#define HFI_RDMAP_PUSH_REG	0x0570	/* RDMA Pending Fifo Push Offset */
+#define HFI_RDMAP_PEND_REG	0x0550	/* RDMA Pending Fifo Pending Count */
+
+/* Send Special Fifo */
+#define HFI_SSFIFO_BASE_ADDR	0x0620	/* Send Special Fifo Effective
+					   Address */
+#define HFI_SSFIFO_LKEY		0x0628	/* Send Special Fifo Local Key */
+#define HFI_SSFIFO_PULL_REG	0x0640	/* Send Special Fifo Pull Offset */
+#define HFI_SSFIFO_SIZE		0x0648	/* Send Special Fifo Size */
+#define HFI_SSFIFO_PUSH_REG	0x0670	/* Send Special Fifo Push Offset */
+#define HFI_SSFIFO_PENG_REG	0x0650	/* Send Special Fifo Pending Count */
+
+/* IP Context */
+#define HFI_IP_MCAST_ENABLE_REG	0x0820	/* IP Send - Multi-cast Enable */
+#define HFI_IP_DISABLE_ISR_REG	0x0828	/* IP Send - Disable Src_ISR_ID
+					   Stamp */
+#define HFI_IP_PORT_VALID_REG	0x0830	/* IP Logical Port ID Valid */
+#define	HFI_IP_PORT_REG		0x0838	/* IP Logical Port ID */
+#define HFI_IP_RECV_SIZE	0x0860	/* IP Recv with Payload Max Size */
+#define HFI_IP_RCV_IMM_REG	0x0868	/* IP RCV-Immediate Max Size */
+
+/* RDMA Context */
+#define HFI_RDMA_RCXT_BASE_ADDR	0x0920	/* RDMA Rcv RCxt Effective Address */
+#define HFI_RDMA_RCXT_LKEY	0x0928	/* RDMA RCxt Local Key */
+#define	HFI_RDMA_RCXT_PAY_LKEY	0x0058	/* RDMA Payload Local Key
+					   (no-sequential) */
+#define HFI_RDMA_RCXT_EPOCH	0x0980	/* RCxt Update Epoch */
+#define HFI_RDMA_RCXT_CACHE	0x0990	/* RCxt Cache Entry Flush Request */
+
+/* Counters */
+#define HFI_PACKETS_SENT_REG	0x0C00	/* Packets Sent */
+#define HFI_PSENT_DROP_REG	0x0C08	/* Packets Dropped from Sending */
+#define HFI_PIND_SENT_CNT_REG	0x0C10	/* Packet-Indicated Send Count */
+#define HFI_IMM_SEND_CNT_REG	0x0C18	/* Immed Send Packet Count */
+#define HFI_PACKETS_RCV_REG	0x0C40	/* Packets Received */
+#define HFI_PRCV_DROP_REG	0x0C48	/* Packets Dropped from Receiving */
+#define HFI_PIND_RCV_CNT_REG	0x0C50	/* Packet-Indicated Receive Count */
+#define HFI_SBIT_EEC_CNT_REG	0x0C60	/* Single-Bit ECC Count */
+#define HFI_SBIT_EEC_TH_REG	0x0C68	/* Single-Bit ECC Threshold for Error */
+#define HFI_ADDR_XLAT_CNT_REG	0x0C80	/* Addr Xlat Wait Count */
+
+/* Misc Non-Window Registers */
+#define	HFI_NUM_WINDOWS_REG	0x0000	/* Number of Windows */
+#define HFI_AGGR_PSENT_CNT_REG	0x0100	/* Aggregate Packet Sent Count */
+#define HFI_AGGR_PSENT_DROP_REG	0x0108	/* Aggregate Packet Dropped from
+					   Sending Count */
+#define HFI_AGGR_PRCV_CNT_REG	0x0110	/* Aggregate Packet Receive Count */
+#define HFI_AGGR_PRCV_DROP_REG	0x0118	/* Aggregate Packet Dropped from
+					   Receive Count */
+#define HFI_AGGR_ISEND_CNT_REG	0x0120	/* Aggregate Immediate Send Packet
+					   Sent Count */
+#define HFI_AGGR_SR_CNT_REG	0x0128	/* Aggregate Send/Rcv Packet Send
+					   Count */
+#define HFI_AGGR_FRDMA_CNT_REG	0x0130	/* Aggregate Full-RDMA Packet Sent
+					   Count */
+#define HFI_AGGR_HRDMA_CNT_REG	0x0138	/* Aggregate Half-RDMA Packet Sent
+					   Count */
+#define HFI_AGGR_SRDMA_CNT_REG	0x0140	/* Aggregate Small-RDMA Packet Sent
+					   Count */
+#define HFI_AGGR_IP_CNT_REG	0x0148	/* Aggregate IP Packet Sent Count */
+#define HFI_AGGR_CAU_CNT_REG	0x0150	/* Aggregate CAU Packet Sent Count */
+#define HFI_AGGR_GUPS_CNT_REG	0x0158	/* Aggregate GUPS Packet Sent Count */
+#define HFI_AGGR_NOTIFS_CNT_REG 0x0170  /* Aggregate Notifications Packet Sent
+						Count*/
+
+#define HFI_RCXT_FLUSH_REG	0x0600	/* RCxt Cache Window Flush Request */
+#define HFI_PG_MIGR1_REG	0x0708	/* Page Migration Register 1 */
+#define HFI_PG_MIGR2_REG	0x0710	/* Page Migration Register 2 */
+#define HFI_PG_MIGR3_REG	0x0718	/* Page Migration Register 3 */
+#define HFI_PG_MIGR4_REG	0x0720	/* Page Migration Register 4 */
+#define HFI_PG_MIGR5_REG	0x0728	/* Page Migration Register 5 */
+#define HFI_PG_MIGR6_REG	0x0730	/* Page Migration Register 6 */
+#define HFI_PG_MIGR7_REG	0x0738	/* Page Migration Register 7 */
+#define HFI_PG_MIGR1_RESV_REG	0x0808	/* Page Migration Reservation 1 */
+#define HFI_PG_MIGR2_RESV_REG	0x0810	/* Page Migration Reservation 2 */
+#define HFI_PG_MIGR3_RESV_REG	0x0818	/* Page Migration Reservation 3 */
+#define HFI_PG_MIGR4_RESV_REG	0x0820	/* Page Migration Reservation 4 */
+#define HFI_PG_MIGR5_RESV_REG	0x0828	/* Page Migration Reservation 5 */
+#define HFI_PG_MIGR6_RESV_REG	0x0830	/* Page Migration Reservation 6 */
+#define HFI_PG_MIGR7_RESV_REG	0x0838	/* Page Migration Reservation 7 */
+#define HFI_ADDR_XLAT_WCNT_REG	0x0A20	/* Addr Xlat Wait Count */
+
+#define MASK_56_BITS	0x00ffffffffffffff
+#define MASK_40_BITS	0x000000ffffffffff
+
+#endif /* HFIDD_REGS_H */
-- 
1.7.3.5

