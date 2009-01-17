From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] via-velocity: fix hot spin
Date: Sat, 17 Jan 2009 22:14:31 +0100
Message-ID: <49724A37.3040703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:9180 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbZAQVOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 16:14:31 -0500
Received: by ug-out-1314.google.com with SMTP id 39so113601ugf.37
        for <netdev@vger.kernel.org>; Sat, 17 Jan 2009 13:14:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

while(--j >= 0) keeps spinning when j is unsigned:

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index a75f91d..c5691fd 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1302,7 +1302,7 @@ static void velocity_free_rd_ring(struct velocity_info *vptr)
 static int velocity_init_td_ring(struct velocity_info *vptr)
 {
 	dma_addr_t curr;
-	unsigned int j;
+	int j;
 
 	/* Init the TD ring entries */
 	for (j = 0; j < vptr->tx.numq; j++) {

