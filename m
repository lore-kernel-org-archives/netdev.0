From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] TG3: limit reaches -1
Date: Wed, 11 Feb 2009 11:49:30 +0100
Message-ID: <4992AD3A.7000301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:11118 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754943AbZBKKt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 05:49:28 -0500
Received: by fk-out-0910.google.com with SMTP id f33so52958fkf.5
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 02:49:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With while (limit--) { ... } limit reaches -1, so 0 means success.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8b3f846..4595962 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -852,7 +852,7 @@ static int tg3_bmcr_reset(struct tg3 *tp)
 		}
 		udelay(10);
 	}
-	if (limit <= 0)
+	if (limit < 0)
 		return -EBUSY;
 
 	return 0;
@@ -1603,7 +1603,7 @@ static int tg3_wait_macro_done(struct tg3 *tp)
 				break;
 		}
 	}
-	if (limit <= 0)
+	if (limit < 0)
 		return -EBUSY;
 
 	return 0;
