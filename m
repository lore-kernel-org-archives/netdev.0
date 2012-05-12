From: "Linus Walleij" <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/17 v5] usb/net: rndis: merge media type definitions
Date: Sat, 12 May 2012 10:16:39 +0200
Message-ID: <1336810599-2834-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>,
	Haiyang Zhang <haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
	Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Let's have a unified table of RNDIS media. We used to have a similar
table with NDIS_* prefix from the gadget driver, but since we're only
using RNDIS in the kernel (IIRC NDIS, non-remote, is for the windows-
internal network drivers so what do we care) let's prefix everything
with RNDIS. Some of the definitions were conflicting, in one of the
defines 0x0B is bearer "CO WAN" and in two others "BPC". Well I took
the majority vote. Two definition of medium 0x09 calls it "wireless
WAN" but one vote for "wireless LAN" but in this case I am sticking
with the minority, "Wide Area Network" does not make much sense in
this case as far as I can tell.

NOTE: latin singular and plural is so screwed up in these defines
that it makes my eyes bleed. But I will not attempt to submit a
patch converting all use of _MEDIA_ to _MEDIUM_ while I can probably
tell from the semantics of the code that RNDIS_MEDIA_STATE_CONNECTED
is most probably (erroneously) referring to a singular, unless it
can return an array of connected media. I suspect these erroneous
plurals are used in documentation and such so I don't want to
mess around with things for no functional change.

Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/usb/gadget/f_rndis.c |    6 ++--
 drivers/usb/gadget/rndis.c   |    8 +++---
 include/linux/rndis.h        |   60 +++++++++++++++--------------------------
 3 files changed, 29 insertions(+), 45 deletions(-)

diff --git a/drivers/usb/gadget/f_rndis.c b/drivers/usb/gadget/f_rndis.c
index 5234365..d4f823f 100644
--- a/drivers/usb/gadget/f_rndis.c
+++ b/drivers/usb/gadget/f_rndis.c
@@ -637,7 +637,7 @@ static void rndis_open(struct gether *geth)
 
 	DBG(cdev, "%s\n", __func__);
 
-	rndis_set_param_medium(rndis->config, NDIS_MEDIUM_802_3,
+	rndis_set_param_medium(rndis->config, RNDIS_MEDIUM_802_3,
 				bitrate(cdev->gadget) / 100);
 	rndis_signal_connect(rndis->config);
 }
@@ -648,7 +648,7 @@ static void rndis_close(struct gether *geth)
 
 	DBG(geth->func.config->cdev, "%s\n", __func__);
 
-	rndis_set_param_medium(rndis->config, NDIS_MEDIUM_802_3, 0);
+	rndis_set_param_medium(rndis->config, RNDIS_MEDIUM_802_3, 0);
 	rndis_signal_disconnect(rndis->config);
 }
 
@@ -765,7 +765,7 @@ rndis_bind(struct usb_configuration *c, struct usb_function *f)
 		goto fail;
 	rndis->config = status;
 
-	rndis_set_param_medium(rndis->config, NDIS_MEDIUM_802_3, 0);
+	rndis_set_param_medium(rndis->config, RNDIS_MEDIUM_802_3, 0);
 	rndis_set_host_mac(rndis->config, rndis->ethaddr);
 
 #if 0
diff --git a/drivers/usb/gadget/rndis.c b/drivers/usb/gadget/rndis.c
index 79ed261..d9086ca 100644
--- a/drivers/usb/gadget/rndis.c
+++ b/drivers/usb/gadget/rndis.c
@@ -252,7 +252,7 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		if (rndis_debug > 1)
 			pr_debug("%s: RNDIS_OID_GEN_LINK_SPEED\n", __func__);
 		if (rndis_per_dev_params[configNr].media_state
-				== NDIS_MEDIA_STATE_DISCONNECTED)
+				== RNDIS_MEDIA_STATE_DISCONNECTED)
 			*outbuf = cpu_to_le32(0);
 		else
 			*outbuf = cpu_to_le32(
@@ -758,7 +758,7 @@ static int rndis_indicate_status_msg(int configNr, u32 status)
 int rndis_signal_connect(int configNr)
 {
 	rndis_per_dev_params[configNr].media_state
-			= NDIS_MEDIA_STATE_CONNECTED;
+			= RNDIS_MEDIA_STATE_CONNECTED;
 	return rndis_indicate_status_msg(configNr,
 					  RNDIS_STATUS_MEDIA_CONNECT);
 }
@@ -766,7 +766,7 @@ int rndis_signal_connect(int configNr)
 int rndis_signal_disconnect(int configNr)
 {
 	rndis_per_dev_params[configNr].media_state
-			= NDIS_MEDIA_STATE_DISCONNECTED;
+			= RNDIS_MEDIA_STATE_DISCONNECTED;
 	return rndis_indicate_status_msg(configNr,
 					  RNDIS_STATUS_MEDIA_DISCONNECT);
 }
@@ -1173,7 +1173,7 @@ int rndis_init(void)
 		rndis_per_dev_params[i].used = 0;
 		rndis_per_dev_params[i].state = RNDIS_UNINITIALIZED;
 		rndis_per_dev_params[i].media_state
-				= NDIS_MEDIA_STATE_DISCONNECTED;
+				= RNDIS_MEDIA_STATE_DISCONNECTED;
 		INIT_LIST_HEAD(&(rndis_per_dev_params[i].resp_queue));
 	}
 
diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index 2e0b1bd..4857959 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -112,6 +112,28 @@
 #define	RNDIS_PHYSICAL_MEDIUM_WIRELESS_WAN	0x00000008
 #define	RNDIS_PHYSICAL_MEDIUM_MAX		0x00000009
 
+/*  Remote NDIS medium types. */
+#define RNDIS_MEDIUM_UNSPECIFIED		0x00000000
+#define RNDIS_MEDIUM_802_3			0x00000000
+#define RNDIS_MEDIUM_802_5			0x00000001
+#define RNDIS_MEDIUM_FDDI			0x00000002
+#define RNDIS_MEDIUM_WAN			0x00000003
+#define RNDIS_MEDIUM_LOCAL_TALK			0x00000004
+#define RNDIS_MEDIUM_ARCNET_RAW			0x00000006
+#define RNDIS_MEDIUM_ARCNET_878_2		0x00000007
+#define RNDIS_MEDIUM_ATM			0x00000008
+#define RNDIS_MEDIUM_WIRELESS_LAN		0x00000009
+#define RNDIS_MEDIUM_IRDA			0x0000000A
+#define RNDIS_MEDIUM_BPC			0x0000000B
+#define RNDIS_MEDIUM_CO_WAN			0x0000000C
+#define RNDIS_MEDIUM_1394			0x0000000D
+/* Not a real medium, defined as an upper-bound */
+#define RNDIS_MEDIUM_MAX			0x0000000E
+
+/* Remote NDIS medium connection states. */
+#define RNDIS_MEDIA_STATE_CONNECTED		0x00000000
+#define RNDIS_MEDIA_STATE_DISCONNECTED		0x00000001
+
 /* packet filter bits used by RNDIS_OID_GEN_CURRENT_PACKET_FILTER */
 #define RNDIS_PACKET_TYPE_DIRECTED		0x00000001
 #define RNDIS_PACKET_TYPE_MULTICAST		0x00000002
@@ -163,21 +185,6 @@
 #define NDIS_MINIPORT_SUPPORTS_CANCEL_SEND_PACKETS    0x00800000
 #define NDIS_MINIPORT_64BITS_DMA                      0x01000000
 
-#define NDIS_MEDIUM_802_3		0x00000000
-#define NDIS_MEDIUM_802_5		0x00000001
-#define NDIS_MEDIUM_FDDI		0x00000002
-#define NDIS_MEDIUM_WAN			0x00000003
-#define NDIS_MEDIUM_LOCAL_TALK		0x00000004
-#define NDIS_MEDIUM_DIX			0x00000005
-#define NDIS_MEDIUM_ARCENT_RAW		0x00000006
-#define NDIS_MEDIUM_ARCENT_878_2	0x00000007
-#define NDIS_MEDIUM_ATM			0x00000008
-#define NDIS_MEDIUM_WIRELESS_LAN	0x00000009
-#define NDIS_MEDIUM_IRDA		0x0000000A
-#define NDIS_MEDIUM_BPC			0x0000000B
-#define NDIS_MEDIUM_CO_WAN		0x0000000C
-#define NDIS_MEDIUM_1394		0x0000000D
-
 #define NDIS_PACKET_TYPE_DIRECTED	0x00000001
 #define NDIS_PACKET_TYPE_MULTICAST	0x00000002
 #define NDIS_PACKET_TYPE_ALL_MULTICAST	0x00000004
@@ -191,9 +198,6 @@
 #define NDIS_PACKET_TYPE_FUNCTIONAL	0x00000400
 #define NDIS_PACKET_TYPE_MAC_FRAME	0x00000800
 
-#define NDIS_MEDIA_STATE_CONNECTED	0x00000000
-#define NDIS_MEDIA_STATE_DISCONNECTED	0x00000001
-
 #define NDIS_MAC_OPTION_COPY_LOOKAHEAD_DATA     0x00000001
 #define NDIS_MAC_OPTION_RECEIVE_SERIALIZED      0x00000002
 #define NDIS_MAC_OPTION_TRANSFERS_NOT_PEND      0x00000004
@@ -421,23 +425,3 @@
  * driver and remote device, if necessary.
  */
 #define REMOTE_NDIS_BUS_MSG			0xff000001
-
-/*  Remote NDIS medium types. */
-#define RNDIS_MEDIUM_802_3			0x00000000
-#define RNDIS_MEDIUM_802_5			0x00000001
-#define RNDIS_MEDIUM_FDDI				0x00000002
-#define RNDIS_MEDIUM_WAN				0x00000003
-#define RNDIS_MEDIUM_LOCAL_TALK			0x00000004
-#define RNDIS_MEDIUM_ARCNET_RAW			0x00000006
-#define RNDIS_MEDIUM_ARCNET_878_2			0x00000007
-#define RNDIS_MEDIUM_ATM				0x00000008
-#define RNDIS_MEDIUM_WIRELESS_WAN			0x00000009
-#define RNDIS_MEDIUM_IRDA				0x0000000a
-#define RNDIS_MEDIUM_CO_WAN			0x0000000b
-/* Not a real medium, defined as an upper-bound */
-#define RNDIS_MEDIUM_MAX				0x0000000d
-
