From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 1/1] mISDN: Bugfix only few bytes are transfered on a connection
Date: Sun, 29 Jul 2012 19:15:13 +0200
Message-ID: <1343582113-14752-2-git-send-email-keil@b1-systems.de>
References: <1343582113-14752-1-git-send-email-keil@b1-systems.de>
Cc: netdev@vger.kernel.org, tobias.powalowski@googlemail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.b1-systems.de ([217.11.58.35]:47397 "EHLO mx1.b1-systems.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753322Ab2G2RVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2012 13:21:46 -0400
In-Reply-To: <1343582113-14752-1-git-send-email-keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The test for the fillempty condition was wrong in one place.
Changed the variable to the right boolean type.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index c08fc60..fa6ca47 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -449,7 +449,8 @@ hdlc_fill_fifo(struct bchannel *bch)
 {
 	struct fritzcard *fc = bch->hw;
 	struct hdlc_hw *hdlc;
-	int count, fs, cnt = 0, idx, fillempty = 0;
+	int count, fs, cnt = 0, idx;
+	bool fillempty = false;
 	u8 *p;
 	u32 *ptr, val, addr;
 
@@ -462,7 +463,7 @@ hdlc_fill_fifo(struct bchannel *bch)
 			return;
 		count = fs;
 		p = bch->fill;
-		fillempty = 1;
+		fillempty = true;
 	} else {
 		count = bch->tx_skb->len - bch->tx_idx;
 		if (count <= 0)
@@ -477,7 +478,7 @@ hdlc_fill_fifo(struct bchannel *bch)
 			hdlc->ctrl.sr.cmd |= HDLC_CMD_XME;
 	}
 	ptr = (u32 *)p;
-	if (fillempty) {
+	if (!fillempty) {
 		pr_debug("%s.B%d: %d/%d/%d", fc->name, bch->nr, count,
 			 bch->tx_idx, bch->tx_skb->len);
 		bch->tx_idx += count;
-- 
1.7.7
