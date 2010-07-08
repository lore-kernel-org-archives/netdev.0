From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 1/4] ax88796: free irq on error
Date: Thu,  8 Jul 2010 16:09:54 +0400
Message-ID: <1278590996-3122-1-git-send-email-segooon@gmail.com>
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>,
	"David S. Miller" <davem@davemloft.net>,
	Julia Lawall <julia@diku.dk>, Tejun Heo <tj@kernel.org>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:54488 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756450Ab0GHMKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 08:10:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If ax_ei_open() failed we must free previously requested irq.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/ax88796.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 55c9958..20e946b 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -481,8 +481,10 @@ static int ax_open(struct net_device *dev)
 		return ret;
 
 	ret = ax_ei_open(dev);
-	if (ret)
+	if (ret) {
+		free_irq(dev->irq, dev);
 		return ret;
+	}
 
 	/* turn the phy on (if turned off) */
 
-- 
1.7.0.4

