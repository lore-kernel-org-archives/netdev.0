From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 04/14] net: emac: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:29 +0200
Message-ID: <20170407081739.5243-5-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34530 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755320AbdDGIRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:46 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in
struct emac_instance, use stats from struct net_device.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/ibm/emac/core.c | 2 +-
 drivers/net/ethernet/ibm/emac/core.h | 1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 0f9cd92fdc5e..508923f39ccf 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -1929,7 +1929,7 @@ static struct net_device_stats *emac_stats(struct net_device *ndev)
 	struct emac_instance *dev = netdev_priv(ndev);
 	struct emac_stats *st = &dev->stats;
 	struct emac_error_stats *est = &dev->estats;
-	struct net_device_stats *nst = &dev->nstats;
+	struct net_device_stats *nst = &ndev->stats;
 	unsigned long flags;
 
 	DBG2(dev, "stats" NL);
diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/ethernet/ibm/emac/core.h
index 0710a6685489..f10e156641d5 100644
--- a/drivers/net/ethernet/ibm/emac/core.h
+++ b/drivers/net/ethernet/ibm/emac/core.h
@@ -265,7 +265,6 @@ struct emac_instance {
 	/* Stats
 	 */
 	struct emac_error_stats		estats;
-	struct net_device_stats		nstats;
 	struct emac_stats 		stats;
 
 	/* Misc
-- 
2.12.2
