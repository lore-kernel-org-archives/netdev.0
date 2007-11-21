From: akpm@linux-foundation.org
Subject: [patch 4/5] drivers/bluetooth/btsdio.c: fix double-free
Date: Wed, 21 Nov 2007 15:03:58 -0800
Message-ID: <200711212303.lALN3wvW013726@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36698 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754655AbXKUXEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:04:32 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>

This patch fixes a double-free spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/bluetooth/btsdio.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff -puN drivers/bluetooth/btsdio.c~drivers-bluetooth-btsdioc-fix-double-free drivers/bluetooth/btsdio.c
--- a/drivers/bluetooth/btsdio.c~drivers-bluetooth-btsdioc-fix-double-free
+++ a/drivers/bluetooth/btsdio.c
@@ -162,10 +162,8 @@ static int btsdio_rx_packet(struct btsdi
 	bt_cb(skb)->pkt_type = hdr[3];
 
 	err = hci_recv_frame(skb);
-	if (err < 0) {
-		kfree(skb);
+	if (err < 0)
 		return err;
-	}
 
 	sdio_writeb(data->func, 0x00, REG_PC_RRT, NULL);
 
_
