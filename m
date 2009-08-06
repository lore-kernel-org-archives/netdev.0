From: akpm@linux-foundation.org
Subject: [patch 1/1] irda: fix read buffer overflow
Date: Thu, 06 Aug 2009 16:06:03 -0700
Message-ID: <200908062306.n76N63iE005813@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	roel.kluin@gmail.com
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53316 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756848AbZHFXGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 19:06:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

io[i] is read before the bounds check on i, order should be reversed.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/irda/w83977af_ir.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/irda/w83977af_ir.c~irda-fix-read-buffer-overflow drivers/net/irda/w83977af_ir.c
--- a/drivers/net/irda/w83977af_ir.c~irda-fix-read-buffer-overflow
+++ a/drivers/net/irda/w83977af_ir.c
@@ -115,7 +115,7 @@ static int __init w83977af_init(void)
 
 	IRDA_DEBUG(0, "%s()\n", __func__ );
 
-	for (i=0; (io[i] < 2000) && (i < ARRAY_SIZE(dev_self)); i++) {
+	for (i=0; i < ARRAY_SIZE(dev_self) && io[i] < 2000; i++) {
 		if (w83977af_open(i, io[i], irq[i], dma[i]) == 0)
 			return 0;
 	}
_
