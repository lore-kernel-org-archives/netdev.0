From: jon@ringle.org
Subject: [PATCH net-next] net: encx24j600: quiet logging noise on open
Date: Tue, 17 Nov 2015 16:42:31 -0500
Message-ID: <1447796551-8522-1-git-send-email-jon@ringle.org>
Cc: Jon Ringle <jringle@gridpoint.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:36574 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbbKQVmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 16:42:39 -0500
Received: by qgad10 with SMTP id d10so15579540qga.3
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 13:42:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Ringle <jringle@gridpoint.com>

When encx24j600 is open and closed many times due to userspace polling the
interface, the log gets noise with this log message. Change logging level
to debug

Signed-off-by: Jon Ringle <jringle@gridpoint.com>
---
 drivers/net/ethernet/microchip/encx24j600.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
index bf08ce2..a6763c3 100644
--- a/drivers/net/ethernet/microchip/encx24j600.c
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -613,8 +613,8 @@ static int encx24j600_hw_init(struct encx24j600_priv *priv)
 		goto err_out;
 	}
 
-	netif_info(priv, drv, dev, "Silicon rev ID: 0x%02x\n",
-		   (eidled & REVID_MASK) >> REVID_SHIFT);
+	netif_dbg(priv, drv, dev, "Silicon rev ID: 0x%02x\n",
+		  (eidled & REVID_MASK) >> REVID_SHIFT);
 
 	/* PHY Leds: link status,
 	 * LEDA: Link State + collision events
-- 
2.4.1
