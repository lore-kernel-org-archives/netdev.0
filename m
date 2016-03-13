From: Varun Prakash <varun@chelsio.com>
Subject: [target-pending 04/12] cxgb4, iw_cxgb4: move definitions to common header file
Date: Sun, 13 Mar 2016 18:58:54 +0530
Message-ID: <fdd1d9c0703b33b8f2d497e99f0883c2a4354a2a.1457872112.git.varun@chelsio.com>
References: <cover.1457872112.git.varun@chelsio.com>
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, swise@opengridcomputing.com,
	indranil@chelsio.com, kxie@chelsio.com, hariprasad@chelsio.com,
	varun@chelsio.com
To: nab@linux-iscsi.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:1644 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932702AbcCMN3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 09:29:24 -0400
In-Reply-To: <cover.1457872112.git.varun@chelsio.com>
In-Reply-To: <cover.1457872112.git.varun@chelsio.com>
References: <cover.1457872112.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

move struct tcp_options, struct cpl_pass_accept_req,
enum defining congestion control algorithms
and associated macros to common header file t4_msg.h

Signed-off-by: Varun Prakash <varun@chelsio.com>
Signed-off-by: Nicholas Bellinger <nab@linux-iscsi.org>
---
 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h   | 81 -----------------------------
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h | 81 +++++++++++++++++++++++++++++
 2 files changed, 81 insertions(+), 81 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
