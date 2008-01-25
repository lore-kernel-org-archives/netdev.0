From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH 05/14] [rndis_host] Fix rndis packet filter flags.
Date: Sat, 26 Jan 2008 00:51:01 +0200
Message-ID: <20080125225100.11716.27243.stgit@fate.lan>
References: <20080125225032.11716.77713.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bjd@jooz.net, david-b@pacbell.net
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:53569 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760302AbYAYWvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 17:51:09 -0500
In-Reply-To: <20080125225032.11716.77713.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RNDIS packet filter flags are not exactly the same as CDC flags
so we cannot reuse them.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Signed-off-by: Bjorge Dijkstra <bjd@jooz.net>
---

 drivers/net/usb/rndis_host.c |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index c686025..12daf9c 100644
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
+	RNDIS_PACKET_TYPE_PROMISCUOUS)
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

