From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 09/10] ixgbe: DCB, return max for IEEE traffic classes
Date: Wed,  2 Nov 2011 17:20:00 -0700
Message-ID: <1320279601-1276-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64280 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754452Ab1KCAUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 20:20:09 -0400
In-Reply-To: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Returning the max traffic classes on get requests simplifies
user space configurations because applications will know
explicitly how many traffic classes can be used.

Typical switch implementations use 2 or 3 traffic classes
so this not seen often today. And user space can learn
the number of traffic classes by return codes but this
allows user space to configure ixgbe correctly at the
start.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 3631d63..33b93ff 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -561,11 +561,12 @@ static int ixgbe_dcbnl_ieee_getets(struct net_device *dev,
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ieee_ets *my_ets = adapter->ixgbe_ieee_ets;
 
+	ets->ets_cap = adapter->dcb_cfg.num_tcs.pg_tcs;
+
 	/* No IEEE PFC settings available */
 	if (!my_ets)
-		return -EINVAL;
+		return 0;
 
-	ets->ets_cap = adapter->dcb_cfg.num_tcs.pg_tcs;
 	ets->cbs = my_ets->cbs;
 	memcpy(ets->tc_tx_bw, my_ets->tc_tx_bw, sizeof(ets->tc_tx_bw));
 	memcpy(ets->tc_rx_bw, my_ets->tc_rx_bw, sizeof(ets->tc_rx_bw));
@@ -621,11 +622,12 @@ static int ixgbe_dcbnl_ieee_getpfc(struct net_device *dev,
 	struct ieee_pfc *my_pfc = adapter->ixgbe_ieee_pfc;
 	int i;
 
+	pfc->pfc_cap = adapter->dcb_cfg.num_tcs.pfc_tcs;
+
 	/* No IEEE PFC settings available */
 	if (!my_pfc)
-		return -EINVAL;
+		return 0;
 
-	pfc->pfc_cap = adapter->dcb_cfg.num_tcs.pfc_tcs;
 	pfc->pfc_en = my_pfc->pfc_en;
 	pfc->mbc = my_pfc->mbc;
 	pfc->delay = my_pfc->delay;
-- 
1.7.6.4
