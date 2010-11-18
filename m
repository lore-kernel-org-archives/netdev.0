From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH 4/4] net: caif: spi: fix potential NULL dereference
Date: Thu, 18 Nov 2010 21:17:05 +0300
Message-ID: <1290104226-31428-1-git-send-email-segoon@openwall.com>
Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:63347 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760095Ab0KRSRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 13:17:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc_netdev() is not checked here for NULL return value.  dev is
check instead.  It might lead to NULL dereference of ndev.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 Compile tested.
 Maybe dev is also must be checked here, but it looks like a trivial typo.

 drivers/net/caif/caif_spi.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 8b4cea5..20da199 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -635,8 +635,8 @@ int cfspi_spi_probe(struct platform_device *pdev)
 
 	ndev = alloc_netdev(sizeof(struct cfspi),
 			"cfspi%d", cfspi_setup);
-	if (!dev)
-		return -ENODEV;
+	if (!ndev)
+		return -ENOMEM;
 
 	cfspi = netdev_priv(ndev);
 	netif_stop_queue(ndev);
-- 
1.7.0.4

