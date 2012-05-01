From: "Linus Walleij" <linus.walleij@linaro.org>
Subject: [PATCH 12/13 v4] usb/net: rndis: fixup a few name prefixes
Date: Tue,  1 May 2012 20:23:43 +0200
Message-ID: <1335896623-13661-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.df.lth.se ([194.47.250.12]:60801 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758182Ab2EASXr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 14:23:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This switches a horde of NDIS_*-prefixed variables to the RNDIS_*
prefix. Most of them aren't used much and causes no changes.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/usb/gadget/rndis.c |    4 +-
 include/linux/rndis.h      |  107 +++++++++++++++++++++----------------------
 2 files changed, 54 insertions(+), 57 deletions(-)

diff --git a/drivers/usb/gadget/rndis.c b/drivers/usb/gadget/rndis.c
index d747e89..b35babe 100644
--- a/drivers/usb/gadget/rndis.c
+++ b/drivers/usb/gadget/rndis.c
@@ -346,8 +346,8 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 	case RNDIS_OID_GEN_MAC_OPTIONS:		/* from WinME */
 		pr_debug("%s: RNDIS_OID_GEN_MAC_OPTIONS\n", __func__);
 		*outbuf = cpu_to_le32(
-			  NDIS_MAC_OPTION_RECEIVE_SERIALIZED
-			| NDIS_MAC_OPTION_FULL_DUPLEX);
+			  RNDIS_MAC_OPTION_RECEIVE_SERIALIZED
+			| RNDIS_MAC_OPTION_FULL_DUPLEX);
 		retval = 0;
 		break;
 
diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index 18a27a4..3f2ba8f 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -3,12 +3,21 @@
  * definitions of the magic numbers used by this protocol
  */
 
-#define RNDIS_MSG_COMPLETION	0x80000000
+/* Remote NDIS Versions */
+#define RNDIS_MAJOR_VERSION		0x00000001
+#define RNDIS_MINOR_VERSION		0x00000000
+
+/* Device Flags */
+#define RNDIS_DF_CONNECTIONLESS		0x00000001U
+#define RNDIS_DF_CONNECTION_ORIENTED	0x00000002U
+#define RNDIS_DF_RAW_DATA		0x00000004U
 
-/* codes for "msg_type" field of rndis messages;
+/*
+ * Codes for "msg_type" field of rndis messages;
  * only the data channel uses packet messages (maybe batched);
  * everything else goes on the control channel.
  */
+#define RNDIS_MSG_COMPLETION	0x80000000
 #define RNDIS_MSG_PACKET	0x00000001	/* 1-N packets */
 #define RNDIS_MSG_INIT		0x00000002
 #define RNDIS_MSG_INIT_C	(RNDIS_MSG_INIT|RNDIS_MSG_COMPLETION)
@@ -151,58 +160,41 @@
 #define RNDIS_PACKET_TYPE_FUNCTIONAL		0x00004000
 #define RNDIS_PACKET_TYPE_MAC_FRAME		0x00008000
 
-/* NDIS_PNP_CAPABILITIES.Flags constants */
-#define NDIS_DEVICE_WAKE_UP_ENABLE                0x00000001
-#define NDIS_DEVICE_WAKE_ON_PATTERN_MATCH_ENABLE  0x00000002
-#define NDIS_DEVICE_WAKE_ON_MAGIC_PACKET_ENABLE   0x00000004
-
-/* IEEE 802.3 (Ethernet) OIDs */
-#define NDIS_802_3_MAC_OPTION_PRIORITY    0x00000001
-
 /* RNDIS_OID_GEN_MINIPORT_INFO constants */
