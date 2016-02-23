From: Diego Viola <diego.viola@gmail.com>
Subject: [PATCH] net: jme: fix suspend/resume on JMC260
Date: Mon, 22 Feb 2016 21:32:52 -0300
Message-ID: <1456187572-2964-1-git-send-email-diego.viola@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	richard.weinberger@gmail.com, pavel@ucw.cz, rjw@rjwysocki.net,
	davem@davemloft.net, Diego Viola <diego.viola@gmail.com>
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:35741 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbcBWAfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 19:35:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Diego Viola <diego.viola@gmail.com>
---
 drivers/net/ethernet/jme.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index b1de7af..8adbe8f 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -3312,13 +3312,14 @@ jme_resume(struct device *dev)
 		jme_reset_phy_processor(jme);
 	jme_phy_calibration(jme);
 	jme_phy_setEA(jme);
-	jme_start_irq(jme);
 	netif_device_attach(netdev);
 
 	atomic_inc(&jme->link_changing);
 
 	jme_reset_link(jme);
 
+	jme_start_irq(jme);
+
 	return 0;
 }
 
-- 
2.7.1
