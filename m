From: "Linus Walleij" <linus.walleij@linaro.org>
Subject: [PATCH 03/14 v2] usb/net: rndis: remove duplicate definitions
Date: Wed, 25 Apr 2012 17:30:17 +0200
Message-ID: <1335367817-4289-1-git-send-email-linus.walleij@linaro.org>
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
Received: from mail.df.lth.se ([194.47.250.12]:37301 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658Ab2DYPaV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 11:30:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This deletes the immediate duplicated defines in the <linux/rndis.h>
file that yields a lot of compilation warnings.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 include/linux/rndis.h |   62 +++---------------------------------------------
 1 files changed, 4 insertions(+), 58 deletions(-)

diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index 453e170..430d72e 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -82,7 +82,6 @@
 #define OID_GEN_MEDIA_SUPPORTED           0x00010103
 #define OID_GEN_MEDIA_IN_USE              0x00010104
 #define OID_GEN_MAXIMUM_LOOKAHEAD         0x00010105
-#define OID_GEN_MAXIMUM_FRAME_SIZE        0x00010106
 #define OID_GEN_LINK_SPEED                0x00010107
 #define OID_GEN_TRANSMIT_BUFFER_SPACE     0x00010108
 #define OID_GEN_RECEIVE_BUFFER_SPACE      0x00010109
@@ -90,7 +89,6 @@
 #define OID_GEN_RECEIVE_BLOCK_SIZE        0x0001010B
 #define OID_GEN_VENDOR_ID                 0x0001010C
 #define OID_GEN_VENDOR_DESCRIPTION        0x0001010D
-#define OID_GEN_CURRENT_PACKET_FILTER     0x0001010E
 #define OID_GEN_CURRENT_LOOKAHEAD         0x0001010F
 #define OID_GEN_DRIVER_VERSION            0x00010110
 #define OID_GEN_MAXIMUM_TOTAL_SIZE        0x00010111
@@ -108,7 +106,6 @@
 
 /* Optional OIDs */
 #define OID_GEN_MEDIA_CAPABILITIES        0x00010201
-#define OID_GEN_PHYSICAL_MEDIUM           0x00010202
 
 /* Required statistics OIDs */
 #define OID_GEN_XMIT_OK                   0x00020101
@@ -146,7 +143,6 @@
 /* IEEE 802.3 (Ethernet) OIDs */
 #define NDIS_802_3_MAC_OPTION_PRIORITY    0x00000001
 
-#define OID_802_3_PERMANENT_ADDRESS       0x01010101
 #define OID_802_3_CURRENT_ADDRESS         0x01010102
 #define OID_802_3_MULTICAST_LIST          0x01010103
 #define OID_802_3_MAXIMUM_LIST_SIZE       0x01010104
@@ -232,16 +228,9 @@
 /* From drivers/usb/gadget/rndis.h */
 
 /* Remote NDIS Versions */
-#define RNDIS_MAJOR_VERSION		1
-#define RNDIS_MINOR_VERSION		0
-
-/* Status Values */
-#define RNDIS_STATUS_SUCCESS		0x00000000U	/* Success           */
-#define RNDIS_STATUS_FAILURE		0xC0000001U	/* Unspecified error */
-#define RNDIS_STATUS_INVALID_DATA	0xC0010015U	/* Invalid data      */
-#define RNDIS_STATUS_NOT_SUPPORTED	0xC00000BBU	/* Unsupported request */
-#define RNDIS_STATUS_MEDIA_CONNECT	0x4001000BU	/* Device connected  */
-#define RNDIS_STATUS_MEDIA_DISCONNECT	0x4001000CU	/* Device disconnected */
+#define RNDIS_MAJOR_VERSION		0x00000001
+#define RNDIS_MINOR_VERSION		0x00000000
+
 /* For all not specified status messages:
  * RNDIS_STATUS_Xxx -> NDIS_STATUS_Xxx
  */
@@ -266,8 +255,7 @@
 /* Device Flags */
 #define RNDIS_DF_CONNECTIONLESS		0x00000001U
 #define RNDIS_DF_CONNECTION_ORIENTED	0x00000002U
-
-#define RNDIS_MEDIUM_802_3		0x00000000U
+#define RNDIS_DF_RAW_DATA		0x00000004U
 
 /* from drivers/net/sk98lin/h/skgepnmi.h */
 #define OID_PNP_CAPABILITIES			0xFD010100
@@ -281,7 +269,6 @@
 
 /*  Status codes */
 
-
 #ifndef STATUS_SUCCESS
 #define STATUS_SUCCESS				(0x00000000L)
 #endif
@@ -306,7 +293,6 @@
 #define STATUS_NOT_SUPPORTED			(0xC00000BBL)
 #endif
 
-#define RNDIS_STATUS_SUCCESS			(STATUS_SUCCESS)
 #define RNDIS_STATUS_PENDING			(STATUS_PENDING)
 #define RNDIS_STATUS_NOT_RECOGNIZED		(0x00010001L)
 #define RNDIS_STATUS_NOT_COPIED			(0x00010002L)
@@ -321,14 +307,11 @@
 #define RNDIS_STATUS_WAN_LINE_UP		(0x40010008L)
 #define RNDIS_STATUS_WAN_LINE_DOWN		(0x40010009L)
 #define RNDIS_STATUS_WAN_FRAGMENT		(0x4001000AL)
-#define RNDIS_STATUS_MEDIA_CONNECT		(0x4001000BL)
-#define RNDIS_STATUS_MEDIA_DISCONNECT		(0x4001000CL)
 #define RNDIS_STATUS_HARDWARE_LINE_UP		(0x4001000DL)
 #define RNDIS_STATUS_HARDWARE_LINE_DOWN		(0x4001000EL)
 #define RNDIS_STATUS_INTERFACE_UP		(0x4001000FL)
 #define RNDIS_STATUS_INTERFACE_DOWN		(0x40010010L)
 #define RNDIS_STATUS_MEDIA_BUSY			(0x40010011L)
-#define RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION	(0x40010012L)
 #define RNDIS_STATUS_WW_INDICATION		RDIA_SPECIFIC_INDICATION
 #define RNDIS_STATUS_LINK_SPEED_CHANGE		(0x40010013L)
 
@@ -337,7 +320,6 @@
 #define RNDIS_STATUS_HARD_ERRORS		(0x80010004L)
 #define RNDIS_STATUS_BUFFER_OVERFLOW		(STATUS_BUFFER_OVERFLOW)
 
-#define RNDIS_STATUS_FAILURE			(STATUS_UNSUCCESSFUL)
 #define RNDIS_STATUS_RESOURCES			(STATUS_INSUFFICIENT_RESOURCES)
 #define RNDIS_STATUS_CLOSING			(0xC0010002L)
 #define RNDIS_STATUS_BAD_VERSION		(0xC0010004L)
@@ -351,14 +333,12 @@
 #define RNDIS_STATUS_REQUEST_ABORTED		(0xC001000CL)
 #define RNDIS_STATUS_RESET_IN_PROGRESS		(0xC001000DL)
 #define RNDIS_STATUS_CLOSING_INDICATING		(0xC001000EL)
-#define RNDIS_STATUS_NOT_SUPPORTED		(STATUS_NOT_SUPPORTED)
 #define RNDIS_STATUS_INVALID_PACKET		(0xC001000FL)
 #define RNDIS_STATUS_OPEN_LIST_FULL		(0xC0010010L)
 #define RNDIS_STATUS_ADAPTER_NOT_READY		(0xC0010011L)
 #define RNDIS_STATUS_ADAPTER_NOT_OPEN		(0xC0010012L)
 #define RNDIS_STATUS_NOT_INDICATING		(0xC0010013L)
 #define RNDIS_STATUS_INVALID_LENGTH		(0xC0010014L)
-#define RNDIS_STATUS_INVALID_DATA		(0xC0010015L)
 #define RNDIS_STATUS_BUFFER_TOO_SHORT		(0xC0010016L)
 #define RNDIS_STATUS_INVALID_OID		(0xC0010017L)
 #define RNDIS_STATUS_ADAPTER_REMOVED		(0xC0010018L)
@@ -390,7 +370,6 @@
 #define RNDIS_OID_GEN_MEDIA_SUPPORTED		0x00010103
 #define RNDIS_OID_GEN_MEDIA_IN_USE		0x00010104
 #define RNDIS_OID_GEN_MAXIMUM_LOOKAHEAD		0x00010105
-#define RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE	0x00010106
 #define RNDIS_OID_GEN_LINK_SPEED		0x00010107
 #define RNDIS_OID_GEN_TRANSMIT_BUFFER_SPACE	0x00010108
 #define RNDIS_OID_GEN_RECEIVE_BUFFER_SPACE	0x00010109
@@ -410,7 +389,6 @@
 #define RNDIS_OID_GEN_NETWORK_LAYER_ADDRESSES	0x00010118
 #define RNDIS_OID_GEN_TRANSPORT_HEADER_OFFSET	0x00010119
 #define RNDIS_OID_GEN_MACHINE_NAME		0x0001021A
-#define RNDIS_OID_GEN_RNDIS_CONFIG_PARAMETER	0x0001021B
 
 #define RNDIS_OID_GEN_XMIT_OK			0x00020101
 #define RNDIS_OID_GEN_RCV_OK			0x00020102
@@ -503,29 +481,12 @@
 #define RNDIS_OID_802_3_XMIT_TIMES_CRS_LOST	0x01020206
 #define RNDIS_OID_802_3_XMIT_LATE_COLLISIONS	0x01020207
 
-/* Remote NDIS message types */
-#define REMOTE_NDIS_PACKET_MSG			0x00000001
-#define REMOTE_NDIS_INITIALIZE_MSG		0x00000002
-#define REMOTE_NDIS_HALT_MSG			0x00000003
-#define REMOTE_NDIS_QUERY_MSG			0x00000004
-#define REMOTE_NDIS_SET_MSG			0x00000005
-#define REMOTE_NDIS_RESET_MSG			0x00000006
-#define REMOTE_NDIS_INDICATE_STATUS_MSG		0x00000007
-#define REMOTE_NDIS_KEEPALIVE_MSG		0x00000008
-
 #define REMOTE_CONDIS_MP_CREATE_VC_MSG		0x00008001
 #define REMOTE_CONDIS_MP_DELETE_VC_MSG		0x00008002
 #define REMOTE_CONDIS_MP_ACTIVATE_VC_MSG	0x00008005
 #define REMOTE_CONDIS_MP_DEACTIVATE_VC_MSG	0x00008006
 #define REMOTE_CONDIS_INDICATE_STATUS_MSG	0x00008007
 
-/* Remote NDIS message completion types */
-#define REMOTE_NDIS_INITIALIZE_CMPLT		0x80000002
-#define REMOTE_NDIS_QUERY_CMPLT			0x80000004
-#define REMOTE_NDIS_SET_CMPLT			0x80000005
-#define REMOTE_NDIS_RESET_CMPLT			0x80000006
-#define REMOTE_NDIS_KEEPALIVE_CMPLT		0x80000008
-
 #define REMOTE_CONDIS_MP_CREATE_VC_CMPLT	0x80008001
 #define REMOTE_CONDIS_MP_DELETE_VC_CMPLT	0x80008002
 #define REMOTE_CONDIS_MP_ACTIVATE_VC_CMPLT	0x80008005
@@ -537,11 +498,6 @@
  */
 #define REMOTE_NDIS_BUS_MSG			0xff000001
 
-/*  Defines for DeviceFlags in struct rndis_initialize_complete */
-#define RNDIS_DF_CONNECTIONLESS			0x00000001
-#define RNDIS_DF_CONNECTION_ORIENTED		0x00000002
-#define RNDIS_DF_RAW_DATA			0x00000004
-
 /*  Remote NDIS medium types. */
 #define RNDIS_MEDIUM_802_3			0x00000000
 #define RNDIS_MEDIUM_802_5			0x00000001
@@ -562,15 +518,10 @@
 #define RNDIS_MEDIA_STATE_CONNECTED		0x00000000
 #define RNDIS_MEDIA_STATE_DISCONNECTED		0x00000001
 
-/*  Remote NDIS version numbers */
-#define RNDIS_MAJOR_VERSION			0x00000001
-#define RNDIS_MINOR_VERSION			0x00000000
-
 /* From drivers/net/wireless/rndis_wlan.c */
 
 /* various RNDIS OID defs */
 #define OID_GEN_LINK_SPEED			0x00010107
-#define OID_GEN_RNDIS_CONFIG_PARAMETER		0x0001021b
 
 #define OID_GEN_XMIT_OK				0x00020101
 #define OID_GEN_RCV_OK				0x00020102
@@ -608,8 +559,3 @@
 #define OID_802_11_CONFIGURATION		0x0d010211
 #define OID_802_11_POWER_MODE			0x0d010216
 #define OID_802_11_BSSID_LIST			0x0d010217
-
-/* codes for "status" field of completion messages */
-#define RNDIS_STATUS_ADAPTER_NOT_READY		0xc0010011
-#define RNDIS_STATUS_ADAPTER_NOT_OPEN		0xc0010012
-
-- 
1.7.7.6