-#define NDIS_MINIPORT_BUS_MASTER                      0x00000001
-#define NDIS_MINIPORT_WDM_DRIVER                      0x00000002
-#define NDIS_MINIPORT_SG_LIST                         0x00000004
-#define NDIS_MINIPORT_SUPPORTS_MEDIA_QUERY            0x00000008
-#define NDIS_MINIPORT_INDICATES_PACKETS               0x00000010
-#define NDIS_MINIPORT_IGNORE_PACKET_QUEUE             0x00000020
-#define NDIS_MINIPORT_IGNORE_REQUEST_QUEUE            0x00000040
-#define NDIS_MINIPORT_IGNORE_TOKEN_RING_ERRORS        0x00000080
-#define NDIS_MINIPORT_INTERMEDIATE_DRIVER             0x00000100
-#define NDIS_MINIPORT_IS_NDIS_5                       0x00000200
-#define NDIS_MINIPORT_IS_CO                           0x00000400
-#define NDIS_MINIPORT_DESERIALIZE                     0x00000800
-#define NDIS_MINIPORT_REQUIRES_MEDIA_POLLING          0x00001000
-#define NDIS_MINIPORT_SUPPORTS_MEDIA_SENSE            0x00002000
-#define NDIS_MINIPORT_NETBOOT_CARD                    0x00004000
-#define NDIS_MINIPORT_PM_SUPPORTED                    0x00008000
-#define NDIS_MINIPORT_SUPPORTS_MAC_ADDRESS_OVERWRITE  0x00010000
-#define NDIS_MINIPORT_USES_SAFE_BUFFER_APIS           0x00020000
-#define NDIS_MINIPORT_HIDDEN                          0x00040000
-#define NDIS_MINIPORT_SWENUM                          0x00080000
-#define NDIS_MINIPORT_SURPRISE_REMOVE_OK              0x00100000
-#define NDIS_MINIPORT_NO_HALT_ON_SUSPEND              0x00200000
-#define NDIS_MINIPORT_HARDWARE_DEVICE                 0x00400000
-#define NDIS_MINIPORT_SUPPORTS_CANCEL_SEND_PACKETS    0x00800000
-#define NDIS_MINIPORT_64BITS_DMA                      0x01000000
-
-#define NDIS_MAC_OPTION_COPY_LOOKAHEAD_DATA     0x00000001
-#define NDIS_MAC_OPTION_RECEIVE_SERIALIZED      0x00000002
-#define NDIS_MAC_OPTION_TRANSFERS_NOT_PEND      0x00000004
-#define NDIS_MAC_OPTION_NO_LOOPBACK             0x00000008
-#define NDIS_MAC_OPTION_FULL_DUPLEX             0x00000010
-#define NDIS_MAC_OPTION_EOTX_INDICATION         0x00000020
-#define NDIS_MAC_OPTION_8021P_PRIORITY          0x00000040
-#define NDIS_MAC_OPTION_RESERVED                0x80000000
-
-/* Remote NDIS Versions */
-#define RNDIS_MAJOR_VERSION		0x00000001
-#define RNDIS_MINOR_VERSION		0x00000000
-
-/* Device Flags */
-#define RNDIS_DF_CONNECTIONLESS		0x00000001U
-#define RNDIS_DF_CONNECTION_ORIENTED	0x00000002U
-#define RNDIS_DF_RAW_DATA		0x00000004U
+#define RNDIS_MINIPORT_BUS_MASTER			0x00000001
+#define RNDIS_MINIPORT_WDM_DRIVER			0x00000002
+#define RNDIS_MINIPORT_SG_LIST				0x00000004
+#define RNDIS_MINIPORT_SUPPORTS_MEDIA_QUERY		0x00000008
+#define RNDIS_MINIPORT_INDICATES_PACKETS		0x00000010
+#define RNDIS_MINIPORT_IGNORE_PACKET_QUEUE		0x00000020
+#define RNDIS_MINIPORT_IGNORE_REQUEST_QUEUE		0x00000040
+#define RNDIS_MINIPORT_IGNORE_TOKEN_RING_ERRORS		0x00000080
+#define RNDIS_MINIPORT_INTERMEDIATE_DRIVER		0x00000100
+#define RNDIS_MINIPORT_IS_NDIS_5			0x00000200
+#define RNDIS_MINIPORT_IS_CO				0x00000400
+#define RNDIS_MINIPORT_DESERIALIZE			0x00000800
+#define RNDIS_MINIPORT_REQUIRES_MEDIA_POLLING		0x00001000
+#define RNDIS_MINIPORT_SUPPORTS_MEDIA_SENSE		0x00002000
+#define RNDIS_MINIPORT_NETBOOT_CARD			0x00004000
+#define RNDIS_MINIPORT_PM_SUPPORTED			0x00008000
+#define RNDIS_MINIPORT_SUPPORTS_MAC_ADDRESS_OVERWRITE	0x00010000
+#define RNDIS_MINIPORT_USES_SAFE_BUFFER_APIS		0x00020000
+#define RNDIS_MINIPORT_HIDDEN				0x00040000
+#define RNDIS_MINIPORT_SWENUM				0x00080000
+#define RNDIS_MINIPORT_SURPRISE_REMOVE_OK		0x00100000
+#define RNDIS_MINIPORT_NO_HALT_ON_SUSPEND		0x00200000
+#define RNDIS_MINIPORT_HARDWARE_DEVICE			0x00400000
+#define RNDIS_MINIPORT_SUPPORTS_CANCEL_SEND_PACKETS	0x00800000
+#define RNDIS_MINIPORT_64BITS_DMA			0x01000000
+
+#define RNDIS_MAC_OPTION_COPY_LOOKAHEAD_DATA		0x00000001
+#define RNDIS_MAC_OPTION_RECEIVE_SERIALIZED		0x00000002
+#define RNDIS_MAC_OPTION_TRANSFERS_NOT_PEND		0x00000004
+#define RNDIS_MAC_OPTION_NO_LOOPBACK			0x00000008
+#define RNDIS_MAC_OPTION_FULL_DUPLEX			0x00000010
+#define RNDIS_MAC_OPTION_EOTX_INDICATION		0x00000020
+#define RNDIS_MAC_OPTION_8021P_PRIORITY			0x00000040
+#define RNDIS_MAC_OPTION_RESERVED			0x80000000
 
 /* Object Identifiers used by NdisRequest Query/Set Information */
 /* General (Required) Objects */
