From: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
Subject: [PATCH 5/8] Fix rndis packet filter flags.
Date: Sat, 22 Dec 2007 22:51:31 +0100
Message-ID: <1198360295996-git-send-email-bjd@jooz.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
To: dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <11983602942818-git-send-email-bjd-a1rhEgazXTw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>

RNDIS packet filter flags are not exactly the same as CDC flags
so we cannot reuse them.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Signed-off-by: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>
---
 drivers/net/usb/rndis_host.c |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index c686025..3c116f9 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -256,6 +256,27 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) */
 #define OID_GEN_MAXIMUM_FRAME_SIZE	ccpu2(0x00010106)
 #define OID_GEN_CURRENT_PACKET_FILTER	ccpu2(0x0001010e)
 
+/* packet filter bits used by OID_GEN_CURRENT_PACKET_FILTER */
+#define RNDIS_PACKET_TYPE_DIRECTED		ccpu2(0x00000001)
+#define RNDIS_PACKET_TYPE_MULTICAST		ccpu2(0x00000002)
+#define RNDIS_PACKET_TYPE_ALL_MULTICAST		ccpu2(0x00000004)
+#define RNDIS_PACKET_TYPE_BROADCAST		ccpu2(0x00000008)
+#define RNDIS_PACKET_TYPE_SOURCE_ROUTING	ccpu2(0x00000010)
+#define RNDIS_PACKET_TYPE_PROMISCUOUS		ccpu2(0x00000020)
+#define RNDIS_PACKET_TYPE_SMT			ccpu2(0x00000040)
+#define RNDIS_PACKET_TYPE_ALL_LOCAL		ccpu2(0x00000080)
+#define RNDIS_PACKET_TYPE_GROUP			ccpu2(0x00001000)
+#define RNDIS_PACKET_TYPE_ALL_FUNCTIONAL	ccpu2(0x00002000)
+#define RNDIS_PACKET_TYPE_FUNCTIONAL		ccpu2(0x00004000)
+#define RNDIS_PACKET_TYPE_MAC_FRAME		ccpu2(0x00008000)
+
+/* default filter used with RNDIS devices */
+#define RNDIS_DEFAULT_FILTER ( \
+	RNDIS_PACKET_TYPE_DIRECTED | \
+	RNDIS_PACKET_TYPE_BROADCAST | \
+	RNDIS_PACKET_TYPE_ALL_MULTICAST | \
+	RNDIS_PACKET_TYPE_PROMISCUOUS )
+
 /*
  * RNDIS notifications from device: command completion; "reverse"
  * keepalives; etc
@@ -551,7 +572,7 @@ static int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
 	u.set->oid = OID_GEN_CURRENT_PACKET_FILTER;
 	u.set->len = ccpu2(4);
 	u.set->offset = ccpu2((sizeof *u.set) - 8);
-	*(__le32 *)(u.buf + sizeof *u.set) = ccpu2(DEFAULT_FILTER);
+	*(__le32 *)(u.buf + sizeof *u.set) = RNDIS_DEFAULT_FILTER;
 
 	retval = rndis_command(dev, u.header);
 	if (unlikely(retval < 0)) {
-- 
1.5.2.5
