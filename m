From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH RFC 2/2] ixp4xx_hss: avoid calling dma_pool_create() with NULL dev
Date: Sun, 18 Nov 2012 01:25:10 -0500
Message-ID: <1353219910-24690-2-git-send-email-xi.wang@gmail.com>
References: <1353219910-24690-1-git-send-email-xi.wang@gmail.com>
Cc: netdev@vger.kernel.org, Xi Wang <xi.wang@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:47794 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312Ab2KRGZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Nov 2012 01:25:23 -0500
Received: by mail-qc0-f174.google.com with SMTP id o22so2545385qcr.19
        for <netdev@vger.kernel.org>; Sat, 17 Nov 2012 22:25:23 -0800 (PST)
In-Reply-To: <1353219910-24690-1-git-send-email-xi.wang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use &port->netdev->dev instead of NULL since dma_pool_create() doesn't
allow NULL dev.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
See also
https://lkml.org/lkml/2012/11/14/11
---
 drivers/net/wan/ixp4xx_hss.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index 3f575af..e9a3da5 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -969,10 +969,12 @@ static int init_hdlc_queues(struct port *port)
 {
 	int i;
 
-	if (!ports_open)
-		if (!(dma_pool = dma_pool_create(DRV_NAME, NULL,
-						 POOL_ALLOC_SIZE, 32, 0)))
+	if (!ports_open) {
+		dma_pool = dma_pool_create(DRV_NAME, &port->netdev->dev,
+					   POOL_ALLOC_SIZE, 32, 0);
+		if (!dma_pool)
 			return -ENOMEM;
+	}
 
 	if (!(port->desc_tab = dma_pool_alloc(dma_pool, GFP_KERNEL,
 					      &port->desc_tab_phys)))
-- 
1.7.10.4
