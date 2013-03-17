From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH] drivers: net: irda: use resource_size() in au1k_ir.c
Date: Sun, 17 Mar 2013 09:03:46 +0200
Message-ID: <1363503826-24166-1-git-send-email-silviupopescu1990@gmail.com>
Cc: samuel@sortiz.org, linux-kernel@vger.kernel.org,
	Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:33198 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361Ab3CQHDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 03:03:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This uses the resource_size() function instead of explicit computation.

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
---
 drivers/net/irda/au1k_ir.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index b5151e4..56f1e6d 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -27,6 +27,7 @@
 #include <linux/slab.h>
 #include <linux/time.h>
 #include <linux/types.h>
+#include <linux/ioport.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/irmod.h>
@@ -882,12 +883,12 @@ static int au1k_irda_probe(struct platform_device *pdev)
 		goto out;
 
 	err = -EBUSY;
-	aup->ioarea = request_mem_region(r->start, r->end - r->start + 1,
+	aup->ioarea = request_mem_region(r->start, resource_size(r),
 					 pdev->name);
 	if (!aup->ioarea)
 		goto out;
 
-	aup->iobase = ioremap_nocache(r->start, r->end - r->start + 1);
+	aup->iobase = ioremap_nocache(r->start, resource_size(r));
 	if (!aup->iobase)
 		goto out2;
 
-- 
1.7.9.5
