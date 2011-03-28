From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: [PATCH 2/2 v2] tg3: Don't use IRQF_SAMPLE_RANDOM
Date: Mon, 28 Mar 2011 14:15:43 +0200
Message-ID: <1301314543-3666-1-git-send-email-martinez.javier@gmail.com>
Cc: Dan Carpenter <error27@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63051 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756Ab1C1MPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 08:15:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This flag is scheduled for removal so we shouldn't used it.

Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
---
v2: Initialize flags to zero suggested by Dan Carpenter.

 drivers/net/tg3.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5135655..7adbf63 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8839,12 +8839,12 @@ static int tg3_request_irq(struct tg3 *tp, int irq_num)
 		fn = tg3_msi;
 		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
 			fn = tg3_msi_1shot;
-		flags = IRQF_SAMPLE_RANDOM;
+		flags = 0;
 	} else {
 		fn = tg3_interrupt;
 		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
 			fn = tg3_interrupt_tagged;
-		flags = IRQF_SHARED | IRQF_SAMPLE_RANDOM;
+		flags = IRQF_SHARED;
 	}
 
 	return request_irq(tnapi->irq_vec, fn, flags, name, tnapi);
@@ -8875,7 +8875,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	}
 
 	err = request_irq(tnapi->irq_vec, tg3_test_isr,
-			  IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, tnapi);
+			  IRQF_SHARED, dev->name, tnapi);
 	if (err)
 		return err;
 
-- 
1.7.2.5

