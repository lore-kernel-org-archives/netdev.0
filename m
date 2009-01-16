From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] typhoon: replace users of __constant_{endian}
Date: Thu, 15 Jan 2009 16:41:28 -0800
Message-ID: <1232066488.11986.5.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:15594 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756543AbZAPAla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 19:41:30 -0500
Received: by wf-out-1314.google.com with SMTP id 27so1570940wfd.4
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2009 16:41:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The base versions handle constant folding just fine, use them
directly.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
All the byteorder patches have landed as of 2.6.29-rc1, please apply.

 drivers/net/typhoon.c |    2 +-
 drivers/net/typhoon.h |  234 ++++++++++++++++++++++++------------------------
 2 files changed, 118 insertions(+), 118 deletions(-)

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 3af9a95..d1c9bc9 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1944,7 +1944,7 @@ typhoon_start_runtime(struct typhoon *tp)
 		goto error_out;
 
 	INIT_COMMAND_NO_RESPONSE(&xp_cmd, TYPHOON_CMD_VLAN_TYPE_WRITE);
-	xp_cmd.parm1 = __constant_cpu_to_le16(ETH_P_8021Q);
+	xp_cmd.parm1 = cpu_to_le16(ETH_P_8021Q);
 	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
 	if(err < 0)
 		goto error_out;
diff --git a/drivers/net/typhoon.h b/drivers/net/typhoon.h
index dd7022c..673fd51 100644
--- a/drivers/net/typhoon.h
+++ b/drivers/net/typhoon.h
@@ -174,18 +174,18 @@ struct tx_desc {
 		u64 tx_addr;	/* opaque for hardware, for TX_DESC */
 	};
 	__le32 processFlags;
-#define TYPHOON_TX_PF_NO_CRC		__constant_cpu_to_le32(0x00000001)
-#define TYPHOON_TX_PF_IP_CHKSUM		__constant_cpu_to_le32(0x00000002)
-#define TYPHOON_TX_PF_TCP_CHKSUM	__constant_cpu_to_le32(0x00000004)
-#define TYPHOON_TX_PF_TCP_SEGMENT	__constant_cpu_to_le32(0x00000008)
-#define TYPHOON_TX_PF_INSERT_VLAN	__constant_cpu_to_le32(0x00000010)
-#define TYPHOON_TX_PF_IPSEC		__constant_cpu_to_le32(0x00000020)
-#define TYPHOON_TX_PF_VLAN_PRIORITY	__constant_cpu_to_le32(0x00000040)
-#define TYPHOON_TX_PF_UDP_CHKSUM	__constant_cpu_to_le32(0x00000080)
-#define TYPHOON_TX_PF_PAD_FRAME		__constant_cpu_to_le32(0x00000100)
-#define TYPHOON_TX_PF_RESERVED		__constant_cpu_to_le32(0x00000e00)
-#define TYPHOON_TX_PF_VLAN_MASK		__constant_cpu_to_le32(0x0ffff000)
-#define TYPHOON_TX_PF_INTERNAL		__constant_cpu_to_le32(0xf0000000)
+#define TYPHOON_TX_PF_NO_CRC		cpu_to_le32(0x00000001)
+#define TYPHOON_TX_PF_IP_CHKSUM		cpu_to_le32(0x00000002)
+#define TYPHOON_TX_PF_TCP_CHKSUM	cpu_to_le32(0x00000004)
+#define TYPHOON_TX_PF_TCP_SEGMENT	cpu_to_le32(0x00000008)
+#define TYPHOON_TX_PF_INSERT_VLAN	cpu_to_le32(0x00000010)
+#define TYPHOON_TX_PF_IPSEC		cpu_to_le32(0x00000020)
+#define TYPHOON_TX_PF_VLAN_PRIORITY	cpu_to_le32(0x00000040)
+#define TYPHOON_TX_PF_UDP_CHKSUM	cpu_to_le32(0x00000080)
+#define TYPHOON_TX_PF_PAD_FRAME		cpu_to_le32(0x00000100)
+#define TYPHOON_TX_PF_RESERVED		cpu_to_le32(0x00000e00)
+#define TYPHOON_TX_PF_VLAN_MASK		cpu_to_le32(0x0ffff000)
+#define TYPHOON_TX_PF_INTERNAL		cpu_to_le32(0xf0000000)
 #define TYPHOON_TX_PF_VLAN_TAG_SHIFT	12
 } __attribute__ ((packed));
 
