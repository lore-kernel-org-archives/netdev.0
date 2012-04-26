From: Somnath Kotur <Somnath.Kotur@emulex.com>
Subject: [PATCH net-next 3/5] be2net: Fix to apply duplex value as unknown when link is down.
Date: Thu, 26 Apr 2012 19:58:01 +0530
Message-ID: <cf78444f-636f-44c5-beb7-5626b8a3df17@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:47281 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757131Ab2DZOhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 10:37:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>


Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 5296df5..bb2add7 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -618,7 +618,7 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ecmd->supported = adapter->phy.supported;
 	}
 
-	ecmd->duplex = DUPLEX_FULL;
+	ecmd->duplex = netif_carrier_ok(netdev) ? DUPLEX_FULL : -1;
 	ecmd->phy_address = adapter->port_num;
 
 	return 0;
-- 
1.5.6.1
