From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH 1/2] net: tile:  Remove unnecessary memset of netdev private data
Date: Tue, 27 May 2014 14:03:51 +0200
Message-ID: <1401192231-26203-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:36766 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142AbaE0MD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 08:03:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for private data is allocated using kzalloc/vzalloc in
alloc_netdev_mqs, thus there is no need to zero it again in the driver.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/tile/tilegx.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 449011b..0db40de 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -2212,7 +2212,6 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 
 	/* Initialize "priv". */
 	priv = netdev_priv(dev);
-	memset(priv, 0, sizeof(*priv));
 	priv->dev = dev;
 	priv->channel = -1;
 	priv->loopify_channel = -1;
-- 
1.7.9.5
