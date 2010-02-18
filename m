From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 1/7] cxgb4: Add register and message definitions
Date: Thu, 18 Feb 2010 13:24:10 -0800
Message-ID: <1266528256-20873-2-git-send-email-dm@chelsio.com>
References: <1266528256-20873-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23271 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308Ab0BRVYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 16:24:30 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o1ILOUfp032165
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 13:24:30 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o1ILOG1Y020944
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 13:24:16 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o1ILOGCP020943
	for netdev@vger.kernel.org; Thu, 18 Feb 2010 13:24:16 -0800
In-Reply-To: <1266528256-20873-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_msg.h  | 1353 +++++++++++++++++++++++++++
 drivers/net/cxgb4/t4_regs.h | 2109 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 3462 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/cxgb4/t4_msg.h
 create mode 100644 drivers/net/cxgb4/t4_regs.h

diff --git a/drivers/net/cxgb4/t4_msg.h b/drivers/net/cxgb4/t4_msg.h
new file mode 100644
index 0000000..9d22c5c
--- /dev/null
+++ b/drivers/net/cxgb4/t4_msg.h
@@ -0,0 +1,1353 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __T4_MSG_H
+#define __T4_MSG_H
+
+#include <linux/types.h>
+
+enum {
+	CPL_PASS_OPEN_REQ     = 0x1,
+	CPL_PASS_ACCEPT_RPL   = 0x2,
+	CPL_ACT_OPEN_REQ      = 0x3,
+	CPL_SET_TCB_FIELD     = 0x5,
+	CPL_GET_TCB           = 0x6,
+	CPL_CLOSE_CON_REQ     = 0x8,
+	CPL_CLOSE_LISTSRV_REQ = 0x9,
+	CPL_ABORT_REQ         = 0xA,
+	CPL_ABORT_RPL         = 0xB,
+	CPL_RX_DATA_ACK       = 0xD,
+	CPL_TX_PKT            = 0xE,
+	CPL_L2T_WRITE_REQ     = 0x12,
+	CPL_TID_RELEASE       = 0x1A,
+
+	CPL_CLOSE_LISTSRV_RPL = 0x20,
+	CPL_L2T_WRITE_RPL     = 0x23,
+	CPL_PASS_OPEN_RPL     = 0x24,
+	CPL_ACT_OPEN_RPL      = 0x25,
+	CPL_PEER_CLOSE        = 0x26,
+	CPL_ABORT_REQ_RSS     = 0x2B,
+	CPL_ABORT_RPL_RSS     = 0x2D,
+
+	CPL_CLOSE_CON_RPL     = 0x32,
+	CPL_ISCSI_HDR         = 0x33,
+	CPL_RDMA_CQE          = 0x35,
+	CPL_RDMA_CQE_READ_RSP = 0x36,
+	CPL_RDMA_CQE_ERR      = 0x37,
+	CPL_RX_DATA           = 0x39,
+	CPL_SET_TCB_RPL       = 0x3A,
+	CPL_RX_PKT            = 0x3B,
+	CPL_RX_DDP_COMPLETE   = 0x3F,
+
+	CPL_ACT_ESTABLISH     = 0x40,
+	CPL_PASS_ESTABLISH    = 0x41,
+	CPL_RX_DATA_DDP       = 0x42,
+	CPL_PASS_ACCEPT_REQ   = 0x44,
+
+	CPL_RDMA_READ_REQ     = 0x60,
+
+	CPL_PASS_OPEN_REQ6    = 0x81,
+	CPL_ACT_OPEN_REQ6     = 0x83,
+
+	CPL_RDMA_TERMINATE    = 0xA2,
+	CPL_RDMA_WRITE        = 0xA4,
+	CPL_SGE_EGR_UPDATE    = 0xA5,
+
+	CPL_TRACE_PKT         = 0xB0,
+
+	CPL_FW4_MSG           = 0xC0,
+	CPL_FW4_PLD           = 0xC1,
+	CPL_FW4_ACK           = 0xC3,
+
+	CPL_FW6_MSG           = 0xE0,
+	CPL_FW6_PLD           = 0xE1,
+	CPL_TX_PKT_LSO        = 0xED,
+	CPL_TX_PKT_XT         = 0xEE,
+
+	NUM_CPL_CMDS    /* must be last and previous entries must be sorted */
+};
+
+enum CPL_error {
+	CPL_ERR_NONE               = 0,
+	CPL_ERR_TCAM_PARITY        = 1,
+	CPL_ERR_TCAM_FULL          = 3,
+	CPL_ERR_BAD_LENGTH         = 15,
+	CPL_ERR_BAD_ROUTE          = 18,
+	CPL_ERR_CONN_RESET         = 20,
+	CPL_ERR_CONN_EXIST_SYNRECV = 21,
+	CPL_ERR_CONN_EXIST         = 22,
+	CPL_ERR_ARP_MISS           = 23,
+	CPL_ERR_BAD_SYN            = 24,
+	CPL_ERR_CONN_TIMEDOUT      = 30,
+	CPL_ERR_XMIT_TIMEDOUT      = 31,
+	CPL_ERR_PERSIST_TIMEDOUT   = 32,
+	CPL_ERR_FINWAIT2_TIMEDOUT  = 33,
+	CPL_ERR_KEEPALIVE_TIMEDOUT = 34,
+	CPL_ERR_RTX_NEG_ADVICE     = 35,
+	CPL_ERR_PERSIST_NEG_ADVICE = 36,
+	CPL_ERR_ABORT_FAILED       = 42,
+	CPL_ERR_IWARP_FLM          = 50,
+};
+
+enum {
+	CPL_CONN_POLICY_ASK  = 1,
+};
+
+enum {
+	ULP_MODE_NONE          = 0,
+	ULP_MODE_ISCSI         = 2,
+	ULP_MODE_RDMA          = 4,
+	ULP_MODE_FCOE          = 6,
+};
+
+enum {
+	ULP_CRC_HEADER = 1 << 0,
+	ULP_CRC_DATA   = 1 << 1
+};
+
+enum {
+	CPL_PASS_OPEN_ACCEPT,
+	CPL_PASS_OPEN_REJECT,
+	CPL_PASS_OPEN_ACCEPT_TNL
+};
+
+enum {
+	CPL_ABORT_SEND_RST = 0,
+	CPL_ABORT_NO_RST,
+};
+
+enum {                     /* TX_PKT_XT checksum types */
+	TX_CSUM_TCP    = 0,
+	TX_CSUM_UDP    = 1,
+	TX_CSUM_CRC16  = 4,
+	TX_CSUM_CRC32  = 5,
+	TX_CSUM_CRC32C = 6,
+	TX_CSUM_FCOE   = 7,
+	TX_CSUM_TCPIP  = 8,
+	TX_CSUM_UDPIP  = 9,
+	TX_CSUM_TCPIP6 = 10,
+	TX_CSUM_UDPIP6 = 11,
+	TX_CSUM_IP     = 12,
+};
+
+enum {                     /* packet type in CPL_RX_PKT */
+	PKTYPE_XACT_UCAST = 0,
+	PKTYPE_HASH_UCAST = 1,
+	PKTYPE_XACT_MCAST = 2,
+	PKTYPE_HASH_MCAST = 3,
+	PKTYPE_PROMISC    = 4,
+	PKTYPE_HPROMISC   = 5,
+	PKTYPE_BCAST      = 6
+};
+
+enum {                     /* DMAC type in CPL_RX_PKT */
+	DATYPE_UCAST,
+	DATYPE_MCAST,
+	DATYPE_BCAST
+};
+
+enum {                     /* RSS hash type */
+	RSS_HASH_NONE = 0, /* no hash computed */
+	RSS_HASH_IP   = 1, /* IP or IPv6 2-tuple hash */
+	RSS_HASH_TCP  = 2, /* TCP 4-tuple hash */
+	RSS_HASH_UDP  = 3  /* UDP 4-tuple hash */
+};
+
+union opcode_tid {
+	__be32 opcode_tid;
+	__u8 opcode;
+};
+
+#define S_CPL_OPCODE    24
+#define V_CPL_OPCODE(x) ((x) << S_CPL_OPCODE)
+#define G_CPL_OPCODE(x) (((x) >> S_CPL_OPCODE) & 0xFF)
+#define G_TID(x)    ((x) & 0xFFFFFF)
+
+#define MK_OPCODE_TID(opcode, tid) (V_CPL_OPCODE(opcode) | (tid))
+
+#define OPCODE_TID(cmd) ((cmd)->ot.opcode_tid)
+
+/* extract the TID from a CPL command */
+#define GET_TID(cmd) (G_TID(ntohl(OPCODE_TID(cmd))))
+
+/* partitioning of TID fields that also carry a queue id */
+#define S_TID_TID    0
+#define M_TID_TID    0x3fff
+#define V_TID_TID(x) ((x) << S_TID_TID)
+#define G_TID_TID(x) (((x) >> S_TID_TID) & M_TID_TID)
+
+#define S_TID_QID    14
+#define M_TID_QID    0x3ff
+#define V_TID_QID(x) ((x) << S_TID_QID)
+#define G_TID_QID(x) (((x) >> S_TID_QID) & M_TID_QID)
+
+struct tcp_options {
+	__be16 mss;
+	__u8 wsf;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u8 :4;
+	__u8 unknown:1;
+	__u8 :1;
+	__u8 sack:1;
+	__u8 tstamp:1;
+#else
+	__u8 tstamp:1;
+	__u8 sack:1;
+	__u8 :1;
+	__u8 unknown:1;
+	__u8 :4;
+#endif
+};
+
+struct rss_header {
+	__u8 opcode;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u8 channel:2;
+	__u8 filter_hit:1;
+	__u8 filter_tid:1;
+	__u8 hash_type:2;
+	__u8 ipv6:1;
+	__u8 send2fw:1;
+#else
+	__u8 send2fw:1;
+	__u8 ipv6:1;
+	__u8 hash_type:2;
+	__u8 filter_tid:1;
+	__u8 filter_hit:1;
+	__u8 channel:2;
+#endif
+	__be16 qid;
+	__be32 hash_val;
+};
+
+#define S_HASHTYPE 20
+#define M_HASHTYPE 0x3
+#define G_HASHTYPE(x) (((x) >> S_HASHTYPE) & M_HASHTYPE)
+
+#define S_QNUM 0
+#define M_QNUM 0xFFFF
+#define G_QNUM(x) (((x) >> S_QNUM) & M_QNUM)
+
+struct work_request_hdr {
+	__be32 wr_hi;
+	__be32 wr_mid;
+	__be64 wr_lo;
+};
+
+/* wr_mid fields */
+#define S_WR_LEN16    0
+#define M_WR_LEN16    0xFF
+#define V_WR_LEN16(x) ((x) << S_WR_LEN16)
+#define G_WR_LEN16(x) (((x) >> S_WR_LEN16) & M_WR_LEN16)
+
+/* wr_hi fields */
+#define S_WR_OP    24
+#define M_WR_OP    0xFF
+#define V_WR_OP(x) ((__u64)(x) << S_WR_OP)
+#define G_WR_OP(x) (((x) >> S_WR_OP) & M_WR_OP)
+
+#define WR_HDR struct work_request_hdr wr
+
+/* option 0 fields */
+#define S_ACCEPT_MODE    0
+#define M_ACCEPT_MODE    0x3
+#define V_ACCEPT_MODE(x) ((x) << S_ACCEPT_MODE)
+#define G_ACCEPT_MODE(x) (((x) >> S_ACCEPT_MODE) & M_ACCEPT_MODE)
+
+#define S_TX_CHAN    2
+#define M_TX_CHAN    0x3
+#define V_TX_CHAN(x) ((x) << S_TX_CHAN)
+#define G_TX_CHAN(x) (((x) >> S_TX_CHAN) & M_TX_CHAN)
+
+#define S_NO_CONG    4
+#define V_NO_CONG(x) ((x) << S_NO_CONG)
+#define F_NO_CONG    V_NO_CONG(1U)
+
+#define S_DELACK    5
+#define V_DELACK(x) ((x) << S_DELACK)
+#define F_DELACK    V_DELACK(1U)
+
+#define S_NON_OFFLOAD    7
+#define V_NON_OFFLOAD(x) ((x) << S_NON_OFFLOAD)
+#define F_NON_OFFLOAD    V_NON_OFFLOAD(1U)
+
+#define S_ULP_MODE    8
+#define M_ULP_MODE    0xF
+#define V_ULP_MODE(x) ((x) << S_ULP_MODE)
+#define G_ULP_MODE(x) (((x) >> S_ULP_MODE) & M_ULP_MODE)
+
+#define S_RCV_BUFSIZ    12
+#define M_RCV_BUFSIZ    0x3FF
+#define V_RCV_BUFSIZ(x) ((x) << S_RCV_BUFSIZ)
+#define G_RCV_BUFSIZ(x) (((x) >> S_RCV_BUFSIZ) & M_RCV_BUFSIZ)
+
+#define S_DSCP    22
+#define M_DSCP    0x3F
+#define V_DSCP(x) ((x) << S_DSCP)
+#define G_DSCP(x) (((x) >> S_DSCP) & M_DSCP)
+
+#define S_SMAC_SEL    28
+#define M_SMAC_SEL    0xFF
+#define V_SMAC_SEL(x) ((__u64)(x) << S_SMAC_SEL)
+#define G_SMAC_SEL(x) (((x) >> S_SMAC_SEL) & M_SMAC_SEL)
+
+#define S_L2T_IDX    36
+#define M_L2T_IDX    0xFFF
+#define V_L2T_IDX(x) ((__u64)(x) << S_L2T_IDX)
+#define G_L2T_IDX(x) (((x) >> S_L2T_IDX) & M_L2T_IDX)
+
+#define S_TCAM_BYPASS    48
+#define V_TCAM_BYPASS(x) ((__u64)(x) << S_TCAM_BYPASS)
+#define F_TCAM_BYPASS    V_TCAM_BYPASS(1ULL)
+
+#define S_NAGLE    49
+#define V_NAGLE(x) ((__u64)(x) << S_NAGLE)
+#define F_NAGLE    V_NAGLE(1ULL)
+
+#define S_WND_SCALE    50
+#define M_WND_SCALE    0xF
+#define V_WND_SCALE(x) ((__u64)(x) << S_WND_SCALE)
+#define G_WND_SCALE(x) (((x) >> S_WND_SCALE) & M_WND_SCALE)
+
+#define S_KEEP_ALIVE    54
+#define V_KEEP_ALIVE(x) ((__u64)(x) << S_KEEP_ALIVE)
+#define F_KEEP_ALIVE    V_KEEP_ALIVE(1ULL)
+
+#define S_MAX_RT    55
+#define M_MAX_RT    0xF
+#define V_MAX_RT(x) ((__u64)(x) << S_MAX_RT)
+#define G_MAX_RT(x) (((x) >> S_MAX_RT) & M_MAX_RT)
+
+#define S_MAX_RT_OVERRIDE    59
+#define V_MAX_RT_OVERRIDE(x) ((__u64)(x) << S_MAX_RT_OVERRIDE)
+#define F_MAX_RT_OVERRIDE    V_MAX_RT_OVERRIDE(1ULL)
+
+#define S_MSS_IDX    60
+#define M_MSS_IDX    0xF
+#define V_MSS_IDX(x) ((__u64)(x) << S_MSS_IDX)
+#define G_MSS_IDX(x) (((x) >> S_MSS_IDX) & M_MSS_IDX)
+
+/* option 1 fields */
+#define S_SYN_RSS_ENABLE    0
+#define V_SYN_RSS_ENABLE(x) ((x) << S_SYN_RSS_ENABLE)
+#define F_SYN_RSS_ENABLE    V_SYN_RSS_ENABLE(1U)
+
+#define S_SYN_RSS_USE_HASH    1
+#define V_SYN_RSS_USE_HASH(x) ((x) << S_SYN_RSS_USE_HASH)
+#define F_SYN_RSS_USE_HASH    V_SYN_RSS_USE_HASH(1U)
+
+#define S_SYN_RSS_QUEUE    2
+#define M_SYN_RSS_QUEUE    0x3FF
+#define V_SYN_RSS_QUEUE(x) ((x) << S_SYN_RSS_QUEUE)
+#define G_SYN_RSS_QUEUE(x) (((x) >> S_SYN_RSS_QUEUE) & M_SYN_RSS_QUEUE)
+
+#define S_LISTEN_INTF    12
+#define M_LISTEN_INTF    0xFF
+#define V_LISTEN_INTF(x) ((x) << S_LISTEN_INTF)
+#define G_LISTEN_INTF(x) (((x) >> S_LISTEN_INTF) & M_LISTEN_INTF)
+
+#define S_LISTEN_FILTER    20
+#define V_LISTEN_FILTER(x) ((x) << S_LISTEN_FILTER)
+#define F_LISTEN_FILTER    V_LISTEN_FILTER(1U)
+
+#define S_CONN_POLICY    22
+#define M_CONN_POLICY    0x3
+#define V_CONN_POLICY(x) ((x) << S_CONN_POLICY)
+#define G_CONN_POLICY(x) (((x) >> S_CONN_POLICY) & M_CONN_POLICY)
+
+/* option 2 fields */
+#define S_RSS_QUEUE    0
+#define M_RSS_QUEUE    0x3FF
+#define V_RSS_QUEUE(x) ((x) << S_RSS_QUEUE)
+#define G_RSS_QUEUE(x) (((x) >> S_RSS_QUEUE) & M_RSS_QUEUE)
+
+#define S_RSS_QUEUE_VALID    10
+#define V_RSS_QUEUE_VALID(x) ((x) << S_RSS_QUEUE_VALID)
+#define F_RSS_QUEUE_VALID    V_RSS_QUEUE_VALID(1U)
+
+#define S_RX_COALESCE_VALID    11
+#define V_RX_COALESCE_VALID(x) ((x) << S_RX_COALESCE_VALID)
+#define F_RX_COALESCE_VALID    V_RX_COALESCE_VALID(1U)
+
+#define S_RX_COALESCE    12
+#define M_RX_COALESCE    0x3
+#define V_RX_COALESCE(x) ((x) << S_RX_COALESCE)
+#define G_RX_COALESCE(x) (((x) >> S_RX_COALESCE) & M_RX_COALESCE)
+
+#define S_CONG_CNTRL    14
+#define M_CONG_CNTRL    0x3
+#define V_CONG_CNTRL(x) ((x) << S_CONG_CNTRL)
+#define G_CONG_CNTRL(x) (((x) >> S_CONG_CNTRL) & M_CONG_CNTRL)
+
+#define S_PACE    16
+#define M_PACE    0x3
+#define V_PACE(x) ((x) << S_PACE)
+#define G_PACE(x) (((x) >> S_PACE) & M_PACE)
+
+#define S_CONG_CNTRL_VALID    18
+#define V_CONG_CNTRL_VALID(x) ((x) << S_CONG_CNTRL_VALID)
+#define F_CONG_CNTRL_VALID    V_CONG_CNTRL_VALID(1U)
+
+#define S_PACE_VALID    19
+#define V_PACE_VALID(x) ((x) << S_PACE_VALID)
+#define F_PACE_VALID    V_PACE_VALID(1U)
+
+#define S_RX_FC_DISABLE    20
+#define V_RX_FC_DISABLE(x) ((x) << S_RX_FC_DISABLE)
+#define F_RX_FC_DISABLE    V_RX_FC_DISABLE(1U)
+
+#define S_RX_FC_DDP    21
+#define V_RX_FC_DDP(x) ((x) << S_RX_FC_DDP)
+#define F_RX_FC_DDP    V_RX_FC_DDP(1U)
+
+#define S_RX_FC_VALID    22
+#define V_RX_FC_VALID(x) ((x) << S_RX_FC_VALID)
+#define F_RX_FC_VALID    V_RX_FC_VALID(1U)
+
+#define S_TX_QUEUE    23
+#define M_TX_QUEUE    0x7
+#define V_TX_QUEUE(x) ((x) << S_TX_QUEUE)
+#define G_TX_QUEUE(x) (((x) >> S_TX_QUEUE) & M_TX_QUEUE)
+
+#define S_RX_CHANNEL    26
+#define V_RX_CHANNEL(x) ((x) << S_RX_CHANNEL)
+#define F_RX_CHANNEL    V_RX_CHANNEL(1U)
+
+#define S_CCTRL_ECN    27
+#define V_CCTRL_ECN(x) ((x) << S_CCTRL_ECN)
+#define F_CCTRL_ECN    V_CCTRL_ECN(1U)
+
+#define S_WND_SCALE_EN    28
+#define V_WND_SCALE_EN(x) ((x) << S_WND_SCALE_EN)
+#define F_WND_SCALE_EN    V_WND_SCALE_EN(1U)
+
+#define S_TSTAMPS_EN    29
+#define V_TSTAMPS_EN(x) ((x) << S_TSTAMPS_EN)
+#define F_TSTAMPS_EN    V_TSTAMPS_EN(1U)
+
+#define S_SACK_EN    30
+#define V_SACK_EN(x) ((x) << S_SACK_EN)
+#define F_SACK_EN    V_SACK_EN(1U)
+
+struct cpl_pass_open_req {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 local_port;
+	__be16 peer_port;
+	__be32 local_ip;
+	__be32 peer_ip;
+	__be64 opt0;
+	__be64 opt1;
+};
+
+struct cpl_pass_open_req6 {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 local_port;
+	__be16 peer_port;
+	__be64 local_ip_hi;
+	__be64 local_ip_lo;
+	__be64 peer_ip_hi;
+	__be64 peer_ip_lo;
+	__be64 opt0;
+	__be64 opt1;
+};
+
+struct cpl_pass_open_rpl {
+	union opcode_tid ot;
+	__u8 rsvd[3];
+	__u8 status;
+};
+
+struct cpl_pass_establish {
+	union opcode_tid ot;
+	__be32 rsvd;
+	__be32 tos_stid;
+	__be16 mac_idx;
+	__be16 tcp_opt;
+	__be32 snd_isn;
+	__be32 rcv_isn;
+};
+
+/* cpl_pass_establish.tos_stid fields */
+#define S_PASS_OPEN_TID    0
+#define M_PASS_OPEN_TID    0xFFFFFF
+#define V_PASS_OPEN_TID(x) ((x) << S_PASS_OPEN_TID)
+#define G_PASS_OPEN_TID(x) (((x) >> S_PASS_OPEN_TID) & M_PASS_OPEN_TID)
+
+#define S_PASS_OPEN_TOS    24
+#define M_PASS_OPEN_TOS    0xFF
+#define V_PASS_OPEN_TOS(x) ((x) << S_PASS_OPEN_TOS)
+#define G_PASS_OPEN_TOS(x) (((x) >> S_PASS_OPEN_TOS) & M_PASS_OPEN_TOS)
+
+/* cpl_pass_establish.tcp_opt fields (also applies to act_open_establish) */
+#define G_TCPOPT_WSCALE_OK(x)  (((x) >> 5) & 1)
+#define G_TCPOPT_SACK(x)       (((x) >> 6) & 1)
+#define G_TCPOPT_TSTAMP(x)     (((x) >> 7) & 1)
+#define G_TCPOPT_SND_WSCALE(x) (((x) >> 8) & 0xf)
+#define G_TCPOPT_MSS(x)        (((x) >> 12) & 0xf)
+
+struct cpl_pass_accept_req {
+	union opcode_tid ot;
+	__be16 rsvd;
+	__be16 len;
+	__be32 hdr_len;
+	__be16 vlan;
+	__be16 l2info;
+	__be32 tos_stid;
+	struct tcp_options tcpopt;
+};
+
+/* cpl_pass_accept_req.hdr_len fields */
+#define S_SYN_RX_CHAN    0
+#define M_SYN_RX_CHAN    0xF
+#define V_SYN_RX_CHAN(x) ((x) << S_SYN_RX_CHAN)
+#define G_SYN_RX_CHAN(x) (((x) >> S_SYN_RX_CHAN) & M_SYN_RX_CHAN)
+
+#define S_TCP_HDR_LEN    10
+#define M_TCP_HDR_LEN    0x3F
+#define V_TCP_HDR_LEN(x) ((x) << S_TCP_HDR_LEN)
+#define G_TCP_HDR_LEN(x) (((x) >> S_TCP_HDR_LEN) & M_TCP_HDR_LEN)
+
+#define S_IP_HDR_LEN    16
+#define M_IP_HDR_LEN    0x3FF
+#define V_IP_HDR_LEN(x) ((x) << S_IP_HDR_LEN)
+#define G_IP_HDR_LEN(x) (((x) >> S_IP_HDR_LEN) & M_IP_HDR_LEN)
+
+#define S_ETH_HDR_LEN    26
+#define M_ETH_HDR_LEN    0x1F
+#define V_ETH_HDR_LEN(x) ((x) << S_ETH_HDR_LEN)
+#define G_ETH_HDR_LEN(x) (((x) >> S_ETH_HDR_LEN) & M_ETH_HDR_LEN)
+
+/* cpl_pass_accept_req.l2info fields */
+#define S_SYN_MAC_IDX    0
+#define M_SYN_MAC_IDX    0x1FF
+#define V_SYN_MAC_IDX(x) ((x) << S_SYN_MAC_IDX)
+#define G_SYN_MAC_IDX(x) (((x) >> S_SYN_MAC_IDX) & M_SYN_MAC_IDX)
+
+#define S_SYN_XACT_MATCH    9
+#define V_SYN_XACT_MATCH(x) ((x) << S_SYN_XACT_MATCH)
+#define F_SYN_XACT_MATCH    V_SYN_XACT_MATCH(1U)
+
+#define S_SYN_INTF    12
+#define M_SYN_INTF    0xF
+#define V_SYN_INTF(x) ((x) << S_SYN_INTF)
+#define G_SYN_INTF(x) (((x) >> S_SYN_INTF) & M_SYN_INTF)
+
+struct cpl_pass_accept_rpl {
+	WR_HDR;
+	union opcode_tid ot;
+	__be32 opt2;
+	__be64 opt0;
+};
+
+struct cpl_act_open_req {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 local_port;
+	__be16 peer_port;
+	__be32 local_ip;
+	__be32 peer_ip;
+	__be64 opt0;
+	__be32 params;
+	__be32 opt2;
+};
+
+struct cpl_act_open_req6 {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 local_port;
+	__be16 peer_port;
+	__be64 local_ip_hi;
+	__be64 local_ip_lo;
+	__be64 peer_ip_hi;
+	__be64 peer_ip_lo;
+	__be64 opt0;
+	__be32 params;
+	__be32 opt2;
+};
+
+struct cpl_act_open_rpl {
+	union opcode_tid ot;
+	__be32 atid_status;
+};
+
+/* cpl_act_open_rpl.atid_status fields */
+#define S_AOPEN_STATUS    0
+#define M_AOPEN_STATUS    0xFF
+#define V_AOPEN_STATUS(x) ((x) << S_AOPEN_STATUS)
+#define G_AOPEN_STATUS(x) (((x) >> S_AOPEN_STATUS) & M_AOPEN_STATUS)
+
+#define S_AOPEN_ATID    8
+#define M_AOPEN_ATID    0xFFFFFF
+#define V_AOPEN_ATID(x) ((x) << S_AOPEN_ATID)
+#define G_AOPEN_ATID(x) (((x) >> S_AOPEN_ATID) & M_AOPEN_ATID)
+
+struct cpl_act_establish {
+	union opcode_tid ot;
+	__be32 rsvd;
+	__be32 tos_atid;
+	__be16 mac_idx;
+	__be16 tcp_opt;
+	__be32 snd_isn;
+	__be32 rcv_isn;
+};
+
+struct cpl_get_tcb {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 reply_ctrl;
+	__be16 cookie;
+};
+
+/* cpl_get_tcb.reply_ctrl fields */
+#define S_QUEUENO    0
+#define M_QUEUENO    0x3FF
+#define V_QUEUENO(x) ((x) << S_QUEUENO)
+#define G_QUEUENO(x) (((x) >> S_QUEUENO) & M_QUEUENO)
+
+#define S_REPLY_CHAN    14
+#define V_REPLY_CHAN(x) ((x) << S_REPLY_CHAN)
+#define F_REPLY_CHAN    V_REPLY_CHAN(1U)
+
+#define S_NO_REPLY    15
+#define V_NO_REPLY(x) ((x) << S_NO_REPLY)
+#define F_NO_REPLY    V_NO_REPLY(1U)
+
+struct cpl_get_tcb_rpl {
+	union opcode_tid ot;
+	__u8 cookie;
+	__u8 status;
+	__be16 len;
+};
+
+struct cpl_set_tcb_field {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 reply_ctrl;
+	__be16 word_cookie;
+	__be64 mask;
+	__be64 val;
+};
+
+/* cpl_set_tcb_field.word_cookie fields */
+#define S_WORD    0
+#define M_WORD    0x1F
+#define V_WORD(x) ((x) << S_WORD)
+#define G_WORD(x) (((x) >> S_WORD) & M_WORD)
+
+#define S_COOKIE    5
+#define M_COOKIE    0x7
+#define V_COOKIE(x) ((x) << S_COOKIE)
+#define G_COOKIE(x) (((x) >> S_COOKIE) & M_COOKIE)
+
+struct cpl_set_tcb_rpl {
+	union opcode_tid ot;
+	__be16 rsvd;
+	__u8   cookie;
+	__u8   status;
+	__be64 oldval;
+};
+
+struct cpl_close_con_req {
+	WR_HDR;
+	union opcode_tid ot;
+	__be32 rsvd;
+};
+
+struct cpl_close_con_rpl {
+	union opcode_tid ot;
+	__u8  rsvd[3];
+	__u8  status;
+	__be32 snd_nxt;
+	__be32 rcv_nxt;
+};
+
+struct cpl_close_listsvr_req {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 reply_ctrl;
+	__be16 rsvd;
+};
+
+/* additional cpl_close_listsvr_req.reply_ctrl field */
+#define S_LISTSVR_IPV6    14
+#define V_LISTSVR_IPV6(x) ((x) << S_LISTSVR_IPV6)
+#define F_LISTSVR_IPV6    V_LISTSVR_IPV6(1U)
+
+struct cpl_close_listsvr_rpl {
+	union opcode_tid ot;
+	__u8 rsvd[3];
+	__u8 status;
+};
+
+struct cpl_abort_req_rss {
+	union opcode_tid ot;
+	__u8  rsvd[3];
+	__u8  status;
+};
+
+struct cpl_abort_req {
+	WR_HDR;
+	union opcode_tid ot;
+	__be32 rsvd0;
+	__u8  rsvd1;
+	__u8  cmd;
+	__u8  rsvd2[6];
+};
+
+struct cpl_abort_rpl_rss {
+	union opcode_tid ot;
+	__u8  rsvd[3];
+	__u8  status;
+};
+
+struct cpl_abort_rpl {
+	WR_HDR;
+	union opcode_tid ot;
+	__be32 rsvd0;
+	__u8  rsvd1;
+	__u8  cmd;
+	__u8  rsvd2[6];
+};
+
+struct cpl_peer_close {
+	union opcode_tid ot;
+	__be32 rcv_nxt;
+};
+
+struct cpl_tid_release {
+	WR_HDR;
+	union opcode_tid ot;
+	__be32 rsvd;
+};
+
+struct cpl_tx_pkt_core {
+	__be32 ctrl0;
+	__be16 pack;
+	__be16 len;
+	__be64 ctrl1;
+};
+
+struct cpl_tx_pkt {
+	WR_HDR;
+	struct cpl_tx_pkt_core c;
+};
+
+#define cpl_tx_pkt_xt cpl_tx_pkt
+
+/* cpl_tx_pkt_core.ctrl0 fields */
+#define S_TXPKT_VF    0
+#define M_TXPKT_VF    0xFF
+#define V_TXPKT_VF(x) ((x) << S_TXPKT_VF)
+#define G_TXPKT_VF(x) (((x) >> S_TXPKT_VF) & M_TXPKT_VF)
+
+#define S_TXPKT_PF    8
+#define M_TXPKT_PF    0x7
+#define V_TXPKT_PF(x) ((x) << S_TXPKT_PF)
+#define G_TXPKT_PF(x) (((x) >> S_TXPKT_PF) & M_TXPKT_PF)
+
+#define S_TXPKT_VF_VLD    11
+#define V_TXPKT_VF_VLD(x) ((x) << S_TXPKT_VF_VLD)
+#define F_TXPKT_VF_VLD    V_TXPKT_VF_VLD(1U)
+
+#define S_TXPKT_OVLAN_IDX    12
+#define M_TXPKT_OVLAN_IDX    0xF
+#define V_TXPKT_OVLAN_IDX(x) ((x) << S_TXPKT_OVLAN_IDX)
+#define G_TXPKT_OVLAN_IDX(x) (((x) >> S_TXPKT_OVLAN_IDX) & M_TXPKT_OVLAN_IDX)
+
+#define S_TXPKT_INTF    16
+#define M_TXPKT_INTF    0xF
+#define V_TXPKT_INTF(x) ((x) << S_TXPKT_INTF)
+#define G_TXPKT_INTF(x) (((x) >> S_TXPKT_INTF) & M_TXPKT_INTF)
+
+#define S_TXPKT_SPECIAL_STAT    20
+#define V_TXPKT_SPECIAL_STAT(x) ((x) << S_TXPKT_SPECIAL_STAT)
+#define F_TXPKT_SPECIAL_STAT    V_TXPKT_SPECIAL_STAT(1U)
+
+#define S_TXPKT_INS_OVLAN    21
+#define V_TXPKT_INS_OVLAN(x) ((x) << S_TXPKT_INS_OVLAN)
+#define F_TXPKT_INS_OVLAN    V_TXPKT_INS_OVLAN(1U)
+
+#define S_TXPKT_STAT_DIS    22
+#define V_TXPKT_STAT_DIS(x) ((x) << S_TXPKT_STAT_DIS)
+#define F_TXPKT_STAT_DIS    V_TXPKT_STAT_DIS(1U)
+
+#define S_TXPKT_LOOPBACK    23
+#define V_TXPKT_LOOPBACK(x) ((x) << S_TXPKT_LOOPBACK)
+#define F_TXPKT_LOOPBACK    V_TXPKT_LOOPBACK(1U)
+
+#define S_TXPKT_OPCODE    24
+#define M_TXPKT_OPCODE    0xFF
+#define V_TXPKT_OPCODE(x) ((x) << S_TXPKT_OPCODE)
+#define G_TXPKT_OPCODE(x) (((x) >> S_TXPKT_OPCODE) & M_TXPKT_OPCODE)
+
+/* cpl_tx_pkt_core.ctrl1 fields */
+#define S_TXPKT_SA_IDX    0
+#define M_TXPKT_SA_IDX    0xFFF
+#define V_TXPKT_SA_IDX(x) ((x) << S_TXPKT_SA_IDX)
+#define G_TXPKT_SA_IDX(x) (((x) >> S_TXPKT_SA_IDX) & M_TXPKT_SA_IDX)
+
+#define S_TXPKT_CSUM_END    12
+#define M_TXPKT_CSUM_END    0xFF
+#define V_TXPKT_CSUM_END(x) ((x) << S_TXPKT_CSUM_END)
+#define G_TXPKT_CSUM_END(x) (((x) >> S_TXPKT_CSUM_END) & M_TXPKT_CSUM_END)
+
+#define S_TXPKT_CSUM_START    20
+#define M_TXPKT_CSUM_START    0x3FF
+#define V_TXPKT_CSUM_START(x) ((x) << S_TXPKT_CSUM_START)
+#define G_TXPKT_CSUM_START(x) (((x) >> S_TXPKT_CSUM_START) & M_TXPKT_CSUM_START)
+
+#define S_TXPKT_IPHDR_LEN    20
+#define M_TXPKT_IPHDR_LEN    0x3FFF
+#define V_TXPKT_IPHDR_LEN(x) ((__u64)(x) << S_TXPKT_IPHDR_LEN)
+#define G_TXPKT_IPHDR_LEN(x) (((x) >> S_TXPKT_IPHDR_LEN) & M_TXPKT_IPHDR_LEN)
+
+#define S_TXPKT_CSUM_LOC    30
+#define M_TXPKT_CSUM_LOC    0x3FF
+#define V_TXPKT_CSUM_LOC(x) ((__u64)(x) << S_TXPKT_CSUM_LOC)
+#define G_TXPKT_CSUM_LOC(x) (((x) >> S_TXPKT_CSUM_LOC) & M_TXPKT_CSUM_LOC)
+
+#define S_TXPKT_ETHHDR_LEN    34
+#define M_TXPKT_ETHHDR_LEN    0x3F
+#define V_TXPKT_ETHHDR_LEN(x) ((__u64)(x) << S_TXPKT_ETHHDR_LEN)
+#define G_TXPKT_ETHHDR_LEN(x) (((x) >> S_TXPKT_ETHHDR_LEN) & M_TXPKT_ETHHDR_LEN)
+
+#define S_TXPKT_CSUM_TYPE    40
+#define M_TXPKT_CSUM_TYPE    0xF
+#define V_TXPKT_CSUM_TYPE(x) ((__u64)(x) << S_TXPKT_CSUM_TYPE)
+#define G_TXPKT_CSUM_TYPE(x) (((x) >> S_TXPKT_CSUM_TYPE) & M_TXPKT_CSUM_TYPE)
+
+#define S_TXPKT_VLAN    44
+#define M_TXPKT_VLAN    0xFFFF
+#define V_TXPKT_VLAN(x) ((__u64)(x) << S_TXPKT_VLAN)
+#define G_TXPKT_VLAN(x) (((x) >> S_TXPKT_VLAN) & M_TXPKT_VLAN)
+
+#define S_TXPKT_VLAN_VLD    60
+#define V_TXPKT_VLAN_VLD(x) ((__u64)(x) << S_TXPKT_VLAN_VLD)
+#define F_TXPKT_VLAN_VLD    V_TXPKT_VLAN_VLD(1ULL)
+
+#define S_TXPKT_IPSEC    61
+#define V_TXPKT_IPSEC(x) ((__u64)(x) << S_TXPKT_IPSEC)
+#define F_TXPKT_IPSEC    V_TXPKT_IPSEC(1ULL)
+
+#define S_TXPKT_IPCSUM_DIS    62
+#define V_TXPKT_IPCSUM_DIS(x) ((__u64)(x) << S_TXPKT_IPCSUM_DIS)
+#define F_TXPKT_IPCSUM_DIS    V_TXPKT_IPCSUM_DIS(1ULL)
+
+#define S_TXPKT_L4CSUM_DIS    63
+#define V_TXPKT_L4CSUM_DIS(x) ((__u64)(x) << S_TXPKT_L4CSUM_DIS)
+#define F_TXPKT_L4CSUM_DIS    V_TXPKT_L4CSUM_DIS(1ULL)
+
+struct cpl_tx_pkt_lso {
+	WR_HDR;
+	__be32 lso_ctrl;
+	__be16 ipid_ofst;
+	__be16 mss;
+	__be32 seqno_offset;
+	__be32 len;
+	/* encapsulated CPL (TX_PKT, TX_PKT_XT or TX_DATA) follows here */
+};
+
+/* cpl_tx_pkt_lso.lso_ctrl fields */
+#define S_LSO_TCPHDR_LEN    0
+#define M_LSO_TCPHDR_LEN    0xF
+#define V_LSO_TCPHDR_LEN(x) ((x) << S_LSO_TCPHDR_LEN)
+#define G_LSO_TCPHDR_LEN(x) (((x) >> S_LSO_TCPHDR_LEN) & M_LSO_TCPHDR_LEN)
+
+#define S_LSO_IPHDR_LEN    4
+#define M_LSO_IPHDR_LEN    0xFFF
+#define V_LSO_IPHDR_LEN(x) ((x) << S_LSO_IPHDR_LEN)
+#define G_LSO_IPHDR_LEN(x) (((x) >> S_LSO_IPHDR_LEN) & M_LSO_IPHDR_LEN)
+
+#define S_LSO_ETHHDR_LEN    16
+#define M_LSO_ETHHDR_LEN    0xF
+#define V_LSO_ETHHDR_LEN(x) ((x) << S_LSO_ETHHDR_LEN)
+#define G_LSO_ETHHDR_LEN(x) (((x) >> S_LSO_ETHHDR_LEN) & M_LSO_ETHHDR_LEN)
+
+#define S_LSO_IPV6    20
+#define V_LSO_IPV6(x) ((x) << S_LSO_IPV6)
+#define F_LSO_IPV6    V_LSO_IPV6(1U)
+
+#define S_LSO_OFLD_ENCAP    21
+#define V_LSO_OFLD_ENCAP(x) ((x) << S_LSO_OFLD_ENCAP)
+#define F_LSO_OFLD_ENCAP    V_LSO_OFLD_ENCAP(1U)
+
+#define S_LSO_LAST_SLICE    22
+#define V_LSO_LAST_SLICE(x) ((x) << S_LSO_LAST_SLICE)
+#define F_LSO_LAST_SLICE    V_LSO_LAST_SLICE(1U)
+
+#define S_LSO_FIRST_SLICE    23
+#define V_LSO_FIRST_SLICE(x) ((x) << S_LSO_FIRST_SLICE)
+#define F_LSO_FIRST_SLICE    V_LSO_FIRST_SLICE(1U)
+
+#define S_LSO_OPCODE    24
+#define M_LSO_OPCODE    0xFF
+#define V_LSO_OPCODE(x) ((x) << S_LSO_OPCODE)
+#define G_LSO_OPCODE(x) (((x) >> S_LSO_OPCODE) & M_LSO_OPCODE)
+
+/* cpl_tx_pkt_lso.mss fields */
+#define S_LSO_MSS    0
+#define M_LSO_MSS    0x3FFF
+#define V_LSO_MSS(x) ((x) << S_LSO_MSS)
+#define G_LSO_MSS(x) (((x) >> S_LSO_MSS) & M_LSO_MSS)
+
+#define S_LSO_IPID_SPLIT    15
+#define V_LSO_IPID_SPLIT(x) ((x) << S_LSO_IPID_SPLIT)
+#define F_LSO_IPID_SPLIT    V_LSO_IPID_SPLIT(1U)
+
+struct cpl_iscsi_hdr {
+	union opcode_tid ot;
+	__be16 pdu_len_ddp;
+	__be16 len;
+	__be32 seq;
+	__be16 urg;
+	__u8 rsvd;
+	__u8 status;
+};
+
+/* cpl_iscsi_hdr.pdu_len_ddp fields */
+#define S_ISCSI_PDU_LEN    0
+#define M_ISCSI_PDU_LEN    0x7FFF
+#define V_ISCSI_PDU_LEN(x) ((x) << S_ISCSI_PDU_LEN)
+#define G_ISCSI_PDU_LEN(x) (((x) >> S_ISCSI_PDU_LEN) & M_ISCSI_PDU_LEN)
+
+#define S_ISCSI_DDP    15
+#define V_ISCSI_DDP(x) ((x) << S_ISCSI_DDP)
+#define F_ISCSI_DDP    V_ISCSI_DDP(1U)
+
+struct cpl_rx_data {
+	union opcode_tid ot;
+	__be16 rsvd;
+	__be16 len;
+	__be32 seq;
+	__be16 urg;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u8 dack_mode:2;
+	__u8 psh:1;
+	__u8 heartbeat:1;
+	__u8 ddp_off:1;
+	__u8 :3;
+#else
+	__u8 :3;
+	__u8 ddp_off:1;
+	__u8 heartbeat:1;
+	__u8 psh:1;
+	__u8 dack_mode:2;
+#endif
+	__u8 status;
+};
+
+struct cpl_rx_data_ack {
+	WR_HDR;
+	union opcode_tid ot;
+	__be32 credit_dack;
+};
+
+/* cpl_rx_data_ack.ack_seq fields */
+#define S_RX_CREDITS    0
+#define M_RX_CREDITS    0x3FFFFFF
+#define V_RX_CREDITS(x) ((x) << S_RX_CREDITS)
+#define G_RX_CREDITS(x) (((x) >> S_RX_CREDITS) & M_RX_CREDITS)
+
+#define S_RX_MODULATE_TX    26
+#define V_RX_MODULATE_TX(x) ((x) << S_RX_MODULATE_TX)
+#define F_RX_MODULATE_TX    V_RX_MODULATE_TX(1U)
+
+#define S_RX_MODULATE_RX    27
+#define V_RX_MODULATE_RX(x) ((x) << S_RX_MODULATE_RX)
+#define F_RX_MODULATE_RX    V_RX_MODULATE_RX(1U)
+
+#define S_RX_FORCE_ACK    28
+#define V_RX_FORCE_ACK(x) ((x) << S_RX_FORCE_ACK)
+#define F_RX_FORCE_ACK    V_RX_FORCE_ACK(1U)
+
+#define S_RX_DACK_MODE    29
+#define M_RX_DACK_MODE    0x3
+#define V_RX_DACK_MODE(x) ((x) << S_RX_DACK_MODE)
+#define G_RX_DACK_MODE(x) (((x) >> S_RX_DACK_MODE) & M_RX_DACK_MODE)
+
+#define S_RX_DACK_CHANGE    31
+#define V_RX_DACK_CHANGE(x) ((x) << S_RX_DACK_CHANGE)
+#define F_RX_DACK_CHANGE    V_RX_DACK_CHANGE(1U)
+
+struct cpl_rx_pkt {
+	__u8 opcode;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u8 iff:4;
+	__u8 csum_calc:1;
+	__u8 ipmi_pkt:1;
+	__u8 vlan_ex:1;
+	__u8 ip_frag:1;
+#else
+	__u8 ip_frag:1;
+	__u8 vlan_ex:1;
+	__u8 ipmi_pkt:1;
+	__u8 csum_calc:1;
+	__u8 iff:4;
+#endif
+	__be16 csum;
+	__be16 vlan;
+	__be16 len;
+	__be32 l2info;
+	__be16 hdr_len;
+	__be16 err_vec;
+};
+
+/* rx_pkt.l2info fields */
+#define S_RX_ETHHDR_LEN    0
+#define M_RX_ETHHDR_LEN    0x1F
+#define V_RX_ETHHDR_LEN(x) ((x) << S_RX_ETHHDR_LEN)
+#define G_RX_ETHHDR_LEN(x) (((x) >> S_RX_ETHHDR_LEN) & M_RX_ETHHDR_LEN)
+
+#define S_RX_PKTYPE    5
+#define M_RX_PKTYPE    0x7
+#define V_RX_PKTYPE(x) ((x) << S_RX_PKTYPE)
+#define G_RX_PKTYPE(x) (((x) >> S_RX_PKTYPE) & M_RX_PKTYPE)
+
+#define S_RX_MACIDX    8
+#define M_RX_MACIDX    0x1FF
+#define V_RX_MACIDX(x) ((x) << S_RX_MACIDX)
+#define G_RX_MACIDX(x) (((x) >> S_RX_MACIDX) & M_RX_MACIDX)
+
+#define S_RX_DATYPE    18
+#define M_RX_DATYPE    0x3
+#define V_RX_DATYPE(x) ((x) << S_RX_DATYPE)
+#define G_RX_DATYPE(x) (((x) >> S_RX_DATYPE) & M_RX_DATYPE)
+
+#define S_RXF_PSH    20
+#define V_RXF_PSH(x) ((x) << S_RXF_PSH)
+#define F_RXF_PSH    V_RXF_PSH(1U)
+
+#define S_RXF_SYN    21
+#define V_RXF_SYN(x) ((x) << S_RXF_SYN)
+#define F_RXF_SYN    V_RXF_SYN(1U)
+
+#define S_RXF_UDP    22
+#define V_RXF_UDP(x) ((x) << S_RXF_UDP)
+#define F_RXF_UDP    V_RXF_UDP(1U)
+
+#define S_RXF_TCP    23
+#define V_RXF_TCP(x) ((x) << S_RXF_TCP)
+#define F_RXF_TCP    V_RXF_TCP(1U)
+
+#define S_RXF_IP    24
+#define V_RXF_IP(x) ((x) << S_RXF_IP)
+#define F_RXF_IP    V_RXF_IP(1U)
+
+#define S_RXF_IP6    25
+#define V_RXF_IP6(x) ((x) << S_RXF_IP6)
+#define F_RXF_IP6    V_RXF_IP6(1U)
+
+#define S_RXF_SYN_COOKIE    26
+#define V_RXF_SYN_COOKIE(x) ((x) << S_RXF_SYN_COOKIE)
+#define F_RXF_SYN_COOKIE    V_RXF_SYN_COOKIE(1U)
+
+#define S_RXF_FCOE    26
+#define V_RXF_FCOE(x) ((x) << S_RXF_FCOE)
+#define F_RXF_FCOE    V_RXF_FCOE(1U)
+
+#define S_RXF_LRO    27
+#define V_RXF_LRO(x) ((x) << S_RXF_LRO)
+#define F_RXF_LRO    V_RXF_LRO(1U)
+
+#define S_RX_CHAN    28
+#define M_RX_CHAN    0xF
+#define V_RX_CHAN(x) ((x) << S_RX_CHAN)
+#define G_RX_CHAN(x) (((x) >> S_RX_CHAN) & M_RX_CHAN)
+
+/* rx_pkt.hdr_len fields */
+#define S_RX_TCPHDR_LEN    0
+#define M_RX_TCPHDR_LEN    0x3F
+#define V_RX_TCPHDR_LEN(x) ((x) << S_RX_TCPHDR_LEN)
+#define G_RX_TCPHDR_LEN(x) (((x) >> S_RX_TCPHDR_LEN) & M_RX_TCPHDR_LEN)
+
+#define S_RX_IPHDR_LEN    6
+#define M_RX_IPHDR_LEN    0x3FF
+#define V_RX_IPHDR_LEN(x) ((x) << S_RX_IPHDR_LEN)
+#define G_RX_IPHDR_LEN(x) (((x) >> S_RX_IPHDR_LEN) & M_RX_IPHDR_LEN)
+
+/* rx_pkt.err_vec fields */
+#define S_RXERR_OR    0
+#define V_RXERR_OR(x) ((x) << S_RXERR_OR)
+#define F_RXERR_OR    V_RXERR_OR(1U)
+
+#define S_RXERR_MAC    1
+#define V_RXERR_MAC(x) ((x) << S_RXERR_MAC)
+#define F_RXERR_MAC    V_RXERR_MAC(1U)
+
+#define S_RXERR_IPVERS    2
+#define V_RXERR_IPVERS(x) ((x) << S_RXERR_IPVERS)
+#define F_RXERR_IPVERS    V_RXERR_IPVERS(1U)
+
+#define S_RXERR_FRAG    3
+#define V_RXERR_FRAG(x) ((x) << S_RXERR_FRAG)
+#define F_RXERR_FRAG    V_RXERR_FRAG(1U)
+
+#define S_RXERR_ATTACK    4
+#define V_RXERR_ATTACK(x) ((x) << S_RXERR_ATTACK)
+#define F_RXERR_ATTACK    V_RXERR_ATTACK(1U)
+
+#define S_RXERR_ETHHDR_LEN    5
+#define V_RXERR_ETHHDR_LEN(x) ((x) << S_RXERR_ETHHDR_LEN)
+#define F_RXERR_ETHHDR_LEN    V_RXERR_ETHHDR_LEN(1U)
+
+#define S_RXERR_IPHDR_LEN    6
+#define V_RXERR_IPHDR_LEN(x) ((x) << S_RXERR_IPHDR_LEN)
+#define F_RXERR_IPHDR_LEN    V_RXERR_IPHDR_LEN(1U)
+
+#define S_RXERR_TCPHDR_LEN    7
+#define V_RXERR_TCPHDR_LEN(x) ((x) << S_RXERR_TCPHDR_LEN)
+#define F_RXERR_TCPHDR_LEN    V_RXERR_TCPHDR_LEN(1U)
+
+#define S_RXERR_PKT_LEN    8
+#define V_RXERR_PKT_LEN(x) ((x) << S_RXERR_PKT_LEN)
+#define F_RXERR_PKT_LEN    V_RXERR_PKT_LEN(1U)
+
+#define S_RXERR_TCP_OPT    9
+#define V_RXERR_TCP_OPT(x) ((x) << S_RXERR_TCP_OPT)
+#define F_RXERR_TCP_OPT    V_RXERR_TCP_OPT(1U)
+
+#define S_RXERR_IPCSUM    12
+#define V_RXERR_IPCSUM(x) ((x) << S_RXERR_IPCSUM)
+#define F_RXERR_IPCSUM    V_RXERR_IPCSUM(1U)
+
+#define S_RXERR_CSUM    13
+#define V_RXERR_CSUM(x) ((x) << S_RXERR_CSUM)
+#define F_RXERR_CSUM    V_RXERR_CSUM(1U)
+
+#define S_RXERR_PING    14
+#define V_RXERR_PING(x) ((x) << S_RXERR_PING)
+#define F_RXERR_PING    V_RXERR_PING(1U)
+
+struct cpl_trace_pkt {
+	__u8 opcode;
+	__u8 intf;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u8 runt:4;
+	__u8 filter_hit:4;
+	__u8 :6;
+	__u8 err:1;
+	__u8 trunc:1;
+#else
+	__u8 filter_hit:4;
+	__u8 runt:4;
+	__u8 trunc:1;
+	__u8 err:1;
+	__u8 :6;
+#endif
+	__be16 rsvd;
+	__be16 len;
+	__be64 tstamp;
+};
+
+struct cpl_l2t_write_req {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 params;
+	__be16 l2t_idx;
+	__be16 vlan;
+	__u8   dst_mac[6];
+};
+
+/* cpl_l2t_write_req.params fields */
+#define S_L2T_W_INFO    2
+#define M_L2T_W_INFO    0x3F
+#define V_L2T_W_INFO(x) ((x) << S_L2T_W_INFO)
+#define G_L2T_W_INFO(x) (((x) >> S_L2T_W_INFO) & M_L2T_W_INFO)
+
+#define S_L2T_W_PORT    8
+#define M_L2T_W_PORT    0xF
+#define V_L2T_W_PORT(x) ((x) << S_L2T_W_PORT)
+#define G_L2T_W_PORT(x) (((x) >> S_L2T_W_PORT) & M_L2T_W_PORT)
+
+#define S_L2T_W_NOREPLY    15
+#define V_L2T_W_NOREPLY(x) ((x) << S_L2T_W_NOREPLY)
+#define F_L2T_W_NOREPLY    V_L2T_W_NOREPLY(1U)
+
+struct cpl_l2t_write_rpl {
+	union opcode_tid ot;
+	__u8 status;
+	__u8 rsvd[3];
+};
+
+struct cpl_rdma_terminate {
+	union opcode_tid ot;
+	__be16 rsvd;
+	__be16 len;
+};
+
+struct cpl_sge_egr_update {
+	__be32 opcode_qid;
+	__be16 cidx;
+	__be16 pidx;
+};
+
+/* cpl_sge_egr_update.ot fields */
+#define S_EGR_QID    0
+#define M_EGR_QID    0x1FFFF
+#define V_EGR_QID(x) ((x) << S_EGR_QID)
+#define G_EGR_QID(x) (((x) >> S_EGR_QID) & M_EGR_QID)
+
+struct cpl_fw4_pld {
+	u8 opcode;
+	u8 rsvd0[3];
+	u8 type;
+	u8 rsvd1;
+	__be16 len;
+	__be64 data;
+	__be64 rsvd2;
+};
+
+struct cpl_fw6_pld {
+	u8 opcode;
+	u8 rsvd[5];
+	__be16 len;
+	__be64 data[4];
+};
+
+struct cpl_fw4_msg {
+	u8 opcode;
+	u8 type;
+	__be16 rsvd0;
+	__be32 rsvd1;
+	__be64 data[2];
+};
+
+struct cpl_fw4_ack {
+	union opcode_tid ot;
+	u8 credits;
+	u8 rsvd0[2];
+	u8 seq_vld;
+	__be32 snd_nxt;
+	__be32 snd_una;
+	__be64 rsvd1;
+};
+
+struct cpl_fw6_msg {
+	u8 opcode;
+	u8 type;
+	__be16 rsvd0;
+	__be32 rsvd1;
+	__be64 data[4];
+};
+
+/* ULP_TX opcodes */
+enum {
+	ULP_TX_MEM_READ = 2,
+	ULP_TX_MEM_WRITE = 3,
+	ULP_TX_PKT = 4
+};
+
+enum {
+	ULP_TX_SC_NOOP = 0x80,
+	ULP_TX_SC_IMM  = 0x81,
+	ULP_TX_SC_DSGL = 0x82,
+	ULP_TX_SC_ISGL = 0x83
+};
+
+#define S_ULPTX_CMD    24
+#define M_ULPTX_CMD    0xFF
+#define V_ULPTX_CMD(x) ((x) << S_ULPTX_CMD)
+
+#define S_ULPTX_LEN16    0
+#define M_ULPTX_LEN16    0xFF
+#define V_ULPTX_LEN16(x) ((x) << S_ULPTX_LEN16)
+
+struct ulptx_sge_pair {
+	__be32 len[2];
+	__be64 addr[2];
+};
+
+struct ulptx_sgl {
+	__be32 cmd_nsge;
+	__be32 len0;
+	__be64 addr0;
+	struct ulptx_sge_pair sge[0];
+};
+
+struct ulptx_isge {
+	__be32 stag;
+	__be32 len;
+	__be64 target_ofst;
+};
+
+struct ulptx_isgl {
+	__be32 cmd_nisge;
+	__be32 rsvd;
+	struct ulptx_isge sge[0];
+};
+
+#define S_ULPTX_NSGE    0
+#define M_ULPTX_NSGE    0xFFFF
+#define V_ULPTX_NSGE(x) ((x) << S_ULPTX_NSGE)
+
+struct ulp_mem_io {
+	WR_HDR;
+	__be32 cmd;
+	__be32 len16;             /* command length */
+	__be32 dlen;              /* data length in 32-byte units */
+	__be32 lock_addr;
+};
+
+/* additional ulp_mem_io.cmd fields */
+#define S_ULP_MEMIO_ORDER    23
+#define V_ULP_MEMIO_ORDER(x) ((x) << S_ULP_MEMIO_ORDER)
+#define F_ULP_MEMIO_ORDER    V_ULP_MEMIO_ORDER(1U)
+
+/* ulp_mem_io.lock_addr fields */
+#define S_ULP_MEMIO_ADDR    0
+#define M_ULP_MEMIO_ADDR    0x7FFFFFF
+#define V_ULP_MEMIO_ADDR(x) ((x) << S_ULP_MEMIO_ADDR)
+
+#define S_ULP_MEMIO_LOCK    31
+#define V_ULP_MEMIO_LOCK(x) ((x) << S_ULP_MEMIO_LOCK)
+#define F_ULP_MEMIO_LOCK    V_ULP_MEMIO_LOCK(1U)
+
+/* ulp_mem_io.dlen fields */
+#define S_ULP_MEMIO_DATA_LEN    0
+#define M_ULP_MEMIO_DATA_LEN    0x1F
+#define V_ULP_MEMIO_DATA_LEN(x) ((x) << S_ULP_MEMIO_DATA_LEN)
+
+struct ulp_txpkt {
+	__be32 cmd_dest;
+	__be32 len;
+};
+
+/* ulp_txpkt.cmd_dest fields */
+#define S_ULP_TXPKT_DEST    16
+#define M_ULP_TXPKT_DEST    0x3
+#define V_ULP_TXPKT_DEST(x) ((x) << S_ULP_TXPKT_DEST)
+
+#endif  /* __T4_MSG_H */
diff --git a/drivers/net/cxgb4/t4_regs.h b/drivers/net/cxgb4/t4_regs.h
new file mode 100644
index 0000000..27d288f
--- /dev/null
+++ b/drivers/net/cxgb4/t4_regs.h
@@ -0,0 +1,2109 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2010 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __T4_REGS_H
+#define __T4_REGS_H
+
+#define MYPF_BASE 0x1b000
+#define MYPF_REG(reg_addr) (MYPF_BASE + (reg_addr))
+
+#define PF0_BASE 0x1e000
+#define PF0_REG(reg_addr) (PF0_BASE + (reg_addr))
+
+#define PF_STRIDE 0x400
+#define PF_BASE(idx) (PF0_BASE + (idx) * PF_STRIDE)
+#define PF_REG(idx, reg) (PF_BASE(idx) + (reg))
+
+#define MYPORT_BASE 0x1c000
+#define MYPORT_REG(reg_addr) (MYPORT_BASE + (reg_addr))
+
+#define PORT0_BASE 0x20000
+#define PORT0_REG(reg_addr) (PORT0_BASE + (reg_addr))
+
+#define PORT_STRIDE 0x2000
+#define PORT_BASE(idx) (PORT0_BASE + (idx) * PORT_STRIDE)
+#define PORT_REG(idx, reg) (PORT_BASE(idx) + (reg))
+
+#define EDC_STRIDE (EDC_1_BASE_ADDR - EDC_0_BASE_ADDR)
+#define EDC_REG(reg, idx) (reg + EDC_STRIDE * idx)
+
+#define PCIE_MEM_ACCESS_REG(reg_addr, idx) ((reg_addr) + (idx) * 8)
+#define NUM_PCIE_MEM_ACCESS_INSTANCES 8
+
+#define PCIE_MAILBOX_REG(reg_addr, idx) ((reg_addr) + (idx) * 8)
+#define NUM_PCIE_MAILBOX_INSTANCES 1
+
+#define MC_BIST_STATUS_REG(reg_addr, idx) ((reg_addr) + (idx) * 4)
+#define NUM_MC_BIST_STATUS_INSTANCES 18
+
+#define EDC_BIST_STATUS_REG(reg_addr, idx) ((reg_addr) + (idx) * 4)
+#define NUM_EDC_BIST_STATUS_INSTANCES 18
+
+#define CIM_PF_MAILBOX_DATA(idx) (A_CIM_PF_MAILBOX_DATA + (idx) * 4)
+#define NUM_CIM_PF_MAILBOX_DATA_INSTANCES 16
+
+#define MPS_TRC_FILTER_MATCH_CTL_A(idx) (A_MPS_TRC_FILTER_MATCH_CTL_A + (idx) * 4)
+#define NUM_MPS_TRC_FILTER_MATCH_CTL_A_INSTANCES 4
+
+#define MPS_TRC_FILTER_MATCH_CTL_B(idx) (A_MPS_TRC_FILTER_MATCH_CTL_B + (idx) * 4)
+#define NUM_MPS_TRC_FILTER_MATCH_CTL_B_INSTANCES 4
+
+#define MPS_TRC_FILTER0_MATCH(idx) (A_MPS_TRC_FILTER0_MATCH + (idx) * 4)
+#define NUM_MPS_TRC_FILTER0_MATCH_INSTANCES 28
+
+#define MPS_TRC_FILTER0_DONT_CARE(idx) (A_MPS_TRC_FILTER0_DONT_CARE + (idx) * 4)
+#define NUM_MPS_TRC_FILTER0_DONT_CARE_INSTANCES 28
+
+#define MPS_TRC_FILTER1_MATCH(idx) (A_MPS_TRC_FILTER1_MATCH + (idx) * 4)
+#define NUM_MPS_TRC_FILTER1_MATCH_INSTANCES 28
+
+/*
+ * The macros below define register addresses and fields within registers.
+ * The first letter of each macro identifies what the macro is about as follows:
+ *
+ * A_* is a register's Address
+ * S_* is the Start bit position of a field in a register
+ * M_* is the Mask for a register field
+ * V_* turns its argument into the Value of a field (appropriately shifted)
+ * F_* is the on value for 1-bit fields, i.e., Flags
+ * E_* is a symbolic constant for a field value, i.e., an Enum
+ * G_* Gets (extracts) a field's value from a register value
+ */
+
+/* registers for module SGE */
+#define A_SGE_PF_KDOORBELL 0x0
+
+#define S_QID    15
+#define M_QID    0x1ffffU
+#define V_QID(x) ((x) << S_QID)
+
+#define S_DBPRIO    14
+#define V_DBPRIO(x) ((x) << S_DBPRIO)
+#define F_DBPRIO    V_DBPRIO(1U)
+
+#define S_PIDX    0
+#define M_PIDX    0x3fffU
+#define V_PIDX(x) ((x) << S_PIDX)
+
+#define A_SGE_PF_GTS 0x4
+
+#define S_INGRESSQID    16
+#define M_INGRESSQID    0xffffU
+#define V_INGRESSQID(x) ((x) << S_INGRESSQID)
+
+#define S_TIMERREG    13
+#define M_TIMERREG    0x7U
+#define V_TIMERREG(x) ((x) << S_TIMERREG)
+
+#define E_TIMERIDX_NONE     6
+#define E_TIMERIDX_CRED_UPD 7
+
+#define S_SEINTARM    12
+#define V_SEINTARM(x) ((x) << S_SEINTARM)
+#define F_SEINTARM    V_SEINTARM(1U)
+
+#define S_CIDXINC    0
+#define M_CIDXINC    0xfffU
+#define V_CIDXINC(x) ((x) << S_CIDXINC)
+
+#define A_SGE_CONTROL 0x1008
+
+#define S_IGRALLCPLTOFL    31
+#define V_IGRALLCPLTOFL(x) ((x) << S_IGRALLCPLTOFL)
+#define F_IGRALLCPLTOFL    V_IGRALLCPLTOFL(1U)
+
+#define S_FLSPLITMIN    22
+#define M_FLSPLITMIN    0x1ffU
+#define V_FLSPLITMIN(x) ((x) << S_FLSPLITMIN)
+#define G_FLSPLITMIN(x) (((x) >> S_FLSPLITMIN) & M_FLSPLITMIN)
+
+#define S_FLSPLITMODE    20
+#define M_FLSPLITMODE    0x3U
+#define V_FLSPLITMODE(x) ((x) << S_FLSPLITMODE)
+#define G_FLSPLITMODE(x) (((x) >> S_FLSPLITMODE) & M_FLSPLITMODE)
+
+#define S_DCASYSTYPE    19
+#define V_DCASYSTYPE(x) ((x) << S_DCASYSTYPE)
+#define F_DCASYSTYPE    V_DCASYSTYPE(1U)
+
+#define S_RXPKTCPLMODE    18
+#define V_RXPKTCPLMODE(x) ((x) << S_RXPKTCPLMODE)
+#define F_RXPKTCPLMODE    V_RXPKTCPLMODE(1U)
+
+#define S_EGRSTATUSPAGESIZE    17
+#define V_EGRSTATUSPAGESIZE(x) ((x) << S_EGRSTATUSPAGESIZE)
+#define F_EGRSTATUSPAGESIZE    V_EGRSTATUSPAGESIZE(1U)
+
+#define S_INGHINTENABLE1    15
+#define V_INGHINTENABLE1(x) ((x) << S_INGHINTENABLE1)
+#define F_INGHINTENABLE1    V_INGHINTENABLE1(1U)
+
+#define S_INGHINTENABLE0    14
+#define V_INGHINTENABLE0(x) ((x) << S_INGHINTENABLE0)
+#define F_INGHINTENABLE0    V_INGHINTENABLE0(1U)
+
+#define S_INGINTCOMPAREIDX    13
+#define V_INGINTCOMPAREIDX(x) ((x) << S_INGINTCOMPAREIDX)
+#define F_INGINTCOMPAREIDX    V_INGINTCOMPAREIDX(1U)
+
+#define S_PKTSHIFT    10
+#define M_PKTSHIFT    0x7U
+#define V_PKTSHIFT(x) ((x) << S_PKTSHIFT)
+#define G_PKTSHIFT(x) (((x) >> S_PKTSHIFT) & M_PKTSHIFT)
+
+#define S_INGPCIEBOUNDARY    7
+#define M_INGPCIEBOUNDARY    0x7U
+#define V_INGPCIEBOUNDARY(x) ((x) << S_INGPCIEBOUNDARY)
+#define G_INGPCIEBOUNDARY(x) (((x) >> S_INGPCIEBOUNDARY) & M_INGPCIEBOUNDARY)
+
+#define S_INGPADBOUNDARY    4
+#define M_INGPADBOUNDARY    0x7U
+#define V_INGPADBOUNDARY(x) ((x) << S_INGPADBOUNDARY)
+#define G_INGPADBOUNDARY(x) (((x) >> S_INGPADBOUNDARY) & M_INGPADBOUNDARY)
+
+#define S_EGRPCIEBOUNDARY    1
+#define M_EGRPCIEBOUNDARY    0x7U
+#define V_EGRPCIEBOUNDARY(x) ((x) << S_EGRPCIEBOUNDARY)
+#define G_EGRPCIEBOUNDARY(x) (((x) >> S_EGRPCIEBOUNDARY) & M_EGRPCIEBOUNDARY)
+
+#define S_GLOBALENABLE    0
+#define V_GLOBALENABLE(x) ((x) << S_GLOBALENABLE)
+#define F_GLOBALENABLE    V_GLOBALENABLE(1U)
+
+#define A_SGE_HOST_PAGE_SIZE 0x100c
+
+#define S_HOSTPAGESIZEPF7    28
+#define M_HOSTPAGESIZEPF7    0xfU
+#define V_HOSTPAGESIZEPF7(x) ((x) << S_HOSTPAGESIZEPF7)
+#define G_HOSTPAGESIZEPF7(x) (((x) >> S_HOSTPAGESIZEPF7) & M_HOSTPAGESIZEPF7)
+
+#define S_HOSTPAGESIZEPF6    24
+#define M_HOSTPAGESIZEPF6    0xfU
+#define V_HOSTPAGESIZEPF6(x) ((x) << S_HOSTPAGESIZEPF6)
+#define G_HOSTPAGESIZEPF6(x) (((x) >> S_HOSTPAGESIZEPF6) & M_HOSTPAGESIZEPF6)
+
+#define S_HOSTPAGESIZEPF5    20
+#define M_HOSTPAGESIZEPF5    0xfU
+#define V_HOSTPAGESIZEPF5(x) ((x) << S_HOSTPAGESIZEPF5)
+#define G_HOSTPAGESIZEPF5(x) (((x) >> S_HOSTPAGESIZEPF5) & M_HOSTPAGESIZEPF5)
+
+#define S_HOSTPAGESIZEPF4    16
+#define M_HOSTPAGESIZEPF4    0xfU
+#define V_HOSTPAGESIZEPF4(x) ((x) << S_HOSTPAGESIZEPF4)
+#define G_HOSTPAGESIZEPF4(x) (((x) >> S_HOSTPAGESIZEPF4) & M_HOSTPAGESIZEPF4)
+
+#define S_HOSTPAGESIZEPF3    12
+#define M_HOSTPAGESIZEPF3    0xfU
+#define V_HOSTPAGESIZEPF3(x) ((x) << S_HOSTPAGESIZEPF3)
+#define G_HOSTPAGESIZEPF3(x) (((x) >> S_HOSTPAGESIZEPF3) & M_HOSTPAGESIZEPF3)
+
+#define S_HOSTPAGESIZEPF2    8
+#define M_HOSTPAGESIZEPF2    0xfU
+#define V_HOSTPAGESIZEPF2(x) ((x) << S_HOSTPAGESIZEPF2)
+#define G_HOSTPAGESIZEPF2(x) (((x) >> S_HOSTPAGESIZEPF2) & M_HOSTPAGESIZEPF2)
+
+#define S_HOSTPAGESIZEPF1    4
+#define M_HOSTPAGESIZEPF1    0xfU
+#define V_HOSTPAGESIZEPF1(x) ((x) << S_HOSTPAGESIZEPF1)
+#define G_HOSTPAGESIZEPF1(x) (((x) >> S_HOSTPAGESIZEPF1) & M_HOSTPAGESIZEPF1)
+
+#define S_HOSTPAGESIZEPF0    0
+#define M_HOSTPAGESIZEPF0    0xfU
+#define V_HOSTPAGESIZEPF0(x) ((x) << S_HOSTPAGESIZEPF0)
+#define G_HOSTPAGESIZEPF0(x) (((x) >> S_HOSTPAGESIZEPF0) & M_HOSTPAGESIZEPF0)
+
+#define A_SGE_EGRESS_QUEUES_PER_PAGE_PF 0x1010
+
+#define S_QUEUESPERPAGEPF7    28
+#define M_QUEUESPERPAGEPF7    0xfU
+#define V_QUEUESPERPAGEPF7(x) ((x) << S_QUEUESPERPAGEPF7)
+#define G_QUEUESPERPAGEPF7(x) (((x) >> S_QUEUESPERPAGEPF7) & M_QUEUESPERPAGEPF7)
+
+#define S_QUEUESPERPAGEPF6    24
+#define M_QUEUESPERPAGEPF6    0xfU
+#define V_QUEUESPERPAGEPF6(x) ((x) << S_QUEUESPERPAGEPF6)
+#define G_QUEUESPERPAGEPF6(x) (((x) >> S_QUEUESPERPAGEPF6) & M_QUEUESPERPAGEPF6)
+
+#define S_QUEUESPERPAGEPF5    20
+#define M_QUEUESPERPAGEPF5    0xfU
+#define V_QUEUESPERPAGEPF5(x) ((x) << S_QUEUESPERPAGEPF5)
+#define G_QUEUESPERPAGEPF5(x) (((x) >> S_QUEUESPERPAGEPF5) & M_QUEUESPERPAGEPF5)
+
+#define S_QUEUESPERPAGEPF4    16
+#define M_QUEUESPERPAGEPF4    0xfU
+#define V_QUEUESPERPAGEPF4(x) ((x) << S_QUEUESPERPAGEPF4)
+#define G_QUEUESPERPAGEPF4(x) (((x) >> S_QUEUESPERPAGEPF4) & M_QUEUESPERPAGEPF4)
+
+#define S_QUEUESPERPAGEPF3    12
+#define M_QUEUESPERPAGEPF3    0xfU
+#define V_QUEUESPERPAGEPF3(x) ((x) << S_QUEUESPERPAGEPF3)
+#define G_QUEUESPERPAGEPF3(x) (((x) >> S_QUEUESPERPAGEPF3) & M_QUEUESPERPAGEPF3)
+
+#define S_QUEUESPERPAGEPF2    8
+#define M_QUEUESPERPAGEPF2    0xfU
+#define V_QUEUESPERPAGEPF2(x) ((x) << S_QUEUESPERPAGEPF2)
+#define G_QUEUESPERPAGEPF2(x) (((x) >> S_QUEUESPERPAGEPF2) & M_QUEUESPERPAGEPF2)
+
+#define S_QUEUESPERPAGEPF1    4
+#define M_QUEUESPERPAGEPF1    0xfU
+#define V_QUEUESPERPAGEPF1(x) ((x) << S_QUEUESPERPAGEPF1)
+#define G_QUEUESPERPAGEPF1(x) (((x) >> S_QUEUESPERPAGEPF1) & M_QUEUESPERPAGEPF1)
+
+#define S_QUEUESPERPAGEPF0    0
+#define M_QUEUESPERPAGEPF0    0xfU
+#define V_QUEUESPERPAGEPF0(x) ((x) << S_QUEUESPERPAGEPF0)
+#define G_QUEUESPERPAGEPF0(x) (((x) >> S_QUEUESPERPAGEPF0) & M_QUEUESPERPAGEPF0)
+
+#define A_SGE_INT_CAUSE1 0x1024
+#define A_SGE_INT_CAUSE2 0x1030
+#define A_SGE_INT_CAUSE3 0x103c
+
+#define S_ERR_FLM_DBP    31
+#define V_ERR_FLM_DBP(x) ((x) << S_ERR_FLM_DBP)
+#define F_ERR_FLM_DBP    V_ERR_FLM_DBP(1U)
+
+#define S_ERR_FLM_IDMA1    30
+#define V_ERR_FLM_IDMA1(x) ((x) << S_ERR_FLM_IDMA1)
+#define F_ERR_FLM_IDMA1    V_ERR_FLM_IDMA1(1U)
+
+#define S_ERR_FLM_IDMA0    29
+#define V_ERR_FLM_IDMA0(x) ((x) << S_ERR_FLM_IDMA0)
+#define F_ERR_FLM_IDMA0    V_ERR_FLM_IDMA0(1U)
+
+#define S_ERR_FLM_HINT    28
+#define V_ERR_FLM_HINT(x) ((x) << S_ERR_FLM_HINT)
+#define F_ERR_FLM_HINT    V_ERR_FLM_HINT(1U)
+
+#define S_ERR_PCIE_ERROR3    27
+#define V_ERR_PCIE_ERROR3(x) ((x) << S_ERR_PCIE_ERROR3)
+#define F_ERR_PCIE_ERROR3    V_ERR_PCIE_ERROR3(1U)
+
+#define S_ERR_PCIE_ERROR2    26
+#define V_ERR_PCIE_ERROR2(x) ((x) << S_ERR_PCIE_ERROR2)
+#define F_ERR_PCIE_ERROR2    V_ERR_PCIE_ERROR2(1U)
+
+#define S_ERR_PCIE_ERROR1    25
+#define V_ERR_PCIE_ERROR1(x) ((x) << S_ERR_PCIE_ERROR1)
+#define F_ERR_PCIE_ERROR1    V_ERR_PCIE_ERROR1(1U)
+
+#define S_ERR_PCIE_ERROR0    24
+#define V_ERR_PCIE_ERROR0(x) ((x) << S_ERR_PCIE_ERROR0)
+#define F_ERR_PCIE_ERROR0    V_ERR_PCIE_ERROR0(1U)
+
+#define S_ERR_TIMER_ABOVE_MAX_QID    23
+#define V_ERR_TIMER_ABOVE_MAX_QID(x) ((x) << S_ERR_TIMER_ABOVE_MAX_QID)
+#define F_ERR_TIMER_ABOVE_MAX_QID    V_ERR_TIMER_ABOVE_MAX_QID(1U)
+
+#define S_ERR_CPL_EXCEED_IQE_SIZE    22
+#define V_ERR_CPL_EXCEED_IQE_SIZE(x) ((x) << S_ERR_CPL_EXCEED_IQE_SIZE)
+#define F_ERR_CPL_EXCEED_IQE_SIZE    V_ERR_CPL_EXCEED_IQE_SIZE(1U)
+
+#define S_ERR_INVALID_CIDX_INC    21
+#define V_ERR_INVALID_CIDX_INC(x) ((x) << S_ERR_INVALID_CIDX_INC)
+#define F_ERR_INVALID_CIDX_INC    V_ERR_INVALID_CIDX_INC(1U)
+
+#define S_ERR_ITP_TIME_PAUSED    20
+#define V_ERR_ITP_TIME_PAUSED(x) ((x) << S_ERR_ITP_TIME_PAUSED)
+#define F_ERR_ITP_TIME_PAUSED    V_ERR_ITP_TIME_PAUSED(1U)
+
+#define S_ERR_CPL_OPCODE_0    19
+#define V_ERR_CPL_OPCODE_0(x) ((x) << S_ERR_CPL_OPCODE_0)
+#define F_ERR_CPL_OPCODE_0    V_ERR_CPL_OPCODE_0(1U)
+
+#define S_ERR_DROPPED_DB    18
+#define V_ERR_DROPPED_DB(x) ((x) << S_ERR_DROPPED_DB)
+#define F_ERR_DROPPED_DB    V_ERR_DROPPED_DB(1U)
+
+#define S_ERR_DATA_CPL_ON_HIGH_QID1    17
+#define V_ERR_DATA_CPL_ON_HIGH_QID1(x) ((x) << S_ERR_DATA_CPL_ON_HIGH_QID1)
+#define F_ERR_DATA_CPL_ON_HIGH_QID1    V_ERR_DATA_CPL_ON_HIGH_QID1(1U)
+
+#define S_ERR_DATA_CPL_ON_HIGH_QID0    16
+#define V_ERR_DATA_CPL_ON_HIGH_QID0(x) ((x) << S_ERR_DATA_CPL_ON_HIGH_QID0)
+#define F_ERR_DATA_CPL_ON_HIGH_QID0    V_ERR_DATA_CPL_ON_HIGH_QID0(1U)
+
+#define S_ERR_BAD_DB_PIDX3    15
+#define V_ERR_BAD_DB_PIDX3(x) ((x) << S_ERR_BAD_DB_PIDX3)
+#define F_ERR_BAD_DB_PIDX3    V_ERR_BAD_DB_PIDX3(1U)
+
+#define S_ERR_BAD_DB_PIDX2    14
+#define V_ERR_BAD_DB_PIDX2(x) ((x) << S_ERR_BAD_DB_PIDX2)
+#define F_ERR_BAD_DB_PIDX2    V_ERR_BAD_DB_PIDX2(1U)
+
+#define S_ERR_BAD_DB_PIDX1    13
+#define V_ERR_BAD_DB_PIDX1(x) ((x) << S_ERR_BAD_DB_PIDX1)
+#define F_ERR_BAD_DB_PIDX1    V_ERR_BAD_DB_PIDX1(1U)
+
+#define S_ERR_BAD_DB_PIDX0    12
+#define V_ERR_BAD_DB_PIDX0(x) ((x) << S_ERR_BAD_DB_PIDX0)
+#define F_ERR_BAD_DB_PIDX0    V_ERR_BAD_DB_PIDX0(1U)
+
+#define S_ERR_ING_CTXT_PRIO    10
+#define V_ERR_ING_CTXT_PRIO(x) ((x) << S_ERR_ING_CTXT_PRIO)
+#define F_ERR_ING_CTXT_PRIO    V_ERR_ING_CTXT_PRIO(1U)
+
+#define S_ERR_EGR_CTXT_PRIO    9
+#define V_ERR_EGR_CTXT_PRIO(x) ((x) << S_ERR_EGR_CTXT_PRIO)
+#define F_ERR_EGR_CTXT_PRIO    V_ERR_EGR_CTXT_PRIO(1U)
+
+#define S_DBFIFO_HP_INT    8
+#define V_DBFIFO_HP_INT(x) ((x) << S_DBFIFO_HP_INT)
+#define F_DBFIFO_HP_INT    V_DBFIFO_HP_INT(1U)
+
+#define S_DBFIFO_LP_INT    7
+#define V_DBFIFO_LP_INT(x) ((x) << S_DBFIFO_LP_INT)
+#define F_DBFIFO_LP_INT    V_DBFIFO_LP_INT(1U)
+
+#define S_INGRESS_SIZE_ERR    5
+#define V_INGRESS_SIZE_ERR(x) ((x) << S_INGRESS_SIZE_ERR)
+#define F_INGRESS_SIZE_ERR    V_INGRESS_SIZE_ERR(1U)
+
+#define S_EGRESS_SIZE_ERR    4
+#define V_EGRESS_SIZE_ERR(x) ((x) << S_EGRESS_SIZE_ERR)
+#define F_EGRESS_SIZE_ERR    V_EGRESS_SIZE_ERR(1U)
+
+#define A_SGE_INT_ENABLE3 0x1040
+#define A_SGE_FL_BUFFER_SIZE0 0x1044
+
+#define S_SIZE    4
+#define M_SIZE    0xfffffffU
+#define V_SIZE(x) ((x) << S_SIZE)
+#define G_SIZE(x) (((x) >> S_SIZE) & M_SIZE)
+
+#define A_SGE_FL_BUFFER_SIZE1 0x1048
+#define A_SGE_INGRESS_RX_THRESHOLD 0x10a0
+
+#define S_THRESHOLD_0    24
+#define M_THRESHOLD_0    0x3fU
+#define V_THRESHOLD_0(x) ((x) << S_THRESHOLD_0)
+#define G_THRESHOLD_0(x) (((x) >> S_THRESHOLD_0) & M_THRESHOLD_0)
+
+#define S_THRESHOLD_1    16
+#define M_THRESHOLD_1    0x3fU
+#define V_THRESHOLD_1(x) ((x) << S_THRESHOLD_1)
+#define G_THRESHOLD_1(x) (((x) >> S_THRESHOLD_1) & M_THRESHOLD_1)
+
+#define S_THRESHOLD_2    8
+#define M_THRESHOLD_2    0x3fU
+#define V_THRESHOLD_2(x) ((x) << S_THRESHOLD_2)
+#define G_THRESHOLD_2(x) (((x) >> S_THRESHOLD_2) & M_THRESHOLD_2)
+
+#define S_THRESHOLD_3    0
+#define M_THRESHOLD_3    0x3fU
+#define V_THRESHOLD_3(x) ((x) << S_THRESHOLD_3)
+#define G_THRESHOLD_3(x) (((x) >> S_THRESHOLD_3) & M_THRESHOLD_3)
+
+#define A_SGE_TIMER_VALUE_0_AND_1 0x10b8
+
+#define S_TIMERVALUE0    16
+#define M_TIMERVALUE0    0xffffU
+#define V_TIMERVALUE0(x) ((x) << S_TIMERVALUE0)
+#define G_TIMERVALUE0(x) (((x) >> S_TIMERVALUE0) & M_TIMERVALUE0)
+
+#define S_TIMERVALUE1    0
+#define M_TIMERVALUE1    0xffffU
+#define V_TIMERVALUE1(x) ((x) << S_TIMERVALUE1)
+#define G_TIMERVALUE1(x) (((x) >> S_TIMERVALUE1) & M_TIMERVALUE1)
+
+#define A_SGE_TIMER_VALUE_2_AND_3 0x10bc
+
+#define S_TIMERVALUE2    16
+#define M_TIMERVALUE2    0xffffU
+#define V_TIMERVALUE2(x) ((x) << S_TIMERVALUE2)
+#define G_TIMERVALUE2(x) (((x) >> S_TIMERVALUE2) & M_TIMERVALUE2)
+
+#define S_TIMERVALUE3    0
+#define M_TIMERVALUE3    0xffffU
+#define V_TIMERVALUE3(x) ((x) << S_TIMERVALUE3)
+#define G_TIMERVALUE3(x) (((x) >> S_TIMERVALUE3) & M_TIMERVALUE3)
+
+#define A_SGE_TIMER_VALUE_4_AND_5 0x10c0
+
+#define S_TIMERVALUE4    16
+#define M_TIMERVALUE4    0xffffU
+#define V_TIMERVALUE4(x) ((x) << S_TIMERVALUE4)
+#define G_TIMERVALUE4(x) (((x) >> S_TIMERVALUE4) & M_TIMERVALUE4)
+
+#define S_TIMERVALUE5    0
+#define M_TIMERVALUE5    0xffffU
+#define V_TIMERVALUE5(x) ((x) << S_TIMERVALUE5)
+#define G_TIMERVALUE5(x) (((x) >> S_TIMERVALUE5) & M_TIMERVALUE5)
+
+#define A_SGE_DEBUG_INDEX 0x10cc
+#define A_SGE_DEBUG_DATA_HIGH 0x10d0
+#define A_SGE_DEBUG_DATA_LOW 0x10d4
+#define A_SGE_INGRESS_QUEUES_PER_PAGE_PF 0x10f4
+#define A_SGE_CTXT_CMD 0x11fc
+
+#define S_BUSY    31
+#define V_BUSY(x) ((x) << S_BUSY)
+#define F_BUSY    V_BUSY(1U)
+
+/* registers for module PCIE */
+#define A_PCIE_PF_CLI 0x44
+#define A_PCIE_INT_CAUSE 0x3004
+
+#define S_NONFATALERR    30
+#define V_NONFATALERR(x) ((x) << S_NONFATALERR)
+#define F_NONFATALERR    V_NONFATALERR(1U)
+
+#define S_UNXSPLCPLERR    29
+#define V_UNXSPLCPLERR(x) ((x) << S_UNXSPLCPLERR)
+#define F_UNXSPLCPLERR    V_UNXSPLCPLERR(1U)
+
+#define S_PCIEPINT    28
+#define V_PCIEPINT(x) ((x) << S_PCIEPINT)
+#define F_PCIEPINT    V_PCIEPINT(1U)
+
+#define S_PCIESINT    27
+#define V_PCIESINT(x) ((x) << S_PCIESINT)
+#define F_PCIESINT    V_PCIESINT(1U)
+
+#define S_RPLPERR    26
+#define V_RPLPERR(x) ((x) << S_RPLPERR)
+#define F_RPLPERR    V_RPLPERR(1U)
+
+#define S_RXWRPERR    25
+#define V_RXWRPERR(x) ((x) << S_RXWRPERR)
+#define F_RXWRPERR    V_RXWRPERR(1U)
+
+#define S_RXCPLPERR    24
+#define V_RXCPLPERR(x) ((x) << S_RXCPLPERR)
+#define F_RXCPLPERR    V_RXCPLPERR(1U)
+
+#define S_PIOTAGPERR    23
+#define V_PIOTAGPERR(x) ((x) << S_PIOTAGPERR)
+#define F_PIOTAGPERR    V_PIOTAGPERR(1U)
+
+#define S_MATAGPERR    22
+#define V_MATAGPERR(x) ((x) << S_MATAGPERR)
+#define F_MATAGPERR    V_MATAGPERR(1U)
+
+#define S_INTXCLRPERR    21
+#define V_INTXCLRPERR(x) ((x) << S_INTXCLRPERR)
+#define F_INTXCLRPERR    V_INTXCLRPERR(1U)
+
+#define S_FIDPERR    20
+#define V_FIDPERR(x) ((x) << S_FIDPERR)
+#define F_FIDPERR    V_FIDPERR(1U)
+
+#define S_CFGSNPPERR    19
+#define V_CFGSNPPERR(x) ((x) << S_CFGSNPPERR)
+#define F_CFGSNPPERR    V_CFGSNPPERR(1U)
+
+#define S_HRSPPERR    18
+#define V_HRSPPERR(x) ((x) << S_HRSPPERR)
+#define F_HRSPPERR    V_HRSPPERR(1U)
+
+#define S_HREQPERR    17
+#define V_HREQPERR(x) ((x) << S_HREQPERR)
+#define F_HREQPERR    V_HREQPERR(1U)
+
+#define S_HCNTPERR    16
+#define V_HCNTPERR(x) ((x) << S_HCNTPERR)
+#define F_HCNTPERR    V_HCNTPERR(1U)
+
+#define S_DRSPPERR    15
+#define V_DRSPPERR(x) ((x) << S_DRSPPERR)
+#define F_DRSPPERR    V_DRSPPERR(1U)
+
+#define S_DREQPERR    14
+#define V_DREQPERR(x) ((x) << S_DREQPERR)
+#define F_DREQPERR    V_DREQPERR(1U)
+
+#define S_DCNTPERR    13
+#define V_DCNTPERR(x) ((x) << S_DCNTPERR)
+#define F_DCNTPERR    V_DCNTPERR(1U)
+
+#define S_CRSPPERR    12
+#define V_CRSPPERR(x) ((x) << S_CRSPPERR)
+#define F_CRSPPERR    V_CRSPPERR(1U)
+
+#define S_CREQPERR    11
+#define V_CREQPERR(x) ((x) << S_CREQPERR)
+#define F_CREQPERR    V_CREQPERR(1U)
+
+#define S_CCNTPERR    10
+#define V_CCNTPERR(x) ((x) << S_CCNTPERR)
+#define F_CCNTPERR    V_CCNTPERR(1U)
+
+#define S_TARTAGPERR    9
+#define V_TARTAGPERR(x) ((x) << S_TARTAGPERR)
+#define F_TARTAGPERR    V_TARTAGPERR(1U)
+
+#define S_PIOREQPERR    8
+#define V_PIOREQPERR(x) ((x) << S_PIOREQPERR)
+#define F_PIOREQPERR    V_PIOREQPERR(1U)
+
+#define S_PIOCPLPERR    7
+#define V_PIOCPLPERR(x) ((x) << S_PIOCPLPERR)
+#define F_PIOCPLPERR    V_PIOCPLPERR(1U)
+
+#define S_MSIXDIPERR    6
+#define V_MSIXDIPERR(x) ((x) << S_MSIXDIPERR)
+#define F_MSIXDIPERR    V_MSIXDIPERR(1U)
+
+#define S_MSIXDATAPERR    5
+#define V_MSIXDATAPERR(x) ((x) << S_MSIXDATAPERR)
+#define F_MSIXDATAPERR    V_MSIXDATAPERR(1U)
+
+#define S_MSIXADDRHPERR    4
+#define V_MSIXADDRHPERR(x) ((x) << S_MSIXADDRHPERR)
+#define F_MSIXADDRHPERR    V_MSIXADDRHPERR(1U)
+
+#define S_MSIXADDRLPERR    3
+#define V_MSIXADDRLPERR(x) ((x) << S_MSIXADDRLPERR)
+#define F_MSIXADDRLPERR    V_MSIXADDRLPERR(1U)
+
+#define S_MSIDATAPERR    2
+#define V_MSIDATAPERR(x) ((x) << S_MSIDATAPERR)
+#define F_MSIDATAPERR    V_MSIDATAPERR(1U)
+
+#define S_MSIADDRHPERR    1
+#define V_MSIADDRHPERR(x) ((x) << S_MSIADDRHPERR)
+#define F_MSIADDRHPERR    V_MSIADDRHPERR(1U)
+
+#define S_MSIADDRLPERR    0
+#define V_MSIADDRLPERR(x) ((x) << S_MSIADDRLPERR)
+#define F_MSIADDRLPERR    V_MSIADDRLPERR(1U)
+
+#define A_PCIE_NONFAT_ERR 0x3010
+#define A_PCIE_MEM_ACCESS_BASE_WIN 0x3068
+
+#define S_PCIEOFST    10
+#define M_PCIEOFST    0x3fffffU
+#define V_PCIEOFST(x) ((x) << S_PCIEOFST)
+#define G_PCIEOFST(x) (((x) >> S_PCIEOFST) & M_PCIEOFST)
+
+#define S_BIR    8
+#define M_BIR    0x3U
+#define V_BIR(x) ((x) << S_BIR)
+#define G_BIR(x) (((x) >> S_BIR) & M_BIR)
+
+#define S_WINDOW    0
+#define M_WINDOW    0xffU
+#define V_WINDOW(x) ((x) << S_WINDOW)
+#define G_WINDOW(x) (((x) >> S_WINDOW) & M_WINDOW)
+
+#define A_PCIE_CORE_UTL_SYSTEM_BUS_AGENT_STATUS 0x5908
+
+#define S_RNPP    31
+#define V_RNPP(x) ((x) << S_RNPP)
+#define F_RNPP    V_RNPP(1U)
+
+#define S_RPCP    29
+#define V_RPCP(x) ((x) << S_RPCP)
+#define F_RPCP    V_RPCP(1U)
+
+#define S_RCIP    27
+#define V_RCIP(x) ((x) << S_RCIP)
+#define F_RCIP    V_RCIP(1U)
+
+#define S_RCCP    26
+#define V_RCCP(x) ((x) << S_RCCP)
+#define F_RCCP    V_RCCP(1U)
+
+#define S_RFTP    23
+#define V_RFTP(x) ((x) << S_RFTP)
+#define F_RFTP    V_RFTP(1U)
+
+#define S_PTRP    20
+#define V_PTRP(x) ((x) << S_PTRP)
+#define F_PTRP    V_PTRP(1U)
+
+#define A_PCIE_CORE_UTL_PCI_EXPRESS_PORT_STATUS 0x59a4
+
+#define S_TPCP    30
+#define V_TPCP(x) ((x) << S_TPCP)
+#define F_TPCP    V_TPCP(1U)
+
+#define S_TNPP    29
+#define V_TNPP(x) ((x) << S_TNPP)
+#define F_TNPP    V_TNPP(1U)
+
+#define S_TFTP    28
+#define V_TFTP(x) ((x) << S_TFTP)
+#define F_TFTP    V_TFTP(1U)
+
+#define S_TCAP    27
+#define V_TCAP(x) ((x) << S_TCAP)
+#define F_TCAP    V_TCAP(1U)
+
+#define S_TCIP    26
+#define V_TCIP(x) ((x) << S_TCIP)
+#define F_TCIP    V_TCIP(1U)
+
+#define S_RCAP    25
+#define V_RCAP(x) ((x) << S_RCAP)
+#define F_RCAP    V_RCAP(1U)
+
+#define S_PLUP    23
+#define V_PLUP(x) ((x) << S_PLUP)
+#define F_PLUP    V_PLUP(1U)
+
+#define S_PLDN    22
+#define V_PLDN(x) ((x) << S_PLDN)
+#define F_PLDN    V_PLDN(1U)
+
+#define S_OTDD    21
+#define V_OTDD(x) ((x) << S_OTDD)
+#define F_OTDD    V_OTDD(1U)
+
+#define S_GTRP    20
+#define V_GTRP(x) ((x) << S_GTRP)
+#define F_GTRP    V_GTRP(1U)
+
+#define S_RDPE    18
+#define V_RDPE(x) ((x) << S_RDPE)
+#define F_RDPE    V_RDPE(1U)
+
+#define S_TDCE    17
+#define V_TDCE(x) ((x) << S_TDCE)
+#define F_TDCE    V_TDCE(1U)
+
+#define S_TDUE    16
+#define V_TDUE(x) ((x) << S_TDUE)
+#define F_TDUE    V_TDUE(1U)
+
+/* registers for module MC */
+#define A_MC_INT_CAUSE 0x7518
+
+#define S_ECC_UE_INT_CAUSE    2
+#define V_ECC_UE_INT_CAUSE(x) ((x) << S_ECC_UE_INT_CAUSE)
+#define F_ECC_UE_INT_CAUSE    V_ECC_UE_INT_CAUSE(1U)
+
+#define S_ECC_CE_INT_CAUSE    1
+#define V_ECC_CE_INT_CAUSE(x) ((x) << S_ECC_CE_INT_CAUSE)
+#define F_ECC_CE_INT_CAUSE    V_ECC_CE_INT_CAUSE(1U)
+
+#define S_PERR_INT_CAUSE    0
+#define V_PERR_INT_CAUSE(x) ((x) << S_PERR_INT_CAUSE)
+#define F_PERR_INT_CAUSE    V_PERR_INT_CAUSE(1U)
+
+#define A_MC_ECC_STATUS 0x751c
+
+#define S_ECC_CECNT    16
+#define M_ECC_CECNT    0xffffU
+#define V_ECC_CECNT(x) ((x) << S_ECC_CECNT)
+#define G_ECC_CECNT(x) (((x) >> S_ECC_CECNT) & M_ECC_CECNT)
+
+#define S_ECC_UECNT    0
+#define M_ECC_UECNT    0xffffU
+#define V_ECC_UECNT(x) ((x) << S_ECC_UECNT)
+#define G_ECC_UECNT(x) (((x) >> S_ECC_UECNT) & M_ECC_UECNT)
+
+#define A_MC_BIST_CMD 0x7600
+
+#define S_START_BIST    31
+#define V_START_BIST(x) ((x) << S_START_BIST)
+#define F_START_BIST    V_START_BIST(1U)
+
+#define S_BIST_CMD_GAP    8
+#define M_BIST_CMD_GAP    0xffU
+#define V_BIST_CMD_GAP(x) ((x) << S_BIST_CMD_GAP)
+
+#define S_BIST_OPCODE    0
+#define M_BIST_OPCODE    0x3U
+#define V_BIST_OPCODE(x) ((x) << S_BIST_OPCODE)
+
+#define A_MC_BIST_CMD_ADDR 0x7604
+#define A_MC_BIST_CMD_LEN 0x7608
+#define A_MC_BIST_DATA_PATTERN 0x760c
+
+#define S_BIST_DATA_TYPE    0
+#define M_BIST_DATA_TYPE    0xfU
+#define V_BIST_DATA_TYPE(x) ((x) << S_BIST_DATA_TYPE)
+
+#define A_MC_BIST_STATUS_RDATA 0x7688
+
+/* registers for module MA */
+#define A_MA_EXT_MEMORY_BAR 0x77c8
+
+#define S_EXT_MEM_BASE    16
+#define M_EXT_MEM_BASE    0xfffU
+#define V_EXT_MEM_BASE(x) ((x) << S_EXT_MEM_BASE)
+#define G_EXT_MEM_BASE(x) (((x) >> S_EXT_MEM_BASE) & M_EXT_MEM_BASE)
+
+#define S_EXT_MEM_SIZE    0
+#define M_EXT_MEM_SIZE    0xfffU
+#define V_EXT_MEM_SIZE(x) ((x) << S_EXT_MEM_SIZE)
+#define G_EXT_MEM_SIZE(x) (((x) >> S_EXT_MEM_SIZE) & M_EXT_MEM_SIZE)
+
+#define A_MA_TARGET_MEM_ENABLE 0x77d8
+
+#define S_HMA_ENABLE    3
+#define V_HMA_ENABLE(x) ((x) << S_HMA_ENABLE)
+#define F_HMA_ENABLE    V_HMA_ENABLE(1U)
+
+#define S_EXT_MEM_ENABLE    2
+#define V_EXT_MEM_ENABLE(x) ((x) << S_EXT_MEM_ENABLE)
+#define F_EXT_MEM_ENABLE    V_EXT_MEM_ENABLE(1U)
+
+#define S_EDRAM1_ENABLE    1
+#define V_EDRAM1_ENABLE(x) ((x) << S_EDRAM1_ENABLE)
+#define F_EDRAM1_ENABLE    V_EDRAM1_ENABLE(1U)
+
+#define S_EDRAM0_ENABLE    0
+#define V_EDRAM0_ENABLE(x) ((x) << S_EDRAM0_ENABLE)
+#define F_EDRAM0_ENABLE    V_EDRAM0_ENABLE(1U)
+
+#define A_MA_INT_CAUSE 0x77e0
+
+#define S_MEM_PERR_INT_CAUSE    1
+#define V_MEM_PERR_INT_CAUSE(x) ((x) << S_MEM_PERR_INT_CAUSE)
+#define F_MEM_PERR_INT_CAUSE    V_MEM_PERR_INT_CAUSE(1U)
+
+#define S_MEM_WRAP_INT_CAUSE    0
+#define V_MEM_WRAP_INT_CAUSE(x) ((x) << S_MEM_WRAP_INT_CAUSE)
+#define F_MEM_WRAP_INT_CAUSE    V_MEM_WRAP_INT_CAUSE(1U)
+
+#define A_MA_INT_WRAP_STATUS 0x77e4
+
+#define S_MEM_WRAP_ADDRESS    4
+#define M_MEM_WRAP_ADDRESS    0xfffffffU
+#define V_MEM_WRAP_ADDRESS(x) ((x) << S_MEM_WRAP_ADDRESS)
+#define G_MEM_WRAP_ADDRESS(x) (((x) >> S_MEM_WRAP_ADDRESS) & M_MEM_WRAP_ADDRESS)
+
+#define S_MEM_WRAP_CLIENT_NUM    0
+#define M_MEM_WRAP_CLIENT_NUM    0xfU
+#define V_MEM_WRAP_CLIENT_NUM(x) ((x) << S_MEM_WRAP_CLIENT_NUM)
+#define G_MEM_WRAP_CLIENT_NUM(x) (((x) >> S_MEM_WRAP_CLIENT_NUM) & M_MEM_WRAP_CLIENT_NUM)
+
+#define A_MA_PARITY_ERROR_STATUS 0x77f4
+
+/* registers for module EDC_0 */
+#define EDC_0_BASE_ADDR 0x7900
+
+#define A_EDC_BIST_CMD 0x7904
+#define A_EDC_BIST_CMD_ADDR 0x7908
+#define A_EDC_BIST_CMD_LEN 0x790c
+#define A_EDC_BIST_DATA_PATTERN 0x7910
+#define A_EDC_BIST_STATUS_RDATA 0x7928
+#define A_EDC_INT_CAUSE 0x7978
+
+#define S_ECC_UE_PAR    5
+#define V_ECC_UE_PAR(x) ((x) << S_ECC_UE_PAR)
+#define F_ECC_UE_PAR    V_ECC_UE_PAR(1U)
+
+#define S_ECC_CE_PAR    4
+#define V_ECC_CE_PAR(x) ((x) << S_ECC_CE_PAR)
+#define F_ECC_CE_PAR    V_ECC_CE_PAR(1U)
+
+#define S_PERR_PAR_CAUSE    3
+#define V_PERR_PAR_CAUSE(x) ((x) << S_PERR_PAR_CAUSE)
+#define F_PERR_PAR_CAUSE    V_PERR_PAR_CAUSE(1U)
+
+#define A_EDC_ECC_STATUS 0x797c
+
+/* registers for module EDC_1 */
+#define EDC_1_BASE_ADDR 0x7980
+
+/* registers for module CIM */
+#define A_CIM_PF_MAILBOX_DATA 0x240
+#define A_CIM_PF_MAILBOX_CTRL 0x280
+
+#define S_MBGENERIC    4
+#define M_MBGENERIC    0xfffffffU
+#define V_MBGENERIC(x) ((x) << S_MBGENERIC)
+#define G_MBGENERIC(x) (((x) >> S_MBGENERIC) & M_MBGENERIC)
+
+#define S_MBMSGVALID    3
+#define V_MBMSGVALID(x) ((x) << S_MBMSGVALID)
+#define F_MBMSGVALID    V_MBMSGVALID(1U)
+
+#define S_MBINTREQ    2
+#define V_MBINTREQ(x) ((x) << S_MBINTREQ)
+#define F_MBINTREQ    V_MBINTREQ(1U)
+
+#define S_MBOWNER    0
+#define M_MBOWNER    0x3U
+#define V_MBOWNER(x) ((x) << S_MBOWNER)
+#define G_MBOWNER(x) (((x) >> S_MBOWNER) & M_MBOWNER)
+
+#define A_CIM_PF_HOST_INT_CAUSE 0x28c
+
+#define S_MBMSGRDYINT    19
+#define V_MBMSGRDYINT(x) ((x) << S_MBMSGRDYINT)
+#define F_MBMSGRDYINT    V_MBMSGRDYINT(1U)
+
+#define A_CIM_HOST_INT_CAUSE 0x7b2c
+
+#define S_TIEQOUTPARERRINT    20
+#define V_TIEQOUTPARERRINT(x) ((x) << S_TIEQOUTPARERRINT)
+#define F_TIEQOUTPARERRINT    V_TIEQOUTPARERRINT(1U)
+
+#define S_TIEQINPARERRINT    19
+#define V_TIEQINPARERRINT(x) ((x) << S_TIEQINPARERRINT)
+#define F_TIEQINPARERRINT    V_TIEQINPARERRINT(1U)
+
+#define S_MBHOSTPARERR    18
+#define V_MBHOSTPARERR(x) ((x) << S_MBHOSTPARERR)
+#define F_MBHOSTPARERR    V_MBHOSTPARERR(1U)
+
+#define S_MBUPPARERR    17
+#define V_MBUPPARERR(x) ((x) << S_MBUPPARERR)
+#define F_MBUPPARERR    V_MBUPPARERR(1U)
+
+#define S_IBQTP0PARERR    16
+#define V_IBQTP0PARERR(x) ((x) << S_IBQTP0PARERR)
+#define F_IBQTP0PARERR    V_IBQTP0PARERR(1U)
+
+#define S_IBQTP1PARERR    15
+#define V_IBQTP1PARERR(x) ((x) << S_IBQTP1PARERR)
+#define F_IBQTP1PARERR    V_IBQTP1PARERR(1U)
+
+#define S_IBQULPPARERR    14
+#define V_IBQULPPARERR(x) ((x) << S_IBQULPPARERR)
+#define F_IBQULPPARERR    V_IBQULPPARERR(1U)
+
+#define S_IBQSGELOPARERR    13
+#define V_IBQSGELOPARERR(x) ((x) << S_IBQSGELOPARERR)
+#define F_IBQSGELOPARERR    V_IBQSGELOPARERR(1U)
+
+#define S_IBQSGEHIPARERR    12
+#define V_IBQSGEHIPARERR(x) ((x) << S_IBQSGEHIPARERR)
+#define F_IBQSGEHIPARERR    V_IBQSGEHIPARERR(1U)
+
+#define S_IBQNCSIPARERR    11
+#define V_IBQNCSIPARERR(x) ((x) << S_IBQNCSIPARERR)
+#define F_IBQNCSIPARERR    V_IBQNCSIPARERR(1U)
+
+#define S_OBQULP0PARERR    10
+#define V_OBQULP0PARERR(x) ((x) << S_OBQULP0PARERR)
+#define F_OBQULP0PARERR    V_OBQULP0PARERR(1U)
+
+#define S_OBQULP1PARERR    9
+#define V_OBQULP1PARERR(x) ((x) << S_OBQULP1PARERR)
+#define F_OBQULP1PARERR    V_OBQULP1PARERR(1U)
+
+#define S_OBQULP2PARERR    8
+#define V_OBQULP2PARERR(x) ((x) << S_OBQULP2PARERR)
+#define F_OBQULP2PARERR    V_OBQULP2PARERR(1U)
+
+#define S_OBQULP3PARERR    7
+#define V_OBQULP3PARERR(x) ((x) << S_OBQULP3PARERR)
+#define F_OBQULP3PARERR    V_OBQULP3PARERR(1U)
+
+#define S_OBQSGEPARERR    6
+#define V_OBQSGEPARERR(x) ((x) << S_OBQSGEPARERR)
+#define F_OBQSGEPARERR    V_OBQSGEPARERR(1U)
+
+#define S_OBQNCSIPARERR    5
+#define V_OBQNCSIPARERR(x) ((x) << S_OBQNCSIPARERR)
+#define F_OBQNCSIPARERR    V_OBQNCSIPARERR(1U)
+
+#define S_TIMER1INT    3
+#define V_TIMER1INT(x) ((x) << S_TIMER1INT)
+#define F_TIMER1INT    V_TIMER1INT(1U)
+
+#define S_TIMER0INT    2
+#define V_TIMER0INT(x) ((x) << S_TIMER0INT)
+#define F_TIMER0INT    V_TIMER0INT(1U)
+
+#define S_PREFDROPINT    1
+#define V_PREFDROPINT(x) ((x) << S_PREFDROPINT)
+#define F_PREFDROPINT    V_PREFDROPINT(1U)
+
+#define S_UPACCNONZERO    0
+#define V_UPACCNONZERO(x) ((x) << S_UPACCNONZERO)
+#define F_UPACCNONZERO    V_UPACCNONZERO(1U)
+
+#define A_CIM_HOST_UPACC_INT_CAUSE 0x7b34
+
+#define S_EEPROMWRINT    30
+#define V_EEPROMWRINT(x) ((x) << S_EEPROMWRINT)
+#define F_EEPROMWRINT    V_EEPROMWRINT(1U)
+
+#define S_TIMEOUTMAINT    29
+#define V_TIMEOUTMAINT(x) ((x) << S_TIMEOUTMAINT)
+#define F_TIMEOUTMAINT    V_TIMEOUTMAINT(1U)
+
+#define S_TIMEOUTINT    28
+#define V_TIMEOUTINT(x) ((x) << S_TIMEOUTINT)
+#define F_TIMEOUTINT    V_TIMEOUTINT(1U)
+
+#define S_RSPOVRLOOKUPINT    27
+#define V_RSPOVRLOOKUPINT(x) ((x) << S_RSPOVRLOOKUPINT)
+#define F_RSPOVRLOOKUPINT    V_RSPOVRLOOKUPINT(1U)
+
+#define S_REQOVRLOOKUPINT    26
+#define V_REQOVRLOOKUPINT(x) ((x) << S_REQOVRLOOKUPINT)
+#define F_REQOVRLOOKUPINT    V_REQOVRLOOKUPINT(1U)
+
+#define S_BLKWRPLINT    25
+#define V_BLKWRPLINT(x) ((x) << S_BLKWRPLINT)
+#define F_BLKWRPLINT    V_BLKWRPLINT(1U)
+
+#define S_BLKRDPLINT    24
+#define V_BLKRDPLINT(x) ((x) << S_BLKRDPLINT)
+#define F_BLKRDPLINT    V_BLKRDPLINT(1U)
+
+#define S_SGLWRPLINT    23
+#define V_SGLWRPLINT(x) ((x) << S_SGLWRPLINT)
+#define F_SGLWRPLINT    V_SGLWRPLINT(1U)
+
+#define S_SGLRDPLINT    22
+#define V_SGLRDPLINT(x) ((x) << S_SGLRDPLINT)
+#define F_SGLRDPLINT    V_SGLRDPLINT(1U)
+
+#define S_BLKWRCTLINT    21
+#define V_BLKWRCTLINT(x) ((x) << S_BLKWRCTLINT)
+#define F_BLKWRCTLINT    V_BLKWRCTLINT(1U)
+
+#define S_BLKRDCTLINT    20
+#define V_BLKRDCTLINT(x) ((x) << S_BLKRDCTLINT)
+#define F_BLKRDCTLINT    V_BLKRDCTLINT(1U)
+
+#define S_SGLWRCTLINT    19
+#define V_SGLWRCTLINT(x) ((x) << S_SGLWRCTLINT)
+#define F_SGLWRCTLINT    V_SGLWRCTLINT(1U)
+
+#define S_SGLRDCTLINT    18
+#define V_SGLRDCTLINT(x) ((x) << S_SGLRDCTLINT)
+#define F_SGLRDCTLINT    V_SGLRDCTLINT(1U)
+
+#define S_BLKWREEPROMINT    17
+#define V_BLKWREEPROMINT(x) ((x) << S_BLKWREEPROMINT)
+#define F_BLKWREEPROMINT    V_BLKWREEPROMINT(1U)
+
+#define S_BLKRDEEPROMINT    16
+#define V_BLKRDEEPROMINT(x) ((x) << S_BLKRDEEPROMINT)
+#define F_BLKRDEEPROMINT    V_BLKRDEEPROMINT(1U)
+
+#define S_SGLWREEPROMINT    15
+#define V_SGLWREEPROMINT(x) ((x) << S_SGLWREEPROMINT)
+#define F_SGLWREEPROMINT    V_SGLWREEPROMINT(1U)
+
+#define S_SGLRDEEPROMINT    14
+#define V_SGLRDEEPROMINT(x) ((x) << S_SGLRDEEPROMINT)
+#define F_SGLRDEEPROMINT    V_SGLRDEEPROMINT(1U)
+
+#define S_BLKWRFLASHINT    13
+#define V_BLKWRFLASHINT(x) ((x) << S_BLKWRFLASHINT)
+#define F_BLKWRFLASHINT    V_BLKWRFLASHINT(1U)
+
+#define S_BLKRDFLASHINT    12
+#define V_BLKRDFLASHINT(x) ((x) << S_BLKRDFLASHINT)
+#define F_BLKRDFLASHINT    V_BLKRDFLASHINT(1U)
+
+#define S_SGLWRFLASHINT    11
+#define V_SGLWRFLASHINT(x) ((x) << S_SGLWRFLASHINT)
+#define F_SGLWRFLASHINT    V_SGLWRFLASHINT(1U)
+
+#define S_SGLRDFLASHINT    10
+#define V_SGLRDFLASHINT(x) ((x) << S_SGLRDFLASHINT)
+#define F_SGLRDFLASHINT    V_SGLRDFLASHINT(1U)
+
+#define S_BLKWRBOOTINT    9
+#define V_BLKWRBOOTINT(x) ((x) << S_BLKWRBOOTINT)
+#define F_BLKWRBOOTINT    V_BLKWRBOOTINT(1U)
+
+#define S_BLKRDBOOTINT    8
+#define V_BLKRDBOOTINT(x) ((x) << S_BLKRDBOOTINT)
+#define F_BLKRDBOOTINT    V_BLKRDBOOTINT(1U)
+
+#define S_SGLWRBOOTINT    7
+#define V_SGLWRBOOTINT(x) ((x) << S_SGLWRBOOTINT)
+#define F_SGLWRBOOTINT    V_SGLWRBOOTINT(1U)
+
+#define S_SGLRDBOOTINT    6
+#define V_SGLRDBOOTINT(x) ((x) << S_SGLRDBOOTINT)
+#define F_SGLRDBOOTINT    V_SGLRDBOOTINT(1U)
+
+#define S_ILLWRBEINT    5
+#define V_ILLWRBEINT(x) ((x) << S_ILLWRBEINT)
+#define F_ILLWRBEINT    V_ILLWRBEINT(1U)
+
+#define S_ILLRDBEINT    4
+#define V_ILLRDBEINT(x) ((x) << S_ILLRDBEINT)
+#define F_ILLRDBEINT    V_ILLRDBEINT(1U)
+
+#define S_ILLRDINT    3
+#define V_ILLRDINT(x) ((x) << S_ILLRDINT)
+#define F_ILLRDINT    V_ILLRDINT(1U)
+
+#define S_ILLWRINT    2
+#define V_ILLWRINT(x) ((x) << S_ILLWRINT)
+#define F_ILLWRINT    V_ILLWRINT(1U)
+
+#define S_ILLTRANSINT    1
+#define V_ILLTRANSINT(x) ((x) << S_ILLTRANSINT)
+#define F_ILLTRANSINT    V_ILLTRANSINT(1U)
+
+#define S_RSVDSPACEINT    0
+#define V_RSVDSPACEINT(x) ((x) << S_RSVDSPACEINT)
+#define F_RSVDSPACEINT    V_RSVDSPACEINT(1U)
+
+/* registers for module TP */
+#define A_TP_OUT_CONFIG 0x7d04
+
+#define S_VLANEXTENABLEPORT0    12
+#define V_VLANEXTENABLEPORT0(x) ((x) << S_VLANEXTENABLEPORT0)
+#define F_VLANEXTENABLEPORT0    V_VLANEXTENABLEPORT0(1U)
+
+#define A_TP_TIMER_RESOLUTION 0x7d90
+
+#define S_TIMERRESOLUTION    16
+#define M_TIMERRESOLUTION    0xffU
+#define V_TIMERRESOLUTION(x) ((x) << S_TIMERRESOLUTION)
+#define G_TIMERRESOLUTION(x) (((x) >> S_TIMERRESOLUTION) & M_TIMERRESOLUTION)
+
+#define A_TP_SHIFT_CNT 0x7dc0
+
+#define S_SYNSHIFTMAX    24
+#define M_SYNSHIFTMAX    0xffU
+#define V_SYNSHIFTMAX(x) ((x) << S_SYNSHIFTMAX)
+#define G_SYNSHIFTMAX(x) (((x) >> S_SYNSHIFTMAX) & M_SYNSHIFTMAX)
+
+#define S_RXTSHIFTMAXR1    20
+#define M_RXTSHIFTMAXR1    0xfU
+#define V_RXTSHIFTMAXR1(x) ((x) << S_RXTSHIFTMAXR1)
+#define G_RXTSHIFTMAXR1(x) (((x) >> S_RXTSHIFTMAXR1) & M_RXTSHIFTMAXR1)
+
+#define S_RXTSHIFTMAXR2    16
+#define M_RXTSHIFTMAXR2    0xfU
+#define V_RXTSHIFTMAXR2(x) ((x) << S_RXTSHIFTMAXR2)
+#define G_RXTSHIFTMAXR2(x) (((x) >> S_RXTSHIFTMAXR2) & M_RXTSHIFTMAXR2)
+
+#define S_PERSHIFTBACKOFFMAX    12
+#define M_PERSHIFTBACKOFFMAX    0xfU
+#define V_PERSHIFTBACKOFFMAX(x) ((x) << S_PERSHIFTBACKOFFMAX)
+#define G_PERSHIFTBACKOFFMAX(x) (((x) >> S_PERSHIFTBACKOFFMAX) & M_PERSHIFTBACKOFFMAX)
+
+#define S_PERSHIFTMAX    8
+#define M_PERSHIFTMAX    0xfU
+#define V_PERSHIFTMAX(x) ((x) << S_PERSHIFTMAX)
+#define G_PERSHIFTMAX(x) (((x) >> S_PERSHIFTMAX) & M_PERSHIFTMAX)
+
+#define S_KEEPALIVEMAXR1    4
+#define M_KEEPALIVEMAXR1    0xfU
+#define V_KEEPALIVEMAXR1(x) ((x) << S_KEEPALIVEMAXR1)
+#define G_KEEPALIVEMAXR1(x) (((x) >> S_KEEPALIVEMAXR1) & M_KEEPALIVEMAXR1)
+
+#define S_KEEPALIVEMAXR2    0
+#define M_KEEPALIVEMAXR2    0xfU
+#define V_KEEPALIVEMAXR2(x) ((x) << S_KEEPALIVEMAXR2)
+#define G_KEEPALIVEMAXR2(x) (((x) >> S_KEEPALIVEMAXR2) & M_KEEPALIVEMAXR2)
+
+#define A_TP_CCTRL_TABLE 0x7ddc
+#define A_TP_MTU_TABLE 0x7de4
+
+#define S_MTUINDEX    24
+#define M_MTUINDEX    0xffU
+#define V_MTUINDEX(x) ((x) << S_MTUINDEX)
+#define G_MTUINDEX(x) (((x) >> S_MTUINDEX) & M_MTUINDEX)
+
+#define S_MTUWIDTH    16
+#define M_MTUWIDTH    0xfU
+#define V_MTUWIDTH(x) ((x) << S_MTUWIDTH)
+#define G_MTUWIDTH(x) (((x) >> S_MTUWIDTH) & M_MTUWIDTH)
+
+#define S_MTUVALUE    0
+#define M_MTUVALUE    0x3fffU
+#define V_MTUVALUE(x) ((x) << S_MTUVALUE)
+#define G_MTUVALUE(x) (((x) >> S_MTUVALUE) & M_MTUVALUE)
+
+#define A_TP_RSS_LKP_TABLE 0x7dec
+
+#define S_LKPTBLROWVLD    31
+#define V_LKPTBLROWVLD(x) ((x) << S_LKPTBLROWVLD)
+#define F_LKPTBLROWVLD    V_LKPTBLROWVLD(1U)
+
+#define S_LKPTBLROWIDX    20
+#define M_LKPTBLROWIDX    0x3ffU
+#define V_LKPTBLROWIDX(x) ((x) << S_LKPTBLROWIDX)
+#define G_LKPTBLROWIDX(x) (((x) >> S_LKPTBLROWIDX) & M_LKPTBLROWIDX)
+
+#define S_LKPTBLQUEUE1    10
+#define M_LKPTBLQUEUE1    0x3ffU
+#define V_LKPTBLQUEUE1(x) ((x) << S_LKPTBLQUEUE1)
+#define G_LKPTBLQUEUE1(x) (((x) >> S_LKPTBLQUEUE1) & M_LKPTBLQUEUE1)
+
+#define S_LKPTBLQUEUE0    0
+#define M_LKPTBLQUEUE0    0x3ffU
+#define V_LKPTBLQUEUE0(x) ((x) << S_LKPTBLQUEUE0)
+#define G_LKPTBLQUEUE0(x) (((x) >> S_LKPTBLQUEUE0) & M_LKPTBLQUEUE0)
+
+#define A_TP_PIO_ADDR 0x7e40
+#define A_TP_PIO_DATA 0x7e44
+#define A_TP_MIB_INDEX 0x7e50
+#define A_TP_MIB_DATA 0x7e54
+#define A_TP_INT_CAUSE 0x7e74
+
+#define S_FLMTXFLSTEMPTY    30
+#define V_FLMTXFLSTEMPTY(x) ((x) << S_FLMTXFLSTEMPTY)
+#define F_FLMTXFLSTEMPTY    V_FLMTXFLSTEMPTY(1U)
+
+#define A_TP_INGRESS_CONFIG 0x141
+
+#define S_VNIC    11
+#define V_VNIC(x) ((x) << S_VNIC)
+#define F_VNIC    V_VNIC(1U)
+
+#define S_CSUM_HAS_PSEUDO_HDR    10
+#define V_CSUM_HAS_PSEUDO_HDR(x) ((x) << S_CSUM_HAS_PSEUDO_HDR)
+#define F_CSUM_HAS_PSEUDO_HDR    V_CSUM_HAS_PSEUDO_HDR(1U)
+
+#define S_RM_OVLAN    9
+#define V_RM_OVLAN(x) ((x) << S_RM_OVLAN)
+#define F_RM_OVLAN    V_RM_OVLAN(1U)
+
+#define S_LOOKUPEVERYPKT    8
+#define V_LOOKUPEVERYPKT(x) ((x) << S_LOOKUPEVERYPKT)
+#define F_LOOKUPEVERYPKT    V_LOOKUPEVERYPKT(1U)
+
+#define A_TP_MIB_MAC_IN_ERR_0 0x0
+#define A_TP_MIB_TCP_OUT_RST 0xc
+#define A_TP_MIB_TCP_IN_SEG_HI 0x10
+#define A_TP_MIB_TCP_IN_SEG_LO 0x11
+#define A_TP_MIB_TCP_OUT_SEG_HI 0x12
+#define A_TP_MIB_TCP_OUT_SEG_LO 0x13
+#define A_TP_MIB_TCP_RXT_SEG_HI 0x14
+#define A_TP_MIB_TCP_RXT_SEG_LO 0x15
+#define A_TP_MIB_TNL_CNG_DROP_0 0x18
+#define A_TP_MIB_TCP_V6IN_ERR_0 0x28
+#define A_TP_MIB_TCP_V6OUT_RST 0x2c
+#define A_TP_MIB_OFD_ARP_DROP 0x36
+#define A_TP_MIB_TNL_DROP_0 0x44
+#define A_TP_MIB_OFD_VLN_DROP_0 0x58
+
+/* registers for module ULP_TX */
+#define A_ULP_TX_INT_CAUSE 0x8dcc
+
+#define S_PBL_BOUND_ERR_CH3    31
+#define V_PBL_BOUND_ERR_CH3(x) ((x) << S_PBL_BOUND_ERR_CH3)
+#define F_PBL_BOUND_ERR_CH3    V_PBL_BOUND_ERR_CH3(1U)
+
+#define S_PBL_BOUND_ERR_CH2    30
+#define V_PBL_BOUND_ERR_CH2(x) ((x) << S_PBL_BOUND_ERR_CH2)
+#define F_PBL_BOUND_ERR_CH2    V_PBL_BOUND_ERR_CH2(1U)
+
+#define S_PBL_BOUND_ERR_CH1    29
+#define V_PBL_BOUND_ERR_CH1(x) ((x) << S_PBL_BOUND_ERR_CH1)
+#define F_PBL_BOUND_ERR_CH1    V_PBL_BOUND_ERR_CH1(1U)
+
+#define S_PBL_BOUND_ERR_CH0    28
+#define V_PBL_BOUND_ERR_CH0(x) ((x) << S_PBL_BOUND_ERR_CH0)
+#define F_PBL_BOUND_ERR_CH0    V_PBL_BOUND_ERR_CH0(1U)
+
+/* registers for module PM_RX */
+#define A_PM_RX_INT_CAUSE 0x8fdc
+
+#define S_ZERO_E_CMD_ERROR    22
+#define V_ZERO_E_CMD_ERROR(x) ((x) << S_ZERO_E_CMD_ERROR)
+#define F_ZERO_E_CMD_ERROR    V_ZERO_E_CMD_ERROR(1U)
+
+#define S_OCSPI_PAR_ERROR    3
+#define V_OCSPI_PAR_ERROR(x) ((x) << S_OCSPI_PAR_ERROR)
+#define F_OCSPI_PAR_ERROR    V_OCSPI_PAR_ERROR(1U)
+
+#define S_DB_OPTIONS_PAR_ERROR    2
+#define V_DB_OPTIONS_PAR_ERROR(x) ((x) << S_DB_OPTIONS_PAR_ERROR)
+#define F_DB_OPTIONS_PAR_ERROR    V_DB_OPTIONS_PAR_ERROR(1U)
+
+#define S_IESPI_PAR_ERROR    1
+#define V_IESPI_PAR_ERROR(x) ((x) << S_IESPI_PAR_ERROR)
+#define F_IESPI_PAR_ERROR    V_IESPI_PAR_ERROR(1U)
+
+#define S_E_PCMD_PAR_ERROR    0
+#define V_E_PCMD_PAR_ERROR(x) ((x) << S_E_PCMD_PAR_ERROR)
+#define F_E_PCMD_PAR_ERROR    V_E_PCMD_PAR_ERROR(1U)
+
+/* registers for module PM_TX */
+#define A_PM_TX_INT_CAUSE 0x8ffc
+
+#define S_PCMD_LEN_OVFL0    31
+#define V_PCMD_LEN_OVFL0(x) ((x) << S_PCMD_LEN_OVFL0)
+#define F_PCMD_LEN_OVFL0    V_PCMD_LEN_OVFL0(1U)
+
+#define S_PCMD_LEN_OVFL1    30
+#define V_PCMD_LEN_OVFL1(x) ((x) << S_PCMD_LEN_OVFL1)
+#define F_PCMD_LEN_OVFL1    V_PCMD_LEN_OVFL1(1U)
+
+#define S_PCMD_LEN_OVFL2    29
+#define V_PCMD_LEN_OVFL2(x) ((x) << S_PCMD_LEN_OVFL2)
+#define F_PCMD_LEN_OVFL2    V_PCMD_LEN_OVFL2(1U)
+
+#define S_ZERO_C_CMD_ERROR    28
+#define V_ZERO_C_CMD_ERROR(x) ((x) << S_ZERO_C_CMD_ERROR)
+#define F_ZERO_C_CMD_ERROR    V_ZERO_C_CMD_ERROR(1U)
+
+#define S_OESPI_PAR_ERROR    3
+#define V_OESPI_PAR_ERROR(x) ((x) << S_OESPI_PAR_ERROR)
+#define F_OESPI_PAR_ERROR    V_OESPI_PAR_ERROR(1U)
+
+#define S_ICSPI_PAR_ERROR    1
+#define V_ICSPI_PAR_ERROR(x) ((x) << S_ICSPI_PAR_ERROR)
+#define F_ICSPI_PAR_ERROR    V_ICSPI_PAR_ERROR(1U)
+
+#define S_C_PCMD_PAR_ERROR    0
+#define V_C_PCMD_PAR_ERROR(x) ((x) << S_C_PCMD_PAR_ERROR)
+#define F_C_PCMD_PAR_ERROR    V_C_PCMD_PAR_ERROR(1U)
+
+/* registers for module MPS */
+#define A_MPS_PORT_STAT_TX_PORT_BYTES_L 0x400
+#define A_MPS_PORT_STAT_TX_PORT_BYTES_H 0x404
+#define A_MPS_PORT_STAT_TX_PORT_FRAMES_L 0x408
+#define A_MPS_PORT_STAT_TX_PORT_FRAMES_H 0x40c
+#define A_MPS_PORT_STAT_TX_PORT_BCAST_L 0x410
+#define A_MPS_PORT_STAT_TX_PORT_BCAST_H 0x414
+#define A_MPS_PORT_STAT_TX_PORT_MCAST_L 0x418
+#define A_MPS_PORT_STAT_TX_PORT_MCAST_H 0x41c
+#define A_MPS_PORT_STAT_TX_PORT_UCAST_L 0x420
+#define A_MPS_PORT_STAT_TX_PORT_UCAST_H 0x424
+#define A_MPS_PORT_STAT_TX_PORT_ERROR_L 0x428
+#define A_MPS_PORT_STAT_TX_PORT_ERROR_H 0x42c
+#define A_MPS_PORT_STAT_TX_PORT_64B_L 0x430
+#define A_MPS_PORT_STAT_TX_PORT_64B_H 0x434
+#define A_MPS_PORT_STAT_TX_PORT_65B_127B_L 0x438
+#define A_MPS_PORT_STAT_TX_PORT_65B_127B_H 0x43c
+#define A_MPS_PORT_STAT_TX_PORT_128B_255B_L 0x440
+#define A_MPS_PORT_STAT_TX_PORT_128B_255B_H 0x444
+#define A_MPS_PORT_STAT_TX_PORT_256B_511B_L 0x448
+#define A_MPS_PORT_STAT_TX_PORT_256B_511B_H 0x44c
+#define A_MPS_PORT_STAT_TX_PORT_512B_1023B_L 0x450
+#define A_MPS_PORT_STAT_TX_PORT_512B_1023B_H 0x454
+#define A_MPS_PORT_STAT_TX_PORT_1024B_1518B_L 0x458
+#define A_MPS_PORT_STAT_TX_PORT_1024B_1518B_H 0x45c
+#define A_MPS_PORT_STAT_TX_PORT_1519B_MAX_L 0x460
+#define A_MPS_PORT_STAT_TX_PORT_1519B_MAX_H 0x464
+#define A_MPS_PORT_STAT_TX_PORT_DROP_L 0x468
+#define A_MPS_PORT_STAT_TX_PORT_DROP_H 0x46c
+#define A_MPS_PORT_STAT_TX_PORT_PAUSE_L 0x470
+#define A_MPS_PORT_STAT_TX_PORT_PAUSE_H 0x474
+#define A_MPS_PORT_STAT_TX_PORT_PPP0_L 0x478
+#define A_MPS_PORT_STAT_TX_PORT_PPP0_H 0x47c
+#define A_MPS_PORT_STAT_TX_PORT_PPP1_L 0x480
+#define A_MPS_PORT_STAT_TX_PORT_PPP1_H 0x484
+#define A_MPS_PORT_STAT_TX_PORT_PPP2_L 0x488
+#define A_MPS_PORT_STAT_TX_PORT_PPP2_H 0x48c
+#define A_MPS_PORT_STAT_TX_PORT_PPP3_L 0x490
+#define A_MPS_PORT_STAT_TX_PORT_PPP3_H 0x494
+#define A_MPS_PORT_STAT_TX_PORT_PPP4_L 0x498
+#define A_MPS_PORT_STAT_TX_PORT_PPP4_H 0x49c
+#define A_MPS_PORT_STAT_TX_PORT_PPP5_L 0x4a0
+#define A_MPS_PORT_STAT_TX_PORT_PPP5_H 0x4a4
+#define A_MPS_PORT_STAT_TX_PORT_PPP6_L 0x4a8
+#define A_MPS_PORT_STAT_TX_PORT_PPP6_H 0x4ac
+#define A_MPS_PORT_STAT_TX_PORT_PPP7_L 0x4b0
+#define A_MPS_PORT_STAT_TX_PORT_PPP7_H 0x4b4
+#define A_MPS_PORT_STAT_LB_PORT_BYTES_L 0x4c0
+#define A_MPS_PORT_STAT_LB_PORT_BYTES_H 0x4c4
+#define A_MPS_PORT_STAT_LB_PORT_FRAMES_L 0x4c8
+#define A_MPS_PORT_STAT_LB_PORT_FRAMES_H 0x4cc
+#define A_MPS_PORT_STAT_LB_PORT_BCAST_L 0x4d0
+#define A_MPS_PORT_STAT_LB_PORT_BCAST_H 0x4d4
+#define A_MPS_PORT_STAT_LB_PORT_MCAST_L 0x4d8
+#define A_MPS_PORT_STAT_LB_PORT_MCAST_H 0x4dc
+#define A_MPS_PORT_STAT_LB_PORT_UCAST_L 0x4e0
+#define A_MPS_PORT_STAT_LB_PORT_UCAST_H 0x4e4
+#define A_MPS_PORT_STAT_LB_PORT_ERROR_L 0x4e8
+#define A_MPS_PORT_STAT_LB_PORT_ERROR_H 0x4ec
+#define A_MPS_PORT_STAT_LB_PORT_64B_L 0x4f0
+#define A_MPS_PORT_STAT_LB_PORT_64B_H 0x4f4
+#define A_MPS_PORT_STAT_LB_PORT_65B_127B_L 0x4f8
+#define A_MPS_PORT_STAT_LB_PORT_65B_127B_H 0x4fc
+#define A_MPS_PORT_STAT_LB_PORT_128B_255B_L 0x500
+#define A_MPS_PORT_STAT_LB_PORT_128B_255B_H 0x504
+#define A_MPS_PORT_STAT_LB_PORT_256B_511B_L 0x508
+#define A_MPS_PORT_STAT_LB_PORT_256B_511B_H 0x50c
+#define A_MPS_PORT_STAT_LB_PORT_512B_1023B_L 0x510
+#define A_MPS_PORT_STAT_LB_PORT_512B_1023B_H 0x514
+#define A_MPS_PORT_STAT_LB_PORT_1024B_1518B_L 0x518
+#define A_MPS_PORT_STAT_LB_PORT_1024B_1518B_H 0x51c
+#define A_MPS_PORT_STAT_LB_PORT_1519B_MAX_L 0x520
+#define A_MPS_PORT_STAT_LB_PORT_1519B_MAX_H 0x524
+#define A_MPS_PORT_STAT_LB_PORT_DROP_FRAMES 0x528
+#define A_MPS_PORT_STAT_RX_PORT_BYTES_L 0x540
+#define A_MPS_PORT_STAT_RX_PORT_BYTES_H 0x544
+#define A_MPS_PORT_STAT_RX_PORT_FRAMES_L 0x548
+#define A_MPS_PORT_STAT_RX_PORT_FRAMES_H 0x54c
+#define A_MPS_PORT_STAT_RX_PORT_BCAST_L 0x550
+#define A_MPS_PORT_STAT_RX_PORT_BCAST_H 0x554
+#define A_MPS_PORT_STAT_RX_PORT_MCAST_L 0x558
+#define A_MPS_PORT_STAT_RX_PORT_MCAST_H 0x55c
+#define A_MPS_PORT_STAT_RX_PORT_UCAST_L 0x560
+#define A_MPS_PORT_STAT_RX_PORT_UCAST_H 0x564
+#define A_MPS_PORT_STAT_RX_PORT_MTU_ERROR_L 0x568
+#define A_MPS_PORT_STAT_RX_PORT_MTU_ERROR_H 0x56c
+#define A_MPS_PORT_STAT_RX_PORT_MTU_CRC_ERROR_L 0x570
+#define A_MPS_PORT_STAT_RX_PORT_MTU_CRC_ERROR_H 0x574
+#define A_MPS_PORT_STAT_RX_PORT_CRC_ERROR_L 0x578
+#define A_MPS_PORT_STAT_RX_PORT_CRC_ERROR_H 0x57c
+#define A_MPS_PORT_STAT_RX_PORT_LEN_ERROR_L 0x580
+#define A_MPS_PORT_STAT_RX_PORT_LEN_ERROR_H 0x584
+#define A_MPS_PORT_STAT_RX_PORT_SYM_ERROR_L 0x588
+#define A_MPS_PORT_STAT_RX_PORT_SYM_ERROR_H 0x58c
+#define A_MPS_PORT_STAT_RX_PORT_64B_L 0x590
+#define A_MPS_PORT_STAT_RX_PORT_64B_H 0x594
+#define A_MPS_PORT_STAT_RX_PORT_65B_127B_L 0x598
+#define A_MPS_PORT_STAT_RX_PORT_65B_127B_H 0x59c
+#define A_MPS_PORT_STAT_RX_PORT_128B_255B_L 0x5a0
+#define A_MPS_PORT_STAT_RX_PORT_128B_255B_H 0x5a4
+#define A_MPS_PORT_STAT_RX_PORT_256B_511B_L 0x5a8
+#define A_MPS_PORT_STAT_RX_PORT_256B_511B_H 0x5ac
+#define A_MPS_PORT_STAT_RX_PORT_512B_1023B_L 0x5b0
+#define A_MPS_PORT_STAT_RX_PORT_512B_1023B_H 0x5b4
+#define A_MPS_PORT_STAT_RX_PORT_1024B_1518B_L 0x5b8
+#define A_MPS_PORT_STAT_RX_PORT_1024B_1518B_H 0x5bc
+#define A_MPS_PORT_STAT_RX_PORT_1519B_MAX_L 0x5c0
+#define A_MPS_PORT_STAT_RX_PORT_1519B_MAX_H 0x5c4
+#define A_MPS_PORT_STAT_RX_PORT_PAUSE_L 0x5c8
+#define A_MPS_PORT_STAT_RX_PORT_PAUSE_H 0x5cc
+#define A_MPS_PORT_STAT_RX_PORT_PPP0_L 0x5d0
+#define A_MPS_PORT_STAT_RX_PORT_PPP0_H 0x5d4
+#define A_MPS_PORT_STAT_RX_PORT_PPP1_L 0x5d8
+#define A_MPS_PORT_STAT_RX_PORT_PPP1_H 0x5dc
+#define A_MPS_PORT_STAT_RX_PORT_PPP2_L 0x5e0
+#define A_MPS_PORT_STAT_RX_PORT_PPP2_H 0x5e4
+#define A_MPS_PORT_STAT_RX_PORT_PPP3_L 0x5e8
+#define A_MPS_PORT_STAT_RX_PORT_PPP3_H 0x5ec
+#define A_MPS_PORT_STAT_RX_PORT_PPP4_L 0x5f0
+#define A_MPS_PORT_STAT_RX_PORT_PPP4_H 0x5f4
+#define A_MPS_PORT_STAT_RX_PORT_PPP5_L 0x5f8
+#define A_MPS_PORT_STAT_RX_PORT_PPP5_H 0x5fc
+#define A_MPS_PORT_STAT_RX_PORT_PPP6_L 0x600
+#define A_MPS_PORT_STAT_RX_PORT_PPP6_H 0x604
+#define A_MPS_PORT_STAT_RX_PORT_PPP7_L 0x608
+#define A_MPS_PORT_STAT_RX_PORT_PPP7_H 0x60c
+#define A_MPS_PORT_STAT_RX_PORT_LESS_64B_L 0x610
+#define A_MPS_PORT_STAT_RX_PORT_LESS_64B_H 0x614
+#define A_MPS_CMN_CTL 0x9000
+
+#define S_NUMPORTS    0
+#define M_NUMPORTS    0x3U
+#define V_NUMPORTS(x) ((x) << S_NUMPORTS)
+#define G_NUMPORTS(x) (((x) >> S_NUMPORTS) & M_NUMPORTS)
+
+#define A_MPS_INT_CAUSE 0x9008
+
+#define S_STATINT    5
+#define V_STATINT(x) ((x) << S_STATINT)
+#define F_STATINT    V_STATINT(1U)
+
+#define S_TXINT    4
+#define V_TXINT(x) ((x) << S_TXINT)
+#define F_TXINT    V_TXINT(1U)
+
+#define S_RXINT    3
+#define V_RXINT(x) ((x) << S_RXINT)
+#define F_RXINT    V_RXINT(1U)
+
+#define S_TRCINT    2
+#define V_TRCINT(x) ((x) << S_TRCINT)
+#define F_TRCINT    V_TRCINT(1U)
+
+#define S_CLSINT    1
+#define V_CLSINT(x) ((x) << S_CLSINT)
+#define F_CLSINT    V_CLSINT(1U)
+
+#define S_PLINT    0
+#define V_PLINT(x) ((x) << S_PLINT)
+#define F_PLINT    V_PLINT(1U)
+
+#define A_MPS_TX_INT_CAUSE 0x9408
+
+#define S_PORTERR    16
+#define V_PORTERR(x) ((x) << S_PORTERR)
+#define F_PORTERR    V_PORTERR(1U)
+
+#define S_FRMERR    15
+#define V_FRMERR(x) ((x) << S_FRMERR)
+#define F_FRMERR    V_FRMERR(1U)
+
+#define S_SECNTERR    14
+#define V_SECNTERR(x) ((x) << S_SECNTERR)
+#define F_SECNTERR    V_SECNTERR(1U)
+
+#define S_BUBBLE    13
+#define V_BUBBLE(x) ((x) << S_BUBBLE)
+#define F_BUBBLE    V_BUBBLE(1U)
+
+#define S_TXDESCFIFO    9
+#define M_TXDESCFIFO    0xfU
+#define V_TXDESCFIFO(x) ((x) << S_TXDESCFIFO)
+#define G_TXDESCFIFO(x) (((x) >> S_TXDESCFIFO) & M_TXDESCFIFO)
+
+#define S_TXDATAFIFO    5
+#define M_TXDATAFIFO    0xfU
+#define V_TXDATAFIFO(x) ((x) << S_TXDATAFIFO)
+#define G_TXDATAFIFO(x) (((x) >> S_TXDATAFIFO) & M_TXDATAFIFO)
+
+#define S_NCSIFIFO    4
+#define V_NCSIFIFO(x) ((x) << S_NCSIFIFO)
+#define F_NCSIFIFO    V_NCSIFIFO(1U)
+
+#define S_TPFIFO    0
+#define M_TPFIFO    0xfU
+#define V_TPFIFO(x) ((x) << S_TPFIFO)
+#define G_TPFIFO(x) (((x) >> S_TPFIFO) & M_TPFIFO)
+
+#define A_MPS_STAT_PERR_INT_CAUSE_SRAM 0x9614
+#define A_MPS_STAT_PERR_INT_CAUSE_TX_FIFO 0x9620
+
+#define S_TX    12
+#define M_TX    0xffU
+#define V_TX(x) ((x) << S_TX)
+#define G_TX(x) (((x) >> S_TX) & M_TX)
+
+#define S_TXPAUSEFIFO    8
+#define M_TXPAUSEFIFO    0xfU
+#define V_TXPAUSEFIFO(x) ((x) << S_TXPAUSEFIFO)
+#define G_TXPAUSEFIFO(x) (((x) >> S_TXPAUSEFIFO) & M_TXPAUSEFIFO)
+
+#define S_DROP    0
+#define M_DROP    0xffU
+#define V_DROP(x) ((x) << S_DROP)
+#define G_DROP(x) (((x) >> S_DROP) & M_DROP)
+
+#define A_MPS_STAT_PERR_INT_CAUSE_RX_FIFO 0x962c
+
+#define S_PAUSEFIFO    20
+#define M_PAUSEFIFO    0xfU
+#define V_PAUSEFIFO(x) ((x) << S_PAUSEFIFO)
+#define G_PAUSEFIFO(x) (((x) >> S_PAUSEFIFO) & M_PAUSEFIFO)
+
+#define S_LPBK    16
+#define M_LPBK    0xfU
+#define V_LPBK(x) ((x) << S_LPBK)
+#define G_LPBK(x) (((x) >> S_LPBK) & M_LPBK)
+
+#define S_NQ    8
+#define M_NQ    0xffU
+#define V_NQ(x) ((x) << S_NQ)
+#define G_NQ(x) (((x) >> S_NQ) & M_NQ)
+
+#define S_PV    4
+#define M_PV    0xfU
+#define V_PV(x) ((x) << S_PV)
+#define G_PV(x) (((x) >> S_PV) & M_PV)
+
+#define S_MAC    0
+#define M_MAC    0xfU
+#define V_MAC(x) ((x) << S_MAC)
+#define G_MAC(x) (((x) >> S_MAC) & M_MAC)
+
+#define A_MPS_STAT_RX_BG_0_MAC_DROP_FRAME_L 0x9640
+#define A_MPS_STAT_RX_BG_0_MAC_DROP_FRAME_H 0x9644
+#define A_MPS_STAT_RX_BG_1_MAC_DROP_FRAME_L 0x9648
+#define A_MPS_STAT_RX_BG_1_MAC_DROP_FRAME_H 0x964c
+#define A_MPS_STAT_RX_BG_2_MAC_DROP_FRAME_L 0x9650
+#define A_MPS_STAT_RX_BG_2_MAC_DROP_FRAME_H 0x9654
+#define A_MPS_STAT_RX_BG_3_MAC_DROP_FRAME_L 0x9658
+#define A_MPS_STAT_RX_BG_3_MAC_DROP_FRAME_H 0x965c
+#define A_MPS_STAT_RX_BG_0_LB_DROP_FRAME_L 0x9660
+#define A_MPS_STAT_RX_BG_0_LB_DROP_FRAME_H 0x9664
+#define A_MPS_STAT_RX_BG_1_LB_DROP_FRAME_L 0x9668
+#define A_MPS_STAT_RX_BG_1_LB_DROP_FRAME_H 0x966c
+#define A_MPS_STAT_RX_BG_2_LB_DROP_FRAME_L 0x9670
+#define A_MPS_STAT_RX_BG_2_LB_DROP_FRAME_H 0x9674
+#define A_MPS_STAT_RX_BG_3_LB_DROP_FRAME_L 0x9678
+#define A_MPS_STAT_RX_BG_3_LB_DROP_FRAME_H 0x967c
+#define A_MPS_STAT_RX_BG_0_MAC_TRUNC_FRAME_L 0x9680
+#define A_MPS_STAT_RX_BG_0_MAC_TRUNC_FRAME_H 0x9684
+#define A_MPS_STAT_RX_BG_1_MAC_TRUNC_FRAME_L 0x9688
+#define A_MPS_STAT_RX_BG_1_MAC_TRUNC_FRAME_H 0x968c
+#define A_MPS_STAT_RX_BG_2_MAC_TRUNC_FRAME_L 0x9690
+#define A_MPS_STAT_RX_BG_2_MAC_TRUNC_FRAME_H 0x9694
+#define A_MPS_STAT_RX_BG_3_MAC_TRUNC_FRAME_L 0x9698
+#define A_MPS_STAT_RX_BG_3_MAC_TRUNC_FRAME_H 0x969c
+#define A_MPS_STAT_RX_BG_0_LB_TRUNC_FRAME_L 0x96a0
+#define A_MPS_STAT_RX_BG_0_LB_TRUNC_FRAME_H 0x96a4
+#define A_MPS_STAT_RX_BG_1_LB_TRUNC_FRAME_L 0x96a8
+#define A_MPS_STAT_RX_BG_1_LB_TRUNC_FRAME_H 0x96ac
+#define A_MPS_STAT_RX_BG_2_LB_TRUNC_FRAME_L 0x96b0
+#define A_MPS_STAT_RX_BG_2_LB_TRUNC_FRAME_H 0x96b4
+#define A_MPS_STAT_RX_BG_3_LB_TRUNC_FRAME_L 0x96b8
+#define A_MPS_STAT_RX_BG_3_LB_TRUNC_FRAME_H 0x96bc
+#define A_MPS_TRC_CFG 0x9800
+
+#define S_TRCFIFOEMPTY    4
+#define V_TRCFIFOEMPTY(x) ((x) << S_TRCFIFOEMPTY)
+#define F_TRCFIFOEMPTY    V_TRCFIFOEMPTY(1U)
+
+#define S_TRCIGNOREDROPINPUT    3
+#define V_TRCIGNOREDROPINPUT(x) ((x) << S_TRCIGNOREDROPINPUT)
+#define F_TRCIGNOREDROPINPUT    V_TRCIGNOREDROPINPUT(1U)
+
+#define S_TRCKEEPDUPLICATES    2
+#define V_TRCKEEPDUPLICATES(x) ((x) << S_TRCKEEPDUPLICATES)
+#define F_TRCKEEPDUPLICATES    V_TRCKEEPDUPLICATES(1U)
+
+#define S_TRCEN    1
+#define V_TRCEN(x) ((x) << S_TRCEN)
+#define F_TRCEN    V_TRCEN(1U)
+
+#define S_TRCMULTIFILTER    0
+#define V_TRCMULTIFILTER(x) ((x) << S_TRCMULTIFILTER)
+#define F_TRCMULTIFILTER    V_TRCMULTIFILTER(1U)
+
+#define A_MPS_TRC_RSS_CONTROL 0x9808
+
+#define S_RSSCONTROL    16
+#define M_RSSCONTROL    0xffU
+#define V_RSSCONTROL(x) ((x) << S_RSSCONTROL)
+#define G_RSSCONTROL(x) (((x) >> S_RSSCONTROL) & M_RSSCONTROL)
+
+#define S_QUEUENUMBER    0
+#define M_QUEUENUMBER    0xffffU
+#define V_QUEUENUMBER(x) ((x) << S_QUEUENUMBER)
+#define G_QUEUENUMBER(x) (((x) >> S_QUEUENUMBER) & M_QUEUENUMBER)
+
+#define A_MPS_TRC_FILTER_MATCH_CTL_A 0x9810
+
+#define S_TFINVERTMATCH    24
+#define V_TFINVERTMATCH(x) ((x) << S_TFINVERTMATCH)
+#define F_TFINVERTMATCH    V_TFINVERTMATCH(1U)
+
+#define S_TFPKTTOOLARGE    23
+#define V_TFPKTTOOLARGE(x) ((x) << S_TFPKTTOOLARGE)
+#define F_TFPKTTOOLARGE    V_TFPKTTOOLARGE(1U)
+
+#define S_TFEN    22
+#define V_TFEN(x) ((x) << S_TFEN)
+#define F_TFEN    V_TFEN(1U)
+
+#define S_TFPORT    18
+#define M_TFPORT    0xfU
+#define V_TFPORT(x) ((x) << S_TFPORT)
+#define G_TFPORT(x) (((x) >> S_TFPORT) & M_TFPORT)
+
+#define S_TFDROP    17
+#define V_TFDROP(x) ((x) << S_TFDROP)
+#define F_TFDROP    V_TFDROP(1U)
+
+#define S_TFSOPEOPERR    16
+#define V_TFSOPEOPERR(x) ((x) << S_TFSOPEOPERR)
+#define F_TFSOPEOPERR    V_TFSOPEOPERR(1U)
+
+#define S_TFLENGTH    8
+#define M_TFLENGTH    0x1fU
+#define V_TFLENGTH(x) ((x) << S_TFLENGTH)
+#define G_TFLENGTH(x) (((x) >> S_TFLENGTH) & M_TFLENGTH)
+
+#define S_TFOFFSET    0
+#define M_TFOFFSET    0x1fU
+#define V_TFOFFSET(x) ((x) << S_TFOFFSET)
+#define G_TFOFFSET(x) (((x) >> S_TFOFFSET) & M_TFOFFSET)
+
+#define A_MPS_TRC_FILTER_MATCH_CTL_B 0x9820
+
+#define S_TFMINPKTSIZE    16
+#define M_TFMINPKTSIZE    0x1ffU
+#define V_TFMINPKTSIZE(x) ((x) << S_TFMINPKTSIZE)
+#define G_TFMINPKTSIZE(x) (((x) >> S_TFMINPKTSIZE) & M_TFMINPKTSIZE)
+
+#define S_TFCAPTUREMAX    0
+#define M_TFCAPTUREMAX    0x3fffU
+#define V_TFCAPTUREMAX(x) ((x) << S_TFCAPTUREMAX)
+#define G_TFCAPTUREMAX(x) (((x) >> S_TFCAPTUREMAX) & M_TFCAPTUREMAX)
+
+#define A_MPS_TRC_INT_CAUSE 0x985c
+
+#define S_TRCPLERRENB    9
+#define V_TRCPLERRENB(x) ((x) << S_TRCPLERRENB)
+#define F_TRCPLERRENB    V_TRCPLERRENB(1U)
+
+#define S_MISCPERR    8
+#define V_MISCPERR(x) ((x) << S_MISCPERR)
+#define F_MISCPERR    V_MISCPERR(1U)
+
+#define S_PKTFIFO    4
+#define M_PKTFIFO    0xfU
+#define V_PKTFIFO(x) ((x) << S_PKTFIFO)
+#define G_PKTFIFO(x) (((x) >> S_PKTFIFO) & M_PKTFIFO)
+
+#define S_FILTMEM    0
+#define M_FILTMEM    0xfU
+#define V_FILTMEM(x) ((x) << S_FILTMEM)
+#define G_FILTMEM(x) (((x) >> S_FILTMEM) & M_FILTMEM)
+
+#define A_MPS_TRC_FILTER0_MATCH 0x9c00
+#define A_MPS_TRC_FILTER0_DONT_CARE 0x9c80
+#define A_MPS_TRC_FILTER1_MATCH 0x9d00
+#define A_MPS_CLS_INT_CAUSE 0xd028
+
+#define S_PLERRENB    3
+#define V_PLERRENB(x) ((x) << S_PLERRENB)
+#define F_PLERRENB    V_PLERRENB(1U)
+
+#define S_HASHSRAM    2
+#define V_HASHSRAM(x) ((x) << S_HASHSRAM)
+#define F_HASHSRAM    V_HASHSRAM(1U)
+
+#define S_MATCHTCAM    1
+#define V_MATCHTCAM(x) ((x) << S_MATCHTCAM)
+#define F_MATCHTCAM    V_MATCHTCAM(1U)
+
+#define S_MATCHSRAM    0
+#define V_MATCHSRAM(x) ((x) << S_MATCHSRAM)
+#define F_MATCHSRAM    V_MATCHSRAM(1U)
+
+#define A_MPS_RX_PERR_INT_CAUSE 0x11074
+
+/* registers for module CPL_SWITCH */
+#define A_CPL_INTR_CAUSE 0x19054
+
+#define S_CIM_OP_MAP_PERR    5
+#define V_CIM_OP_MAP_PERR(x) ((x) << S_CIM_OP_MAP_PERR)
+#define F_CIM_OP_MAP_PERR    V_CIM_OP_MAP_PERR(1U)
+
+#define S_CIM_OVFL_ERROR    4
+#define V_CIM_OVFL_ERROR(x) ((x) << S_CIM_OVFL_ERROR)
+#define F_CIM_OVFL_ERROR    V_CIM_OVFL_ERROR(1U)
+
+#define S_TP_FRAMING_ERROR    3
+#define V_TP_FRAMING_ERROR(x) ((x) << S_TP_FRAMING_ERROR)
+#define F_TP_FRAMING_ERROR    V_TP_FRAMING_ERROR(1U)
+
+#define S_SGE_FRAMING_ERROR    2
+#define V_SGE_FRAMING_ERROR(x) ((x) << S_SGE_FRAMING_ERROR)
+#define F_SGE_FRAMING_ERROR    V_SGE_FRAMING_ERROR(1U)
+
+#define S_CIM_FRAMING_ERROR    1
+#define V_CIM_FRAMING_ERROR(x) ((x) << S_CIM_FRAMING_ERROR)
+#define F_CIM_FRAMING_ERROR    V_CIM_FRAMING_ERROR(1U)
+
+#define S_ZERO_SWITCH_ERROR    0
+#define V_ZERO_SWITCH_ERROR(x) ((x) << S_ZERO_SWITCH_ERROR)
+#define F_ZERO_SWITCH_ERROR    V_ZERO_SWITCH_ERROR(1U)
+
+/* registers for module SMB */
+#define A_SMB_INT_CAUSE 0x19090
+
+#define S_MSTTXFIFOPARINT    21
+#define V_MSTTXFIFOPARINT(x) ((x) << S_MSTTXFIFOPARINT)
+#define F_MSTTXFIFOPARINT    V_MSTTXFIFOPARINT(1U)
+
+#define S_MSTRXFIFOPARINT    20
+#define V_MSTRXFIFOPARINT(x) ((x) << S_MSTRXFIFOPARINT)
+#define F_MSTRXFIFOPARINT    V_MSTRXFIFOPARINT(1U)
+
+#define S_SLVFIFOPARINT    19
+#define V_SLVFIFOPARINT(x) ((x) << S_SLVFIFOPARINT)
+#define F_SLVFIFOPARINT    V_SLVFIFOPARINT(1U)
+
+/* registers for module ULP_RX */
+#define A_ULP_RX_INT_CAUSE 0x19158
+#define A_ULP_RX_ISCSI_TAGMASK 0x19164
+
+#define S_ISCSITAGMASK    6
+#define M_ISCSITAGMASK    0x3ffffffU
+#define V_ISCSITAGMASK(x) ((x) << S_ISCSITAGMASK)
+#define G_ISCSITAGMASK(x) (((x) >> S_ISCSITAGMASK) & M_ISCSITAGMASK)
+
+#define A_ULP_RX_ISCSI_PSZ 0x19168
+
+#define S_HPZ3    24
+#define M_HPZ3    0xfU
+#define V_HPZ3(x) ((x) << S_HPZ3)
+#define G_HPZ3(x) (((x) >> S_HPZ3) & M_HPZ3)
+
+#define S_HPZ2    16
+#define M_HPZ2    0xfU
+#define V_HPZ2(x) ((x) << S_HPZ2)
+#define G_HPZ2(x) (((x) >> S_HPZ2) & M_HPZ2)
+
+#define S_HPZ1    8
+#define M_HPZ1    0xfU
+#define V_HPZ1(x) ((x) << S_HPZ1)
+#define G_HPZ1(x) (((x) >> S_HPZ1) & M_HPZ1)
+
+#define S_HPZ0    0
+#define M_HPZ0    0xfU
+#define V_HPZ0(x) ((x) << S_HPZ0)
+#define G_HPZ0(x) (((x) >> S_HPZ0) & M_HPZ0)
+
+#define A_ULP_RX_TDDP_PSZ 0x19178
+
+/* registers for module SF */
+#define A_SF_DATA 0x193f8
+#define A_SF_OP 0x193fc
+
+#define S_SF_LOCK    4
+#define V_SF_LOCK(x) ((x) << S_SF_LOCK)
+#define F_SF_LOCK    V_SF_LOCK(1U)
+
+#define S_CONT    3
+#define V_CONT(x) ((x) << S_CONT)
+#define F_CONT    V_CONT(1U)
+
+#define S_BYTECNT    1
+#define M_BYTECNT    0x3U
+#define V_BYTECNT(x) ((x) << S_BYTECNT)
+
+#define S_OP    0
+#define V_OP(x) ((x) << S_OP)
+#define F_OP    V_OP(1U)
+
+/* registers for module PL */
+#define A_PL_PF_INT_CAUSE 0x3c0
+
+#define S_PFSW    3
+#define V_PFSW(x) ((x) << S_PFSW)
+#define F_PFSW    V_PFSW(1U)
+
+#define S_PFSGE    2
+#define V_PFSGE(x) ((x) << S_PFSGE)
+#define F_PFSGE    V_PFSGE(1U)
+
+#define S_PFCIM    1
+#define V_PFCIM(x) ((x) << S_PFCIM)
+#define F_PFCIM    V_PFCIM(1U)
+
+#define S_PFMPS    0
+#define V_PFMPS(x) ((x) << S_PFMPS)
+#define F_PFMPS    V_PFMPS(1U)
+
+#define A_PL_PF_INT_ENABLE 0x3c4
+#define A_PL_PF_CTL 0x3c8
+
+#define S_SWINT    0
+#define V_SWINT(x) ((x) << S_SWINT)
+#define F_SWINT    V_SWINT(1U)
+
+#define A_PL_WHOAMI 0x19400
+
+#define S_PORTXMAP    24
+#define M_PORTXMAP    0x7U
+#define V_PORTXMAP(x) ((x) << S_PORTXMAP)
+#define G_PORTXMAP(x) (((x) >> S_PORTXMAP) & M_PORTXMAP)
+
+#define S_SOURCEBUS    16
+#define M_SOURCEBUS    0x3U
+#define V_SOURCEBUS(x) ((x) << S_SOURCEBUS)
+#define G_SOURCEBUS(x) (((x) >> S_SOURCEBUS) & M_SOURCEBUS)
+
+#define S_SOURCEPF    8
+#define M_SOURCEPF    0x7U
+#define V_SOURCEPF(x) ((x) << S_SOURCEPF)
+#define G_SOURCEPF(x) (((x) >> S_SOURCEPF) & M_SOURCEPF)
+
+#define S_ISVF    7
+#define V_ISVF(x) ((x) << S_ISVF)
+#define F_ISVF    V_ISVF(1U)
+
+#define S_VFID    0
+#define M_VFID    0x7fU
+#define V_VFID(x) ((x) << S_VFID)
+#define G_VFID(x) (((x) >> S_VFID) & M_VFID)
+
+#define A_PL_INT_CAUSE 0x1940c
+
+#define S_FLR    30
+#define V_FLR(x) ((x) << S_FLR)
+#define F_FLR    V_FLR(1U)
+
+#define S_ULP_TX    27
+#define V_ULP_TX(x) ((x) << S_ULP_TX)
+#define F_ULP_TX    V_ULP_TX(1U)
+
+#define S_SGE    26
+#define V_SGE(x) ((x) << S_SGE)
+#define F_SGE    V_SGE(1U)
+
+#define S_CPL_SWITCH    24
+#define V_CPL_SWITCH(x) ((x) << S_CPL_SWITCH)
+#define F_CPL_SWITCH    V_CPL_SWITCH(1U)
+
+#define S_ULP_RX    23
+#define V_ULP_RX(x) ((x) << S_ULP_RX)
+#define F_ULP_RX    V_ULP_RX(1U)
+
+#define S_PM_RX    22
+#define V_PM_RX(x) ((x) << S_PM_RX)
+#define F_PM_RX    V_PM_RX(1U)
+
+#define S_PM_TX    21
+#define V_PM_TX(x) ((x) << S_PM_TX)
+#define F_PM_TX    V_PM_TX(1U)
+
+#define S_MA    20
+#define V_MA(x) ((x) << S_MA)
+#define F_MA    V_MA(1U)
+
+#define S_TP    19
+#define V_TP(x) ((x) << S_TP)
+#define F_TP    V_TP(1U)
+
+#define S_LE    18
+#define V_LE(x) ((x) << S_LE)
+#define F_LE    V_LE(1U)
+
+#define S_EDC1    17
+#define V_EDC1(x) ((x) << S_EDC1)
+#define F_EDC1    V_EDC1(1U)
+
+#define S_EDC0    16
+#define V_EDC0(x) ((x) << S_EDC0)
+#define F_EDC0    V_EDC0(1U)
+
+#define S_MC    15
+#define V_MC(x) ((x) << S_MC)
+#define F_MC    V_MC(1U)
+
+#define S_PCIE    14
+#define V_PCIE(x) ((x) << S_PCIE)
+#define F_PCIE    V_PCIE(1U)
+
+#define S_PMU    13
+#define V_PMU(x) ((x) << S_PMU)
+#define F_PMU    V_PMU(1U)
+
+#define S_XGMAC_KR1    12
+#define V_XGMAC_KR1(x) ((x) << S_XGMAC_KR1)
+#define F_XGMAC_KR1    V_XGMAC_KR1(1U)
+
+#define S_XGMAC_KR0    11
+#define V_XGMAC_KR0(x) ((x) << S_XGMAC_KR0)
+#define F_XGMAC_KR0    V_XGMAC_KR0(1U)
+
+#define S_XGMAC1    10
+#define V_XGMAC1(x) ((x) << S_XGMAC1)
+#define F_XGMAC1    V_XGMAC1(1U)
+
+#define S_XGMAC0    9
+#define V_XGMAC0(x) ((x) << S_XGMAC0)
+#define F_XGMAC0    V_XGMAC0(1U)
+
+#define S_SMB    8
+#define V_SMB(x) ((x) << S_SMB)
+#define F_SMB    V_SMB(1U)
+
+#define S_SF    7
+#define V_SF(x) ((x) << S_SF)
+#define F_SF    V_SF(1U)
+
+#define S_PL    6
+#define V_PL(x) ((x) << S_PL)
+#define F_PL    V_PL(1U)
+
+#define S_NCSI    5
+#define V_NCSI(x) ((x) << S_NCSI)
+#define F_NCSI    V_NCSI(1U)
+
+#define S_MPS    4
+#define V_MPS(x) ((x) << S_MPS)
+#define F_MPS    V_MPS(1U)
+
+#define S_MI    3
+#define V_MI(x) ((x) << S_MI)
+#define F_MI    V_MI(1U)
+
+#define S_DBG    2
+#define V_DBG(x) ((x) << S_DBG)
+#define F_DBG    V_DBG(1U)
+
+#define S_I2CM    1
+#define V_I2CM(x) ((x) << S_I2CM)
+#define F_I2CM    V_I2CM(1U)
+
+#define S_CIM    0
+#define V_CIM(x) ((x) << S_CIM)
+#define F_CIM    V_CIM(1U)
+
+#define A_PL_INT_MAP0 0x19414
+
+#define S_MAPNCSI    16
+#define M_MAPNCSI    0x1ffU
+#define V_MAPNCSI(x) ((x) << S_MAPNCSI)
+#define G_MAPNCSI(x) (((x) >> S_MAPNCSI) & M_MAPNCSI)
+
+#define S_MAPDEFAULT    0
+#define M_MAPDEFAULT    0x1ffU
+#define V_MAPDEFAULT(x) ((x) << S_MAPDEFAULT)
+#define G_MAPDEFAULT(x) (((x) >> S_MAPDEFAULT) & M_MAPDEFAULT)
+
+#define A_PL_RST 0x19428
+
+#define S_PIORST    1
+#define V_PIORST(x) ((x) << S_PIORST)
+#define F_PIORST    V_PIORST(1U)
+
+#define S_PIORSTMODE    0
+#define V_PIORSTMODE(x) ((x) << S_PIORSTMODE)
+#define F_PIORSTMODE    V_PIORSTMODE(1U)
+
+#define A_PL_PL_INT_CAUSE 0x19430
+
+#define S_PF_ENABLEERR    5
+#define V_PF_ENABLEERR(x) ((x) << S_PF_ENABLEERR)
+#define F_PF_ENABLEERR    V_PF_ENABLEERR(1U)
+
+#define S_FATALPERR    4
+#define V_FATALPERR(x) ((x) << S_FATALPERR)
+#define F_FATALPERR    V_FATALPERR(1U)
+
+#define S_INVALIDACCESS    3
+#define V_INVALIDACCESS(x) ((x) << S_INVALIDACCESS)
+#define F_INVALIDACCESS    V_INVALIDACCESS(1U)
+
+#define S_TIMEOUT    2
+#define V_TIMEOUT(x) ((x) << S_TIMEOUT)
+#define F_TIMEOUT    V_TIMEOUT(1U)
+
+#define S_PLERR    1
+#define V_PLERR(x) ((x) << S_PLERR)
+#define F_PLERR    V_PLERR(1U)
+
+#define S_PERRVFID    0
+#define V_PERRVFID(x) ((x) << S_PERRVFID)
+#define F_PERRVFID    V_PERRVFID(1U)
+
+#define A_PL_REV 0x1943c
+
+/* registers for module LE */
+#define A_LE_DB_CONFIG 0x19c04
+
+#define S_HASHEN    20
+#define V_HASHEN(x) ((x) << S_HASHEN)
+#define F_HASHEN    V_HASHEN(1U)
+
+#define S_ASBOTHSRCHEN    18
+#define V_ASBOTHSRCHEN(x) ((x) << S_ASBOTHSRCHEN)
+#define F_ASBOTHSRCHEN    V_ASBOTHSRCHEN(1U)
+
+#define S_ASLIPCOMPEN    17
+#define V_ASLIPCOMPEN(x) ((x) << S_ASLIPCOMPEN)
+#define F_ASLIPCOMPEN    V_ASLIPCOMPEN(1U)
+
+#define S_FILTEREN    11
+#define V_FILTEREN(x) ((x) << S_FILTEREN)
+#define F_FILTEREN    V_FILTEREN(1U)
+
+#define A_LE_DB_SERVER_INDEX 0x19c18
+
+#define S_SRINDX    7
+#define M_SRINDX    0x3fU
+#define V_SRINDX(x) ((x) << S_SRINDX)
+#define G_SRINDX(x) (((x) >> S_SRINDX) & M_SRINDX)
+
+#define A_LE_DB_ACT_CNT_IPV4 0x19c20
+#define A_LE_DB_ACT_CNT_IPV6 0x19c24
+#define A_LE_DB_INT_CAUSE 0x19c3c
+
+#define S_REQQPARERR    16
+#define V_REQQPARERR(x) ((x) << S_REQQPARERR)
+#define F_REQQPARERR    V_REQQPARERR(1U)
+
+#define S_UNKNOWNCMD    15
+#define V_UNKNOWNCMD(x) ((x) << S_UNKNOWNCMD)
+#define F_UNKNOWNCMD    V_UNKNOWNCMD(1U)
+
+#define S_PARITYERR    6
+#define V_PARITYERR(x) ((x) << S_PARITYERR)
+#define F_PARITYERR    V_PARITYERR(1U)
+
+#define S_LIPMISS    5
+#define V_LIPMISS(x) ((x) << S_LIPMISS)
+#define F_LIPMISS    V_LIPMISS(1U)
+
+#define S_LIP0    4
+#define V_LIP0(x) ((x) << S_LIP0)
+#define F_LIP0    V_LIP0(1U)
+
+#define A_LE_DB_TID_HASHBASE 0x19df8
+
+#define S_HASHBASE_ADDR    2
+#define M_HASHBASE_ADDR    0xfffffU
+#define V_HASHBASE_ADDR(x) ((x) << S_HASHBASE_ADDR)
+#define G_HASHBASE_ADDR(x) (((x) >> S_HASHBASE_ADDR) & M_HASHBASE_ADDR)
+
+/* registers for module NCSI */
+#define A_NCSI_INT_CAUSE 0x1a0d8
+
+#define S_CIM_DM_PRTY_ERR    8
+#define V_CIM_DM_PRTY_ERR(x) ((x) << S_CIM_DM_PRTY_ERR)
+#define F_CIM_DM_PRTY_ERR    V_CIM_DM_PRTY_ERR(1U)
+
+#define S_MPS_DM_PRTY_ERR    7
+#define V_MPS_DM_PRTY_ERR(x) ((x) << S_MPS_DM_PRTY_ERR)
+#define F_MPS_DM_PRTY_ERR    V_MPS_DM_PRTY_ERR(1U)
+
+#define S_TXFIFO_PRTY_ERR    1
+#define V_TXFIFO_PRTY_ERR(x) ((x) << S_TXFIFO_PRTY_ERR)
+#define F_TXFIFO_PRTY_ERR    V_TXFIFO_PRTY_ERR(1U)
+
+#define S_RXFIFO_PRTY_ERR    0
+#define V_RXFIFO_PRTY_ERR(x) ((x) << S_RXFIFO_PRTY_ERR)
+#define F_RXFIFO_PRTY_ERR    V_RXFIFO_PRTY_ERR(1U)
+
+/* registers for module XGMAC */
+#define A_XGMAC_PORT_CFG2 0x1018
+
+#define S_PATEN    18
+#define V_PATEN(x) ((x) << S_PATEN)
+#define F_PATEN    V_PATEN(1U)
+
+#define S_MAGICEN    17
+#define V_MAGICEN(x) ((x) << S_MAGICEN)
+#define F_MAGICEN    V_MAGICEN(1U)
+
+#define S_TX_IPG    4
+#define M_TX_IPG    0x1fffU
+#define V_TX_IPG(x) ((x) << S_TX_IPG)
+#define G_TX_IPG(x) (((x) >> S_TX_IPG) & M_TX_IPG)
+
+#define S_AEC_PMA_TX_READY    1
+#define V_AEC_PMA_TX_READY(x) ((x) << S_AEC_PMA_TX_READY)
+#define F_AEC_PMA_TX_READY    V_AEC_PMA_TX_READY(1U)
+
+#define S_AEC_PMA_RX_READY    0
+#define V_AEC_PMA_RX_READY(x) ((x) << S_AEC_PMA_RX_READY)
+#define F_AEC_PMA_RX_READY    V_AEC_PMA_RX_READY(1U)
+
+#define A_XGMAC_PORT_MAGIC_MACID_LO 0x1024
+#define A_XGMAC_PORT_MAGIC_MACID_HI 0x1028
+
+#define S_MAC_WOL_DA    0
+#define M_MAC_WOL_DA    0xffffU
+#define V_MAC_WOL_DA(x) ((x) << S_MAC_WOL_DA)
+#define G_MAC_WOL_DA(x) (((x) >> S_MAC_WOL_DA) & M_MAC_WOL_DA)
+
+#define A_XGMAC_PORT_EPIO_DATA0 0x10c0
+#define A_XGMAC_PORT_EPIO_DATA1 0x10c4
+#define A_XGMAC_PORT_EPIO_DATA2 0x10c8
+#define A_XGMAC_PORT_EPIO_DATA3 0x10cc
+#define A_XGMAC_PORT_EPIO_OP 0x10d0
+
+#define S_EPIOWR    8
+#define V_EPIOWR(x) ((x) << S_EPIOWR)
+#define F_EPIOWR    V_EPIOWR(1U)
+
+#define S_ADDRESS    0
+#define M_ADDRESS    0xffU
+#define V_ADDRESS(x) ((x) << S_ADDRESS)
+
+#define A_XGMAC_PORT_INT_CAUSE 0x10dc
+#endif /* __T4_REGS_H */
-- 
1.5.4

