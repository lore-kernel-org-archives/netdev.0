From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: [PATCH 4/5] tg3: Don't use IRQF_SAMPLE_RANDOM
Date: Tue,  1 Mar 2011 18:04:28 +0100
Message-ID: <1298999069-12740-4-git-send-email-martinez.javier@gmail.com>
References: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
Cc: Michael Chan <mchan@broadcom.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, kernelnewbies@kernelnewbies.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:57121 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757016Ab1CARE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 12:04:27 -0500
Received: by mail-ew0-f46.google.com with SMTP id 6so1731330ewy.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 09:04:27 -0800 (PST)
In-Reply-To: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This flag is scheduled for removal so we shouldn't used it.

Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
---
 drivers/net/tg3.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c67eb19..58c6049 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8844,12 +8844,11 @@ static int tg3_request_irq(struct tg3 *tp, int irq_num)
 		fn = tg3_msi;
 		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
 			fn = tg3_msi_1shot;
-		flags = IRQF_SAMPLE_RANDOM;
 	} else {
 		fn = tg3_interrupt;
 		if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
 			fn = tg3_interrupt_tagged;
-		flags = IRQF_SHARED | IRQF_SAMPLE_RANDOM;
+		flags = IRQF_SHARED;
 	}
 
 	return request_irq(tnapi->irq_vec, fn, flags, name, tnapi);
@@ -8880,7 +8879,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	}
 
 	err = request_irq(tnapi->irq_vec, tg3_test_isr,
-			  IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, tnapi);
+			  IRQF_SHARED, dev->name, tnapi);
 	if (err)
 		return err;
 
-- 
1.7.2.3

