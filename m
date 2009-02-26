From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/5] [net-next] qlge: Add defines for firmware support.
Date: Thu, 26 Feb 2009 12:08:32 -0800
Message-ID: <1235678916-2856-1-git-send-email-ron.mercer@qlogic.com>
References: <20090226200746.GA23769@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:10180 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbZBZULx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 15:11:53 -0500
In-Reply-To: <20090226200746.GA23769@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h         |   97 +++++++++++++++++++++++++-------------
 drivers/net/qlge/qlge_ethtool.c |    3 +-
 2 files changed, 66 insertions(+), 34 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index e6fdce9..8b3c37a 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -164,7 +164,7 @@ enum {
 	CSR_RP = (1 << 10),
 	CSR_CMD_PARM_SHIFT = 22,
 	CSR_CMD_NOP = 0x00000000,
-	CSR_CMD_SET_RST = 0x1000000,
+	CSR_CMD_SET_RST = 0x10000000,
 	CSR_CMD_CLR_RST = 0x20000000,
 	CSR_CMD_SET_PAUSE = 0x30000000,
 	CSR_CMD_CLR_PAUSE = 0x40000000,
@@ -424,7 +424,7 @@ enum {
 	RX_SYMBOL_ERR = 0x00000370,
 	RX_MAC_ERR = 0x00000378,
 	RX_CTL_PKTS = 0x00000380,
-	RX_PAUSE_PKTS = 0x00000384,
+	RX_PAUSE_PKTS = 0x00000388,
 	RX_64_PKTS = 0x00000390,
 	RX_65_TO_127_PKTS = 0x00000398,
 	RX_128_255_PKTS = 0x000003a0,
@@ -733,6 +733,11 @@ enum {
 	AEN_LINK_DOWN = 0x00008012,
 	AEN_IDC_CMPLT = 0x00008100,
 	AEN_IDC_REQ = 0x00008101,
+	AEN_IDC_EXT = 0x00008102,
+	AEN_DCBX_CHG = 0x00008110,
+	AEN_AEN_LOST = 0x00008120,
+	AEN_AEN_SFP_IN = 0x00008130,
+	AEN_AEN_SFP_OUT = 0x00008131,
 	AEN_FW_INIT_DONE = 0x00008400,
 	AEN_FW_INIT_FAIL = 0x00008401,
 
@@ -742,40 +747,48 @@ enum {
 	MB_CMD_MB_TEST = 0x00000006,
 	MB_CMD_CSUM_TEST = 0x00000007,	/* Verify Checksum */
 	MB_CMD_ABOUT_FW = 0x00000008,
+	MB_CMD_COPY_RISC_RAM = 0x0000000a,
 	MB_CMD_LOAD_RISC_RAM = 0x0000000b,
 	MB_CMD_DUMP_RISC_RAM = 0x0000000c,
 	MB_CMD_WRITE_RAM = 0x0000000d,
+	MB_CMD_INIT_RISC_RAM = 0x0000000e,
 	MB_CMD_READ_RAM = 0x0000000f,
 	MB_CMD_STOP_FW = 0x00000014,
 	MB_CMD_MAKE_SYS_ERR = 0x0000002a,
+	MB_CMD_WRITE_SFP = 0x00000030,
+	MB_CMD_READ_SFP = 0x00000031,
 	MB_CMD_INIT_FW = 0x00000060,
-	MB_CMD_GET_INIT_CB = 0x00000061,
+	MB_CMD_GET_IFCB = 0x00000061,
 	MB_CMD_GET_FW_STATE = 0x00000069,
 	MB_CMD_IDC_REQ = 0x00000100,	/* Inter-Driver Communication */
 	MB_CMD_IDC_ACK = 0x00000101,	/* Inter-Driver Communication */
 	MB_CMD_SET_WOL_MODE = 0x00000110,	/* Wake On Lan */
-	MB_WOL_DISABLE = 0x00000000,
-	MB_WOL_MAGIC_PKT = 0x00000001,
-	MB_WOL_FLTR = 0x00000002,
-	MB_WOL_UCAST = 0x00000004,
-	MB_WOL_MCAST = 0x00000008,
-	MB_WOL_BCAST = 0x00000010,
-	MB_WOL_LINK_UP = 0x00000020,
-	MB_WOL_LINK_DOWN = 0x00000040,
+	MB_WOL_DISABLE = 0,
+	MB_WOL_MAGIC_PKT = (1 << 1),
+	MB_WOL_FLTR = (1 << 2),
+	MB_WOL_UCAST = (1 << 3),
+	MB_WOL_MCAST = (1 << 4),
+	MB_WOL_BCAST = (1 << 5),
+	MB_WOL_LINK_UP = (1 << 6),
+	MB_WOL_LINK_DOWN = (1 << 7),
 	MB_CMD_SET_WOL_FLTR = 0x00000111,	/* Wake On Lan Filter */
-	MB_CMD_CLEAR_WOL_FLTR = 0x00000112,	/* Wake On Lan Filter */
+	MB_CMD_CLEAR_WOL_FLTR = 0x00000112, /* Wake On Lan Filter */
 	MB_CMD_SET_WOL_MAGIC = 0x00000113,	/* Wake On Lan Magic Packet */
-	MB_CMD_CLEAR_WOL_MAGIC = 0x00000114,	/* Wake On Lan Magic Packet */
+	MB_CMD_CLEAR_WOL_MAGIC = 0x00000114,/* Wake On Lan Magic Packet */
+	MB_CMD_SET_WOL_IMMED = 0x00000115,
 	MB_CMD_PORT_RESET = 0x00000120,
 	MB_CMD_SET_PORT_CFG = 0x00000122,
 	MB_CMD_GET_PORT_CFG = 0x00000123,
-	MB_CMD_SET_ASIC_VOLTS = 0x00000130,
-	MB_CMD_GET_SNS_DATA = 0x00000131,	/* Temp and Volt Sense data. */
+	MB_CMD_GET_LINK_STS = 0x00000124,
 
 	/* Mailbox Command Status. */
 	MB_CMD_STS_GOOD = 0x00004000,	/* Success. */
 	MB_CMD_STS_INTRMDT = 0x00001000,	/* Intermediate Complete. */
-	MB_CMD_STS_ERR = 0x00004005,	/* Error. */
+	MB_CMD_STS_INVLD_CMD = 0x00004001,	/* Invalid. */
+	MB_CMD_STS_XFC_ERR = 0x00004002,	/* Interface Error. */
+	MB_CMD_STS_CSUM_ERR = 0x00004003,	/* Csum Error. */
+	MB_CMD_STS_ERR = 0x00004005,	/* System Error. */
+	MB_CMD_STS_PARAM_ERR = 0x00004006,	/* Parameter Error. */
 };
 
 struct mbox_params {
@@ -967,6 +980,7 @@ struct ib_mac_iocb_rsp {
 	__le16 vlan_id;		/* 12 bits */
 #define IB_MAC_IOCB_RSP_C	0x1000	/* VLAN CFI bit */
 #define IB_MAC_IOCB_RSP_COS_SHIFT	12	/* class of service value */
+#define IB_MAC_IOCB_RSP_VLAN_MASK	0x0ffff
 
 	__le16 reserved1;
 	__le32 reserved2[6];
@@ -1032,6 +1046,7 @@ struct wqicb {
 #define Q_LEN_CPP_16	0x0001
 #define Q_LEN_CPP_32	0x0002
 #define Q_LEN_CPP_64	0x0003
+#define Q_LEN_CPP_512	0x0006
 	__le16 flags;
 #define Q_PRI_SHIFT	1
 #define Q_FLAGS_LC	0x1000
@@ -1313,27 +1328,43 @@ enum {
 	QL_DMA64 = (1 << 5),
 	QL_PROMISCUOUS = (1 << 6),
 	QL_ALLMULTI = (1 << 7),
+	QL_PORT_CFG = (1 << 8),
+	QL_CAM_RT_SET = (1 << 9),
 };
 
 /* link_status bit definitions */
 enum {
-	LOOPBACK_MASK = 0x00000700,
-	LOOPBACK_PCS = 0x00000100,
-	LOOPBACK_HSS = 0x00000200,
-	LOOPBACK_EXT = 0x00000300,
-	PAUSE_MASK = 0x000000c0,
-	PAUSE_STD = 0x00000040,
-	PAUSE_PRI = 0x00000080,
-	SPEED_MASK = 0x00000038,
-	SPEED_100Mb = 0x00000000,
-	SPEED_1Gb = 0x00000008,
-	SPEED_10Gb = 0x00000010,
-	LINK_TYPE_MASK = 0x00000007,
-	LINK_TYPE_XFI = 0x00000001,
-	LINK_TYPE_XAUI = 0x00000002,
-	LINK_TYPE_XFI_BP = 0x00000003,
-	LINK_TYPE_XAUI_BP = 0x00000004,
-	LINK_TYPE_10GBASET = 0x00000005,
+	STS_LOOPBACK_MASK = 0x00000700,
+	STS_LOOPBACK_PCS = 0x00000100,
+	STS_LOOPBACK_HSS = 0x00000200,
+	STS_LOOPBACK_EXT = 0x00000300,
+	STS_PAUSE_MASK = 0x000000c0,
+	STS_PAUSE_STD = 0x00000040,
+	STS_PAUSE_PRI = 0x00000080,
+	STS_SPEED_MASK = 0x00000038,
+	STS_SPEED_100Mb = 0x00000000,
+	STS_SPEED_1Gb = 0x00000008,
+	STS_SPEED_10Gb = 0x00000010,
+	STS_LINK_TYPE_MASK = 0x00000007,
+	STS_LINK_TYPE_XFI = 0x00000001,
+	STS_LINK_TYPE_XAUI = 0x00000002,
+	STS_LINK_TYPE_XFI_BP = 0x00000003,
+	STS_LINK_TYPE_XAUI_BP = 0x00000004,
+	STS_LINK_TYPE_10GBASET = 0x00000005,
+};
+
+/* link_config bit definitions */
+enum {
+	CFG_JUMBO_FRAME_SIZE = 0x00010000,
+	CFG_PAUSE_MASK = 0x00000060,
+	CFG_PAUSE_STD = 0x00000020,
+	CFG_PAUSE_PRI = 0x00000040,
+	CFG_DCBX = 0x00000010,
+	CFG_LOOPBACK_MASK = 0x00000007,
+	CFG_LOOPBACK_PCS = 0x00000002,
+	CFG_LOOPBACK_HSS = 0x00000004,
+	CFG_LOOPBACK_EXT = 0x00000006,
+	CFG_DEFAULT_MAX_FRAME_SIZE = 0x00002580,
 };
 
 /*
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 9d922e2..a500786 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -271,7 +271,8 @@ static int ql_get_settings(struct net_device *ndev,
 	ecmd->advertising = ADVERTISED_10000baseT_Full;
 	ecmd->autoneg = AUTONEG_ENABLE;
 	ecmd->transceiver = XCVR_EXTERNAL;
-	if ((qdev->link_status & LINK_TYPE_MASK) == LINK_TYPE_10GBASET) {
+	if ((qdev->link_status & STS_LINK_TYPE_MASK) ==
+				STS_LINK_TYPE_10GBASET) {
 		ecmd->supported |= (SUPPORTED_TP | SUPPORTED_Autoneg);
 		ecmd->advertising |= (ADVERTISED_TP | ADVERTISED_Autoneg);
 		ecmd->port = PORT_TP;
-- 
1.6.0.2

