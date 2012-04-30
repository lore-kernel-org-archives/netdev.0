From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 2/5] be2net: Fix to apply duplex value as unknown when link is down.
Date: Mon, 30 Apr 2012 11:34:31 +0530
Message-ID: <8783fdf1-630b-4610-b42d-0c7be4f1d7b2@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:42953 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751962Ab2D3GFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 02:05:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Suggested-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index c9ba2cb..747f68f 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -618,7 +618,7 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ecmd->supported = adapter->phy.supported;
 	}
 
-	ecmd->duplex = DUPLEX_FULL;
+	ecmd->duplex = netif_carrier_ok(netdev) ? DUPLEX_FULL : DUPLEX_UNKNOWN;
 	ecmd->phy_address = adapter->port_num;
 
 	return 0;
-- 
1.5.6.1
