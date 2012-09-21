From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/1] gianfar: fix phc index build failure
Date: Fri, 21 Sep 2012 07:11:12 +0200
Message-ID: <24134c2d3a9bcbe65f1becd809b98d9c2559212d.1348203988.git.richardcochran@gmail.com>
References: <cover.1348203988.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>, <stable@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59457 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab2IUFL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 01:11:28 -0400
In-Reply-To: <cover.1348203988.git.richardcochran@gmail.com>
In-Reply-To: <cover.1348203988.git.richardcochran@gmail.com>
References: <cover.1348203988.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a build failure introduced in commit 66636287. Not only
was a global variable inconsistently named, but also it was not exported
as it should have been.

This fix is also needed in stable version 3.5.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Cc: <stable@vger.kernel.org>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c |    1 +
 drivers/net/ethernet/freescale/gianfar_ptp.c     |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 8971921..ab6762c 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1773,6 +1773,7 @@ static int gfar_get_nfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
 }
 
 int gfar_phc_index = -1;
+EXPORT_SYMBOL(gfar_phc_index);
 
 static int gfar_get_ts_info(struct net_device *dev,
 			    struct ethtool_ts_info *info)
diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index c08e5d4..0daa66b 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -515,7 +515,7 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 		err = PTR_ERR(etsects->clock);
 		goto no_clock;
 	}
-	gfar_phc_clock = ptp_clock_index(etsects->clock);
+	gfar_phc_index = ptp_clock_index(etsects->clock);
 
 	dev_set_drvdata(&dev->dev, etsects);
 
@@ -539,7 +539,7 @@ static int gianfar_ptp_remove(struct platform_device *dev)
 	gfar_write(&etsects->regs->tmr_temask, 0);
 	gfar_write(&etsects->regs->tmr_ctrl,   0);
 
-	gfar_phc_clock = -1;
+	gfar_phc_index = -1;
 	ptp_clock_unregister(etsects->clock);
 	iounmap(etsects->regs);
 	release_resource(etsects->rsrc);
-- 
1.7.2.5
