From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 6/9][v2] mISDN: fix sparse warning: symbol 'id' shadows an earlier one
Date: Thu, 11 Dec 2008 22:36:00 +0100
Message-ID: <49419a37.0aa5660a.7d74.31a0@mx.google.com>
Cc: Karsten Keil <kkeil@suse.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758363AbYLKWzw@vger.kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Impact: rename function scope variable

Fix this warning:

  drivers/isdn/mISDN/l1oip_core.c:472:8: warning: symbol 'id' shadows an earlier one
  drivers/isdn/mISDN/l1oip_core.c:254:14: originally declared here

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
Acked-by: Karsten Keil <kkeil@suse.de>
---
 drivers/isdn/mISDN/l1oip_core.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index e42150a..0884dd6 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -469,7 +469,7 @@ l1oip_socket_recv(struct l1oip *hc, u8 remotecodec, u8 channel, u16 timebase,
 static void
 l1oip_socket_parse(struct l1oip *hc, struct sockaddr_in *sin, u8 *buf, int len)
 {
-	u32			id;
+	u32			packet_id;
 	u8			channel;
 	u8			remotecodec;
 	u16			timebase;
@@ -508,7 +508,7 @@ l1oip_socket_parse(struct l1oip *hc, struct sockaddr_in *sin, u8 *buf, int len)
 	}
 
 	/* get id flag */
-	id = (*buf>>4)&1;
+	packet_id = (*buf>>4)&1;
 
 	/* check coding */
 	remotecodec = (*buf) & 0x0f;
@@ -520,11 +520,11 @@ l1oip_socket_parse(struct l1oip *hc, struct sockaddr_in *sin, u8 *buf, int len)
 	buf++;
 	len--;
 
-	/* check id */
-	if (id) {
+	/* check packet_id */
+	if (packet_id) {
 		if (!hc->id) {
 			printk(KERN_WARNING "%s: packet error - packet has id "
-				"0x%x, but we have not\n", __func__, id);
+				"0x%x, but we have not\n", __func__, packet_id);
 			return;
 		}
 		if (len < 4) {
@@ -532,16 +532,16 @@ l1oip_socket_parse(struct l1oip *hc, struct sockaddr_in *sin, u8 *buf, int len)
 				"short for ID value\n", __func__);
 			return;
 		}
-		id = (*buf++) << 24;
-		id += (*buf++) << 16;
-		id += (*buf++) << 8;
-		id += (*buf++);
+		packet_id = (*buf++) << 24;
+		packet_id += (*buf++) << 16;
+		packet_id += (*buf++) << 8;
+		packet_id += (*buf++);
 		len -= 4;
 
-		if (id != hc->id) {
+		if (packet_id != hc->id) {
 			printk(KERN_WARNING "%s: packet error - ID mismatch, "
 				"got 0x%x, we 0x%x\n",
-				__func__, id, hc->id);
+				__func__, packet_id, hc->id);
 			return;
 		}
 	} else {
-- 
1.5.6.3
