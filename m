From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 1/6] cxgb4: Add register, message, and FW definitions
Date: Thu,  1 Apr 2010 17:28:22 -0800
Message-ID: <1270171707-26058-2-git-send-email-dm@chelsio.com>
References: <1270171707-26058-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27652 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757653Ab0DBB3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:29:01 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o321T0Pv031525
	for <netdev@vger.kernel.org>; Thu, 1 Apr 2010 18:29:00 -0700
In-Reply-To: <1270171707-26058-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_msg.h   |  664 ++++++++++++++++++
 drivers/net/cxgb4/t4_regs.h  |  878 +++++++++++++++++++++++
 drivers/net/cxgb4/t4fw_api.h | 1580 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 3122 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/cxgb4/t4_msg.h
 create mode 100644 drivers/net/cxgb4/t4_regs.h
 create mode 100644 drivers/net/cxgb4/t4fw_api.h

diff --git a/drivers/net/cxgb4/t4_msg.h b/drivers/net/cxgb4/t4_msg.h
new file mode 100644
index 0000000..aac9605
--- /dev/null
+++ b/drivers/net/cxgb4/t4_msg.h
@@ -0,0 +1,664 @@
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
+	NUM_CPL_CMDS
+};
+
+enum CPL_error {
+	CPL_ERR_NONE               = 0,
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
+union opcode_tid {
+	__be32 opcode_tid;
+	u8 opcode;
+};
+
+#define CPL_OPCODE(x) ((x) << 24)
+#define MK_OPCODE_TID(opcode, tid) (CPL_OPCODE(opcode) | (tid))
+#define OPCODE_TID(cmd) ((cmd)->ot.opcode_tid)
+#define GET_TID(cmd) (ntohl(OPCODE_TID(cmd)) & 0xFFFFFF)
+
+/* partitioning of TID fields that also carry a queue id */
+#define GET_TID_TID(x) ((x) & 0x3fff)
+#define GET_TID_QID(x) (((x) >> 14) & 0x3ff)
+#define TID_QID(x)     ((x) << 14)
+
+struct rss_header {
+	u8 opcode;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	u8 channel:2;
+	u8 filter_hit:1;
+	u8 filter_tid:1;
+	u8 hash_type:2;
+	u8 ipv6:1;
+	u8 send2fw:1;
+#else
+	u8 send2fw:1;
+	u8 ipv6:1;
+	u8 hash_type:2;
+	u8 filter_tid:1;
+	u8 filter_hit:1;
+	u8 channel:2;
+#endif
+	__be16 qid;
+	__be32 hash_val;
+};
+
+struct work_request_hdr {
+	__be32 wr_hi;
+	__be32 wr_mid;
+	__be64 wr_lo;
+};
+
+#define WR_HDR struct work_request_hdr wr
+
+struct cpl_pass_open_req {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 local_port;
+	__be16 peer_port;
+	__be32 local_ip;
+	__be32 peer_ip;
+	__be64 opt0;
+#define TX_CHAN(x)    ((x) << 2)
+#define DELACK(x)     ((x) << 5)
+#define ULP_MODE(x)   ((x) << 8)
+#define RCV_BUFSIZ(x) ((x) << 12)
+#define DSCP(x)       ((x) << 22)
+#define SMAC_SEL(x)   ((u64)(x) << 28)
+#define L2T_IDX(x)    ((u64)(x) << 36)
+#define NAGLE(x)      ((u64)(x) << 49)
+#define WND_SCALE(x)  ((u64)(x) << 50)
+#define KEEP_ALIVE(x) ((u64)(x) << 54)
+#define MSS_IDX(x)    ((u64)(x) << 60)
+	__be64 opt1;
+#define SYN_RSS_ENABLE   (1 << 0)
+#define SYN_RSS_QUEUE(x) ((x) << 2)
+#define CONN_POLICY_ASK  (1 << 22)
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
+	u8 rsvd[3];
+	u8 status;
+};
+
+struct cpl_pass_accept_rpl {
+	WR_HDR;
+	union opcode_tid ot;
+	__be32 opt2;
+#define RSS_QUEUE(x)         ((x) << 0)
+#define RSS_QUEUE_VALID      (1 << 10)
+#define RX_COALESCE_VALID(x) ((x) << 11)
+#define RX_COALESCE(x)       ((x) << 12)
+#define TX_QUEUE(x)          ((x) << 23)
+#define RX_CHANNEL(x)        ((x) << 26)
+#define WND_SCALE_EN(x)      ((x) << 28)
+#define TSTAMPS_EN(x)        ((x) << 29)
+#define SACK_EN(x)           ((x) << 30)
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
+#define GET_AOPEN_STATUS(x) ((x) & 0xff)
+#define GET_AOPEN_ATID(x)   (((x) >> 8) & 0xffffff)
+};
+
+struct cpl_pass_establish {
+	union opcode_tid ot;
+	__be32 rsvd;
+	__be32 tos_stid;
+#define GET_POPEN_TID(x) ((x) & 0xffffff)
+#define GET_POPEN_TOS(x) (((x) >> 24) & 0xff)
+	__be16 mac_idx;
+	__be16 tcp_opt;
+#define GET_TCPOPT_WSCALE_OK(x)  (((x) >> 5) & 1)
+#define GET_TCPOPT_SACK(x)       (((x) >> 6) & 1)
+#define GET_TCPOPT_TSTAMP(x)     (((x) >> 7) & 1)
+#define GET_TCPOPT_SND_WSCALE(x) (((x) >> 8) & 0xf)
+#define GET_TCPOPT_MSS(x)        (((x) >> 12) & 0xf)
+	__be32 snd_isn;
+	__be32 rcv_isn;
+};
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
+#define QUEUENO(x)    ((x) << 0)
+#define REPLY_CHAN(x) ((x) << 14)
+#define NO_REPLY(x)   ((x) << 15)
+	__be16 cookie;
+};
+
+struct cpl_set_tcb_field {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 reply_ctrl;
+	__be16 word_cookie;
+#define TCB_WORD(x)   ((x) << 0)
+#define TCB_COOKIE(x) ((x) << 5)
+	__be64 mask;
+	__be64 val;
+};
+
+struct cpl_set_tcb_rpl {
+	union opcode_tid ot;
+	__be16 rsvd;
+	u8 cookie;
+	u8 status;
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
+	u8 rsvd[3];
+	u8 status;
+	__be32 snd_nxt;
+	__be32 rcv_nxt;
+};
+
+struct cpl_close_listsvr_req {
+	WR_HDR;
+	union opcode_tid ot;
+	__be16 reply_ctrl;
+#define LISTSVR_IPV6 (1 << 14)
+	__be16 rsvd;
+};
+
+struct cpl_close_listsvr_rpl {
+	union opcode_tid ot;
+	u8 rsvd[3];
+	u8 status;
+};
+
+struct cpl_abort_req_rss {
+	union opcode_tid ot;
+	u8 rsvd[3];
+	u8 status;
+};
+
+struct cpl_abort_req {
+	WR_HDR;
+	union opcode_tid ot;
+	__be32 rsvd0;
+	u8 rsvd1;
+	u8 cmd;
+	u8 rsvd2[6];
+};
+
+struct cpl_abort_rpl_rss {
+	union opcode_tid ot;
+	u8 rsvd[3];
+	u8 status;
+};
+
+struct cpl_abort_rpl {
+	WR_HDR;
+	union opcode_tid ot;
+	__be32 rsvd0;
+	u8 rsvd1;
+	u8 cmd;
+	u8 rsvd2[6];
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
+#define TXPKT_VF(x)        ((x) << 0)
+#define TXPKT_PF(x)        ((x) << 8)
+#define TXPKT_VF_VLD       (1 << 11)
+#define TXPKT_OVLAN_IDX(x) ((x) << 12)
+#define TXPKT_INTF(x)      ((x) << 16)
+#define TXPKT_INS_OVLAN    (1 << 21)
+#define TXPKT_OPCODE(x)    ((x) << 24)
+	__be16 pack;
+	__be16 len;
+	__be64 ctrl1;
+#define TXPKT_CSUM_END(x)   ((x) << 12)
+#define TXPKT_CSUM_START(x) ((x) << 20)
+#define TXPKT_IPHDR_LEN(x)  ((u64)(x) << 20)
+#define TXPKT_CSUM_LOC(x)   ((u64)(x) << 30)
+#define TXPKT_ETHHDR_LEN(x) ((u64)(x) << 34)
+#define TXPKT_CSUM_TYPE(x)  ((u64)(x) << 40)
+#define TXPKT_VLAN(x)       ((u64)(x) << 44)
+#define TXPKT_VLAN_VLD      (1ULL << 60)
+#define TXPKT_IPCSUM_DIS    (1ULL << 62)
+#define TXPKT_L4CSUM_DIS    (1ULL << 63)
+};
+
+struct cpl_tx_pkt {
+	WR_HDR;
+	struct cpl_tx_pkt_core c;
+};
+
+#define cpl_tx_pkt_xt cpl_tx_pkt
+
+struct cpl_tx_pkt_lso {
+	WR_HDR;
+	__be32 lso_ctrl;
+#define LSO_TCPHDR_LEN(x) ((x) << 0)
+#define LSO_IPHDR_LEN(x)  ((x) << 4)
+#define LSO_ETHHDR_LEN(x) ((x) << 16)
+#define LSO_IPV6(x)       ((x) << 20)
+#define LSO_LAST_SLICE    (1 << 22)
+#define LSO_FIRST_SLICE   (1 << 23)
+#define LSO_OPCODE(x)     ((x) << 24)
+	__be16 ipid_ofst;
+	__be16 mss;
+	__be32 seqno_offset;
+	__be32 len;
+	/* encapsulated CPL (TX_PKT, TX_PKT_XT or TX_DATA) follows here */
+};
+
+struct cpl_iscsi_hdr {
+	union opcode_tid ot;
+	__be16 pdu_len_ddp;
+#define ISCSI_PDU_LEN(x) ((x) & 0x7FFF)
+#define ISCSI_DDP        (1 << 15)
+	__be16 len;
+	__be32 seq;
+	__be16 urg;
+	u8 rsvd;
+	u8 status;
+};
+
+struct cpl_rx_data {
+	union opcode_tid ot;
+	__be16 rsvd;
+	__be16 len;
+	__be32 seq;
+	__be16 urg;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	u8 dack_mode:2;
+	u8 psh:1;
+	u8 heartbeat:1;
+	u8 ddp_off:1;
+	u8 :3;
+#else
+	u8 :3;
+	u8 ddp_off:1;
+	u8 heartbeat:1;
+	u8 psh:1;
+	u8 dack_mode:2;
+#endif
+	u8 status;
+};
+
+struct cpl_rx_data_ack {
+	WR_HDR;
+	union opcode_tid ot;
+	__be32 credit_dack;
+#define RX_CREDITS(x)   ((x) << 0)
+#define RX_FORCE_ACK(x) ((x) << 28)
+};
+
+struct cpl_rx_pkt {
+	u8 opcode;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	u8 iff:4;
+	u8 csum_calc:1;
+	u8 ipmi_pkt:1;
+	u8 vlan_ex:1;
+	u8 ip_frag:1;
+#else
+	u8 ip_frag:1;
+	u8 vlan_ex:1;
+	u8 ipmi_pkt:1;
+	u8 csum_calc:1;
+	u8 iff:4;
+#endif
+	__be16 csum;
+	__be16 vlan;
+	__be16 len;
+	__be32 l2info;
+#define RXF_UDP (1 << 22)
+#define RXF_TCP (1 << 23)
+	__be16 hdr_len;
+	__be16 err_vec;
+};
+
+struct cpl_trace_pkt {
+	u8 opcode;
+	u8 intf;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	u8 runt:4;
+	u8 filter_hit:4;
+	u8 :6;
+	u8 err:1;
+	u8 trunc:1;
+#else
+	u8 filter_hit:4;
+	u8 runt:4;
+	u8 trunc:1;
+	u8 err:1;
+	u8 :6;
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
+#define L2T_W_INFO(x)    ((x) << 2)
+#define L2T_W_PORT(x)    ((x) << 8)
+#define L2T_W_NOREPLY(x) ((x) << 15)
+	__be16 l2t_idx;
+	__be16 vlan;
+	u8 dst_mac[6];
+};
+
+struct cpl_l2t_write_rpl {
+	union opcode_tid ot;
+	u8 status;
+	u8 rsvd[3];
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
+#define EGR_QID(x) ((x) & 0x1FFFF)
+	__be16 cidx;
+	__be16 pidx;
+};
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
+struct ulptx_sge_pair {
+	__be32 len[2];
+	__be64 addr[2];
+};
+
+struct ulptx_sgl {
+	__be32 cmd_nsge;
+#define ULPTX_CMD(x) ((x) << 24)
+#define ULPTX_NSGE(x) ((x) << 0)
+	__be32 len0;
+	__be64 addr0;
+	struct ulptx_sge_pair sge[0];
+};
+
+struct ulp_mem_io {
+	WR_HDR;
+	__be32 cmd;
+#define ULP_MEMIO_ORDER(x) ((x) << 23)
+	__be32 len16;             /* command length */
+	__be32 dlen;              /* data length in 32-byte units */
+#define ULP_MEMIO_DATA_LEN(x) ((x) << 0)
+	__be32 lock_addr;
+#define ULP_MEMIO_ADDR(x) ((x) << 0)
+#define ULP_MEMIO_LOCK(x) ((x) << 31)
+};
+
+#endif  /* __T4_MSG_H */
diff --git a/drivers/net/cxgb4/t4_regs.h b/drivers/net/cxgb4/t4_regs.h
new file mode 100644
index 0000000..5ed5648
--- /dev/null
+++ b/drivers/net/cxgb4/t4_regs.h
@@ -0,0 +1,878 @@
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
+#define PCIE_MAILBOX_REG(reg_addr, idx) ((reg_addr) + (idx) * 8)
+#define MC_BIST_STATUS_REG(reg_addr, idx) ((reg_addr) + (idx) * 4)
+#define EDC_BIST_STATUS_REG(reg_addr, idx) ((reg_addr) + (idx) * 4)
+
+#define SGE_PF_KDOORBELL 0x0
+#define  QID_MASK    0xffff8000U
+#define  QID_SHIFT   15
+#define  QID(x)      ((x) << QID_SHIFT)
+#define  DBPRIO      0x00004000U
+#define  PIDX_MASK   0x00003fffU
+#define  PIDX_SHIFT  0
+#define  PIDX(x)     ((x) << PIDX_SHIFT)
+
+#define SGE_PF_GTS 0x4
+#define  INGRESSQID_MASK   0xffff0000U
+#define  INGRESSQID_SHIFT  16
+#define  INGRESSQID(x)     ((x) << INGRESSQID_SHIFT)
+#define  TIMERREG_MASK     0x0000e000U
+#define  TIMERREG_SHIFT    13
+#define  TIMERREG(x)       ((x) << TIMERREG_SHIFT)
+#define  SEINTARM_MASK     0x00001000U
+#define  SEINTARM_SHIFT    12
+#define  SEINTARM(x)       ((x) << SEINTARM_SHIFT)
+#define  CIDXINC_MASK      0x00000fffU
+#define  CIDXINC_SHIFT     0
+#define  CIDXINC(x)        ((x) << CIDXINC_SHIFT)
+
+#define SGE_CONTROL 0x1008
+#define  DCASYSTYPE             0x00080000U
+#define  RXPKTCPLMODE           0x00040000U
+#define  EGRSTATUSPAGESIZE      0x00020000U
+#define  PKTSHIFT_MASK          0x00001c00U
+#define  PKTSHIFT_SHIFT         10
+#define  PKTSHIFT(x)            ((x) << PKTSHIFT_SHIFT)
+#define  INGPCIEBOUNDARY_MASK   0x00000380U
+#define  INGPCIEBOUNDARY_SHIFT  7
+#define  INGPCIEBOUNDARY(x)     ((x) << INGPCIEBOUNDARY_SHIFT)
+#define  INGPADBOUNDARY_MASK    0x00000070U
+#define  INGPADBOUNDARY_SHIFT   4
+#define  INGPADBOUNDARY(x)      ((x) << INGPADBOUNDARY_SHIFT)
+#define  EGRPCIEBOUNDARY_MASK   0x0000000eU
+#define  EGRPCIEBOUNDARY_SHIFT  1
+#define  EGRPCIEBOUNDARY(x)     ((x) << EGRPCIEBOUNDARY_SHIFT)
+#define  GLOBALENABLE           0x00000001U
+
+#define SGE_HOST_PAGE_SIZE 0x100c
+#define  HOSTPAGESIZEPF0_MASK   0x0000000fU
+#define  HOSTPAGESIZEPF0_SHIFT  0
+#define  HOSTPAGESIZEPF0(x)     ((x) << HOSTPAGESIZEPF0_SHIFT)
+
+#define SGE_EGRESS_QUEUES_PER_PAGE_PF 0x1010
+#define  QUEUESPERPAGEPF0_MASK   0x0000000fU
+#define  QUEUESPERPAGEPF0_GET(x) ((x) & QUEUESPERPAGEPF0_MASK)
+
+#define SGE_INT_CAUSE1 0x1024
+#define SGE_INT_CAUSE2 0x1030
+#define SGE_INT_CAUSE3 0x103c
+#define  ERR_FLM_DBP               0x80000000U
+#define  ERR_FLM_IDMA1             0x40000000U
+#define  ERR_FLM_IDMA0             0x20000000U
+#define  ERR_FLM_HINT              0x10000000U
+#define  ERR_PCIE_ERROR3           0x08000000U
+#define  ERR_PCIE_ERROR2           0x04000000U
+#define  ERR_PCIE_ERROR1           0x02000000U
+#define  ERR_PCIE_ERROR0           0x01000000U
+#define  ERR_TIMER_ABOVE_MAX_QID   0x00800000U
+#define  ERR_CPL_EXCEED_IQE_SIZE   0x00400000U
+#define  ERR_INVALID_CIDX_INC      0x00200000U
+#define  ERR_ITP_TIME_PAUSED       0x00100000U
+#define  ERR_CPL_OPCODE_0          0x00080000U
+#define  ERR_DROPPED_DB            0x00040000U
+#define  ERR_DATA_CPL_ON_HIGH_QID1 0x00020000U
+#define  ERR_DATA_CPL_ON_HIGH_QID0 0x00010000U
+#define  ERR_BAD_DB_PIDX3          0x00008000U
+#define  ERR_BAD_DB_PIDX2          0x00004000U
+#define  ERR_BAD_DB_PIDX1          0x00002000U
+#define  ERR_BAD_DB_PIDX0          0x00001000U
+#define  ERR_ING_PCIE_CHAN         0x00000800U
+#define  ERR_ING_CTXT_PRIO         0x00000400U
+#define  ERR_EGR_CTXT_PRIO         0x00000200U
+#define  DBFIFO_HP_INT             0x00000100U
+#define  DBFIFO_LP_INT             0x00000080U
+#define  REG_ADDRESS_ERR           0x00000040U
+#define  INGRESS_SIZE_ERR          0x00000020U
+#define  EGRESS_SIZE_ERR           0x00000010U
+#define  ERR_INV_CTXT3             0x00000008U
+#define  ERR_INV_CTXT2             0x00000004U
+#define  ERR_INV_CTXT1             0x00000002U
+#define  ERR_INV_CTXT0             0x00000001U
+
+#define SGE_INT_ENABLE3 0x1040
+#define SGE_FL_BUFFER_SIZE0 0x1044
+#define SGE_FL_BUFFER_SIZE1 0x1048
+#define SGE_INGRESS_RX_THRESHOLD 0x10a0
+#define  THRESHOLD_0_MASK   0x3f000000U
+#define  THRESHOLD_0_SHIFT  24
+#define  THRESHOLD_0(x)     ((x) << THRESHOLD_0_SHIFT)
+#define  THRESHOLD_0_GET(x) (((x) & THRESHOLD_0_MASK) >> THRESHOLD_0_SHIFT)
+#define  THRESHOLD_1_MASK   0x003f0000U
+#define  THRESHOLD_1_SHIFT  16
+#define  THRESHOLD_1(x)     ((x) << THRESHOLD_1_SHIFT)
+#define  THRESHOLD_1_GET(x) (((x) & THRESHOLD_1_MASK) >> THRESHOLD_1_SHIFT)
+#define  THRESHOLD_2_MASK   0x00003f00U
+#define  THRESHOLD_2_SHIFT  8
+#define  THRESHOLD_2(x)     ((x) << THRESHOLD_2_SHIFT)
+#define  THRESHOLD_2_GET(x) (((x) & THRESHOLD_2_MASK) >> THRESHOLD_2_SHIFT)
+#define  THRESHOLD_3_MASK   0x0000003fU
+#define  THRESHOLD_3_SHIFT  0
+#define  THRESHOLD_3(x)     ((x) << THRESHOLD_3_SHIFT)
+#define  THRESHOLD_3_GET(x) (((x) & THRESHOLD_3_MASK) >> THRESHOLD_3_SHIFT)
+
+#define SGE_TIMER_VALUE_0_AND_1 0x10b8
+#define  TIMERVALUE0_MASK   0xffff0000U
+#define  TIMERVALUE0_SHIFT  16
+#define  TIMERVALUE0(x)     ((x) << TIMERVALUE0_SHIFT)
+#define  TIMERVALUE0_GET(x) (((x) & TIMERVALUE0_MASK) >> TIMERVALUE0_SHIFT)
+#define  TIMERVALUE1_MASK   0x0000ffffU
+#define  TIMERVALUE1_SHIFT  0
+#define  TIMERVALUE1(x)     ((x) << TIMERVALUE1_SHIFT)
+#define  TIMERVALUE1_GET(x) (((x) & TIMERVALUE1_MASK) >> TIMERVALUE1_SHIFT)
+
+#define SGE_TIMER_VALUE_2_AND_3 0x10bc
+#define SGE_TIMER_VALUE_4_AND_5 0x10c0
+#define SGE_DEBUG_INDEX 0x10cc
+#define SGE_DEBUG_DATA_HIGH 0x10d0
+#define SGE_DEBUG_DATA_LOW 0x10d4
+#define SGE_INGRESS_QUEUES_PER_PAGE_PF 0x10f4
+
+#define PCIE_PF_CLI 0x44
+#define PCIE_INT_CAUSE 0x3004
+#define  UNXSPLCPLERR  0x20000000U
+#define  PCIEPINT      0x10000000U
+#define  PCIESINT      0x08000000U
+#define  RPLPERR       0x04000000U
+#define  RXWRPERR      0x02000000U
+#define  RXCPLPERR     0x01000000U
+#define  PIOTAGPERR    0x00800000U
+#define  MATAGPERR     0x00400000U
+#define  INTXCLRPERR   0x00200000U
+#define  FIDPERR       0x00100000U
+#define  CFGSNPPERR    0x00080000U
+#define  HRSPPERR      0x00040000U
+#define  HREQPERR      0x00020000U
+#define  HCNTPERR      0x00010000U
+#define  DRSPPERR      0x00008000U
+#define  DREQPERR      0x00004000U
+#define  DCNTPERR      0x00002000U
+#define  CRSPPERR      0x00001000U
+#define  CREQPERR      0x00000800U
+#define  CCNTPERR      0x00000400U
+#define  TARTAGPERR    0x00000200U
+#define  PIOREQPERR    0x00000100U
+#define  PIOCPLPERR    0x00000080U
+#define  MSIXDIPERR    0x00000040U
+#define  MSIXDATAPERR  0x00000020U
+#define  MSIXADDRHPERR 0x00000010U
+#define  MSIXADDRLPERR 0x00000008U
+#define  MSIDATAPERR   0x00000004U
+#define  MSIADDRHPERR  0x00000002U
+#define  MSIADDRLPERR  0x00000001U
+
+#define PCIE_NONFAT_ERR 0x3010
+#define PCIE_MEM_ACCESS_BASE_WIN 0x3068
+#define  PCIEOFST_MASK   0xfffffc00U
+#define  BIR_MASK        0x00000300U
+#define  BIR_SHIFT       8
+#define  BIR(x)          ((x) << BIR_SHIFT)
+#define  WINDOW_MASK     0x000000ffU
+#define  WINDOW_SHIFT    0
+#define  WINDOW(x)       ((x) << WINDOW_SHIFT)
+
+#define PCIE_CORE_UTL_SYSTEM_BUS_AGENT_STATUS 0x5908
+#define  RNPP 0x80000000U
+#define  RPCP 0x20000000U
+#define  RCIP 0x08000000U
+#define  RCCP 0x04000000U
+#define  RFTP 0x00800000U
+#define  PTRP 0x00100000U
+
+#define PCIE_CORE_UTL_PCI_EXPRESS_PORT_STATUS 0x59a4
+#define  TPCP 0x40000000U
+#define  TNPP 0x20000000U
+#define  TFTP 0x10000000U
+#define  TCAP 0x08000000U
+#define  TCIP 0x04000000U
+#define  RCAP 0x02000000U
+#define  PLUP 0x00800000U
+#define  PLDN 0x00400000U
+#define  OTDD 0x00200000U
+#define  GTRP 0x00100000U
+#define  RDPE 0x00040000U
+#define  TDCE 0x00020000U
+#define  TDUE 0x00010000U
+
+#define MC_INT_CAUSE 0x7518
+#define  ECC_UE_INT_CAUSE 0x00000004U
+#define  ECC_CE_INT_CAUSE 0x00000002U
+#define  PERR_INT_CAUSE   0x00000001U
+
+#define MC_ECC_STATUS 0x751c
+#define  ECC_CECNT_MASK   0xffff0000U
+#define  ECC_CECNT_SHIFT  16
+#define  ECC_CECNT(x)     ((x) << ECC_CECNT_SHIFT)
+#define  ECC_CECNT_GET(x) (((x) & ECC_CECNT_MASK) >> ECC_CECNT_SHIFT)
+#define  ECC_UECNT_MASK   0x0000ffffU
+#define  ECC_UECNT_SHIFT  0
+#define  ECC_UECNT(x)     ((x) << ECC_UECNT_SHIFT)
+#define  ECC_UECNT_GET(x) (((x) & ECC_UECNT_MASK) >> ECC_UECNT_SHIFT)
+
+#define MC_BIST_CMD 0x7600
+#define  START_BIST          0x80000000U
+#define  BIST_CMD_GAP_MASK   0x0000ff00U
+#define  BIST_CMD_GAP_SHIFT  8
+#define  BIST_CMD_GAP(x)     ((x) << BIST_CMD_GAP_SHIFT)
+#define  BIST_OPCODE_MASK    0x00000003U
+#define  BIST_OPCODE_SHIFT   0
+#define  BIST_OPCODE(x)      ((x) << BIST_OPCODE_SHIFT)
+
+#define MC_BIST_CMD_ADDR 0x7604
+#define MC_BIST_CMD_LEN 0x7608
+#define MC_BIST_DATA_PATTERN 0x760c
+#define  BIST_DATA_TYPE_MASK   0x0000000fU
+#define  BIST_DATA_TYPE_SHIFT  0
+#define  BIST_DATA_TYPE(x)     ((x) << BIST_DATA_TYPE_SHIFT)
+
+#define MC_BIST_STATUS_RDATA 0x7688
+
+#define MA_EXT_MEMORY_BAR 0x77c8
+#define  EXT_MEM_SIZE_MASK   0x00000fffU
+#define  EXT_MEM_SIZE_SHIFT  0
+#define  EXT_MEM_SIZE_GET(x) (((x) & EXT_MEM_SIZE_MASK) >> EXT_MEM_SIZE_SHIFT)
+
+#define MA_TARGET_MEM_ENABLE 0x77d8
+#define  EXT_MEM_ENABLE 0x00000004U
+#define  EDRAM1_ENABLE  0x00000002U
+#define  EDRAM0_ENABLE  0x00000001U
+
+#define MA_INT_CAUSE 0x77e0
+#define  MEM_PERR_INT_CAUSE 0x00000002U
+#define  MEM_WRAP_INT_CAUSE 0x00000001U
+
+#define MA_INT_WRAP_STATUS 0x77e4
+#define  MEM_WRAP_ADDRESS_MASK   0xfffffff0U
+#define  MEM_WRAP_ADDRESS_SHIFT  4
+#define  MEM_WRAP_ADDRESS_GET(x) (((x) & MEM_WRAP_ADDRESS_MASK) >> MEM_WRAP_ADDRESS_SHIFT)
+#define  MEM_WRAP_CLIENT_NUM_MASK   0x0000000fU
+#define  MEM_WRAP_CLIENT_NUM_SHIFT  0
+#define  MEM_WRAP_CLIENT_NUM_GET(x) (((x) & MEM_WRAP_CLIENT_NUM_MASK) >> MEM_WRAP_CLIENT_NUM_SHIFT)
+
+#define MA_PARITY_ERROR_STATUS 0x77f4
+
+#define EDC_0_BASE_ADDR 0x7900
+
+#define EDC_BIST_CMD 0x7904
+#define EDC_BIST_CMD_ADDR 0x7908
+#define EDC_BIST_CMD_LEN 0x790c
+#define EDC_BIST_DATA_PATTERN 0x7910
+#define EDC_BIST_STATUS_RDATA 0x7928
+#define EDC_INT_CAUSE 0x7978
+#define  ECC_UE_PAR     0x00000020U
+#define  ECC_CE_PAR     0x00000010U
+#define  PERR_PAR_CAUSE 0x00000008U
+
+#define EDC_ECC_STATUS 0x797c
+
+#define EDC_1_BASE_ADDR 0x7980
+
+#define CIM_PF_MAILBOX_DATA 0x240
+#define CIM_PF_MAILBOX_CTRL 0x280
+#define  MBMSGVALID     0x00000008U
+#define  MBINTREQ       0x00000004U
+#define  MBOWNER_MASK   0x00000003U
+#define  MBOWNER_SHIFT  0
+#define  MBOWNER(x)     ((x) << MBOWNER_SHIFT)
+#define  MBOWNER_GET(x) (((x) & MBOWNER_MASK) >> MBOWNER_SHIFT)
+
+#define CIM_PF_HOST_INT_CAUSE 0x28c
+#define  MBMSGRDYINT 0x00080000U
+
+#define CIM_HOST_INT_CAUSE 0x7b2c
+#define  TIEQOUTPARERRINT  0x00100000U
+#define  TIEQINPARERRINT   0x00080000U
+#define  MBHOSTPARERR      0x00040000U
+#define  MBUPPARERR        0x00020000U
+#define  IBQPARERR         0x0001f800U
+#define  IBQTP0PARERR      0x00010000U
+#define  IBQTP1PARERR      0x00008000U
+#define  IBQULPPARERR      0x00004000U
+#define  IBQSGELOPARERR    0x00002000U
+#define  IBQSGEHIPARERR    0x00001000U
+#define  IBQNCSIPARERR     0x00000800U
+#define  OBQPARERR         0x000007e0U
+#define  OBQULP0PARERR     0x00000400U
+#define  OBQULP1PARERR     0x00000200U
+#define  OBQULP2PARERR     0x00000100U
+#define  OBQULP3PARERR     0x00000080U
+#define  OBQSGEPARERR      0x00000040U
+#define  OBQNCSIPARERR     0x00000020U
+#define  PREFDROPINT       0x00000002U
+#define  UPACCNONZERO      0x00000001U
+
+#define CIM_HOST_UPACC_INT_CAUSE 0x7b34
+#define  EEPROMWRINT      0x40000000U
+#define  TIMEOUTMAINT     0x20000000U
+#define  TIMEOUTINT       0x10000000U
+#define  RSPOVRLOOKUPINT  0x08000000U
+#define  REQOVRLOOKUPINT  0x04000000U
+#define  BLKWRPLINT       0x02000000U
+#define  BLKRDPLINT       0x01000000U
+#define  SGLWRPLINT       0x00800000U
+#define  SGLRDPLINT       0x00400000U
+#define  BLKWRCTLINT      0x00200000U
+#define  BLKRDCTLINT      0x00100000U
+#define  SGLWRCTLINT      0x00080000U
+#define  SGLRDCTLINT      0x00040000U
+#define  BLKWREEPROMINT   0x00020000U
+#define  BLKRDEEPROMINT   0x00010000U
+#define  SGLWREEPROMINT   0x00008000U
+#define  SGLRDEEPROMINT   0x00004000U
+#define  BLKWRFLASHINT    0x00002000U
+#define  BLKRDFLASHINT    0x00001000U
+#define  SGLWRFLASHINT    0x00000800U
+#define  SGLRDFLASHINT    0x00000400U
+#define  BLKWRBOOTINT     0x00000200U
+#define  BLKRDBOOTINT     0x00000100U
+#define  SGLWRBOOTINT     0x00000080U
+#define  SGLRDBOOTINT     0x00000040U
+#define  ILLWRBEINT       0x00000020U
+#define  ILLRDBEINT       0x00000010U
+#define  ILLRDINT         0x00000008U
+#define  ILLWRINT         0x00000004U
+#define  ILLTRANSINT      0x00000002U
+#define  RSVDSPACEINT     0x00000001U
+
+#define TP_OUT_CONFIG 0x7d04
+#define  VLANEXTENABLE_MASK  0x0000f000U
+#define  VLANEXTENABLE_SHIFT 12
+
+#define TP_PARA_REG2 0x7d68
+#define  MAXRXDATA_MASK    0xffff0000U
+#define  MAXRXDATA_SHIFT   16
+#define  MAXRXDATA_GET(x) (((x) & MAXRXDATA_MASK) >> MAXRXDATA_SHIFT)
+
+#define TP_TIMER_RESOLUTION 0x7d90
+#define  TIMERRESOLUTION_MASK   0x00ff0000U
+#define  TIMERRESOLUTION_SHIFT  16
+#define  TIMERRESOLUTION_GET(x) (((x) & TIMERRESOLUTION_MASK) >> TIMERRESOLUTION_SHIFT)
+
+#define TP_SHIFT_CNT 0x7dc0
+
+#define TP_CCTRL_TABLE 0x7ddc
+#define TP_MTU_TABLE 0x7de4
+#define  MTUINDEX_MASK   0xff000000U
+#define  MTUINDEX_SHIFT  24
+#define  MTUINDEX(x)     ((x) << MTUINDEX_SHIFT)
+#define  MTUWIDTH_MASK   0x000f0000U
+#define  MTUWIDTH_SHIFT  16
+#define  MTUWIDTH(x)     ((x) << MTUWIDTH_SHIFT)
+#define  MTUWIDTH_GET(x) (((x) & MTUWIDTH_MASK) >> MTUWIDTH_SHIFT)
+#define  MTUVALUE_MASK   0x00003fffU
+#define  MTUVALUE_SHIFT  0
+#define  MTUVALUE(x)     ((x) << MTUVALUE_SHIFT)
+#define  MTUVALUE_GET(x) (((x) & MTUVALUE_MASK) >> MTUVALUE_SHIFT)
+
+#define TP_RSS_LKP_TABLE 0x7dec
+#define  LKPTBLROWVLD        0x80000000U
+#define  LKPTBLQUEUE1_MASK   0x000ffc00U
+#define  LKPTBLQUEUE1_SHIFT  10
+#define  LKPTBLQUEUE1(x)     ((x) << LKPTBLQUEUE1_SHIFT)
+#define  LKPTBLQUEUE1_GET(x) (((x) & LKPTBLQUEUE1_MASK) >> LKPTBLQUEUE1_SHIFT)
+#define  LKPTBLQUEUE0_MASK   0x000003ffU
+#define  LKPTBLQUEUE0_SHIFT  0
+#define  LKPTBLQUEUE0(x)     ((x) << LKPTBLQUEUE0_SHIFT)
+#define  LKPTBLQUEUE0_GET(x) (((x) & LKPTBLQUEUE0_MASK) >> LKPTBLQUEUE0_SHIFT)
+
+#define TP_PIO_ADDR 0x7e40
+#define TP_PIO_DATA 0x7e44
+#define TP_MIB_INDEX 0x7e50
+#define TP_MIB_DATA 0x7e54
+#define TP_INT_CAUSE 0x7e74
+#define  FLMTXFLSTEMPTY 0x40000000U
+
+#define TP_INGRESS_CONFIG 0x141
+#define  VNIC                0x00000800U
+#define  CSUM_HAS_PSEUDO_HDR 0x00000400U
+#define  RM_OVLAN            0x00000200U
+#define  LOOKUPEVERYPKT      0x00000100U
+
+#define TP_MIB_MAC_IN_ERR_0 0x0
+#define TP_MIB_TCP_OUT_RST 0xc
+#define TP_MIB_TCP_IN_SEG_HI 0x10
+#define TP_MIB_TCP_IN_SEG_LO 0x11
+#define TP_MIB_TCP_OUT_SEG_HI 0x12
+#define TP_MIB_TCP_OUT_SEG_LO 0x13
+#define TP_MIB_TCP_RXT_SEG_HI 0x14
+#define TP_MIB_TCP_RXT_SEG_LO 0x15
+#define TP_MIB_TNL_CNG_DROP_0 0x18
+#define TP_MIB_TCP_V6IN_ERR_0 0x28
+#define TP_MIB_TCP_V6OUT_RST 0x2c
+#define TP_MIB_OFD_ARP_DROP 0x36
+#define TP_MIB_TNL_DROP_0 0x44
+#define TP_MIB_OFD_VLN_DROP_0 0x58
+
+#define ULP_TX_INT_CAUSE 0x8dcc
+#define  PBL_BOUND_ERR_CH3 0x80000000U
+#define  PBL_BOUND_ERR_CH2 0x40000000U
+#define  PBL_BOUND_ERR_CH1 0x20000000U
+#define  PBL_BOUND_ERR_CH0 0x10000000U
+
+#define PM_RX_INT_CAUSE 0x8fdc
+#define  ZERO_E_CMD_ERROR     0x00400000U
+#define  PMRX_FRAMING_ERROR   0x003ffff0U
+#define  OCSPI_PAR_ERROR      0x00000008U
+#define  DB_OPTIONS_PAR_ERROR 0x00000004U
+#define  IESPI_PAR_ERROR      0x00000002U
+#define  E_PCMD_PAR_ERROR     0x00000001U
+
+#define PM_TX_INT_CAUSE 0x8ffc
+#define  PCMD_LEN_OVFL0     0x80000000U
+#define  PCMD_LEN_OVFL1     0x40000000U
+#define  PCMD_LEN_OVFL2     0x20000000U
+#define  ZERO_C_CMD_ERROR   0x10000000U
+#define  PMTX_FRAMING_ERROR 0x0ffffff0U
+#define  OESPI_PAR_ERROR    0x00000008U
+#define  ICSPI_PAR_ERROR    0x00000002U
+#define  C_PCMD_PAR_ERROR   0x00000001U
+
+#define MPS_PORT_STAT_TX_PORT_BYTES_L 0x400
+#define MPS_PORT_STAT_TX_PORT_BYTES_H 0x404
+#define MPS_PORT_STAT_TX_PORT_FRAMES_L 0x408
+#define MPS_PORT_STAT_TX_PORT_FRAMES_H 0x40c
+#define MPS_PORT_STAT_TX_PORT_BCAST_L 0x410
+#define MPS_PORT_STAT_TX_PORT_BCAST_H 0x414
+#define MPS_PORT_STAT_TX_PORT_MCAST_L 0x418
+#define MPS_PORT_STAT_TX_PORT_MCAST_H 0x41c
+#define MPS_PORT_STAT_TX_PORT_UCAST_L 0x420
+#define MPS_PORT_STAT_TX_PORT_UCAST_H 0x424
+#define MPS_PORT_STAT_TX_PORT_ERROR_L 0x428
+#define MPS_PORT_STAT_TX_PORT_ERROR_H 0x42c
+#define MPS_PORT_STAT_TX_PORT_64B_L 0x430
+#define MPS_PORT_STAT_TX_PORT_64B_H 0x434
+#define MPS_PORT_STAT_TX_PORT_65B_127B_L 0x438
+#define MPS_PORT_STAT_TX_PORT_65B_127B_H 0x43c
+#define MPS_PORT_STAT_TX_PORT_128B_255B_L 0x440
+#define MPS_PORT_STAT_TX_PORT_128B_255B_H 0x444
+#define MPS_PORT_STAT_TX_PORT_256B_511B_L 0x448
+#define MPS_PORT_STAT_TX_PORT_256B_511B_H 0x44c
+#define MPS_PORT_STAT_TX_PORT_512B_1023B_L 0x450
+#define MPS_PORT_STAT_TX_PORT_512B_1023B_H 0x454
+#define MPS_PORT_STAT_TX_PORT_1024B_1518B_L 0x458
+#define MPS_PORT_STAT_TX_PORT_1024B_1518B_H 0x45c
+#define MPS_PORT_STAT_TX_PORT_1519B_MAX_L 0x460
+#define MPS_PORT_STAT_TX_PORT_1519B_MAX_H 0x464
+#define MPS_PORT_STAT_TX_PORT_DROP_L 0x468
+#define MPS_PORT_STAT_TX_PORT_DROP_H 0x46c
+#define MPS_PORT_STAT_TX_PORT_PAUSE_L 0x470
+#define MPS_PORT_STAT_TX_PORT_PAUSE_H 0x474
+#define MPS_PORT_STAT_TX_PORT_PPP0_L 0x478
+#define MPS_PORT_STAT_TX_PORT_PPP0_H 0x47c
+#define MPS_PORT_STAT_TX_PORT_PPP1_L 0x480
+#define MPS_PORT_STAT_TX_PORT_PPP1_H 0x484
+#define MPS_PORT_STAT_TX_PORT_PPP2_L 0x488
+#define MPS_PORT_STAT_TX_PORT_PPP2_H 0x48c
+#define MPS_PORT_STAT_TX_PORT_PPP3_L 0x490
+#define MPS_PORT_STAT_TX_PORT_PPP3_H 0x494
+#define MPS_PORT_STAT_TX_PORT_PPP4_L 0x498
+#define MPS_PORT_STAT_TX_PORT_PPP4_H 0x49c
+#define MPS_PORT_STAT_TX_PORT_PPP5_L 0x4a0
+#define MPS_PORT_STAT_TX_PORT_PPP5_H 0x4a4
+#define MPS_PORT_STAT_TX_PORT_PPP6_L 0x4a8
+#define MPS_PORT_STAT_TX_PORT_PPP6_H 0x4ac
+#define MPS_PORT_STAT_TX_PORT_PPP7_L 0x4b0
+#define MPS_PORT_STAT_TX_PORT_PPP7_H 0x4b4
+#define MPS_PORT_STAT_LB_PORT_BYTES_L 0x4c0
+#define MPS_PORT_STAT_LB_PORT_BYTES_H 0x4c4
+#define MPS_PORT_STAT_LB_PORT_FRAMES_L 0x4c8
+#define MPS_PORT_STAT_LB_PORT_FRAMES_H 0x4cc
+#define MPS_PORT_STAT_LB_PORT_BCAST_L 0x4d0
+#define MPS_PORT_STAT_LB_PORT_BCAST_H 0x4d4
+#define MPS_PORT_STAT_LB_PORT_MCAST_L 0x4d8
+#define MPS_PORT_STAT_LB_PORT_MCAST_H 0x4dc
+#define MPS_PORT_STAT_LB_PORT_UCAST_L 0x4e0
+#define MPS_PORT_STAT_LB_PORT_UCAST_H 0x4e4
+#define MPS_PORT_STAT_LB_PORT_ERROR_L 0x4e8
+#define MPS_PORT_STAT_LB_PORT_ERROR_H 0x4ec
+#define MPS_PORT_STAT_LB_PORT_64B_L 0x4f0
+#define MPS_PORT_STAT_LB_PORT_64B_H 0x4f4
+#define MPS_PORT_STAT_LB_PORT_65B_127B_L 0x4f8
+#define MPS_PORT_STAT_LB_PORT_65B_127B_H 0x4fc
+#define MPS_PORT_STAT_LB_PORT_128B_255B_L 0x500
+#define MPS_PORT_STAT_LB_PORT_128B_255B_H 0x504
+#define MPS_PORT_STAT_LB_PORT_256B_511B_L 0x508
+#define MPS_PORT_STAT_LB_PORT_256B_511B_H 0x50c
+#define MPS_PORT_STAT_LB_PORT_512B_1023B_L 0x510
+#define MPS_PORT_STAT_LB_PORT_512B_1023B_H 0x514
+#define MPS_PORT_STAT_LB_PORT_1024B_1518B_L 0x518
+#define MPS_PORT_STAT_LB_PORT_1024B_1518B_H 0x51c
+#define MPS_PORT_STAT_LB_PORT_1519B_MAX_L 0x520
+#define MPS_PORT_STAT_LB_PORT_1519B_MAX_H 0x524
+#define MPS_PORT_STAT_LB_PORT_DROP_FRAMES 0x528
+#define MPS_PORT_STAT_RX_PORT_BYTES_L 0x540
+#define MPS_PORT_STAT_RX_PORT_BYTES_H 0x544
+#define MPS_PORT_STAT_RX_PORT_FRAMES_L 0x548
+#define MPS_PORT_STAT_RX_PORT_FRAMES_H 0x54c
+#define MPS_PORT_STAT_RX_PORT_BCAST_L 0x550
+#define MPS_PORT_STAT_RX_PORT_BCAST_H 0x554
+#define MPS_PORT_STAT_RX_PORT_MCAST_L 0x558
+#define MPS_PORT_STAT_RX_PORT_MCAST_H 0x55c
+#define MPS_PORT_STAT_RX_PORT_UCAST_L 0x560
+#define MPS_PORT_STAT_RX_PORT_UCAST_H 0x564
+#define MPS_PORT_STAT_RX_PORT_MTU_ERROR_L 0x568
+#define MPS_PORT_STAT_RX_PORT_MTU_ERROR_H 0x56c
+#define MPS_PORT_STAT_RX_PORT_MTU_CRC_ERROR_L 0x570
+#define MPS_PORT_STAT_RX_PORT_MTU_CRC_ERROR_H 0x574
+#define MPS_PORT_STAT_RX_PORT_CRC_ERROR_L 0x578
+#define MPS_PORT_STAT_RX_PORT_CRC_ERROR_H 0x57c
+#define MPS_PORT_STAT_RX_PORT_LEN_ERROR_L 0x580
+#define MPS_PORT_STAT_RX_PORT_LEN_ERROR_H 0x584
+#define MPS_PORT_STAT_RX_PORT_SYM_ERROR_L 0x588
+#define MPS_PORT_STAT_RX_PORT_SYM_ERROR_H 0x58c
+#define MPS_PORT_STAT_RX_PORT_64B_L 0x590
+#define MPS_PORT_STAT_RX_PORT_64B_H 0x594
+#define MPS_PORT_STAT_RX_PORT_65B_127B_L 0x598
+#define MPS_PORT_STAT_RX_PORT_65B_127B_H 0x59c
+#define MPS_PORT_STAT_RX_PORT_128B_255B_L 0x5a0
+#define MPS_PORT_STAT_RX_PORT_128B_255B_H 0x5a4
+#define MPS_PORT_STAT_RX_PORT_256B_511B_L 0x5a8
+#define MPS_PORT_STAT_RX_PORT_256B_511B_H 0x5ac
+#define MPS_PORT_STAT_RX_PORT_512B_1023B_L 0x5b0
+#define MPS_PORT_STAT_RX_PORT_512B_1023B_H 0x5b4
+#define MPS_PORT_STAT_RX_PORT_1024B_1518B_L 0x5b8
+#define MPS_PORT_STAT_RX_PORT_1024B_1518B_H 0x5bc
+#define MPS_PORT_STAT_RX_PORT_1519B_MAX_L 0x5c0
+#define MPS_PORT_STAT_RX_PORT_1519B_MAX_H 0x5c4
+#define MPS_PORT_STAT_RX_PORT_PAUSE_L 0x5c8
+#define MPS_PORT_STAT_RX_PORT_PAUSE_H 0x5cc
+#define MPS_PORT_STAT_RX_PORT_PPP0_L 0x5d0
+#define MPS_PORT_STAT_RX_PORT_PPP0_H 0x5d4
+#define MPS_PORT_STAT_RX_PORT_PPP1_L 0x5d8
+#define MPS_PORT_STAT_RX_PORT_PPP1_H 0x5dc
+#define MPS_PORT_STAT_RX_PORT_PPP2_L 0x5e0
+#define MPS_PORT_STAT_RX_PORT_PPP2_H 0x5e4
+#define MPS_PORT_STAT_RX_PORT_PPP3_L 0x5e8
+#define MPS_PORT_STAT_RX_PORT_PPP3_H 0x5ec
+#define MPS_PORT_STAT_RX_PORT_PPP4_L 0x5f0
+#define MPS_PORT_STAT_RX_PORT_PPP4_H 0x5f4
+#define MPS_PORT_STAT_RX_PORT_PPP5_L 0x5f8
+#define MPS_PORT_STAT_RX_PORT_PPP5_H 0x5fc
+#define MPS_PORT_STAT_RX_PORT_PPP6_L 0x600
+#define MPS_PORT_STAT_RX_PORT_PPP6_H 0x604
+#define MPS_PORT_STAT_RX_PORT_PPP7_L 0x608
+#define MPS_PORT_STAT_RX_PORT_PPP7_H 0x60c
+#define MPS_PORT_STAT_RX_PORT_LESS_64B_L 0x610
+#define MPS_PORT_STAT_RX_PORT_LESS_64B_H 0x614
+#define MPS_CMN_CTL 0x9000
+#define  NUMPORTS_MASK   0x00000003U
+#define  NUMPORTS_SHIFT  0
+#define  NUMPORTS_GET(x) (((x) & NUMPORTS_MASK) >> NUMPORTS_SHIFT)
+
+#define MPS_INT_CAUSE 0x9008
+#define  STATINT 0x00000020U
+#define  TXINT   0x00000010U
+#define  RXINT   0x00000008U
+#define  TRCINT  0x00000004U
+#define  CLSINT  0x00000002U
+#define  PLINT   0x00000001U
+
+#define MPS_TX_INT_CAUSE 0x9408
+#define  PORTERR    0x00010000U
+#define  FRMERR     0x00008000U
+#define  SECNTERR   0x00004000U
+#define  BUBBLE     0x00002000U
+#define  TXDESCFIFO 0x00001e00U
+#define  TXDATAFIFO 0x000001e0U
+#define  NCSIFIFO   0x00000010U
+#define  TPFIFO     0x0000000fU
+
+#define MPS_STAT_PERR_INT_CAUSE_SRAM 0x9614
+#define MPS_STAT_PERR_INT_CAUSE_TX_FIFO 0x9620
+#define MPS_STAT_PERR_INT_CAUSE_RX_FIFO 0x962c
+
+#define MPS_STAT_RX_BG_0_MAC_DROP_FRAME_L 0x9640
+#define MPS_STAT_RX_BG_0_MAC_DROP_FRAME_H 0x9644
+#define MPS_STAT_RX_BG_1_MAC_DROP_FRAME_L 0x9648
+#define MPS_STAT_RX_BG_1_MAC_DROP_FRAME_H 0x964c
+#define MPS_STAT_RX_BG_2_MAC_DROP_FRAME_L 0x9650
+#define MPS_STAT_RX_BG_2_MAC_DROP_FRAME_H 0x9654
+#define MPS_STAT_RX_BG_3_MAC_DROP_FRAME_L 0x9658
+#define MPS_STAT_RX_BG_3_MAC_DROP_FRAME_H 0x965c
+#define MPS_STAT_RX_BG_0_LB_DROP_FRAME_L 0x9660
+#define MPS_STAT_RX_BG_0_LB_DROP_FRAME_H 0x9664
+#define MPS_STAT_RX_BG_1_LB_DROP_FRAME_L 0x9668
+#define MPS_STAT_RX_BG_1_LB_DROP_FRAME_H 0x966c
+#define MPS_STAT_RX_BG_2_LB_DROP_FRAME_L 0x9670
+#define MPS_STAT_RX_BG_2_LB_DROP_FRAME_H 0x9674
+#define MPS_STAT_RX_BG_3_LB_DROP_FRAME_L 0x9678
+#define MPS_STAT_RX_BG_3_LB_DROP_FRAME_H 0x967c
+#define MPS_STAT_RX_BG_0_MAC_TRUNC_FRAME_L 0x9680
+#define MPS_STAT_RX_BG_0_MAC_TRUNC_FRAME_H 0x9684
+#define MPS_STAT_RX_BG_1_MAC_TRUNC_FRAME_L 0x9688
+#define MPS_STAT_RX_BG_1_MAC_TRUNC_FRAME_H 0x968c
+#define MPS_STAT_RX_BG_2_MAC_TRUNC_FRAME_L 0x9690
+#define MPS_STAT_RX_BG_2_MAC_TRUNC_FRAME_H 0x9694
+#define MPS_STAT_RX_BG_3_MAC_TRUNC_FRAME_L 0x9698
+#define MPS_STAT_RX_BG_3_MAC_TRUNC_FRAME_H 0x969c
+#define MPS_STAT_RX_BG_0_LB_TRUNC_FRAME_L 0x96a0
+#define MPS_STAT_RX_BG_0_LB_TRUNC_FRAME_H 0x96a4
+#define MPS_STAT_RX_BG_1_LB_TRUNC_FRAME_L 0x96a8
+#define MPS_STAT_RX_BG_1_LB_TRUNC_FRAME_H 0x96ac
+#define MPS_STAT_RX_BG_2_LB_TRUNC_FRAME_L 0x96b0
+#define MPS_STAT_RX_BG_2_LB_TRUNC_FRAME_H 0x96b4
+#define MPS_STAT_RX_BG_3_LB_TRUNC_FRAME_L 0x96b8
+#define MPS_STAT_RX_BG_3_LB_TRUNC_FRAME_H 0x96bc
+#define MPS_TRC_CFG 0x9800
+#define  TRCFIFOEMPTY       0x00000010U
+#define  TRCIGNOREDROPINPUT 0x00000008U
+#define  TRCKEEPDUPLICATES  0x00000004U
+#define  TRCEN              0x00000002U
+#define  TRCMULTIFILTER     0x00000001U
+
+#define MPS_TRC_RSS_CONTROL 0x9808
+#define  RSSCONTROL_MASK    0x00ff0000U
+#define  RSSCONTROL_SHIFT   16
+#define  RSSCONTROL(x)      ((x) << RSSCONTROL_SHIFT)
+#define  QUEUENUMBER_MASK   0x0000ffffU
+#define  QUEUENUMBER_SHIFT  0
+#define  QUEUENUMBER(x)     ((x) << QUEUENUMBER_SHIFT)
+
+#define MPS_TRC_FILTER_MATCH_CTL_A 0x9810
+#define  TFINVERTMATCH   0x01000000U
+#define  TFPKTTOOLARGE   0x00800000U
+#define  TFEN            0x00400000U
+#define  TFPORT_MASK     0x003c0000U
+#define  TFPORT_SHIFT    18
+#define  TFPORT(x)       ((x) << TFPORT_SHIFT)
+#define  TFPORT_GET(x)   (((x) & TFPORT_MASK) >> TFPORT_SHIFT)
+#define  TFDROP          0x00020000U
+#define  TFSOPEOPERR     0x00010000U
+#define  TFLENGTH_MASK   0x00001f00U
+#define  TFLENGTH_SHIFT  8
+#define  TFLENGTH(x)     ((x) << TFLENGTH_SHIFT)
+#define  TFLENGTH_GET(x) (((x) & TFLENGTH_MASK) >> TFLENGTH_SHIFT)
+#define  TFOFFSET_MASK   0x0000001fU
+#define  TFOFFSET_SHIFT  0
+#define  TFOFFSET(x)     ((x) << TFOFFSET_SHIFT)
+#define  TFOFFSET_GET(x) (((x) & TFOFFSET_MASK) >> TFOFFSET_SHIFT)
+
+#define MPS_TRC_FILTER_MATCH_CTL_B 0x9820
+#define  TFMINPKTSIZE_MASK   0x01ff0000U
+#define  TFMINPKTSIZE_SHIFT  16
+#define  TFMINPKTSIZE(x)     ((x) << TFMINPKTSIZE_SHIFT)
+#define  TFMINPKTSIZE_GET(x) (((x) & TFMINPKTSIZE_MASK) >> TFMINPKTSIZE_SHIFT)
+#define  TFCAPTUREMAX_MASK   0x00003fffU
+#define  TFCAPTUREMAX_SHIFT  0
+#define  TFCAPTUREMAX(x)     ((x) << TFCAPTUREMAX_SHIFT)
+#define  TFCAPTUREMAX_GET(x) (((x) & TFCAPTUREMAX_MASK) >> TFCAPTUREMAX_SHIFT)
+
+#define MPS_TRC_INT_CAUSE 0x985c
+#define  MISCPERR 0x00000100U
+#define  PKTFIFO  0x000000f0U
+#define  FILTMEM  0x0000000fU
+
+#define MPS_TRC_FILTER0_MATCH 0x9c00
+#define MPS_TRC_FILTER0_DONT_CARE 0x9c80
+#define MPS_TRC_FILTER1_MATCH 0x9d00
+#define MPS_CLS_INT_CAUSE 0xd028
+#define  PLERRENB  0x00000008U
+#define  HASHSRAM  0x00000004U
+#define  MATCHTCAM 0x00000002U
+#define  MATCHSRAM 0x00000001U
+
+#define MPS_RX_PERR_INT_CAUSE 0x11074
+
+#define CPL_INTR_CAUSE 0x19054
+#define  CIM_OP_MAP_PERR   0x00000020U
+#define  CIM_OVFL_ERROR    0x00000010U
+#define  TP_FRAMING_ERROR  0x00000008U
+#define  SGE_FRAMING_ERROR 0x00000004U
+#define  CIM_FRAMING_ERROR 0x00000002U
+#define  ZERO_SWITCH_ERROR 0x00000001U
+
+#define SMB_INT_CAUSE 0x19090
+#define  MSTTXFIFOPARINT 0x00200000U
+#define  MSTRXFIFOPARINT 0x00100000U
+#define  SLVFIFOPARINT   0x00080000U
+
+#define ULP_RX_INT_CAUSE 0x19158
+#define ULP_RX_ISCSI_TAGMASK 0x19164
+#define ULP_RX_ISCSI_PSZ 0x19168
+#define  HPZ3_MASK   0x0f000000U
+#define  HPZ3_SHIFT  24
+#define  HPZ3(x)     ((x) << HPZ3_SHIFT)
+#define  HPZ2_MASK   0x000f0000U
+#define  HPZ2_SHIFT  16
+#define  HPZ2(x)     ((x) << HPZ2_SHIFT)
+#define  HPZ1_MASK   0x00000f00U
+#define  HPZ1_SHIFT  8
+#define  HPZ1(x)     ((x) << HPZ1_SHIFT)
+#define  HPZ0_MASK   0x0000000fU
+#define  HPZ0_SHIFT  0
+#define  HPZ0(x)     ((x) << HPZ0_SHIFT)
+
+#define ULP_RX_TDDP_PSZ 0x19178
+
+#define SF_DATA 0x193f8
+#define SF_OP 0x193fc
+#define  BUSY          0x80000000U
+#define  SF_LOCK       0x00000010U
+#define  SF_CONT       0x00000008U
+#define  BYTECNT_MASK  0x00000006U
+#define  BYTECNT_SHIFT 1
+#define  BYTECNT(x)    ((x) << BYTECNT_SHIFT)
+#define  OP_WR         0x00000001U
+
+#define PL_PF_INT_CAUSE 0x3c0
+#define  PFSW  0x00000008U
+#define  PFSGE 0x00000004U
+#define  PFCIM 0x00000002U
+#define  PFMPS 0x00000001U
+
+#define PL_PF_INT_ENABLE 0x3c4
+#define PL_PF_CTL 0x3c8
+#define  SWINT 0x00000001U
+
+#define PL_WHOAMI 0x19400
+#define  SOURCEPF_MASK   0x00000700U
+#define  SOURCEPF_SHIFT  8
+#define  SOURCEPF(x)     ((x) << SOURCEPF_SHIFT)
+#define  SOURCEPF_GET(x) (((x) & SOURCEPF_MASK) >> SOURCEPF_SHIFT)
+#define  ISVF            0x00000080U
+#define  VFID_MASK       0x0000007fU
+#define  VFID_SHIFT      0
+#define  VFID(x)         ((x) << VFID_SHIFT)
+#define  VFID_GET(x)     (((x) & VFID_MASK) >> VFID_SHIFT)
+
+#define PL_INT_CAUSE 0x1940c
+#define  ULP_TX     0x08000000U
+#define  SGE        0x04000000U
+#define  HMA        0x02000000U
+#define  CPL_SWITCH 0x01000000U
+#define  ULP_RX     0x00800000U
+#define  PM_RX      0x00400000U
+#define  PM_TX      0x00200000U
+#define  MA         0x00100000U
+#define  TP         0x00080000U
+#define  LE         0x00040000U
+#define  EDC1       0x00020000U
+#define  EDC0       0x00010000U
+#define  MC         0x00008000U
+#define  PCIE       0x00004000U
+#define  PMU        0x00002000U
+#define  XGMAC_KR1  0x00001000U
+#define  XGMAC_KR0  0x00000800U
+#define  XGMAC1     0x00000400U
+#define  XGMAC0     0x00000200U
+#define  SMB        0x00000100U
+#define  SF         0x00000080U
+#define  PL         0x00000040U
+#define  NCSI       0x00000020U
+#define  MPS        0x00000010U
+#define  MI         0x00000008U
+#define  DBG        0x00000004U
+#define  I2CM       0x00000002U
+#define  CIM        0x00000001U
+
+#define PL_INT_MAP0 0x19414
+#define PL_RST 0x19428
+#define  PIORST     0x00000002U
+#define  PIORSTMODE 0x00000001U
+
+#define PL_PL_INT_CAUSE 0x19430
+#define  FATALPERR 0x00000010U
+#define  PERRVFID  0x00000001U
+
+#define PL_REV 0x1943c
+
+#define LE_DB_CONFIG 0x19c04
+#define  HASHEN 0x00100000U
+
+#define LE_DB_SERVER_INDEX 0x19c18
+#define LE_DB_ACT_CNT_IPV4 0x19c20
+#define LE_DB_ACT_CNT_IPV6 0x19c24
+
+#define LE_DB_INT_CAUSE 0x19c3c
+#define  REQQPARERR 0x00010000U
+#define  UNKNOWNCMD 0x00008000U
+#define  PARITYERR  0x00000040U
+#define  LIPMISS    0x00000020U
+#define  LIP0       0x00000010U
+
+#define LE_DB_TID_HASHBASE 0x19df8
+
+#define NCSI_INT_CAUSE 0x1a0d8
+#define  CIM_DM_PRTY_ERR 0x00000100U
+#define  MPS_DM_PRTY_ERR 0x00000080U
+#define  TXFIFO_PRTY_ERR 0x00000002U
+#define  RXFIFO_PRTY_ERR 0x00000001U
+
+#define XGMAC_PORT_CFG2 0x1018
+#define  PATEN   0x00040000U
+#define  MAGICEN 0x00020000U
+
+#define XGMAC_PORT_MAGIC_MACID_LO 0x1024
+#define XGMAC_PORT_MAGIC_MACID_HI 0x1028
+
+#define XGMAC_PORT_EPIO_DATA0 0x10c0
+#define XGMAC_PORT_EPIO_DATA1 0x10c4
+#define XGMAC_PORT_EPIO_DATA2 0x10c8
+#define XGMAC_PORT_EPIO_DATA3 0x10cc
+#define XGMAC_PORT_EPIO_OP 0x10d0
+#define  EPIOWR         0x00000100U
+#define  ADDRESS_MASK   0x000000ffU
+#define  ADDRESS_SHIFT  0
+#define  ADDRESS(x)     ((x) << ADDRESS_SHIFT)
+
+#define XGMAC_PORT_INT_CAUSE 0x10dc
+#endif /* __T4_REGS_H */
diff --git a/drivers/net/cxgb4/t4fw_api.h b/drivers/net/cxgb4/t4fw_api.h
new file mode 100644
index 0000000..ef2854d
--- /dev/null
+++ b/drivers/net/cxgb4/t4fw_api.h
@@ -0,0 +1,1580 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2009-2010 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef _T4FW_INTERFACE_H_
+#define _T4FW_INTERFACE_H_
+
+#define FW_T4VF_SGE_BASE_ADDR      0x0000
+#define FW_T4VF_MPS_BASE_ADDR      0x0100
+#define FW_T4VF_PL_BASE_ADDR       0x0200
+#define FW_T4VF_MBDATA_BASE_ADDR   0x0240
+#define FW_T4VF_CIM_BASE_ADDR      0x0300
+
+enum fw_wr_opcodes {
+	FW_FILTER_WR                   = 0x02,
+	FW_ULPTX_WR                    = 0x04,
+	FW_TP_WR                       = 0x05,
+	FW_ETH_TX_PKT_WR               = 0x08,
+	FW_FLOWC_WR                    = 0x0a,
+	FW_OFLD_TX_DATA_WR             = 0x0b,
+	FW_CMD_WR                      = 0x10,
+	FW_ETH_TX_PKT_VM_WR            = 0x11,
+	FW_RI_RES_WR                   = 0x0c,
+	FW_RI_INIT_WR                  = 0x0d,
+	FW_RI_RDMA_WRITE_WR            = 0x14,
+	FW_RI_SEND_WR                  = 0x15,
+	FW_RI_RDMA_READ_WR             = 0x16,
+	FW_RI_RECV_WR                  = 0x17,
+	FW_RI_BIND_MW_WR               = 0x18,
+	FW_RI_FR_NSMR_WR               = 0x19,
+	FW_RI_INV_LSTAG_WR             = 0x1a,
+	FW_LASTC2E_WR                  = 0x40
+};
+
+struct fw_wr_hdr {
+	__be32 hi;
+	__be32 lo;
+};
+
+#define FW_WR_OP(x)	 ((x) << 24)
+#define FW_WR_ATOMIC(x)	 ((x) << 23)
+#define FW_WR_FLUSH(x)   ((x) << 22)
+#define FW_WR_COMPL(x)   ((x) << 21)
+#define FW_WR_IMMDLEN(x) ((x) << 0)
+
+#define FW_WR_EQUIQ	(1U << 31)
+#define FW_WR_EQUEQ	(1U << 30)
+#define FW_WR_FLOWID(x)	((x) << 8)
+#define FW_WR_LEN16(x)	((x) << 0)
+
+struct fw_ulptx_wr {
+	__be32 op_to_compl;
+	__be32 flowid_len16;
+	u64 cookie;
+};
+
+struct fw_tp_wr {
+	__be32 op_to_immdlen;
+	__be32 flowid_len16;
+	u64 cookie;
+};
+
+struct fw_eth_tx_pkt_wr {
+	__be32 op_immdlen;
+	__be32 equiq_to_len16;
+	__be64 r3;
+};
+
+enum fw_flowc_mnem {
+	FW_FLOWC_MNEM_PFNVFN,		/* PFN [15:8] VFN [7:0] */
+	FW_FLOWC_MNEM_CH,
+	FW_FLOWC_MNEM_PORT,
+	FW_FLOWC_MNEM_IQID,
+	FW_FLOWC_MNEM_SNDNXT,
+	FW_FLOWC_MNEM_RCVNXT,
+	FW_FLOWC_MNEM_SNDBUF,
+	FW_FLOWC_MNEM_MSS,
+};
+
+struct fw_flowc_mnemval {
+	u8 mnemonic;
+	u8 r4[3];
+	__be32 val;
+};
+
+struct fw_flowc_wr {
+	__be32 op_to_nparams;
+#define FW_FLOWC_WR_NPARAMS(x)	((x) << 0)
+	__be32 flowid_len16;
+	struct fw_flowc_mnemval mnemval[0];
+};
+
+struct fw_ofld_tx_data_wr {
+	__be32 op_to_immdlen;
+	__be32 flowid_len16;
+	__be32 plen;
+	__be32 tunnel_to_proxy;
+#define FW_OFLD_TX_DATA_WR_TUNNEL(x)	 ((x) << 19)
+#define FW_OFLD_TX_DATA_WR_SAVE(x)	 ((x) << 18)
+#define FW_OFLD_TX_DATA_WR_FLUSH(x)	 ((x) << 17)
+#define FW_OFLD_TX_DATA_WR_URGENT(x)	 ((x) << 16)
+#define FW_OFLD_TX_DATA_WR_MORE(x)	 ((x) << 15)
+#define FW_OFLD_TX_DATA_WR_SHOVE(x)	 ((x) << 14)
+#define FW_OFLD_TX_DATA_WR_ULPMODE(x)	 ((x) << 10)
+#define FW_OFLD_TX_DATA_WR_ULPSUBMODE(x) ((x) << 6)
+};
+
+struct fw_cmd_wr {
+	__be32 op_dma;
+#define FW_CMD_WR_DMA (1U << 17)
+	__be32 len16_pkd;
+	__be64 cookie_daddr;
+};
+
+struct fw_eth_tx_pkt_vm_wr {
+	__be32 op_immdlen;
+	__be32 equiq_to_len16;
+	__be32 r3[2];
+	u8 ethmacdst[6];
+	u8 ethmacsrc[6];
+	__be16 ethtype;
+	__be16 vlantci;
+};
+
+#define FW_CMD_MAX_TIMEOUT 3000
+
+enum fw_cmd_opcodes {
+	FW_LDST_CMD                    = 0x01,
+	FW_RESET_CMD                   = 0x03,
+	FW_HELLO_CMD                   = 0x04,
+	FW_BYE_CMD                     = 0x05,
+	FW_INITIALIZE_CMD              = 0x06,
+	FW_CAPS_CONFIG_CMD             = 0x07,
+	FW_PARAMS_CMD                  = 0x08,
+	FW_PFVF_CMD                    = 0x09,
+	FW_IQ_CMD                      = 0x10,
+	FW_EQ_MNGT_CMD                 = 0x11,
+	FW_EQ_ETH_CMD                  = 0x12,
+	FW_EQ_CTRL_CMD                 = 0x13,
+	FW_EQ_OFLD_CMD                 = 0x21,
+	FW_VI_CMD                      = 0x14,
+	FW_VI_MAC_CMD                  = 0x15,
+	FW_VI_RXMODE_CMD               = 0x16,
+	FW_VI_ENABLE_CMD               = 0x17,
+	FW_ACL_MAC_CMD                 = 0x18,
+	FW_ACL_VLAN_CMD                = 0x19,
+	FW_VI_STATS_CMD                = 0x1a,
+	FW_PORT_CMD                    = 0x1b,
+	FW_PORT_STATS_CMD              = 0x1c,
+	FW_PORT_LB_STATS_CMD           = 0x1d,
+	FW_PORT_TRACE_CMD              = 0x1e,
+	FW_PORT_TRACE_MMAP_CMD         = 0x1f,
+	FW_RSS_IND_TBL_CMD             = 0x20,
+	FW_RSS_GLB_CONFIG_CMD          = 0x22,
+	FW_RSS_VI_CONFIG_CMD           = 0x23,
+	FW_LASTC2E_CMD                 = 0x40,
+	FW_ERROR_CMD                   = 0x80,
+	FW_DEBUG_CMD                   = 0x81,
+};
+
+enum fw_cmd_cap {
+	FW_CMD_CAP_PF                  = 0x01,
+	FW_CMD_CAP_DMAQ                = 0x02,
+	FW_CMD_CAP_PORT                = 0x04,
+	FW_CMD_CAP_PORTPROMISC         = 0x08,
+	FW_CMD_CAP_PORTSTATS           = 0x10,
+	FW_CMD_CAP_VF                  = 0x80,
+};
+
+/*
+ * Generic command header flit0
+ */
+struct fw_cmd_hdr {
+	__be32 hi;
+	__be32 lo;
+};
+
+#define FW_CMD_OP(x)		((x) << 24)
+#define FW_CMD_OP_GET(x)        (((x) >> 24) & 0xff)
+#define FW_CMD_REQUEST          (1U << 23)
+#define FW_CMD_READ		(1U << 22)
+#define FW_CMD_WRITE		(1U << 21)
+#define FW_CMD_EXEC		(1U << 20)
+#define FW_CMD_RAMASK(x)	((x) << 20)
+#define FW_CMD_RETVAL(x)	((x) << 8)
+#define FW_CMD_RETVAL_GET(x)	(((x) >> 8) & 0xff)
+#define FW_CMD_LEN16(x)         ((x) << 0)
+
+enum fw_ldst_addrspc {
+	FW_LDST_ADDRSPC_FIRMWARE  = 0x0001,
+	FW_LDST_ADDRSPC_SGE_EGRC  = 0x0008,
+	FW_LDST_ADDRSPC_SGE_INGC  = 0x0009,
+	FW_LDST_ADDRSPC_SGE_FLMC  = 0x000a,
+	FW_LDST_ADDRSPC_SGE_CONMC = 0x000b,
+	FW_LDST_ADDRSPC_TP_PIO    = 0x0010,
+	FW_LDST_ADDRSPC_TP_TM_PIO = 0x0011,
+	FW_LDST_ADDRSPC_TP_MIB    = 0x0012,
+	FW_LDST_ADDRSPC_MDIO      = 0x0018,
+	FW_LDST_ADDRSPC_MPS       = 0x0020,
+	FW_LDST_ADDRSPC_FUNC      = 0x0028
+};
+
+enum fw_ldst_mps_fid {
+	FW_LDST_MPS_ATRB,
+	FW_LDST_MPS_RPLC
+};
+
+enum fw_ldst_func_access_ctl {
+	FW_LDST_FUNC_ACC_CTL_VIID,
+	FW_LDST_FUNC_ACC_CTL_FID
+};
+
+enum fw_ldst_func_mod_index {
+	FW_LDST_FUNC_MPS
+};
+
+struct fw_ldst_cmd {
+	__be32 op_to_addrspace;
+#define FW_LDST_CMD_ADDRSPACE(x) ((x) << 0)
+	__be32 cycles_to_len16;
+	union fw_ldst {
+		struct fw_ldst_addrval {
+			__be32 addr;
+			__be32 val;
+		} addrval;
+		struct fw_ldst_idctxt {
+			__be32 physid;
+			__be32 msg_pkd;
+			__be32 ctxt_data7;
+			__be32 ctxt_data6;
+			__be32 ctxt_data5;
+			__be32 ctxt_data4;
+			__be32 ctxt_data3;
+			__be32 ctxt_data2;
+			__be32 ctxt_data1;
+			__be32 ctxt_data0;
+		} idctxt;
+		struct fw_ldst_mdio {
+			__be16 paddr_mmd;
+			__be16 raddr;
+			__be16 vctl;
+			__be16 rval;
+		} mdio;
+		struct fw_ldst_mps {
+			__be16 fid_ctl;
+			__be16 rplcpf_pkd;
+			__be32 rplc127_96;
+			__be32 rplc95_64;
+			__be32 rplc63_32;
+			__be32 rplc31_0;
+			__be32 atrb;
+			__be16 vlan[16];
+		} mps;
+		struct fw_ldst_func {
+			u8 access_ctl;
+			u8 mod_index;
+			__be16 ctl_id;
+			__be32 offset;
+			__be64 data0;
+			__be64 data1;
+		} func;
+	} u;
+};
+
+#define FW_LDST_CMD_MSG(x)	((x) << 31)
+#define FW_LDST_CMD_PADDR(x)	((x) << 8)
+#define FW_LDST_CMD_MMD(x)	((x) << 0)
+#define FW_LDST_CMD_FID(x)	((x) << 15)
+#define FW_LDST_CMD_CTL(x)	((x) << 0)
+#define FW_LDST_CMD_RPLCPF(x)	((x) << 0)
+
+struct fw_reset_cmd {
+	__be32 op_to_write;
+	__be32 retval_len16;
+	__be32 val;
+	__be32 r3;
+};
+
+struct fw_hello_cmd {
+	__be32 op_to_write;
+	__be32 retval_len16;
+	__be32 err_to_mbasyncnot;
+#define FW_HELLO_CMD_ERR	    (1U << 31)
+#define FW_HELLO_CMD_INIT	    (1U << 30)
+#define FW_HELLO_CMD_MASTERDIS(x)   ((x) << 29)
+#define FW_HELLO_CMD_MASTERFORCE(x) ((x) << 28)
+#define FW_HELLO_CMD_MBMASTER(x)    ((x) << 24)
+#define FW_HELLO_CMD_MBASYNCNOT(x)  ((x) << 20)
+	__be32 fwrev;
+};
+
+struct fw_bye_cmd {
+	__be32 op_to_write;
+	__be32 retval_len16;
+	__be64 r3;
+};
+
+struct fw_initialize_cmd {
+	__be32 op_to_write;
+	__be32 retval_len16;
+	__be64 r3;
+};
+
+enum fw_caps_config_hm {
+	FW_CAPS_CONFIG_HM_PCIE		= 0x00000001,
+	FW_CAPS_CONFIG_HM_PL		= 0x00000002,
+	FW_CAPS_CONFIG_HM_SGE		= 0x00000004,
+	FW_CAPS_CONFIG_HM_CIM		= 0x00000008,
+	FW_CAPS_CONFIG_HM_ULPTX		= 0x00000010,
+	FW_CAPS_CONFIG_HM_TP		= 0x00000020,
+	FW_CAPS_CONFIG_HM_ULPRX		= 0x00000040,
+	FW_CAPS_CONFIG_HM_PMRX		= 0x00000080,
+	FW_CAPS_CONFIG_HM_PMTX		= 0x00000100,
+	FW_CAPS_CONFIG_HM_MC		= 0x00000200,
+	FW_CAPS_CONFIG_HM_LE		= 0x00000400,
+	FW_CAPS_CONFIG_HM_MPS		= 0x00000800,
+	FW_CAPS_CONFIG_HM_XGMAC		= 0x00001000,
+	FW_CAPS_CONFIG_HM_CPLSWITCH	= 0x00002000,
+	FW_CAPS_CONFIG_HM_T4DBG		= 0x00004000,
+	FW_CAPS_CONFIG_HM_MI		= 0x00008000,
+	FW_CAPS_CONFIG_HM_I2CM		= 0x00010000,
+	FW_CAPS_CONFIG_HM_NCSI		= 0x00020000,
+	FW_CAPS_CONFIG_HM_SMB		= 0x00040000,
+	FW_CAPS_CONFIG_HM_MA		= 0x00080000,
+	FW_CAPS_CONFIG_HM_EDRAM		= 0x00100000,
+	FW_CAPS_CONFIG_HM_PMU		= 0x00200000,
+	FW_CAPS_CONFIG_HM_UART		= 0x00400000,
+	FW_CAPS_CONFIG_HM_SF		= 0x00800000,
+};
+
+enum fw_caps_config_nbm {
+	FW_CAPS_CONFIG_NBM_IPMI		= 0x00000001,
+	FW_CAPS_CONFIG_NBM_NCSI		= 0x00000002,
+};
+
+enum fw_caps_config_link {
+	FW_CAPS_CONFIG_LINK_PPP		= 0x00000001,
+	FW_CAPS_CONFIG_LINK_QFC		= 0x00000002,
+	FW_CAPS_CONFIG_LINK_DCBX	= 0x00000004,
+};
+
+enum fw_caps_config_switch {
+	FW_CAPS_CONFIG_SWITCH_INGRESS	= 0x00000001,
+	FW_CAPS_CONFIG_SWITCH_EGRESS	= 0x00000002,
+};
+
+enum fw_caps_config_nic {
+	FW_CAPS_CONFIG_NIC		= 0x00000001,
+	FW_CAPS_CONFIG_NIC_VM		= 0x00000002,
+};
+
+enum fw_caps_config_ofld {
+	FW_CAPS_CONFIG_OFLD		= 0x00000001,
+};
+
+enum fw_caps_config_rdma {
+	FW_CAPS_CONFIG_RDMA_RDDP	= 0x00000001,
+	FW_CAPS_CONFIG_RDMA_RDMAC	= 0x00000002,
+};
+
+enum fw_caps_config_iscsi {
+	FW_CAPS_CONFIG_ISCSI_INITIATOR_PDU = 0x00000001,
+	FW_CAPS_CONFIG_ISCSI_TARGET_PDU = 0x00000002,
+	FW_CAPS_CONFIG_ISCSI_INITIATOR_CNXOFLD = 0x00000004,
+	FW_CAPS_CONFIG_ISCSI_TARGET_CNXOFLD = 0x00000008,
+};
+
+enum fw_caps_config_fcoe {
+	FW_CAPS_CONFIG_FCOE_INITIATOR	= 0x00000001,
+	FW_CAPS_CONFIG_FCOE_TARGET	= 0x00000002,
+};
+
+struct fw_caps_config_cmd {
+	__be32 op_to_write;
+	__be32 retval_len16;
+	__be32 r2;
+	__be32 hwmbitmap;
+	__be16 nbmcaps;
+	__be16 linkcaps;
+	__be16 switchcaps;
+	__be16 r3;
+	__be16 niccaps;
+	__be16 ofldcaps;
+	__be16 rdmacaps;
+	__be16 r4;
+	__be16 iscsicaps;
+	__be16 fcoecaps;
+	__be32 r5;
+	__be64 r6;
+};
+
+/*
+ * params command mnemonics
+ */
+enum fw_params_mnem {
+	FW_PARAMS_MNEM_DEV		= 1,	/* device params */
+	FW_PARAMS_MNEM_PFVF		= 2,	/* function params */
+	FW_PARAMS_MNEM_REG		= 3,	/* limited register access */
+	FW_PARAMS_MNEM_DMAQ		= 4,	/* dma queue params */
+	FW_PARAMS_MNEM_LAST
+};
+
+/*
+ * device parameters
+ */
+enum fw_params_param_dev {
+	FW_PARAMS_PARAM_DEV_CCLK	= 0x00, /* chip core clock in khz */
+	FW_PARAMS_PARAM_DEV_PORTVEC	= 0x01, /* the port vector */
+	FW_PARAMS_PARAM_DEV_NTID	= 0x02, /* reads the number of TIDs
+						 * allocated by the device's
+						 * Lookup Engine
+						 */
+	FW_PARAMS_PARAM_DEV_FLOWC_BUFFIFO_SZ = 0x03,
+	FW_PARAMS_PARAM_DEV_INTVER_NIC	= 0x04,
+	FW_PARAMS_PARAM_DEV_INTVER_VNIC = 0x05,
+	FW_PARAMS_PARAM_DEV_INTVER_OFLD = 0x06,
+	FW_PARAMS_PARAM_DEV_INTVER_RI	= 0x07,
+	FW_PARAMS_PARAM_DEV_INTVER_ISCSIPDU = 0x08,
+	FW_PARAMS_PARAM_DEV_INTVER_ISCSI = 0x09,
+	FW_PARAMS_PARAM_DEV_INTVER_FCOE = 0x0A
+};
+
+/*
+ * physical and virtual function parameters
+ */
+enum fw_params_param_pfvf {
+	FW_PARAMS_PARAM_PFVF_RWXCAPS	= 0x00,
+	FW_PARAMS_PARAM_PFVF_ROUTE_START = 0x01,
+	FW_PARAMS_PARAM_PFVF_ROUTE_END = 0x02,
+	FW_PARAMS_PARAM_PFVF_CLIP_START = 0x03,
+	FW_PARAMS_PARAM_PFVF_CLIP_END = 0x04,
+	FW_PARAMS_PARAM_PFVF_FILTER_START = 0x05,
+	FW_PARAMS_PARAM_PFVF_FILTER_END = 0x06,
+	FW_PARAMS_PARAM_PFVF_SERVER_START = 0x07,
+	FW_PARAMS_PARAM_PFVF_SERVER_END = 0x08,
+	FW_PARAMS_PARAM_PFVF_TDDP_START = 0x09,
+	FW_PARAMS_PARAM_PFVF_TDDP_END = 0x0A,
+	FW_PARAMS_PARAM_PFVF_ISCSI_START = 0x0B,
+	FW_PARAMS_PARAM_PFVF_ISCSI_END = 0x0C,
+	FW_PARAMS_PARAM_PFVF_STAG_START = 0x0D,
+	FW_PARAMS_PARAM_PFVF_STAG_END = 0x0E,
+	FW_PARAMS_PARAM_PFVF_RQ_START = 0x1F,
+	FW_PARAMS_PARAM_PFVF_RQ_END	= 0x10,
+	FW_PARAMS_PARAM_PFVF_PBL_START = 0x11,
+	FW_PARAMS_PARAM_PFVF_PBL_END	= 0x12,
+	FW_PARAMS_PARAM_PFVF_L2T_START = 0x13,
+	FW_PARAMS_PARAM_PFVF_L2T_END = 0x14,
+	FW_PARAMS_PARAM_PFVF_SCHEDCLASS_ETH = 0x20,
+};
+
+/*
+ * dma queue parameters
+ */
+enum fw_params_param_dmaq {
+	FW_PARAMS_PARAM_DMAQ_IQ_DCAEN_DCACPU = 0x00,
+	FW_PARAMS_PARAM_DMAQ_IQ_INTCNTTHRESH = 0x01,
+	FW_PARAMS_PARAM_DMAQ_EQ_CMPLIQID_MNGT = 0x10,
+	FW_PARAMS_PARAM_DMAQ_EQ_CMPLIQID_CTRL = 0x11,
+	FW_PARAMS_PARAM_DMAQ_EQ_SCHEDCLASS_ETH = 0x12,
+};
+
+#define FW_PARAMS_MNEM(x)      ((x) << 24)
+#define FW_PARAMS_PARAM_X(x)   ((x) << 16)
+#define FW_PARAMS_PARAM_Y(x)   ((x) << 8)
+#define FW_PARAMS_PARAM_Z(x)   ((x) << 0)
+#define FW_PARAMS_PARAM_XYZ(x) ((x) << 0)
+#define FW_PARAMS_PARAM_YZ(x)  ((x) << 0)
+
+struct fw_params_cmd {
+	__be32 op_to_vfn;
+	__be32 retval_len16;
+	struct fw_params_param {
+		__be32 mnem;
+		__be32 val;
+	} param[7];
+};
+
+#define FW_PARAMS_CMD_PFN(x) ((x) << 8)
+#define FW_PARAMS_CMD_VFN(x) ((x) << 0)
+
+struct fw_pfvf_cmd {
+	__be32 op_to_vfn;
+	__be32 retval_len16;
+	__be32 niqflint_niq;
+	__be32 cmask_to_neq;
+	__be32 tc_to_nexactf;
+	__be32 r_caps_to_nethctrl;
+	__be16 nricq;
+	__be16 nriqp;
+	__be32 r4;
+};
+
+#define FW_PFVF_CMD_PFN(x) ((x) << 8)
+#define FW_PFVF_CMD_VFN(x) ((x) << 0)
+
+#define FW_PFVF_CMD_NIQFLINT(x) ((x) << 20)
+#define FW_PFVF_CMD_NIQFLINT_GET(x) (((x) >> 20) & 0xfff)
+
+#define FW_PFVF_CMD_NIQ(x) ((x) << 0)
+#define FW_PFVF_CMD_NIQ_GET(x) (((x) >> 0) & 0xfffff)
+
+#define FW_PFVF_CMD_CMASK(x) ((x) << 24)
+#define FW_PFVF_CMD_CMASK_GET(x) (((x) >> 24) & 0xf)
+
+#define FW_PFVF_CMD_PMASK(x) ((x) << 20)
+#define FW_PFVF_CMD_PMASK_GET(x) (((x) >> 20) & 0xf)
+
+#define FW_PFVF_CMD_NEQ(x) ((x) << 0)
+#define FW_PFVF_CMD_NEQ_GET(x) (((x) >> 0) & 0xfffff)
+
+#define FW_PFVF_CMD_TC(x) ((x) << 24)
+#define FW_PFVF_CMD_TC_GET(x) (((x) >> 24) & 0xff)
+
+#define FW_PFVF_CMD_NVI(x) ((x) << 16)
+#define FW_PFVF_CMD_NVI_GET(x) (((x) >> 16) & 0xff)
+
+#define FW_PFVF_CMD_NEXACTF(x) ((x) << 0)
+#define FW_PFVF_CMD_NEXACTF_GET(x) (((x) >> 0) & 0xffff)
+
+#define FW_PFVF_CMD_R_CAPS(x) ((x) << 24)
+#define FW_PFVF_CMD_R_CAPS_GET(x) (((x) >> 24) & 0xff)
+
+#define FW_PFVF_CMD_WX_CAPS(x) ((x) << 16)
+#define FW_PFVF_CMD_WX_CAPS_GET(x) (((x) >> 16) & 0xff)
+
+#define FW_PFVF_CMD_NETHCTRL(x) ((x) << 0)
+#define FW_PFVF_CMD_NETHCTRL_GET(x) (((x) >> 0) & 0xffff)
+
+enum fw_iq_type {
+	FW_IQ_TYPE_FL_INT_CAP,
+	FW_IQ_TYPE_NO_FL_INT_CAP
+};
+
+struct fw_iq_cmd {
+	__be32 op_to_vfn;
+	__be32 alloc_to_len16;
+	__be16 physiqid;
+	__be16 iqid;
+	__be16 fl0id;
+	__be16 fl1id;
+	__be32 type_to_iqandstindex;
+	__be16 iqdroprss_to_iqesize;
+	__be16 iqsize;
+	__be64 iqaddr;
+	__be32 iqns_to_fl0congen;
+	__be16 fl0dcaen_to_fl0cidxfthresh;
+	__be16 fl0size;
+	__be64 fl0addr;
+	__be32 fl1cngchmap_to_fl1congen;
+	__be16 fl1dcaen_to_fl1cidxfthresh;
+	__be16 fl1size;
+	__be64 fl1addr;
+};
+
+#define FW_IQ_CMD_PFN(x) ((x) << 8)
+#define FW_IQ_CMD_VFN(x) ((x) << 0)
+
+#define FW_IQ_CMD_ALLOC (1U << 31)
+#define FW_IQ_CMD_FREE (1U << 30)
+#define FW_IQ_CMD_MODIFY (1U << 29)
+#define FW_IQ_CMD_IQSTART(x) ((x) << 28)
+#define FW_IQ_CMD_IQSTOP(x) ((x) << 27)
+
+#define FW_IQ_CMD_TYPE(x) ((x) << 29)
+#define FW_IQ_CMD_IQASYNCH(x) ((x) << 28)
+#define FW_IQ_CMD_VIID(x) ((x) << 16)
+#define FW_IQ_CMD_IQANDST(x) ((x) << 15)
+#define FW_IQ_CMD_IQANUS(x) ((x) << 14)
+#define FW_IQ_CMD_IQANUD(x) ((x) << 12)
+#define FW_IQ_CMD_IQANDSTINDEX(x) ((x) << 0)
+
+#define FW_IQ_CMD_IQDROPRSS (1U << 15)
+#define FW_IQ_CMD_IQGTSMODE (1U << 14)
+#define FW_IQ_CMD_IQPCIECH(x) ((x) << 12)
+#define FW_IQ_CMD_IQDCAEN(x) ((x) << 11)
+#define FW_IQ_CMD_IQDCACPU(x) ((x) << 6)
+#define FW_IQ_CMD_IQINTCNTTHRESH(x) ((x) << 4)
+#define FW_IQ_CMD_IQO (1U << 3)
+#define FW_IQ_CMD_IQCPRIO(x) ((x) << 2)
+#define FW_IQ_CMD_IQESIZE(x) ((x) << 0)
+
+#define FW_IQ_CMD_IQNS(x) ((x) << 31)
+#define FW_IQ_CMD_IQRO(x) ((x) << 30)
+#define FW_IQ_CMD_IQFLINTIQHSEN(x) ((x) << 28)
+#define FW_IQ_CMD_IQFLINTCONGEN(x) ((x) << 27)
+#define FW_IQ_CMD_IQFLINTISCSIC(x) ((x) << 26)
+#define FW_IQ_CMD_FL0CNGCHMAP(x) ((x) << 20)
+#define FW_IQ_CMD_FL0CACHELOCK(x) ((x) << 15)
+#define FW_IQ_CMD_FL0DBP(x) ((x) << 14)
+#define FW_IQ_CMD_FL0DATANS(x) ((x) << 13)
+#define FW_IQ_CMD_FL0DATARO(x) ((x) << 12)
+#define FW_IQ_CMD_FL0CONGCIF(x) ((x) << 11)
+#define FW_IQ_CMD_FL0ONCHIP(x) ((x) << 10)
+#define FW_IQ_CMD_FL0STATUSPGNS(x) ((x) << 9)
+#define FW_IQ_CMD_FL0STATUSPGRO(x) ((x) << 8)
+#define FW_IQ_CMD_FL0FETCHNS(x) ((x) << 7)
+#define FW_IQ_CMD_FL0FETCHRO(x) ((x) << 6)
+#define FW_IQ_CMD_FL0HOSTFCMODE(x) ((x) << 4)
+#define FW_IQ_CMD_FL0CPRIO(x) ((x) << 3)
+#define FW_IQ_CMD_FL0PADEN (1U << 2)
+#define FW_IQ_CMD_FL0PACKEN (1U << 1)
+#define FW_IQ_CMD_FL0CONGEN (1U << 0)
+
+#define FW_IQ_CMD_FL0DCAEN(x) ((x) << 15)
+#define FW_IQ_CMD_FL0DCACPU(x) ((x) << 10)
+#define FW_IQ_CMD_FL0FBMIN(x) ((x) << 7)
+#define FW_IQ_CMD_FL0FBMAX(x) ((x) << 4)
+#define FW_IQ_CMD_FL0CIDXFTHRESHO (1U << 3)
+#define FW_IQ_CMD_FL0CIDXFTHRESH(x) ((x) << 0)
+
+#define FW_IQ_CMD_FL1CNGCHMAP(x) ((x) << 20)
+#define FW_IQ_CMD_FL1CACHELOCK(x) ((x) << 15)
+#define FW_IQ_CMD_FL1DBP(x) ((x) << 14)
+#define FW_IQ_CMD_FL1DATANS(x) ((x) << 13)
+#define FW_IQ_CMD_FL1DATARO(x) ((x) << 12)
+#define FW_IQ_CMD_FL1CONGCIF(x) ((x) << 11)
+#define FW_IQ_CMD_FL1ONCHIP(x) ((x) << 10)
+#define FW_IQ_CMD_FL1STATUSPGNS(x) ((x) << 9)
+#define FW_IQ_CMD_FL1STATUSPGRO(x) ((x) << 8)
+#define FW_IQ_CMD_FL1FETCHNS(x) ((x) << 7)
+#define FW_IQ_CMD_FL1FETCHRO(x) ((x) << 6)
+#define FW_IQ_CMD_FL1HOSTFCMODE(x) ((x) << 4)
+#define FW_IQ_CMD_FL1CPRIO(x) ((x) << 3)
+#define FW_IQ_CMD_FL1PADEN (1U << 2)
+#define FW_IQ_CMD_FL1PACKEN (1U << 1)
+#define FW_IQ_CMD_FL1CONGEN (1U << 0)
+
+#define FW_IQ_CMD_FL1DCAEN(x) ((x) << 15)
+#define FW_IQ_CMD_FL1DCACPU(x) ((x) << 10)
+#define FW_IQ_CMD_FL1FBMIN(x) ((x) << 7)
+#define FW_IQ_CMD_FL1FBMAX(x) ((x) << 4)
+#define FW_IQ_CMD_FL1CIDXFTHRESHO (1U << 3)
+#define FW_IQ_CMD_FL1CIDXFTHRESH(x) ((x) << 0)
+
+struct fw_eq_eth_cmd {
+	__be32 op_to_vfn;
+	__be32 alloc_to_len16;
+	__be32 eqid_pkd;
+	__be32 physeqid_pkd;
+	__be32 fetchszm_to_iqid;
+	__be32 dcaen_to_eqsize;
+	__be64 eqaddr;
+	__be32 viid_pkd;
+	__be32 r8_lo;
+	__be64 r9;
+};
+
+#define FW_EQ_ETH_CMD_PFN(x) ((x) << 8)
+#define FW_EQ_ETH_CMD_VFN(x) ((x) << 0)
+#define FW_EQ_ETH_CMD_ALLOC (1U << 31)
+#define FW_EQ_ETH_CMD_FREE (1U << 30)
+#define FW_EQ_ETH_CMD_MODIFY (1U << 29)
+#define FW_EQ_ETH_CMD_EQSTART (1U << 28)
+#define FW_EQ_ETH_CMD_EQSTOP (1U << 27)
+
+#define FW_EQ_ETH_CMD_EQID(x) ((x) << 0)
+#define FW_EQ_ETH_CMD_EQID_GET(x) (((x) >> 0) & 0xfffff)
+#define FW_EQ_ETH_CMD_PHYSEQID(x) ((x) << 0)
+
+#define FW_EQ_ETH_CMD_FETCHSZM(x) ((x) << 26)
+#define FW_EQ_ETH_CMD_STATUSPGNS(x) ((x) << 25)
+#define FW_EQ_ETH_CMD_STATUSPGRO(x) ((x) << 24)
+#define FW_EQ_ETH_CMD_FETCHNS(x) ((x) << 23)
+#define FW_EQ_ETH_CMD_FETCHRO(x) ((x) << 22)
+#define FW_EQ_ETH_CMD_HOSTFCMODE(x) ((x) << 20)
+#define FW_EQ_ETH_CMD_CPRIO(x) ((x) << 19)
+#define FW_EQ_ETH_CMD_ONCHIP(x) ((x) << 18)
+#define FW_EQ_ETH_CMD_PCIECHN(x) ((x) << 16)
+#define FW_EQ_ETH_CMD_IQID(x) ((x) << 0)
+
+#define FW_EQ_ETH_CMD_DCAEN(x) ((x) << 31)
+#define FW_EQ_ETH_CMD_DCACPU(x) ((x) << 26)
+#define FW_EQ_ETH_CMD_FBMIN(x) ((x) << 23)
+#define FW_EQ_ETH_CMD_FBMAX(x) ((x) << 20)
+#define FW_EQ_ETH_CMD_CIDXFTHRESHO(x) ((x) << 19)
+#define FW_EQ_ETH_CMD_CIDXFTHRESH(x) ((x) << 16)
+#define FW_EQ_ETH_CMD_EQSIZE(x) ((x) << 0)
+
+#define FW_EQ_ETH_CMD_VIID(x) ((x) << 16)
+
+struct fw_eq_ctrl_cmd {
+	__be32 op_to_vfn;
+	__be32 alloc_to_len16;
+	__be32 cmpliqid_eqid;
+	__be32 physeqid_pkd;
+	__be32 fetchszm_to_iqid;
+	__be32 dcaen_to_eqsize;
+	__be64 eqaddr;
+};
+
+#define FW_EQ_CTRL_CMD_PFN(x) ((x) << 8)
+#define FW_EQ_CTRL_CMD_VFN(x) ((x) << 0)
+
+#define FW_EQ_CTRL_CMD_ALLOC (1U << 31)
+#define FW_EQ_CTRL_CMD_FREE (1U << 30)
+#define FW_EQ_CTRL_CMD_MODIFY (1U << 29)
+#define FW_EQ_CTRL_CMD_EQSTART (1U << 28)
+#define FW_EQ_CTRL_CMD_EQSTOP (1U << 27)
+
+#define FW_EQ_CTRL_CMD_CMPLIQID(x) ((x) << 20)
+#define FW_EQ_CTRL_CMD_EQID(x) ((x) << 0)
+#define FW_EQ_CTRL_CMD_EQID_GET(x) (((x) >> 0) & 0xfffff)
+#define FW_EQ_CTRL_CMD_PHYSEQID_GET(x) (((x) >> 0) & 0xfffff)
+
+#define FW_EQ_CTRL_CMD_FETCHSZM (1U << 26)
+#define FW_EQ_CTRL_CMD_STATUSPGNS (1U << 25)
+#define FW_EQ_CTRL_CMD_STATUSPGRO (1U << 24)
+#define FW_EQ_CTRL_CMD_FETCHNS (1U << 23)
+#define FW_EQ_CTRL_CMD_FETCHRO (1U << 22)
+#define FW_EQ_CTRL_CMD_HOSTFCMODE(x) ((x) << 20)
+#define FW_EQ_CTRL_CMD_CPRIO(x) ((x) << 19)
+#define FW_EQ_CTRL_CMD_ONCHIP(x) ((x) << 18)
+#define FW_EQ_CTRL_CMD_PCIECHN(x) ((x) << 16)
+#define FW_EQ_CTRL_CMD_IQID(x) ((x) << 0)
+
+#define FW_EQ_CTRL_CMD_DCAEN(x) ((x) << 31)
+#define FW_EQ_CTRL_CMD_DCACPU(x) ((x) << 26)
+#define FW_EQ_CTRL_CMD_FBMIN(x) ((x) << 23)
+#define FW_EQ_CTRL_CMD_FBMAX(x) ((x) << 20)
+#define FW_EQ_CTRL_CMD_CIDXFTHRESHO(x) ((x) << 19)
+#define FW_EQ_CTRL_CMD_CIDXFTHRESH(x) ((x) << 16)
+#define FW_EQ_CTRL_CMD_EQSIZE(x) ((x) << 0)
+
+struct fw_eq_ofld_cmd {
+	__be32 op_to_vfn;
+	__be32 alloc_to_len16;
+	__be32 eqid_pkd;
+	__be32 physeqid_pkd;
+	__be32 fetchszm_to_iqid;
+	__be32 dcaen_to_eqsize;
+	__be64 eqaddr;
+};
+
+#define FW_EQ_OFLD_CMD_PFN(x) ((x) << 8)
+#define FW_EQ_OFLD_CMD_VFN(x) ((x) << 0)
+
+#define FW_EQ_OFLD_CMD_ALLOC (1U << 31)
+#define FW_EQ_OFLD_CMD_FREE (1U << 30)
+#define FW_EQ_OFLD_CMD_MODIFY (1U << 29)
+#define FW_EQ_OFLD_CMD_EQSTART (1U << 28)
+#define FW_EQ_OFLD_CMD_EQSTOP (1U << 27)
+
+#define FW_EQ_OFLD_CMD_EQID(x) ((x) << 0)
+#define FW_EQ_OFLD_CMD_EQID_GET(x) (((x) >> 0) & 0xfffff)
+#define FW_EQ_OFLD_CMD_PHYSEQID_GET(x) (((x) >> 0) & 0xfffff)
+
+#define FW_EQ_OFLD_CMD_FETCHSZM(x) ((x) << 26)
+#define FW_EQ_OFLD_CMD_STATUSPGNS(x) ((x) << 25)
+#define FW_EQ_OFLD_CMD_STATUSPGRO(x) ((x) << 24)
+#define FW_EQ_OFLD_CMD_FETCHNS(x) ((x) << 23)
+#define FW_EQ_OFLD_CMD_FETCHRO(x) ((x) << 22)
+#define FW_EQ_OFLD_CMD_HOSTFCMODE(x) ((x) << 20)
+#define FW_EQ_OFLD_CMD_CPRIO(x) ((x) << 19)
+#define FW_EQ_OFLD_CMD_ONCHIP(x) ((x) << 18)
+#define FW_EQ_OFLD_CMD_PCIECHN(x) ((x) << 16)
+#define FW_EQ_OFLD_CMD_IQID(x) ((x) << 0)
+
+#define FW_EQ_OFLD_CMD_DCAEN(x) ((x) << 31)
+#define FW_EQ_OFLD_CMD_DCACPU(x) ((x) << 26)
+#define FW_EQ_OFLD_CMD_FBMIN(x) ((x) << 23)
+#define FW_EQ_OFLD_CMD_FBMAX(x) ((x) << 20)
+#define FW_EQ_OFLD_CMD_CIDXFTHRESHO(x) ((x) << 19)
+#define FW_EQ_OFLD_CMD_CIDXFTHRESH(x) ((x) << 16)
+#define FW_EQ_OFLD_CMD_EQSIZE(x) ((x) << 0)
+
+/*
+ * Macros for VIID parsing:
+ * VIID - [10:8] PFN, [7] VI Valid, [6:0] VI number
+ */
+#define FW_VIID_PFN_GET(x) (((x) >> 8) & 0x7)
+#define FW_VIID_VIVLD_GET(x) (((x) >> 7) & 0x1)
+#define FW_VIID_VIN_GET(x) (((x) >> 0) & 0x7F)
+
+struct fw_vi_cmd {
+	__be32 op_to_vfn;
+	__be32 alloc_to_len16;
+	__be16 viid_pkd;
+	u8 mac[6];
+	u8 portid_pkd;
+	u8 nmac;
+	u8 nmac0[6];
+	__be16 rsssize_pkd;
+	u8 nmac1[6];
+	__be16 r7;
+	u8 nmac2[6];
+	__be16 r8;
+	u8 nmac3[6];
+	__be64 r9;
+	__be64 r10;
+};
+
+#define FW_VI_CMD_PFN(x) ((x) << 8)
+#define FW_VI_CMD_VFN(x) ((x) << 0)
+#define FW_VI_CMD_ALLOC (1U << 31)
+#define FW_VI_CMD_FREE (1U << 30)
+#define FW_VI_CMD_VIID(x) ((x) << 0)
+#define FW_VI_CMD_PORTID(x) ((x) << 4)
+#define FW_VI_CMD_RSSSIZE_GET(x) (((x) >> 0) & 0x7ff)
+
+/* Special VI_MAC command index ids */
+#define FW_VI_MAC_ADD_MAC		0x3FF
+#define FW_VI_MAC_ADD_PERSIST_MAC	0x3FE
+#define FW_VI_MAC_MAC_BASED_FREE	0x3FD
+
+enum fw_vi_mac_smac {
+	FW_VI_MAC_MPS_TCAM_ENTRY,
+	FW_VI_MAC_MPS_TCAM_ONLY,
+	FW_VI_MAC_SMT_ONLY,
+	FW_VI_MAC_SMT_AND_MPSTCAM
+};
+
+enum fw_vi_mac_result {
+	FW_VI_MAC_R_SUCCESS,
+	FW_VI_MAC_R_F_NONEXISTENT_NOMEM,
+	FW_VI_MAC_R_SMAC_FAIL,
+	FW_VI_MAC_R_F_ACL_CHECK
+};
+
+struct fw_vi_mac_cmd {
+	__be32 op_to_viid;
+	__be32 freemacs_to_len16;
+	union fw_vi_mac {
+		struct fw_vi_mac_exact {
+			__be16 valid_to_idx;
+			u8 macaddr[6];
+		} exact[7];
+		struct fw_vi_mac_hash {
+			__be64 hashvec;
+		} hash;
+	} u;
+};
+
+#define FW_VI_MAC_CMD_VIID(x) ((x) << 0)
+#define FW_VI_MAC_CMD_FREEMACS(x) ((x) << 31)
+#define FW_VI_MAC_CMD_HASHVECEN (1U << 23)
+#define FW_VI_MAC_CMD_HASHUNIEN(x) ((x) << 22)
+#define FW_VI_MAC_CMD_VALID (1U << 15)
+#define FW_VI_MAC_CMD_PRIO(x) ((x) << 12)
+#define FW_VI_MAC_CMD_SMAC_RESULT(x) ((x) << 10)
+#define FW_VI_MAC_CMD_SMAC_RESULT_GET(x) (((x) >> 10) & 0x3)
+#define FW_VI_MAC_CMD_IDX(x) ((x) << 0)
+#define FW_VI_MAC_CMD_IDX_GET(x) (((x) >> 0) & 0x3ff)
+
+#define FW_RXMODE_MTU_NO_CHG	65535
+
+struct fw_vi_rxmode_cmd {
+	__be32 op_to_viid;
+	__be32 retval_len16;
+	__be32 mtu_to_broadcasten;
+	__be32 r4_lo;
+};
+
+#define FW_VI_RXMODE_CMD_VIID(x) ((x) << 0)
+#define FW_VI_RXMODE_CMD_MTU(x) ((x) << 16)
+#define FW_VI_RXMODE_CMD_PROMISCEN_MASK 0x3
+#define FW_VI_RXMODE_CMD_PROMISCEN(x) ((x) << 14)
+#define FW_VI_RXMODE_CMD_ALLMULTIEN_MASK 0x3
+#define FW_VI_RXMODE_CMD_ALLMULTIEN(x) ((x) << 12)
+#define FW_VI_RXMODE_CMD_BROADCASTEN_MASK 0x3
+#define FW_VI_RXMODE_CMD_BROADCASTEN(x) ((x) << 10)
+
+struct fw_vi_enable_cmd {
+	__be32 op_to_viid;
+	__be32 ien_to_len16;
+	__be16 blinkdur;
+	__be16 r3;
+	__be32 r4;
+};
+
+#define FW_VI_ENABLE_CMD_VIID(x) ((x) << 0)
+#define FW_VI_ENABLE_CMD_IEN(x) ((x) << 31)
+#define FW_VI_ENABLE_CMD_EEN(x) ((x) << 30)
+#define FW_VI_ENABLE_CMD_LED (1U << 29)
+
+/* VI VF stats offset definitions */
+#define VI_VF_NUM_STATS	16
+enum fw_vi_stats_vf_index {
+	FW_VI_VF_STAT_TX_BCAST_BYTES_IX,
+	FW_VI_VF_STAT_TX_BCAST_FRAMES_IX,
+	FW_VI_VF_STAT_TX_MCAST_BYTES_IX,
+	FW_VI_VF_STAT_TX_MCAST_FRAMES_IX,
+	FW_VI_VF_STAT_TX_UCAST_BYTES_IX,
+	FW_VI_VF_STAT_TX_UCAST_FRAMES_IX,
+	FW_VI_VF_STAT_TX_DROP_FRAMES_IX,
+	FW_VI_VF_STAT_TX_OFLD_BYTES_IX,
+	FW_VI_VF_STAT_TX_OFLD_FRAMES_IX,
+	FW_VI_VF_STAT_RX_BCAST_BYTES_IX,
+	FW_VI_VF_STAT_RX_BCAST_FRAMES_IX,
+	FW_VI_VF_STAT_RX_MCAST_BYTES_IX,
+	FW_VI_VF_STAT_RX_MCAST_FRAMES_IX,
+	FW_VI_VF_STAT_RX_UCAST_BYTES_IX,
+	FW_VI_VF_STAT_RX_UCAST_FRAMES_IX,
+	FW_VI_VF_STAT_RX_ERR_FRAMES_IX
+};
+
+/* VI PF stats offset definitions */
+#define VI_PF_NUM_STATS	17
+enum fw_vi_stats_pf_index {
+	FW_VI_PF_STAT_TX_BCAST_BYTES_IX,
+	FW_VI_PF_STAT_TX_BCAST_FRAMES_IX,
+	FW_VI_PF_STAT_TX_MCAST_BYTES_IX,
+	FW_VI_PF_STAT_TX_MCAST_FRAMES_IX,
+	FW_VI_PF_STAT_TX_UCAST_BYTES_IX,
+	FW_VI_PF_STAT_TX_UCAST_FRAMES_IX,
+	FW_VI_PF_STAT_TX_OFLD_BYTES_IX,
+	FW_VI_PF_STAT_TX_OFLD_FRAMES_IX,
+	FW_VI_PF_STAT_RX_BYTES_IX,
+	FW_VI_PF_STAT_RX_FRAMES_IX,
+	FW_VI_PF_STAT_RX_BCAST_BYTES_IX,
+	FW_VI_PF_STAT_RX_BCAST_FRAMES_IX,
+	FW_VI_PF_STAT_RX_MCAST_BYTES_IX,
+	FW_VI_PF_STAT_RX_MCAST_FRAMES_IX,
+	FW_VI_PF_STAT_RX_UCAST_BYTES_IX,
+	FW_VI_PF_STAT_RX_UCAST_FRAMES_IX,
+	FW_VI_PF_STAT_RX_ERR_FRAMES_IX
+};
+
+struct fw_vi_stats_cmd {
+	__be32 op_to_viid;
+	__be32 retval_len16;
+	union fw_vi_stats {
+		struct fw_vi_stats_ctl {
+			__be16 nstats_ix;
+			__be16 r6;
+			__be32 r7;
+			__be64 stat0;
+			__be64 stat1;
+			__be64 stat2;
+			__be64 stat3;
+			__be64 stat4;
+			__be64 stat5;
+		} ctl;
+		struct fw_vi_stats_pf {
+			__be64 tx_bcast_bytes;
+			__be64 tx_bcast_frames;
+			__be64 tx_mcast_bytes;
+			__be64 tx_mcast_frames;
+			__be64 tx_ucast_bytes;
+			__be64 tx_ucast_frames;
+			__be64 tx_offload_bytes;
+			__be64 tx_offload_frames;
+			__be64 rx_pf_bytes;
+			__be64 rx_pf_frames;
+			__be64 rx_bcast_bytes;
+			__be64 rx_bcast_frames;
+			__be64 rx_mcast_bytes;
+			__be64 rx_mcast_frames;
+			__be64 rx_ucast_bytes;
+			__be64 rx_ucast_frames;
+			__be64 rx_err_frames;
+		} pf;
+		struct fw_vi_stats_vf {
+			__be64 tx_bcast_bytes;
+			__be64 tx_bcast_frames;
+			__be64 tx_mcast_bytes;
+			__be64 tx_mcast_frames;
+			__be64 tx_ucast_bytes;
+			__be64 tx_ucast_frames;
+			__be64 tx_drop_frames;
+			__be64 tx_offload_bytes;
+			__be64 tx_offload_frames;
+			__be64 rx_bcast_bytes;
+			__be64 rx_bcast_frames;
+			__be64 rx_mcast_bytes;
+			__be64 rx_mcast_frames;
+			__be64 rx_ucast_bytes;
+			__be64 rx_ucast_frames;
+			__be64 rx_err_frames;
+		} vf;
+	} u;
+};
+
+#define FW_VI_STATS_CMD_VIID(x) ((x) << 0)
+#define FW_VI_STATS_CMD_NSTATS(x) ((x) << 12)
+#define FW_VI_STATS_CMD_IX(x) ((x) << 0)
+
+struct fw_acl_mac_cmd {
+	__be32 op_to_vfn;
+	__be32 en_to_len16;
+	u8 nmac;
+	u8 r3[7];
+	__be16 r4;
+	u8 macaddr0[6];
+	__be16 r5;
+	u8 macaddr1[6];
+	__be16 r6;
+	u8 macaddr2[6];
+	__be16 r7;
+	u8 macaddr3[6];
+};
+
+#define FW_ACL_MAC_CMD_PFN(x) ((x) << 8)
+#define FW_ACL_MAC_CMD_VFN(x) ((x) << 0)
+#define FW_ACL_MAC_CMD_EN(x) ((x) << 31)
+
+struct fw_acl_vlan_cmd {
+	__be32 op_to_vfn;
+	__be32 en_to_len16;
+	u8 nvlan;
+	u8 dropnovlan_fm;
+	u8 r3_lo[6];
+	__be16 vlanid[16];
+};
+
+#define FW_ACL_VLAN_CMD_PFN(x) ((x) << 8)
+#define FW_ACL_VLAN_CMD_VFN(x) ((x) << 0)
+#define FW_ACL_VLAN_CMD_EN(x) ((x) << 31)
+#define FW_ACL_VLAN_CMD_DROPNOVLAN(x) ((x) << 7)
+#define FW_ACL_VLAN_CMD_FM(x) ((x) << 6)
+
+enum fw_port_cap {
+	FW_PORT_CAP_SPEED_100M		= 0x0001,
+	FW_PORT_CAP_SPEED_1G		= 0x0002,
+	FW_PORT_CAP_SPEED_2_5G		= 0x0004,
+	FW_PORT_CAP_SPEED_10G		= 0x0008,
+	FW_PORT_CAP_SPEED_40G		= 0x0010,
+	FW_PORT_CAP_SPEED_100G		= 0x0020,
+	FW_PORT_CAP_FC_RX		= 0x0040,
+	FW_PORT_CAP_FC_TX		= 0x0080,
+	FW_PORT_CAP_ANEG		= 0x0100,
+	FW_PORT_CAP_MDI_0		= 0x0200,
+	FW_PORT_CAP_MDI_1		= 0x0400,
+	FW_PORT_CAP_BEAN		= 0x0800,
+	FW_PORT_CAP_PMA_LPBK		= 0x1000,
+	FW_PORT_CAP_PCS_LPBK		= 0x2000,
+	FW_PORT_CAP_PHYXS_LPBK		= 0x4000,
+	FW_PORT_CAP_FAR_END_LPBK	= 0x8000,
+};
+
+enum fw_port_mdi {
+	FW_PORT_MDI_UNCHANGED,
+	FW_PORT_MDI_AUTO,
+	FW_PORT_MDI_F_STRAIGHT,
+	FW_PORT_MDI_F_CROSSOVER
+};
+
+#define FW_PORT_MDI(x) ((x) << 9)
+
+enum fw_port_action {
+	FW_PORT_ACTION_L1_CFG		= 0x0001,
+	FW_PORT_ACTION_L2_CFG		= 0x0002,
+	FW_PORT_ACTION_GET_PORT_INFO	= 0x0003,
+	FW_PORT_ACTION_L2_PPP_CFG	= 0x0004,
+	FW_PORT_ACTION_L2_DCB_CFG	= 0x0005,
+	FW_PORT_ACTION_LOW_PWR_TO_NORMAL = 0x0010,
+	FW_PORT_ACTION_L1_LOW_PWR_EN	= 0x0011,
+	FW_PORT_ACTION_L2_WOL_MODE_EN	= 0x0012,
+	FW_PORT_ACTION_LPBK_TO_NORMAL	= 0x0020,
+	FW_PORT_ACTION_L1_LPBK		= 0x0021,
+	FW_PORT_ACTION_L1_PMA_LPBK	= 0x0022,
+	FW_PORT_ACTION_L1_PCS_LPBK	= 0x0023,
+	FW_PORT_ACTION_L1_PHYXS_CSIDE_LPBK = 0x0024,
+	FW_PORT_ACTION_L1_PHYXS_ESIDE_LPBK = 0x0025,
+	FW_PORT_ACTION_PHY_RESET	= 0x0040,
+	FW_PORT_ACTION_PMA_RESET	= 0x0041,
+	FW_PORT_ACTION_PCS_RESET	= 0x0042,
+	FW_PORT_ACTION_PHYXS_RESET	= 0x0043,
+	FW_PORT_ACTION_DTEXS_REEST	= 0x0044,
+	FW_PORT_ACTION_AN_RESET		= 0x0045
+};
+
+enum fw_port_l2cfg_ctlbf {
+	FW_PORT_L2_CTLBF_OVLAN0	= 0x01,
+	FW_PORT_L2_CTLBF_OVLAN1	= 0x02,
+	FW_PORT_L2_CTLBF_OVLAN2	= 0x04,
+	FW_PORT_L2_CTLBF_OVLAN3	= 0x08,
+	FW_PORT_L2_CTLBF_IVLAN	= 0x10,
+	FW_PORT_L2_CTLBF_TXIPG	= 0x20
+};
+
+enum fw_port_dcb_cfg {
+	FW_PORT_DCB_CFG_PG	= 0x01,
+	FW_PORT_DCB_CFG_PFC	= 0x02,
+	FW_PORT_DCB_CFG_APPL	= 0x04
+};
+
+enum fw_port_dcb_cfg_rc {
+	FW_PORT_DCB_CFG_SUCCESS	= 0x0,
+	FW_PORT_DCB_CFG_ERROR	= 0x1
+};
+
+struct fw_port_cmd {
+	__be32 op_to_portid;
+	__be32 action_to_len16;
+	union fw_port {
+		struct fw_port_l1cfg {
+			__be32 rcap;
+			__be32 r;
+		} l1cfg;
+		struct fw_port_l2cfg {
+			__be16 ctlbf_to_ivlan0;
+			__be16 ivlantype;
+			__be32 txipg_pkd;
+			__be16 ovlan0mask;
+			__be16 ovlan0type;
+			__be16 ovlan1mask;
+			__be16 ovlan1type;
+			__be16 ovlan2mask;
+			__be16 ovlan2type;
+			__be16 ovlan3mask;
+			__be16 ovlan3type;
+		} l2cfg;
+		struct fw_port_info {
+			__be32 lstatus_to_modtype;
+			__be16 pcap;
+			__be16 acap;
+		} info;
+		struct fw_port_ppp {
+			__be32 pppen_to_ncsich;
+			__be32 r11;
+		} ppp;
+		struct fw_port_dcb {
+			__be16 cfg;
+			u8 up_map;
+			u8 sf_cfgrc;
+			__be16 prot_ix;
+			u8 pe7_to_pe0;
+			u8 numTCPFCs;
+			__be32 pgid0_to_pgid7;
+			__be32 numTCs_oui;
+			u8 pgpc[8];
+		} dcb;
+	} u;
+};
+
+#define FW_PORT_CMD_READ (1U << 22)
+
+#define FW_PORT_CMD_PORTID(x) ((x) << 0)
+#define FW_PORT_CMD_PORTID_GET(x) (((x) >> 0) & 0xf)
+
+#define FW_PORT_CMD_ACTION(x) ((x) << 16)
+
+#define FW_PORT_CMD_CTLBF(x) ((x) << 10)
+#define FW_PORT_CMD_OVLAN3(x) ((x) << 7)
+#define FW_PORT_CMD_OVLAN2(x) ((x) << 6)
+#define FW_PORT_CMD_OVLAN1(x) ((x) << 5)
+#define FW_PORT_CMD_OVLAN0(x) ((x) << 4)
+#define FW_PORT_CMD_IVLAN0(x) ((x) << 3)
+
+#define FW_PORT_CMD_TXIPG(x) ((x) << 19)
+
+#define FW_PORT_CMD_LSTATUS (1U << 31)
+#define FW_PORT_CMD_LSPEED(x) ((x) << 24)
+#define FW_PORT_CMD_LSPEED_GET(x) (((x) >> 24) & 0x3f)
+#define FW_PORT_CMD_TXPAUSE (1U << 23)
+#define FW_PORT_CMD_RXPAUSE (1U << 22)
+#define FW_PORT_CMD_MDIOCAP (1U << 21)
+#define FW_PORT_CMD_MDIOADDR_GET(x) (((x) >> 16) & 0x1f)
+#define FW_PORT_CMD_LPTXPAUSE (1U << 15)
+#define FW_PORT_CMD_LPRXPAUSE (1U << 14)
+#define FW_PORT_CMD_PTYPE_MASK 0x1f
+#define FW_PORT_CMD_PTYPE_GET(x) (((x) >> 8) & FW_PORT_CMD_PTYPE_MASK)
+#define FW_PORT_CMD_MODTYPE_MASK 0x1f
+#define FW_PORT_CMD_MODTYPE_GET(x) (((x) >> 0) & FW_PORT_CMD_MODTYPE_MASK)
+
+#define FW_PORT_CMD_PPPEN(x) ((x) << 31)
+#define FW_PORT_CMD_TPSRC(x) ((x) << 28)
+#define FW_PORT_CMD_NCSISRC(x) ((x) << 24)
+
+#define FW_PORT_CMD_CH0(x) ((x) << 20)
+#define FW_PORT_CMD_CH1(x) ((x) << 16)
+#define FW_PORT_CMD_CH2(x) ((x) << 12)
+#define FW_PORT_CMD_CH3(x) ((x) << 8)
+#define FW_PORT_CMD_NCSICH(x) ((x) << 4)
+
+enum fw_port_type {
+	FW_PORT_TYPE_FIBER,
+	FW_PORT_TYPE_KX4,
+	FW_PORT_TYPE_BT_SGMII,
+	FW_PORT_TYPE_KX,
+	FW_PORT_TYPE_BT_XAUI,
+	FW_PORT_TYPE_KR,
+	FW_PORT_TYPE_CX4,
+	FW_PORT_TYPE_TWINAX,
+
+	FW_PORT_TYPE_NONE = FW_PORT_CMD_PTYPE_MASK
+};
+
+enum fw_port_module_type {
+	FW_PORT_MOD_TYPE_NA,
+	FW_PORT_MOD_TYPE_LR,
+	FW_PORT_MOD_TYPE_SR,
+	FW_PORT_MOD_TYPE_ER,
+
+	FW_PORT_MOD_TYPE_NONE = FW_PORT_CMD_MODTYPE_MASK
+};
+
+/* port stats */
+#define FW_NUM_PORT_STATS 50
+#define FW_NUM_PORT_TX_STATS 23
+#define FW_NUM_PORT_RX_STATS 27
+
+enum fw_port_stats_tx_index {
+	FW_STAT_TX_PORT_BYTES_IX,
+	FW_STAT_TX_PORT_FRAMES_IX,
+	FW_STAT_TX_PORT_BCAST_IX,
+	FW_STAT_TX_PORT_MCAST_IX,
+	FW_STAT_TX_PORT_UCAST_IX,
+	FW_STAT_TX_PORT_ERROR_IX,
+	FW_STAT_TX_PORT_64B_IX,
+	FW_STAT_TX_PORT_65B_127B_IX,
+	FW_STAT_TX_PORT_128B_255B_IX,
+	FW_STAT_TX_PORT_256B_511B_IX,
+	FW_STAT_TX_PORT_512B_1023B_IX,
+	FW_STAT_TX_PORT_1024B_1518B_IX,
+	FW_STAT_TX_PORT_1519B_MAX_IX,
+	FW_STAT_TX_PORT_DROP_IX,
+	FW_STAT_TX_PORT_PAUSE_IX,
+	FW_STAT_TX_PORT_PPP0_IX,
+	FW_STAT_TX_PORT_PPP1_IX,
+	FW_STAT_TX_PORT_PPP2_IX,
+	FW_STAT_TX_PORT_PPP3_IX,
+	FW_STAT_TX_PORT_PPP4_IX,
+	FW_STAT_TX_PORT_PPP5_IX,
+	FW_STAT_TX_PORT_PPP6_IX,
+	FW_STAT_TX_PORT_PPP7_IX
+};
+
+enum fw_port_stat_rx_index {
+	FW_STAT_RX_PORT_BYTES_IX,
+	FW_STAT_RX_PORT_FRAMES_IX,
+	FW_STAT_RX_PORT_BCAST_IX,
+	FW_STAT_RX_PORT_MCAST_IX,
+	FW_STAT_RX_PORT_UCAST_IX,
+	FW_STAT_RX_PORT_MTU_ERROR_IX,
+	FW_STAT_RX_PORT_MTU_CRC_ERROR_IX,
+	FW_STAT_RX_PORT_CRC_ERROR_IX,
+	FW_STAT_RX_PORT_LEN_ERROR_IX,
+	FW_STAT_RX_PORT_SYM_ERROR_IX,
+	FW_STAT_RX_PORT_64B_IX,
+	FW_STAT_RX_PORT_65B_127B_IX,
+	FW_STAT_RX_PORT_128B_255B_IX,
+	FW_STAT_RX_PORT_256B_511B_IX,
+	FW_STAT_RX_PORT_512B_1023B_IX,
+	FW_STAT_RX_PORT_1024B_1518B_IX,
+	FW_STAT_RX_PORT_1519B_MAX_IX,
+	FW_STAT_RX_PORT_PAUSE_IX,
+	FW_STAT_RX_PORT_PPP0_IX,
+	FW_STAT_RX_PORT_PPP1_IX,
+	FW_STAT_RX_PORT_PPP2_IX,
+	FW_STAT_RX_PORT_PPP3_IX,
+	FW_STAT_RX_PORT_PPP4_IX,
+	FW_STAT_RX_PORT_PPP5_IX,
+	FW_STAT_RX_PORT_PPP6_IX,
+	FW_STAT_RX_PORT_PPP7_IX,
+	FW_STAT_RX_PORT_LESS_64B_IX
+};
+
+struct fw_port_stats_cmd {
+	__be32 op_to_portid;
+	__be32 retval_len16;
+	union fw_port_stats {
+		struct fw_port_stats_ctl {
+			u8 nstats_bg_bm;
+			u8 tx_ix;
+			__be16 r6;
+			__be32 r7;
+			__be64 stat0;
+			__be64 stat1;
+			__be64 stat2;
+			__be64 stat3;
+			__be64 stat4;
+			__be64 stat5;
+		} ctl;
+		struct fw_port_stats_all {
+			__be64 tx_bytes;
+			__be64 tx_frames;
+			__be64 tx_bcast;
+			__be64 tx_mcast;
+			__be64 tx_ucast;
+			__be64 tx_error;
+			__be64 tx_64b;
+			__be64 tx_65b_127b;
+			__be64 tx_128b_255b;
+			__be64 tx_256b_511b;
+			__be64 tx_512b_1023b;
+			__be64 tx_1024b_1518b;
+			__be64 tx_1519b_max;
+			__be64 tx_drop;
+			__be64 tx_pause;
+			__be64 tx_ppp0;
+			__be64 tx_ppp1;
+			__be64 tx_ppp2;
+			__be64 tx_ppp3;
+			__be64 tx_ppp4;
+			__be64 tx_ppp5;
+			__be64 tx_ppp6;
+			__be64 tx_ppp7;
+			__be64 rx_bytes;
+			__be64 rx_frames;
+			__be64 rx_bcast;
+			__be64 rx_mcast;
+			__be64 rx_ucast;
+			__be64 rx_mtu_error;
+			__be64 rx_mtu_crc_error;
+			__be64 rx_crc_error;
+			__be64 rx_len_error;
+			__be64 rx_sym_error;
+			__be64 rx_64b;
+			__be64 rx_65b_127b;
+			__be64 rx_128b_255b;
+			__be64 rx_256b_511b;
+			__be64 rx_512b_1023b;
+			__be64 rx_1024b_1518b;
+			__be64 rx_1519b_max;
+			__be64 rx_pause;
+			__be64 rx_ppp0;
+			__be64 rx_ppp1;
+			__be64 rx_ppp2;
+			__be64 rx_ppp3;
+			__be64 rx_ppp4;
+			__be64 rx_ppp5;
+			__be64 rx_ppp6;
+			__be64 rx_ppp7;
+			__be64 rx_less_64b;
+			__be64 rx_bg_drop;
+			__be64 rx_bg_trunc;
+		} all;
+	} u;
+};
+
+#define FW_PORT_STATS_CMD_NSTATS(x) ((x) << 4)
+#define FW_PORT_STATS_CMD_BG_BM(x) ((x) << 0)
+#define FW_PORT_STATS_CMD_TX(x) ((x) << 7)
+#define FW_PORT_STATS_CMD_IX(x) ((x) << 0)
+
+/* port loopback stats */
+#define FW_NUM_LB_STATS 16
+enum fw_port_lb_stats_index {
+	FW_STAT_LB_PORT_BYTES_IX,
+	FW_STAT_LB_PORT_FRAMES_IX,
+	FW_STAT_LB_PORT_BCAST_IX,
+	FW_STAT_LB_PORT_MCAST_IX,
+	FW_STAT_LB_PORT_UCAST_IX,
+	FW_STAT_LB_PORT_ERROR_IX,
+	FW_STAT_LB_PORT_64B_IX,
+	FW_STAT_LB_PORT_65B_127B_IX,
+	FW_STAT_LB_PORT_128B_255B_IX,
+	FW_STAT_LB_PORT_256B_511B_IX,
+	FW_STAT_LB_PORT_512B_1023B_IX,
+	FW_STAT_LB_PORT_1024B_1518B_IX,
+	FW_STAT_LB_PORT_1519B_MAX_IX,
+	FW_STAT_LB_PORT_DROP_FRAMES_IX
+};
+
+struct fw_port_lb_stats_cmd {
+	__be32 op_to_lbport;
+	__be32 retval_len16;
+	union fw_port_lb_stats {
+		struct fw_port_lb_stats_ctl {
+			u8 nstats_bg_bm;
+			u8 ix_pkd;
+			__be16 r6;
+			__be32 r7;
+			__be64 stat0;
+			__be64 stat1;
+			__be64 stat2;
+			__be64 stat3;
+			__be64 stat4;
+			__be64 stat5;
+		} ctl;
+		struct fw_port_lb_stats_all {
+			__be64 tx_bytes;
+			__be64 tx_frames;
+			__be64 tx_bcast;
+			__be64 tx_mcast;
+			__be64 tx_ucast;
+			__be64 tx_error;
+			__be64 tx_64b;
+			__be64 tx_65b_127b;
+			__be64 tx_128b_255b;
+			__be64 tx_256b_511b;
+			__be64 tx_512b_1023b;
+			__be64 tx_1024b_1518b;
+			__be64 tx_1519b_max;
+			__be64 rx_lb_drop;
+			__be64 rx_lb_trunc;
+		} all;
+	} u;
+};
+
+#define FW_PORT_LB_STATS_CMD_LBPORT(x) ((x) << 0)
+#define FW_PORT_LB_STATS_CMD_NSTATS(x) ((x) << 4)
+#define FW_PORT_LB_STATS_CMD_BG_BM(x) ((x) << 0)
+#define FW_PORT_LB_STATS_CMD_IX(x) ((x) << 0)
+
+struct fw_rss_ind_tbl_cmd {
+	__be32 op_to_viid;
+#define FW_RSS_IND_TBL_CMD_VIID(x) ((x) << 0)
+	__be32 retval_len16;
+	__be16 niqid;
+	__be16 startidx;
+	__be32 r3;
+	__be32 iq0_to_iq2;
+#define FW_RSS_IND_TBL_CMD_IQ0(x) ((x) << 20)
+#define FW_RSS_IND_TBL_CMD_IQ1(x) ((x) << 10)
+#define FW_RSS_IND_TBL_CMD_IQ2(x) ((x) << 0)
+	__be32 iq3_to_iq5;
+	__be32 iq6_to_iq8;
+	__be32 iq9_to_iq11;
+	__be32 iq12_to_iq14;
+	__be32 iq15_to_iq17;
+	__be32 iq18_to_iq20;
+	__be32 iq21_to_iq23;
+	__be32 iq24_to_iq26;
+	__be32 iq27_to_iq29;
+	__be32 iq30_iq31;
+	__be32 r15_lo;
+};
+
+struct fw_rss_glb_config_cmd {
+	__be32 op_to_write;
+	__be32 retval_len16;
+	union fw_rss_glb_config {
+		struct fw_rss_glb_config_manual {
+			__be32 mode_pkd;
+			__be32 r3;
+			__be64 r4;
+			__be64 r5;
+		} manual;
+		struct fw_rss_glb_config_basicvirtual {
+			__be32 mode_pkd;
+			__be32 synmapen_to_hashtoeplitz;
+#define FW_RSS_GLB_CONFIG_CMD_SYNMAPEN      (1U << 8)
+#define FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV6 (1U << 7)
+#define FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV6 (1U << 6)
+#define FW_RSS_GLB_CONFIG_CMD_SYN4TUPENIPV4 (1U << 5)
+#define FW_RSS_GLB_CONFIG_CMD_SYN2TUPENIPV4 (1U << 4)
+#define FW_RSS_GLB_CONFIG_CMD_OFDMAPEN      (1U << 3)
+#define FW_RSS_GLB_CONFIG_CMD_TNLMAPEN      (1U << 2)
+#define FW_RSS_GLB_CONFIG_CMD_TNLALLLKP     (1U << 1)
+#define FW_RSS_GLB_CONFIG_CMD_HASHTOEPLITZ  (1U << 0)
+			__be64 r8;
+			__be64 r9;
+		} basicvirtual;
+	} u;
+};
+
+#define FW_RSS_GLB_CONFIG_CMD_MODE(x)	((x) << 28)
+
+#define FW_RSS_GLB_CONFIG_CMD_MODE_MANUAL	0
+#define FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL	1
+
+struct fw_rss_vi_config_cmd {
+	__be32 op_to_viid;
+#define FW_RSS_VI_CONFIG_CMD_VIID(x) ((x) << 0)
+	__be32 retval_len16;
+	union fw_rss_vi_config {
+		struct fw_rss_vi_config_manual {
+			__be64 r3;
+			__be64 r4;
+			__be64 r5;
+		} manual;
+		struct fw_rss_vi_config_basicvirtual {
+			__be32 r6;
+			__be32 defaultq_to_ip4udpen;
+#define FW_RSS_VI_CONFIG_CMD_DEFAULTQ(x)  ((x) << 16)
+#define FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN (1U << 4)
+#define FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN  (1U << 3)
+#define FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN (1U << 2)
+#define FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN  (1U << 1)
+#define FW_RSS_VI_CONFIG_CMD_IP4UDPEN     (1U << 0)
+			__be64 r9;
+			__be64 r10;
+		} basicvirtual;
+	} u;
+};
+
+enum fw_error_type {
+	FW_ERROR_TYPE_EXCEPTION		= 0x0,
+	FW_ERROR_TYPE_HWMODULE		= 0x1,
+	FW_ERROR_TYPE_WR		= 0x2,
+	FW_ERROR_TYPE_ACL		= 0x3,
+};
+
+struct fw_error_cmd {
+	__be32 op_to_type;
+	__be32 len16_pkd;
+	union fw_error {
+		struct fw_error_exception {
+			__be32 info[6];
+		} exception;
+		struct fw_error_hwmodule {
+			__be32 regaddr;
+			__be32 regval;
+		} hwmodule;
+		struct fw_error_wr {
+			__be16 cidx;
+			__be16 pfn_vfn;
+			__be32 eqid;
+			u8 wrhdr[16];
+		} wr;
+		struct fw_error_acl {
+			__be16 cidx;
+			__be16 pfn_vfn;
+			__be32 eqid;
+			__be16 mv_pkd;
+			u8 val[6];
+			__be64 r4;
+		} acl;
+	} u;
+};
+
+struct fw_debug_cmd {
+	__be32 op_type;
+#define FW_DEBUG_CMD_TYPE_GET(x) ((x) & 0xff)
+	__be32 len16_pkd;
+	union fw_debug {
+		struct fw_debug_assert {
+			__be32 fcid;
+			__be32 line;
+			__be32 x;
+			__be32 y;
+			u8 filename_0_7[8];
+			u8 filename_8_15[8];
+			__be64 r3;
+		} assert;
+		struct fw_debug_prt {
+			__be16 dprtstridx;
+			__be16 r3[3];
+			__be32 dprtstrparam0;
+			__be32 dprtstrparam1;
+			__be32 dprtstrparam2;
+			__be32 dprtstrparam3;
+		} prt;
+	} u;
+};
+
+struct fw_hdr {
+	u8 ver;
+	u8 reserved1;
+	__be16	len512;			/* bin length in units of 512-bytes */
+	__be32	fw_ver;			/* firmware version */
+	__be32	tp_microcode_ver;
+	u8 intfver_nic;
+	u8 intfver_vnic;
+	u8 intfver_ofld;
+	u8 intfver_ri;
+	u8 intfver_iscsipdu;
+	u8 intfver_iscsi;
+	u8 intfver_fcoe;
+	u8 reserved2;
+	__be32  reserved3[27];
+};
+
+#define FW_HDR_FW_VER_MAJOR_GET(x) (((x) >> 24) & 0xff)
+#define FW_HDR_FW_VER_MINOR_GET(x) (((x) >> 16) & 0xff)
+#define FW_HDR_FW_VER_MICRO_GET(x) (((x) >> 8) & 0xff)
+#define FW_HDR_FW_VER_BUILD_GET(x) (((x) >> 0) & 0xff)
+#endif /* _T4FW_INTERFACE_H_ */
-- 
1.5.4

