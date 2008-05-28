From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] tulip: remove wrapper around get_unaligned
Date: Wed, 28 May 2008 16:51:04 -0700
Message-ID: <1212018664.20781.9.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:43464 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbYE1XvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 19:51:05 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2749133wfd.4
        for <netdev@vger.kernel.org>; Wed, 28 May 2008 16:51:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DE_UNALIGNED_16 is always being passed a u16 *, no need to have the
wrapper with two casts in it, just call get_unaligned directly.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/tulip/de2104x.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 1b5edd6..9281d06 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -124,8 +124,6 @@ MODULE_PARM_DESC (rx_copybreak, "de2104x Breakpoint at which Rx packets are copi
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT		(6*HZ)
 
-#define DE_UNALIGNED_16(a)	(u16)(get_unaligned((u16 *)(a)))
-
 /* This is a mysterious value that can be written to CSR11 in the 21040 (only)
    to support a pre-NWay full-duplex signaling mechanism using short frames.
    No one knows what it should be, but if left at its default value some
@@ -1811,7 +1809,7 @@ static void __devinit de21041_get_srom_info (struct de_private *de)
 		goto bad_srom;
 
 	/* get default media type */
-	switch (DE_UNALIGNED_16(&il->default_media)) {
+	switch (get_unaligned(&il->default_media)) {
 	case 0x0001:  de->media_type = DE_MEDIA_BNC; break;
 	case 0x0002:  de->media_type = DE_MEDIA_AUI; break;
 	case 0x0204:  de->media_type = DE_MEDIA_TP_FD; break;
@@ -1875,9 +1873,9 @@ static void __devinit de21041_get_srom_info (struct de_private *de)
 		bufp += sizeof (ib->opts);
 
 		if (ib->opts & MediaCustomCSRs) {
-			de->media[idx].csr13 = DE_UNALIGNED_16(&ib->csr13);
-			de->media[idx].csr14 = DE_UNALIGNED_16(&ib->csr14);
-			de->media[idx].csr15 = DE_UNALIGNED_16(&ib->csr15);
+			de->media[idx].csr13 = get_unaligned(&ib->csr13);
+			de->media[idx].csr14 = get_unaligned(&ib->csr14);
+			de->media[idx].csr15 = get_unaligned(&ib->csr15);
 			bufp += sizeof(ib->csr13) + sizeof(ib->csr14) +
 				sizeof(ib->csr15);
 
-- 
1.5.6.rc0.277.g804cf



