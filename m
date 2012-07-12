From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 1/7] be2net: Fix error while toggling autoneg of pause parameters
Date: Thu, 12 Jul 2012 19:26:11 +0530
Message-ID: <bb0a0f55-d3ee-46fe-b951-c54516143f70@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:9048 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933878Ab2GLOB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 10:01:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Autonegotiation of pause parameters is possible only on some PHYs.
Ability of autoneg of pause parameters is reported by adapter.
Autoneg of pause parameters cannot be changed from driver.
Fix driver to give error when autoneg mode is toggled by user.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 63e51d4..e34be1c 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -648,7 +648,7 @@ be_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *ecmd)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status;
 
-	if (ecmd->autoneg != 0)
+	if (ecmd->autoneg != adapter->phy.fc_autoneg)
 		return -EINVAL;
 	adapter->tx_fc = ecmd->tx_pause;
 	adapter->rx_fc = ecmd->rx_pause;
-- 
1.6.0.2