index 343e8daf..5b66da3 100644
--- a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
+++ b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
@@ -753,71 +753,6 @@ struct fw_ri_wr {
 #define FW_RI_WR_P2PTYPE_G(x)	\
 	(((x) >> FW_RI_WR_P2PTYPE_S) & FW_RI_WR_P2PTYPE_M)
 
-struct tcp_options {
-	__be16 mss;
-	__u8 wsf;
-#if defined(__LITTLE_ENDIAN_BITFIELD)
-	__u8:4;
-	__u8 unknown:1;
-	__u8:1;
-	__u8 sack:1;
-	__u8 tstamp:1;
-#else
-	__u8 tstamp:1;
-	__u8 sack:1;
-	__u8:1;
-	__u8 unknown:1;
-	__u8:4;
-#endif
-};
-
-struct cpl_pass_accept_req {
-	union opcode_tid ot;
-	__be16 rsvd;
-	__be16 len;
-	__be32 hdr_len;
-	__be16 vlan;
-	__be16 l2info;
-	__be32 tos_stid;
-	struct tcp_options tcpopt;
-};
-
-/* cpl_pass_accept_req.hdr_len fields */
-#define SYN_RX_CHAN_S    0
-#define SYN_RX_CHAN_M    0xF
-#define SYN_RX_CHAN_V(x) ((x) << SYN_RX_CHAN_S)
-#define SYN_RX_CHAN_G(x) (((x) >> SYN_RX_CHAN_S) & SYN_RX_CHAN_M)
-
-#define TCP_HDR_LEN_S    10
-#define TCP_HDR_LEN_M    0x3F
-#define TCP_HDR_LEN_V(x) ((x) << TCP_HDR_LEN_S)
-#define TCP_HDR_LEN_G(x) (((x) >> TCP_HDR_LEN_S) & TCP_HDR_LEN_M)
-
-#define IP_HDR_LEN_S    16
-#define IP_HDR_LEN_M    0x3FF
-#define IP_HDR_LEN_V(x) ((x) << IP_HDR_LEN_S)
-#define IP_HDR_LEN_G(x) (((x) >> IP_HDR_LEN_S) & IP_HDR_LEN_M)
-
-#define ETH_HDR_LEN_S    26
-#define ETH_HDR_LEN_M    0x1F
-#define ETH_HDR_LEN_V(x) ((x) << ETH_HDR_LEN_S)
-#define ETH_HDR_LEN_G(x) (((x) >> ETH_HDR_LEN_S) & ETH_HDR_LEN_M)
-
-/* cpl_pass_accept_req.l2info fields */
-#define SYN_MAC_IDX_S    0
-#define SYN_MAC_IDX_M    0x1FF
-#define SYN_MAC_IDX_V(x) ((x) << SYN_MAC_IDX_S)
-#define SYN_MAC_IDX_G(x) (((x) >> SYN_MAC_IDX_S) & SYN_MAC_IDX_M)
-
-#define SYN_XACT_MATCH_S    9
-#define SYN_XACT_MATCH_V(x) ((x) << SYN_XACT_MATCH_S)
-#define SYN_XACT_MATCH_F    SYN_XACT_MATCH_V(1U)
-
-#define SYN_INTF_S    12
-#define SYN_INTF_M    0xF
-#define SYN_INTF_V(x) ((x) << SYN_INTF_S)
-#define SYN_INTF_G(x) (((x) >> SYN_INTF_S) & SYN_INTF_M)
-
 struct ulptx_idata {
 	__be32 cmd_more;
 	__be32 len;
@@ -836,20 +771,4 @@ struct ulptx_idata {
 #define RX_DACK_CHANGE_V(x) ((x) << RX_DACK_CHANGE_S)
 #define RX_DACK_CHANGE_F    RX_DACK_CHANGE_V(1U)
 
-enum {                     /* TCP congestion control algorithms */
-	CONG_ALG_RENO,
-	CONG_ALG_TAHOE,
-	CONG_ALG_NEWRENO,
-	CONG_ALG_HIGHSPEED
-};
-
-#define CONG_CNTRL_S    14
-#define CONG_CNTRL_M    0x3
-#define CONG_CNTRL_V(x) ((x) << CONG_CNTRL_S)
-#define CONG_CNTRL_G(x) (((x) >> CONG_CNTRL_S) & CONG_CNTRL_M)
-
-#define T5_ISS_S    18
-#define T5_ISS_V(x) ((x) << T5_ISS_S)
-#define T5_ISS_F    T5_ISS_V(1U)
-
 #endif /* _T4FW_RI_API_H_ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index a072d34..5753bd4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -344,6 +344,87 @@ struct cpl_pass_open_rpl {
 	u8 status;
 };
 
+struct tcp_options {
+	__be16 mss;
+	__u8 wsf;
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	__u8:4;
+	__u8 unknown:1;
+	__u8:1;
+	__u8 sack:1;
+	__u8 tstamp:1;
+#else
+	__u8 tstamp:1;
+	__u8 sack:1;
+	__u8:1;
+	__u8 unknown:1;
+	__u8:4;
+#endif
+};
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
+#define SYN_RX_CHAN_S    0
+#define SYN_RX_CHAN_M    0xF
+#define SYN_RX_CHAN_V(x) ((x) << SYN_RX_CHAN_S)
+#define SYN_RX_CHAN_G(x) (((x) >> SYN_RX_CHAN_S) & SYN_RX_CHAN_M)
+
+#define TCP_HDR_LEN_S    10
+#define TCP_HDR_LEN_M    0x3F
+#define TCP_HDR_LEN_V(x) ((x) << TCP_HDR_LEN_S)
+#define TCP_HDR_LEN_G(x) (((x) >> TCP_HDR_LEN_S) & TCP_HDR_LEN_M)
+
+#define IP_HDR_LEN_S    16
+#define IP_HDR_LEN_M    0x3FF
+#define IP_HDR_LEN_V(x) ((x) << IP_HDR_LEN_S)
+#define IP_HDR_LEN_G(x) (((x) >> IP_HDR_LEN_S) & IP_HDR_LEN_M)
+
+#define ETH_HDR_LEN_S    26
+#define ETH_HDR_LEN_M    0x1F
+#define ETH_HDR_LEN_V(x) ((x) << ETH_HDR_LEN_S)
+#define ETH_HDR_LEN_G(x) (((x) >> ETH_HDR_LEN_S) & ETH_HDR_LEN_M)
+
+/* cpl_pass_accept_req.l2info fields */
+#define SYN_MAC_IDX_S    0
+#define SYN_MAC_IDX_M    0x1FF
+#define SYN_MAC_IDX_V(x) ((x) << SYN_MAC_IDX_S)
+#define SYN_MAC_IDX_G(x) (((x) >> SYN_MAC_IDX_S) & SYN_MAC_IDX_M)
+
+#define SYN_XACT_MATCH_S    9
+#define SYN_XACT_MATCH_V(x) ((x) << SYN_XACT_MATCH_S)
+#define SYN_XACT_MATCH_F    SYN_XACT_MATCH_V(1U)
+
+#define SYN_INTF_S    12
+#define SYN_INTF_M    0xF
+#define SYN_INTF_V(x) ((x) << SYN_INTF_S)
+#define SYN_INTF_G(x) (((x) >> SYN_INTF_S) & SYN_INTF_M)
+
+enum {                     /* TCP congestion control algorithms */
+	CONG_ALG_RENO,
+	CONG_ALG_TAHOE,
+	CONG_ALG_NEWRENO,
+	CONG_ALG_HIGHSPEED
+};
+
+#define CONG_CNTRL_S    14
+#define CONG_CNTRL_M    0x3
+#define CONG_CNTRL_V(x) ((x) << CONG_CNTRL_S)
+#define CONG_CNTRL_G(x) (((x) >> CONG_CNTRL_S) & CONG_CNTRL_M)
+
+#define T5_ISS_S    18
+#define T5_ISS_V(x) ((x) << T5_ISS_S)
+#define T5_ISS_F    T5_ISS_V(1U)
+
 struct cpl_pass_accept_rpl {
 	WR_HDR;
 	union opcode_tid ot;
-- 
2.0.2
