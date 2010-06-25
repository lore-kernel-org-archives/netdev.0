From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 2/9] cxgb4vf: update to latest T4 firmware API file
Date: Fri, 25 Jun 2010 15:10:32 -0700
Message-ID: <201006251510.32478.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:20772 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756080Ab0FYWKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 18:10:33 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5PMAXrO019385
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 15:10:33 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update to latest T4 firmware API file.

Signed-off-by: Casey Leedom
---
 drivers/net/cxgb4/t4_hw.c    |    2 +-
 drivers/net/cxgb4/t4fw_api.h |   27 +++++++++++++++++++++------
 2 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index d92129b..3e63d14 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -2518,7 +2518,7 @@ int t4_cfg_pfvf(struct adapter *adap, unsigned int mbox, 
unsigned int pf,
 	c.retval_len16 = htonl(FW_LEN16(c));
 	c.niqflint_niq = htonl(FW_PFVF_CMD_NIQFLINT(rxqi) |
 			       FW_PFVF_CMD_NIQ(rxq));
-	c.cmask_to_neq = htonl(FW_PFVF_CMD_CMASK(cmask) |
+	c.type_to_neq = htonl(FW_PFVF_CMD_CMASK(cmask) |
 			       FW_PFVF_CMD_PMASK(pmask) |
 			       FW_PFVF_CMD_NEQ(txq));
 	c.tc_to_nexactf = htonl(FW_PFVF_CMD_TC(tc) | FW_PFVF_CMD_NVI(vi) |
diff --git a/drivers/net/cxgb4/t4fw_api.h b/drivers/net/cxgb4/t4fw_api.h
index 111c2a5..ca45df8 100644
--- a/drivers/net/cxgb4/t4fw_api.h
+++ b/drivers/net/cxgb4/t4fw_api.h
@@ -71,6 +71,7 @@ struct fw_wr_hdr {
 #define FW_WR_ATOMIC(x)	 ((x) << 23)
 #define FW_WR_FLUSH(x)   ((x) << 22)
 #define FW_WR_COMPL(x)   ((x) << 21)
+#define FW_WR_IMMDLEN_MASK 0xff
 #define FW_WR_IMMDLEN(x) ((x) << 0)
 
 #define FW_WR_EQUIQ	(1U << 31)
@@ -447,7 +448,9 @@ enum fw_params_param_dev {
 	FW_PARAMS_PARAM_DEV_INTVER_RI	= 0x07,
 	FW_PARAMS_PARAM_DEV_INTVER_ISCSIPDU = 0x08,
 	FW_PARAMS_PARAM_DEV_INTVER_ISCSI = 0x09,
-	FW_PARAMS_PARAM_DEV_INTVER_FCOE = 0x0A
+	FW_PARAMS_PARAM_DEV_INTVER_FCOE = 0x0A,
+	FW_PARAMS_PARAM_DEV_FWREV = 0x0B,
+	FW_PARAMS_PARAM_DEV_TPREV = 0x0C,
 };
 
 /*
@@ -518,7 +521,7 @@ struct fw_pfvf_cmd {
 	__be32 op_to_vfn;
 	__be32 retval_len16;
 	__be32 niqflint_niq;
-	__be32 cmask_to_neq;
+	__be32 type_to_neq;
 	__be32 tc_to_nexactf;
 	__be32 r_caps_to_nethctrl;
 	__be16 nricq;
@@ -535,11 +538,16 @@ struct fw_pfvf_cmd {
 #define FW_PFVF_CMD_NIQ(x) ((x) << 0)
 #define FW_PFVF_CMD_NIQ_GET(x) (((x) >> 0) & 0xfffff)
 
+#define FW_PFVF_CMD_TYPE (1 << 31)
+#define FW_PFVF_CMD_TYPE_GET(x) (((x) >> 31) & 0x1)
+
 #define FW_PFVF_CMD_CMASK(x) ((x) << 24)
-#define FW_PFVF_CMD_CMASK_GET(x) (((x) >> 24) & 0xf)
+#define FW_PFVF_CMD_CMASK_MASK 0xf
+#define FW_PFVF_CMD_CMASK_GET(x) (((x) >> 24) & FW_PFVF_CMD_CMASK_MASK)
 
 #define FW_PFVF_CMD_PMASK(x) ((x) << 20)
-#define FW_PFVF_CMD_PMASK_GET(x) (((x) >> 20) & 0xf)
+#define FW_PFVF_CMD_PMASK_MASK 0xf
+#define FW_PFVF_CMD_PMASK_GET(x) (((x) >> 20) & FW_PFVF_CMD_PMASK_MASK)
 
 #define FW_PFVF_CMD_NEQ(x) ((x) << 0)
 #define FW_PFVF_CMD_NEQ_GET(x) (((x) >> 0) & 0xfffff)
@@ -692,6 +700,7 @@ struct fw_eq_eth_cmd {
 #define FW_EQ_ETH_CMD_EQID(x) ((x) << 0)
 #define FW_EQ_ETH_CMD_EQID_GET(x) (((x) >> 0) & 0xfffff)
 #define FW_EQ_ETH_CMD_PHYSEQID(x) ((x) << 0)
+#define FW_EQ_ETH_CMD_PHYSEQID_GET(x) (((x) >> 0) & 0xfffff)
 
 #define FW_EQ_ETH_CMD_FETCHSZM(x) ((x) << 26)
 #define FW_EQ_ETH_CMD_STATUSPGNS(x) ((x) << 25)
@@ -832,12 +841,14 @@ struct fw_vi_cmd {
 #define FW_VI_CMD_VIID(x) ((x) << 0)
 #define FW_VI_CMD_VIID_GET(x) ((x) & 0xfff)
 #define FW_VI_CMD_PORTID(x) ((x) << 4)
+#define FW_VI_CMD_PORTID_GET(x) (((x) >> 4) & 0xf)
 #define FW_VI_CMD_RSSSIZE_GET(x) (((x) >> 0) & 0x7ff)
 
 /* Special VI_MAC command index ids */
 #define FW_VI_MAC_ADD_MAC		0x3FF
 #define FW_VI_MAC_ADD_PERSIST_MAC	0x3FE
 #define FW_VI_MAC_MAC_BASED_FREE	0x3FD
+#define FW_CLS_TCAM_NUM_ENTRIES		336
 
 enum fw_vi_mac_smac {
 	FW_VI_MAC_MPS_TCAM_ENTRY,
@@ -888,6 +899,7 @@ struct fw_vi_rxmode_cmd {
 };
 
 #define FW_VI_RXMODE_CMD_VIID(x) ((x) << 0)
+#define FW_VI_RXMODE_CMD_MTU_MASK 0xffff
 #define FW_VI_RXMODE_CMD_MTU(x) ((x) << 16)
 #define FW_VI_RXMODE_CMD_PROMISCEN_MASK 0x3
 #define FW_VI_RXMODE_CMD_PROMISCEN(x) ((x) << 14)
@@ -1173,6 +1185,7 @@ struct fw_port_cmd {
 #define FW_PORT_CMD_PORTID_GET(x) (((x) >> 0) & 0xf)
 
 #define FW_PORT_CMD_ACTION(x) ((x) << 16)
+#define FW_PORT_CMD_ACTION_GET(x) (((x) >> 16) & 0xffff)
 
 #define FW_PORT_CMD_CTLBF(x) ((x) << 10)
 #define FW_PORT_CMD_OVLAN3(x) ((x) << 7)
@@ -1487,6 +1500,7 @@ struct fw_rss_glb_config_cmd {
 };
 
 #define FW_RSS_GLB_CONFIG_CMD_MODE(x)	((x) << 28)
+#define FW_RSS_GLB_CONFIG_CMD_MODE_GET(x) (((x) >> 28) & 0xf)
 
 #define FW_RSS_GLB_CONFIG_CMD_MODE_MANUAL	0
 #define FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL	1
@@ -1503,13 +1517,14 @@ struct fw_rss_vi_config_cmd {
 		} manual;
 		struct fw_rss_vi_config_basicvirtual {
 			__be32 r6;
-			__be32 defaultq_to_ip4udpen;
+			__be32 defaultq_to_udpen;
 #define FW_RSS_VI_CONFIG_CMD_DEFAULTQ(x)  ((x) << 16)
+#define FW_RSS_VI_CONFIG_CMD_DEFAULTQ_GET(x) (((x) >> 16) & 0x3ff)
 #define FW_RSS_VI_CONFIG_CMD_IP6FOURTUPEN (1U << 4)
 #define FW_RSS_VI_CONFIG_CMD_IP6TWOTUPEN  (1U << 3)
 #define FW_RSS_VI_CONFIG_CMD_IP4FOURTUPEN (1U << 2)
 #define FW_RSS_VI_CONFIG_CMD_IP4TWOTUPEN  (1U << 1)
-#define FW_RSS_VI_CONFIG_CMD_IP4UDPEN     (1U << 0)
+#define FW_RSS_VI_CONFIG_CMD_UDPEN        (1U << 0)
 			__be64 r9;
 			__be64 r10;
 		} basicvirtual;
