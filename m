From: "Linus Walleij" <linus.walleij@linaro.org>
Subject: [PATCH 04/17 v5] usb/net: rndis: eliminate first set of duplicate OIDs
Date: Sat, 12 May 2012 10:16:08 +0200
Message-ID: <1336810568-2691-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.df.lth.se ([194.47.250.12]:51116 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753650Ab2ELIQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 May 2012 04:16:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RNDIS protocol contains a vast number of Object ID:s (OIDs).
The current definitions had multiple definitions of these ID:s,
let's use the nicely RNDIS_*-prefixed defines from the HyperV
implementation, rename everywhere they're used, and copy+rename
the few that were missing from this list of objects.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/usb/rndis_host.c      |    6 +-
 drivers/net/wireless/rndis_wlan.c |   34 ++++----
 drivers/usb/gadget/rndis.c        |  160 ++++++++++++++++++------------------
 include/linux/rndis.h             |  108 +++++--------------------
 4 files changed, 123 insertions(+), 185 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 3b7ddfd..dd342dc 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -396,7 +396,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	phym = NULL;
 	reply_len = sizeof *phym;
 	retval = rndis_query(dev, intf, u.buf,
-			     cpu_to_le32(OID_GEN_PHYSICAL_MEDIUM),
+			     cpu_to_le32(RNDIS_OID_GEN_PHYSICAL_MEDIUM),
 			0, (void **) &phym, &reply_len);
 	if (retval != 0 || !phym) {
 		/* OID is optional so don't fail here. */
@@ -421,7 +421,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	/* Get designated host ethernet address */
 	reply_len = ETH_ALEN;
 	retval = rndis_query(dev, intf, u.buf,
-			     cpu_to_le32(OID_802_3_PERMANENT_ADDRESS),
+			     cpu_to_le32(RNDIS_OID_802_3_PERMANENT_ADDRESS),
 			48, (void **) &bp, &reply_len);
 	if (unlikely(retval< 0)) {
 		dev_err(&intf->dev, "rndis get ethaddr, %d\n", retval);
@@ -434,7 +434,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	memset(u.set, 0, sizeof *u.set);
 	u.set->msg_type = cpu_to_le32(RNDIS_MSG_SET);
 	u.set->msg_len = cpu_to_le32(4 + sizeof *u.set);
-	u.set->oid = cpu_to_le32(OID_GEN_CURRENT_PACKET_FILTER);
+	u.set->oid = cpu_to_le32(RNDIS_OID_GEN_CURRENT_PACKET_FILTER);
 	u.set->len = cpu_to_le32(4);
 	u.set->offset = cpu_to_le32((sizeof *u.set) - 8);
 	*(__le32 *)(u.buf + sizeof *u.set) = cpu_to_le32(RNDIS_DEFAULT_FILTER);
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 1868851..c774bf5 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -626,20 +626,20 @@ static const char *oid_to_string(__le32 oid)
 	switch (oid) {
 #define OID_STR(oid) case cpu_to_le32(oid): return(#oid)
 		/* from rndis_host.h */
-		OID_STR(OID_802_3_PERMANENT_ADDRESS);
-		OID_STR(OID_GEN_MAXIMUM_FRAME_SIZE);
-		OID_STR(OID_GEN_CURRENT_PACKET_FILTER);
-		OID_STR(OID_GEN_PHYSICAL_MEDIUM);
+		OID_STR(RNDIS_OID_802_3_PERMANENT_ADDRESS);
+		OID_STR(RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE);
+		OID_STR(RNDIS_OID_GEN_CURRENT_PACKET_FILTER);
+		OID_STR(RNDIS_OID_GEN_PHYSICAL_MEDIUM);
 
 		/* from rndis_wlan.c */
-		OID_STR(OID_GEN_LINK_SPEED);
-		OID_STR(OID_GEN_RNDIS_CONFIG_PARAMETER);
+		OID_STR(RNDIS_OID_GEN_LINK_SPEED);
+		OID_STR(RNDIS_OID_GEN_RNDIS_CONFIG_PARAMETER);
 
-		OID_STR(OID_GEN_XMIT_OK);
-		OID_STR(OID_GEN_RCV_OK);
-		OID_STR(OID_GEN_XMIT_ERROR);
-		OID_STR(OID_GEN_RCV_ERROR);
-		OID_STR(OID_GEN_RCV_NO_BUFFER);
+		OID_STR(RNDIS_OID_GEN_XMIT_OK);
+		OID_STR(RNDIS_OID_GEN_RCV_OK);
+		OID_STR(RNDIS_OID_GEN_XMIT_ERROR);
+		OID_STR(RNDIS_OID_GEN_RCV_ERROR);
+		OID_STR(RNDIS_OID_GEN_RCV_NO_BUFFER);
 
 		OID_STR(OID_802_3_CURRENT_ADDRESS);
 		OID_STR(OID_802_3_MULTICAST_LIST);
@@ -945,7 +945,7 @@ static int rndis_set_config_parameter(struct usbnet *dev, char *param,
 	}
 #endif
 
-	ret = rndis_set_oid(dev, cpu_to_le32(OID_GEN_RNDIS_CONFIG_PARAMETER),
+	ret = rndis_set_oid(dev, cpu_to_le32(RNDIS_OID_GEN_RNDIS_CONFIG_PARAMETER),
 							infobuf, info_len);
 	if (ret != 0)
 		netdev_dbg(dev->net, "setting rndis config parameter failed, %d\n",
@@ -1633,14 +1633,14 @@ static void set_multicast_list(struct usbnet *usbdev)
 	}
 
 set_filter:
-	ret = rndis_set_oid(usbdev, cpu_to_le32(OID_GEN_CURRENT_PACKET_FILTER), &filter,
+	ret = rndis_set_oid(usbdev, cpu_to_le32(RNDIS_OID_GEN_CURRENT_PACKET_FILTER), &filter,
 							sizeof(filter));
 	if (ret < 0) {
 		netdev_warn(usbdev->net, "couldn't set packet filter: %08x\n",
 			    le32_to_cpu(filter));
 	}
 
-	netdev_dbg(usbdev->net, "OID_GEN_CURRENT_PACKET_FILTER(%08x) -> %d\n",
+	netdev_dbg(usbdev->net, "RNDIS_OID_GEN_CURRENT_PACKET_FILTER(%08x) -> %d\n",
 		   le32_to_cpu(filter), ret);
 }
 
@@ -2462,7 +2462,7 @@ static void rndis_fill_station_info(struct usbnet *usbdev,
 	memset(sinfo, 0, sizeof(*sinfo));
 
 	len = sizeof(linkspeed);
-	ret = rndis_query_oid(usbdev, cpu_to_le32(OID_GEN_LINK_SPEED), &linkspeed, &len);
+	ret = rndis_query_oid(usbdev, cpu_to_le32(RNDIS_OID_GEN_LINK_SPEED), &linkspeed, &len);
 	if (ret == 0) {
 		sinfo->txrate.legacy = le32_to_cpu(linkspeed) / 1000;
 		sinfo->filled |= STATION_INFO_TX_BITRATE;
@@ -3418,7 +3418,7 @@ static int rndis_wlan_bind(struct usbnet *usbdev, struct usb_interface *intf)
 
 	tmp = cpu_to_le32(RNDIS_PACKET_TYPE_DIRECTED | RNDIS_PACKET_TYPE_BROADCAST);
 	retval = rndis_set_oid(usbdev,
-			       cpu_to_le32(OID_GEN_CURRENT_PACKET_FILTER),
+			       cpu_to_le32(RNDIS_OID_GEN_CURRENT_PACKET_FILTER),
 			       &tmp, sizeof(tmp));
 
 	len = sizeof(tmp);
@@ -3554,7 +3554,7 @@ static int rndis_wlan_stop(struct usbnet *usbdev)
 	/* Set current packet filter zero to block receiving data packets from
 	   device. */
 	filter = 0;
-	rndis_set_oid(usbdev, cpu_to_le32(OID_GEN_CURRENT_PACKET_FILTER), &filter,
+	rndis_set_oid(usbdev, cpu_to_le32(RNDIS_OID_GEN_CURRENT_PACKET_FILTER), &filter,
 								sizeof(filter));
 
 	return retval;
diff --git a/drivers/usb/gadget/rndis.c b/drivers/usb/gadget/rndis.c
index 73a934a..3ade168 100644
--- a/drivers/usb/gadget/rndis.c
+++ b/drivers/usb/gadget/rndis.c
@@ -73,48 +73,48 @@ static rndis_resp_t *rndis_add_response(int configNr, u32 length);
 static const u32 oid_supported_list[] =
 {
 	/* the general stuff */
-	OID_GEN_SUPPORTED_LIST,
-	OID_GEN_HARDWARE_STATUS,
-	OID_GEN_MEDIA_SUPPORTED,
-	OID_GEN_MEDIA_IN_USE,
-	OID_GEN_MAXIMUM_FRAME_SIZE,
-	OID_GEN_LINK_SPEED,
-	OID_GEN_TRANSMIT_BLOCK_SIZE,
-	OID_GEN_RECEIVE_BLOCK_SIZE,
-	OID_GEN_VENDOR_ID,
-	OID_GEN_VENDOR_DESCRIPTION,
-	OID_GEN_VENDOR_DRIVER_VERSION,
-	OID_GEN_CURRENT_PACKET_FILTER,
-	OID_GEN_MAXIMUM_TOTAL_SIZE,
-	OID_GEN_MEDIA_CONNECT_STATUS,
-	OID_GEN_PHYSICAL_MEDIUM,
+	RNDIS_OID_GEN_SUPPORTED_LIST,
+	RNDIS_OID_GEN_HARDWARE_STATUS,
+	RNDIS_OID_GEN_MEDIA_SUPPORTED,
+	RNDIS_OID_GEN_MEDIA_IN_USE,
+	RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE,
+	RNDIS_OID_GEN_LINK_SPEED,
+	RNDIS_OID_GEN_TRANSMIT_BLOCK_SIZE,
+	RNDIS_OID_GEN_RECEIVE_BLOCK_SIZE,
+	RNDIS_OID_GEN_VENDOR_ID,
+	RNDIS_OID_GEN_VENDOR_DESCRIPTION,
+	RNDIS_OID_GEN_VENDOR_DRIVER_VERSION,
+	RNDIS_OID_GEN_CURRENT_PACKET_FILTER,
+	RNDIS_OID_GEN_MAXIMUM_TOTAL_SIZE,
+	RNDIS_OID_GEN_MEDIA_CONNECT_STATUS,
+	RNDIS_OID_GEN_PHYSICAL_MEDIUM,
 
 	/* the statistical stuff */
-	OID_GEN_XMIT_OK,
-	OID_GEN_RCV_OK,
-	OID_GEN_XMIT_ERROR,
-	OID_GEN_RCV_ERROR,
-	OID_GEN_RCV_NO_BUFFER,
+	RNDIS_OID_GEN_XMIT_OK,
+	RNDIS_OID_GEN_RCV_OK,
+	RNDIS_OID_GEN_XMIT_ERROR,
+	RNDIS_OID_GEN_RCV_ERROR,
+	RNDIS_OID_GEN_RCV_NO_BUFFER,
 #ifdef	RNDIS_OPTIONAL_STATS
-	OID_GEN_DIRECTED_BYTES_XMIT,
-	OID_GEN_DIRECTED_FRAMES_XMIT,
-	OID_GEN_MULTICAST_BYTES_XMIT,
-	OID_GEN_MULTICAST_FRAMES_XMIT,
-	OID_GEN_BROADCAST_BYTES_XMIT,
-	OID_GEN_BROADCAST_FRAMES_XMIT,
-	OID_GEN_DIRECTED_BYTES_RCV,
-	OID_GEN_DIRECTED_FRAMES_RCV,
-	OID_GEN_MULTICAST_BYTES_RCV,
-	OID_GEN_MULTICAST_FRAMES_RCV,
-	OID_GEN_BROADCAST_BYTES_RCV,
-	OID_GEN_BROADCAST_FRAMES_RCV,
-	OID_GEN_RCV_CRC_ERROR,
-	OID_GEN_TRANSMIT_QUEUE_LENGTH,
+	RNDIS_OID_GEN_DIRECTED_BYTES_XMIT,
+	RNDIS_OID_GEN_DIRECTED_FRAMES_XMIT,
+	RNDIS_OID_GEN_MULTICAST_BYTES_XMIT,
+	RNDIS_OID_GEN_MULTICAST_FRAMES_XMIT,
+	RNDIS_OID_GEN_BROADCAST_BYTES_XMIT,
+	RNDIS_OID_GEN_BROADCAST_FRAMES_XMIT,
+	RNDIS_OID_GEN_DIRECTED_BYTES_RCV,
+	RNDIS_OID_GEN_DIRECTED_FRAMES_RCV,
+	RNDIS_OID_GEN_MULTICAST_BYTES_RCV,
+	RNDIS_OID_GEN_MULTICAST_FRAMES_RCV,
+	RNDIS_OID_GEN_BROADCAST_BYTES_RCV,
+	RNDIS_OID_GEN_BROADCAST_FRAMES_RCV,
+	RNDIS_OID_GEN_RCV_CRC_ERROR,
+	RNDIS_OID_GEN_TRANSMIT_QUEUE_LENGTH,
 #endif	/* RNDIS_OPTIONAL_STATS */
 
 	/* mandatory 802.3 */
 	/* the general stuff */
-	OID_802_3_PERMANENT_ADDRESS,
+	RNDIS_OID_802_3_PERMANENT_ADDRESS,
 	OID_802_3_CURRENT_ADDRESS,
 	OID_802_3_MULTICAST_LIST,
 	OID_802_3_MAC_OPTIONS,
@@ -200,8 +200,8 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 	/* general oids (table 4-1) */
 
 	/* mandatory */
-	case OID_GEN_SUPPORTED_LIST:
-		pr_debug("%s: OID_GEN_SUPPORTED_LIST\n", __func__);
+	case RNDIS_OID_GEN_SUPPORTED_LIST:
+		pr_debug("%s: RNDIS_OID_GEN_SUPPORTED_LIST\n", __func__);
 		length = sizeof(oid_supported_list);
 		count  = length / sizeof(u32);
 		for (i = 0; i < count; i++)
@@ -210,8 +210,8 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_GEN_HARDWARE_STATUS:
-		pr_debug("%s: OID_GEN_HARDWARE_STATUS\n", __func__);
+	case RNDIS_OID_GEN_HARDWARE_STATUS:
+		pr_debug("%s: RNDIS_OID_GEN_HARDWARE_STATUS\n", __func__);
 		/* Bogus question!
 		 * Hardware must be ready to receive high level protocols.
 		 * BTW:
@@ -223,23 +223,23 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_GEN_MEDIA_SUPPORTED:
-		pr_debug("%s: OID_GEN_MEDIA_SUPPORTED\n", __func__);
+	case RNDIS_OID_GEN_MEDIA_SUPPORTED:
+		pr_debug("%s: RNDIS_OID_GEN_MEDIA_SUPPORTED\n", __func__);
 		*outbuf = cpu_to_le32(rndis_per_dev_params[configNr].medium);
 		retval = 0;
 		break;
 
 	/* mandatory */
-	case OID_GEN_MEDIA_IN_USE:
-		pr_debug("%s: OID_GEN_MEDIA_IN_USE\n", __func__);
+	case RNDIS_OID_GEN_MEDIA_IN_USE:
+		pr_debug("%s: RNDIS_OID_GEN_MEDIA_IN_USE\n", __func__);
 		/* one medium, one transport... (maybe you do it better) */
 		*outbuf = cpu_to_le32(rndis_per_dev_params[configNr].medium);
 		retval = 0;
 		break;
 
 	/* mandatory */
-	case OID_GEN_MAXIMUM_FRAME_SIZE:
-		pr_debug("%s: OID_GEN_MAXIMUM_FRAME_SIZE\n", __func__);
+	case RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE:
+		pr_debug("%s: RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE\n", __func__);
 		if (rndis_per_dev_params[configNr].dev) {
 			*outbuf = cpu_to_le32(
 				rndis_per_dev_params[configNr].dev->mtu);
@@ -248,9 +248,9 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_GEN_LINK_SPEED:
+	case RNDIS_OID_GEN_LINK_SPEED:
 		if (rndis_debug > 1)
-			pr_debug("%s: OID_GEN_LINK_SPEED\n", __func__);
+			pr_debug("%s: RNDIS_OID_GEN_LINK_SPEED\n", __func__);
 		if (rndis_per_dev_params[configNr].media_state
 				== NDIS_MEDIA_STATE_DISCONNECTED)
 			*outbuf = cpu_to_le32(0);
@@ -261,8 +261,8 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_GEN_TRANSMIT_BLOCK_SIZE:
-		pr_debug("%s: OID_GEN_TRANSMIT_BLOCK_SIZE\n", __func__);
+	case RNDIS_OID_GEN_TRANSMIT_BLOCK_SIZE:
+		pr_debug("%s: RNDIS_OID_GEN_TRANSMIT_BLOCK_SIZE\n", __func__);
 		if (rndis_per_dev_params[configNr].dev) {
 			*outbuf = cpu_to_le32(
 				rndis_per_dev_params[configNr].dev->mtu);
@@ -271,8 +271,8 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_GEN_RECEIVE_BLOCK_SIZE:
-		pr_debug("%s: OID_GEN_RECEIVE_BLOCK_SIZE\n", __func__);
+	case RNDIS_OID_GEN_RECEIVE_BLOCK_SIZE:
+		pr_debug("%s: RNDIS_OID_GEN_RECEIVE_BLOCK_SIZE\n", __func__);
 		if (rndis_per_dev_params[configNr].dev) {
 			*outbuf = cpu_to_le32(
 				rndis_per_dev_params[configNr].dev->mtu);
@@ -281,16 +281,16 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_GEN_VENDOR_ID:
-		pr_debug("%s: OID_GEN_VENDOR_ID\n", __func__);
+	case RNDIS_OID_GEN_VENDOR_ID:
+		pr_debug("%s: RNDIS_OID_GEN_VENDOR_ID\n", __func__);
 		*outbuf = cpu_to_le32(
 			rndis_per_dev_params[configNr].vendorID);
 		retval = 0;
 		break;
 
 	/* mandatory */
-	case OID_GEN_VENDOR_DESCRIPTION:
-		pr_debug("%s: OID_GEN_VENDOR_DESCRIPTION\n", __func__);
+	case RNDIS_OID_GEN_VENDOR_DESCRIPTION:
+		pr_debug("%s: RNDIS_OID_GEN_VENDOR_DESCRIPTION\n", __func__);
 		if (rndis_per_dev_params[configNr].vendorDescr) {
 			length = strlen(rndis_per_dev_params[configNr].
 					vendorDescr);
@@ -303,38 +303,38 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		retval = 0;
 		break;
 
-	case OID_GEN_VENDOR_DRIVER_VERSION:
-		pr_debug("%s: OID_GEN_VENDOR_DRIVER_VERSION\n", __func__);
+	case RNDIS_OID_GEN_VENDOR_DRIVER_VERSION:
+		pr_debug("%s: RNDIS_OID_GEN_VENDOR_DRIVER_VERSION\n", __func__);
 		/* Created as LE */
 		*outbuf = rndis_driver_version;
 		retval = 0;
 		break;
 
 	/* mandatory */
-	case OID_GEN_CURRENT_PACKET_FILTER:
-		pr_debug("%s: OID_GEN_CURRENT_PACKET_FILTER\n", __func__);
+	case RNDIS_OID_GEN_CURRENT_PACKET_FILTER:
+		pr_debug("%s: RNDIS_OID_GEN_CURRENT_PACKET_FILTER\n", __func__);
 		*outbuf = cpu_to_le32(*rndis_per_dev_params[configNr].filter);
 		retval = 0;
 		break;
 
 	/* mandatory */
-	case OID_GEN_MAXIMUM_TOTAL_SIZE:
-		pr_debug("%s: OID_GEN_MAXIMUM_TOTAL_SIZE\n", __func__);
+	case RNDIS_OID_GEN_MAXIMUM_TOTAL_SIZE:
+		pr_debug("%s: RNDIS_OID_GEN_MAXIMUM_TOTAL_SIZE\n", __func__);
 		*outbuf = cpu_to_le32(RNDIS_MAX_TOTAL_SIZE);
 		retval = 0;
 		break;
 
 	/* mandatory */
-	case OID_GEN_MEDIA_CONNECT_STATUS:
+	case RNDIS_OID_GEN_MEDIA_CONNECT_STATUS:
 		if (rndis_debug > 1)
-			pr_debug("%s: OID_GEN_MEDIA_CONNECT_STATUS\n", __func__);
+			pr_debug("%s: RNDIS_OID_GEN_MEDIA_CONNECT_STATUS\n", __func__);
 		*outbuf = cpu_to_le32(rndis_per_dev_params[configNr]
 						.media_state);
 		retval = 0;
 		break;
 
-	case OID_GEN_PHYSICAL_MEDIUM:
-		pr_debug("%s: OID_GEN_PHYSICAL_MEDIUM\n", __func__);
+	case RNDIS_OID_GEN_PHYSICAL_MEDIUM:
+		pr_debug("%s: RNDIS_OID_GEN_PHYSICAL_MEDIUM\n", __func__);
 		*outbuf = cpu_to_le32(0);
 		retval = 0;
 		break;
@@ -343,8 +343,8 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 	 * of MS-Windows expect OIDs that aren't specified there.  Other
 	 * versions emit undefined RNDIS messages. DOCUMENT ALL THESE!
 	 */
-	case OID_GEN_MAC_OPTIONS:		/* from WinME */
-		pr_debug("%s: OID_GEN_MAC_OPTIONS\n", __func__);
+	case RNDIS_OID_GEN_MAC_OPTIONS:		/* from WinME */
+		pr_debug("%s: RNDIS_OID_GEN_MAC_OPTIONS\n", __func__);
 		*outbuf = cpu_to_le32(
 			  NDIS_MAC_OPTION_RECEIVE_SERIALIZED
 			| NDIS_MAC_OPTION_FULL_DUPLEX);
@@ -354,9 +354,9 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 	/* statistics OIDs (table 4-2) */
 
 	/* mandatory */
-	case OID_GEN_XMIT_OK:
+	case RNDIS_OID_GEN_XMIT_OK:
 		if (rndis_debug > 1)
-			pr_debug("%s: OID_GEN_XMIT_OK\n", __func__);
+			pr_debug("%s: RNDIS_OID_GEN_XMIT_OK\n", __func__);
 		if (stats) {
 			*outbuf = cpu_to_le32(stats->tx_packets
 				- stats->tx_errors - stats->tx_dropped);
@@ -365,9 +365,9 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_GEN_RCV_OK:
+	case RNDIS_OID_GEN_RCV_OK:
 		if (rndis_debug > 1)
-			pr_debug("%s: OID_GEN_RCV_OK\n", __func__);
+			pr_debug("%s: RNDIS_OID_GEN_RCV_OK\n", __func__);
 		if (stats) {
 			*outbuf = cpu_to_le32(stats->rx_packets
 				- stats->rx_errors - stats->rx_dropped);
@@ -376,9 +376,9 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_GEN_XMIT_ERROR:
+	case RNDIS_OID_GEN_XMIT_ERROR:
 		if (rndis_debug > 1)
-			pr_debug("%s: OID_GEN_XMIT_ERROR\n", __func__);
+			pr_debug("%s: RNDIS_OID_GEN_XMIT_ERROR\n", __func__);
 		if (stats) {
 			*outbuf = cpu_to_le32(stats->tx_errors);
 			retval = 0;
@@ -386,9 +386,9 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_GEN_RCV_ERROR:
+	case RNDIS_OID_GEN_RCV_ERROR:
 		if (rndis_debug > 1)
-			pr_debug("%s: OID_GEN_RCV_ERROR\n", __func__);
+			pr_debug("%s: RNDIS_OID_GEN_RCV_ERROR\n", __func__);
 		if (stats) {
 			*outbuf = cpu_to_le32(stats->rx_errors);
 			retval = 0;
@@ -396,8 +396,8 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_GEN_RCV_NO_BUFFER:
-		pr_debug("%s: OID_GEN_RCV_NO_BUFFER\n", __func__);
+	case RNDIS_OID_GEN_RCV_NO_BUFFER:
+		pr_debug("%s: RNDIS_OID_GEN_RCV_NO_BUFFER\n", __func__);
 		if (stats) {
 			*outbuf = cpu_to_le32(stats->rx_dropped);
 			retval = 0;
@@ -407,7 +407,7 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 	/* ieee802.3 OIDs (table 4-3) */
 
 	/* mandatory */
-	case OID_802_3_PERMANENT_ADDRESS:
+	case RNDIS_OID_802_3_PERMANENT_ADDRESS:
 		pr_debug("%s: OID_802_3_PERMANENT_ADDRESS\n", __func__);
 		if (rndis_per_dev_params[configNr].dev) {
 			length = ETH_ALEN;
@@ -516,7 +516,7 @@ static int gen_ndis_set_resp(u8 configNr, u32 OID, u8 *buf, u32 buf_len,
 
 	params = &rndis_per_dev_params[configNr];
 	switch (OID) {
-	case OID_GEN_CURRENT_PACKET_FILTER:
+	case RNDIS_OID_GEN_CURRENT_PACKET_FILTER:
 
 		/* these NDIS_PACKET_TYPE_* bitflags are shared with
 		 * cdc_filter; it's not RNDIS-specific
@@ -525,7 +525,7 @@ static int gen_ndis_set_resp(u8 configNr, u32 OID, u8 *buf, u32 buf_len,
 		 *	MULTICAST, ALL_MULTICAST, BROADCAST
 		 */
 		*params->filter = (u16)get_unaligned_le32(buf);
-		pr_debug("%s: OID_GEN_CURRENT_PACKET_FILTER %08x\n",
+		pr_debug("%s: RNDIS_OID_GEN_CURRENT_PACKET_FILTER %08x\n",
 			__func__, *params->filter);
 
 		/* this call has a significant side effect:  it's
diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index 61b4185..ebc40b3 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -30,7 +30,7 @@
 #define	RNDIS_STATUS_MEDIA_DISCONNECT		0x4001000c
 #define	RNDIS_STATUS_MEDIA_SPECIFIC_INDICATION	0x40010012
 
-/* codes for OID_GEN_PHYSICAL_MEDIUM */
+/* codes for RNDIS_OID_GEN_PHYSICAL_MEDIUM */
 #define	RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED	0x00000000
 #define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN	0x00000001
 #define	RNDIS_PHYSICAL_MEDIUM_CABLE_MODEM	0x00000002
@@ -42,16 +42,7 @@
 #define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN	0x00000008
 #define	RNDIS_PHYSICAL_MEDIUM_MAX		0x00000009
 
-/* NOTE:  about 30 OIDs are "mandatory" for peripherals to support ... and
- * there are gobs more that may optionally be supported.  We'll avoid as much
- * of that mess as possible.
- */
-#define OID_802_3_PERMANENT_ADDRESS	0x01010101
-#define OID_GEN_MAXIMUM_FRAME_SIZE	0x00010106
-#define OID_GEN_CURRENT_PACKET_FILTER	0x0001010e
-#define OID_GEN_PHYSICAL_MEDIUM		0x00010202
-
-/* packet filter bits used by OID_GEN_CURRENT_PACKET_FILTER */
+/* packet filter bits used by RNDIS_OID_GEN_CURRENT_PACKET_FILTER */
 #define RNDIS_PACKET_TYPE_DIRECTED		0x00000001
 #define RNDIS_PACKET_TYPE_MULTICAST		0x00000002
 #define RNDIS_PACKET_TYPE_ALL_MULTICAST		0x00000004
@@ -76,70 +67,6 @@
 #define NDIS_DEVICE_WAKE_ON_PATTERN_MATCH_ENABLE  0x00000002
 #define NDIS_DEVICE_WAKE_ON_MAGIC_PACKET_ENABLE   0x00000004
 
-/* Required Object IDs (OIDs) */
-#define OID_GEN_SUPPORTED_LIST            0x00010101
-#define OID_GEN_HARDWARE_STATUS           0x00010102
-#define OID_GEN_MEDIA_SUPPORTED           0x00010103
-#define OID_GEN_MEDIA_IN_USE              0x00010104
-#define OID_GEN_MAXIMUM_LOOKAHEAD         0x00010105
-#define OID_GEN_LINK_SPEED                0x00010107
-#define OID_GEN_TRANSMIT_BUFFER_SPACE     0x00010108
-#define OID_GEN_RECEIVE_BUFFER_SPACE      0x00010109
-#define OID_GEN_TRANSMIT_BLOCK_SIZE       0x0001010A
-#define OID_GEN_RECEIVE_BLOCK_SIZE        0x0001010B
-#define OID_GEN_VENDOR_ID                 0x0001010C
-#define OID_GEN_VENDOR_DESCRIPTION        0x0001010D
-#define OID_GEN_CURRENT_LOOKAHEAD         0x0001010F
-#define OID_GEN_DRIVER_VERSION            0x00010110
-#define OID_GEN_MAXIMUM_TOTAL_SIZE        0x00010111
-#define OID_GEN_PROTOCOL_OPTIONS          0x00010112
-#define OID_GEN_MAC_OPTIONS               0x00010113
-#define OID_GEN_MEDIA_CONNECT_STATUS      0x00010114
-#define OID_GEN_MAXIMUM_SEND_PACKETS      0x00010115
-#define OID_GEN_VENDOR_DRIVER_VERSION     0x00010116
-#define OID_GEN_SUPPORTED_GUIDS           0x00010117
-#define OID_GEN_NETWORK_LAYER_ADDRESSES   0x00010118
-#define OID_GEN_TRANSPORT_HEADER_OFFSET   0x00010119
-#define OID_GEN_MACHINE_NAME              0x0001021A
-#define OID_GEN_RNDIS_CONFIG_PARAMETER    0x0001021B
-#define OID_GEN_VLAN_ID                   0x0001021C
-
-/* Optional OIDs */
-#define OID_GEN_MEDIA_CAPABILITIES        0x00010201
-
-/* Required statistics OIDs */
-#define OID_GEN_XMIT_OK                   0x00020101
-#define OID_GEN_RCV_OK                    0x00020102
-#define OID_GEN_XMIT_ERROR                0x00020103
-#define OID_GEN_RCV_ERROR                 0x00020104
-#define OID_GEN_RCV_NO_BUFFER             0x00020105
-
-/* Optional statistics OIDs */
-#define OID_GEN_DIRECTED_BYTES_XMIT       0x00020201
-#define OID_GEN_DIRECTED_FRAMES_XMIT      0x00020202
-#define OID_GEN_MULTICAST_BYTES_XMIT      0x00020203
-#define OID_GEN_MULTICAST_FRAMES_XMIT     0x00020204
-#define OID_GEN_BROADCAST_BYTES_XMIT      0x00020205
-#define OID_GEN_BROADCAST_FRAMES_XMIT     0x00020206
-#define OID_GEN_DIRECTED_BYTES_RCV        0x00020207
-#define OID_GEN_DIRECTED_FRAMES_RCV       0x00020208
-#define OID_GEN_MULTICAST_BYTES_RCV       0x00020209
-#define OID_GEN_MULTICAST_FRAMES_RCV      0x0002020A
-#define OID_GEN_BROADCAST_BYTES_RCV       0x0002020B
-#define OID_GEN_BROADCAST_FRAMES_RCV      0x0002020C
-#define OID_GEN_RCV_CRC_ERROR             0x0002020D
-#define OID_GEN_TRANSMIT_QUEUE_LENGTH     0x0002020E
-#define OID_GEN_GET_TIME_CAPS             0x0002020F
-#define OID_GEN_GET_NETCARD_TIME          0x00020210
-#define OID_GEN_NETCARD_LOAD              0x00020211
-#define OID_GEN_DEVICE_PROFILE            0x00020212
-#define OID_GEN_INIT_TIME_MS              0x00020213
-#define OID_GEN_RESET_COUNTS              0x00020214
-#define OID_GEN_MEDIA_SENSE_COUNTS        0x00020215
-#define OID_GEN_FRIENDLY_NAME             0x00020216
-#define OID_GEN_MINIPORT_INFO             0x00020217
-#define OID_GEN_RESET_VERIFY_PARAMETERS   0x00020218
-
 /* IEEE 802.3 (Ethernet) OIDs */
 #define NDIS_802_3_MAC_OPTION_PRIORITY    0x00000001
 
@@ -158,7 +85,7 @@
 #define OID_802_3_XMIT_TIMES_CRS_LOST     0x01020206
 #define OID_802_3_XMIT_LATE_COLLISIONS    0x01020207
 
-/* OID_GEN_MINIPORT_INFO constants */
+/* RNDIS_OID_GEN_MINIPORT_INFO constants */
 #define NDIS_MINIPORT_BUS_MASTER                      0x00000001
 #define NDIS_MINIPORT_WDM_DRIVER                      0x00000002
 #define NDIS_MINIPORT_SG_LIST                         0x00000004
@@ -339,12 +266,13 @@
 #define RNDIS_STATUS_TOKEN_RING_OPEN_ERROR	(0xC0011000L)
 
 /* Object Identifiers used by NdisRequest Query/Set Information */
-/* General Objects */
+/* General (Required) Objects */
 #define RNDIS_OID_GEN_SUPPORTED_LIST		0x00010101
 #define RNDIS_OID_GEN_HARDWARE_STATUS		0x00010102
 #define RNDIS_OID_GEN_MEDIA_SUPPORTED		0x00010103
 #define RNDIS_OID_GEN_MEDIA_IN_USE		0x00010104
 #define RNDIS_OID_GEN_MAXIMUM_LOOKAHEAD		0x00010105
+#define RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE	0x00010106
 #define RNDIS_OID_GEN_LINK_SPEED		0x00010107
 #define RNDIS_OID_GEN_TRANSMIT_BUFFER_SPACE	0x00010108
 #define RNDIS_OID_GEN_RECEIVE_BUFFER_SPACE	0x00010109
@@ -361,16 +289,25 @@
 #define RNDIS_OID_GEN_MEDIA_CONNECT_STATUS	0x00010114
 #define RNDIS_OID_GEN_MAXIMUM_SEND_PACKETS	0x00010115
 #define RNDIS_OID_GEN_VENDOR_DRIVER_VERSION	0x00010116
+#define RNDIS_OID_GEN_SUPPORTED_GUIDS		0x00010117
 #define RNDIS_OID_GEN_NETWORK_LAYER_ADDRESSES	0x00010118
 #define RNDIS_OID_GEN_TRANSPORT_HEADER_OFFSET	0x00010119
+#define RNDIS_OID_GEN_PHYSICAL_MEDIUM		0x00010202
 #define RNDIS_OID_GEN_MACHINE_NAME		0x0001021A
+#define RNDIS_OID_GEN_RNDIS_CONFIG_PARAMETER	0x0001021B
+#define RNDIS_OID_GEN_VLAN_ID			0x0001021C
+
+/* Optional OIDs */
+#define OID_GEN_MEDIA_CAPABILITIES		0x00010201
 
+/* Required statistics OIDs */
 #define RNDIS_OID_GEN_XMIT_OK			0x00020101
 #define RNDIS_OID_GEN_RCV_OK			0x00020102
 #define RNDIS_OID_GEN_XMIT_ERROR		0x00020103
 #define RNDIS_OID_GEN_RCV_ERROR			0x00020104
 #define RNDIS_OID_GEN_RCV_NO_BUFFER		0x00020105
 
+/* Optional statistics OIDs */
 #define RNDIS_OID_GEN_DIRECTED_BYTES_XMIT	0x00020201
 #define RNDIS_OID_GEN_DIRECTED_FRAMES_XMIT	0x00020202
 #define RNDIS_OID_GEN_MULTICAST_BYTES_XMIT	0x00020203
@@ -390,6 +327,15 @@
 #define RNDIS_OID_GEN_GET_TIME_CAPS		0x0002020F
 #define RNDIS_OID_GEN_GET_NETCARD_TIME		0x00020210
 
+#define RNDIS_OID_GEN_NETCARD_LOAD		0x00020211
+#define RNDIS_OID_GEN_DEVICE_PROFILE		0x00020212
+#define RNDIS_OID_GEN_INIT_TIME_MS		0x00020213
+#define RNDIS_OID_GEN_RESET_COUNTS		0x00020214
+#define RNDIS_OID_GEN_MEDIA_SENSE_COUNTS	0x00020215
+#define RNDIS_OID_GEN_FRIENDLY_NAME		0x00020216
+#define RNDIS_OID_GEN_MINIPORT_INFO		0x00020217
+#define RNDIS_OID_GEN_RESET_VERIFY_PARAMETERS	0x00020218
+
 /* These are connection-oriented general OIDs. */
 /* These replace the above OIDs for connection-oriented media. */
 #define RNDIS_OID_GEN_CO_SUPPORTED_LIST		0x00010101
@@ -496,14 +442,6 @@
 /* From drivers/net/wireless/rndis_wlan.c */
 
 /* various RNDIS OID defs */
-#define OID_GEN_LINK_SPEED			0x00010107
-
-#define OID_GEN_XMIT_OK				0x00020101
-#define OID_GEN_RCV_OK				0x00020102
-#define OID_GEN_XMIT_ERROR			0x00020103
-#define OID_GEN_RCV_ERROR			0x00020104
-#define OID_GEN_RCV_NO_BUFFER			0x00020105
-
 #define OID_802_3_CURRENT_ADDRESS		0x01010102
 #define OID_802_3_MULTICAST_LIST		0x01010103
 #define OID_802_3_MAXIMUM_LIST_SIZE		0x01010104
-- 
1.7.7.6
