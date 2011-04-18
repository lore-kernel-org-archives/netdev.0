From: David Miller <davem@davemloft.net>
Subject: [PATCH 42/42] be2net: Fix unused-but-set variables.
Date: Sun, 17 Apr 2011 17:34:33 -0700 (PDT)
Message-ID: <20110417.173433.214218279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51111
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751536Ab1DRAfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:35:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1400624C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variables 'tx_min' and 'tx_max' are set but not used in
be_set_coalesce().

Similarly for 'region' in be_do_flash().

Just kill them off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/benet/be_ethtool.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 80226e4..0f645a9 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -205,9 +205,9 @@ be_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 	struct be_rx_obj *rxo;
 	struct be_eq_obj *rx_eq;
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
-	u32 tx_max, tx_min, tx_cur;
 	u32 rx_max, rx_min, rx_cur;
 	int status = 0, i;
+	u32 tx_cur;
 
 	if (coalesce->use_adaptive_tx_coalesce == 1)
 		return -EINVAL;
@@ -246,8 +246,6 @@ be_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 		}
 	}
 
-	tx_max = coalesce->tx_coalesce_usecs_high;
-	tx_min = coalesce->tx_coalesce_usecs_low;
 	tx_cur = coalesce->tx_coalesce_usecs;
 
 	if (tx_cur > BE_MAX_EQD)
@@ -664,11 +662,9 @@ be_do_flash(struct net_device *netdev, struct ethtool_flash *efl)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	char file_name[ETHTOOL_FLASH_MAX_FILENAME];
-	u32 region;
 
 	file_name[ETHTOOL_FLASH_MAX_FILENAME - 1] = 0;
 	strcpy(file_name, efl->data);
-	region = efl->region;
 
 	return be_load_fw(adapter, file_name);
 }
-- 
1.7.4.3

