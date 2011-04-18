From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: [PATCH] net: dm9000: Fix build
Date: Mon, 18 Apr 2011 12:04:37 +0100
Message-ID: <1303124677-6168-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Cc: netdev@vger.kernel.org, patches@opensource.wolfsonmicro.com,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
To: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:36520 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752422Ab1DRLEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 07:04:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c88fcb (net: dm9000: convert to hw_features) broke the build of
the dm9000 driver since it merged functions which use different names
for the board info structure used for I/O operations without updating
all the references to use the same name. Fix that.

Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
---
 drivers/net/dm9000.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index f7bdebb..fbaff35 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -768,7 +768,7 @@ dm9000_init_dm9000(struct net_device *dev)
 
 	/* Checksum mode */
 	if (dev->hw_features & NETIF_F_RXCSUM)
-		iow(dm, DM9000_RCSR,
+		iow(db, DM9000_RCSR,
 			(dev->features & NETIF_F_RXCSUM) ? RCSR_CSUM : 0);
 
 	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
-- 
1.7.4.1

