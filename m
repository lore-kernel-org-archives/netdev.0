From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] ixgbe: remove tie between NAPI work limits and interrupt moderation
Date: Mon, 12 Mar 2012 21:03:40 -0700
Message-ID: <1331611432-30109-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43936 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016Ab2CMED5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:03:57 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As noted by Ben Hutchings and David Miller, work limits for NAPI
should not be tied to interrupt moderation parameters.  This
should be handled by NAPI, possibly through sysfs.

Neil Horman & Stephen Hemminger are working on a solution for
NAPI currently.  In the meantime, remove this tie between
work limits and interrupt moderation.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 8e2e473..4846206 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2108,8 +2108,6 @@ static int ixgbe_get_coalesce(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	ec->tx_max_coalesced_frames_irq = adapter->tx_work_limit;
-
 	/* only valid if in constant ITR mode */
 	if (adapter->rx_itr_setting <= 1)
 		ec->rx_coalesce_usecs = adapter->rx_itr_setting;
@@ -2177,9 +2175,6 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	    && ec->tx_coalesce_usecs)
 		return -EINVAL;
 
-	if (ec->tx_max_coalesced_frames_irq)
-		adapter->tx_work_limit = ec->tx_max_coalesced_frames_irq;
-
 	if ((ec->rx_coalesce_usecs > (IXGBE_MAX_EITR >> 2)) ||
 	    (ec->tx_coalesce_usecs > (IXGBE_MAX_EITR >> 2)))
 		return -EINVAL;
@@ -2214,7 +2209,6 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 
 	for (i = 0; i < num_vectors; i++) {
 		q_vector = adapter->q_vector[i];
-		q_vector->tx.work_limit = adapter->tx_work_limit;
 		if (q_vector->tx.count && !q_vector->rx.count)
 			/* tx only */
 			q_vector->itr = tx_itr_param;
-- 
1.7.7.6
