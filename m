From: zealcook@gmail.com
Subject: [PATCH 2/2] KS8695: fix ks8695_rx to block user space program.
Date: Mon, 16 Nov 2009 22:30:19 +0800
Message-ID: <1258381819-10324-2-git-send-email-jie.zeng@soliton.com.cn>
References: <1258381819-10324-1-git-send-email-jie.zeng@soliton.com.cn>
Cc: ben@simtec.co.uk, davem@davemloft.net,
	"jie.zeng" <jie.zeng@soliton.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:42105 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900AbZKPOaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 09:30:23 -0500
Received: by fxm21 with SMTP id 21so2750876fxm.21
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 06:30:28 -0800 (PST)
In-Reply-To: <1258381819-10324-1-git-send-email-jie.zeng@soliton.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jie.zeng <jie.zeng@soliton.com.cn>

ks8695_rx() will call refill_buffers() for every incoming packet.
Its not necessary. We just need do it after finishing receiving thing.
And the 'RX dma engine' is in the same situation.
This blocks our user space application. The following patch may fix it.

Signed-off-by: jie.zeng <jie.zeng@soliton.com.cn>
---
 drivers/net/arm/ks8695net.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index 64c683d..a99be26 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -547,13 +547,14 @@ rx_finished:
 					(last_rx_processed + 1) &
 					MAX_RX_DESC_MASK;
 
-			/* And refill the buffers */
-			ks8695_refill_rxbuffers(ksp);
-
-			/* Kick the RX DMA engine, in case it became
-			 *  suspended */
-			ks8695_writereg(ksp, KS8695_DRSC, 0);
 	}
+
+	/* And refill the buffers */
+	ks8695_refill_rxbuffers(ksp);
+
+	/* Kick the RX DMA engine, in case it became
+	 * suspended */
+	ks8695_writereg(ksp, KS8695_DRSC, 0);
 	return received;
 }
 
-- 
1.4.4.4