@@ -237,7 +229,7 @@
 #define RNDIS_OID_GEN_VLAN_ID			0x0001021C
 
 /* Optional OIDs */
-#define OID_GEN_MEDIA_CAPABILITIES		0x00010201
+#define RNDIS_OID_GEN_MEDIA_CAPABILITIES	0x00010201
 
 /* Required statistics OIDs */
 #define RNDIS_OID_GEN_XMIT_OK			0x00020101
@@ -327,7 +319,7 @@
 #define RNDIS_OID_802_3_MAXIMUM_LIST_SIZE	0x01010104
 #define RNDIS_OID_802_3_MAC_OPTIONS		0x01010105
 
-#define NDIS_802_3_MAC_OPTION_PRIORITY		0x00000001
+#define RNDIS_802_3_MAC_OPTION_PRIORITY		0x00000001
 
 #define RNDIS_OID_802_3_RCV_ERROR_ALIGNMENT	0x01020101
 #define RNDIS_OID_802_3_XMIT_ONE_COLLISION	0x01020102
@@ -376,6 +368,11 @@
 #define RNDIS_OID_PNP_REMOVE_WAKE_UP_PATTERN	0xFD010104
 #define RNDIS_OID_PNP_ENABLE_WAKE_UP		0xFD010106
 
+/* RNDIS_PNP_CAPABILITIES.Flags constants */
+#define RNDIS_DEVICE_WAKE_UP_ENABLE			0x00000001
+#define RNDIS_DEVICE_WAKE_ON_PATTERN_MATCH_ENABLE	0x00000002
+#define RNDIS_DEVICE_WAKE_ON_MAGIC_PACKET_ENABLE	0x00000004
+
 #define REMOTE_CONDIS_MP_CREATE_VC_MSG		0x00008001
 #define REMOTE_CONDIS_MP_DELETE_VC_MSG		0x00008002
 #define REMOTE_CONDIS_MP_ACTIVATE_VC_MSG	0x00008005
-- 
1.7.7.6
