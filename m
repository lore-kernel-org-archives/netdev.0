From: zeal <zealcook@gmail.com>
Subject: [PATCH 2/2 v2] KS8695: fix ks8695_rx() unreasonable action.
Date: Mon, 16 Nov 2009 22:58:10 +0800
Message-ID: <4b016886.16115e0a.355d.ffffca52@mx.google.com>
References: <1258383490-13341-1-git-send-email-zeal>
Cc: ben@simtec.co.uk, davem@davemloft.net, figo1802@gmail.com,
	zeal <zealcook@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:64240 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbZKPO6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 09:58:09 -0500
Received: by bwz27 with SMTP id 27so5734008bwz.21
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 06:58:14 -0800 (PST)
In-Reply-To: <1258383490-13341-1-git-send-email-zeal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: zeal <zealcook@gmail.com>

ks8695_rx() will call refill_buffers() for every incoming packet.
Its not necessary. We just need do it after finishing receiving thing.
And the 'RX dma engine' is in the same situation.
This blocks our user space application. The following patch may fix it.

Signed-off-by: zeal <zealcook@gmail.com>
---
 drivers/net/arm/ks8695net.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index e15451a..be256b3 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -544,14 +544,13 @@ rx_finished:
 				ksp->next_rx_desc_read =
 					(last_rx_processed + 1) &
 					MAX_RX_DESC_MASK;
-
-			/* And refill the buffers */
-			ks8695_refill_rxbuffers(ksp);
-
-			/* Kick the RX DMA engine, in case it became
-			 *  suspended */
-			ks8695_writereg(ksp, KS8695_DRSC, 0);
 	}
+	/* And refill the buffers */
+	ks8695_refill_rxbuffers(ksp);
+
+	/* Kick the RX DMA engine, in case it became
+	 *  suspended */
+	ks8695_writereg(ksp, KS8695_DRSC, 0);
 	return received;
 }
 
-- 
1.5.6.5

