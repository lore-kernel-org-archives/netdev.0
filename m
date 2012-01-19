From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/9] igbvf: Remove unnecessary irq disable/enable
Date: Thu, 19 Jan 2012 00:13:29 -0800
Message-ID: <1326960814-16976-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23062 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754427Ab2ASINy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 03:13:54 -0500
In-Reply-To: <1326960814-16976-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

This irq disable/enable pair used to wrap access to the driver's vlgrp
struct, which is no longer present. So, then, this could also so no longer
be present.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index fd3da30..a4b20c8 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1194,11 +1194,6 @@ static int igbvf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
-	igbvf_irq_disable(adapter);
-
-	if (!test_bit(__IGBVF_DOWN, &adapter->state))
-		igbvf_irq_enable(adapter);
-
 	if (hw->mac.ops.set_vfta(hw, vid, false)) {
 		dev_err(&adapter->pdev->dev,
 		        "Failed to remove vlan id %d\n", vid);
-- 
1.7.7.5