@@ -203,8 +203,8 @@ struct tcpopt_desc {
 	u8  flags;
 	u8  numDesc;
 	__le16 mss_flags;
-#define TYPHOON_TSO_FIRST		__constant_cpu_to_le16(0x1000)
-#define TYPHOON_TSO_LAST		__constant_cpu_to_le16(0x2000)
+#define TYPHOON_TSO_FIRST		cpu_to_le16(0x1000)
+#define TYPHOON_TSO_LAST		cpu_to_le16(0x2000)
 	__le32 respAddrLo;
 	__le32 bytesTx;
 	__le32 status;
@@ -222,8 +222,8 @@ struct ipsec_desc {
 	u8  flags;
 	u8  numDesc;
 	__le16 ipsecFlags;
-#define TYPHOON_IPSEC_GEN_IV	__constant_cpu_to_le16(0x0000)
-#define TYPHOON_IPSEC_USE_IV	__constant_cpu_to_le16(0x0001)
+#define TYPHOON_IPSEC_GEN_IV	cpu_to_le16(0x0000)
+#define TYPHOON_IPSEC_USE_IV	cpu_to_le16(0x0001)
 	__le32 sa1;
 	__le32 sa2;
 	__le32 reserved;
@@ -248,41 +248,41 @@ struct rx_desc {
 	u32 addr;	/* opaque, comes from virtAddr */
 	u32 addrHi;	/* opaque, comes from virtAddrHi */
 	__le32 rxStatus;
-#define TYPHOON_RX_ERR_INTERNAL		__constant_cpu_to_le32(0x00000000)
-#define TYPHOON_RX_ERR_FIFO_UNDERRUN	__constant_cpu_to_le32(0x00000001)
-#define TYPHOON_RX_ERR_BAD_SSD		__constant_cpu_to_le32(0x00000002)
-#define TYPHOON_RX_ERR_RUNT		__constant_cpu_to_le32(0x00000003)
-#define TYPHOON_RX_ERR_CRC		__constant_cpu_to_le32(0x00000004)
-#define TYPHOON_RX_ERR_OVERSIZE		__constant_cpu_to_le32(0x00000005)
-#define TYPHOON_RX_ERR_ALIGN		__constant_cpu_to_le32(0x00000006)
-#define TYPHOON_RX_ERR_DRIBBLE		__constant_cpu_to_le32(0x00000007)
-#define TYPHOON_RX_PROTO_MASK		__constant_cpu_to_le32(0x00000003)
-#define TYPHOON_RX_PROTO_UNKNOWN	__constant_cpu_to_le32(0x00000000)
-#define TYPHOON_RX_PROTO_IP		__constant_cpu_to_le32(0x00000001)
-#define TYPHOON_RX_PROTO_IPX		__constant_cpu_to_le32(0x00000002)
-#define TYPHOON_RX_VLAN			__constant_cpu_to_le32(0x00000004)
-#define TYPHOON_RX_IP_FRAG		__constant_cpu_to_le32(0x00000008)
-#define TYPHOON_RX_IPSEC		__constant_cpu_to_le32(0x00000010)
-#define TYPHOON_RX_IP_CHK_FAIL		__constant_cpu_to_le32(0x00000020)
-#define TYPHOON_RX_TCP_CHK_FAIL		__constant_cpu_to_le32(0x00000040)
-#define TYPHOON_RX_UDP_CHK_FAIL		__constant_cpu_to_le32(0x00000080)
-#define TYPHOON_RX_IP_CHK_GOOD		__constant_cpu_to_le32(0x00000100)
-#define TYPHOON_RX_TCP_CHK_GOOD		__constant_cpu_to_le32(0x00000200)
-#define TYPHOON_RX_UDP_CHK_GOOD		__constant_cpu_to_le32(0x00000400)
+#define TYPHOON_RX_ERR_INTERNAL		cpu_to_le32(0x00000000)
+#define TYPHOON_RX_ERR_FIFO_UNDERRUN	cpu_to_le32(0x00000001)
+#define TYPHOON_RX_ERR_BAD_SSD		cpu_to_le32(0x00000002)
+#define TYPHOON_RX_ERR_RUNT		cpu_to_le32(0x00000003)
+#define TYPHOON_RX_ERR_CRC		cpu_to_le32(0x00000004)
+#define TYPHOON_RX_ERR_OVERSIZE		cpu_to_le32(0x00000005)
+#define TYPHOON_RX_ERR_ALIGN		cpu_to_le32(0x00000006)
+#define TYPHOON_RX_ERR_DRIBBLE		cpu_to_le32(0x00000007)
+#define TYPHOON_RX_PROTO_MASK		cpu_to_le32(0x00000003)
+#define TYPHOON_RX_PROTO_UNKNOWN	cpu_to_le32(0x00000000)
+#define TYPHOON_RX_PROTO_IP		cpu_to_le32(0x00000001)
+#define TYPHOON_RX_PROTO_IPX		cpu_to_le32(0x00000002)
+#define TYPHOON_RX_VLAN			cpu_to_le32(0x00000004)
+#define TYPHOON_RX_IP_FRAG		cpu_to_le32(0x00000008)
+#define TYPHOON_RX_IPSEC		cpu_to_le32(0x00000010)
+#define TYPHOON_RX_IP_CHK_FAIL		cpu_to_le32(0x00000020)
+#define TYPHOON_RX_TCP_CHK_FAIL		cpu_to_le32(0x00000040)
+#define TYPHOON_RX_UDP_CHK_FAIL		cpu_to_le32(0x00000080)
+#define TYPHOON_RX_IP_CHK_GOOD		cpu_to_le32(0x00000100)
+#define TYPHOON_RX_TCP_CHK_GOOD		cpu_to_le32(0x00000200)
+#define TYPHOON_RX_UDP_CHK_GOOD		cpu_to_le32(0x00000400)
 	__le16 filterResults;
-#define TYPHOON_RX_FILTER_MASK		__constant_cpu_to_le16(0x7fff)
-#define TYPHOON_RX_FILTERED		__constant_cpu_to_le16(0x8000)
+#define TYPHOON_RX_FILTER_MASK		cpu_to_le16(0x7fff)
+#define TYPHOON_RX_FILTERED		cpu_to_le16(0x8000)
 	__le16 ipsecResults;
-#define TYPHOON_RX_OUTER_AH_GOOD	__constant_cpu_to_le16(0x0001)
-#define TYPHOON_RX_OUTER_ESP_GOOD	__constant_cpu_to_le16(0x0002)
-#define TYPHOON_RX_INNER_AH_GOOD	__constant_cpu_to_le16(0x0004)
-#define TYPHOON_RX_INNER_ESP_GOOD	__constant_cpu_to_le16(0x0008)
-#define TYPHOON_RX_OUTER_AH_FAIL	__constant_cpu_to_le16(0x0010)
-#define TYPHOON_RX_OUTER_ESP_FAIL	__constant_cpu_to_le16(0x0020)
-#define TYPHOON_RX_INNER_AH_FAIL	__constant_cpu_to_le16(0x0040)
-#define TYPHOON_RX_INNER_ESP_FAIL	__constant_cpu_to_le16(0x0080)
-#define TYPHOON_RX_UNKNOWN_SA		__constant_cpu_to_le16(0x0100)
-#define TYPHOON_RX_ESP_FORMAT_ERR	__constant_cpu_to_le16(0x0200)
+#define TYPHOON_RX_OUTER_AH_GOOD	cpu_to_le16(0x0001)
+#define TYPHOON_RX_OUTER_ESP_GOOD	cpu_to_le16(0x0002)
+#define TYPHOON_RX_INNER_AH_GOOD	cpu_to_le16(0x0004)
+#define TYPHOON_RX_INNER_ESP_GOOD	cpu_to_le16(0x0008)
+#define TYPHOON_RX_OUTER_AH_FAIL	cpu_to_le16(0x0010)
+#define TYPHOON_RX_OUTER_ESP_FAIL	cpu_to_le16(0x0020)
+#define TYPHOON_RX_INNER_AH_FAIL	cpu_to_le16(0x0040)
+#define TYPHOON_RX_INNER_ESP_FAIL	cpu_to_le16(0x0080)
+#define TYPHOON_RX_UNKNOWN_SA		cpu_to_le16(0x0100)
+#define TYPHOON_RX_ESP_FORMAT_ERR	cpu_to_le16(0x0200)
 	__be32 vlanTag;
 } __attribute__ ((packed));
 
@@ -318,31 +318,31 @@ struct cmd_desc {
 	u8  flags;
 	u8  numDesc;
 	__le16 cmd;
-#define TYPHOON_CMD_TX_ENABLE		__constant_cpu_to_le16(0x0001)
-#define TYPHOON_CMD_TX_DISABLE		__constant_cpu_to_le16(0x0002)
-#define TYPHOON_CMD_RX_ENABLE		__constant_cpu_to_le16(0x0003)
-#define TYPHOON_CMD_RX_DISABLE		__constant_cpu_to_le16(0x0004)
-#define TYPHOON_CMD_SET_RX_FILTER	__constant_cpu_to_le16(0x0005)
-#define TYPHOON_CMD_READ_STATS		__constant_cpu_to_le16(0x0007)
-#define TYPHOON_CMD_XCVR_SELECT		__constant_cpu_to_le16(0x0013)
-#define TYPHOON_CMD_SET_MAX_PKT_SIZE	__constant_cpu_to_le16(0x001a)
-#define TYPHOON_CMD_READ_MEDIA_STATUS	__constant_cpu_to_le16(0x001b)
-#define TYPHOON_CMD_GOTO_SLEEP		__constant_cpu_to_le16(0x0023)
-#define TYPHOON_CMD_SET_MULTICAST_HASH	__constant_cpu_to_le16(0x0025)
-#define TYPHOON_CMD_SET_MAC_ADDRESS	__constant_cpu_to_le16(0x0026)
-#define TYPHOON_CMD_READ_MAC_ADDRESS	__constant_cpu_to_le16(0x0027)
-#define TYPHOON_CMD_VLAN_TYPE_WRITE	__constant_cpu_to_le16(0x002b)
-#define TYPHOON_CMD_CREATE_SA		__constant_cpu_to_le16(0x0034)
-#define TYPHOON_CMD_DELETE_SA		__constant_cpu_to_le16(0x0035)
-#define TYPHOON_CMD_READ_VERSIONS	__constant_cpu_to_le16(0x0043)
-#define TYPHOON_CMD_IRQ_COALESCE_CTRL	__constant_cpu_to_le16(0x0045)
-#define TYPHOON_CMD_ENABLE_WAKE_EVENTS	__constant_cpu_to_le16(0x0049)
-#define TYPHOON_CMD_SET_OFFLOAD_TASKS	__constant_cpu_to_le16(0x004f)
-#define TYPHOON_CMD_HELLO_RESP		__constant_cpu_to_le16(0x0057)
-#define TYPHOON_CMD_HALT		__constant_cpu_to_le16(0x005d)
-#define TYPHOON_CMD_READ_IPSEC_INFO	__constant_cpu_to_le16(0x005e)
-#define TYPHOON_CMD_GET_IPSEC_ENABLE	__constant_cpu_to_le16(0x0067)
-#define TYPHOON_CMD_GET_CMD_LVL		__constant_cpu_to_le16(0x0069)
+#define TYPHOON_CMD_TX_ENABLE		cpu_to_le16(0x0001)
+#define TYPHOON_CMD_TX_DISABLE		cpu_to_le16(0x0002)
+#define TYPHOON_CMD_RX_ENABLE		cpu_to_le16(0x0003)
+#define TYPHOON_CMD_RX_DISABLE		cpu_to_le16(0x0004)
+#define TYPHOON_CMD_SET_RX_FILTER	cpu_to_le16(0x0005)
+#define TYPHOON_CMD_READ_STATS		cpu_to_le16(0x0007)
+#define TYPHOON_CMD_XCVR_SELECT		cpu_to_le16(0x0013)
+#define TYPHOON_CMD_SET_MAX_PKT_SIZE	cpu_to_le16(0x001a)
+#define TYPHOON_CMD_READ_MEDIA_STATUS	cpu_to_le16(0x001b)
+#define TYPHOON_CMD_GOTO_SLEEP		cpu_to_le16(0x0023)
+#define TYPHOON_CMD_SET_MULTICAST_HASH	cpu_to_le16(0x0025)
+#define TYPHOON_CMD_SET_MAC_ADDRESS	cpu_to_le16(0x0026)
+#define TYPHOON_CMD_READ_MAC_ADDRESS	cpu_to_le16(0x0027)
+#define TYPHOON_CMD_VLAN_TYPE_WRITE	cpu_to_le16(0x002b)
+#define TYPHOON_CMD_CREATE_SA		cpu_to_le16(0x0034)
+#define TYPHOON_CMD_DELETE_SA		cpu_to_le16(0x0035)
+#define TYPHOON_CMD_READ_VERSIONS	cpu_to_le16(0x0043)
+#define TYPHOON_CMD_IRQ_COALESCE_CTRL	cpu_to_le16(0x0045)
+#define TYPHOON_CMD_ENABLE_WAKE_EVENTS	cpu_to_le16(0x0049)
+#define TYPHOON_CMD_SET_OFFLOAD_TASKS	cpu_to_le16(0x004f)
+#define TYPHOON_CMD_HELLO_RESP		cpu_to_le16(0x0057)
+#define TYPHOON_CMD_HALT		cpu_to_le16(0x005d)
+#define TYPHOON_CMD_READ_IPSEC_INFO	cpu_to_le16(0x005e)
+#define TYPHOON_CMD_GET_IPSEC_ENABLE	cpu_to_le16(0x0067)
+#define TYPHOON_CMD_GET_CMD_LVL		cpu_to_le16(0x0069)
 	u16 seqNo;
 	__le16 parm1;
 	__le32 parm2;
@@ -380,11 +380,11 @@ struct resp_desc {
 
 /* TYPHOON_CMD_SET_RX_FILTER filter bits (cmd.parm1)
  */
-#define TYPHOON_RX_FILTER_DIRECTED	__constant_cpu_to_le16(0x0001)
-#define TYPHOON_RX_FILTER_ALL_MCAST	__constant_cpu_to_le16(0x0002)
-#define TYPHOON_RX_FILTER_BROADCAST	__constant_cpu_to_le16(0x0004)
-#define TYPHOON_RX_FILTER_PROMISCOUS	__constant_cpu_to_le16(0x0008)
-#define TYPHOON_RX_FILTER_MCAST_HASH	__constant_cpu_to_le16(0x0010)
+#define TYPHOON_RX_FILTER_DIRECTED	cpu_to_le16(0x0001)
+#define TYPHOON_RX_FILTER_ALL_MCAST	cpu_to_le16(0x0002)
+#define TYPHOON_RX_FILTER_BROADCAST	cpu_to_le16(0x0004)
+#define TYPHOON_RX_FILTER_PROMISCOUS	cpu_to_le16(0x0008)
+#define TYPHOON_RX_FILTER_MCAST_HASH	cpu_to_le16(0x0010)
 
 /* TYPHOON_CMD_READ_STATS response format
  */
@@ -416,40 +416,40 @@ struct stats_resp {
 	__le32 rxOverflow;
 	__le32 rxFiltered;
 	__le32 linkStatus;
-#define TYPHOON_LINK_STAT_MASK		__constant_cpu_to_le32(0x00000001)
-#define TYPHOON_LINK_GOOD		__constant_cpu_to_le32(0x00000001)
-#define TYPHOON_LINK_BAD		__constant_cpu_to_le32(0x00000000)
-#define TYPHOON_LINK_SPEED_MASK		__constant_cpu_to_le32(0x00000002)
-#define TYPHOON_LINK_100MBPS		__constant_cpu_to_le32(0x00000002)
-#define TYPHOON_LINK_10MBPS		__constant_cpu_to_le32(0x00000000)
-#define TYPHOON_LINK_DUPLEX_MASK	__constant_cpu_to_le32(0x00000004)
-#define TYPHOON_LINK_FULL_DUPLEX	__constant_cpu_to_le32(0x00000004)
-#define TYPHOON_LINK_HALF_DUPLEX	__constant_cpu_to_le32(0x00000000)
+#define TYPHOON_LINK_STAT_MASK		cpu_to_le32(0x00000001)
+#define TYPHOON_LINK_GOOD		cpu_to_le32(0x00000001)
+#define TYPHOON_LINK_BAD		cpu_to_le32(0x00000000)
+#define TYPHOON_LINK_SPEED_MASK		cpu_to_le32(0x00000002)
+#define TYPHOON_LINK_100MBPS		cpu_to_le32(0x00000002)
+#define TYPHOON_LINK_10MBPS		cpu_to_le32(0x00000000)
+#define TYPHOON_LINK_DUPLEX_MASK	cpu_to_le32(0x00000004)
+#define TYPHOON_LINK_FULL_DUPLEX	cpu_to_le32(0x00000004)
+#define TYPHOON_LINK_HALF_DUPLEX	cpu_to_le32(0x00000000)
 	__le32 unused2;
 	__le32 unused3;
 } __attribute__ ((packed));
 
 /* TYPHOON_CMD_XCVR_SELECT xcvr values (resp.parm1)
  */
-#define TYPHOON_XCVR_10HALF	__constant_cpu_to_le16(0x0000)
-#define TYPHOON_XCVR_10FULL	__constant_cpu_to_le16(0x0001)
-#define TYPHOON_XCVR_100HALF	__constant_cpu_to_le16(0x0002)
-#define TYPHOON_XCVR_100FULL	__constant_cpu_to_le16(0x0003)
-#define TYPHOON_XCVR_AUTONEG	__constant_cpu_to_le16(0x0004)
+#define TYPHOON_XCVR_10HALF	cpu_to_le16(0x0000)
+#define TYPHOON_XCVR_10FULL	cpu_to_le16(0x0001)
+#define TYPHOON_XCVR_100HALF	cpu_to_le16(0x0002)
+#define TYPHOON_XCVR_100FULL	cpu_to_le16(0x0003)
+#define TYPHOON_XCVR_AUTONEG	cpu_to_le16(0x0004)
 
 /* TYPHOON_CMD_READ_MEDIA_STATUS (resp.parm1)
  */
-#define TYPHOON_MEDIA_STAT_CRC_STRIP_DISABLE	__constant_cpu_to_le16(0x0004)
-#define TYPHOON_MEDIA_STAT_COLLISION_DETECT	__constant_cpu_to_le16(0x0010)
-#define TYPHOON_MEDIA_STAT_CARRIER_SENSE	__constant_cpu_to_le16(0x0020)
-#define TYPHOON_MEDIA_STAT_POLARITY_REV		__constant_cpu_to_le16(0x0400)
-#define TYPHOON_MEDIA_STAT_NO_LINK		__constant_cpu_to_le16(0x0800)
+#define TYPHOON_MEDIA_STAT_CRC_STRIP_DISABLE	cpu_to_le16(0x0004)
+#define TYPHOON_MEDIA_STAT_COLLISION_DETECT	cpu_to_le16(0x0010)
+#define TYPHOON_MEDIA_STAT_CARRIER_SENSE	cpu_to_le16(0x0020)
+#define TYPHOON_MEDIA_STAT_POLARITY_REV		cpu_to_le16(0x0400)
+#define TYPHOON_MEDIA_STAT_NO_LINK		cpu_to_le16(0x0800)
 
 /* TYPHOON_CMD_SET_MULTICAST_HASH enable values (cmd.parm1)
  */
-#define TYPHOON_MCAST_HASH_DISABLE	__constant_cpu_to_le16(0x0000)
-#define TYPHOON_MCAST_HASH_ENABLE	__constant_cpu_to_le16(0x0001)
-#define TYPHOON_MCAST_HASH_SET		__constant_cpu_to_le16(0x0002)
+#define TYPHOON_MCAST_HASH_DISABLE	cpu_to_le16(0x0000)
+#define TYPHOON_MCAST_HASH_ENABLE	cpu_to_le16(0x0001)
+#define TYPHOON_MCAST_HASH_SET		cpu_to_le16(0x0002)
 
 /* TYPHOON_CMD_CREATE_SA descriptor and settings
  */
@@ -459,9 +459,9 @@ struct sa_descriptor {
 	u16 cmd;
 	u16 seqNo;
 	u16 mode;
-#define TYPHOON_SA_MODE_NULL		__constant_cpu_to_le16(0x0000)
-#define TYPHOON_SA_MODE_AH		__constant_cpu_to_le16(0x0001)
-#define TYPHOON_SA_MODE_ESP		__constant_cpu_to_le16(0x0002)
+#define TYPHOON_SA_MODE_NULL		cpu_to_le16(0x0000)
+#define TYPHOON_SA_MODE_AH		cpu_to_le16(0x0001)
+#define TYPHOON_SA_MODE_ESP		cpu_to_le16(0x0002)
 	u8  hashFlags;
 #define TYPHOON_SA_HASH_ENABLE		0x01
 #define TYPHOON_SA_HASH_SHA1		0x02
@@ -493,22 +493,22 @@ struct sa_descriptor {
 /* TYPHOON_CMD_SET_OFFLOAD_TASKS bits (cmd.parm2 (Tx) & cmd.parm3 (Rx))
  * This is all for IPv4.
  */
-#define TYPHOON_OFFLOAD_TCP_CHKSUM	__constant_cpu_to_le32(0x00000002)
-#define TYPHOON_OFFLOAD_UDP_CHKSUM	__constant_cpu_to_le32(0x00000004)
-#define TYPHOON_OFFLOAD_IP_CHKSUM	__constant_cpu_to_le32(0x00000008)
-#define TYPHOON_OFFLOAD_IPSEC		__constant_cpu_to_le32(0x00000010)
-#define TYPHOON_OFFLOAD_BCAST_THROTTLE	__constant_cpu_to_le32(0x00000020)
-#define TYPHOON_OFFLOAD_DHCP_PREVENT	__constant_cpu_to_le32(0x00000040)
-#define TYPHOON_OFFLOAD_VLAN		__constant_cpu_to_le32(0x00000080)
-#define TYPHOON_OFFLOAD_FILTERING	__constant_cpu_to_le32(0x00000100)
-#define TYPHOON_OFFLOAD_TCP_SEGMENT	__constant_cpu_to_le32(0x00000200)
+#define TYPHOON_OFFLOAD_TCP_CHKSUM	cpu_to_le32(0x00000002)
+#define TYPHOON_OFFLOAD_UDP_CHKSUM	cpu_to_le32(0x00000004)
+#define TYPHOON_OFFLOAD_IP_CHKSUM	cpu_to_le32(0x00000008)
+#define TYPHOON_OFFLOAD_IPSEC		cpu_to_le32(0x00000010)
+#define TYPHOON_OFFLOAD_BCAST_THROTTLE	cpu_to_le32(0x00000020)
+#define TYPHOON_OFFLOAD_DHCP_PREVENT	cpu_to_le32(0x00000040)
+#define TYPHOON_OFFLOAD_VLAN		cpu_to_le32(0x00000080)
+#define TYPHOON_OFFLOAD_FILTERING	cpu_to_le32(0x00000100)
+#define TYPHOON_OFFLOAD_TCP_SEGMENT	cpu_to_le32(0x00000200)
 
 /* TYPHOON_CMD_ENABLE_WAKE_EVENTS bits (cmd.parm1)
  */
-#define TYPHOON_WAKE_MAGIC_PKT		__constant_cpu_to_le16(0x01)
-#define TYPHOON_WAKE_LINK_EVENT		__constant_cpu_to_le16(0x02)
-#define TYPHOON_WAKE_ICMP_ECHO		__constant_cpu_to_le16(0x04)
-#define TYPHOON_WAKE_ARP		__constant_cpu_to_le16(0x08)
+#define TYPHOON_WAKE_MAGIC_PKT		cpu_to_le16(0x01)
+#define TYPHOON_WAKE_LINK_EVENT		cpu_to_le16(0x02)
+#define TYPHOON_WAKE_ICMP_ECHO		cpu_to_le16(0x04)
+#define TYPHOON_WAKE_ARP		cpu_to_le16(0x08)
 
 /* These are used to load the firmware image on the NIC
  */
-- 
1.6.1.249.g455e5



